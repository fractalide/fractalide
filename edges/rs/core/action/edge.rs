use std::any::Any;
use scheduler::{Scheduler};
use std::collections::HashMap;

#[derive(Debug)]
pub enum CoreAction {
        Add(CoreActionAdd),
        Remove(String),
        Connect(CoreActionConnect),
        // TODO need send?
        // Send(CoreActionSend),
        ConnectSender(CoreActionConnectSender),
        Halt,
}

#[derive(Debug)]
pub struct CoreActionAdd {
    pub name: String,
    pub comp: String,
}

#[derive(Debug)]
pub struct CoreActionConnect {
    pub out_comp: String,
    pub out_port: String,
    pub out_elem: Option<String>,
    pub in_comp: String,
    pub in_port: String,
    pub in_elem: String,
}

#[derive(Debug)]
pub struct CoreActionConnectSender {
    pub name: String,
    pub port: String,
    pub elem: String,
    pub output: Box<Any + Send>,
}
