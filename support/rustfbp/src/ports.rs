//! Utility class to communicate between agents
//!
//! This class provides three structs : IP, Ports and IPSender.


extern crate capnp;
#[allow(unused_imports)]
use std::io::Read;

use result;
use result::Result;

use std::collections::HashMap;
use std::mem;

use std::sync::mpsc::{Sender, Receiver, SyncSender};
use std::sync::mpsc::sync_channel;

use scheduler::CompMsg;

/// Represent an IP
pub struct IP {
    /// The capn'p representation
    pub vec: Vec<u8>,
    /// is the action of the IP
    pub action: String,
    reader: Option<capnp::message::Reader<capnp::serialize::OwnedSegments>>,
    builder: Option<capnp::message::Builder<capnp::message::HeapAllocator>>,
}

impl IP {
    /// Return a new IP
    ///
    /// # Example
    /// ```rust,ignore
    /// let ip = IP::new();
    /// ```
    pub fn new() -> Self {
        IP { vec: vec![],
             action: String::new(),
             reader: None,
             builder: None,
        }
    }

    /// Return a capnp `Reader`
    ///
    /// # Example
    ///
    /// ```rust,ignore
    /// let ip = an_initialized_ip;
    /// {
    ///     let reader: generic_text::Reader = try!(ip.read_schema());
    ///     let text = try!(reader.get_text());
    /// }
    /// ```
    pub fn read_schema<'a, T: capnp::traits::FromPointerReader<'a>>(&'a mut self) -> Result<T> {
        let msg = try!(capnp::serialize::read_message(&mut &self.vec[..], capnp::message::ReaderOptions::new()));
        self.reader = Some(msg);
        Ok(try!(self.reader.as_ref().unwrap().get_root()))
    }

    /// Return a capnp `Builder`
    ///
    /// # Example
    ///
    /// ```rust,ignore
    /// let mut ip = IP::new();
    /// // Initialize the IP
    /// {
    ///     let mut builder: generic_text::Builder = ip.build_schema();
    ///     builder.set_text("Hello Fractalide!");
    /// }
    /// ```
    pub fn build_schema<'a, T: capnp::traits::FromPointerBuilder<'a>>(&'a mut self) -> T {
        let msg = capnp::message::Builder::new_default();
        self.builder = Some(msg);
        self.builder.as_mut().unwrap().init_root()
    }

    /// Return a capnp `Builder` from a capnp `Reader`
    ///
    /// # Example
    ///
    /// ```rust,ignore
    /// let mut ip = an_initialized_ip;
    /// {
    ///     let mut builder = try!(edit_edge::<generic_text::Builder, generic_text::Reader>());
    ///     builder.set_text("Hello Fractalide!");
    /// }
    /// ```
    pub fn edit_schema<'a, T: capnp::traits::FromPointerBuilder<'a>,
                                 U: capnp::traits::FromPointerReader<'a> + capnp::traits::SetPointerBuilder<T>>
        (&'a mut self) -> Result<T> {
        let reader = try!(capnp::serialize::read_message(&mut &self.vec[..], capnp::message::ReaderOptions::new()));
        self.reader = Some(reader);
        let reader: U = try!(self.reader.as_ref().unwrap().get_root());

        let mut msg = capnp::message::Builder::new_default();
        try!(msg.set_root(reader));
        self.builder = Some(msg);
        Ok(try!(self.builder.as_mut().unwrap().get_root()))
    }

    /// Write a capnp `Builder` to a `Vec`
    ///
    /// # Example
    ///
    /// ```rust,ignore
    /// let mut ip = an_initialized_ip;
    /// {
    ///     let mut builder = try!(edit_edge::<generic_text::Builder, generic_text::Reader>());
    ///     builder.set_text("Hello Fractalide!");
    /// }
    /// try!(ip.before_send());
    /// ```
    pub fn before_send(&mut self) -> Result<()> {
        let mut build = mem::replace(&mut self.builder, None);
        if let Some(ref mut b) = build {
            self.vec.clear();
            try!(capnp::serialize::write_message(&mut self.vec, b))
        }
        Ok(())

    }
}

impl Clone for IP {
    fn clone(&self) -> Self {
        IP {
            vec: self.vec.clone(),
            action: self.action.clone(),
            reader: None,
            builder: None,
        }
    }
}

/// A wrapper around `SyncSender<IP>`
///
/// A specific `SyncSender` for the IP object. It also sends information to the scheduler.
#[derive(Clone)]
pub struct IPSender {
    /// The SyncSender, connected to a receiver in another agent
    pub sender: SyncSender<IP>,
    /// The name of the agent owning the receiver
    pub dest: String,
    /// A Sender to the scheduler, to signal that the receiver must be run
    pub sched: Sender<CompMsg>,
}

impl IPSender {
    /// Send an IP to the Receiver
    pub fn send(&self, mut ip: IP) -> Result<()> {
        try!(ip.before_send());
        try!(self.sender.send(ip));
        if self.dest != "" {
            try!(self.sched.send(CompMsg::Inc(self.dest.clone())));
        }
        Ok(())
    }
}

pub trait OutputSend {
    fn send(&self, ip:IP) -> Result<()>;
}

impl OutputSend for Option<IPSender> {
    fn send(&self, ip: IP) -> Result<()> {
        if let &Some(ref sender) = self {
            sender.send(ip)?;
            Ok(())
        } else {
            Err(result::Error::OutputNotConnected)
        }
    }
}


pub struct IPReceiver {
    name: String,
    recv: Receiver<IP>,
    sched: Sender<CompMsg>,
    must_sched: bool,
}

impl IPReceiver {
    pub fn new(name: String, sched: Sender<CompMsg>, must_sched: bool) -> (IPReceiver, IPSender) {
        let (s, r) = sync_channel(25);
        let s = IPSender {
            sender: s,
            dest: if must_sched { name.clone() } else { "".into() },
            sched: sched.clone(),
        };
        let r = IPReceiver {
            recv: r,
            name: name,
            sched: sched,
            must_sched: must_sched,
        };
        (r, s)
    }

    pub fn recv(&self) -> Result<IP> {
        let ip = try!(self.recv.recv());
        if self.must_sched {
            try!(self.sched.send(CompMsg::Dec(self.name.clone())));
        }
        Ok(ip)
    }

    pub fn try_recv(&self) -> Result<IP> {
        let ip = self.recv.try_recv()?;
        if self.must_sched {
            try!(self.sched.send(CompMsg::Dec(self.name.clone())));
        }
        Ok(ip)
    }
}
