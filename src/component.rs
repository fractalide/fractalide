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

pub type IP = Box<Any + Send>;

pub trait ReceiverIP<T> {
    fn recv_ip<I: Reflect + 'static>(&self) -> Result<I, RecvError>;
}
impl ReceiverIP<IP> for Receiver<IP> {
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

trait InputPort {
}
impl InputPort for HashMap<&'static str, Receiver<IP>> {}

pub struct InputPorts {
   pub simple: HashMap<&'static str, Receiver<IP>>,
   pub array: HashMap<&'static str, HashMap<&'static str, Receiver<IP>>>,
}

impl InputPorts {

    fn new() -> Self {
        InputPorts { 
            simple: HashMap::new(), 
            array: HashMap::new(),
        }
    }
}

#[test]
fn input_ports_tests() {
   let mut input = InputPorts::new();
   let (tx, rx) = sync_channel(16);
   input.simple.insert("input", rx);
   tx.send(Box::new(42)).unwrap();
   {
   let port = input.simple.get("input").unwrap();
   let result: i32 = port.recv_ip().unwrap();
   assert_eq!(result, 42);
   }
   {
   let recv = input.simple.remove("input");
   assert!(recv.is_some());
   }
   {
   let recv = input.simple.remove("input");
   assert!(recv.is_none());
   }
   let port = input.simple.get("input");
   assert!(port.is_none());
}

/*
 * Output Ports for the state
 */

pub enum OutputPortError {
    NotConnected,
    CannotSend(SendError<IP>),
}

pub struct OutputSender {
    send: Option<SyncSender<IP>>,
}
impl OutputSender {
    fn new() -> Self {
        OutputSender { send: None, }
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

trait OutputPort {
    fn insert_empty(&mut self, name: &'static str) -> Option<OutputSender>; 
}
impl OutputPort for HashMap<&'static str, OutputSender> {
    fn insert_empty(&mut self, name: &'static str) -> Option<OutputSender>{
        self.insert(name, OutputSender::new())
    }
}

pub struct OutputPorts {
    pub simple: HashMap<&'static str, OutputSender>,
    pub array: HashMap<&'static str, HashMap<&'static str, OutputSender>>,
}

impl OutputPorts {
    fn new() -> Self {
        OutputPorts { 
            simple: HashMap::new(),
            array: HashMap::new(),
        }
    }
}


#[test]
fn output_ports_tests() {
   let mut output = OutputPorts::new();
   let (tx, rx) = sync_channel(16);
   {
   let res = output.simple.insert_empty("output");
   assert!(res.is_none());
   }
   output.simple.insert_empty("output");
   {
   let res = output.simple.remove("output");
   assert!(res.is_some());
   }
   {
   let res = output.simple.remove("output");
   assert!(res.is_none());
   }
   output.simple.insert_empty("output");
   let mut out = output.simple.get_mut("output").unwrap();
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
    input.simple.insert("input", rx);
    output.simple.insert_empty("output");
    let out = output.simple.get_mut("output").unwrap();
    out.connect(tx);
    out.send(42);
    let port = input.simple.get("input").unwrap();
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
    pub input_array_ports: Vec<&'static str>,
    pub output_array_ports: Vec<&'static str>,
}

pub trait Closure {
    fn run(&mut self, input_ports: &InputPorts, output_ports: &OutputPorts);
}

pub type BoxedClosure = Box<Closure + Send>;

enum CompMsg {
    Start, Stop, Halt,
    RunEnd(BoxedClosure, InputPorts, OutputPorts),
    ConnectOutputPort(&'static str, SyncSender<IP>),
    ConnectOutputArrayPort(&'static str, &'static str, SyncSender<IP>),
    AddInputPort(&'static str, Receiver<IP>),
    AddInputArrayPort(&'static str),
    AddInputArraySelection(&'static str, &'static str, Receiver<IP>),
    AddOutputPort(&'static str),
    AddOutputArrayPort(&'static str),
    AddOutputArraySelection(&'static str, &'static str),
}

enum CompError {
    PortNotFound(&'static str),
}


pub struct Component {
    sender: Sender<CompMsg>,
    input_simple_senders: HashMap<&'static str, SyncSender<IP>>,
    input_array_senders: HashMap<&'static str, HashMap<&'static str, SyncSender<IP>>>,
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
                        CompMsg::AddInputArrayPort(name) => { state.receive_edit_msg(CompMsg::AddInputArrayPort(name)); },
                        CompMsg::AddInputArraySelection(name, selection, rec) => { state.receive_edit_msg(CompMsg::AddInputArraySelection(name, selection, rec)); },
                        CompMsg::AddOutputPort(name) => { state.receive_edit_msg(CompMsg::AddOutputPort(name)); },
                        CompMsg::AddOutputArrayPort(name) => { state.receive_edit_msg(CompMsg::AddOutputArrayPort(name)); },
                        CompMsg::AddOutputArraySelection(name, selection) => { state.receive_edit_msg(CompMsg::AddOutputArraySelection(name, selection)); },
                        CompMsg::ConnectOutputPort(port, send) => { state.receive_edit_msg(CompMsg::ConnectOutputPort(port, send)); },
                        CompMsg::ConnectOutputArrayPort(port, selection, send) => { state.receive_edit_msg(CompMsg::ConnectOutputArrayPort(port, selection, send)); },
                    }
                }
            });
        }
        let mut comp = Component {
            sender: control_s,
            input_simple_senders: HashMap::new(),
            input_array_senders: HashMap::new(),
        };
        for input in c.input_ports {
            comp.add_input_port(input);
        }
        for output in c.output_ports {
            comp.add_output_port(output);
        }
        for input in c.input_array_ports {
            comp.add_input_array_port(input);
        }
        for output in c.output_array_ports {
            comp.add_output_array_port(output);
        }
        comp
    }

    pub fn add_input_port(&mut self, name: &'static str) {
        let (tx, rx) = sync_channel(16);
        self.input_simple_senders.insert(name, tx);
        self.sender.send(CompMsg::AddInputPort(name, rx)).unwrap();
    }

    pub fn add_input_array_port(&mut self, name: &'static str) {
        self.input_array_senders.insert(name, HashMap::new());
        self.sender.send(CompMsg::AddInputArrayPort(name)).unwrap();
    }
    
    pub fn add_input_array_selection(&mut self, name: &'static str, selection: &'static str) {
        let (tx, rx) = sync_channel(16);
        let mut array = self.input_array_senders.get_mut(name).unwrap();
        array.insert(selection, tx);
        self.sender.send(CompMsg::AddInputArraySelection(name, selection, rx)).unwrap();
    }

    pub fn add_output_port(&mut self, name: &'static str) {
        self.sender.send(CompMsg::AddOutputPort(name)).unwrap();
    }

    pub fn add_output_array_port(&mut self, name: &'static str) {
        self.sender.send(CompMsg::AddOutputArrayPort(name)).unwrap();
    }

    pub fn add_output_array_selection(&mut self, name: &'static str, selection: &'static str) {
        self.sender.send(CompMsg::AddOutputArraySelection(name, selection)).unwrap();
    }

    pub fn connect_output_port(&mut self, port_out: &'static str, rec: &Component, port_in: &'static str) {
        let s = rec.get_sender(port_in);
        if let Some(s) = s {
            self.sender.send(CompMsg::ConnectOutputPort(port_out, s)).unwrap();
        }
    }

    pub fn connect_output_port_to_array(&mut self, port_out: &'static str, rec: &Component, port_in: &'static str, selection_in: &'static str) {
        let s = rec.get_array_sender(port_in, selection_in);
        if let Some(s) = s {
            self.sender.send(CompMsg::ConnectOutputPort(port_out, s)).unwrap();
        }
    }

    pub fn connect_output_array_port(&mut self, port_out: &'static str, selection_out: &'static str, rec: &Component, port_in: &'static str) {
        let s = rec.get_sender(port_in);
        if let Some(s) = s {
            self.sender.send(CompMsg::ConnectOutputArrayPort(port_out, selection_out, s)).unwrap();
        }
    }

    pub fn connect_output_array_port_to_array(&mut self, port_out: &'static str, selection_out: &'static str, rec: &Component, port_in: &'static str, selection_in: &'static str) {
        let s = rec.get_array_sender(port_in, selection_in);
        if let Some(s) = s {
            self.sender.send(CompMsg::ConnectOutputArrayPort(port_out, selection_out, s)).unwrap();
        }
    }

    pub fn start(&self) {
        self.sender.send(CompMsg::Start).unwrap();
    }

    pub fn get_sender(&self, name: &'static str) -> Option<SyncSender<IP>> {
        match self.input_simple_senders.get(name) {
            None => { None },
            Some(s) => {
                Some(s.clone())
            }
        }
    }

    pub fn get_array_sender(&self, name: &'static str, selection: &'static str) -> Option<SyncSender<IP>> {
        let port = self.input_array_senders.get(name).unwrap();
        match port.get(selection) {
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
                self.in_receivers.as_mut().unwrap().simple.insert(name, rec);
            },
            CompMsg::AddInputArrayPort(name) => {
                self.in_receivers.as_mut().unwrap().array.insert(name, HashMap::new());
            }
            CompMsg::AddInputArraySelection(name, selection, rec) => {
                let mut port = self.in_receivers.as_mut().unwrap().array.get_mut(name).unwrap();
                port.insert(selection, rec);
            }
            CompMsg::AddOutputPort(name) => {
                self.out_senders.as_mut().unwrap().simple.insert_empty(name);
            },
            CompMsg::AddOutputArrayPort(name) => {
                self.out_senders.as_mut().unwrap().array.insert(name, HashMap::new());
            },
            CompMsg::AddOutputArraySelection(name, selection) => {
                let mut port = self.out_senders.as_mut().unwrap().array.get_mut(name).expect("Unable to found the array port");
                port.insert_empty(selection);
            },
            CompMsg::ConnectOutputPort(name, send) => {
                let port = self.out_senders.as_mut().unwrap().simple.get_mut(name).unwrap();
                port.connect(send);
            },
            CompMsg::ConnectOutputArrayPort(name, selection, send) => {
                let mut port = self.out_senders.as_mut().unwrap().array.get_mut(name).unwrap();
                let mut selection = port.get_mut(selection).unwrap();
                selection.connect(send);
            }
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
