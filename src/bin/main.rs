#![feature(reflect_marker)]
#![feature(concat_idents)]
#![feature(braced_empty_structs)]

#[macro_use]
extern crate fractalide;

use self::fractalide::component;
use self::fractalide::component::{Component, ComponentRun, ComponentConnect, OutputSender, IP, InputSenders, InputArraySenders, InputArrayReceivers, OptionReceiver, CountSender, CountReceiver, count_channel};
use self::fractalide::scheduler::{CompMsg, Scheduler};
use self::fractalide::subnet::*;

use std::fmt::Debug;

use std::sync::mpsc::{SyncSender, Receiver, Sender};
use std::sync::mpsc::sync_channel;
use std::sync::atomic::Ordering;
use std::any::Any;
use std::collections::HashMap;

use std::thread;
use std::mem;

component! {
    Nand,
    inputs(NANDIA NANDIB => (a: bool, b: bool)),
    inputs_array(NANDIIA NANDIIB => ()),
    outputs(NANDO => (output:bool)),
    outputs_array(NANDOA => ()),
    fn run(&mut self) {
        let a = self.inputs.a.recv().unwrap();
        let b = self.inputs.b.recv().unwrap();
        let out = if a == false || b == false { true } else {false};
        let _ = self.outputs.output.send(out).ok().expect("Nand: cannot send out");
    }
}

component! {
    IIPC,
    inputs(IIPCS IIPCR => ()),
    inputs_array(IIPCAS IIPCAR => ()),
    outputs(IIPCO => (output: i32)),
    outputs_array(IIPCOA => ()),
    fn run(&mut self) {
        let _ = self.outputs.output.send(42);
        let _ = self.outputs.output.send(666);
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

trait CloneIP: Clone + IP {}
impl <T> CloneIP for T where T: Clone + IP {}
component! {
    CloneC, (T: CloneIP),
    inputs(CS CR (T: CloneIP) => (input: T)),
    inputs_array(CAS CAR => ()),
    outputs(CO => ()),
    outputs_array(CAO (T: CloneIP) => (output: T)),
    fn run(&mut self) {
        let msg = self.inputs.input.recv().unwrap();
        for out in self.outputs_array.output.values() {
            out.send(msg.clone());
        }
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
    let mut fvm = Scheduler::new();
    // fvm.add_component("iip1".to_string(), IIPC::new());
    // fvm.add_component("display1".to_string(), Display::<i32>::new());
    // fvm.subnet_names.insert("kikin".to_string(), ("display1".to_string(), "input".to_string()));
    // fvm.connect("iip1".to_string(), "output".to_string(), "kik".to_string(), "in".to_string());
    // fvm.start("iip1".to_string());

    // thread::sleep_ms(1000);
    // println!("");
    // println!("");

    //fvm.add_component("adder".to_string(), Adder::new());
    //fvm.add_component("display_adder".to_string(), Display::<i32>::new());
    //let o: SyncSender<String> = fvm.get_option("display_adder".to_string());

    //fvm.connect("adder".to_string(), "output".to_string(), "display_adder".to_string(), "input".to_string());

    //fvm.add_input_array_selection("adder".to_string(), "numbers".to_string(), "x".to_string());
    //fvm.add_input_array_selection("adder".to_string(), "numbers".to_string(), "y".to_string());

    //let x: CountSender<i32> = fvm.get_array_sender("adder".to_string(), "numbers".to_string(), "x".to_string());
    //let y: CountSender<i32> = fvm.get_array_sender("adder".to_string(), "numbers".to_string(), "y".to_string());


    //o.send("first test : ".to_string());
    //x.send(1).unwrap();
    //y.send(11).unwrap();
    //x.send(2).unwrap();
    //y.send(22).unwrap();
    //x.send(3).unwrap();
    //thread::sleep_ms(2000);
    //o.send("first test change : ".to_string());
    //o.send("first test change twices : ".to_string());
    //y.send(33).unwrap();
 
    //thread::sleep_ms(2000);
    //println!("");
    //println!("");

    let nand1 = Node{ name: "nand1".to_string(), sort: COrG::C(Nand::new) };
    let clone = Node{ name: "clone".to_string(), sort: COrG::C(CloneC::<bool>::new) };
    let edge1 = Edge::Array2simple("clone".to_string(), "output".to_string(), "1".to_string(), "nand1".to_string(), "a".to_string());
    let edge2 = Edge::Array2simple("clone".to_string(), "output".to_string(), "2".to_string(), "nand1".to_string(), "b".to_string());
    let not = Graph {
        nodes: vec![nand1, clone],
        edges: vec![edge1, edge2],
        virtual_ports: vec![VirtualPort("input".to_string(), "clone".to_string(), "input".to_string()), 
                            VirtualPort("output".to_string(), "nand1".to_string(), "output".to_string())],
        iips: vec![],
    };

    fvm.add_subnet("firstnot".to_string(), not.clone());
    fvm.add_component("display_not".to_string(), Display::<bool>::new());
    let o: SyncSender<String> = fvm.get_option("display_not".to_string());
    o.send("Not result : ".to_string());
    fvm.connect("firstnot".to_string(), "output".to_string(), "display_not".to_string(), "input".to_string());


    let s: CountSender<bool> = fvm.get_sender("firstnot".to_string(), "input".to_string());
    s.send(true);
    s.send(false);

    thread::sleep_ms(2000);
    println!("");
    println!("");

    let nand1 = Node{ name: "nand1".to_string(), sort: COrG::C(Nand::new) };
    let sn_not = Node{ name: "not".to_string(), sort: COrG::G(not) };
    let edge3 = Edge::Simple2simple("nand1".to_string(), "output".to_string(), "not".to_string(), "input".to_string());
    let g = Graph {
        nodes: vec![nand1, sn_not],
        edges: vec![edge3],
        virtual_ports: vec![VirtualPort("a".to_string(), "nand1".to_string(), "a".to_string()), 
                            VirtualPort("b".to_string(), "nand1".to_string(), "b".to_string()),
                            VirtualPort("output".to_string(), "not".to_string(), "output".to_string())],
        iips: vec![],
    };

    fvm.add_subnet("firstand".to_string(), g);
    fvm.add_component("display_and".to_string(), Display::<bool>::new());
    fvm.connect("firstand".to_string(), "output".to_string(), "display_and".to_string(), "input".to_string());
    let a: CountSender<bool> = fvm.get_sender("firstand".to_string(), "a".to_string());
    let b: CountSender<bool> = fvm.get_sender("firstand".to_string(), "b".to_string());
    let o: SyncSender<String> = fvm.get_option("display_and".to_string());
    o.send("And result : ".to_string());

    thread::sleep_ms(1000);
    a.send(true).unwrap();
    b.send(false).unwrap();

    a.send(true).unwrap();
    b.send(true).unwrap();

    thread::sleep_ms(2000);
//     println!("");
//     println!("");
//  
//  
//     fvm.add_component("dlb1", Display::<String>::new());
//     fvm.add_component("dlb2", Display::<String>::new());
//     fvm.add_component("dlb3", Display::<String>::new());
//     fvm.add_component("lb", LoadBalancer::<String>::new());
//  
//     let o = fvm.get_sender("dlb1", "option");
//     let o: SyncSender<String> = component::downcast(o);
//     o.send("lb first display : ".to_string());
//     let o = fvm.get_sender("dlb2", "option");
//     let o: SyncSender<String> = component::downcast(o);
//     o.send("lb second display : ".to_string());
//     let o = fvm.get_sender("dlb3", "option");
//     let o: SyncSender<String> = component::downcast(o);
//     o.send("lb third display : ".to_string());
//     thread::sleep_ms(1000);
//  
//     fvm.connect("lb", "acc", "lb", "acc");
//     fvm.add_output_array_selection("lb", "output", "1");
//     fvm.add_output_array_selection("lb", "output", "2");
//     fvm.add_output_array_selection("lb", "output", "z");
//     fvm.connect_array("lb", "output", "1", "dlb1", "input");
//     fvm.connect_array("lb", "output", "2", "dlb2", "input");
//     fvm.connect_array("lb", "output", "z", "dlb3", "input");
//     let acc = fvm.get_sender("lb", "acc");
//     let acc: CountSender<usize> = component::downcast(acc);
//     acc.send(0).unwrap();
//  
//     let i = fvm.get_sender("lb", "input");
//     let i: CountSender<String> = component::downcast(i);
//     fvm.start("lb");
//  
//     i.send("hello Fractalide".to_string()).unwrap();
//     i.send("hello Fractalide".to_string()).unwrap();
//     i.send("hello Fractalide".to_string()).unwrap();
//     i.send("hello Fractalide".to_string()).unwrap();
//     thread::sleep_ms(2000);

}
