#![feature(core)]
#![feature(alloc)]
use std::thread;

mod component;
use component::*;

// The Display Component
struct DisplayInt {
    pre: String,
}
impl DisplayInt {
    fn new_component(pre: &'static str) -> ComponentCreator {
        ComponentCreator {
            closure: Box::new(DisplayInt { pre: pre.to_string(), }), 
            input_ports: vec!["input"],
            output_ports: vec!["output"],
        }
    }
}
impl Closure for DisplayInt {
    fn run(&mut self, inputs: &InputPorts, outputs: &OutputPorts) {
        let port = inputs.get_simple("input").unwrap();
        let msg: i32 = port.recv_ip().unwrap();
        println!("{}{}", self.pre, msg);
        let out = outputs.get_simple("output").unwrap();
        out.send(msg);
    }
}

// The Adder Component
struct Adder;
impl Adder {
    fn new_component() -> ComponentCreator {
        ComponentCreator {
            closure: Box::new(Adder),
            input_ports: vec!["x", "y"],
            output_ports: vec!["result"],
        }
    }
}
impl Closure for Adder {
    fn run(&mut self, inputs: &InputPorts, outputs: &OutputPorts) {
        let port_x = inputs.get_simple("x").unwrap();
        let port_y = inputs.get_simple("y").unwrap();
        let x: i32 = port_x.recv_ip().unwrap();
        let y: i32 = port_y.recv_ip().unwrap();
        let out = outputs.get_simple("result").unwrap();
        out.send(x+y);
    }
}

struct VecLen;
impl VecLen {
    fn new_component() -> ComponentCreator {
        ComponentCreator {
            closure: Box::new(VecLen),
            input_ports: vec!["input"],
            output_ports: vec!["output"],
        }
    }
}
impl Closure for VecLen {
    fn run(&mut self, inputs: &InputPorts, outputs: &OutputPorts) {
        let port = inputs.get_simple("input").unwrap();
        let v: Vec<i32> = port.recv_ip().unwrap();
        println!("len : {}", v.len());
        let out = outputs.get_simple("output").unwrap();
        out.send(v);
    }
}

fn main() {
    // Create 4 components : 3 display, 1 adder 
    let mut dx = Component::new(DisplayInt::new_component("x : "));
    let mut dy = Component::new(DisplayInt::new_component("y : "));
    let dr = Component::new(DisplayInt::new_component("result : "));
    let mut a1 = Component::new(Adder::new_component());

    /*
     * Graph like 
     *   "11" -> input dx(display) output -> x a1(adder) result -> input dr(display)
     *   "111" -> input dy(display) oiutput -> y a1()
     */
    a1.connect_output_port("result", &dr, "input");
    dx.connect_output_port("output", &a1, "x");
    dy.connect_output_port("output", &a1, "y");


    // Start the comp
    dx.start();
    dy.start();
    dr.start();
    a1.start();

    // Vec test
    let v = Component::new(VecLen::new_component());
    let input = v.get_sender("input").unwrap();
    v.start();


    // Get the input ports and send numbers
    let x = dx.get_sender("input").unwrap();
    let y = dy.get_sender("input").unwrap();
    x.send(Box::new(11)).unwrap();
    y.send(Box::new(111)).unwrap();
    x.send(Box::new(111)).unwrap();
    y.send(Box::new(1111)).unwrap();

    thread::sleep_ms(2000);
    input.send(Box::new(vec![1, 2, 3])).unwrap();

    thread::sleep_ms(2000);
}
