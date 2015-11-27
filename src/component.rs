/*
 * The component library for rustfbp
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

// TODO : manage the number of connection on the array port (on each port on in the scheduler?)
// TODO : option port

extern crate nanomsg;
extern crate capnp;

use result;
use result::Result;

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
 

/// Manage the array input ports of a component.
pub trait InputArray {
    /// Allow to add a selection in an input array port.
    fn add_selection(&mut self, sched: String, comp: String, port: String, selection: String) -> Result<()>;
}

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
// pub struct OptionReceiver<T> {
//     opt: Option<T>,
//     receiver: Receiver<T>,
// }
// impl<T: Clone> OptionReceiver<T> {
//     /// Return a new OptionReceiver for the Receiver "r"
//     pub fn new(r: Receiver<T>) -> Self {
//         OptionReceiver{ 
//             opt: None,
//             receiver: r,
//         }
//     }
// 
//     fn recv_last(&mut self, acc: Option<T>) -> T {
//         let msg = self.receiver.try_recv();
//         match msg {
//             Ok(msg) => {
//                 self.recv_last(Some(msg))
//             },
//             _ => {
//                 if acc.is_some() { acc.unwrap() }
//                 else { self.receiver.recv().unwrap() }
//             }
//         }
//     }
// 
//     /// Return a message.
//     pub fn recv(&mut self) -> T {
//         let actual = mem::replace(&mut self.opt, None);
//         let opt = self.recv_last(actual); 
//         self.opt = Some(opt.clone());
//         opt
//     }
// 
//     fn try_recv_last(&mut self, acc: Option<T>) -> Result<T, TryRecvError> {
//         let msg = self.receiver.try_recv();
//         match msg {
//             Ok(msg) => {
//                 self.try_recv_last(Some(msg))
//             }
//             _ => {
//                 if acc.is_some() { Ok(acc.unwrap()) }
//                 else { msg }
//             }
//         }
//     }
// 
//     /// Return a message or an error 
//     pub fn try_recv(&mut self) -> Result<T, TryRecvError> {
//         let actual = mem::replace(&mut self.opt, None);
//         let opt = self.try_recv_last(actual);
//         if opt.is_ok() {
//             self.opt = Some(opt.clone().unwrap());
//         } 
//         opt
//     }
// }


        //option($($option_type:ty)*), 
        //acc($($acc_type:ty)*),
#[macro_export]
macro_rules! component {
    (
       $name:ident, $( ( $($c_t:ident$(: $c_tr:ident)* ),* ),)*
        inputs($( $input_field_name:ident),* ),
        inputs_array($( $input_array_name:ident),* ),
        outputs($( $output_field_name:ident),* ),
        outputs_array($($output_array_name:ident),* ),
        fn run(&mut $arg:ident) $fun:block
        $($more:item)*
    ) 
        =>
    {
        #[allow(non_snake_case)]
        mod $name {
        use rustfbp::component::*;

        use rustfbp::result;
        use rustfbp::result::Result;

        use rustfbp::ports::{InputPort, OutputPort};
        #[allow(unused_imports)]
        use std::collections::HashMap;

        $($more)*

        /* Input ports part */

        // simple
        #[allow(dead_code)]
        struct Inputs {
            $(
                $input_field_name: InputPort,
            )*
            /*
            $( 
                option: OptionReceiver<$option_type>,
            )*
            */
            acc: InputPort,
        }

        // array
        #[allow(dead_code)]
        struct InputsArray {
            $(
                $input_array_name: HashMap<String, InputPort>,
            )*    
        }

        impl InputArray for InputsArray {
            fn add_selection(&mut self, _sched: String, _comp: String, port: String, _selection: String) -> Result<()>{
                match &(port[..]) {
                    $(
                        stringify!($input_array_name) => { 
                            self.$input_array_name.insert(_selection.clone(), try!(InputPort::new(_sched, _comp, format!("{}{}", port, _selection))));
                            Ok(())
                        }
                    ),*
                    _ => { Err(result::Error::PortNotFound) },
                }    
            }
        }


        /* Output ports part */

        // simple
        #[allow(dead_code)]
        struct Outputs {
            $(
                $output_field_name: OutputPort,
            )*
            acc: OutputPort,
        }

        // array
        #[allow(dead_code)]
        struct OutputsArray {
            $(
                $output_array_name: HashMap<String, OutputPort>
            ),*
        }

        // simple and array
        impl $name {
            pub fn connect(&mut self, port_out: &String, _sched: &String, _comp_in: &String, _port_in: &String) -> Result<()>{
                match &(port_out[..]) {
                    $(
                        stringify!($output_field_name) => { 
                            self.outputs.$output_field_name.connect(_sched.clone(), _comp_in.clone(), _port_in.clone()) 
                        }
                    ),*
                    _ => { Err(result::Error::PortNotFound) },
                }    
            }

            pub fn connect_array(&mut self, port_out: &String, _selection_out: &String, _sched: &String, _comp_in: &String, _port_in: &String) -> Result<()>{
                match &(port_out[..]) {
                    $(
                        stringify!($output_array_name) => { 
                            self.outputs_array.$output_array_name.get_mut(_selection_out)
                                              .ok_or(result::Error::SelectionNotFound)
                                              .and_then(|s| {
                                                  s.connect(_sched.clone(), _comp_in.clone(), _port_in.clone()) 
                                              })
                        }
                    ),*
                    _ => { Err(result::Error::PortNotFound) },
                }    
            }

            pub fn add_input_selection(&mut self, port: &String, selection: &String) -> Result<()> {
                self.inputs_array.add_selection(self.sched.clone(), self.name.clone(), port.clone(), selection.clone())
            }

            pub fn add_output_selection(&mut self, port: &String, _selection: &String) -> Result<()> {
                match &(port[..]) {
                    $(
                        stringify!($output_array_name) => { 
                            if self.outputs_array.$output_array_name.get(_selection).is_none() {
                                self.outputs_array.$output_array_name.insert(_selection.clone(), try!(OutputPort::new())); 
                            }
                            Ok(())
                        }
                    ),*
                    _ => { Err(result::Error::PortNotFound) },
                }    

            }


            pub fn disconnect(&mut self, port: &String) -> Result<Option<(String, String, String)>> {
                match &(port[..]) {
                    $(
                        stringify!($output_field_name) => { 
                            self.outputs.$output_field_name.disconnect() 
                        }
                    ),*
                    _ => { Err(result::Error::PortNotFound) },
                }    
            }

            pub fn disconnect_array(&mut self, port: &String, _selection: &String) -> Result<Option<(String, String, String)>> {
                match &(port[..]) {
                    $(
                        stringify!($output_array_name) => { 
                            self.outputs_array.$output_array_name.get_mut(_selection)
                                              .ok_or(result::Error::SelectionNotFound)
                                              .and_then(|s| { s.disconnect() })
                        }
                    ),*
                    _ => { Err(result::Error::PortNotFound) },
                }    
            }

            pub fn is_input_ports(&self) -> bool { 
                $(
                    if true || stringify!($input_field_name) == "" { return true; }
                )*
                $(
                    if true || stringify!($input_array_name) == "" { return true; }
                )*
                false 
            }

            pub fn run(&mut $arg) $fun

        }

        /* Global component */

        #[allow(dead_code)]
        pub struct $name {
            sched: String,
            name: String,
            inputs: Inputs,
            inputs_array:InputsArray,
            outputs: Outputs,
            outputs_array: OutputsArray,
        }

        #[allow(dead_code)]
        pub fn new(sched: &String, name: &String) -> Result<Box<$name>> {
            // Creation of the inputs
            /*
            $( 
                let options = sync_channel::<$option_type>(16);
                let options_s = options.0;
                let options_r = OptionReceiver::new(options.1);
            )*
            */
            let r = Inputs {
            $(
                $input_field_name: try!(InputPort::new(sched.clone(), name.clone(), stringify!($input_field_name).into())),
            )*    
            /*
            $(
                option: options_r as OptionReceiver<$option_type>,
            )*
            */
            acc: try!(InputPort::new(sched.clone(), name.clone(), "acc".into())),
            };

            // Creation of the array inputs
            let a_r = InputsArray {
            $(
                $input_array_name: HashMap::<String, InputPort>::new(),
            )*
            };

            // Creation of the output
            let mut out = Outputs {
                $(
                    $output_field_name: try!(OutputPort::new()),
                )*    
                acc: try!(OutputPort::new()),
            };

            // Creation of the array output
            let out_array = OutputsArray {
                $(
                    $output_array_name: HashMap::<String, OutputPort>::new(),
                )*
            };

            try!(out.acc.connect(sched.clone(), name.clone(), "acc".into()));

            // Put it together
            let comp = $name{
                sched: sched.clone(),
                name: name.clone(),
                inputs: r, 
                outputs: out,
                inputs_array: a_r,
                outputs_array: out_array,
            };
            Ok(Box::new(comp))
        }

        }

        use std::mem::transmute;

        #[no_mangle]
        pub extern fn create_component(sched: &String, name: &String) -> *mut $name::$name {
            let comp = $name::new(sched, name).expect("unable to create the comp");
            unsafe { transmute(comp) }
        }

        #[no_mangle]
        pub extern fn run(ptr: *mut $name::$name) {
            let mut comp = unsafe { &mut *ptr };
            comp.run();
        }

        #[no_mangle]
        pub extern fn connect(ptr: *mut $name::$name, port_out: &String, sched: &String, comp_in: &String, port_in: &String) -> u32 {
            let mut comp = unsafe { &mut *ptr };
            match comp.connect(port_out, sched, comp_in, port_in) {
                Ok(_) => 0,
                Err(_) => 1,
            }
        }

        #[no_mangle]
        pub extern fn connect_array(ptr: *mut $name::$name, port_out: &String, selection_out: &String, sched: &String, comp_in: &String, port_in: &String) -> u32 {
            let mut comp = unsafe { &mut *ptr };
            match comp.connect_array(port_out, selection_out, sched, comp_in, port_in) {
                Ok(_) => 0,
                Err(_) => 1,
            }
        }

        #[no_mangle]
        pub extern fn add_output_selection(ptr: *mut $name::$name, port: &String, selection: &String) -> u32 {
            let mut comp = unsafe { &mut *ptr };
            match comp.add_output_selection(port, selection) {
                Ok(_) => 0,
                Err(_) => 1,
            }
        }

        #[no_mangle]
        pub extern fn add_input_selection(ptr: *mut $name::$name, port: &String, selection: &String) -> u32 {
            let mut comp = unsafe { &mut *ptr };
            match comp.add_input_selection(port, selection) {
                Ok(_) => 0,
                Err(_) => 1,
            }
        }

        #[no_mangle]
        pub extern fn disconnect(ptr: *mut $name::$name, port: &String) -> u32 {
            let mut comp = unsafe { &mut *ptr };
            match comp.disconnect(port) {
                Ok(_) => 0,
                Err(_) => 1,
            }
        }

        #[no_mangle]
        pub extern fn disconnect_array(ptr: *mut $name::$name, port: &String, selection: &String) -> u32 {
            let mut comp = unsafe { &mut *ptr };
            match comp.disconnect_array(port, selection) {
                Ok(_) => 0,
                Err(_) => 1,
            }
        }

        #[no_mangle]
        pub extern fn is_input_ports(ptr: *mut $name::$name) -> bool {
            let mut comp = unsafe { &mut *ptr };
            comp.is_input_ports() 
        }


        #[no_mangle]
        pub extern fn destroy_component(ptr: *mut $name::$name) {
            let _comp: Box<$name::$name> = unsafe { transmute(ptr) };
        }
    }
}
