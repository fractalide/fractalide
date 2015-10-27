#![feature(braced_empty_structs)]
#[macro_use]
extern crate fractalide;

use fractalide::component::{CountSender, downcast};
use fractalide::component::count_channel;
use fractalide::scheduler::{CompMsg, Scheduler};
use fractalide::subnet::*;
use std::sync::mpsc::channel;

use std::thread;

#[test]
fn it_works() {
    assert_eq!(4, 2+2);
}

component! {
    TestEmpty,
    inputs(),
    inputs_array(),
    outputs(),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) { 
        unsafe { test_result = 1; }    
    }
    // Only for test, bad!
    pub static mut test_result: i32 = 0;
}

component! {
    TestNotGeneric,
    inputs(a: bool, b: i32),
    inputs_array(a: bool, b: i32),
    outputs(a: bool, b: i32),
    outputs_array(a: bool, b: i32),
    option(),
    acc(),
    fn run(&mut self) { 
        let a = self.inputs.a.recv().expect("TestNotGeneric : cannot receive a");
        let b = self.inputs.b.recv().expect("TestNotGeneric : cannot receive b");
        self.outputs.a.send(!a).ok().expect("TestNotGeneric : cannot send a");
        self.outputs.b.send(b * 2).ok().expect("TestNotGeneric : cannot send b");

        for (key, val) in &(self.inputs_array.a) {
            let msg = val.recv().expect("No in input array");
            println!("{}", key);
            let port = self.outputs_array.a.get(key).expect("No output array port");
            port.send(!msg).ok().expect("No able to send");
        }
        for (key, val) in &(self.inputs_array.b) {
            let msg = val.recv().expect("No in input array");
            let port = self.outputs_array.b.get(key).expect("No output array port");
            port.send(msg * 2).ok().expect("No able to send");
        }
    }
}

component! {
    TestGeneric, (T: DebugIP, U: IP),
    inputs(a: T, b: U where T: DebugIP, U: IP),
    inputs_array(a: T, b: U where T: DebugIP, U: IP),
    outputs(a: T, b: U where T: DebugIP, U: IP),
    outputs_array(a: T, b: U where T: DebugIP, U: IP),
    option(i32),
    acc(String),
    fn run(&mut self) {
        let a = self.inputs.a.recv().expect("TestNotGeneric : cannot receive a");
        let b = self.inputs.b.recv().expect("TestNotGeneric : cannot receive b");
        self.outputs.a.send(a).ok().expect("TestNotGeneric : cannot send a");
        self.outputs.b.send(b).ok().expect("TestNotGeneric : cannot send b");

        for (key, val) in &(self.inputs_array.a) {
            let msg = val.recv().expect("No in input array");
            println!("{}", key);
            let port = self.outputs_array.a.get(key).expect("No output array port");
            port.send(msg).ok().expect("No able to send");
        }
        for (key, val) in &(self.inputs_array.b) {
            let msg = val.recv().expect("No in input array");
            let port = self.outputs_array.b.get(key).expect("No output array port");
            port.send(msg).ok().expect("No able to send");
        }
    }
    use std::fmt::Debug;
    pub trait DebugIP: Debug + IP {}
    impl <T> DebugIP for T where T : Debug + IP {}
}

#[test] 
fn component_empty() {
    let (mut e, _, _) = TestEmpty::new();
    assert_eq!(e.is_input_ports(), false);
    assert_eq!(e.is_ips(), false);

    unsafe {
        assert_eq!(TestEmpty::test_result, 0);
        e.run();
        assert_eq!(TestEmpty::test_result, 1);
    }


}
#[test]
fn component_not_generic() {
    let (mut ng, ngi, mut ngia) = TestNotGeneric::new();

    let (s, r) = channel::<CompMsg>();

    assert_eq!(ng.is_input_ports(), true);
    assert_eq!(ng.is_ips(), false);
    let (a_s, a_r) = count_channel::<bool>(16);
    let (b_s, b_r) = count_channel::<i32>(16);
    ng.connect("a".into(), Box::new(a_s.clone()), "test".into(), s.clone());
    ng.connect("b".into(), Box::new(b_s.clone()), "test2".into(), s.clone());
    let port_a = ngi.get_sender("a".into()).expect("no input");
    let port_a: CountSender<bool> = downcast(port_a);
    port_a.send(true).ok().expect("cannot send");
    let port_b = ngi.get_sender("b".into()).expect("no input");
    let port_b: CountSender<i32> = downcast(port_b);
    port_b.send(333).ok().expect("cannot send");

    assert_eq!(ng.is_ips(), true);
    ng.run();
    assert_eq!(ng.is_ips(), false);
    let sched = r.try_recv().expect("scheduler receive");
    assert!(match sched { CompMsg::Start(n) => { n == "test".to_string() }, _ => { false }});
    let sched = r.try_recv().expect("scheduler receive");
    assert!(match sched { CompMsg::Start(n) => { n == "test2".to_string() }, _ => { false }});

    let msg = a_r.try_recv().expect("a not receive");
    assert_eq!(msg, false);
    let msg = b_r.try_recv().expect("b not receive");
    assert_eq!(msg, 666);


    let (a_s1, a_r1) = count_channel::<bool>(16);
    let (a_s2, a_r2) = count_channel::<bool>(16);
    let (b_s1, b_r1) = count_channel::<i32>(16);
    let (b_s2, b_r2) = count_channel::<i32>(16);
    ng.add_selection_receiver("a".into(), "1".into(), Box::new(a_r1));
    ng.add_selection_receiver("a".into(), "2".into(), Box::new(a_r2));
    ng.add_selection_receiver("b".into(), "1".into(), Box::new(b_r1));
    ng.add_selection_receiver("b".into(), "2".into(), Box::new(b_r2));
    ng.add_output_selection("a".into(), "1".into());
    ng.add_output_selection("a".into(), "2".into());
    ng.add_output_selection("b".into(), "1".into());
    ng.add_output_selection("b".into(), "2".into());

    let (ar_s1, ar_r1) = count_channel::<bool>(16);
    let (ar_s2, ar_r2) = count_channel::<bool>(16);
    let (br_s1, br_r1) = count_channel::<i32>(16);
    let (br_s2, br_r2) = count_channel::<i32>(16);
    ng.connect_array("a".into(), "1".into(), Box::new(ar_s1.clone()), "testa".into(), s.clone());
    ng.connect_array("a".into(), "2".into(), Box::new(ar_s2.clone()), "testa".into(), s.clone());
    ng.connect_array("b".into(), "1".into(), Box::new(br_s1.clone()), "testb".into(), s.clone());
    ng.connect_array("b".into(), "2".into(), Box::new(br_s2.clone()), "testb".into(), s.clone());

    
    ngia.add_selection_sender("a".into(), "1".into(), Box::new(ar_s1));
    let ar_s1 = ngia.get_selection_sender("a".into(), "1".into()).expect("no selection input port");
    let _: CountSender<bool> = downcast(ar_s1);
    a_s1.send(true).ok().expect("cannot send");
    a_s2.send(false).ok().expect("cannot send");
    b_s1.send(333).ok().expect("cannot send");
    b_s2.send(21).ok().expect("cannot send");
    assert_eq!(ng.is_ips(), true);
    port_a.send(true).ok().expect("cannot send");
    port_b.send(333).ok().expect("cannot send");
    ng.run();
    assert_eq!(ng.is_ips(), false);

    let msg = a_r.try_recv().expect("a not receive");
    assert_eq!(msg, false);
    let msg = b_r.try_recv().expect("b not receive");
    assert_eq!(msg, 666);

    let msg = ar_r1.try_recv().expect("a not receive");
    assert_eq!(msg, false);
    let msg = ar_r2.try_recv().expect("a not receive");
    assert_eq!(msg, true);
    let msg = br_r1.try_recv().expect("a not receive");
    assert_eq!(msg, 666);
    let msg = br_r2.try_recv().expect("a not receive");
    assert_eq!(msg, 42);
    
    let sched = r.try_recv().expect("scheduler receive");
    assert!(match sched { CompMsg::Start(n) => { n == "test".to_string() }, _ => { false }});
    let sched = r.try_recv().expect("scheduler receive");
    assert!(match sched { CompMsg::Start(n) => { n == "test2".to_string() }, _ => { false }});
    let sched = r.try_recv().expect("scheduler receive");
    assert!(match sched { CompMsg::Start(n) => { n == "testa".to_string() }, _ => { false }});
    let sched = r.try_recv().expect("scheduler receive");
    assert!(match sched { CompMsg::Start(n) => { n == "testa".to_string() }, _ => { false }});
    let sched = r.try_recv().expect("scheduler receive");
    assert!(match sched { CompMsg::Start(n) => { n == "testb".to_string() }, _ => { false }});
    let sched = r.try_recv().expect("scheduler receive");
    assert!(match sched { CompMsg::Start(n) => { n == "testb".to_string() }, _ => { false }});

}

#[test]
fn component_generic() {
    let (mut g, gi, mut gia) = TestGeneric::new::<String, i32>();

    let (s, r) = channel::<CompMsg>();

    assert_eq!(g.is_input_ports(), true);
    assert_eq!(g.is_ips(), false);
    let (a_s, a_r) = count_channel::<String>(16);
    let (b_s, b_r) = count_channel::<i32>(16);
    g.connect("a".into(), Box::new(a_s.clone()), "test".into(), s.clone());
    g.connect("b".into(), Box::new(b_s.clone()), "test2".into(), s.clone());
    let port_a = gi.get_sender("a".into()).expect("no input");
    let port_a: CountSender<String> = downcast(port_a);
    port_a.send("a".to_string()).ok().expect("cannot send");
    let port_b = gi.get_sender("b".into()).expect("no input");
    let port_b: CountSender<i32> = downcast(port_b);
    port_b.send(666).ok().expect("cannot send");

    assert_eq!(g.is_ips(), true);
    g.run();
    assert_eq!(g.is_ips(), false);
    let sched = r.try_recv().expect("scheduler receive");
    assert!(match sched { CompMsg::Start(n) => { n == "test".to_string() }, _ => { false }});
    let sched = r.try_recv().expect("scheduler receive");
    assert!(match sched { CompMsg::Start(n) => { n == "test2".to_string() }, _ => { false }});

    let msg = a_r.try_recv().expect("a not receive");
    assert_eq!(msg, "a".to_string());
    let msg = b_r.try_recv().expect("b not receive");
    assert_eq!(msg, 666);


    let (a_s1, a_r1) = count_channel::<String>(16);
    let (a_s2, a_r2) = count_channel::<String>(16);
    let (b_s1, b_r1) = count_channel::<i32>(16);
    let (b_s2, b_r2) = count_channel::<i32>(16);
    g.add_selection_receiver("a".into(), "1".into(), Box::new(a_r1));
    g.add_selection_receiver("a".into(), "2".into(), Box::new(a_r2));
    g.add_selection_receiver("b".into(), "1".into(), Box::new(b_r1));
    g.add_selection_receiver("b".into(), "2".into(), Box::new(b_r2));
    g.add_output_selection("a".into(), "1".into());
    g.add_output_selection("a".into(), "2".into());
    g.add_output_selection("b".into(), "1".into());
    g.add_output_selection("b".into(), "2".into());

    let (ar_s1, ar_r1) = count_channel::<String>(16);
    let (ar_s2, ar_r2) = count_channel::<String>(16);
    let (br_s1, br_r1) = count_channel::<i32>(16);
    let (br_s2, br_r2) = count_channel::<i32>(16);
    g.connect_array("a".into(), "1".into(), Box::new(ar_s1.clone()), "testa".into(), s.clone());
    g.connect_array("a".into(), "2".into(), Box::new(ar_s2.clone()), "testa".into(), s.clone());
    g.connect_array("b".into(), "1".into(), Box::new(br_s1.clone()), "testb".into(), s.clone());
    g.connect_array("b".into(), "2".into(), Box::new(br_s2.clone()), "testb".into(), s.clone());

    
    gia.add_selection_sender("a".into(), "1".into(), Box::new(ar_s1));
    let ar_s1 = gia.get_selection_sender("a".into(), "1".into()).expect("no selection input port");
    let _: CountSender<String> = downcast(ar_s1);
    a_s1.send("a".to_string()).ok().expect("cannot send");
    a_s2.send("b".to_string()).ok().expect("cannot send");
    b_s1.send(666).ok().expect("cannot send");
    b_s2.send(42).ok().expect("cannot send");
    assert_eq!(g.is_ips(), true);
    port_a.send("a".to_string()).ok().expect("cannot send");
    port_b.send(666).ok().expect("cannot send");
    g.run();
    assert_eq!(g.is_ips(), false);

    let msg = a_r.try_recv().expect("a not receive");
    assert_eq!(msg, "a".to_string());
    let msg = b_r.try_recv().expect("b not receive");
    assert_eq!(msg, 666);

    let msg = ar_r1.try_recv().expect("a not receive");
    assert_eq!(msg, "a".to_string());
    let msg = ar_r2.try_recv().expect("a not receive");
    assert_eq!(msg, "b".to_string());
    let msg = br_r1.try_recv().expect("a not receive");
    assert_eq!(msg, 666);
    let msg = br_r2.try_recv().expect("a not receive");
    assert_eq!(msg, 42);
    
    let sched = r.try_recv().expect("scheduler receive");
    assert!(match sched { CompMsg::Start(n) => { n == "test".to_string() }, _ => { false }});
    let sched = r.try_recv().expect("scheduler receive");
    assert!(match sched { CompMsg::Start(n) => { n == "test2".to_string() }, _ => { false }});
    let sched = r.try_recv().expect("scheduler receive");
    assert!(match sched { CompMsg::Start(n) => { n == "testa".to_string() }, _ => { false }});
    let sched = r.try_recv().expect("scheduler receive");
    assert!(match sched { CompMsg::Start(n) => { n == "testa".to_string() }, _ => { false }});
    let sched = r.try_recv().expect("scheduler receive");
    assert!(match sched { CompMsg::Start(n) => { n == "testb".to_string() }, _ => { false }});
    let sched = r.try_recv().expect("scheduler receive");
    assert!(match sched { CompMsg::Start(n) => { n == "testb".to_string() }, _ => { false }});


}


component! {
    Inc,
    inputs(input: usize),
    inputs_array(),
    outputs(output: usize),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) { 
        let msg = self.inputs.input.recv().expect("Inc : cannot receive");
        let _ = self.outputs.output.send(msg+1);
    }
}

#[test]
fn test_sched() {

    // empty sched
    let sched = Scheduler::new();
    sched.join();

    // A component that never run
    let mut sched = Scheduler::new();
    let (i, ii, iia) = Inc::new();
    sched.add_component("i".into(), (i, ii, iia));
    sched.join();

    // A running component
    let mut sched = Scheduler::new();
    let (s, r) = channel::<CompMsg>();
    let (mut i, ii, iia) = Inc::new();
    // test set_sender
    let (mut port, set_r) = count_channel::<usize>(16);
    i.set_receiver("input".into(), Box::new(set_r)); 
    port.set_sched("i".into(), sched.sender.clone());
    let (i_s, i_r) = count_channel::<usize>(16);
    i.connect("output".into(), Box::new(i_s.clone()), "test".into(), s.clone());
    sched.add_component("i".into(), (i, ii, iia));
    port.send(0).ok().unwrap();
    sched.join();
    let res = i_r.try_recv().expect("No result");
    assert_eq!(res, 1);
    let res_s = r.try_recv().expect("scheduler receive");
    assert!(match res_s { CompMsg::Start(n) => { n == "test".to_string() }, _ => { false }});

    // Two running component with a connection
    let mut sched = Scheduler::new();
    let (s, r) = channel::<CompMsg>();
    let (mut i, ii, iia) = Inc::new();
    let (i_s, i_r) = count_channel::<usize>(16);
    i.connect("output".into(), Box::new(i_s.clone()), "test".into(), s.clone());
    sched.add_component("i".into(), Inc::new());
    sched.add_component("i2".into(), (i, ii, iia));
    sched.connect("i".into(), "output".into(), "i2".into(), "input".into());
    let port: CountSender<usize> = sched.get_sender("i".into(), "input".into());
    port.send(0).ok().unwrap();
    sched.join();
    let res = i_r.try_recv().expect("No result");
    assert_eq!(res, 2);
    let res_s = r.try_recv().expect("scheduler receive");
    assert!(match res_s { CompMsg::Start(n) => { n == "test".to_string() }, _ => { false }});

    // A subnet
    let mut sched = Scheduler::new();

    let (s, r) = channel::<CompMsg>();
    let (mut i, ii, iia) = Inc::new();
    let (i_s, i_r) = count_channel::<usize>(16);
    i.connect("output".into(), Box::new(i_s.clone()), "test".into(), s.clone());

    let not = GraphBuilder::new()
        .add_component("inc1".into(), Inc::new)
        .add_component("inc2".into(), Inc::new)
        .edges()
        .add_simple2simple("inc1".into(), "output".into(), "inc2".into(), "input".into())
        .add_virtual_input_port("input".into(), "inc1".into(), "input".into())
        .add_virtual_output_port("output".into(), "inc2".into(), "output".into());

    sched.add_component("i".into(), (i, ii, iia));
    sched.add_subnet("sub".into(), &not);
    sched.connect("sub".into(), "output".into(), "i".into(), "input".into());
    let port: CountSender<usize> = sched.get_sender("sub".into(), "input".into());
    port.send(0).ok().unwrap();
    sched.join();
    let res = i_r.try_recv().expect("No result");
    assert_eq!(res, 3);
    let res_s = r.try_recv().expect("scheduler receive");
    assert!(match res_s { CompMsg::Start(n) => { n == "test".to_string() }, _ => { false }});
    
}

component! {
    Delay,
    inputs(a: usize, b: usize),
    inputs_array(),
    outputs(output: usize),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) { 
        let a = self.inputs.a.recv().expect("Delay : cannot receive");
        let b = self.inputs.b.recv().expect("Delay : cannot receive");
        let _ = self.outputs.output.send(a+b);
    }
}

component! {
    Debug, (T: IP),
    inputs(input: T where T: IP),
    inputs_array(),
    outputs(output: T where T: IP),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) {
        let a = self.inputs.input.recv().expect("Debug : cannot receive");
        self.outputs.output.send(a).ok().expect("Debug : cannot send");
    }
}

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
