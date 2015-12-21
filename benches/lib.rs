#![feature(test)]

#![feature(braced_empty_structs)]
#[macro_use]
extern crate rustfbp;
extern crate test;

use test::Bencher;

use rustfbp::scheduler::Scheduler;
use rustfbp::subnet::*;
use rustfbp::loader::ComponentBuilder;
use rustfbp::ports::Ports;
use rustfbp::allocator::{HeapSenders};


extern crate capnp;
mod number_capnp {
    include!("../tests/schema/number_capnp.rs");
}
use number_capnp::number;

#[bench]
fn creation(b: &mut Bencher) {
    // creation
    let builder = ComponentBuilder::new("./tests/libinc.so");
    b.iter(|| {
        let mut sched = Scheduler::new();
        for i in (1..10000) {
            sched.add_component(i.to_string(), &builder);
        }
        sched.join();
    });

}

#[bench]
fn many_messages_nothing(b: &mut Bencher) {
    // Execution with many messages
    let nothing = ComponentBuilder::new("./tests/libnothing.so");
    let mut sched = Scheduler::new();
    for i in (1..10000) {
        sched.add_component(i.to_string(), &nothing);
    }
    for i in (1..9999) {
        sched.connect(i.to_string(), "output".into(), (i+1).to_string(), "input".into()).expect("cannot connect many");
    }

    let senders = (sched.allocator.senders.create)();
    let mut p = Ports::new("exterior".into(), &sched.allocator, senders,
                           vec!["r".into()],
                           vec![],
                           vec!["s".into()],
                           vec![]).expect("cannot create");
    let hs = HeapSenders::from_raw(senders);
    sched.inputs.insert("exterior".into(), hs);

    p.connect("s".into(), sched.inputs.get("1".into()).unwrap().get_sender("input".into()).expect("cannot get sneder").to_raw()).expect("cannot connect");
    sched.connect("9999".into(), "output".into(), "exterior".into(), "r".into()).expect("cannot sched connect");

    let mut msg = capnp::message::Builder::new_default();
    {
        let mut number = msg.init_root::<number::Builder>();
        number.set_number(0);
    }

    b.iter(|| {
        let mut ip = sched.allocator.ip.build_empty();
        ip.write_builder(&msg);

        p.send("s".into(), ip).expect("unable to send to comp");

        let mut ip_recv = p.recv("r".into()).expect("cannot receive");

        let msg = ip_recv.get_reader().expect("test : cannot get reader");
        let n: number::Reader = msg.get_root().expect("test : not a date reader");

        assert_eq!(n.get_number(), 0);
    });
    sched.join();

}

#[bench]
fn many_messages(b: &mut Bencher) {
    // Execution with many messages
    let inc = ComponentBuilder::new("./tests/libinc.so");
    let mut sched = Scheduler::new();
    for i in (1..10000) {
        sched.add_component(i.to_string(), &inc);
    }
    for i in (1..9999) {
        sched.connect(i.to_string(), "output".into(), (i+1).to_string(), "input".into()).expect("cannot connect many");
    }

    let senders = (sched.allocator.senders.create)();
    let mut p = Ports::new("exterior".into(), &sched.allocator, senders,
                           vec!["r".into()],
                           vec![],
                           vec!["s".into()],
                           vec![]).expect("cannot create");
    let hs = HeapSenders::from_raw(senders);
    sched.inputs.insert("exterior".into(), hs);

    p.connect("s".into(), sched.inputs.get("1".into()).unwrap().get_sender("input".into()).expect("cannot get sneder").to_raw()).expect("cannot connect");
    sched.connect("9999".into(), "output".into(), "exterior".into(), "r".into()).expect("cannot sched connect");

    let mut msg = capnp::message::Builder::new_default();
    {
        let mut number = msg.init_root::<number::Builder>();
        number.set_number(0);
    }

    b.iter(|| {
        let mut ip = sched.allocator.ip.build_empty();
        ip.write_builder(&msg);

        p.send("s".into(), ip).expect("unable to send to comp");

        let mut ip_recv = p.recv("r".into()).expect("cannot receive");

        let msg = ip_recv.get_reader().expect("test : cannot get reader");
        let n: number::Reader = msg.get_root().expect("test : not a date reader");

        assert_eq!(n.get_number(), 9999);
    });
    sched.join();

}

/*
fn create_deep_graph(n: usize) -> Graph {
    if n == 0 {
        let g = GraphBuilder::new()
            .add_component("inc".into(), Inc::new)
            .edges()
            .add_virtual_input_port("input".into(), "inc".into(), "input".into())
            .add_virtual_output_port("output".into(), "inc".into(), "output".into());
        g
    } else {
        let g = GraphBuilder::new()
            .add_subnet("inc".into(), &create_deep_graph(n-1))
            .edges()
            .add_virtual_input_port("input".into(), "inc".into(), "input".into())
            .add_virtual_output_port("output".into(), "inc".into(), "output".into());
        g
    }
}

#[bench]
fn creation_deep_subnet(b: &mut Bencher) {
    let g = create_deep_graph(30);
    
    b.iter(|| {
        let mut sched = Scheduler::new();
        for i in (1..10000) {
            sched.add_subnet("i".to_string() + &i.to_string(), &g);
        }
        sched.join();
    });
    
}

#[bench]
fn deep_many_messages(b: &mut Bencher) {
    // Execution with many messages
    let g = create_deep_graph(30);
    
    let (s, r) = channel::<CompMsg>();
    let mut sched = Scheduler::new();
    for i in (1..10000) {
        sched.add_subnet("i".to_string() + &i.to_string(), &g); 
    }
    for i in (1..9999) {
        sched.connect("i".to_string() + &i.to_string(), "output".into(), "i".to_string() + &(i+1).to_string(), "input".into());     
    }
    let (mut i, ii, iia) = Inc::new();
    let (i_s, i_r) = count_channel::<usize>(16);
    i.connect("output".into(), Box::new(i_s.clone()), "test".into(), s.clone());
    sched.add_component("i".into(), (i, ii, iia));
    sched.connect("i9999".into(), "output".into(), "i".into(), "input".into());
    let start: CountSender<usize> = sched.get_sender("i1".into(), "input".into());
    b.iter(|| {
        start.send(0).ok().expect("Cannot send");
        let msg = i_r.recv().expect("cannot receive");
        let _ = r.recv();
        assert_eq!(msg, 10000);
    });
    sched.join();

}
*/
