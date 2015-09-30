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
use std::sync::mpsc::{SyncSender, Sender, Receiver, SendError};
use std::sync::mpsc::sync_channel;
use std::sync::mpsc::channel;

use std::any::Any;
use std::marker::Reflect;
use std::raw::TraitObject;
use std::mem;
use std::thread;

pub trait Component: Send{
    fn run(&self);
    fn get_sender(&self, port: &'static str) -> Option<Box<Any + Send + 'static>>; 
    fn connect(&mut self, port_out: &'static str, send: Box<Any>);
}

pub fn downcast<I: Reflect + 'static>(i: Box<Any>) -> I {
    unsafe {
        let obj: Box<Any> = i;
        if !(*obj).is::<I>(){
            panic!("Type mismatch");
        }
        let raw: TraitObject = mem::transmute(Box::into_raw(obj));
        *Box::from_raw(raw.data as *mut I)
    }
}

pub trait IP: Send + 'static {}
impl<T> IP for T where T: Send + 'static {}


pub struct OutputSender<T> {
    send: Option<SyncSender<T>>,
}
pub enum OutputPortError<T> {
    NotConnected,
    CannotSend(SendError<T>),
}

impl<T> OutputSender<T> {
    pub fn new() -> Self {
        OutputSender { send: None, }
    }

    pub fn connect(&mut self, send: SyncSender<T>){
        self.send = Some(send);
    }

    pub fn send(&self, msg: T) -> Result<(), OutputPortError<T>> {
        if self.send.is_none() {
            Err(OutputPortError::NotConnected)
        } else {
            let send = self.send.as_ref().unwrap();
            let res = send.send(msg);
            if res.is_ok() { Ok(()) }
            else { Err(OutputPortError::CannotSend(res.unwrap_err())) }
        }
    }
}
impl<T> Reflect for OutputSender<T> where T: Reflect {}

pub type BoxedComp = Box<Component + Send + 'static>;

enum CompMsg {
    Start, Stop, Halt,
    RunEnd(BoxedComp),
    GetSender(&'static str, Sender<CompMsg>, &'static str),
    ConnectOutputPort(&'static str, Box<Any + Send + 'static>),
}

pub struct CompRunner {
    sender: Sender<CompMsg>,
}
impl CompRunner {
    pub fn new(c: BoxedComp) -> Self {
        let (s,r) = channel();
        let mut state = State::new(c, s.clone());
        thread::spawn(move || {
            loop {
                let msg = r.recv().unwrap();
                match msg {
                    CompMsg::Start => { state.start(); },
                    CompMsg::Stop => { state.stop(); },
                    CompMsg::Halt => { break; },
                    CompMsg::RunEnd(comp) => { state.run_end(comp); },
                    CompMsg::GetSender(port, sender, port_in) => { state.get_sender(port, sender, port_in); },
                    CompMsg::ConnectOutputPort(port_out, send) => { state.receive_edit_msg(CompMsg::ConnectOutputPort(port_out, send)); },
                }
            }
        });
        CompRunner{
            sender: s,
        }
    }

    fn get_sender(&self, port_out: &'static str, send: Sender<CompMsg>, port_in: &'static str){
        self.sender.send(CompMsg::GetSender(port_out, send, port_in));
    }

    pub fn connect(&self, port_out: &'static str, comp: &CompRunner, port_in: &'static str){
        comp.get_sender(port_out, self.sender.clone(), port_in);
    }

    pub fn start(&self) {
        self.sender.send(CompMsg::Start).unwrap();
    }

}

struct State {
    runner_s: Sender<CompMsg>,
    comp: Option<BoxedComp>,
    can_run: bool,
    edit_msgs: Vec<CompMsg>,
}

impl State {
    fn new(c: BoxedComp, rs: Sender<CompMsg>) -> Self {
        State {
            runner_s: rs,
            comp: Some(c),
            can_run: false,
            edit_msgs: vec![],
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
    
    fn run(&mut self) {
        let mut c= mem::replace(&mut self.comp, None).unwrap();
        let rs = self.runner_s.clone();
        thread::spawn(move || {
            c.run();
            rs.send(CompMsg::RunEnd(c)).unwrap();
        });
    }

    fn run_end(&mut self, c: BoxedComp) {
        self.comp = Some(c);
        let msgs = mem::replace(&mut self.edit_msgs, vec![]);
        for msg in msgs {
            self.edit_component(msg);
        }
        if self.can_run {
            self.run();
        }
    }

    fn receive_edit_msg(&mut self, msg: CompMsg){
        if self.can_run {
            self.edit_msgs.push(msg);
        } else {
            self.edit_component(msg);
        }
    }

    fn edit_component(&mut self, msg: CompMsg){
        match msg{
            CompMsg::ConnectOutputPort(port_out, send) => {
                if let Some(ref mut c) = self.comp {
                    c.connect(port_out, send);
                }
            }
            _ => { panic!("Wrong edit message"); }
        }
    }

    fn get_sender(&self, port_out: &'static str, sender: Sender<CompMsg>, port_in: &'static str){
        if let Some(ref c) = self.comp {
            let s = c.get_sender(port_in).unwrap();
            sender.send(CompMsg::ConnectOutputPort(port_out, s)).unwrap();
        }
    }
}


