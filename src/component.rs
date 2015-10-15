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
use std::sync::mpsc::{SyncSender, Sender, Receiver, SendError, RecvError, TryRecvError};
use std::sync::mpsc::channel;
use std::sync::mpsc::sync_channel;
use std::sync::Arc;

use std::sync::atomic::{AtomicUsize, Ordering};

use std::any::Any;
use std::marker::Reflect;
use std::raw::TraitObject;
use std::mem;
use std::thread;

use fvm::CompMsg;
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
    /// ```ignore
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
/// ```ignore
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
    /// ```ignore
    /// let sync_sender_boxed = inputs_array.get_selectionsender("numbers", "1").unwrap();
    /// let sync_sender: SyncSender<i32> = downcast(sync_sender_boxed);
    /// ```
    fn get_selection_sender(&self, port: &'static str, selection: &'static str) -> Option<Box<Any + Send + 'static>>;

    /// Allow to add a SyncSender in an array input port.
    ///
    /// # Example
    ///
    /// ```ignore
    /// let (s, _) = sync_channel(16);
    /// inputs_array.add_selection_sender("numbers", "1", s);
    /// ```
    fn add_selection_sender(&mut self, port: &'static str, selection: &'static str, sender: Box<Any>);
    /// This method create a SyncSender and a Receiver for the array input port "port".
    /// It returns a tuple (SyncSender, Receiver) both casted at Box<Any>
    ///
    /// # Example
    ///
    /// ```ignore
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
/// ```ignore
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
    /// ```ignore
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
    /// ```ignore
    /// component.connect("output", a_sync_sender);
    /// ```
    fn connect(&mut self, port_out: &'static str, send: Box<Any>, dest: &'static str, sched: Sender<CompMsg>);
    /// Create a selection "selection" for the array output port "port"
    /// # Example
    ///
    /// ```ignore
    /// component.add_output_selection("output", "1");
    /// ```
    fn add_output_selection(&mut self, port: &'static str, selection: &'static str);
    /// Connects the selection "selection" of the array output port "port" with a specific SyncSender
    /// # Example
    ///
    /// ```ignore
    /// component.connect_array("output", "1", a_sync_sender);
    /// ```
    fn connect_array(&mut self, port: &'static str, selection: &'static str, send: Box<Any>, dest: &'static str, sched: Sender<CompMsg>);
    /// Add a Receiver for the selection "selection" of the array input port "port"
    /// # Example
    ///
    /// ```ignore
    /// component.add_selection_receiver("numbers", "1", a_receiver);
    /// ```
    fn add_selection_receiver(&mut self, port: &'static str, selection: &'static str, rec: Box<Any>);
    /// Return true if there is at least one IP in at least one input ports
    fn is_ips(&self) -> bool;
}

/// Define the minimal traits that an IP must have
pub trait IP: Send + Reflect + 'static {}
impl<T> IP for T where T: Send + Reflect + 'static {}

/// Downcast a Box<Any> to a type I. It returns the ownership of the variable, not a borrow.
///
/// # Example 
///
/// ```ignore
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
/// ```ignore
/// let (s, r) = sync_channel(16);
/// let os = OutputSender::<i32>::new();
/// os.connect(s);
/// os.send(23);
/// assert_eq!(r.recv().unwrap(), 23);
/// ```
pub struct OutputSender<T> {
    send: Option<CountSender<T>>,
}
impl<T> OutputSender<T> {
    /// Create a new unconnected OutputSender structure.
    pub fn new() -> Self {
        OutputSender { 
            send: None, 
        }
    }

    /// Connect the OutputSener structure with the given SyncSender
    pub fn connect(&mut self, send: CountSender<T>){
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
            if res.is_ok() { 
                Ok(()) 
            }
            else { Err(OutputPortError::CannotSend(res.unwrap_err())) }
        }
    }
}

pub struct CountSender<T> {
    send: SyncSender<T>,
    pub count: Arc<AtomicUsize>,
    sched: Option<(&'static str, Sender<CompMsg>)>,
}
impl<T> CountSender<T> {
    pub fn new(sender: SyncSender<T>, atom: Arc<AtomicUsize>) -> Self {
        CountSender {
            send: sender,
            count: atom,
            sched: None,
        }
    }

    pub fn send(&self, msg: T) -> Result<(), SendError<T>> {
        let res = self.send.send(msg);
        if res.is_ok() {
            if let Some((ref n, ref s)) = self.sched {
                s.send(CompMsg::Start(n)).ok().expect("CountSender send : Cannot send to the scheduler");
            }
            self.count.fetch_add(1, Ordering::SeqCst);
        }
        res
    }

    pub fn set_sched(&mut self, name: &'static str, sched: Sender<CompMsg>) {
        self.sched = Some((name, sched));
    }
}

impl<T> Clone for CountSender<T> {
    fn clone(&self) -> Self {
        let sched = if let Some((ref n, ref s)) = self.sched {
            Some((n.clone(), s.clone()))
        } else {
            None
        };
        CountSender {
            send: self.send.clone(),
            count: self.count.clone(),
            sched: sched,
        }
    }
}

pub struct CountReceiver<T> {
    recv: Receiver<T>,
    pub count: Arc<AtomicUsize>,
}
impl<T> CountReceiver<T> {
    pub fn new(recv: Receiver<T>, atom: Arc<AtomicUsize>) -> Self {
        CountReceiver {
            recv: recv,
            count: atom,
        }
    }

    pub fn recv(&self) -> Result<T, RecvError> {
        let res = self.recv.recv(); 
        if res.is_ok() {
            self.count.fetch_sub(1, Ordering::SeqCst);
        }
        res
    }

    pub fn try_recv(&self) -> Result<T, TryRecvError> {
        let res = self.recv.try_recv(); 
        if res.is_ok() {
            self.count.fetch_sub(1, Ordering::SeqCst);
        }
        res
    }
}

pub fn count_channel<T>(size: usize) -> (CountSender<T>, CountReceiver<T>){
    let (s, r) = sync_channel(size); 
    let c = Arc::new(AtomicUsize::new(0));
    let s = CountSender::new(s, c.clone());
    let r = CountReceiver::new(r, c.clone());
    (s, r)
}

#[test]
fn test_count_channel() {
    assert!(true);
    let (s, r) = count_channel(16);
    assert!(s.count.load(Ordering::Relaxed) == 0);
    assert!(r.count.load(Ordering::Relaxed) == 0);
    let _ = s.send(11).ok().expect("Not ok");
    assert!(s.count.load(Ordering::Relaxed) == 1);
    assert!(r.count.load(Ordering::Relaxed) == 1);
    let _ = r.recv().ok().expect("Not ok");
    assert!(s.count.load(Ordering::Relaxed) == 0);
    assert!(r.count.load(Ordering::Relaxed) == 0);
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
/// ```ignore
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

    /// Return a message or an error 
    pub fn try_recv(&mut self) -> Result<T, TryRecvError> {
        let opt = self.receiver.try_recv();
        if opt.is_ok() {
            self.opt = Some(opt.clone().unwrap());
        } else {
            if let Some(ref o) = self.opt {
                return Ok(o.clone());
            }
        }
        opt
            
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
                $input_field_name: CountSender<$input_field_type>,
            )*
            $( 
                option: SyncSender<$option_type>,
            )*
        }

        #[allow(dead_code)]
        struct $i_name2<$( $( $i_t ),* )*> {
            $(
                $input_field_name: CountReceiver<$input_field_type>,
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
                $input_array_name: HashMap<&'static str, CountSender<$input_array_type>>,
            )*    
        }
        #[allow(dead_code)]
        struct $ia_name2<$( $( $ia_t ),* )*> {
            $(
                $input_array_name: HashMap<&'static str, CountReceiver<$input_array_type>>,
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
                            let (s, r) : (CountSender<$input_array_type>, CountReceiver<$input_array_type>)= count_channel(16);
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
            fn connect(&mut self, port: &'static str, _send: Box<Any>, _name: &'static str, _sched: Sender<CompMsg>) {
                match port {
                    $(
                        stringify!($output_field_name) => { 
                            let mut down: CountSender<$output_field_type> = component::downcast(_send);
                            down.set_sched(_name, _sched);
                            self.outputs.$output_field_name.connect(down); 
                        }
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

            fn connect_array(&mut self, port: &'static str, _selection: &'static str, _send: Box<Any>, _name: &'static str, _sched: Sender<CompMsg>){
                match port {
                    $(
                        stringify!($output_array_name) => { 
                            let mut s = self.outputs_array.$output_array_name.get_mut(_selection).expect("connect_array : selection not found");
                            let mut down: CountSender<$output_array_type> = component::downcast(_send);
                            down.set_sched(_name, _sched);
                            s.connect(down); 
                        }
                    ),*
                    _ => {},
                }    
            }

            fn is_ips(&self) -> bool { 
                $(
                    if self.inputs.$input_field_name.count.load(Ordering::Relaxed) > 0 { return true; }
                )*
                $(
                    for i in self.inputs_array.$input_array_name.values() {
                        if i.count.load(Ordering::Relaxed) > 0 { return true; }
                    }
                )*
                false 
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
                    let $input_field_name = count_channel::<$input_field_type>(16);
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
                    $input_array_name: HashMap::<&'static str, CountSender<$input_array_type>>::new(),
                ),*
                };
                let a_r = $ia_name2 {
                $(
                    $input_array_name: HashMap::<&'static str, CountReceiver<$input_array_type>>::new(),
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
