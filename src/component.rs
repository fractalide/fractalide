/*
 * The component library for Fractalide
 *
 * Author : Denis Michiels
 * Copyright (C) 2015 Michiels Denis
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */
#![feature(core)]
#![feature(alloc)]
use std::marker::Reflect;
use std::raw::TraitObject;
use std::boxed;

use std::collections::HashMap;

use std::sync::mpsc::{SyncSender, Sender, Receiver, SendError, RecvError};
use std::sync::mpsc::sync_channel;
use std::sync::mpsc::channel;

use std::thread;
use std::mem;
use std::any::Any;

/*
 * Input Ports for the state, only the receivers
 */

type IP = Box<Any + Send>;

pub trait InputPort<T> {
    fn recv_ip<I: Reflect + 'static>(&self) -> Result<I, RecvError>;
}
impl InputPort<IP> for Receiver<IP> {
    fn recv_ip<I: Reflect + 'static>(&self) -> Result<I, RecvError> {
        unsafe {
            let obj: Box<Any> = self.recv().unwrap();
            if !(*obj).is::<I>(){
                panic!("Type mismatch");
            }
            let raw: TraitObject = mem::transmute(boxed::into_raw(obj));
            Ok(*Box::from_raw(raw.data as *mut I))
        }
    }
}

pub struct InputPorts {
   simple: HashMap<&'static str, Receiver<IP>>,
}

impl InputPorts {

    fn new() -> Self {
        InputPorts { simple: HashMap::new(), }
    }

    fn add_simple(&mut self, name: &'static str, rec: Receiver<IP>) -> Option<Receiver<IP>> {
        self.simple.insert(name, rec) 
    }

    fn remove_simple(&mut self, name: &'static str) -> Option<Receiver<IP>> {
        self.simple.remove(&name)
    }

    pub fn get_simple(&self, name: &'static str) -> Option<&Receiver<IP>> {
        self.simple.get(name)
    }
}

#[test]
fn input_ports_tests() {
   let mut input = InputPorts::new();
   let (tx, rx) = sync_channel(16);
   input.add_simple("input", rx);
   tx.send(Box::new(42)).unwrap();
   {
   let port = input.get_simple("input").unwrap();
   let result: i32 = port.recv_ip().unwrap();
   assert_eq!(result, 42);
   }
   {
   let recv = input.remove_simple("input");
   assert!(recv.is_some());
   }
   {
   let recv = input.remove_simple("input");
   assert!(recv.is_none());
   }
   let port = input.get_simple("input");
   assert!(port.is_none());
}

/*
 * Output Ports for the state
 */

pub enum OutputPortError {
    NotConnected,
    CannotSend(SendError<IP>),
}

pub struct OutputPort {
    send: Option<SyncSender<IP>>,
}
impl OutputPort {
    fn new() -> Self {
        OutputPort { send: None, }
    }

    pub fn connect(&mut self, send: SyncSender<IP>){
        self.send = Some(send);
    }

    pub fn send<T: Any + Send>(&self, msg: T) -> Result<(), OutputPortError> {
        if self.send.is_none() {
            Err(OutputPortError::NotConnected)
        } else {
            let send = self.send.as_ref().unwrap();
            let res = send.send(Box::new(msg));
            if res.is_ok() { Ok(()) }
            else { Err(OutputPortError::CannotSend(res.unwrap_err())) }
        }
    }


}

pub struct OutputPorts {
    simple: HashMap<&'static str, OutputPort>,
}

impl OutputPorts {
    fn new() -> Self {
        OutputPorts { simple: HashMap::new(), }
    }

    pub fn add_simple(&mut self, name: &'static str) -> Option<OutputPort>{
        self.simple.insert(name, OutputPort::new())
    }

    pub fn remove_simple(&mut self, name: &'static str) -> Option<OutputPort> {
        self.simple.remove(name)
    }

    pub fn get_simple(&self, name: &'static str) -> Option<&OutputPort> {
        self.simple.get(name)
    }

    fn get_simple_mut(&mut self, name: &'static str) -> Option<&mut OutputPort> {
        self.simple.get_mut(name)
    }
}


#[test]
fn output_ports_tests() {
   let mut output = OutputPorts::new();
   let (tx, rx) = sync_channel(16);
   {
   let res = output.get_simple("output");
   assert!(res.is_none());
   }
   output.add_simple("output");
   {
   let res = output.remove_simple("output");
   assert!(res.is_some());
   }
   {
   let res = output.remove_simple("output");
   assert!(res.is_none());
   }
   output.add_simple("output");
   let mut out = output.get_simple_mut("output").unwrap();
   out.connect(tx);
   out.send(42);
   let res: i32 = rx.recv_ip().unwrap();
   assert_eq!(res, 42);
}

#[test]
fn input_output_ports_tests() {
    let mut input = InputPorts::new();
    let mut output = OutputPorts::new();
    let (tx, rx) = sync_channel(16);
    input.add_simple("input", rx);
    output.add_simple("output");
    let out = output.get_simple_mut("output").unwrap();
    out.connect(tx);
    out.send(42);
    let port = input.get_simple("input").unwrap();
    let msg: i32 = port.recv_ip().unwrap();
    assert_eq!(msg, 42);
}


/*
 * Component Structure
 * Divided in two : component and state. 
 * The component is the user interface for the component.
 * The state is the running part of the component, in a Thread.
 * The two use a channel to interact.
 */

pub struct ComponentCreator {
    pub closure: Box<Closure + Send + 'static>,
    pub input_ports: Vec<&'static str>,
    pub output_ports: Vec<&'static str>,
}

pub trait Closure {
    fn run(&mut self, input_ports: &InputPorts, output_ports: &OutputPorts);
}

pub type BoxedClosure = Box<Closure + Send>;

enum CompMsg {
    Start, Stop, Halt,
    RunEnd(BoxedClosure, InputPorts, OutputPorts),
    ConnectOutputPort(&'static str, SyncSender<IP>),
    AddInputPort(&'static str, Receiver<IP>),
    AddOutputPort(&'static str),
}

enum CompError {
    PortNotFound(&'static str),
}

pub struct Component {
    sender: Sender<CompMsg>,
    input_senders: HashMap<&'static str, SyncSender<IP>>,
}

impl Component {
    pub fn new(c: ComponentCreator) -> Self {
        let (control_s, control_r) = channel();
        {
            let control_sender = control_s.clone();
            let mut state = State::new(c.closure, control_sender);
            thread::spawn(move || {
                loop {
                    let msg = control_r.recv().unwrap();
                    match msg {
                        CompMsg::Start => { state.start(); },
                        CompMsg::Stop => { state.stop(); },
                        CompMsg::Halt => { break; },
                        CompMsg::RunEnd(closure, inputs, outputs)  => { state.run_end(closure, inputs, outputs); },
                        CompMsg::AddInputPort(name, rec) => { state.receive_edit_msg(CompMsg::AddInputPort(name, rec)); },
                        CompMsg::AddOutputPort(name) => { state.receive_edit_msg(CompMsg::AddOutputPort(name)); },
                        CompMsg::ConnectOutputPort(port, send) => { state.receive_edit_msg(CompMsg::ConnectOutputPort(port, send)); },
                    }
                }
            });
        }
        let mut comp = Component {
            sender: control_s,
            input_senders: HashMap::new(),
        };
        for input in c.input_ports {
            comp.add_input_port(input);
        }
        for output in c.output_ports {
            comp.add_output_port(output);
        }
        comp
    }

    pub fn add_input_port(&mut self, name: &'static str) {
        let (tx, rx) = sync_channel(16);
        self.input_senders.insert(name, tx);
        self.sender.send(CompMsg::AddInputPort(name, rx)).unwrap();
    }

    pub fn add_output_port(&mut self, name: &'static str) {
        self.sender.send(CompMsg::AddOutputPort(name)).unwrap();
    }

    pub fn connect_output_port(&mut self, name: &'static str, rec: &Component, dest: &'static str) {
        let s = rec.get_sender(dest);
        if let Some(s) = s {
            self.sender.send(CompMsg::ConnectOutputPort(name, s)).unwrap();
        }
    }

    pub fn start(&self) {
        self.sender.send(CompMsg::Start).unwrap();
    }

    pub fn get_sender(&self, name: &'static str) -> Option<SyncSender<IP>> {
        match self.input_senders.get(name) {
            None => { None },
            Some(s) => {
                Some(s.clone())
            }
        }
    }
}

struct State {
    control_sender:Sender<CompMsg>,
    closure: Option<BoxedClosure>,
    in_receivers: Option<InputPorts>,
    out_senders: Option<OutputPorts>,
    can_run: bool,
    edit_msgs: Vec<CompMsg>,
}

impl State {
    fn new(c: BoxedClosure, cs: Sender<CompMsg>) -> Self {
        State {
            control_sender: cs,
            closure: Some(c),
            in_receivers: Some(InputPorts::new()),
            out_senders: Some(OutputPorts::new()),
            can_run: false,
            edit_msgs: vec![],
        }
    }

    fn edit_component(&mut self, msg: CompMsg){
        match msg {
            CompMsg::AddInputPort(name, rec) => {
                self.in_receivers.as_mut().unwrap().add_simple(name, rec);
            },
            CompMsg::AddOutputPort(name) => {
                self.out_senders.as_mut().unwrap().add_simple(name);
            },
            CompMsg::ConnectOutputPort(name, send) => {
                let port = self.out_senders.as_mut().unwrap().get_simple_mut(name).unwrap();
                port.connect(send);
            },
            _ => { },
        }

    }

    fn receive_edit_msg(&mut self, msg: CompMsg){
        if self.can_run {
            self.edit_msgs.push(msg);
        } else {
            self.edit_component(msg);
        }
    }

    fn start(&mut self) { 
        if !self.can_run {
            self.can_run = true;
            self.run(); 
        }
    }

    fn stop(&mut self) { 
        self.can_run = false;
    }

    fn run_end(&mut self, c: BoxedClosure, i: InputPorts, o: OutputPorts) {
        self.closure = Some(c);
        self.in_receivers = Some(i);
        self.out_senders = Some(o);
        let msgs = mem::replace(&mut self.edit_msgs, vec![]);
        for msg in msgs {
            self.edit_component(msg);
        }
        if self.can_run {
            self.run();
        }
    }

    fn run(&mut self) {
        let mut c = mem::replace(&mut self.closure, None).unwrap();
        let inputs = mem::replace(&mut self.in_receivers, None).unwrap();
        let outputs = mem::replace(&mut self.out_senders, None).unwrap();
        let control_sender = self.control_sender.clone();

        thread::spawn(move || {
            c.run(&inputs, &outputs);
            control_sender.send(CompMsg::RunEnd(c, inputs, outputs)).unwrap();
        });
    }
}

#[test]
fn edit_state_tests() {
    struct Test; 
    impl Closure for Test {
        fn run(&mut self, input: &InputPorts, output: &OutputPorts){
        }
    }
    let (tx, rx) = channel();
    let mut state = State::new(Box::new(Test), tx);

    // Add while not running
    assert!(state.edit_msgs.len() == 0);
    state.receive_edit_msg(CompMsg::AddOutputPort("input"));
    assert!(state.edit_msgs.len() == 0);
    assert!(state.out_senders.as_mut().unwrap().simple.len() == 1);

    // Add while running
    state.start();
    state.receive_edit_msg(CompMsg::AddOutputPort("input2"));
    // Must save the msg
    assert!(state.edit_msgs.len() == 1);
    assert!(state.out_senders.is_none());
    // At the end, the msg must read. As the closure run again, we have
    // no access to the out_senders
    state.run_end(Box::new(Test), InputPorts::new(), OutputPorts::new());
    assert!(state.edit_msgs.len() == 0);
    assert!(state.out_senders.is_none());

    // Add after stop
    state.receive_edit_msg(CompMsg::AddOutputPort("input3"));
    state.stop();
    state.run_end(Box::new(Test), InputPorts::new(), OutputPorts::new());
    assert!(state.edit_msgs.len() == 0);
    assert!(state.out_senders.as_mut().unwrap().simple.len() == 1);

    // receive useless msgs
    rx.recv();
    rx.recv();

}
