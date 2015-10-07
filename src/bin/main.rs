#![feature(reflect_marker)]
#![feature(concat_idents)]

#[macro_use]
extern crate fractalide;

use self::fractalide::component;
use self::fractalide::component::{Component, ComponentRun, ComponentConnect, OutputSender, IP, CompRunner, InputSenders, InputArraySenders, InputArrayReceivers};

use std::fmt::Debug;

use std::sync::mpsc::{SyncSender, Receiver, SendError};
use std::sync::mpsc::sync_channel;
use std::any::Any;
use std::marker::Reflect;
use std::collections::HashMap;

use std::thread;


component! {
    Adder, 
    inputs(AIS AIR => (x:i32, y:i32)),
    inputs_array(AIIS AIIR => (numbers: i32)),
    outputs(AO => (output:i32)),
    outputs_array(AAO => (out:i32)),
    fn run(&self) {
        // let x = self.inputs.x.recv().unwrap();
        // let y = self.inputs.y.recv().unwrap();
        let res = self.inputs_array.numbers.values().fold(0, |acc, port| {
            let msg = port.recv().unwrap();
            acc + msg
        });
        let _ = self.outputs.output.send(res);
    }
}   

trait DisplayIP: Debug + IP {}
impl <T> DisplayIP for T where T : Debug + IP {}

component! {
    Display, (T: DisplayIP),
    inputs(DIS DIR (T: DisplayIP) => (input: T)),
    inputs_array(DIIS DIIR => (numbers: i32)),
    outputs(DO (T: DisplayIP) => (output: T)),
    outputs_array(DAO => (out:i32)),
    fn run(&self){
        let i = self.inputs.input.recv().unwrap();
        println!("Debug {:?}", i);
        self.outputs.output.send(i);
    }
}

component! {
    LoadBalancer, (T: IP),
    inputs(LBS LBR (T: IP) => (acc: usize, input: T)),
    inputs_array(LBAS LBAR => (dummy: i32)),
    outputs(LBO => (acc: usize)),
    outputs_array(LBOA (T: IP) => (output: T)),
    fn run(&self) {
        let mut actual = self.inputs.acc.recv().unwrap();
        if (actual > self.outputs_array.output.len()-1){ actual = 0; }
        let mut list: Vec<_> = self.outputs_array.output.iter().collect();
        list.sort_by(|&a, &b| { (a.0).cmp((&b.0)) });
        let port = list.get(actual).unwrap();

        // send the IP
        let ip = self.inputs.input.recv().unwrap();
        (port.1).send(ip).ok().expect("LoadBalancer: cannot send");
        self.outputs.acc.send(actual + 1);
    }
}
        

/*
trait DummyInIP: ToString + Reflect + IP {}
impl<T> DummyInIP for T where T: ToString + Reflect +IP {}
trait DummyOutIP: Clone + Reflect + IP {}
impl<T> DummyOutIP for T where T: Clone + Reflect +IP {}

component! {
    Dummy, (T: DummyInIP),
    inputs(DUIS DUIR (T: DummyInIP) => (input: T)),
    outputs(DUO => (output: String)),
    fn run(&self) {
        let i = self.inputs.input.recv().unwrap();
        self.outputs.output.send(i.to_string());
    }       
}
*/

pub fn main() {
    let mut a = CompRunner::new(Adder::new());
    let mut d = CompRunner::new(Display::<i32>::new());

    a.connect("output", &d, "input");

    a.add_input_array_selection("numbers", "x");
    a.add_input_array_selection("numbers", "y");

    let x = a.get_array_sender("numbers", "x").unwrap();
    let x: SyncSender<i32> = component::downcast(x);
    let y = a.get_array_sender("numbers", "y").unwrap();
    let y: SyncSender<i32> = component::downcast(y);


    x.send(1).unwrap();
    y.send(11).unwrap();
    x.send(2).unwrap();
    y.send(22).unwrap();
    x.send(3).unwrap();
    a.start();
    d.start();
    y.send(33).unwrap();

    thread::sleep_ms(1000);


    let mut d1 = CompRunner::new(Display::<String>::new());
    let mut d2 = CompRunner::new(Display::<String>::new());
    let mut d3 = CompRunner::new(Display::<String>::new());
    let mut lb = CompRunner::new(LoadBalancer::<String>::new());

    thread::sleep_ms(1000);

    lb.connect("acc", &lb, "acc");
    lb.add_output_array_selection("output", "1");
    lb.add_output_array_selection("output", "2");
    lb.add_output_array_selection("output", "3");
    lb.connect_array("output", "1", &d1, "input");
    lb.connect_array("output", "2", &d2, "input");
    lb.connect_array("output", "3", &d3, "input");
    let acc = lb.get_sender("acc").unwrap();
    let acc: SyncSender<usize> = component::downcast(acc);
    acc.send(0).unwrap();

    let i = lb.get_sender("input").unwrap();
    let i: SyncSender<String> = component::downcast(i);
    d1.start();
    d3.start();
    lb.start();

    i.send("hello Fractalide".to_string()).unwrap();
    thread::sleep_ms(2000);
    i.send("hello Fractalide".to_string()).unwrap();
    thread::sleep_ms(2000);
    i.send("hello Fractalide".to_string()).unwrap();
    thread::sleep_ms(2000);
    d2.start();

    thread::sleep_ms(2000);

}
