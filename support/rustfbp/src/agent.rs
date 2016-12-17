//! This crate helps to create a Fractalide component
//!
//! It provides the macro `component` which takes the high level view of the component, and creates the code for the scheduler.
//!
//! It also declare the Trait Agent and the shared methods needed by every component and the scheduler.


extern crate capnp;

// TODO : Add method to remove components
use ports::{IPSender, IPReceiver};
use scheduler::Signal;
use result::Result;

/// Provide the generic functions of agents
///
/// These three functions are used by the scheduler
pub trait Agent {
    /// Return true if there is at least one input port
    fn is_input_ports(&self) -> bool;
    /// Connect output port
    fn connect(&mut self, port: &str, sender: IPSender) -> Result<()>;
    /// Connect array output port
    fn connect_array(&mut self, port: &str, element: String, sender: IPSender) -> Result<()>;
    /// Add input element
    fn add_inarr_element(&mut self, port: &str, element: String, recv: IPReceiver) -> Result<()>;
    /// Run the method of the component, his personal logic
    fn run(&mut self) -> Result<Signal>;
}


/// The agent macro.
///
/// It helps to define a agent, by defining the input and output ports, if there is an option or an acc port, ...
///
/// Example :
///
/// ```rust,ignore
/// agent! {
///    inputs(input: any),
///    outputs(output: any),
///    option(generic_text),
///    fn run(&mut self) -> Result<Signal> {
///        // Receive an IP
///        let ip = try!(self.input.input.recv());
///
///        // Received an IP from the option port (a generic_text)
///        let opt = self.recv_opt();
///
///        // Get the capn'p reader
///        let reader: generic_text::Reader = try!(opt.read_schema());
///        // Print the option
///        println!("{}", try!(reader.get_text()));
///
///        // Send the received IP outside, but don't care about the success (drop on fail)
///        let _ = self.output.output.send(ip);
///
///        Ok(End)
///    }
/// }
/// ```
#[macro_export]
macro_rules! agent {
    (
        $( input($( $input_name:ident: $input_contract:ident ),*), )*
        $( inarr($( $input_a_name:ident: $input_a_contract:ident ),*), )*
        $( output($( $output_name:ident: $output_contract:ident ),*), )*
        $( outarr($( $output_a_name:ident: $output_a_contract:ident ),*), )*
        $( portal( $portal_type:ty => $portal_value:expr ), )*
        $( option($option:ident), )*
        $( accumulator($acc:ident ), )*
        fn run(&mut $arg:ident) -> Result<Signal> $fun:block
    )
        =>
    {
        use rustfbp::agent::Agent;

        use rustfbp::result;
        use rustfbp::result::Result;
        use rustfbp::scheduler::{CompMsg, Signal};
        use std::error::Error;

        use std::sync::mpsc::{Sender};
        use std::sync::mpsc::channel;

        use rustfbp::ports::{IP, IPSender, IPReceiver, OutputSend};

        #[allow(unused_imports)]
        use std::collections::HashMap;

        use capnp::serialize;
        use capnp::message;

        use std::io::{Read, Write};

        use rustfbp::scheduler::Signal::*;

        mod edge_capnp {
                include!("edge_capnp.rs");
        }

        use edge_capnp::*;

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
        impl Agent for $name {

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

        /* Global agent */

        #[allow(dead_code)]
        #[allow(non_camel_case_types)]
        pub struct $name {
            name: String,
            pub ports: Ports,
            pub option_ip: Option<IP>,
            $(
            pub portal: $portal_type ,
            )*
        }

        #[allow(dead_code)]
        pub fn new(name: String, sched: Sender<CompMsg>) -> Result<(Box<Agent + Send>, HashMap<String, IPSender>)> {
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
            Ok((Box::new(comp) as Box<Agent + Send>, senders))
        }

        #[no_mangle]
        pub extern fn create_agent(name: String, sched: Sender<CompMsg>) -> Result<(Box<Agent + Send>, HashMap<String, IPSender>)> {
            new(name, sched)
        }

        #[no_mangle]
        pub extern fn get_schema_input(port: &str) -> Result<String> {
            match port {
                $(
                    stringify!($input_field_name)=> Ok(stringify!($input_edge_name).into()),
                )*
                _ => { Err(result::Error::PortNotFound("unknown".into(), port.into())) }
            }
        }

        #[no_mangle]
        pub extern fn get_schema_input_array(port: &str) -> Result<String> {
            match port {
                $(
                    stringify!($input_array_name) => Ok(stringify!($input_edge_array).into()),
                )*
                _ => { Err(result::Error::PortNotFound("unknown".into(), port.into())) }
            }
        }

        #[no_mangle]
        pub extern fn get_schema_output(port: &str) -> Result<String> {
            match port {
                $(
                    stringify!($output_field_name)=> Ok(stringify!($output_edge_name).into()),
                )*
                _ => { Err(result::Error::PortNotFound("unknown".into(), port.into())) }
            }
        }

        #[no_mangle]
        pub extern fn get_schema_output_array(port: &str) -> Result<String> {
            match port {
                $(
                    stringify!($output_array_name) => Ok(stringify!($output_edge_array).into()),
                )*
                _ => { Err(result::Error::PortNotFound("unknown".into(), port.into())) }
            }
        }
    }
}
