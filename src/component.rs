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
use std::sync::mpsc::{SyncSender, Sender, SendError};
use std::sync::mpsc::channel;

use std::any::Any;
use std::marker::Reflect;
use std::raw::TraitObject;
use std::mem;
use std::thread;

pub trait InputSenders {
    fn get_sender(&self, port: &'static str) -> Option<Box<Any + Send + 'static>>; 
}

pub trait InputArraySenders {
    fn get_selection_sender(&self, port: &'static str, selection: &'static str) -> Option<Box<Any + Send + 'static>>;
    fn add_selection_sender(&mut self, port: &'static str, selection: &'static str, sender: Box<Any>);
    fn get_sender_receiver(&self, port: &'static str) -> Option<(Box<Any + Send + 'static>, Box<Any + Send + 'static>)>;
}

pub trait InputArrayReceivers {
    fn add_selection_receiver(&mut self, port: &'static str, selection: &'static str, rec: Box<Any>);
}

pub trait Component: ComponentRun + ComponentConnect {}
impl<T> Component for T where T: ComponentRun + ComponentConnect {}

pub trait ComponentRun: Send{
    fn run(&self);
}

pub trait ComponentConnect: Send {
    fn connect(&mut self, port_out: &'static str, send: Box<Any>);
    fn add_selection_receiver(&mut self, port: &'static str, selection: &'static str, rec: Box<Any>);
    fn add_output_selection(&mut self, port: &'static str, selection: &'static str);
    fn connect_array(&mut self, port: &'static str, selection: &'static str, send: Box<Any>);
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

pub trait IP: Send + Reflect + 'static {}
impl<T> IP for T where T: Send + Reflect + 'static {}


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
    AddInputArraySelection(&'static str, &'static str, Box<Any + Send + 'static>),
    AddOutputArraySelection(&'static str, &'static str),
    ConnectOutputPort(&'static str, Box<Any + Send + 'static>),
    ConnectOutputArrayPort(&'static str, &'static str, Box<Any + Send + 'static>),
}

pub struct CompRunner {
    sender: Sender<CompMsg>,
    input_senders: Box<InputSenders>,
    input_array_senders: Box<InputArraySenders>,
}
impl CompRunner {
    pub fn new(c: (BoxedComp, Box<InputSenders>, Box<InputArraySenders>)) -> Self {
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
                    CompMsg::ConnectOutputArrayPort(port, selection, send) => { state.receive_edit_msg(CompMsg::ConnectOutputArrayPort(port, selection, send)); },
                    CompMsg::AddInputArraySelection(port, selection, rec) => { state.receive_edit_msg(CompMsg::AddInputArraySelection(port, selection, rec)); },
                    CompMsg::AddOutputArraySelection(port, selection) => { state.receive_edit_msg(CompMsg::AddOutputArraySelection(port, selection)); },
                }
            }
        });
        CompRunner{
            sender: s,
            input_senders: c.1,
            input_array_senders: c.2,
        }
    }

    pub fn connect(&self, port_out: &'static str, comp: &CompRunner, port_in: &'static str){
        let s = comp.get_sender(port_in).unwrap();
        self.sender.send(CompMsg::ConnectOutputPort(port_out, s)).ok().expect("unable to send to the state");
    }

    pub fn connect_array(&self, port_out: &'static str, selection_out: &'static str, comp: &CompRunner, port_in: &'static str){
        let s = comp.get_sender(port_in).expect("CompRunner -> connect_array -> don't find the sender");
        self.sender.send(CompMsg::ConnectOutputArrayPort(port_out, selection_out, s)).ok().expect("unable to send to the state");
    }

    pub fn connect_to_array(&self, port_out: &'static str, comp: &CompRunner, port_in: &'static str, selection_in: &'static str){
        let s = comp.get_array_sender(port_in, selection_in).expect("CompRunner -> connect_to_array -> don't find the sender");
        self.sender.send(CompMsg::ConnectOutputPort(port_out, s)).ok().expect("unable to send to the state");
    }

    pub fn connect_array_to_array(&self, port_out: &'static str, selection_out: &'static str, comp: &CompRunner, port_in: &'static str, selection_in: &'static str){
        let s = comp.get_array_sender(port_in, selection_in).expect("CompRunner -> connect_array_to_array -> don't find the sender");
        self.sender.send(CompMsg::ConnectOutputArrayPort(port_out, selection_out, s)).ok().expect("unable to send to the state");
    }
    
    
    pub fn get_sender(&self, port_in: &'static str) -> Option<Box<Any + Send + 'static>> {
        self.input_senders.get_sender(port_in)
    }

    pub fn get_array_sender(&self, port: &'static str, selection: &'static str) -> Option<Box<Any + Send + 'static>> {
        self.input_array_senders.get_selection_sender(port, selection)
    }

    pub fn add_input_array_selection(&mut self, port: &'static str, selection: &'static str) {
        let (s, r) = self.input_array_senders.get_sender_receiver(port).unwrap();
        self.input_array_senders.add_selection_sender(port, selection, s);
        self.sender.send(CompMsg::AddInputArraySelection(port, selection, r)).ok().expect("unable to send to the state");
    }

    pub fn add_output_array_selection(&self, port: &'static str, selection: &'static str) {
        self.sender.send(CompMsg::AddOutputArraySelection(port, selection)).ok().expect("unable to send to the state");
    }

    pub fn start(&self) {
        self.sender.send(CompMsg::Start).ok().expect("unable to send to the state");
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
        let c = mem::replace(&mut self.comp, None).unwrap();
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
            },
            CompMsg::ConnectOutputArrayPort(port_out, selection, send) => {
                if let Some(ref mut c) = self.comp {
                    c.connect_array(port_out, selection, send);
                }
            },
            CompMsg::AddInputArraySelection(port, selection, rec) => {
                if let Some(ref mut c) = self.comp {
                    c.add_selection_receiver(port, selection, rec);
                }
            }
            CompMsg::AddOutputArraySelection(port, selection) => {
                if let Some(ref mut c) = self.comp {
                    c.add_output_selection(port, selection);
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
        inputs_array($ia_name: ident $ia_name2:ident $( ( $($ia_t:ident$(: $ia_tr:ident)* ),* ) )* => ($($input_array_name:ident: $input_array_type:ty),* )),
        outputs($o_name:ident $( ( $($o_t:ident$(: $o_tr:ident)* ),* ) )* => ($($output_field_name:ident: $output_field_type:ty ),* )),
        outputs_array($oa_name:ident $( ( $($oa_t:ident$(: $oa_tr:ident)* ),* ) )* => ($($output_array_name:ident: $output_array_type:ty ),* )),
        fn run(&$arg:ident) $fun:block
    ) 
        =>
    {
        /* Input ports part */

        // simple
        #[allow(dead_code)]
        struct $i_name<$( $( $i_t ),* )*> {
            $(
                $input_field_name: SyncSender<$input_field_type>
            ),*
        }

        #[allow(dead_code)]
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

        // array
        #[allow(dead_code)]
        struct $ia_name<$( $( $ia_t ),* )*> {
            $(
                $input_array_name: HashMap<&'static str, SyncSender<$input_array_type>>
            ),*    
        }
        #[allow(dead_code)]
        struct $ia_name2<$( $( $ia_t ),* )*> {
            $(
                $input_array_name: HashMap<&'static str, Receiver<$input_array_type>>
            ),*    
        }

        impl<$( $( $ia_t: $($ia_tr)* ),* )*> InputArraySenders for $ia_name<$( $( $ia_t),* )*>{
            fn get_selection_sender(&self, port: &'static str, _selection: &'static str) -> Option<Box<Any + Send + 'static>> {
                match port {
                    $(
                        stringify!($input_array_name) => { 
                            let p = self.$input_array_name.get(_selection).expect("get_selection_sender : the port doesn't exist");
                            Some(Box::new(p.clone())) 
                        }
                    ),*
                    _ => { None },
                }    
            }

            fn add_selection_sender(&mut self, port: &'static str, _selection: &'static str, _sender: Box<Any>){
                match port {
                    $(
                        stringify!($input_array_name) => { 
                             self.$input_array_name.insert(_selection, component::downcast(_sender));

                        }
                    ),*
                    _ => { println!("add_selection_sender : Add Nothing!"); },
                }    
            }

            fn get_sender_receiver(&self, port: &'static str) -> Option<(Box<Any + Send + 'static>, Box<Any + Send + 'static>)>{
                match port {
                    $(
                        stringify!($input_array_name) => { 
                            let (s, r) : (SyncSender<$input_array_type>, Receiver<$input_array_type>)= sync_channel(16);
                            Some((Box::new(s), Box::new(r)))
                        }
                    ),*
                    _ => { None },
                }    
            }
        }

        impl<$( $( $ia_t: $($ia_tr)* ),* )*> InputArrayReceivers for $ia_name2<$( $( $ia_t),* )*>{
            fn add_selection_receiver(&mut self, port: &'static str, _selection: &'static str, _receiver: Box<Any>){
                match port {
                    $(
                        stringify!($input_array_name) => { 
                            self.$input_array_name.insert(_selection, component::downcast(_receiver));
                        }
                    ),*
                    _ => { println!("add_selection_receivers : Add Nothing!"); },
                }    
            }
        }


        /* Output ports part */

        // simple
        #[allow(dead_code)]
        struct $o_name<$( $( $o_t ),* )*> {
            $(
                $output_field_name: OutputSender<$output_field_type>
            ),*
        }

        // array
        #[allow(dead_code)]
        struct $oa_name<$( $( $oa_t ),* )*> {
            $(
                $output_array_name: HashMap<&'static str, OutputSender<$output_array_type>>
            ),*
        }

        // simple and array
        impl<$( $( $c_t: $($c_tr)* ),* )*> ComponentConnect for $name<$( $( $c_t ),* ),* >{
            fn connect(&mut self, port: &'static str, _send: Box<Any>) {
                match port {
                    $(
                        stringify!($output_field_name) => { self.outputs.$output_field_name.connect(component::downcast(_send)); }
                    ),*
                    _ => {},
                }    
            }

            fn add_selection_receiver(&mut self, port: &'static str, selection: &'static str, rec: Box<Any>) {
                self.inputs_array.add_selection_receiver(port, selection, rec);
            }

            fn add_output_selection(&mut self, port: &'static str, _selection: &'static str){
                match port {
                    $(
                        stringify!($output_array_name) => { self.outputs_array.$output_array_name.insert(_selection, OutputSender::new()); }
                    ),*
                    _ => {},
                }    

            }

            fn connect_array(&mut self, port: &'static str, _selection: &'static str, _send: Box<Any>){
                match port {
                    $(
                        stringify!($output_array_name) => { 
                            let mut s = self.outputs_array.$output_array_name.get_mut(_selection).expect("connect_array : selection not found");
                            s.connect(component::downcast(_send)); 
                        }
                    ),*
                    _ => {},
                }    
            }
        }

        /* Global component */

        #[allow(dead_code)]
        struct $name<$( $( $c_t ),* )*> {
            inputs: $i_name2<$( $( $i_t ),* )*>,
            inputs_array:$ia_name2<$( $( $ia_t ),* )*>,
            outputs: $o_name<$( $( $o_t ),* )*>,
            outputs_array: $oa_name<$( $( $oa_t ),* )*>,
        }

        impl<$( $( $c_t: $($c_tr)* ),* )*> $name<$( $( $c_t ),* ),*>{
            fn new() -> (Box<Component + Send>, Box<InputSenders>, Box<InputArraySenders>) {
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

                // Creation of the array inputs
                let a_s = $ia_name {
                $(
                    $input_array_name: HashMap::<&'static str, SyncSender<$input_array_type>>::new(),
                ),*
                };
                let a_r = $ia_name2 {
                $(
                    $input_array_name: HashMap::<&'static str, Receiver<$input_array_type>>::new(),
                ),*
                };

                // Creation of the output
                let out = $o_name {
                    $(
                        $output_field_name: OutputSender::new(),
                    ),*    
                };

                // Creation of the array output
                let out_array = $oa_name {
                    $(
                        $output_array_name: HashMap::<&'static str, OutputSender<$output_array_type>>::new(),
                    ),*
                };

                // Put it together
                let comp = $name{
                    inputs: r, outputs: out, inputs_array: a_r, outputs_array: out_array
                };
                (Box::new(comp), Box::new(s), Box::new(a_s))
            }
        }

        impl<$( $( $c_t: $($c_tr)* ),* )*> ComponentRun for $name<$( $( $c_t ),* ),* >{
            fn run(&$arg) $fun
        }    
    }
}
