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
                        CompMsg::AddInputPort(name, rec) => { state.add_input_port(name, rec); },
                        CompMsg::AddOutputPort(name) => { state.add_output_port(name); },
                        CompMsg::ConnectOutputPort(port, send) => { state.connect_output_port(port, send); },
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
}

impl State {
    fn new(c: BoxedClosure, cs: Sender<CompMsg>) -> Self {
        State {
            control_sender: cs,
            closure: Some(c),
            in_receivers: Some(InputPorts::new()),
            out_senders: Some(OutputPorts::new()),
        }
    }

    fn add_input_port(&mut self, name: &'static str, rec: Receiver<i32>) {
        if let Some(ref mut inputs) = self.in_receivers {
            inputs.add(name, rec);
        }
    }

    fn add_output_port(&mut self, name: &'static str) {
        if let Some(ref mut outputs) = self.out_senders {
            outputs.add(name);
        }
    }

    fn connect_output_port(&mut self, port: &'static str, send: SyncSender<i32>) {
        if let Some(ref mut out_s) = self.out_senders {
            out_s.connect(port, send);
        }
    }

    fn start(&mut self) { self.run(); }

    fn stop(&mut self) { }

    fn run_end(&mut self, c: BoxedClosure, i: InputPorts, o: OutputPorts) {
        self.closure = Some(c);
        self.in_receivers = Some(i);
        self.out_senders = Some(o);
        self.run();
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
