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
            input_array_ports: vec![],
            output_array_ports: vec![],
        }
    }
}
impl Closure for DisplayInt {
    fn run(&mut self, inputs: &InputPorts, outputs: &OutputPorts) {
        let port = inputs.simple.get("input").unwrap();
        let msg: i32 = port.recv_ip().unwrap();
        println!("{}{}", self.pre, msg);
        let out = outputs.simple.get("output").unwrap();
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
            input_array_ports: vec![],
            output_array_ports: vec![],
        }
    }
}
impl Closure for Adder {
    fn run(&mut self, inputs: &InputPorts, outputs: &OutputPorts) {
        let port_x = inputs.simple.get("x").unwrap();
        let port_y = inputs.simple.get("y").unwrap();
        let x: i32 = port_x.recv_ip().unwrap();
        let y: i32 = port_y.recv_ip().unwrap();
        let out = outputs.simple.get("result").unwrap();
        out.send(x+y);
    }
}

// Adder with array port
struct ArrayAdder;
impl ArrayAdder {
    fn new_component() -> ComponentCreator {
        ComponentCreator {
            closure: Box::new(ArrayAdder),
            input_ports: vec![],
            output_ports: vec!["result"],
            input_array_ports: vec!["numbers"],
            output_array_ports: vec![],
        }
    }
}
impl Closure for ArrayAdder {
    fn run(&mut self, inputs: &InputPorts, outputs: &OutputPorts) {
        let numbers = inputs.array.get("numbers").unwrap();
        let res = numbers.values().fold(0, |acc, port| {
            let msg: i32 = port.recv_ip().unwrap();
            acc + msg
        });
        let out = outputs.simple.get("result").unwrap();
        out.send(res);
    }
}

// Load balancer
struct LoadBalancer {
    actual: usize,   
}
impl LoadBalancer {
    fn new_component() -> ComponentCreator {
        ComponentCreator {
            closure: Box::new(LoadBalancer { actual: 0, }),
            input_ports: vec!["input"],
            output_ports: vec![],
            input_array_ports: vec![],
            output_array_ports: vec!["output"],
        }
    }
}
impl Closure for LoadBalancer {
    fn run(&mut self, inputs: &InputPorts, outputs: &OutputPorts) {
        // get the correct output port
        let output = outputs.array.get("output").unwrap();
        // TODO : check if there is at least one output
        if (self.actual > output.len()-1){ self.actual = 0; }
        let mut list: Vec<_> = output.iter().collect();
        list.sort_by(|&a, &b| { (a.0).cmp((&b.0)) });
        let port = list.get(self.actual).unwrap();

        // send the IP
        let in_port = inputs.simple.get("input").unwrap();
        let ip: i32 = in_port.recv_ip().unwrap();
        (port.1).send(ip).ok().expect("LoadBalancer: cannot send");
        self.actual += 1;
    }

}   


struct VecLen;
impl VecLen {
    fn new_component() -> ComponentCreator {
        ComponentCreator {
            closure: Box::new(VecLen),
            input_ports: vec!["input"],
            output_ports: vec!["output"],
            input_array_ports: vec![],
            output_array_ports: vec![],
        }
    }
}
impl Closure for VecLen {
    fn run(&mut self, inputs: &InputPorts, outputs: &OutputPorts) {
        let port = inputs.simple.get("input").unwrap();
        let v: Vec<i32> = port.recv_ip().unwrap();
        println!("len : {}", v.len());
        let out = outputs.simple.get("output").unwrap();
        out.send(v);
    }
}

fn main() {
    let mut array_add = Component::new(ArrayAdder::new_component());
    let mut load_bal = Component::new(LoadBalancer::new_component());
    let da = Component::new(DisplayInt::new_component("a : "));
    let db = Component::new(DisplayInt::new_component("b : "));
    let dc = Component::new(DisplayInt::new_component("c : "));

    /*
     * Graph like
     * "22" -> numbers[1] array_add() result -> input lb(LoadBalancer) output[a] -> input da()
     * "222" -> numbers[2] array_add()
     * lb() output[b] -> input db()
     * lb() output[z] -> input dc()
     */
    array_add.add_input_array_selection("numbers", "1");
    array_add.add_input_array_selection("numbers", "2");
    array_add.connect_output_port("result", &load_bal, "input");

    load_bal.add_output_array_selection("output", "a");
    load_bal.add_output_array_selection("output", "b");
    load_bal.add_output_array_selection("output", "z");
    load_bal.connect_output_array_port("output", "a", &da, "input");
    load_bal.connect_output_array_port("output", "b", &db, "input");
    load_bal.connect_output_array_port("output", "z", &dc, "input");

    // Start
    array_add.start();
    load_bal.start();
    da.start();
    db.start();
    dc.start();

    // Array test
    println!("Array Test");
    let n1 = array_add.get_array_sender("numbers", "1").unwrap();
    let n2 = array_add.get_array_sender("numbers", "2").unwrap();
    n1.send(Box::new(11)).unwrap();
    n2.send(Box::new(111)).unwrap();
    n1.send(Box::new(22)).unwrap();
    n2.send(Box::new(222)).unwrap();
    n1.send(Box::new(33)).unwrap();
    n1.send(Box::new(44)).unwrap();
    n1.send(Box::new(55)).unwrap();
    n2.send(Box::new(333)).unwrap();
    thread::sleep_ms(1000);
    n2.send(Box::new(444)).unwrap();
    n2.send(Box::new(555)).unwrap();

    thread::sleep_ms(2000);

}
