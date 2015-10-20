#![feature(braced_empty_structs)]
#[macro_use]
extern crate fractalide;

use fractalide::component::{CountSender, CountReceiver, downcast};
use fractalide::component::count_channel;
use fractalide::scheduler::{CompMsg};
use std::sync::mpsc::{Sender};
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
    let (mut ng, ngi, _) = TestNotGeneric::new();

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
    let (mut g, gi, _) = TestGeneric::new::<String, i32>();

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
