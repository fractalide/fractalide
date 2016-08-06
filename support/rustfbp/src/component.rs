//! This module helps to create a Component
//!
//! It provides a macro `component` which take the high level view of the component, and create the code for the scheduler.
//!
//! It also declare the Trait Component. It's the common methods between all components, needed by the scheduler.


extern crate capnp;
use ports::Ports;
use result::Result;

/// Provide the generic functions of components
///
/// These three functions are used by the scheduler
pub trait Component {
    /// Return a muttable borrow to the Ports object.
    fn get_ports(&mut self) -> &mut Ports;
    /// Return true if there is at least one input port
    fn is_input_ports(&self) -> bool;
    /// Run the method of the component, his personal logic
    fn run(&mut self) -> Result<()>;
}


/// The component macro.
///
/// It helps to define a component, by defining the input and output ports, if there is an option or an acc port, ...
/// 
/// `contracts()` and `portal()` are optional.
/// 
/// Example :
///
/// ```rust,ignore
/// component! {
///    display, contract(generic_text)
///    inputs(input: any),
///    inputs_array(),
///    outputs(output: any),
///    outputs_array(),
///    option(generic_text),
///    acc()
///    fn run(&mut self) -> Result<()> {
///        // Receive an IP
///        let ip = try!(self.ports.recv("input"));
///
///        // Received an IP from the option port (a generic_text)
///        let opt = self.recv_opt();
///
///        // Get the capn'p reader
///        let reader: generic_text::Reader = try!(opt.get_root());
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
                include!(concat!(stringify!($contract), ".rs"));
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
                _ => { Err(result::Error::PortNotFound("unknown".into(), port.into())) }
            }
        }

        #[no_mangle]
        pub extern fn get_contract_input_array(port: &str) -> Result<String> {
            match port {
                $(
                    stringify!($input_array_name) => Ok(stringify!($input_contract_array).into()),
                )*
                _ => { Err(result::Error::PortNotFound("unknown".into(), port.into())) }
            }
        }

        #[no_mangle]
        pub extern fn get_contract_output(port: &str) -> Result<String> {
            match port {
                $(
                    stringify!($output_field_name)=> Ok(stringify!($output_contract_name).into()),
                )*
                _ => { Err(result::Error::PortNotFound("unknown".into(), port.into())) }
            }
        }

        #[no_mangle]
        pub extern fn get_contract_output_array(port: &str) -> Result<String> {
            match port {
                $(
                    stringify!($output_array_name) => Ok(stringify!($output_contract_array).into()),
                )*
                _ => { Err(result::Error::PortNotFound("unknown".into(), port.into())) }
            }
        }
    }
}
