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
use ports::Ports;
use result::Result;

pub trait Component {
    fn get_ports(&mut self) -> &mut Ports;
    fn is_input_ports(&self) -> bool;
    fn run(&mut self) -> Result<()>;
}

#[macro_export]
macro_rules! component {
    (
       $name:ident, $( contracts( $( $contract:ident ),* ) )*
        inputs($( $input_field_name:ident: $input_contract_name:ident),* ),
        inputs_array($( $input_array_name:ident: $input_contract_array:ident),* ),
        outputs($( $output_field_name:ident: $output_contract_name:ident),* ),
        outputs_array($($output_array_name:ident: $output_contract_array:ident),* ),
        option($($option_contract: ident),*),
        acc($($acc_contract: ident),*), $( portal($portal_type:ty => $portal_value:expr))*
        fn run(&mut $arg:ident) -> Result<()> $fun:block
    )
        =>
    {
        use rustfbp::component::Component;

        use rustfbp::result;
        use rustfbp::result::Result;
        use rustfbp::ports::IPSender;
        use rustfbp::scheduler::CompMsg;
        use std::error::Error;

        use std::sync::mpsc::Sender;

        use rustfbp::ports::{IP, Ports};

        #[allow(unused_imports)]
        use std::collections::HashMap;

        use capnp::serialize;
        use capnp::message;

        use std::io::{Read, Write};

        $(
        mod contract_capnp {
            $(
                include!(concat!("src/",stringify!($contract), ".rs"));
            )*
        })*

        $( $(
            use contract_capnp::$contract;
        )* )*

        impl $name {
            pub fn recv_option(&mut self) -> IP {
                self.try_recv_option();
                if self.option_ip.is_none() {
                    self.option_ip = self.ports.recv("option").ok();
                }
                match self.option_ip {
                    Some(ref ip) => ip.clone(),
                    None => unreachable!(),
                }
            }

            pub fn try_recv_option(&mut self) -> Option<IP> {
                loop {
                    match self.ports.try_recv("option") {
                        Err(_) => { break; },
                        Ok(ip) => { self.option_ip = Some(ip); }
                    };
                }
                self.option_ip.as_ref().map(|ip|{ ip.clone() })
            }
        }

        // simple and array
        impl Component for $name {

            fn get_ports(&mut self) -> &mut Ports {
                &mut self.ports
            }

            fn is_input_ports(&self) -> bool {
                $(
                    if true || stringify!($input_field_name) == "" { return true; }
                )*
                $(
                    if true || stringify!($input_array_name) == "" { return true; }
                )*
                false
            }

            fn run(&mut $arg) -> Result<()> $fun

        }

        /* Global component */

        #[allow(dead_code)]
        pub struct $name {
            name: String,
            pub ports: Ports,
            pub option_ip: Option<IP>,
            $(
            pub portal: $portal_type ,
            )*
        }

        #[allow(dead_code)]
        pub fn new(name: String, sched: Sender<CompMsg>) -> Result<(Box<Component + Send>, HashMap<String, IPSender>)> {
            let (ports, senders) = try!(Ports::new(name.clone(), sched,
                                   vec!["option".into(), "acc".into(), $( stringify!($input_field_name).to_string() ),*],
                                   vec![$( stringify!($input_array_name).to_string() ),*],
                                   vec!["acc".into(), $( stringify!($output_field_name).to_string() ),*],
                                   vec![$( stringify!($output_array_name).to_string() ),*],));

            // Put it together
            let comp = $name{
                name: name,
                ports: ports,
                option_ip: None,
                $(
                    portal: $portal_value,
                )*
            };
            Ok((Box::new(comp) as Box<Component + Send>, senders))
        }

        #[no_mangle]
        pub extern fn create_component(name: String, sched: Sender<CompMsg>) -> Result<(Box<Component + Send>, HashMap<String, IPSender>)> {
            new(name, sched)
        }

        #[no_mangle]
        pub extern fn get_contract_input(port: &str) -> Result<String> {
            match port {
                $(
                    stringify!($input_field_name)=> Ok(stringify!($input_contract_name).into()),
                )*
                _ => { Err(result::Error::PortNotFound) }
            }
        }

        #[no_mangle]
        pub extern fn get_contract_input_array(port: &str) -> Result<String> {
            match port {
                $(
                    stringify!($input_array_name) => Ok(stringify!($input_contract_array).into()),
                )*
                _ => { Err(result::Error::PortNotFound) }
            }
        }

        #[no_mangle]
        pub extern fn get_contract_output(port: &str) -> Result<String> {
            match port {
                $(
                    stringify!($output_field_name)=> Ok(stringify!($output_contract_name).into()),
                )*
                _ => { Err(result::Error::PortNotFound) }
            }
        }

        #[no_mangle]
        pub extern fn get_contract_output_array(port: &str) -> Result<String> {
            match port {
                $(
                    stringify!($output_array_name) => Ok(stringify!($output_contract_array).into()),
                )*
                _ => { Err(result::Error::PortNotFound) }
            }
        }
    }
}
