#![feature(reflect_marker)]
#![feature(concat_idents)]
#![feature(braced_empty_structs)]

#[macro_use]
extern crate fractalide;

use self::fractalide::component;
use self::fractalide::component::{Component, ComponentRun, ComponentConnect, OutputSender, IP, CompRunner, InputSenders, InputArraySenders, InputArrayReceivers, OptionReceiver};

use std::fmt::Debug;

use std::sync::mpsc::{SyncSender, Receiver};
use std::sync::mpsc::sync_channel;
use std::any::Any;
use std::collections::HashMap;

use std::thread;
use std::mem;


component! {
    Adder, 
    inputs(AIS AIR => ()),
    inputs_array(AIIS AIIR => (numbers: i32)),
    outputs(AO => (output:i32)),
    outputs_array(AAO => ()),
    fn run(&mut self) {
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
    inputs_array(DIIS DIIR => ()),
    outputs(DO (T: DisplayIP) => (output: T)),
    outputs_array(DAO => ()),
    option(String),
    fn run(&mut self){
        let i = self.inputs.input.recv().unwrap();
        let pre = self.inputs.option.recv();
        println!("{} {:?}", pre, i);
        let _ = self.outputs.output.send(i);
    }
}

component! {
    LoadBalancer, (T: IP),
    inputs(LBS LBR (T: IP) => (acc: usize, input: T)),
    inputs_array(LBAS LBAR => ()),
    outputs(LBO => (acc: usize)),
    outputs_array(LBOA (T: IP) => (output: T)),
    fn run(&mut self) {
        // Find the good output port
        let mut actual = self.inputs.acc.recv().unwrap();
        if actual > self.outputs_array.output.len()-1 { actual = 0; }
        let mut list: Vec<_> = self.outputs_array.output.iter().collect();
        list.sort_by(|&a, &b| { (a.0).cmp((&b.0)) });
        let port = list.get(actual).unwrap();

        // send the IP
        let ip = self.inputs.input.recv().unwrap();
        (port.1).send(ip).ok().expect("LoadBalancer: cannot send");
        self.outputs.acc.send(actual + 1).ok().expect("LoadBalancer : cannot send acc");
    }
}
        

pub fn main() {
    let mut a = CompRunner::new(Adder::new());
    let mut d = CompRunner::new(Display::<i32>::new());
    let o = d.get_sender("option").unwrap();
    let o: SyncSender<String> = component::downcast(o);

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
    println!("Display is started");
    thread::sleep_ms(2000);
    println!("Display receive the option");
    o.send("first test".to_string());
    thread::sleep_ms(1000);
    o.send("first test change".to_string());
    o.send("first test change twices".to_string());
    thread::sleep_ms(1000);
    y.send(33).unwrap();

    thread::sleep_ms(1000);


    let d1 = CompRunner::new(Display::<String>::new());
    let d2 = CompRunner::new(Display::<String>::new());
    let d3 = CompRunner::new(Display::<String>::new());
    let lb = CompRunner::new(LoadBalancer::<String>::new());

    let o = d1.get_sender("option").unwrap();
    let o: SyncSender<String> = component::downcast(o);
    o.send("lb first display".to_string());
    let o = d2.get_sender("option").unwrap();
    let o: SyncSender<String> = component::downcast(o);
    o.send("lb second display".to_string());
    let o = d3.get_sender("option").unwrap();
    let o: SyncSender<String> = component::downcast(o);
    o.send("lb third display".to_string());
    thread::sleep_ms(1000);

    lb.connect("acc", &lb, "acc");
    lb.add_output_array_selection("output", "1");
    lb.add_output_array_selection("output", "2");
    lb.add_output_array_selection("output", "z");
    lb.connect_array("output", "1", &d1, "input");
    lb.connect_array("output", "2", &d2, "input");
    lb.connect_array("output", "z", &d3, "input");
    let acc = lb.get_sender("acc").unwrap();
    let acc: SyncSender<usize> = component::downcast(acc);
    acc.send(0).unwrap();

    let i = lb.get_sender("input").unwrap();
    let i: SyncSender<String> = component::downcast(i);
    d1.start();
    d3.start();
    lb.start();

    i.send("hello Fractalide".to_string()).unwrap();
    thread::sleep_ms(1000);
    i.send("hello Fractalide".to_string()).unwrap();
    thread::sleep_ms(1000);
    i.send("hello Fractalide".to_string()).unwrap();
    thread::sleep_ms(1000);
    d2.start();

    thread::sleep_ms(2000);

}
