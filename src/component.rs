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

pub trait InputSenders {
    fn get_sender(&self, port: &'static str) -> Option<Box<Any + Send + 'static>>; 
}

pub trait Component: ComponentRun + ComponentConnect {}
impl<T> Component for T where T: ComponentRun + ComponentConnect {}

pub trait ComponentRun: Send{
    fn run(&self);
}

pub trait ComponentConnect: Send {
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
    ConnectOutputPort(&'static str, Box<Any + Send + 'static>),
}

pub struct CompRunner {
    sender: Sender<CompMsg>,
    input_senders: Box<InputSenders>,
}
impl CompRunner {
    pub fn new(c: (BoxedComp, Box<InputSenders>)) -> Self {
        let (s,r) = channel();
        let mut state = State::new(c.0, s.clone());
        thread::spawn(move || {
            loop {
                let msg = r.recv().unwrap();
                match msg {
                    CompMsg::Start => { state.start(); },
                    CompMsg::Stop => { state.stop(); },
                    CompMsg::Halt => { break; },
                    CompMsg::RunEnd(comp) => { state.run_end(comp); },
                    CompMsg::ConnectOutputPort(port_out, send) => { state.receive_edit_msg(CompMsg::ConnectOutputPort(port_out, send)); },
                }
            }
        });
        CompRunner{
            sender: s,
            input_senders: c.1,
        }
    }

    pub fn connect(&self, port_out: &'static str, comp: &CompRunner, port_in: &'static str){
        let s = comp.get_sender(port_in).unwrap();
        self.sender.send(CompMsg::ConnectOutputPort(port_out, s));
    }
    
    
    pub fn get_sender(&self, port_in: &'static str) -> Option<Box<Any + Send + 'static>> {
        self.input_senders.get_sender(port_in)
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

}


#[macro_export]
macro_rules! component {
    (
        $name:ident, $( ( $($c_t:ident$(: $c_tr:ident)* ),* ),)*
        inputs($i_name:ident $i_name2:ident $( ( $($i_t:ident$(: $i_tr:ident)* ),* ) )* => ($($input_field_name:ident: $input_field_type:ty ),* )),
        outputs($o_name:ident $( ( $($o_t:ident$(: $o_tr:ident)* ),* ) )* => ($($output_field_name:ident: $output_field_type:ty ),* )),
        fn run(&$arg:ident) $fun:block
    ) 
        =>
    {
        /* Input ports part */
        struct $i_name<$( $( $i_t ),* )*> {
            $(
                $input_field_name: SyncSender<$input_field_type>
            ),*
        }

        struct $i_name2<$( $( $i_t ),* )*> {
            $(
                $input_field_name: Receiver<$input_field_type>
            ),*
        }

        impl<$( $( $i_t: $($i_tr)* ),* )*> InputSenders for $i_name<$( $( $i_t),* )*>{
            fn get_sender(&self, port: &'static str) -> Option<Box<Any + Send + 'static>> {
                match port {
                    $(
                        stringify!($input_field_name) => { Some(Box::new(self.$input_field_name.clone())) }
                    ),*
                    _ => { None },
                }    
            }

        }

        /* Output ports part */
        struct $o_name<$( $( $o_t ),* )*> {
            $(
                $output_field_name: OutputSender<$output_field_type>
            ),*
        }

        impl<$( $( $c_t: $($c_tr)* ),* )*> ComponentConnect for $name<$( $( $c_t ),* ),* >{
            fn connect(&mut self, port: &'static str, send: Box<Any>) {
                match port {
                    $(
                        stringify!($output_field_name) => { self.outputs.$output_field_name.connect(component::downcast(send)); }
                    ),*
                    _ => {},
                }    
            }
        }

        /* Global component */

        struct $name<$( $( $c_t ),* )*> {
            inputs: $i_name2<$( $( $i_t ),* )*>,
            outputs: $o_name<$( $( $o_t ),* )*>,
        }

        impl<$( $( $c_t: $($c_tr)* ),* )*> $name<$( $( $c_t ),* ),*>{
            fn new() -> (Box<Component + Send>, Box<InputSenders>) {
                // Creation of the inputs
                $(
                    let $input_field_name = sync_channel::<$input_field_type>(16);
                )*
                let s = $i_name {
                $(
                    $input_field_name: $input_field_name.0
                ),*    
                };
                let r = $i_name2 {
                $(
                    $input_field_name: $input_field_name.1
                ),*    
                };

                // Creation of the output
                let out = $o_name {
                    $(
                        $output_field_name: OutputSender::new()
                    ),*    
                };

                // Put it together
                let comp = $name{
                    inputs: r, outputs: out
                };
                (Box::new(comp), Box::new(s))
            }
        }

        impl<$( $( $c_t: $($c_tr)* ),* )*> ComponentRun for $name<$( $( $c_t ),* ),* >{
            fn run(&$arg) $fun
        }    
    }
}
