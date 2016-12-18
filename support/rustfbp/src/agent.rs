//! This crate helps to create a Fractalide component
//!
//! It provides the macro `component` which takes the high level view of the component, and creates the code for the scheduler.
//!
//! It also declare the Trait Agent and the shared methods needed by every component and the scheduler.


extern crate capnp;

// TODO : Add method to remove components
use ports::{MsgSender, MsgReceiver};
use scheduler::Signal;
use result::Result;

/// Provide the generic functions of agents
///
/// These three functions are used by the scheduler
pub trait Agent {
    /// Return true if there is at least one input port
    fn is_input_ports(&self) -> bool;
    /// Connect output port
    fn connect(&mut self, port: &str, sender: MsgSender) -> Result<()>;
    /// Connect array output port
    fn connect_array(&mut self, port: &str, element: String, sender: MsgSender) -> Result<()>;
    /// Add input element
    fn add_inarr_element(&mut self, port: &str, element: String, recv: MsgReceiver) -> Result<()>;
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
///        let msg = try!(self.input.input.recv());
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
///        let _ = self.output.output.send(msg);
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

        use rustfbp::ports::{Msg, MsgSender, MsgReceiver, OutputSend};

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
            pub fn recv_option(&mut self) -> Msg {
                self.try_recv_option();
                if self.option_msg.is_none() {
                    self.option_msg = self.input.option.recv().ok();
                }
                match self.option_msg {
                    Some(ref msg) => msg.clone(),
                    None => unreachable!(),
                }
            }

            pub fn try_recv_option(&mut self) -> Option<Msg> {
                loop {
                    match self.input.option.try_recv() {
                        Err(_) => { break; },
                        Ok(msg) => { self.option_msg = Some(msg); }
                    };
                }
                self.option_msg.as_ref().map(|msg|{ msg.clone() })
            }
            )*

            pub fn send_action(&mut self, output: &str, msg: Msg) -> Result<()> {
                if let Some(sender) = {
                    match output {
                        $($(
                            stringify!($output_a_name) =>  { self.outarr.$output_a_name.get(&msg.action) }
                        )*)*
                            _ => None
                    }
                } // End of the if let Some = { ... }
                {
                    let s: &MsgSender = sender;
                    try!(s.send(msg));
                }
                else {
                    match output {
                        $($(
                            stringify!($output_name) => { self.output.$output_name.send(msg);}
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

            fn connect(&mut self, port: &str, sender: MsgSender) -> Result<()> {
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

            fn connect_array(&mut self, port: &str, element: String, sender: MsgSender) -> Result<()> {
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

            fn add_inarr_element(&mut self, port: &str, element: String, recv: MsgReceiver) -> Result<()> {
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
            option: MsgReceiver,
            acc: MsgReceiver,
            $($(
                $input_name: MsgReceiver,
            )*)*
        }

        pub struct Inarr {
            $($(
                $input_a_name: HashMap<String, MsgReceiver>,
            )*)*
        }

        pub struct Output {
            acc: Option<MsgSender>,
            $($(
                $output_name: Option<MsgSender>,
            )*)*
        }

        pub struct Outarr {
            $($(
                $output_a_name: HashMap<String, MsgSender>
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
            pub option_msg: Option<Msg>,
            sched: Sender<CompMsg>,
            $(
            pub portal: $portal_type ,
            )*
        }

        #[allow(dead_code)]
        pub fn new(name: String, sched: Sender<CompMsg>) -> Result<(Box<Agent + Send>, HashMap<String, MsgSender>)> {

            let mut senders: HashMap<String, MsgSender> = HashMap::new();
            let option = MsgReceiver::new(name.clone(), sched.clone(), false);
            senders.insert("option".to_string(), option.1);
            let acc = MsgReceiver::new(name.clone(), sched.clone(), false);
            senders.insert("acc".to_string(), acc.1.clone());
            $($(
                let $input_name = MsgReceiver::new(name.clone(), sched.clone(), true);
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
                option_msg: None,
                sched: sched,
                $(
                    portal: $portal_value,
                )*
            };

            Ok((Box::new(agent) as Box<Agent + Send>, senders))
        }

        #[no_mangle]
        pub extern fn create_agent(name: String, sched: Sender<CompMsg>) -> Result<(Box<Agent + Send>, HashMap<String, MsgSender>)> {
            new(name, sched)
        }

        #[no_mangle]
        pub extern fn get_schema_input(port: &str) -> Result<String> {
            match port {
                $($(
                    stringify!($input_name)=> Ok(stringify!($input_contract).into()),
                )*)*
                $(
                    "option" => Ok(stringify!($option).into()),
                )*
                $(
                    "acc" => Ok(stringify!($acc).into()),
                )*
                _ => { Err(result::Error::PortDontExist(port.into())) }
            }
        }

        #[no_mangle]
        pub extern fn get_schema_input_array(port: &str) -> Result<String> {
            match port {
                $($(
                    stringify!($input_a_name) => Ok(stringify!($input_a_contract).into()),
                )*)*
                _ => { Err(result::Error::PortDontExist(port.into())) }
            }
        }

        #[no_mangle]
        pub extern fn get_schema_output(port: &str) -> Result<String> {
            match port {
                $($(
                    stringify!($output_name)=> Ok(stringify!($output_contract).into()),
                )*)*
                _ => { Err(result::Error::PortDontExist(port.into())) }
            }
        }

        #[no_mangle]
        pub extern fn get_schema_output_array(port: &str) -> Result<String> {
            match port {
                $($(
                    stringify!($output_a_name) => Ok(stringify!($output_a_contract).into()),
                )*)*
                _ => { Err(result::Error::PortDontExist(port.into())) }
            }
        }
    }
}
