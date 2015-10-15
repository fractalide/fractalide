#![feature(reflect_marker)]
#![feature(concat_idents)]
#![feature(braced_empty_structs)]

#[macro_use]
extern crate fractalide;

use self::fractalide::component;
use self::fractalide::component::{Component, ComponentRun, ComponentConnect, OutputSender, IP, InputSenders, InputArraySenders, InputArrayReceivers, OptionReceiver, CountSender, CountReceiver, count_channel};
use self::fractalide::fvm::{CompMsg, FVM};

use std::fmt::Debug;

use std::sync::mpsc::{SyncSender, Receiver, Sender};
use std::sync::mpsc::sync_channel;
use std::sync::atomic::Ordering;
use std::any::Any;
use std::collections::HashMap;

use std::thread;
use std::mem;

component! {
    IIPC,
    inputs(IIPCS IIPCR => ()),
    inputs_array(IIPCAS IIPCAR => ()),
    outputs(IIPCO => (output: i32)),
    outputs_array(IIPCOA => ()),
    fn run(&mut self) {
        let _ = self.outputs.output.send(42);
        let _ = self.outputs.output.send(42);
    }
}

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
        let pre = match self.inputs.option.try_recv() {
            Ok(msg) => { msg },
            _ => { "".to_string() },
        };
        println!("{}{:?}", pre, i);
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
    let mut fvm = FVM::new();
    fvm.add_component("iip1", IIPC::new());
    fvm.add_component("display1", Display::<i32>::new());
    fvm.connect("iip1", "output", "display1", "input");
    fvm.start("iip1");

    thread::sleep_ms(1000);
    println!("");
    println!("");

    fvm.add_component("adder", Adder::new());
    fvm.add_component("display_adder", Display::<i32>::new());
    let o = fvm.get_sender("display_adder", "option");
    let o: SyncSender<String> = component::downcast(o);

    fvm.connect("adder", "output", "display_adder", "input");

    fvm.add_input_array_selection("adder", "numbers", "x");
    fvm.add_input_array_selection("adder", "numbers", "y");

    let x = fvm.get_array_sender("adder", "numbers", "x");
    let x: CountSender<i32> = component::downcast(x);
    let y = fvm.get_array_sender("adder", "numbers", "y");
    let y: CountSender<i32> = component::downcast(y);


    o.send("first test : ".to_string());
    x.send(1).unwrap();
    y.send(11).unwrap();
    x.send(2).unwrap();
    y.send(22).unwrap();
    x.send(3).unwrap();
    fvm.start("adder");
    thread::sleep_ms(2000);
    o.send("first test change : ".to_string());
    o.send("first test change twices : ".to_string());
    thread::sleep_ms(2000);
    y.send(33).unwrap();
 
    thread::sleep_ms(2000);
    println!("");
    println!("");
 
 
    fvm.add_component("dlb1", Display::<String>::new());
    fvm.add_component("dlb2", Display::<String>::new());
    fvm.add_component("dlb3", Display::<String>::new());
    fvm.add_component("lb", LoadBalancer::<String>::new());
 
    let o = fvm.get_sender("dlb1", "option");
    let o: SyncSender<String> = component::downcast(o);
    o.send("lb first display : ".to_string());
    let o = fvm.get_sender("dlb2", "option");
    let o: SyncSender<String> = component::downcast(o);
    o.send("lb second display : ".to_string());
    let o = fvm.get_sender("dlb3", "option");
    let o: SyncSender<String> = component::downcast(o);
    o.send("lb third display : ".to_string());
    thread::sleep_ms(1000);
 
    fvm.connect("lb", "acc", "lb", "acc");
    fvm.add_output_array_selection("lb", "output", "1");
    fvm.add_output_array_selection("lb", "output", "2");
    fvm.add_output_array_selection("lb", "output", "z");
    fvm.connect_array("lb", "output", "1", "dlb1", "input");
    fvm.connect_array("lb", "output", "2", "dlb2", "input");
    fvm.connect_array("lb", "output", "z", "dlb3", "input");
    let acc = fvm.get_sender("lb", "acc");
    let acc: CountSender<usize> = component::downcast(acc);
    acc.send(0).unwrap();
 
    let i = fvm.get_sender("lb", "input");
    let i: CountSender<String> = component::downcast(i);
    fvm.start("lb");
 
    i.send("hello Fractalide".to_string()).unwrap();
    i.send("hello Fractalide".to_string()).unwrap();
    i.send("hello Fractalide".to_string()).unwrap();
    i.send("hello Fractalide".to_string()).unwrap();
    thread::sleep_ms(2000);

}
