#![feature(concat_idents)]
#![feature(braced_empty_structs)]

#[macro_use]
extern crate rustfbp;

use self::rustfbp::scheduler::{Scheduler};
use self::rustfbp::subnet::*;
use self::rustfbp::component::{CountSender};

use std::sync::mpsc::SyncSender;
use std::thread;
component! {
    Nand,
    inputs(a: bool, b: bool),
    inputs_array(),
    outputs(output:bool),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) {
        let a = self.inputs.a.recv().unwrap();
        let b = self.inputs.b.recv().unwrap();
        let out = if a == false || b == false { true } else {false};
        let _ = self.outputs.output.send(out).ok().expect("Nand: cannot send out");
    }
}

component! {
    IIPC,
    inputs(),
    inputs_array(),
    outputs(output: i32),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) {
        let _ = self.outputs.output.send(42);
        let _ = self.outputs.output.send(666);
    }
}

component! {
    Adder, 
    inputs(),
    inputs_array(numbers: i32),
    outputs(output:i32),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) {
        let res = self.inputs_array.numbers.values().fold(0, |acc, port| {
            let msg = port.recv().unwrap();
            acc + msg
        });
        let _ = self.outputs.output.send(res);
    }
}   


component! {
    Display, (T: DisplayIP),
    inputs(input: T where T: DisplayIP),
    inputs_array(),
    outputs(output: T where T: DisplayIP),
    outputs_array(),
    option(String),
    acc(),
    fn run(&mut self){
        let i = self.inputs.input.recv().unwrap();
        let pre = match self.inputs.option.try_recv() {
            Ok(msg) => { msg },
            _ => { "".to_string() },
        };
        println!("{}{:?}", pre, i);
        let _ = self.outputs.output.send(i);
    }
    use std::fmt::Debug;
    pub trait DisplayIP: Debug + IP {}
    impl <T> DisplayIP for T where T : Debug + IP {}
}

component! {
    CloneC, (T: CloneIP),
    inputs(input: T where T: CloneIP),
    inputs_array(),
    outputs(),
    outputs_array(output: T where T: CloneIP),
    option(),
    acc(),
    fn run(&mut self) {
        let msg = self.inputs.input.recv().unwrap();
        for out in self.outputs_array.output.values() {
            out.send(msg.clone()).ok().unwrap();
        }
    }
    pub trait CloneIP: Clone + IP {}
    impl <T> CloneIP for T where T: Clone + IP {}
}

component! {
    ConcatC, (T: IP),
    inputs(),
    inputs_array(inputs: T where T: IP),
    outputs(output: T where T: IP),
    outputs_array(),
    option(),
    acc(usize),
    fn run(&mut self){
        let mut actual = self.inputs.acc.recv().unwrap();
        if actual > self.inputs_array.inputs.len()-1 { actual = 0; }
        let mut list: Vec<_> = self.inputs_array.inputs.iter().collect();
        list.sort_by(|&a, &b| { (a.0).cmp((&b.0)) });
        let port = list.get(actual).unwrap();
        self.outputs.output.send(port.1.recv().unwrap()).ok().unwrap();
        self.outputs.acc.send(actual+1).ok().unwrap();

    }
}

component! {
    LoadBalancer, (T: IP),
    inputs(input: T where T: IP),
    inputs_array(),
    outputs(),
    outputs_array(output: T where T: IP),
    option(),
    acc(usize),
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

    let not = GraphBuilder::new()
        .add_component("nand1".into(), Nand::new)
        .add_component("clone".into(), CloneC::new::<bool>)
        .edges()
        .add_array2simple("clone".into(), "output".into(), "1".into(), "nand1".into(), "a".into())
        .add_array2simple("clone".into(), "output".into(), "2".into(), "nand1".into(), "b".into())
        .add_virtual_input_port("input".into(), "clone".into(), "input".into())
        .add_virtual_output_port("output".into(), "nand1".into(), "output".into());

    fvm.add_subnet("firstnot".to_string(), &not);
    fvm.add_component("display_not".to_string(), Display::new::<bool>());
    let o: SyncSender<String> = fvm.get_option("display_not".to_string());
    let _ = o.send("Not result : ".to_string());
    fvm.connect("firstnot".to_string(), "output".to_string(), "display_not".to_string(), "input".to_string());


    let s: CountSender<bool> = fvm.get_sender("firstnot".to_string(), "input".to_string());
    s.send(true).unwrap();
    s.send(false).unwrap();

    thread::sleep_ms(2000);
    println!("");
    println!("");

    let and = GraphBuilder::new()
        .add_component("nand1".into(), Nand::new)
        .add_component("display_and".into(), Display::new::<bool>)
        .add_subnet("not".into(), &not)
        .edges()
        .add_simple2simple("nand1".into(), "output".into(), "not".into(), "input".into())
        .add_virtual_input_port("a".into(), "nand1".into(), "a".into())
        .add_virtual_input_port("b".into(), "nand1".into(), "b".into())
        .add_simple2simple("not".into(), "output".into(), "display_and".into(), "input".into())
        .add_iip("And result : ".into(), "display_and".into(), "option".into());
    fvm.add_subnet("firstand".to_string(), &and);
    let a: CountSender<bool> = fvm.get_sender("firstand".to_string(), "a".to_string());
    let b: CountSender<bool> = fvm.get_sender("firstand".to_string(), "b".to_string());

    a.send(true).unwrap();
    b.send(false).unwrap();

    a.send(true).unwrap();
    b.send(true).unwrap();

    fvm.join();
    let mut fvm = Scheduler::new();
    println!("");
    println!("");
 
 
    fvm.add_component("dlb1".into(), Display::new::<String>());
    fvm.add_component("dlb2".into(), Display::new::<String>());
    fvm.add_component("dlb3".into(), Display::new::<String>());
    fvm.add_component("lb".into(), LoadBalancer::new::<String>());
 
    let o: SyncSender<String> = fvm.get_option("dlb1".into());
    o.send("lb first display : ".into()).ok().unwrap();
    let o: SyncSender<String> = fvm.get_option("dlb2".into());
    o.send("lb second display : ".to_string()).ok().unwrap();
    let o: SyncSender<String> = fvm.get_option("dlb3".into());
    o.send("lb third display : ".to_string()).ok().unwrap();
 
    fvm.connect("lb".into(), "acc".into(), "lb".into(), "acc".into());
    fvm.add_output_array_selection("lb".into(), "output".into(), "1".into());
    fvm.add_output_array_selection("lb".into(), "output".into(), "2".into());
    fvm.add_output_array_selection("lb".into(), "output".into(), "z".into());
    fvm.connect_array("lb".into(), "output".into(), "1".into(), "dlb1".into(), "input".into());
    fvm.connect_array("lb".into(), "output".into(), "2".into(), "dlb2".into(), "input".into());
    fvm.connect_array("lb".into(), "output".into(), "z".into(), "dlb3".into(), "input".into());
 
    let acc: SyncSender<usize> = fvm.get_acc("lb".into());
    acc.send(0).unwrap();
    let i: CountSender<String> = fvm.get_sender("lb".into(), "input".into());

    i.send("hello Fractalide".to_string()).unwrap();
    thread::sleep_ms(200);
    i.send("hello Fractalide".to_string()).unwrap();
    thread::sleep_ms(200);
    i.send("hello Fractalide".to_string()).unwrap();
    thread::sleep_ms(200);
    i.send("hello Fractalide".to_string()).unwrap();

    fvm.join();
    let mut fvm = Scheduler::new();
    println!("");
    println!("");

    fvm.add_component("concat".into(), ConcatC::new::<i32>());
    fvm.add_input_array_selection("concat".into(), "inputs".into(), "a".into());
    fvm.add_input_array_selection("concat".into(), "inputs".into(), "b".into());
    let acc: SyncSender<usize> = fvm.get_acc("concat".into());
    acc.send(0).unwrap();

    fvm.add_component("display_concat".into(), Display::new::<i32>());
    let o: SyncSender<String> = fvm.get_option("display_concat".into());
    let _ = o.send("concat result : ".into());

    fvm.connect("concat".into(), "output".into(), "display_concat".into(), "input".into());

    let a = fvm.get_array_sender("concat".into(), "inputs".into(), "a".into());
    let b = fvm.get_array_sender("concat".into(), "inputs".into(), "b".into());

    println!("Start concat");
    b.send(2).unwrap();
    thread::sleep_ms(1000);
    a.send(1).unwrap();
    a.send(1).unwrap();
    b.send(2).unwrap();

    fvm.join();


}
