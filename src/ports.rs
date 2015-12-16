extern crate capnp;

use result;
use result::Result;

use std::collections::HashMap;

use allocator::{Allocator, HeapSenders, IPSender, IPReceiver, IP, HeapIPSender};

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
            let ptr = try!(port.recv());
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

    pub fn recv_array(&self, port_in: String, selection_in: String) -> Result<IP> {
        self.inputs_array.get(&port_in).ok_or(result::Error::PortNotFound)
            .and_then(|port|{
                port.get(&selection_in).ok_or(result::Error::SelectionNotFound)
                    .and_then(|recv| {
                        let ip = try!(recv.recv());
                        Ok(self.allocator.ip.build(ip))
                    })
            })
    }

    pub fn send(&self, port_out: String, ip: IP) -> Result<()> {
        self.outputs.get(&port_out).ok_or(result::Error::PortNotFound)
            .and_then(|port|{
                port.as_ref().ok_or(result::Error::OutputPortNotConnected)
                    .and_then(|sender| {
                        sender.send(ip)
                    })
            })
    }

    pub fn send_array(&self, port_out: String, selection_out: String, ip: IP) -> Result<()> {
        self.outputs_array.get(&port_out).ok_or(result::Error::PortNotFound)
            .and_then(|port| {
                port.get(&selection_out).ok_or(result::Error::SelectionNotFound)
                    .and_then(|sender| {
                        sender.as_ref().ok_or(result::Error::OutputPortNotConnected)
                            .and_then(|sender| {
                                sender.send(ip)
                            })
                    })
            })
    }

    pub fn connect(&mut self, port_out: String, sender: *const HeapIPSender) -> Result<()> {
        if !self.outputs.contains_key(&port_out) {
            return Err(result::Error::PortNotFound);
        }
        let sender = self.allocator.channel.build_sender(sender);
        self.outputs.insert(port_out, Some(sender));
        Ok(())
    }

    pub fn connect_array(&mut self, port_out: String, selection_out: String, sender: *const HeapIPSender) -> Result<()> {
        if !self.outputs_array.contains_key(&port_out) {
            return Err(result::Error::PortNotFound);
        }
        let sender = self.allocator.channel.build_sender(sender);
        self.outputs_array.get_mut(&port_out).ok_or(result::Error::PortNotFound)
            .and_then(|port| {
                if !port.contains_key(&selection_out) {
                    return Err(result::Error::SelectionNotFound);
                }
                port.insert(selection_out, Some(sender));
                Ok(())
            })
    }

    pub fn add_input_selection(&mut self, port_in: String, selection_in: String) -> Result<*const HeapIPSender> {
        let (s, r) = self.allocator.channel.build();
        let r = self.allocator.channel.build_receiver(r);
        self.inputs_array.get_mut(&port_in)
            .ok_or(result::Error::PortNotFound)
            .map(|port| {
                if !port.contains_key(&selection_in) {
                    port.insert(selection_in, r);
                }
                s
            })
    }

    pub fn add_output_selection(&mut self, port_out: String, selection_out: String) -> Result<()> {
        self.outputs_array.get_mut(&port_out)
            .ok_or(result::Error::PortNotFound)
            .map(|port| {
                if !port.contains_key(&selection_out) {
                    port.insert(selection_out, None);
                }
                ()
            })
    }
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

        let mut p1 = Ports::new(&a, senders,
                                vec!["in".into(), "vec".into()],
                                vec!["in_a".into()],
                                vec!["out".into()],
                                vec!["out_a".into()]
                                ).expect("cannot create");

        let mut senders: Box<HeapSenders> = unsafe { transmute(senders) };
        let mut senders = senders.senders;
        assert!(senders.len() == 2);
        let s_in = senders.remove("in").unwrap();

        p1.connect("out".into(), s_in).expect("cannot connect");

        let mut ip = a.ip.build_empty();

        let wrong = p1.try_recv("in".into());
        assert!(wrong.is_err());

        p1.send("out".into(), ip).expect("cannot send");

        let ok = p1.try_recv("in".into());
        assert!(ok.is_ok());

        let mut ip = a.ip.build_empty();
        p1.send("out".into(), ip).expect("cannot send second times");

        let nip = p1.recv("in".into());
        assert!(nip.is_ok());


        // test array ports

        let s_in = p1.add_input_selection("in_a".into(), "1".into()).expect("cannot add input selection");

        p1.add_output_selection("out_a".into(), "a".into());
        p1.connect_array("out_a".into(), "a".into(), s_in).expect("cannot connect array");

        let mut ip = a.ip.build_empty();
        p1.send_array("out_a".into(), "a".into(), ip).expect("cannot send array");

        let nip = p1.recv_array("in_a".into(), "1".into());
        assert!(nip.is_ok());

    }
}
