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
use std::sync::mpsc::channel;

use std::any::Any;
use std::marker::Reflect;
use std::raw::TraitObject;
use std::mem;
use std::thread;

/* 
 *
 * There are two main parts for a component : the component itself and the part that manage the
 * connections and the running part. 
 *
 * Each component must implement some trait (InputSenders, InputArraySenders, InputArrayReceivers,
 * ComponentRun and ComponentConnect). These traits give all the information for the connection
 * between several components.
 *
 * The CompRunner, that manages the connection and the run of the component only interact with the
 * Trait of the component.
 *
 */
 
/// Manage the simple input ports of a component.
///
/// The trait had one method that allows to get the syncsender of the port "port"
///
pub trait InputSenders {
    /// Get the SyncSender of the port "port".
    /// If the port exists, this method return a SyncSender casted as a Box<Any>.
    ///
    /// # Example
    ///
    /// ```
    /// let sync_sender_boxed = inputs.get_sender("input").unwrap();
    /// let sync_sender: SyncSender<i32> = downcast(sync_sender_boxed);
    /// ```
    fn get_sender(&self, port: &'static str) -> Option<Box<Any + Send + 'static>>; 
}

/// Manage the array input ports of a component.
///
/// The trait, with the InputArrayReceivers,  allows to add and retrieve and create an array input port. 
/// # Example
///
///
/// ```
/// let (s, r) = inputs_array.get_sender_receiver("numbers").unwrap();
/// inputs_array.add_selection_sender("numbers", "1", s);
/// inputs_array.add_selection_receiver("numbers", "1", r);
///
/// let sync_sender_boxed = inputs.get_sender("input").unwrap();
/// let sync_sender: SyncSender<i32> = downcast(sync_sender_boxed);
/// ```
pub trait InputArraySenders {
    /// Get the SyncSender of the selection "selection" of the port "port".
    /// If the selection port exists, this method return a SyncSender casted as a Box<Any>.
    ///
    /// # Example
    ///
    /// ```
    /// let sync_sender_boxed = inputs_array.get_selectionsender("numbers", "1").unwrap();
    /// let sync_sender: SyncSender<i32> = downcast(sync_sender_boxed);
    /// ```
    fn get_selection_sender(&self, port: &'static str, selection: &'static str) -> Option<Box<Any + Send + 'static>>;

    /// Allow to add a SyncSender in an array input port.
    ///
    /// # Example
    ///
    /// ```
    /// let (s, _) = sync_channel(16);
    /// inputs_array.add_selection_sender("numbers", "1", s);
    /// ```
    fn add_selection_sender(&mut self, port: &'static str, selection: &'static str, sender: Box<Any>);
    /// This method create a SyncSender and a Receiver for the array input port "port".
    /// It returns a tuple (SyncSender, Receiver) both casted at Box<Any>
    ///
    /// # Example
    ///
    /// ```
    /// let (s, r) = inputs_array.get_sender_receiver("numbers").unwrap();
    /// let s: SyncSender<i32> = downcast(s);
    /// let r: Recever<i32> = downcast(r);
    /// ```
    fn get_sender_receiver(&self, port: &'static str) -> Option<(Box<Any + Send + 'static>, Box<Any + Send + 'static>)>;
}

/// Manage the array input ports of a component.
///
/// The trait, with the InputArraySenders,  allows to add and retrieve and create an array input port. 
/// # Example
///
///
/// ```
/// let (s, r) = inputs_array.get_sender_receiver("numbers").unwrap();
/// inputs_array.add_selection_sender("numbers", "1", s);
/// inputs_array.add_selection_receiver("numbers", "1", r);
///
/// let sync_sender_boxed = inputs.get_sender("input").unwrap();
/// let sync_sender: SyncSender<i32> = downcast(sync_sender_boxed);
/// ```
pub trait InputArrayReceivers {
    /// Allow to add a Receiver in an array input port.
    ///
    /// # Example
    ///
    /// ```
    /// let (_, r) = sync_channel(16);
    /// inputs_array.add_selection_receiver("numbers", "1", r);
    /// ```
    fn add_selection_receiver(&mut self, port: &'static str, selection: &'static str, rec: Box<Any>);
}

/// Allows to manage a component from outside
pub trait Component: ComponentRun + ComponentConnect {}
impl<T> Component for T where T: ComponentRun + ComponentConnect {}

/// Allows to run a component once
pub trait ComponentRun: Send{
    /// Runs the component once. It read and write on the input and output ports.
    fn run(&mut self);
}

/// Allows to manage the simple and array output port
pub trait ComponentConnect: Send {
    /// Connects the output port "port" with a specific SyncSender
    /// # Example
    ///
    /// ```
    /// component.connect("output", a_sync_sender);
    /// ```
    fn connect(&mut self, port_out: &'static str, send: Box<Any>);
    /// Create a selection "selection" for the array output port "port"
    /// # Example
    ///
    /// ```
    /// component.add_output_selection("output", "1");
    /// ```
    fn add_output_selection(&mut self, port: &'static str, selection: &'static str);
    /// Connects the selection "selection" of the array output port "port" with a specific SyncSender
    /// # Example
    ///
    /// ```
    /// component.connect_array("output", "1", a_sync_sender);
    /// ```
    fn connect_array(&mut self, port: &'static str, selection: &'static str, send: Box<Any>);
    /// Add a Receiver for the selection "selection" of the array input port "port"
    /// # Example
    ///
    /// ```
    /// component.add_selection_receiver("numbers", "1", a_receiver);
    /// ```
    fn add_selection_receiver(&mut self, port: &'static str, selection: &'static str, rec: Box<Any>);
}

/// Define the minimal traits that an IP must have
pub trait IP: Send + Reflect + 'static {}
impl<T> IP for T where T: Send + Reflect + 'static {}

/// Downcast a Box<Any> to a type I. It returns the ownership of the variable, not a borrow.
///
/// # Example 
///
/// ```
/// let a: i32 = 32;
/// let b = Box::new(a) as Box<Any>;
/// let c: i32 = downcast(b);
/// ```
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

/// Error for the OutputSender.
///
/// It says if the output port is not connected, or a classical SendError message.
pub enum OutputPortError<T> {
    NotConnected,
    CannotSend(SendError<T>),
}

/// Represent a output port.
///
/// It allows to connect the port and send an IP through it.
///
/// # Example
///
/// ```
/// let (s, r) = sync_channel(16);
/// let os = OutputSender::<i32>::new();
/// os.connect(s);
/// os.send(23);
/// assert_eq!(r.recv().unwrap(), 23);
/// ```
pub struct OutputSender<T> {
    send: Option<SyncSender<T>>,
}
impl<T> OutputSender<T> {
    /// Create a new unconnected OutputSender structure.
    pub fn new() -> Self {
        OutputSender { send: None, }
    }

    /// Connect the OutputSener structure with the given SyncSender
    pub fn connect(&mut self, send: SyncSender<T>){
        self.send = Some(send);
    }

    /// Send a message to the OutputPort. If the port is unconnected, it return a
    /// OutputPortError::NotConnected. If there is an error while the transfer, it return the
    /// corresponding SendError message.
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

/// Represent the default options simple input port
///
/// It is different from a classical Receiver because it :
///
/// * Remember the last message received
/// 
/// * If there is more than one message inside the channel, it keeps only the last one.
///
/// * If there is no message in the channel, it sends the last one. If it is the first message, it
/// block until there is a message
///
/// # Example
///
/// ```
/// let (s, r) = sync_channel(16);
/// let or = OptionReceiver::new(r);
/// s.send(23).unwrap();
/// assert_eq!(or.recv().unwrap(), 23);
/// assert_eq!(or.recv().unwrap(), 23);
/// s.send(42).unwrap();
/// s.send(666).unwrap();
/// assert_eq!(or.recv().unwrap(), 666);
/// ```
pub struct OptionReceiver<T> {
    opt: Option<T>,
    receiver: Receiver<T>,
}
impl<T: Clone> OptionReceiver<T> {
    /// Return a new OptionReceiver for the Receiver "r"
    pub fn new(r: Receiver<T>) -> Self {
        OptionReceiver{ 
            opt: None,
            receiver: r,
        }
    }

    fn recv_last(&mut self, acc: Option<T>) -> T {
        let msg = self.receiver.try_recv();
        match msg {
            Ok(msg) => {
                self.recv_last(Some(msg))
            },
            _ => {
                if acc.is_some() { acc.unwrap() }
                else { self.receiver.recv().unwrap() }
            }
        }
    }

    /// Return a message.
    pub fn recv(&mut self) -> T {
        let actual = mem::replace(&mut self.opt, None);
        let opt = self.recv_last(actual); 
        self.opt = Some(opt.clone());
        opt
    }
}

/// Represent a component in a Box 
pub type BoxedComp = Box<Component + Send + 'static>;

enum CompMsg {
    Start, Stop, Halt,
    RunEnd(BoxedComp),
    AddInputArraySelection(&'static str, &'static str, Box<Any + Send + 'static>),
    AddOutputArraySelection(&'static str, &'static str),
    ConnectOutputPort(&'static str, Box<Any + Send + 'static>),
    ConnectOutputArrayPort(&'static str, &'static str, Box<Any + Send + 'static>),
}

/// Deal with a running component. 
///
/// This structure allows to manage a running component that is connected inside a graph. It do all
/// the modification between two executions.
///
pub struct CompRunner {
    sender: Sender<CompMsg>,
    input_senders: Box<InputSenders>,
    input_array_senders: Box<InputArraySenders>,
}
impl CompRunner {
    /// Create a new CompRunner. 
    ///
    /// ```c``` is a tuple of three elements : 
    ///
    /// 1) The component in a Box
    ///
    /// 2) A Trait Object which implement InputSenders
    ///
    /// 3) A Trait Object which implement InputArraySenders
    ///
    ///
    /// The trait object are used to return the SyncSenders of the component
    /// 
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

    /// Start the component. It will run the inside function "run" until it was stopped.
    pub fn start(&self) {
        self.sender.send(CompMsg::Start).ok().expect("unable to send to the state");
    }

    /// Connect a simple output port to a simple input port from another component.
    ///
    /// # Example
    ///
    /// In FBP : 
    ///
    /// ```
    /// comp_runner() output => input display()
    /// ```
    ///
    /// In Rust : 
    ///
    /// ```
    /// comp_runner.connect("output", &display, "input");
    /// ```
    pub fn connect(&self, port_out: &'static str, comp: &CompRunner, port_in: &'static str){
        let s = comp.get_sender(port_in).unwrap();
        self.sender.send(CompMsg::ConnectOutputPort(port_out, s)).ok().expect("unable to send to the state");
    }

    /// Connect an array output port to a simple input port from another component.
    ///
    /// # Example
    ///
    /// In FBP : 
    ///
    /// ```
    /// comp_runner() outputs[1] => input display()
    /// ```
    ///
    /// In Rust : 
    ///
    /// ```
    /// comp_runner.connect_array("outputs", "1", &display, "input");
    /// ```
    pub fn connect_array(&self, port_out: &'static str, selection_out: &'static str, comp: &CompRunner, port_in: &'static str){
        let s = comp.get_sender(port_in).expect("CompRunner -> connect_array -> don't find the sender");
        self.sender.send(CompMsg::ConnectOutputArrayPort(port_out, selection_out, s)).ok().expect("unable to send to the state");
    }

    /// Connect a simple output port to an array input port from another component.
    ///
    /// # Example
    ///
    /// In FBP : 
    ///
    /// ```
    /// comp_runner() output => numbers[1] adder()
    /// ```
    ///
    /// In Rust : 
    ///
    /// ```
    /// comp_runner.connect_array("output", &adder, "numbers", "1");
    /// ```
    pub fn connect_to_array(&self, port_out: &'static str, comp: &CompRunner, port_in: &'static str, selection_in: &'static str){
        let s = comp.get_array_sender(port_in, selection_in).expect("CompRunner -> connect_to_array -> don't find the sender");
        self.sender.send(CompMsg::ConnectOutputPort(port_out, s)).ok().expect("unable to send to the state");
    }

    /// Connect an array output port to an array input port from another component.
    ///
    /// # Example
    ///
    /// In FBP : 
    ///
    /// ```
    /// comp_runner() outputs[a] => numbers[1] adder()
    /// ```
    ///
    /// In Rust : 
    ///
    /// ```
    /// comp_runner.connect_array("outputs", "a", &adder, "numbers", "1");
    /// ```
    pub fn connect_array_to_array(&self, port_out: &'static str, selection_out: &'static str, comp: &CompRunner, port_in: &'static str, selection_in: &'static str){
        let s = comp.get_array_sender(port_in, selection_in).expect("CompRunner -> connect_array_to_array -> don't find the sender");
        self.sender.send(CompMsg::ConnectOutputArrayPort(port_out, selection_out, s)).ok().expect("unable to send to the state");
    }
    
    
    /// Returns a SyncSender from the simple input port "port"
    pub fn get_sender(&self, port: &'static str) -> Option<Box<Any + Send + 'static>> {
        self.input_senders.get_sender(port)
    }

    /// Returns a SyncSender from the selection "selection" of the array input port "port"
    pub fn get_array_sender(&self, port: &'static str, selection: &'static str) -> Option<Box<Any + Send + 'static>> {
        self.input_array_senders.get_selection_sender(port, selection)
    }

    /// Modify the component to add the selection "selection" to the array input port "port"
    pub fn add_input_array_selection(&mut self, port: &'static str, selection: &'static str) {
        let (s, r) = self.input_array_senders.get_sender_receiver(port).unwrap();
        self.input_array_senders.add_selection_sender(port, selection, s);
        self.sender.send(CompMsg::AddInputArraySelection(port, selection, r)).ok().expect("unable to send to the state");
    }

    /// Modify the component to add the selection "selection" to the array output port "port"
    pub fn add_output_array_selection(&self, port: &'static str, selection: &'static str) {
        self.sender.send(CompMsg::AddOutputArraySelection(port, selection)).ok().expect("unable to send to the state");
    }

}

/* 
 *  A state is the internal representation of a ComponentRunner. It holds the component between the
 *  execution.
 */
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
        let mut c = mem::replace(&mut self.comp, None).unwrap();
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
        $( option($option_type:ty), )*
        fn run(&mut $arg:ident) $fun:block
    ) 
        =>
    {
        /* Input ports part */

        // simple
        #[allow(dead_code)]
        struct $i_name<$( $( $i_t ),* )*> {
            $(
                $input_field_name: SyncSender<$input_field_type>,
            )*
            $( 
                option: SyncSender<$option_type>,
            )*
        }

        #[allow(dead_code)]
        struct $i_name2<$( $( $i_t ),* )*> {
            $(
                $input_field_name: Receiver<$input_field_type>,
            )*
            $( 
                option: OptionReceiver<$option_type>,
            )*
        }

        impl<$( $( $i_t: $($i_tr)* ),* )*> InputSenders for $i_name<$( $( $i_t),* )*>{
            fn get_sender(&self, port: &'static str) -> Option<Box<Any + Send + 'static>> {
                match port {
                    $(
                        stringify!($input_field_name) => { Some(Box::new(self.$input_field_name.clone())) },
                    )*
                    $(
                        "option" => { 
                            let s : SyncSender<$option_type> = self.option.clone();
                            Some(Box::new(s)) 
                        }, 
                    )*
                    _ => { None },
                }    
            }
        }

        // array
        #[allow(dead_code)]
        struct $ia_name<$( $( $ia_t ),* )*> {
            $(
                $input_array_name: HashMap<&'static str, SyncSender<$input_array_type>>,
            )*    
        }
        #[allow(dead_code)]
        struct $ia_name2<$( $( $ia_t ),* )*> {
            $(
                $input_array_name: HashMap<&'static str, Receiver<$input_array_type>>,
            )*    
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
                $( 
                    let options = sync_channel::<$option_type>(16);
                    let options_s = options.0;
                    let options_r = OptionReceiver::new(options.1);
                )*
                let s = $i_name {
                $(
                    $input_field_name: $input_field_name.0,
                )*    
                $(
                    option: options_s as SyncSender<$option_type>,
                )*
                };
                let r = $i_name2 {
                $(
                    $input_field_name: $input_field_name.1,
                )*    
                $(
                    option: options_r as OptionReceiver<$option_type>,
                )*
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
                    inputs: r, outputs: out, inputs_array: a_r, outputs_array: out_array,
                };
                (Box::new(comp), Box::new(s), Box::new(a_s))
            }
        }

        impl<$( $( $c_t: $($c_tr)* ),* )*> ComponentRun for $name<$( $( $c_t ),* ),* >{
            fn run(&mut $arg) $fun
        }    
    }
}
