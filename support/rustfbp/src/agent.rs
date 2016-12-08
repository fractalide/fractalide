//! This crate helps to create a Fractalide agent
//!
//! It provides the macro `agent` which takes the high level view of the agent, and creates the code for the scheduler.
//!
//! It also declare the Trait Agent and the shared methods needed by every agent and the scheduler.


extern crate capnp;
use ports::Ports;
use result::Result;

/// Provide the generic functions of agents
///
/// These three functions are used by the scheduler
pub trait Agent {
    /// Return a muttable borrow to the Ports object.
    fn get_ports(&mut self) -> &mut Ports;
    /// Return true if there is at least one input port
    fn is_input_ports(&self) -> bool;
    /// Run the method of the agent, his personal logic
    fn run(&mut self) -> Result<()>;
}


/// The agent macro.
///
/// It helps to define a agent, by defining the input and output ports, if there is an option or an acc port, ...
///
/// `edges()` and `portal()` are optional.
///
/// Example :
///
/// ```rust,ignore
/// agent! {
///    display, edges(generic_text)
///    inputs(input: any),
///    inputs_array(),
///    outputs(output: any),
///    outputs_array(),
///    option(generic_text),
///    acc(), portal()
///    fn run(&mut self) -> Result<()> {
///        // Receive an IP
///        let ip = try!(self.ports.recv("input"));
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
///        let _ = self.ports.send("output", ip);
///
///        Ok(())
///    }
/// }
/// ```
#[macro_export]
macro_rules! agent {
    (
       $name:ident, $( edges( $( $edge:ident ),* ) )*
        inputs($( $input_field_name:ident: $input_edge_name:ident),* ),
        inputs_array($( $input_array_name:ident: $input_edge_array:ident),* ),
        outputs($( $output_field_name:ident: $output_edge_name:ident),* ),
        outputs_array($($output_array_name:ident: $output_edge_array:ident),* ),
        option($($option_edge: ident),*),
        acc($($acc_edge: ident),*), $( portal($portal_type:ty => $portal_value:expr))*
        fn run(&mut $arg:ident) -> Result<()> $fun:block
    )
        =>
    {
        use rustfbp::agent::Agent;

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

        mod edge_capnp {
                include!("edge_capnp.rs");
        }

        $( $(
            use edge_capnp::$edge;
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
