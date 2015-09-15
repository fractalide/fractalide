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

use std::collections::HashMap;

use std::sync::mpsc::{SyncSender, Sender, Receiver, SendError, RecvError};
use std::sync::mpsc::sync_channel;
use std::sync::mpsc::channel;

use std::thread;
use std::mem;

/*
 * Input Ports for the state, only the receivers
 */

pub enum InputPortError {
    InputPortNotFind(&'static str),
    CannotRecv(RecvError),
}

pub struct InputPorts {
    input: HashMap<&'static str, Receiver<i32>>,
}

impl InputPorts {

    fn new() -> Self {
        InputPorts { input: HashMap::new(), }
    }

    fn add(&mut self, name: &'static str, rec: Receiver<i32>) -> Option<Receiver<i32>> {
        self.input.insert(name, rec) 
    }

    fn remove(&mut self, name: &'static str) -> Option<Receiver<i32>> {
        self.input.remove(&name)
    }

    pub fn recv(&self, name: &'static str) -> Result<i32, InputPortError> {
        let port = self.input.get(name);
        match port {
            None => { Err(InputPortError::InputPortNotFind(name)) }
            Some(port) => {
                match port.recv() {
                    Ok(msg) => { Ok(msg) },
                    Err(err) => { Err(InputPortError::CannotRecv(err)) },
                }
            }
        }
    }

}

#[test]
fn input_ports_tests() {
   let mut input = InputPorts::new();
   let (tx, rx) = sync_channel(16);
   input.add("input", rx);
   tx.send(42).unwrap();
   let result = input.recv("input").ok().expect("There is no message in the channel");
   assert_eq!(result, 42);
   let recv = input.remove("input");
   assert!(recv.is_some());
   let recv = input.remove("input");
   assert!(recv.is_none());
   let result = input.recv("input");
   assert!(result.is_err());
}

/*
 * Output Ports for the state
 */

pub enum OutputPortError {
    OutputPortNotFind(&'static str),
    CannotSend(SendError<i32>),
}

pub struct OutputPorts {
    output: HashMap<&'static str, Option<SyncSender<i32>>>,
}

impl OutputPorts {
    fn new() -> Self {
        OutputPorts { output: HashMap::new(), }
    }

    fn add(&mut self, name: &'static str) -> Option<Option<SyncSender<i32>>>{
        self.output.insert(name, None)
    }

    fn remove(&mut self, name: &'static str) -> Option<Option<SyncSender<i32>>> {
        self.output.remove(name)
    }

    fn connect(&mut self, name: &'static str, send: SyncSender<i32>) -> Result<(), OutputPortError> {
        if !self.output.contains_key(name) {
            Err(OutputPortError::OutputPortNotFind(name))
        } else {
            self.output.insert(name, Some(send));
            Ok(())
        }
    }

    pub fn send(&self, name: &'static str, msg: i32) -> Result<(), OutputPortError> {
        let sender = self.output.get(name);
        match sender {
            None => { Err(OutputPortError::OutputPortNotFind(name)) },
            Some(port) => {
                match *port {
                    None => { Ok(()) },
                    Some(ref send) => {
                        let res = send.send(msg);
                        if res.is_ok() { Ok(()) }
                        else { Err(OutputPortError::CannotSend(res.unwrap_err())) }
                    }
                }
            }
        }
    }

}


#[test]
fn output_ports_tests() {
   let mut output = OutputPorts::new();
   let (tx, rx) = sync_channel(16);
   let res = output.send("output", 42);
   assert!(res.is_err());
   let res = output.connect("output", tx.clone());
   assert!(res.is_err());
   output.add("output");
   let res = output.remove("output");
   assert!(res.is_some());
   let res = output.remove("output");
   assert!(res.is_none());

   output.add("output");
   output.connect("output", tx);
   output.send("output", 42);
   let res = rx.recv().unwrap();
   assert_eq!(res, 42);
}

#[test]
fn input_output_ports_tests() {
    let mut input = InputPorts::new();
    let mut output = OutputPorts::new();
    let (tx, rx) = sync_channel(16);
    input.add("input", rx);
    output.add("output");
    output.connect("output", tx);
    output.send("output", 42);
    assert_eq!(input.recv("input").ok().expect(""), 42);
}


/*
 * Component Structure
 * Divided in two : component and state. 
 * The component is the user interface for the component.
 * The state is the running part of the component, in a Thread.
 * The two use a channel to interact.
 */

pub trait Closure {
    fn run(&mut self, input_ports: &InputPorts, output_ports: &OutputPorts);
}

pub type BoxedClosure = Box<Closure + Send>;

enum CompMsg {
    Start, Stop, Halt,
    RunEnd(BoxedClosure, InputPorts, OutputPorts),
    ConnectOutputPort(&'static str, SyncSender<i32>),
    AddInputPort(&'static str, Receiver<i32>),
    AddOutputPort(&'static str),
}

enum CompError {
    PortNotFound(&'static str),
}

pub struct Component {
    sender: Sender<CompMsg>,
    input_senders: HashMap<&'static str, SyncSender<i32>>,
}

impl Component {
    pub fn new<T: Closure + Send + 'static>(c: Box<T>) -> Self {
        let (control_s, control_r) = channel();
        {
            let control_sender = control_s.clone();
            let mut state = State::new(c, control_sender);
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
        Component {
            sender: control_s,
            input_senders: HashMap::new(),
        }
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

    pub fn get_sender(&self, name: &'static str) -> Option<SyncSender<i32>> {
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
                self.in_receivers.as_mut().unwrap().add(name, rec);
            },
            CompMsg::AddOutputPort(name) => {
                self.out_senders.as_mut().unwrap().add(name);
            },
            CompMsg::ConnectOutputPort(name, send) => {
                self.out_senders.as_mut().unwrap().connect(name, send);
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
    assert!(state.out_senders.as_mut().unwrap().output.len() == 1);

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
    assert!(state.out_senders.as_mut().unwrap().output.len() == 1);

    // receive useless msgs
    rx.recv();
    rx.recv();

}
