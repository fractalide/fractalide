extern crate nanomsg;
extern crate capnp;

use nanomsg::{Socket, Protocol, Endpoint};
use std::mem;

use result;
use result::Result;

/// Represent a output port.
pub struct OutputPort {
    data: Option<(String, String, String)>,
    send_comp: Socket,
    end_point_comp: Option<Endpoint>,
    send_sched: Socket,
    end_point_sched: Option<Endpoint>,
}

impl OutputPort {
    /// Create a new unconnected OutputPort structure.
    pub fn new() -> Result<Self> {
        let comp = try!(Socket::new(Protocol::Push)); 
        let sched = try!(Socket::new(Protocol::Push)); 
        Ok(OutputPort { 
            data: None,
            send_comp: comp,
            end_point_comp: None,
            send_sched: sched, 
            end_point_sched: None,
        })
    }

    /// Connect the OutputSener structure with the given SyncSender
    pub fn connect(&mut self, sched: String, comp_in: String, port_in: String) -> Result<()>{
        let address = &format!("inproc://{}/{}/{}", sched, comp_in, port_in);
        self.end_point_comp = Some(try!(self.send_comp.connect(address)));
        self.end_point_sched = Some(try!(self.send_sched.connect(&format!("inproc://{}", sched))));
        self.data = Some((sched, comp_in, port_in));
        Ok(())
    }

    /// Disconect
    pub fn disconnect(&mut self) -> Result<Option<(String, String, String)>> {
        // Component socket
        let mut endpoint = mem::replace(&mut self.end_point_comp, None);
        endpoint.as_mut().map(|ep| {
            ep.shutdown().map_err(|_|{ return result::Error::NanomsgCannotShutdown; }).ok();
        });
        // Scheduler socket
        let mut endpoint = mem::replace(&mut self.end_point_sched, None);
        endpoint.as_mut().map(|ep| {
            ep.shutdown().map_err(|_|{ return result::Error::NanomsgCannotShutdown; }).ok();
        });
        Ok(mem::replace(&mut self.data, None))
    }

    /// Send a message to the OutputPort. 
    pub fn send<A: capnp::message::Allocator>(&mut self, mut msg: &capnp::message::Builder<A>) -> Result<()> {
        if self.end_point_comp.is_none() {
            Err(result::Error::OutputPortNotConnected)
        } else {
            let mut msg_u8: Vec<u8> = vec![];
            try!(capnp::serialize::write_message(&mut msg_u8, &mut msg));
            try!(self.send_comp.nb_write(&msg_u8));
            if let Some(ref t) = self.data {
                let c = & t.1;
                try!(self.send_sched.nb_write(&format!("1{}", c.clone()).into_bytes()));
            };
            Ok(()) 
        }
    }

}

pub struct InputPort {
    name: String,
    recv: Socket,
    end_point: Endpoint,
    sched: Socket,
    end_point_sched: Endpoint,
}
impl InputPort {
    pub fn new(sched: String, comp_out: String, port_out: String) -> Result<Self> {
        let mut socket = try!(Socket::new(Protocol::Pull));
        let mut s_sched = try!(Socket::new(Protocol::Push));
        let ep = try!(socket.bind(&format!("inproc://{}/{}/{}", sched, comp_out, port_out)));
        let ep_sched = try!(s_sched.connect(&format!("inproc://{}", sched)));
        Ok(InputPort {
            name: comp_out,
            recv: socket,
            end_point: ep,
            sched: s_sched,
            end_point_sched: ep_sched,
        })
    }

    pub fn recv(&mut self) -> Result<capnp::message::Reader<capnp::serialize::OwnedSegments>> {
        let mut reader = &mut self.recv as &mut ::std::io::Read;
        let mut msg = Vec::new();
        try!(reader.read_to_end(&mut msg));

        // for number of IPs
        try!(self.sched.nb_write(&format!("0{}", self.name.clone()).into_bytes()));

        capnp::serialize::read_message(&mut &msg[..], capnp::message::ReaderOptions::new()).map_err(|e| {
            From::from(e)
        })

    }

    pub fn try_recv(&mut self) -> Result<capnp::message::Reader<capnp::serialize::OwnedSegments>> {
        let mut msg = Vec::new();
        try!(self.recv.nb_read_to_end(&mut msg));

        // For number of IP
        try!(self.sched.nb_write(&format!("0{}", self.name.clone()).into_bytes()));

        capnp::serialize::read_message(&mut &msg[..], capnp::message::ReaderOptions::new())
                          .map_err(|e| { From::from(e) })
    }

    pub fn shutdown(&mut self) -> Result<()> {
        try!(self.end_point.shutdown());
        try!(self.end_point_sched.shutdown());
        Ok(())
    }
}
