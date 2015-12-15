extern crate capnp;

use std::mem;

use result;
use result::Result;

use std::collections::HashMap;
use std::collections::hash_map::Keys;

use std::io::{Write, Read};

use allocator::{Allocator, HeapSenders, IPSender, IPReceiver, IP};

pub struct Ports {
    allocator: Allocator,
    inputs: HashMap<String, IPReceiver>,
    inputs_array: HashMap< String, HashMap<String, IPReceiver>>,
    outputs: HashMap<String, Option<IPSender>>,
    outputs_array: HashMap<String, HashMap<String, Option<IPSender>>>,
}

impl Ports {
    pub fn new(allocator: &Allocator, senders: *mut HeapSenders,
               n_input: Vec<String>, n_input_array: Vec<String>,
               n_output: Vec<String>, n_output_array: Vec<String>) -> Result<Self> {
        let senders = allocator.senders.build(senders);
        let mut inputs = HashMap::new();
        for i in n_input {
            let (s, r) = allocator.channel.build();
            senders.add_ptr(&i, s);
            let r = allocator.channel.build_receiver(r);
            inputs.insert(i, r);
        }
        let mut inputs_array = HashMap::new();
        for i in n_input_array { inputs_array.insert(i, HashMap::new()); }
        let mut outputs = HashMap::new();
        for i in n_output { outputs.insert(i, None); }
        let mut outputs_array = HashMap::new();
        for i in n_output_array { outputs_array.insert(i, HashMap::new()); }
        Ok(Ports {
            allocator: allocator.clone(),
            inputs: inputs,
            inputs_array: inputs_array,
            outputs: outputs,
            outputs_array: outputs_array,
        })
    }

    pub fn get_input_selections(&self, port_in: &'static str) -> Result<Vec<String>> {
        self.inputs_array.get(port_in).ok_or(result::Error::PortNotFound)
            .map(|port| {
                port.keys().cloned().collect()
            })
    }

    pub fn get_output_selections(&self, port_out: &'static str) -> Result<Vec<String>> {
        self.outputs_array.get(port_out).ok_or(result::Error::PortNotFound)
            .map(|port| {
                port.keys().cloned().collect()
            })
    }

    pub fn recv(&self, port_in: String) -> Result<IP> {
        if let Some(ref mut port) = self.inputs.get(&port_in) {
            let mut ptr = try!(port.recv());
            Ok(self.allocator.ip.build(ptr))
        } else {
            Err(result::Error::PortNotFound)
        }
    }

    pub fn try_recv(&self, port_in: String) -> Result<IP> {
        if let Some(ref mut port) = self.inputs.get(&port_in) {
            let ip = try!(port.try_recv());
            Ok(self.allocator.ip.build(ip))
        } else {
            Err(result::Error::PortNotFound)
        }
    }
/*
    // Input ports
    pub fn recv_vecu8(&mut self, port_in: String) -> Result<Vec<u8>> {
        if let Some(ref mut port) = self.buffers.get_mut(&port_in) {
            if port.len() > 0 {
                // for number of IPs
                if port_in != "acc".to_string() && port_in != "option".to_string() {
                    try!(self.sched.write_all(&format!("0{}", self.name_comp.clone()).into_bytes()));
                }

                return Ok(port.remove(0));
            }
        } else {
            return Err(result::Error::PortNotFound);
        }
        self.socket_recv_vecu8();
        self.recv_vecu8(port_in)
    }

    pub fn recv(&mut self, port_in: String) -> Result<capnp::message::Reader<capnp::serialize::OwnedSegments>> {
        let mut msg = try!(self.recv_vecu8(port_in));
        capnp::serialize::read_message(&mut &msg[..], capnp::message::ReaderOptions::new()).map_err(|e| {
            From::from(e)
        })
    }

    pub fn recv_array_vecu8(&mut self, port_in: String, selection_in: String) -> Result<Vec<u8>> {
        if let Some(ref mut port) = self.buffers_array.get_mut(&port_in) {
            if let Some(ref mut vec) = port.get_mut(&selection_in) {
                if vec.len() > 0 {
                    // for number of IPs
                    if port_in != "acc".to_string() && port_in != "option".to_string() {
                        try!(self.sched.write_all(&format!("0{}", self.name_comp.clone()).into_bytes()));
                    }
                    return Ok(vec.remove(0));
                }
            } else { return Err(result::Error::SelectionNotFound); }
        } else {
            return Err(result::Error::PortNotFound);
        }
        self.socket_recv_vecu8();
        self.recv_array_vecu8(port_in, selection_in)
    }

    pub fn recv_array(&mut self, port_in: String, selection_in: String) -> Result<capnp::message::Reader<capnp::serialize::OwnedSegments>> {
        let mut msg = try!(self.recv_array_vecu8(port_in, selection_in));
        capnp::serialize::read_message(&mut &msg[..], capnp::message::ReaderOptions::new()).map_err(|e| {
            From::from(e)
        })
    }

    pub fn try_recv_vecu8(&mut self, port_in: String) -> Result<Option<Vec<u8>>> {
        let mut res = self.socket_try_recv_vecu8();
        while res.is_ok() {
            res = self.socket_try_recv_vecu8();
        }
        if let Some(ref mut port) = self.buffers.get_mut(&port_in) {
            if port.len() > 0 {
                // for number of IPs
                if port_in != "acc".to_string() && port_in != "option".to_string() {
                    try!(self.sched.write_all(&format!("0{}", self.name_comp.clone()).into_bytes()));
                }

                return Ok(Some(port.remove(0)));
            }
        } else {
            return Err(result::Error::PortNotFound);
        }
        Ok(None)
    }

    pub fn try_recv(&mut self, port_in: String) -> Result<Option<capnp::message::Reader<capnp::serialize::OwnedSegments>>> {
        let mut msg = try!(self.try_recv_vecu8(port_in));
        match msg {
            Some(m) => {
                capnp::serialize::read_message(&mut &m[..], capnp::message::ReaderOptions::new())
                    .map(|m| {
                        Some(m)
                    })
                    .map_err(|e| {
                        From::from(e)
                    })
            }
            None => {
                Ok(None)
            }
        }
    }

    fn push_msg(&mut self, mut msg: Vec<u8>) -> Result<()> {
        // feed the buffers with the message
        let comp_name_size = msg.remove(0);
        let (comp_name, msg) = msg.split_at(comp_name_size as usize);
        let (selection_size, msg) = msg.split_at(1);
        let (selection_name, msg) = msg.split_at(selection_size[0] as usize);
        let comp_name = try!(String::from_utf8(comp_name.to_vec()));
        let selection_name = try!(String::from_utf8(selection_name.to_vec()));
        if selection_size[0] == 0 {
            if let Some(vec) = self.buffers.get_mut(&comp_name) {
                vec.push(msg.to_vec());
            } else {
                return Err(result::Error::PortNotFound);
            }
        } else {
            if let Some(port) = self.buffers_array.get_mut(&comp_name) {
                if let Some(vec) = port.get_mut(&selection_name) {
                    vec.push(msg.to_vec());
                } else {
                    return Err(result::Error::SelectionNotFound);
                }
            } else {
                return Err(result::Error::PortNotFound);
            }
        }
        Ok(())
    }

    fn socket_recv_vecu8(&mut self) -> Result<()> {
        let mut msg: Vec<u8> = Vec::new();
        {
            let mut reader = &mut self.input as &mut ::std::io::Read;
            try!(reader.read_to_end(&mut msg));
        }

        self.push_msg(msg)
    }

    fn socket_try_recv_vecu8(&mut self) -> Result<()> {
        let mut msg: Vec<u8> = Vec::new();
        try!(self.input.nb_read_to_end(&mut msg));

        self.push_msg(msg)
    }

    pub fn send_vecu8(&mut self, port_out: String, msg: &Vec<u8>) -> Result<()> {
        let mut final_addr = String::new();
        let mut comp = String::new();
        let mut port = String::new();
        let mut final_msg: Vec<u8> = vec![];
        {
            let address = self.connection.get(&port_out).ok_or(result::Error::PortNotFound).unwrap();
            match *address {
                Some(ref a) => {
                    final_addr = format!("tcp://{}:{}", self.name_sched, a.0);
                    comp = a.0.clone();
                    port = a.1.clone();
                    final_msg.push(a.1.len() as u8);
                    final_msg.append(&mut a.1.clone().into_bytes().to_vec());
                    match a.2 {
                        Some(ref select) => {
                            final_msg.push(select.len() as u8);
                            final_msg.append(&mut select.clone().into_bytes().to_vec());
                        }
                        None => {
                            final_msg.push(0 as u8);
                        }
                    };
                    final_msg.extend(msg);
                },
                None => { return Err(result::Error::OutputPortNotConnected); }
            }
        }
        self.send_address_vecu8(final_addr, comp, port, &final_msg)
    }

    /// Send a message to the OutputPort.
    pub fn send<A: capnp::message::Allocator>(&mut self, port_out: String, mut msg: &capnp::message::Builder<A>) -> Result<()> {
        let mut msg_u8: Vec<u8> = vec![];
        try!(capnp::serialize::write_message(&mut msg_u8, &mut msg));
        self.send_vecu8(port_out, &msg_u8)
    }

    pub fn send_array_vecu8(&mut self, port_out: String, selection_out: String, msg: &Vec<u8>) -> Result<()> {
        let mut final_addr = String::new();
        let mut comp = String::new();
        let mut port = String::new();
        let mut final_msg: Vec<u8> = vec![];
        {
            let address = self.connection_array.get(&port_out).ok_or(result::Error::PortNotFound).unwrap();
            let address = address.get(&selection_out).ok_or(result::Error::SelectionNotFound).unwrap();
            match *address {
                Some(ref a) => {
                    final_addr = format!("tcp://{}:{}", self.name_sched, a.0);
                    comp = a.0.clone();
                    port = a.1.clone();
                    final_msg.push(a.1.len() as u8);
                    final_msg.append(&mut a.1.clone().into_bytes().to_vec());
                    match a.2 {
                        Some(ref select) => {
                            final_msg.push(select.len() as u8);
                            final_msg.append(&mut select.clone().into_bytes().to_vec());
                        }
                        None => {
                            final_msg.push(0 as u8);
                        }
                    };
                    final_msg.extend(msg);
                },
                None => { return Err(result::Error::OutputPortNotConnected); }
            }
        }
        self.send_address_vecu8(final_addr, comp, port, &final_msg)
    }

    /// Send a message to the OutputPort.
    pub fn send_array<A: capnp::message::Allocator>(&mut self, port_out: String, selection_out: String, mut msg: &capnp::message::Builder<A>) -> Result<()> {
        let mut msg_u8: Vec<u8> = vec![];
        try!(capnp::serialize::write_message(&mut msg_u8, &mut msg));
        self.send_array_vecu8(port_out, selection_out, &msg_u8)
    }

    pub fn send_address_vecu8(&mut self, address: String, comp_in: String, port_in: String, msg: &Vec<u8>) -> Result<()>{
        if self.output_endpoint.is_none() || self.output_last != address {
            if let Some(ref mut ep) = self.output_endpoint {
                try!(ep.shutdown());
            }
            self.output_endpoint = Some(try!(self.output.connect(&address)));
        }
        try!(self.output.write_all(&msg));
        if port_in != "acc".to_string() && port_in != "option".to_string() {
            try!(self.sched.write_all(&format!("1{}", comp_in).into_bytes()));
        }
        self.output_last = address;
        Ok(())
    }

    pub fn connect(&mut self, port_out: String, comp_in: String, port_in: String, selection_in: Option<String>) -> Result<()> {
        self.connection.insert(port_out, Some((comp_in, port_in, selection_in)));
        Ok(())
    }

    pub fn connect_array(&mut self, port_out: String, selection_out: String, comp_in: String, port_in: String, selection_in: Option<String>) -> Result<()> {
        self.connection_array.get_mut(&port_out)
            .ok_or(result::Error::PortNotFound)
            .map(|port| {
                port.insert(selection_out, Some((comp_in, port_in, selection_in)));
                ()
            })
    }

    pub fn add_input_selection(&mut self, port_in: String, selection_in: String) -> Result<()> {
        self.buffers_array.get_mut(&port_in)
            .ok_or(result::Error::PortNotFound)
            .map(|port| {
                if !port.contains_key(&selection_in) {
                    port.insert(selection_in, vec![]);
                }
                ()
            })
    }

    pub fn add_output_selection(&mut self, port_out: String, selection_out: String) -> Result<()> {
        self.connection_array.get_mut(&port_out)
            .ok_or(result::Error::PortNotFound)
            .map(|port| {
                if !port.contains_key(&selection_out) {
                    port.insert(selection_out, None);
                }
                ()
            })
    }
    */
}

mod test_port {
    use super::Ports;
    use allocator::*;

    use std::mem::transmute;


    #[test]
    fn ports() {
        assert!(1==1);
        let a = Allocator::new();
        let senders = (a.senders.create)();

        let mut p1 = Ports::new(&a, senders, vec!["in".into(), "vec".into()], vec![], vec![], vec![]).expect("cannot create");

        let mut senders: Box<HeapSenders> = unsafe { transmute(senders) };
        let mut senders = senders.senders;
        assert!(senders.len() == 2);
        let s_in = senders.remove("in").unwrap();
        let s_in = a.channel.build_sender(s_in);

        let mut ip = a.ip.build_empty();

        let wrong = p1.try_recv("in".into());
        assert!(wrong.is_err());

        s_in.send(ip);

        let ok = p1.try_recv("in".into());
        assert!(ok.is_ok());

        let mut ip = a.ip.build_empty();
        s_in.send(ip);
        let nip = p1.recv("in".into());
        assert!(nip.is_ok());

        drop(s_in);
        let nip = p1.recv("in".into());
        assert!(nip.is_err());




        // let mut sched = Socket::new(Protocol::Pull).expect("cannot create sc hed");
        // sched.bind("tcp://127.1.0.1:30000".into()).expect("cannot bind");

        // {
        // let mut p1 = Ports::new("127.1.0.1".into(), "30001".into(), vec!["in".into()], vec![], vec!["out".into(), "o2".into()], vec![]).expect("cannot create");
        // let mut p2 = Ports::new("127.1.0.1".into(), "30002".into(), vec!["a".into(), "b".into()], vec![], vec!["out".into()], vec![]).expect("cannot create");
        // p1.connect("out".into(), "30002".into(), "a".into(), None).expect("cannot connect");
        // p1.connect("o2".into(), "30002".into(), "b".into(), None).expect("cannot connect");

        // p1.send_vecu8("o2".into(), &vec![3, 4]).expect("cannot send");
        // p1.send_vecu8("out".into(), &vec![1, 2]).expect("cannot send");
        // let msg = p2.recv_vecu8("a".into()).expect("cannot receive");
        // assert!(msg == vec![1, 2]);
        // let msg = p2.recv_vecu8("b".into()).expect("cannot receive");
        // assert!(msg == vec![3, 4]);
        // }

        // let mut p1 = Ports::new("127.1.0.1".into(), "30001".into(), vec![], vec![], vec![], vec!["num".into()]).expect("cannot create");
        // let mut p2 = Ports::new("127.1.0.1".into(), "30002".into(), vec![], vec!["num".into()], vec![], vec![]).expect("cannot create");
        // p1.add_output_selection("num".into(), "first".into()).expect("cannot add output");
        // p2.add_input_selection("num".into(), "a".into()).expect("cannot add input");
        // p1.connect_array("num".into(), "first".into(), "30002".into(), "num".into(), Some("a".into())).expect("cannot connect");
        // p1.send_array_vecu8("num".into(), "first".into(), &vec![1, 2]).expect("cannot send");
        // let msg = p2.recv_array_vecu8("num".into(), "a".into()).expect("cannot receive");
        // assert!(msg == vec![1, 2]);
    }
}
