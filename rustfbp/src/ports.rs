//! Utility class to communicate between components
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
    ///     let reader: generic_text::Reader = try!(ip.get_root());
    ///     let text = try!(reader.get_text());
    /// }
    /// ```
    pub fn get_root<'a, T: capnp::traits::FromPointerReader<'a>>(&'a mut self) -> Result<T> {
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
    ///     let mut builder: generic_text::Builder = ip.init_root();
    ///     builder.set_text("Hello Fractalide!");
    /// }
    /// ```
    pub fn init_root<'a, T: capnp::traits::FromPointerBuilder<'a>>(&'a mut self) -> T {
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
    ///     let mut builder = try!(init_root_from_reader::<generic_text::Builder, generic_text::Reader>());
    ///     builder.set_text("Hello Fractalide!");
    /// }
    /// ```
    pub fn init_root_from_reader<'a, T: capnp::traits::FromPointerBuilder<'a>,
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

    /// Write the capnp `Builer` to the `Vec`
    ///
    /// # Example
    ///
    /// ```rust,ignore
    /// let mut ip = an_initialized_ip;
    /// {
    ///     let mut builder = try!(init_root_from_reader::<generic_text::Builder, generic_text::Reader>());
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

/// An wrapper around `SyncSender<IP>`
///
/// A specific `SyncSender` for the IP object. It also send information to the scheduler.
#[derive(Clone)]
pub struct IPSender {
    /// The SyncSender, connected to a receiver in another component
    pub sender: SyncSender<IP>,
    /// The name of the component owning the receiver
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

/// Represents all the ports of a component
///
/// It provides help to send and receive IP, and to create ports.
pub struct Ports {
    /// The name of the component owning this structure
    name: String,
    /// A Sender to the scheduler owning the component
    sched: Sender<CompMsg>,
    /// All the receiver of the inputs ports
    inputs: HashMap<String, Receiver<IP>>,
    /// All the receiver of the input array ports
    inputs_array: HashMap< String, HashMap<String, Receiver<IP>>>,
    /// Place for the future IPSender in output port (to be connected)
    outputs: HashMap<String, Option<IPSender>>,
    /// Place for the future IPSender in output array port (to be connected)
    outputs_array: HashMap<String, HashMap<String, Option<IPSender>>>,
    /// The IPSender linked corresponding to the input ports
    senders: HashMap<String, IPSender>,
}

impl Ports {
    /// Create a new Ports
    ///
    /// # Example
    /// ```rust,ignore
    /// let ports = try!(Ports::new("component".to_string(),
    ///                        sched_sender,
    ///                        vec!["input".to_string()], vec![],
    ///                        vec!["output".to_string()], vec![]));
    /// let sender = try!(ports.get_sender("input"));
    /// ```
    pub fn new(name: String, sched: Sender<CompMsg>,
               n_input: Vec<String>, n_input_array: Vec<String>,
               n_output: Vec<String>, n_output_array: Vec<String>) -> Result<(Self, HashMap<String, IPSender>)> {
        let mut senders: HashMap<String, IPSender> = HashMap::new();
        let mut inputs = HashMap::new();
        for i in n_input {
            let (s, r) = sync_channel(25);
            let s = IPSender {
                sender: s,
                dest: if i != "acc" && i != "option" { name.clone() } else { "".into() },
                sched: sched.clone(),
            };
            senders.insert(i.clone(), s);
            inputs.insert(i, r);
        }
        let mut inputs_array = HashMap::new();
        for i in n_input_array { inputs_array.insert(i, HashMap::new()); }
        let mut outputs = HashMap::new();
        for i in n_output { outputs.insert(i, None); }
        let mut outputs_array = HashMap::new();
        for i in n_output_array { outputs_array.insert(i, HashMap::new()); }
        let ports = Ports {
            name: name,
            sched: sched,
            inputs: inputs,
            inputs_array: inputs_array,
            outputs: outputs,
            outputs_array: outputs_array,
            senders: senders.clone(),
        };

        Ok((ports, senders))
    }

    /// Get the sender of a input ports
    ///
    /// # Example
    /// ```rust,ignore
    /// let sender = try!(ports.get_sender("input"));
    /// let ip = IP::new();
    /// try!(sender.send(ip));
    /// ```
    pub fn get_sender(&self, port_in: &str) -> Result<IPSender> {
        self.senders.get(port_in).ok_or(result::Error::PortNotFound(self.name.clone(), port_in.into()))
            .map(|sender| {
                sender.clone()
            })
    }

    /// Get the sender of a input array ports
    ///
    /// # Example
    /// ```rust,ignore
    /// let sender = try!(ports.get_sender("inputs", "1"));
    /// let ip = IP::new();
    /// try!(sender.send(ip));
    /// ```
    pub fn get_array_sender(&self, port_name: &str, selection: &str) -> Result<IPSender> {
        self.outputs_array.get(port_name).ok_or(result::Error::PortNotFound(self.name.clone(), port_name.into()))
            .and_then(|port|{
                port.get(selection).ok_or(result::Error::SelectionNotFound(self.name.clone(), port_name.into(), selection.into()))
                    .and_then(|recv| {
                        recv.as_ref().ok_or(result::Error::ArrayOutputPortNotConnected(self.name.clone(), port_name.into(), selection.into()))
                            .and_then(|sender| {
                                Ok(sender.clone())
                            })
                    })
            })
    }

    /// Get the list of the current selections in a array input port
    ///
    /// # Example
    /// ```rust,ignore
    /// let vec = try!(ports.get_input_selections("inputs"));
    /// assert_eq!(vec.length(), 0);
    /// try!(ports.add_input_selection("inputs", "1"));
    /// try!(ports.add_input_selection("inputs", "2"));
    /// let vec = try!(ports.get_input_selections("inputs"));
    /// for i in vec {
    ///     print!("{} ", i);
    /// }
    /// // Produce `1 2`
    /// ```
    pub fn get_input_selections(&self, port_in: &'static str) -> Result<Vec<String>> {
        self.inputs_array.get(port_in).ok_or(result::Error::PortNotFound(self.name.clone(), port_in.into()))
            .map(|port| {
                port.keys().cloned().collect()
            })
    }

    /// Get the list of the current selections in a array output port
    ///
    /// # Example
    /// ```rust,ignore
    /// let vec = try!(ports.get_output_selections("outputs"));
    /// assert_eq!(vec.length(), 0);
    /// try!(ports.add_output_selection("outputs", "1"));
    /// try!(ports.add_output_selection("outputs", "2"));
    /// let vec = try!(ports.get_output_selections("outputs"));
    /// for i in vec {
    ///     print!("{} ", i);
    /// }
    /// // Produce `1 2`
    /// ```
    pub fn get_output_selections(&self, port_out: &'static str) -> Result<Vec<String>> {
        self.outputs_array.get(port_out).ok_or(result::Error::PortNotFound(self.name.clone(), port_out.into()))
            .map(|port| {
                port.keys().cloned().collect()
            })
    }

    /// Receive an IP from an input ports
    ///
    /// # Example
    /// ```rust,ignore
    /// let ip = try!(ports.recv("input"));
    /// println!("{}", ip.action);
    /// ```
    pub fn recv(&self, port_in: &str) -> Result<IP> {
        if let Some(ref mut port) = self.inputs.get(port_in) {
            // Received the IP
            let ip = try!(port.recv());
            if port_in != "acc" && port_in != "option" {
                try!(self.sched.send(CompMsg::Dec(self.name.clone())));
            }
            Ok(ip)
        } else {
            Err(result::Error::PortNotFound(self.name.clone(), port_in.into()))
        }
    }

    /// Try to receive an IP from an input ports
    ///
    /// # Example
    /// ```rust,ignore
    /// while let Ok(ip) = ports.try_recv("input") {
    ///     println!("{}", ip.action);
    /// }
    /// ```
    pub fn try_recv(&self, port_in: &str) -> Result<IP> {
        if let Some(ref mut port) = self.inputs.get(port_in) {
            let ip = try!(port.try_recv());
            if port_in != "acc" && port_in != "option" {
                try!(self.sched.send(CompMsg::Dec(self.name.clone())));
            }
            Ok(ip)
        } else {
            Err(result::Error::PortNotFound(self.name.clone(), port_in.into()))
        }
    }

    /// Receive an IP from an array input ports
    ///
    /// # Example
    /// ```rust,ignore
    /// let ip = try!(ports.recv_array("inputs", "1"));
    /// println!("{}", ip.action);
    /// ```
    pub fn recv_array(&self, port_in: &str, selection_in: &str) -> Result<IP> {
        self.inputs_array.get(port_in).ok_or(result::Error::PortNotFound(self.name.clone(), port_in.into()))
            .and_then(|port|{
                port.get(selection_in).ok_or(result::Error::SelectionNotFound(self.name.clone(), port_in.into(), selection_in.into()))
                    .and_then(|recv| {
                        let ip = try!(recv.recv());
                        if port_in != "acc" && port_in != "option" {
                            try!(self.sched.send(CompMsg::Dec(self.name.clone())));
                        }
                        Ok(ip)
                    })
            })
    }

    /// Try to receive an IP from an array input ports
    ///
    /// # Example
    /// ```rust,ignore
    /// while let Ok(ip) = ports.try_recv_array("input", "1") {
    ///     println!("{}", ip.action);
    /// }
    /// ```
    pub fn try_recv_array(&self, port_in: &str, selection_in: &str) -> Result<IP> {
        self.inputs_array.get(port_in).ok_or(result::Error::PortNotFound(self.name.clone(), port_in.into()))
            .and_then(|port|{
                port.get(selection_in).ok_or(result::Error::SelectionNotFound(self.name.clone(), port_in.into(), selection_in.into()))
                    .and_then(|recv| {
                        let ip = try!(recv.try_recv());
                        if port_in != "acc" && port_in != "option" {
                            try!(self.sched.send(CompMsg::Dec(self.name.clone())));
                        }
                        Ok(ip)
                    })
            })
    }

    /// Send an IP outside, through the output port `port_out`
    ///
    /// # Example
    /// ```rust,ignore
    ///    let ip = IP::new();
    ///    try!(ports.send("output", ip));
    /// ```
    pub fn send(&self, port_out: &str, ip: IP) -> Result<()> {
        self.outputs.get(port_out).ok_or(result::Error::PortNotFound(self.name.clone(), port_out.into()))
            .and_then(|port|{
                port.as_ref().ok_or(result::Error::OutputPortNotConnected(self.name.clone(), port_out.into()))
                    .and_then(|sender| {
                        sender.send(ip)
                    })
            })
    }

    /// Send an IP outside, through the array output port `port_out` with the selection `selection_out`
    ///
    /// # Example
    /// ```rust,ignore
    ///    let ip = IP::new();
    ///    try!(ports.send_array("output", "1", ip));
    /// ```
    pub fn send_array(&self, port_out: &str, selection_out: &str, ip: IP) -> Result<()> {
        self.outputs_array.get(port_out).ok_or(result::Error::PortNotFound(self.name.clone(), port_out.into()))
            .and_then(|port| {
                port.get(selection_out).ok_or(result::Error::SelectionNotFound(self.name.clone(), port_out.into(), selection_out.into()))
                    .and_then(|sender| {
                        sender.as_ref().ok_or(result::Error::ArrayOutputPortNotConnected(self.name.clone(), port_out.into(), selection_out.into()))
                            .and_then(|sender| {
                                sender.send(ip)
                            })
                    })
            })
    }

    /// Send an IP outside, depending of the action
    ///
    /// The component must have a simple output port and an array output port with the same name (IE: output). If the array output port had a selection corresponding to the IP action, the IP will be send on it. Otherwise, the IP is send on the simple output port.
    ///
    /// # Example
    ///
    /// ```rust,ignore
    /// try!(ports.add_output_selection("output", "1"));
    /// let mut ip = IP::new();
    /// ip.action = "2".to_string();
    /// try!(send_action("output", ip)); // Send on the simple output port "output"
    /// let mut ip = IP::new();
    /// ip.action = "1".to_string();
    /// try!(send_action("output", ip)); // Send on the array output port "output", selection "1"
    /// ```
    pub fn send_action(&self, port_out: &'static str, ip: IP) -> Result<()> {
        if try!(self.get_output_selections(&port_out)).contains(&ip.action) {
            self.send_array(&port_out, &ip.action.clone(), ip)
        } else {
            self.send(&port_out, ip)
        }
    }

    /// Connect an simple output port with the IPSender
    ///
    /// ```rust,ignore
    /// try!(ports.connect("output", sender));
    /// ```
    ///
    pub fn connect(&mut self, port_out: String, sender: IPSender) -> Result<()> {
        if !self.outputs.contains_key(&port_out) {
            return Err(result::Error::PortNotFound(self.name.clone(), port_out.into()));
        }
        self.outputs.insert(port_out, Some(sender));
        Ok(())
    }

    /// Connect an array output port with the IPSender
    ///
    /// ```rust,ignore
    /// try!(ports.connect_array("output", "1", sender));
    /// ```
    ///
    pub fn connect_array(&mut self, port_out: String, selection_out: String, sender: IPSender) -> Result<()> {
        let name = self.name.clone();
        if !self.outputs_array.contains_key(&port_out) {
            return Err(result::Error::PortNotFound(name, port_out.into()));
        }
        self.outputs_array.get_mut(&port_out).ok_or(result::Error::PortNotFound(name.clone(), port_out.clone()))
            .and_then(|port| {
                if !port.contains_key(&selection_out) {
                    return Err(result::Error::SelectionNotFound(name, port_out.into(), selection_out.into()));
                }
                port.insert(selection_out, Some(sender));
                Ok(())
            })
    }

    /// Disconnect and retrieve the IPSender of an simple output port
    ///
    /// ```rust,ignore
    /// let sender = try!(ports.disconnect("output"));
    /// ```
    ///
    pub fn disconnect(&mut self, port_out: String) -> Result<Option<IPSender>> {
        if !self.outputs.contains_key(&port_out) {
            return Err(result::Error::PortNotFound(self.name.clone(), port_out.into()));
        }
        let old = self.outputs.insert(port_out, None);
        match old {
            Some(Some(ip_sender)) => {
                Ok(Some(ip_sender))
            }
            _ => { Ok(None) },
        }
    }

    /// Disconnect and retrieve the IPSender of an array output port
    ///
    /// ```rust,ignore
    /// let sender = try!(ports.disconnect_array("outputs", "1"));
    /// ```
    ///
    pub fn disconnect_array(&mut self, port_out: String, selection_out: String) -> Result<Option<IPSender>> {
        if !self.outputs_array.contains_key(&port_out) {
            return Err(result::Error::PortNotFound(self.name.clone(), port_out.into()));
        }
        let name = self.name.clone();
        self.outputs_array.get_mut(&port_out).ok_or(result::Error::PortNotFound(name.clone(), port_out.clone()))
            .and_then(|port| {
                if !port.contains_key(&selection_out) {
                    return Err(result::Error::SelectionNotFound(name, port_out, selection_out));
                }
                let old = port.insert(port_out, None);
                match old {
                    Some(Some(ip_sender)) => {
                        Ok(Some(ip_sender))
                    }
                    _ => { Ok(None) },
                }
            })
    }

    /// Change the receiver of a simple output ports
    ///
    /// usefull if you want to swap a component, but keep the existing connection
    ///
    /// ```rust,ignore
    /// ports.set_receiver("input", receiver);
    /// ```
    pub fn set_receiver(&mut self, port: String, recv: Receiver<IP>) {
        self.inputs.insert(port, recv);
    }

    /// Get the receiver of a simple output ports
    ///
    /// usefull if you want to swap a component, but keep the existing connection
    ///
    /// ```rust,ignore
    /// let receiver = try!(ports.remove_receiver("input"));
    /// ```
    pub fn remove_receiver(&mut self, port: &str) -> Result<Receiver<IP>> {
        self.inputs.remove(port).ok_or(result::Error::PortNotFound(self.name.clone(), port.into()))
            .map(|recv| { recv })
    }

    /// Get the receiver of a array output ports
    ///
    /// usefull if you want to swap a component, but keep the existing connection
    ///
    /// ```rust,ignore
    /// let receiver = try!(ports.remove_array_receiver("inputs", "1"));
    /// ```
    pub fn remove_array_receiver(&mut self, port_name: &str, selection: &str) -> Result<Receiver<IP>> {
        let name = self.name.clone();
        self.inputs_array.get_mut(port_name).ok_or(result::Error::PortNotFound(name.clone(), port_name.into()))
            .and_then(|port| {
                port.remove(selection).ok_or(result::Error::SelectionNotFound(name, port_name.into(), selection.into()))
                    .map(|recv| { recv })
            })
    }

    /// Add a selection in an input array port, and retrieve the corresponding IPSender
    ///
    /// ```rust,ignore
    /// let sender = try!(ports.add_input_selection("inputs", "1"));
    /// ```
    pub fn add_input_selection(&mut self, port_in: &str, selection_in: String) -> Result<IPSender> {
        let (s, r) = sync_channel(25);
        let s = IPSender {
            sender: s,
            dest: self.name.clone(),
            sched: self.sched.clone(),
        };
        self.inputs_array.get_mut(port_in)
            .ok_or(result::Error::PortNotFound(self.name.clone(), port_in.into()))
            .map(|port| {
                port.insert(selection_in, r);
                s
            })
    }

    /// Change the receiver of an array output ports
    ///
    /// usefull if you want to swap a component, but keep the existing connection
    ///
    /// ```rust,ignore
    /// ports.add_input_receiver("input", receiver);
    /// ```
    pub fn add_input_receiver(&mut self, port_in: &str, selection_in: String, r: Receiver<IP>) -> Result<()> {
        self.inputs_array.get_mut(port_in)
            .ok_or(result::Error::PortNotFound(self.name.clone(), port_in.into()))
            .map(|port| {
                port.insert(selection_in, r);
                ()
            })
    }

    /// Add a selection in an input array port
    ///
    /// This selection will be able to be connected to another component
    ///
    /// ```rust,ignore
    /// try!(ports.add_output_selection("inputs", "1"));
    /// ```
    pub fn add_output_selection(&mut self, port_out: &str, selection_out: String) -> Result<()> {
        self.outputs_array.get_mut(port_out)
            .ok_or(result::Error::PortNotFound(self.name.clone(), port_out.into()))
            .map(|port| {
                if !port.contains_key(&selection_out) {
                    port.insert(selection_out, None);
                }
                ()
            })
    }
}

#[allow(unused_imports)]
mod test_port {

    use super::Ports;

    use scheduler::CompMsg;

    use std::sync::mpsc::channel;
    #[test]
    fn ports() {
        assert!(1==1);
        let (s, r) = channel();


        let (mut p1, senders) = Ports::new("unique".into(), s,
                                               vec!["in".into(), "vec".into()],
                                               vec!["in_a".into()],
                                               vec!["out".into()],
                                               vec!["out_a".into()]
                                               ).expect("cannot create");
        assert!(senders.len() == 2);

        let s_in = senders.get("in").unwrap();

        p1.connect("out".into(), s_in.clone()).expect("cannot connect");

        let wrong = p1.try_recv("in");
        assert!(wrong.is_err());

        let ip = super::IP::new();

        p1.send("out", ip).expect("cannot send");

        let ok = p1.try_recv("in");
        assert!(ok.is_ok());

        let ip = super::IP::new();
        p1.send("out", ip).expect("cannot send second times");

        let nip = p1.recv("in");
        assert!(nip.is_ok());
        // test array ports

        let s_in = p1.add_input_selection("in_a", "1".into()).expect("cannot add input selection");

        p1.add_output_selection("out_a".into(), "a".into()).expect("cannot add output");
        p1.connect_array("out_a".into(), "a".into(), s_in).expect("cannot connect array");

        let ip = super::IP::new();
        p1.send_array("out_a", "a", ip).expect("cannot send array");

        let nip = p1.recv_array("in_a", "1");
        assert!(nip.is_ok());

        let i = r.recv().expect("cannot received the sched");
        assert!(
            if let CompMsg::Inc(ref name) = i { name == "unique" } else { false }
            );
        let i = r.recv().expect("cannot received the sched");
        assert!(
            if let CompMsg::Dec(ref name) = i { name == "unique" } else { false }
            );
        let i = r.recv().expect("cannot received the sched");
        assert!(
            if let CompMsg::Inc(ref name) = i { name == "unique" } else { false }
            );
        let i = r.recv().expect("cannot received the sched");
        assert!(
            if let CompMsg::Dec(ref name) = i { name == "unique" } else { false }
            );
        let i = r.recv().expect("cannot received the sched");
        assert!(
            if let CompMsg::Inc(ref name) = i { name == "unique" } else { false }
            );
        let i = r.recv().expect("cannot received the sched");
        assert!(
            if let CompMsg::Dec(ref name) = i { name == "unique" } else { false }
            );
        let i = r.try_recv();
        assert!(i.is_err());
    }
}
