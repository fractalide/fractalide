//! This crate helps to create a Fractalide agent
//!
//! It provides the macro `agent` which takes the high level view of the agent, and creates the code for the scheduler.
//!
//! It also declare the Trait Agent and the shared methods needed by every agent and the scheduler.


extern crate capnp;

// TODO : Add method to remove agents
use ports::{MsgSender, MsgReceiver};
use scheduler::Signal;
use result::Result;
use std::any::Any;
use std;
use edges;

use edges::Msg;

/// Provide the generic functions of agents
///
/// These three functions are used by the scheduler
pub trait Agent {
    /// Return true if there is at least one input port
    fn is_input_ports(&self) -> bool;
    /// Connect output port
    fn connect(&mut self, port: &str, sender: MsgSender<Msg>) -> Result<()>;
    /// Connect array output port
    fn connect_array(&mut self, port: &str, element: String, sender: MsgSender<Msg>) -> Result<()>;
    /// Add input element
    fn add_inarr_element(&mut self, port: &str, element: String, recv: MsgReceiver<Msg>) -> Result<()>;
    /// Run the method of the agent, his personal logic
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
///    option(prim_text),
///    fn run(&mut self) -> Result<Signal> {
///        // Receive an IP
///        let msg = try!(self.input.input.recv());
///
///        // Received an IP from the option port (a prim_text)
///        let opt = self.recv_opt();
///
///        // Get the capn'p reader
///        let reader: prim_text::Reader = try!(opt.read_schema());
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
        $( state( $state_type:ty => $state_value:expr ), )*
        $( option($option:ident), )*
        $( accumulator($accumulator:ident ), )*
        fn run(&mut $arg:ident) -> Result<Signal> $fun:block
    )
        =>
    {
        use rustfbp::agent::Agent;
        use rustfbp::edges::Msg;

        use rustfbp::result;
        use rustfbp::result::Result;
        use rustfbp::scheduler::{CompMsg, Signal};
        use std::error::Error;

        use std::sync::mpsc::{Sender};
        use std::sync::mpsc::channel;

        use rustfbp::ports::{MsgSender, MsgSenderInto, MsgReceiver, MsgReceiverFrom, OutputSend};

        #[allow(unused_imports)]
        use std::collections::HashMap;

        use capnp::serialize;
        use capnp::message;

        use std::io::{Read, Write};
        use std::any::Any;

        use rustfbp::scheduler::Signal::*;

        mod edge_capnp {
                include!("edge_capnp.rs");
        }
        use edge_capnp::*;
        use rustfbp::edges;
        use std::marker::PhantomData;

        impl ThisAgent {
            $(

            pub fn recv_option(&mut self) -> $option {
                self.try_recv_option();
                if self.option_msg.is_none() {
                    self.option_msg = self.input.option.recv().ok();
                }
                match self.option_msg {
                    Some(ref msg) => msg.clone(),
                    None => unreachable!(),
                }
            }

            pub fn try_recv_option(&mut self) -> Option<$option> {
                loop {
                    match self.input.option.try_recv() {
                        Err(_) => { break; },
                        Ok(msg) => { self.option_msg = Some(msg); }
                    };
                }
                self.option_msg.as_ref().map(|msg|{ msg.clone() })
            }
            )*

        }

        impl Agent for ThisAgent where $($(Msg: Into<$input_contract>),*)* {

            fn is_input_ports(&self) -> bool {
                $($(
                    if true || stringify!($input_name) == "" { return true; }
                )*)*
                $($(
                    if true || stringify!($input_a_name) == "" { return true; }
                )*)*
                false
            }

            fn connect(&mut self, port: &str, sender: MsgSender<Msg>) -> Result<()> {
                match port {
                    $($(
                        stringify!($output_name) => {
                            self.output.$output_name = Some(sender); // MsgSenderInto { s: sender, i: PhantomData });
                        }
                    )*)*
                        _ => {
                            return Err(result::Error::PortDontExist(port.into()));
                        }
                }
                Ok(())
            }

            fn connect_array(&mut self, port: &str, element: String, sender: MsgSender<Msg>) -> Result<()> {
                match port {
                    $($(
                        stringify!($output_a_name) => {
                            self.outarr.$output_a_name.insert(element, sender); // MsgSenderInto { s: sender, i: PhantomData });
                        }
                    )*)*
                        _ => {
                            return Err(result::Error::PortDontExist(port.into()));
                        }
                }
                Ok(())
            }

            fn add_inarr_element(&mut self, port: &str, element: String, recv: MsgReceiver<Msg>) -> Result<()> {
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
            $($(
                $input_name: MsgReceiverFrom<Msg, $input_contract>,
            )*)*
                option: MsgReceiver<Msg>,
                accumulator: MsgReceiver<Msg>,
        }

        pub struct Inarr {
            $($(
                $input_a_name: HashMap<String, MsgReceiver<Msg>>, // MsgReceiverFrom<Msg, $input_a_contract>>,
            )*)*
                marker: std::marker::PhantomData<(Msg)>
        }

        pub struct Outarr {
            $($(
                $output_a_name: HashMap<String, MsgSender<Msg>>, // MsgSenderInto<Msg, $output_a_contract>>,
            )*)*
                marker: std::marker::PhantomData<(Msg)>
        }

        pub struct Output {
            $($(
                $output_name: Option<MsgSender<Msg>>, // Option<MsgSenderInto<Msg, $output_contract>>,
            )*)*
                accumulator: Option<MsgSender<Msg>>,
        }


        /* Global agent */

        #[allow(dead_code)]
        #[allow(non_camel_case_types)]
        pub struct ThisAgent {
            id: usize,
            pub input: Input,
            pub output: Output,
            pub inarr: Inarr,
            pub outarr: Outarr,
            pub option_msg: Option<Msg>,
            sched: Sender<CompMsg<Msg>>,
            $(
            pub state: $state_type ,
            )*
        }

        #[allow(dead_code)]
        pub fn new(id: usize, sched: Sender<CompMsg<Msg>>) -> Result<(Box<Agent>, HashMap<String, MsgSender<Msg>>)> {
            let mut senders: HashMap<String, MsgSender<Msg>> = HashMap::new();
            let option = MsgReceiver::<Msg>::new(id, sched.clone(), false);
            senders.insert("option".to_string(), option.1);

            let accumulator = MsgReceiver::<Msg>::new(id, sched.clone(), false);
            senders.insert("accumulator".to_string(), accumulator.1.clone());

            $($(
                let $input_name = MsgReceiver::<Msg>::new(id, sched.clone(), true);
                senders.insert(stringify!($input_name).to_string(), $input_name.1);
            )*)*

            let input = Input {
                $($(
                    $input_name: MsgReceiverFrom { r: $input_name.0, i: PhantomData },
                )*)*
                    option: option.0 as MsgReceiver::<Msg>,
                    accumulator: accumulator.0 as MsgReceiver::<Msg>,
            };
            let output = Output {
                $($(
                    $output_name: None,
                )*)*
                    accumulator: Some(accumulator.1) as Option<MsgSender::<Msg>>,
            };
            let inarr = Inarr {
                $($(
                    $input_a_name: HashMap::new(),
                )*)*
                    marker: std::marker::PhantomData,
            };
            let outarr = Outarr {
                $($(
                    $output_a_name: HashMap::new(),
                )*)*
                    marker: std::marker::PhantomData,
            };

            let agent= ThisAgent {
                id: id,
                input: input,
                output: output,
                inarr: inarr,
                outarr: outarr,
                option_msg: None as Option<Msg>,
                sched: sched,
                $(
                    state: $state_value,
                )*
            };

            Ok((Box::new(agent), senders))
        }

        #[no_mangle]
        pub extern fn create_agent(id: usize, sched: Sender<CompMsg<Msg>>) -> Result<(Box<Agent>, HashMap<String, MsgSender<Msg>>)> {
            new(id, sched)
        }

        #[no_mangle]
        pub extern fn clone_input(port: &str, sender: &MsgSender<Msg>) -> Result<MsgSender<Msg>> {
            match port {
                $($(
                    stringify!($input_name) => {
                        Ok(sender.clone())
                    },
                )*)*
                    $(
                        "option" => {
                            let x: $option = unsafe { std::mem::uninitialized() };
                            Ok(sender.clone())
                        }
                    )*
                    $(
                        "accumulator" => {
                            let x: $accumulator = unsafe { std::mem::uninitialized() };
                            Ok(sender.clone())
                        }
                    )*
                    _ => { Err(result::Error::PortDontExist(port.into())) }
            }
        }

        #[no_mangle]
        pub extern fn clone_input_array(port: &str, sender: &MsgSender<Msg>) -> Result<MsgSender<Msg>> {
            match port {
                $($(
                    stringify!($input_a_name) => {
                        Ok(sender.clone())
                    },
                )*)*
                    _ => { Err(result::Error::PortDontExist(port.into())) }
            }
        }

        #[no_mangle]
        pub extern fn create_input_array(port: &str, id: usize, sched: Sender<CompMsg<Msg>>, must_sched: bool ) -> Result<(MsgReceiver<Msg>, MsgSender<Msg>)> {
            match port {
                $($(
                    stringify!($input_a_name) => {
                        let (r, s): (MsgReceiver::<Msg>, MsgSender::<Msg>) = MsgReceiver::new(id, sched, must_sched);
                        Ok((r, s))
                    },
                )*)*
                    _ => { Err(result::Error::PortDontExist(port.into())) }
            }
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
                    "accumulator" => Ok(stringify!($accumulator).into()),
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

#[macro_export]
macro_rules! send_action {
    ($agent: ident, $port:ident, $msg:ident) => {{
        if let Some(sender) = $agent.outarr.$port.get(&$msg.action) {
            sender.send($msg)
        } else {
            $agent.output.$port.send($msg)
        }
    }}
}
