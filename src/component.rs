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

extern crate capnp;

#[macro_export]
macro_rules! component {
    (
       $name:ident, $( ( $($c_t:ident$(: $c_tr:ident)* ),* ),)*
        inputs($( $input_field_name:ident: $input_contract_name:ident),* ),
        inputs_array($( $input_array_name:ident: $input_contract_array:ident),* ),
        outputs($( $output_field_name:ident: $output_contract_name:ident),* ),
        outputs_array($($output_array_name:ident: $output_contract_array:ident),* ),
        option($($option_contract: ident),*),
        acc($($acc_contract: ident),*),
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

        use rustfbp::allocator::{Allocator, HeapSenders, HeapIPSender, HeapIPReceiver, IP};
        #[allow(unused_imports)]
        use std::collections::HashMap;

        use capnp::serialize;
        use capnp::message;

        use std::io::{Read, Write};

        $($more)*

        // simple and array
        impl $name {
            pub fn recv_option(&mut self) -> IP {
                self.try_recv_option();
                if self.option_ip.is_none() {
                    self.option_ip = self.ports.recv("option".into()).ok();
                }
                match self.option_ip {
                    Some(ref ip) => ip.clone(),
                    None => unreachable!(),
                }
            }

            pub fn try_recv_option(&mut self) -> Option<IP> {
                loop {
                    match self.ports.try_recv("option".into()) {
                        Err(_) => { break; },
                        Ok(ip) => { self.option_ip = Some(ip); }
                    };
                }
                self.option_ip.as_ref().map(|ip|{ ip.clone() })
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
            pub option_ip: Option<IP>,
        }

        #[allow(dead_code)]
        pub fn new(name: &String, allocator: &Allocator, senders: *mut HeapSenders) -> Result<Box<$name>> {
            let mut ports = try!(Ports::new(name.clone(), allocator, senders,
                                   vec!["option".into(), "acc".into(), $( stringify!($input_field_name).to_string() ),*],
                                   vec![$( stringify!($input_array_name).to_string() ),*],
                                   vec!["acc".into(), $( stringify!($output_field_name).to_string() ),*],
                                   vec![$( stringify!($output_array_name).to_string() ),*],));

            // Put it together
            let comp = $name{
                allocator: allocator.clone(),
                name: name.clone(),
                ports: ports,
                option_ip: None,
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
        pub extern fn set_receiver(ptr: *mut $name::$name, port: &String, recv: *const HeapIPReceiver) {
            let mut comp = unsafe { &mut *ptr };
            comp.ports.set_receiver(port.clone(), recv);
        }

        #[no_mangle]
        pub extern fn get_receiver(ptr: *mut $name::$name, port: &String) -> *const HeapIPReceiver {
            let mut comp = unsafe { &mut *ptr };
            comp.ports.remove_receiver(port).expect("cannot get receiver")
        }

        #[no_mangle]
        pub extern fn get_array_receiver(ptr: *mut $name::$name, port: &String, selection: &String) -> *const HeapIPReceiver {
            let mut comp = unsafe { &mut *ptr };
            comp.ports.remove_array_receiver(port, selection).expect("cannot get receiver")
        }

        #[no_mangle]
        pub extern fn disconnect(ptr: *mut $name::$name, port: &String) -> u32 {
            let mut comp = unsafe { &mut *ptr };
            match comp.ports.disconnect(port.clone()) {
                Ok(_) => 0,
                Err(_) => 1,
            }
        }

        #[no_mangle]
        pub extern fn disconnect_array(ptr: *mut $name::$name, port: &String, selection: &String) -> u32 {
            let mut comp = unsafe { &mut *ptr };
            match comp.ports.disconnect_array(port.clone(), selection.clone()) {
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
