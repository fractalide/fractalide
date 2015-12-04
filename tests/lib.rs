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

use std::thread;

/*
#[test]
fn many() {
    let inc = ComponentBuilder::new("./tests/libinc.so");
    let mut sched = Scheduler::new("127.0.0.1".into());

    for i in 1..200 {
        sched.add_component(i.to_string(), &inc);
    }

    sched.join();
}
*/

#[test]
fn simple_port() {
    let inc = ComponentBuilder::new("./tests/libinc.so");
    {
        let comp = inc.build(&"127.1.1.1".into(), &"30101".into());
        assert!(comp.is_input_ports(), true);
    }

    let mut sched = Scheduler::new("127.1.0.1".into());
    sched.components.insert("res".into(), "29999".into());
    sched.add_component("inc".into(), &inc);

    let mut p = Ports::new("127.1.0.1".into(), "29999".into(), vec!["r".into()], vec![], vec!["s".into()], vec![]).expect("cannot create");

    p.connect("s".into(), sched.components.get("inc").unwrap().clone(), "input".into(), None).expect("unable to connect");
    sched.connect("inc".into(), "output".into(), "res".into(), "r".into());

    let mut msg = capnp::message::Builder::new_default();
    {
        let mut number = msg.init_root::<number::Builder>();
        number.set_number(0);
    }

    thread::sleep_ms(1);
    p.send("s".into(), &msg).expect("unable to send to comp");

    thread::sleep_ms(10);
    sched.start_receive();
    let m = p.recv("r".into()).expect("cannot receive");
    let n: number::Reader = m.get_root().expect("not a date reader");
    assert_eq!(n.get_number(), 1);
    sched.join();

}

#[test]
fn array_input_port() {
    let add = ComponentBuilder::new("./tests/libadd.so");
    {
        let comp = add.build(&"127.2.0.1".into(), &"30101".into());
        assert!(comp.is_input_ports(), true);
    }

    let mut sched = Scheduler::new("127.2.0.1".into());
    sched.components.insert("recv".into(), "29999".into());
    sched.add_component("add".into(), &add);

    sched.add_input_array_selection("add".into(), "numbers".into(), "first".into());
    sched.add_input_array_selection("add".into(), "numbers".into(), "second".into());

    let mut p = Ports::new("127.2.0.1".into(), "29999".into(), vec!["input".into()], vec![], vec!["s1".into(), "s2".into()], vec![]).expect("cannot create");

    {
        let add = sched.components.get("add").unwrap();
        p.connect("s1".into(), add.clone(), "numbers".into(), Some("first".into())).expect("unable to connect");
        p.connect("s2".into(), add.clone(), "numbers".into(), Some("second".into())).expect("unable to connect");
        sched.connect("add".into(), "output".into(), "recv".into(), "input".into());
    }

    let mut msg = capnp::message::Builder::new_default();
    {
        let mut number = msg.init_root::<number::Builder>();
        number.set_number(1);
    }

    thread::sleep_ms(1);
    p.send("s1".into(), &msg).expect("unable to send to comp");
    p.send("s2".into(), &msg).expect("unable to send to comp");

    thread::sleep_ms(1);
    sched.start_receive();
    let m = p.recv("input".into()).expect("cannot receive");
    let n: number::Reader = m.get_root().expect("not a date reader");
    assert_eq!(n.get_number(), 2);

    sched.join();
}

#[test]
fn array_output_port() {
    let lb = ComponentBuilder::new("./tests/libload_balancer.so");
    {
        let comp = lb.build(&"127.3.0.1".into(), &"30111".into());
        assert!(comp.is_input_ports(), true);
    }

    let mut sched = Scheduler::new("127.3.0.1".into());
    sched.add_component("lb".into(), &lb);
    sched.components.insert("recv".into(), "29999".into());

    sched.add_output_array_selection("lb".into(), "outputs".into(), "first".into());
    sched.add_output_array_selection("lb".into(), "outputs".into(), "second".into());

    let mut p = Ports::new("127.3.0.1".into(), "29999".into(),
                           vec!["recv1".into(), "recv2".into()],
                           vec![],
                           vec!["acc".into(), "s".into()],
                           vec![]).expect("cannot create receiver");

    {
        let lb = sched.components.get("lb").unwrap();
        p.connect("s".into(), lb.clone(), "input".into(), None).expect("unable to connect");
        p.connect("acc".into(), lb.clone(), "acc".into(), None).expect("unable to connect");
    }
    sched.connect_array("lb".into(), "outputs".into(), "first".into(), "recv".into(), "recv1".into());
    sched.connect_array("lb".into(), "outputs".into(), "second".into(), "recv".into(), "recv2".into());

    let mut msg = capnp::message::Builder::new_default();
    {
        let mut number = msg.init_root::<number::Builder>();
        number.set_number(1);
    }

    thread::sleep_ms(1);
    p.send("s".into(), &msg).expect("unable to send to comp");
    p.send("s".into(), &msg).expect("unable to send to comp");
    p.send("s".into(), &msg).expect("unable to send to comp");
    p.send_vecu8("acc".into(), &vec![0]);

    thread::sleep_ms(10);
    sched.start_receive();
    let m = p.recv("recv1".into()).expect("cannot receive");
    let n: number::Reader = m.get_root().expect("not a date reader");
    assert_eq!(n.get_number(), 1);

    let m = p.recv("recv2".into()).expect("cannot receive");
    let n: number::Reader = m.get_root().expect("not a date reader");
    assert_eq!(n.get_number(), 1);

    let m = p.recv("recv1".into()).expect("cannot receive");
    let n: number::Reader = m.get_root().expect("not a date reader");
    assert_eq!(n.get_number(), 1);

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

    let mut sched = Scheduler::new("127.4.0.1".into());

    let mut p = Ports::new("127.4.0.1".into(), "29999".into(),
                           vec!["r1".into(), "r2".into()],
                           vec![],
                           vec!["acc".into(), "s1".into(), "s2".into()],
                           vec![]).expect("cannot create receiver");

    sched.add_subnet("sn".into(), &sn);
    sched.components.insert("recv".into(), "29999".into());


    {
        p.connect("s2".into(), sched.components.get("sninc2").unwrap().clone(), "input".into(), None).expect("unable to connect");
        p.connect("s1".into(), sched.components.get("sninc1").unwrap().clone(), "input".into(), None).expect("unable to connect");
        p.connect("acc".into(), sched.components.get("snlb").unwrap().clone(), "acc".into(), None).expect("unable to connect");
    }
    sched.connect("sn".into(), "output1".into(), "recv".into(), "r1".into());
    sched.connect("sn".into(), "output2".into(), "recv".into(), "r2".into());

    p.send_vecu8("acc".into(), &vec![0]).expect("unable to send acc");
    let mut msg = capnp::message::Builder::new_default();
    {
        let mut number = msg.init_root::<number::Builder>();
        number.set_number(1);
    }
    let mut msg2 = capnp::message::Builder::new_default();
    {
        let mut number = msg2.init_root::<number::Builder>();
        number.set_number(38);
    }

    p.send("s2".into(), &msg2).expect("unable to send to comp");
    p.send("s1".into(), &msg).expect("unable to send to comp");

    thread::sleep_ms(100);
    sched.start_receive();
    let m = p.recv("r1".into()).expect("cannot receive");
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

    thread::sleep_ms(1);
    p.send("s1".into(), &msg).expect("unable to send to comp");
    p.send("s2".into(), &msg2).expect("unable to send to comp");

    sched.start_receive();
    let m = p.recv("r2".into()).expect("cannot receive");
    let n: number::Reader = m.get_root().expect("not a date reader");
    assert_eq!(n.get_number(), 666);

    sched.join();

}

/*
#[test]
fn update() {
    // A running component
    let mut sched = Scheduler::new();
    let (s, r) = channel::<CompMsg>();
    let (mut i, ii, iia) = Delay::new();
    let (i_s, i_r) = count_channel::<usize>(16);
    i.connect("output".into(), Box::new(i_s.clone()), "test".into(), s.clone());
    sched.add_component("i".into(), (i, ii, iia));
    let port_a: CountSender<usize> = sched.get_sender("i".into(), "a".into());
    let port_b: CountSender<usize> = sched.get_sender("i".into(), "b".into());
    port_a.send(111).ok().unwrap();
    port_b.send(555).ok().unwrap();
    let res = i_r.recv().expect("No result");
    assert_eq!(res, 666);
    let res_s = r.recv().expect("scheduler receive");
    assert!(match res_s { CompMsg::Start(n) => { n == "test".to_string() }, _ => { false }});



    // Change the output during
    let mut sched = Scheduler::new();
    sched.add_component("i".into(), Delay::new());
    let (s, r) = channel::<CompMsg>();
    let (mut i, ii, iia) = Debug::new::<usize>();
    let (i_s, i_r) = count_channel::<usize>(16);
    i.connect("output".into(), Box::new(i_s.clone()), "test".into(), s.clone());
    let (mut i2, ii2, iia2) = Debug::new::<usize>();
    let (i_s2, i_r2) = count_channel::<usize>(16);
    i2.connect("output".into(), Box::new(i_s2.clone()), "test2".into(), s.clone());

    sched.add_component("d1".into(), (i, ii, iia));
    sched.add_component("d2".into(), (i2, ii2, iia2));
    sched.connect("i".into(), "output".into(), "d1".into(), "input".into());



    let port_a: CountSender<usize> = sched.get_sender("i".into(), "a".into());
    let port_b: CountSender<usize> = sched.get_sender("i".into(), "b".into());
    port_a.send(111).ok().expect("cannot send a");
    port_b.send(555).ok().expect("cannot send b");
    let res = i_r.recv().expect("No result");
    assert_eq!(res, 666);
    assert!(i_r2.try_recv().is_err());
    let res_s = r.recv().expect("scheduler receive");
    assert!(match res_s { CompMsg::Start(n) => { n == "test".to_string() }, _ => { false }});
    
    // start a new run
    port_a.send(111).ok().expect("cannot send a");
    // send connect: 
    sched.connect("i".into(), "output".into(), "d2".into(), "input".into());
    thread::sleep_ms(500);
    port_b.send(555).ok().expect("cannot send b");
    let res = i_r.recv().expect("No result");
    assert_eq!(res, 666);
    assert!(i_r2.try_recv().is_err());
    let res_s = r.recv().expect("scheduler receive");
    assert!(match res_s { CompMsg::Start(n) => { n == "test".to_string() }, _ => { false }});

    // start a new run with the new connection
    port_a.send(111).ok().expect("cannot send a");
    port_b.send(555).ok().expect("cannot send b");
    let res = i_r2.recv().expect("No result");
    assert_eq!(res, 666);
    assert!(i_r.try_recv().is_err());
    let res_s = r.recv().expect("scheduler receive");
    assert!(match res_s { CompMsg::Start(n) => { n == "test2".to_string() }, _ => { false }});


    sched.disconnect("i".into(), "output".into());
    thread::sleep_ms(500);
    port_a.send(111).ok().expect("cannot send a");
    port_b.send(555).ok().expect("cannot send b");
    sched.join();
    assert!(i_r.try_recv().is_err());
    assert!(i_r2.try_recv().is_err());
    assert!(r.try_recv().is_err());




}


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
