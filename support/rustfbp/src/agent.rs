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

        impl ThisAgent {
            $(
            fn dummy() {
                if stringify!($option) != "" {}
            }
            pub fn recv_option(&mut self) -> IP {
                self.try_recv_option();
                if self.option_ip.is_none() {
                    self.option_ip = self.input.option.recv().ok();
                }
                match self.option_ip {
                    Some(ref ip) => ip.clone(),
                    None => unreachable!(),
                }
            }

            pub fn try_recv_option(&mut self) -> Option<IP> {
                loop {
                    match self.input.option.try_recv() {
                        Err(_) => { break; },
                        Ok(ip) => { self.option_ip = Some(ip); }
                    };
                }
                self.option_ip.as_ref().map(|ip|{ ip.clone() })
            }
            )*

            pub fn send_action(&mut self, output: &str, ip: IP) -> Result<()> {
                if let Some(sender) = {
                    match output {
                        $($(
                            stringify!($output_a_name) =>  { self.outarr.$output_a_name.get(&ip.action) }
                        )*)*
                            _ => None
                    }
                } // End of the if let Some = { ... }
                {
                    let s: &IPSender = sender;
                    try!(s.send(ip));
                }
                else {
                    match output {
                        $($(
                            stringify!($output_name) => { self.output.$output_name.send(ip);}
                        )*)*
                            _ => { return Err(result::Error::PortDontExist(output.into())); }
                    }
                }
                Ok(())
            }
        }

        impl Agent for ThisAgent {

            fn is_input_ports(&self) -> bool {
                $($(
                    if true || stringify!($input_name) == "" { return true; }
                )*)*
                $($(
                    if true || stringify!($input_a_name) == "" { return true; }
                )*)*
                false
            }

            fn connect(&mut self, port: &str, sender: IPSender) -> Result<()> {
                match port {
                    $($(
                        stringify!($output_name) => {
                            self.output.$output_name = Some(sender);
                        }
                    )*)*
                        _ => {
                            return Err(result::Error::PortDontExist(port.into()));
                        }
                }
                Ok(())
            }

            fn connect_array(&mut self, port: &str, element: String, sender: IPSender) -> Result<()> {
                match port {
                    $($(
                        stringify!($output_a_name) => {
                            self.outarr.$output_a_name.insert(element, sender);
                        }
                    )*)*
                        _ => {
                            return Err(result::Error::PortDontExist(port.into()));
                        }
                }
                Ok(())
            }

            fn add_inarr_element(&mut self, port: &str, element: String, recv: IPReceiver) -> Result<()> {
                match port {
                    $($(
                        stringify!($input_a_name) => {
                            self.inarr.$input_a_name.insert(element, recv);
                            Ok(())
                        }
                    )*)*
                        _ => {
                            Err(result::Error::PortDontExist(port.into()))
                        }
                }
            }

            fn run(&mut $arg) -> Result<Signal> $fun

        }

        pub struct Input {
            option: IPReceiver,
            acc: IPReceiver,
            $($(
                $input_name: IPReceiver,
            )*)*
        }

        pub struct Inarr {
            $($(
                $input_a_name: HashMap<String, IPReceiver>,
            )*)*
        }

        pub struct Output {
            acc: Option<IPSender>,
            $($(
                $output_name: Option<IPSender>,
            )*)*
        }

        pub struct Outarr {
            $($(
                $output_a_name: HashMap<String, IPSender>
            )*)*
        }

        /* Global component */

        #[allow(dead_code)]
        #[allow(non_camel_case_types)]
        pub struct ThisAgent {
            name: String,
            pub input: Input,
            pub inarr: Inarr,
            pub output: Output,
            pub outarr: Outarr,
            pub option_ip: Option<IP>,
            sched: Sender<CompMsg>,
            $(
            pub portal: $portal_type ,
            )*
        }

        #[allow(dead_code)]
        pub fn new(name: String, sched: Sender<CompMsg>) -> Result<(Box<Agent + Send>, HashMap<String, IPSender>)> {

            let mut senders: HashMap<String, IPSender> = HashMap::new();
            let option = IPReceiver::new(name.clone(), sched.clone(), false);
            senders.insert("option".to_string(), option.1);
            let acc = IPReceiver::new(name.clone(), sched.clone(), false);
            senders.insert("acc".to_string(), acc.1.clone());
            $($(
                let $input_name = IPReceiver::new(name.clone(), sched.clone(), true);
                senders.insert(stringify!($input_name).to_string(), $input_name.1);
            )*)*
            let input = Input {
                option: option.0,
                acc: acc.0,
                $($(
                    $input_name: $input_name.0,
                )*)*
            };

            let inarr = Inarr {
                $($(
                    $input_a_name: HashMap::new(),
                )*)*
            };

            let output = Output {
                acc: Some(acc.1),
                $($(
                    $output_name: None,
                )*)*
            };

            let outarr = Outarr {
                $($(
                    $output_a_name: HashMap::new(),
                )*)*
            };

            let agent= ThisAgent {
                name: name,
                input: input,
                inarr: inarr,
                output: output,
                outarr: outarr,
                option_ip: None,
                sched: sched,
                $(
                    portal: $portal_value,
                )*
            };

            Ok((Box::new(agent) as Box<Agent + Send>, senders))
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
