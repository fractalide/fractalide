#![feature(braced_empty_structs)]
#[macro_use]
extern crate rustfbp;

// TODO : test array2array

extern crate capnp;
mod number_capnp {
    include!("./schema/number_capnp.rs");
}
use number_capnp::number;

use rustfbp::loader::ComponentBuilder;
use rustfbp::scheduler::Scheduler;
use rustfbp::ports::Ports;

use rustfbp::subnet::*;
use rustfbp::allocator::{Allocator, HeapSenders, HeapIP};

use std::mem::transmute;

use std::thread;
use std::sync::mpsc::channel;

// #[test]
// fn many() {
//     let inc = ComponentBuilder::new("./tests/libinc.so");
//     let mut sched = Scheduler::new();
// 
//     for i in 1..10000 {
//         sched.add_component(i.to_string(), &inc);
//     }
// 
//     sched.join();
// }

#[test]
fn simple_port() {
    let inc = ComponentBuilder::new("./tests/libinc.so");
    {
        let (s, r) = channel();
        let a = Allocator::new(s);
        let senders = (a.senders.create)();
        let comp = inc.build(&"hello".to_string(), &a, senders);
        assert!(comp.is_input_ports(), true);
    }

    let mut sched = Scheduler::new();
    sched.add_component("inc".into(), &inc);

    let senders = (sched.allocator.senders.create)();
    let mut p = Ports::new("exterior".into(), &sched.allocator, senders,
                           vec!["r".into()],
                           vec![],
                           vec!["s".into()],
                           vec![]).expect("cannot create");
    let hs = HeapSenders::from_raw(senders);
    sched.inputs.insert("exterior".into(), hs);

    p.connect("s".into(), sched.get_sender("inc".into(), "input".into()).unwrap()).expect("unable to connect");
    sched.connect("inc".into(), "output".into(), "exterior".into(), "r".into()).expect("cannot connect");

    let mut msg = capnp::message::Builder::new_default();
    {
        let mut number = msg.init_root::<number::Builder>();
        number.set_number(0);
    }

    let mut ip = sched.allocator.ip.build_empty();
    ip.write_builder(&msg);

    p.send("s".into(), ip).expect("unable to send to comp");

    let mut ip_recv = p.recv("r".into()).expect("cannot receive");

    let msg = ip_recv.get_reader().expect("test : cannot get reader");
    let n: number::Reader = msg.get_root().expect("test : not a date reader");

    assert_eq!(n.get_number(), 1);
    sched.join();

}

#[test]
fn option_port() {
    let inc = ComponentBuilder::new("./tests/libinc_opt.so");
    {
        let (s, r) = channel();
        let a = Allocator::new(s);
        let senders = (a.senders.create)();
        let comp = inc.build(&"hello".to_string(), &a, senders);
        assert!(comp.is_input_ports(), true);
    }

    let mut sched = Scheduler::new();
    sched.add_component("inc".into(), &inc);

    let senders = (sched.allocator.senders.create)();
    let mut p = Ports::new("exterior".into(), &sched.allocator, senders,
                           vec!["r".into()],
                           vec![],
                           vec!["s".into(), "opt".into()],
                           vec![]).expect("cannot create");
    let hs = HeapSenders::from_raw(senders);
    sched.inputs.insert("exterior".into(), hs);

    p.connect("s".into(), sched.get_sender("inc".into(), "input".into()).unwrap()).expect("unable to connect");
    p.connect("opt".into(), sched.get_sender("inc".into(), "option".into()).unwrap()).expect("unable to connect");
    sched.connect("inc".into(), "output".into(), "exterior".into(), "r".into()).expect("cannot connect");

    let mut msg = capnp::message::Builder::new_default();
    {
        let mut number = msg.init_root::<number::Builder>();
        number.set_number(4);
    }

    let mut ip = sched.allocator.ip.build_empty();
    ip.write_builder(&msg);
    p.send("s".into(), ip).expect("unable to send to comp");

    let mut ip = sched.allocator.ip.build_empty();
    ip.write_builder(&msg);
    p.send("opt".into(), ip).expect("unable to send to comp");

    let mut ip_recv = p.recv("r".into()).expect("cannot receive");

    let msg = ip_recv.get_reader().expect("test : cannot get reader");
    let n: number::Reader = msg.get_root().expect("test : not a date reader");

    assert_eq!(n.get_number(), 8);
    sched.join();

}
#[test]
fn array_input_port() {
    let add = ComponentBuilder::new("./tests/libadd.so");

    let mut sched = Scheduler::new();
    sched.add_component("add".into(), &add);

    sched.add_input_array_selection("add".into(), "numbers".into(), "first".into());
    sched.add_input_array_selection("add".into(), "numbers".into(), "second".into());

    assert!(sched.inputs_array.len() == 2);

    let senders = (sched.allocator.senders.create)();
    let mut p = Ports::new("exterior".into(), &sched.allocator, senders,
                           vec!["input".into()],
                           vec![],
                           vec!["s1".into(), "s2".into()],
                           vec![]).expect("cannot create");
    let hs = HeapSenders::from_raw(senders);
    sched.inputs.insert("exterior".into(), hs);

    {
        let r1 = sched.get_array_sender("add".into(), "numbers".into(), "first".into()).unwrap();
        let r2 = sched.get_array_sender("add".into(), "numbers".into(), "second".into()).unwrap();
        p.connect("s1".into(), r1).expect("unable to connect");
        p.connect("s2".into(), r2).expect("unable to connect");
        sched.connect("add".into(), "output".into(), "exterior".into(), "input".into()).expect("cannot sched connect");
    }

    let mut msg = capnp::message::Builder::new_default();
    {
        let mut number = msg.init_root::<number::Builder>();
        number.set_number(1);
    }

    let mut ip = sched.allocator.ip.build_empty();
    ip.write_builder(&msg);
    let mut ip2 = sched.allocator.ip.build_empty();
    ip2.write_builder(&msg);

    p.send("s1".into(), ip).expect("unable to send to comp");
    p.send("s2".into(), ip2).expect("unable to send to comp");

    let mut ip = p.recv("input".into()).expect("cannot receive");
    let m = ip.get_reader().expect("cannot get builder");
    let n: number::Reader = m.get_root().expect("not a date reader");
    assert_eq!(n.get_number(), 2);

    sched.join();
}

#[test]
fn array_output_port() {
    let lb = ComponentBuilder::new("./tests/libload_balancer.so");

    let mut sched = Scheduler::new();
    sched.add_component("lb".into(), &lb);

    sched.add_output_array_selection("lb".into(), "outputs".into(), "first".into());
    sched.add_output_array_selection("lb".into(), "outputs".into(), "second".into());

    let senders = (sched.allocator.senders.create)();
    let mut p = Ports::new("exterior".into(), &sched.allocator, senders,
                            vec!["recv1".into(), "recv2".into()],
                            vec![],
                            vec!["acc".into(), "s".into()],
                            vec![]).expect("cannot create receiver");
    let hs = HeapSenders::from_raw(senders);
    sched.inputs.insert("exterior".into(), hs);

    {
        let r1 = sched.get_sender("lb".into(), "input".into()).expect("cannot get sender");
        let acc = sched.get_sender("lb".into(), "acc".into()).expect("cannot get sender");
        p.connect("s".into(), r1).expect("unable to connect");
        p.connect("acc".into(), acc).expect("unable to connect");
        sched.connect_array("lb".into(), "outputs".into(), "first".into(), "exterior".into(), "recv1".into());
        sched.connect_array("lb".into(), "outputs".into(), "second".into(), "exterior".into(), "recv2".into());
    }

    let mut msg = capnp::message::Builder::new_default();
    {
        let mut number = msg.init_root::<number::Builder>();
        number.set_number(4);
    }

    let mut acc = capnp::message::Builder::new_default();
    {
        let mut number = acc.init_root::<number::Builder>();
        number.set_number(0);
    }

    let mut ip1 = sched.allocator.ip.build_empty();
    let mut ip2 = sched.allocator.ip.build_empty();
    let mut ip3 = sched.allocator.ip.build_empty();
    ip1.write_builder(&msg);
    ip2.write_builder(&acc);
    ip3.write_builder(&msg);

    let mut ip_acc = sched.allocator.ip.build_empty();
    ip_acc.write_builder(&acc);

    p.send("s".into(), ip1).expect("unable to send to comp");
    p.send("s".into(), ip2).expect("unable to send to comp");
    p.send("s".into(), ip3).expect("unable to send to comp");
    p.send("acc".into(), ip_acc);

    let mut ip = p.recv("recv1".into()).expect("cannot receive");
    let m = ip.get_reader().expect("cannot get reader");
    let n: number::Reader = m.get_root().expect("not a date reader");
    assert_eq!(n.get_number(), 4);

    let mut ip = p.recv("recv2".into()).expect("cannot receive");
    let m = ip.get_reader().expect("cannot get reader");
    let n: number::Reader = m.get_root().expect("not a date reader");
    assert_eq!(n.get_number(), 0);

    let mut ip = p.recv("recv1".into()).expect("cannot receive");
    let m = ip.get_reader().expect("cannot get reader");
    let n: number::Reader = m.get_root().expect("not a date reader");
    assert_eq!(n.get_number(), 4);

    sched.join();
}

#[test]
fn subnet() {
    let inc = ComponentBuilder::new("./tests/libinc.so");
    let add = ComponentBuilder::new("./tests/libadd.so");
    let lb = ComponentBuilder::new("./tests/libload_balancer.so");

    let sn = GraphBuilder::new()
        .add_component("inc1".into(), &inc)
        .add_component("inc2".into(), &inc)
        .add_component("add".into(), &add)
        .add_component("lb".into(), &lb)
        .add_component("res1".into(), &inc)
        .add_component("res2".into(), &inc)
        .edges()
        .add_simple2array("inc1".into(), "output".into(), "add".into(), "numbers".into(), "first".into())
        .add_simple2array("inc2".into(), "output".into(), "add".into(), "numbers".into(), "second".into())
        .add_simple2simple("add".into(), "output".into(), "lb".into(), "input".into())
        .add_array2simple("lb".into(), "outputs".into(), "first".into(), "res1".into(), "input".into())
        .add_array2simple("lb".into(), "outputs".into(), "second".into(), "res2".into(), "input".into())
        .add_virtual_input_port("a".into(), "inc1".into(), "input".into())
        .add_virtual_input_port("b".into(), "inc2".into(), "input".into())
        .add_virtual_input_port("acc".into(), "lb".into(), "acc".into())
        .add_virtual_output_port("output1".into(), "res1".into(), "output".into())
        .add_virtual_output_port("output2".into(), "res2".into(), "output".into());

    let mut sched = Scheduler::new();

    let senders = (sched.allocator.senders.create)();
    let mut p = Ports::new("exterior".into(), &sched.allocator, senders,
                            vec!["r1".into(), "r2".into()],
                            vec![],
                            vec!["acc".into(), "s1".into(), "s2".into()],
                            vec![]).expect("cannot create receiver");
    let hs = HeapSenders::from_raw(senders);
    sched.inputs.insert("exterior".into(), hs);

    sched.add_subnet("sn".into(), &sn);


    {
        p.connect("s1".into(), sched.get_sender("sninc1".into(), "input".into()).unwrap()).expect("unable to connect");
        p.connect("s2".into(), sched.get_sender("sninc2".into(), "input".into()).unwrap()).expect("unable to connect");
        p.connect("acc".into(), sched.get_sender("snlb".into(), "acc".into()).unwrap()).expect("unable to connect");
    }
    sched.connect("sn".into(), "output1".into(), "exterior".into(), "r1".into()).expect("cannot connect to exterior");
    sched.connect("sn".into(), "output2".into(), "exterior".into(), "r2".into()).expect("cannot connect to exterior");

    let mut msg = capnp::message::Builder::new_default();
    {
        let mut number = msg.init_root::<number::Builder>();
        number.set_number(0);
    }
    let mut msg2 = capnp::message::Builder::new_default();
    {
        let mut number = msg2.init_root::<number::Builder>();
        number.set_number(39);
    }


    let mut ip1 = sched.allocator.ip.build_empty();
    let mut ip2 = sched.allocator.ip.build_empty();
    let mut ip_acc = sched.allocator.ip.build_empty();

    ip1.write_builder(&msg);
    ip2.write_builder(&msg2);
    ip_acc.write_builder(&msg);


    p.send("s1".into(), ip1).expect("unable to send to comp");
    p.send("s2".into(), ip2).expect("unable to send to comp");
    p.send("acc".into(), ip_acc).expect("unable to send to acc");

    let mut ip_recv = p.recv("r1".into()).expect("cannot receive");
    let m = ip_recv.get_reader().expect("unable to get reader");
    let n: number::Reader = m.get_root().expect("not a date reader");
    assert_eq!(n.get_number(), 42);

    let mut msg = capnp::message::Builder::new_default();
    {
        let mut number = msg.init_root::<number::Builder>();
        number.set_number(300);
    }
    let mut msg2 = capnp::message::Builder::new_default();
    {
        let mut number = msg2.init_root::<number::Builder>();
        number.set_number(363);
    }

    let mut ip1 = sched.allocator.ip.build_empty();
    let mut ip2 = sched.allocator.ip.build_empty();

    ip1.write_builder(&msg);
    ip2.write_builder(&msg2);

    p.send("s1".into(), ip1).expect("unable to send to comp");
    p.send("s2".into(), ip2).expect("unable to send to comp");

    let mut ip_recv = p.recv("r2".into()).expect("cannot receive");
    let m = ip_recv.get_reader().expect("cannot get the reader");
    let n: number::Reader = m.get_root().expect("not a date reader");
    assert_eq!(n.get_number(), 666);

    sched.join();

}

#[test]
fn update() {
    let inc = ComponentBuilder::new("./tests/libinc.so");
    {
        let (s, r) = channel();
        let a = Allocator::new(s);
        let senders = (a.senders.create)();
        let comp = inc.build(&"hello".to_string(), &a, senders);
        assert!(comp.is_input_ports(), true);
    }

    let mut sched = Scheduler::new();
    sched.add_component("inc".into(), &inc);

    let senders = (sched.allocator.senders.create)();
    let mut p = Ports::new("exterior".into(), &sched.allocator, senders,
                           vec!["r".into(), "r2".into()],
                           vec![],
                           vec!["s".into()],
                           vec![]).expect("cannot create");
    let hs = HeapSenders::from_raw(senders);
    sched.inputs.insert("exterior".into(), hs);

    p.connect("s".into(), sched.get_sender("inc".into(), "input".into()).expect("cannot get sender")).expect("unable to connect");
    sched.connect("inc".into(), "output".into(), "exterior".into(), "r".into()).expect("cannot connect");

    let mut the_msg = capnp::message::Builder::new_default();
    {
        let mut number = the_msg.init_root::<number::Builder>();
        number.set_number(0);
    }

    let mut ip = sched.allocator.ip.build_empty();
    ip.write_builder(&the_msg);

    p.send("s".into(), ip).expect("unable to send to comp");

    let mut ip_recv = p.recv("r".into()).expect("cannot receive");

    let msg = ip_recv.get_reader().expect("test : cannot get reader");
    let n: number::Reader = msg.get_root().expect("test : not a date reader");

    assert_eq!(n.get_number(), 1);

    sched.disconnect("inc".into(), "output".into()).expect("cannot disconnect");
    sched.connect("inc".into(), "output".into(), "exterior".into(), "r2".into()).expect("cannot reconnect");

    let mut ip = sched.allocator.ip.build_empty();
    ip.write_builder(&the_msg);

    p.send("s".into(), ip).expect("unable to send to comp");

    let mut ip_recv = p.recv("r2".into()).expect("cannot receive");

    let msg = ip_recv.get_reader().expect("test : cannot get reader");
    let n: number::Reader = msg.get_root().expect("test : not a date reader");

    assert_eq!(n.get_number(), 1);
    sched.join();
}
/*

#[test]
fn test_remove() {
    // A running component
    let mut sched = Scheduler::new();
    assert!(sched.components.len() == 0);
    sched.add_component("i".into(), Delay::new());
    let port_a: CountSender<usize> = sched.get_sender("i".into(), "a".into());
    let port_b: CountSender<usize> = sched.get_sender("i".into(), "b".into());
    port_a.send(111).ok().expect("cannot send a");
    thread::sleep_ms(500);
    assert!(sched.components.len() == 1);
    let res = sched.remove_component("i".into());
    assert!(res.is_err());
    assert!(sched.components.len() == 1);
    port_b.send(555).ok().expect("cannot send b");
    thread::sleep_ms(500);
    let res = sched.remove_component("i".into());
    assert!(res.is_ok());
    assert!(sched.components.len() == 0);
    sched.join();

    // A subnet
    let mut sched = Scheduler::new();

    let not = GraphBuilder::new()
        .add_component("inc1".into(), Delay::new)
        .add_component("inc2".into(), Inc::new)
        .edges()
        .add_simple2simple("inc1".into(), "output".into(), "inc2".into(), "input".into())
        .add_virtual_input_port("a".into(), "inc1".into(), "a".into())
        .add_virtual_input_port("b".into(), "inc1".into(), "b".into());
    assert!(sched.components.len() == 0);
    assert!(sched.subnets.len() == 0);
    sched.add_subnet("sub".into(), &not);
    assert!(sched.components.len() == 2);
    assert!(sched.subnets.len() == 1);
    let port_a: CountSender<usize> = sched.get_sender("sub".into(), "a".into());
    let port_b: CountSender<usize> = sched.get_sender("sub".into(), "b".into());
    port_a.send(0).ok().unwrap();
    thread::sleep_ms(500);
    let res = sched.remove_subnet("sub".into());
    assert!(res.is_err());
    assert!(sched.components.len() == 2);
    assert!(sched.subnets.len() == 1);

    port_b.send(3).ok().unwrap();
    thread::sleep_ms(500);
    let res = sched.remove_subnet("sub".into());
    assert!(res.is_ok());
    assert!(sched.components.len() == 0);
    assert!(sched.subnets.len() == 0);

    sched.join();
}

component! {
    Add,
    inputs(a: usize, b: usize),
    inputs_array(),
    outputs(output: usize),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) { 
        let a = self.inputs.a.recv().expect("Add : cannot receive");
        let b = self.inputs.b.recv().expect("Add : cannot receive");
        let _ = self.outputs.output.send(a+b);
    }
}

component! {
    Sub,
    inputs(a: usize, b: usize),
    inputs_array(),
    outputs(output: usize),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) { 
        let a = self.inputs.a.recv().expect("Sub : cannot receive");
        let b = self.inputs.b.recv().expect("Sub : cannot receive");
        let _ = self.outputs.output.send(a-b);
    }
}

component! {
    Display, (T: DebugIP),
    inputs(input: T where T: DebugIP),
    inputs_array(),
    outputs(output: T where T: DebugIP),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) { 
        let msg = self.inputs.input.recv().expect("Debug : cannot receive");
        // println!("{:?}", msg);
        let _ = self.outputs.output.send(msg);
    }
    use std::fmt::Debug;
    pub trait DebugIP: Debug + IP {}
    impl <T> DebugIP for T where T : Debug + IP {}
}

#[test]
fn test_replace() {
    let mut sched = Scheduler::new();
    let (s, r) = channel();
    sched.add_component("display_a".into(), Display::new::<usize>());
    sched.add_component("display_b".into(), Display::new::<usize>());
    sched.add_component("calc".into(), Add::new());

    let (mut i, ii, iia) = Display::new::<usize>();
    let (i_s, i_r) = count_channel::<usize>(16);
    i.connect("output".into(), Box::new(i_s.clone()), "test".into(), s.clone());
    sched.add_component("display_r".into(), (i, ii, iia));

    sched.connect("display_a".into(), "output".into(), "calc".into(), "a".into());
    sched.connect("display_b".into(), "output".into(), "calc".into(), "b".into());
    sched.connect("calc".into(), "output".into(), "display_r".into(), "input".into());

    let port_a: CountSender<usize> = sched.get_sender("display_a".into(), "input".into());
    let port_b: CountSender<usize> = sched.get_sender("display_b".into(), "input".into());

    port_a.send(40).unwrap();
    port_b.send(2).unwrap();
    assert_eq!(i_r.recv().unwrap(), 42);

    let (boxed, ii, iia) = sched.remove_component("calc".into()).ok().expect("unable to remove add").remove("calc").expect("unable to retrieve add");
    let (mut inputs, _, mut outputs, _) = Box::new(boxed).get_receiver_outputport();
    let (mut o, _, _) = Sub::new();
    o.set_receiver("a".into(), inputs.remove("a".into()).expect("no a in calc"));
    o.set_receiver("b".into(), inputs.remove("b".into()).expect("no b in calc"));
    let o_s = outputs.remove("output".into()).expect("no output in add").expect("The output port wasn't connected");
    o.connect("output".into(), o_s, "display_r".into(), sched.sender.clone());
    sched.add_component("calc".into(), (o, ii, iia));

    port_a.send(40).unwrap();
    port_b.send(2).unwrap();
    assert_eq!(i_r.recv().unwrap(), 38);



    sched.join();

    
}
*/
