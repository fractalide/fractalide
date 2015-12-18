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

extern crate capnp;

/* 
 *
 * There are two main parts for a component : the component itself and the part that manage the
 * connections and the running part. 
 *
 * Each
 * ComponentRun and ComponentConnect). These traits give all the information for the connection
 * between several components.
 *
 * The CompRunner, that manages the connection and the run of the component only interact with the
 * Trait of the component.
 *
 */
 


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

        use rustfbp::ports::Ports;

        use rustfbp::allocator::{Allocator, HeapSenders, HeapIPSender, HeapIPReceiver};
        #[allow(unused_imports)]
        use std::collections::HashMap;

        use capnp::serialize;
        use capnp::message;

        use std::io::{Read, Write};

        $($more)*

        // simple and array
        impl $name {
            pub fn disconnect(&mut self, port: &String) -> Result<()> {
                Ok(())
            }

            pub fn disconnect_array(&mut self, port: &String, _selection: &String) -> Result<()> {
                Ok(())
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
            allocator: Allocator,
            name: String,
            pub ports: Ports,
        }

        #[allow(dead_code)]
        pub fn new(name: &String, allocator: &Allocator, senders: *mut HeapSenders) -> Result<Box<$name>> {
            // Creation of the inputs
            /*
            $( 
                let options = sync_channel::<$option_type>(16);
                let options_s = options.0;
                let options_r = OptionReceiver::new(options.1);
            )*
            */
            let mut ports = try!(Ports::new(name.clone(), allocator, senders,
                                   vec!["acc".into(), $( stringify!($input_field_name).to_string() ),*],
                                   vec![$( stringify!($input_array_name).to_string() ),*],
                                   vec!["acc".into(), $( stringify!($output_field_name).to_string() ),*],
                                   vec![$( stringify!($output_array_name).to_string() ),*],));
            // TODO : connect acc port
            //try!(ports.connect("acc".into(), name.clone(), "acc".into(), None));

            // Put it together
            let comp = $name{
                allocator: allocator.clone(),
                name: name.clone(),
                ports: ports,
            };
            Ok(Box::new(comp))
        }

        }

        use std::mem::transmute;
        use rustfbp::allocator::{Allocator, HeapSenders, HeapIPSender, HeapIPReceiver};

        #[no_mangle]
        pub extern fn create_component(name: &String, allocator: &Allocator, senders: *mut HeapSenders) -> *mut $name::$name {
            let comp = $name::new(name, allocator, senders).expect("unable to create the comp");
            unsafe { transmute(comp) }
        }

        #[no_mangle]
        pub extern fn run(ptr: *mut $name::$name) {
            let mut comp = unsafe { &mut *ptr };
            comp.run();
        }

        #[no_mangle]
        pub extern fn connect(ptr: *mut $name::$name, port_out: &String, send: *const HeapIPSender) -> u32 {
            let mut comp = unsafe { &mut *ptr };
            match comp.ports.connect(port_out.clone(), send) {
                Ok(_) => 0,
                Err(_) => 1,
            }
        }
        #[no_mangle]
        pub extern fn connect_array(ptr: *mut $name::$name, port_out: &String, selection_out: &String, send: *const HeapIPSender) -> u32 {
            let mut comp = unsafe { &mut *ptr };
            match comp.ports.connect_array(port_out.clone(), selection_out.clone(), send) {
                Ok(_) => 0,
                Err(_) => 1,
            }
        }
        #[no_mangle]
        pub extern fn add_output_selection(ptr: *mut $name::$name, port: &String, selection: &String) -> u32 {
            let mut comp = unsafe { &mut *ptr };
            match comp.ports.add_output_selection(port.clone(), selection.clone()) {
                Ok(_) => 0,
                Err(_) => 1,
            }
        }

        #[no_mangle]
        pub extern fn add_input_selection(ptr: *mut $name::$name, port: &String, selection: &String) -> *const HeapIPSender {
            let mut comp = unsafe { &mut *ptr };
            comp.ports.add_input_selection(port.clone(), selection.clone()).expect("cannot add_input_selection")
        }

        #[no_mangle]
        pub extern fn add_input_receiver(ptr: *mut $name::$name, port: &String, selection: &String, hir: *const HeapIPReceiver) {
            let mut comp = unsafe { &mut *ptr };
            comp.ports.add_input_receiver(port.clone(), selection.clone(), hir).expect("cannot add_input_receiver")
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
