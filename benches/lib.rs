#![feature(test)]

#![feature(braced_empty_structs)]
#[macro_use]
extern crate fractalide;
extern crate test;

use test::Bencher;

use fractalide::component::{CountSender, CountReceiver, downcast};
use fractalide::component::count_channel;
use fractalide::scheduler::{CompMsg, Scheduler};
use fractalide::subnet::*;
use std::sync::mpsc::{Sender};
use std::sync::mpsc::channel;

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
        self.outputs.output.send(msg+1).ok().expect("Inc: cannot send");
    }
}

#[bench]
fn creation(b: &mut Bencher) {
    // creation
    b.iter(|| {
        let mut sched = Scheduler::new();
        for i in (1..10000) {
            sched.add_component("i".to_string() + &i.to_string(), Inc::new()); 
        }
        sched.join();
    });

}

#[bench]
fn many_messages(b: &mut Bencher) {
    // Execution with many messages
    let (s, r) = channel::<CompMsg>();
    let mut sched = Scheduler::new();
    for i in (1..10000) {
        sched.add_component("i".to_string() + &i.to_string(), Inc::new()); 
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
