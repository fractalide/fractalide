use std::thread;

mod component;
use component::*;

// The Display Component
struct Display {
    pre: String,
}
impl Display {
    fn new_component(pre: &'static str) -> ComponentCreator {
        ComponentCreator {
            closure: Box::new(Display { pre: pre.to_string(), }), 
            input_ports: vec!["input"],
            output_ports: vec!["output"],
        }
    }
}
impl Closure for Display {
    fn run(&mut self, inputs: &InputPorts, outputs: &OutputPorts) {
        let msg = inputs.recv("input").ok().expect("a message");
        println!("{}{}", self.pre, msg);
        outputs.send("output", msg);
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
        let x = inputs.recv("x").ok().expect("must be a x");
        let y = inputs.recv("y").ok().expect("must be a y");
        outputs.send("result", x+y);
    }
}

fn main() {
    // Create 4 components : 3 display, 1 adder 
    let mut dx = Component::new(Display::new_component("x : "));
    let mut dy = Component::new(Display::new_component("y : "));
    let mut dr = Component::new(Display::new_component("result : "));
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


    // Get the input ports and send numbers
    let x = dx.get_sender("input").unwrap();
    let y = dy.get_sender("input").unwrap();
    x.send(11).unwrap();
    y.send(111).unwrap();
    x.send(111).unwrap();
    y.send(1111).unwrap();

    println!("Hello, world!");
    thread::sleep_ms(2000);
}
