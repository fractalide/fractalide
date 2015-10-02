#![feature(reflect_marker)]
#![feature(concat_idents)]

#[macro_use]
extern crate fractalide;

use self::fractalide::component;
use self::fractalide::component::{Component, ComponentRun, ComponentConnect, OutputSender, IP, CompRunner, InputSenders};

use std::fmt::Debug;

use std::sync::mpsc::{SyncSender, Receiver, SendError};
use std::sync::mpsc::sync_channel;
use std::any::Any;
use std::marker::Reflect;

use std::thread;

component! {
    Adder, 
    inputs(AIS AIR => (x:i32, y:i32)),
    outputs(AO => (output:i32)),
    fn run(&self) {
        let x = self.inputs.x.recv().unwrap();
        let y = self.inputs.y.recv().unwrap();
        println!("Receive {} and {}", x, y);
        let res = self.outputs.output.send(x+y);
    }
}   

trait DisplayIP: Debug + Reflect + IP {}
impl <T> DisplayIP for T where T : Debug + Reflect + IP {}

component! {
    Display, (T: DisplayIP),
    inputs(DIS DIR (T: DisplayIP) => (input: T)),
    outputs(DO (T: DisplayIP) => (output: T)),
    fn run(&self){
        let i = self.inputs.input.recv().unwrap();
        println!("Debug {:?}", i);
        self.outputs.output.send(i);
    }
}

pub fn main() {
    let mut a = CompRunner::new(Adder::new());
    let mut d = CompRunner::new(Display::<i32>::new());

    a.connect("output", &d, "input");

    let x = a.get_sender("x").unwrap();
    let x: SyncSender<i32> = component::downcast(x);
    let y = a.get_sender("y").unwrap();
    let y: SyncSender<i32> = component::downcast(y);

    x.send(1).unwrap();
    y.send(11).unwrap();
    x.send(2).unwrap();
    y.send(22).unwrap();
    x.send(3).unwrap();
    a.start();
    d.start();
    thread::sleep_ms(1000);
    y.send(33).unwrap();


    thread::sleep_ms(2000);
    
    let mut d = CompRunner::new(Display::<String>::new());
    let i = d.get_sender("input").unwrap();
    let i: SyncSender<String> = component::downcast(i);
    i.send("hello Fractalide".to_string()).unwrap();
    d.start();

    thread::sleep_ms(2000);

}
