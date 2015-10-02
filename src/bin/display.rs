extern crate fractalide;

use self::fractalide::component;
use self::fractalide::component::{Component, OutputSender, IP, CompRunner, InputSenders};

use std::fmt::Debug;

use std::sync::mpsc::{SyncSender, Receiver, SendError};
use std::sync::mpsc::sync_channel;
use std::any::Any;
use std::marker::Reflect;

use std::thread;

struct AdderInputSender {
    x: SyncSender<i32>,
    y: SyncSender<i32>,
}

struct AdderInputReceiver {
    x: Receiver<i32>,
    y: Receiver<i32>,
}

struct AdderOutputPorts {
    output: OutputSender<i32>,
}

struct Adder {
    input_receivers: AdderInputReceiver,
    output_ports: AdderOutputPorts,
}

impl Adder {
    fn new() -> (Box<Component + Send>, Box<InputSenders>) {
        let (xs, xr) = sync_channel(16);
        let (ys, yr) = sync_channel(16);
        let comp = Adder {
            input_receivers: AdderInputReceiver { x: xr, y: yr, },
            output_ports: AdderOutputPorts { output: OutputSender::new(), },
        };
        let is = AdderInputSender { x: xs, y: ys, };
        (Box::new(comp), Box::new(is))
    }

    
}
impl Component for Adder {
    fn connect(&mut self, port:&'static str, send: Box<Any>){
        match port {
            "output" => { 
                self.output_ports.output.connect(component::downcast(send)); 
            },
            _ => {},
        }
    }

    fn run(&self) {
        let x = self.input_receivers.x.recv().unwrap();
        let y = self.input_receivers.y.recv().unwrap();
        println!("Receive {} and {}", x, y);
        let res = self.output_ports.output.send(x+y);
    }
}
impl InputSenders for AdderInputSender {
    fn get_sender(&self, port: &'static str) -> Option<Box<Any + Send + 'static>> {
        match port {
            "x" => { Some(Box::new(self.x.clone())) },
            "y" => { Some(Box::new(self.y.clone())) },
            _ => { None },
        }
    }
}

struct DisplayInputSender<T> {
    input: SyncSender<T>,
}
struct DisplayInputReceiver<T> {
    input: Receiver<T>,
}
struct DisplayOutput<T> {
    output: OutputSender<T>,
}

struct Display<T> {
    input_receivers: DisplayInputReceiver<T>,
    output_ports: DisplayOutput<T>,
}
impl<T: Debug + Reflect + IP> Display<T>{
    fn new() -> (Box<Component + Send>, Box<InputSenders>) {
        let (xs, xr) = sync_channel::<T>(16);
        let comp = Display{
            input_receivers: DisplayInputReceiver { input: xr, },
            output_ports: DisplayOutput { output: OutputSender::new(), },
        };
        let is = DisplayInputSender { input: xs, };
        (Box::new(comp), Box::new(is))
    }
}
impl<T: Debug + Reflect + IP> Component for Display<T> {
    fn connect(&mut self, port:&'static str, send: Box<Any>){
        match port {
            "output" => { self.output_ports.output.connect(component::downcast(send)); },
            _ => {},
        }
    }


    fn run(&self) {
        let i = self.input_receivers.input.recv().unwrap();
        println!("Debug {:?}", i);
        self.output_ports.output.send(i);
    }
}

impl<T: Debug + Reflect + IP> InputSenders for DisplayInputSender<T> {
    fn get_sender(&self, port: &'static str) -> Option<Box<Any + Send + 'static>> {
        match port {
            "input" => { Some(Box::new(self.input.clone())) },
            _ => { None },
        }
    }
}


pub fn testAdder() {
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
