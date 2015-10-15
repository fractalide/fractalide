use component::{Component, InputSenders, InputArraySenders};
use std::collections::HashMap;
use std::sync::mpsc::{Sender, Receiver};
use std::sync::mpsc::channel;
use std::thread;

use std::any::Any;
use std::mem;

pub type Sstr = &'static str;

pub enum CompMsg {
    NewComponent(Sstr, BoxedComp),
    Start(Sstr),
    RunEnd(Sstr, BoxedComp),
    AddInputArraySelection(Sstr, Sstr, Sstr, Box<Any + Send + 'static>),
    AddOutputArraySelection(Sstr, Sstr, Sstr),
    ConnectOutputPort(Sstr, Sstr, Box<Any + Send + 'static>, Sstr, Sender<CompMsg>),
    ConnectOutputArrayPort(Sstr, Sstr, Sstr, Box<Any + Send + 'static>, Sstr, Sender<CompMsg>),
}

struct Comp {
    input_senders: Box<InputSenders>,
    input_array_senders: Box<InputArraySenders>,
}

/// Represent a component in a Box 
pub type BoxedComp = Box<Component + Send + 'static>;

pub struct FVM {
    components: HashMap<Sstr, Comp>,
    sender: Sender<CompMsg>,
}

impl FVM {
    pub fn new() -> Self {
        let (s, r) = channel();
        let mut FVMS = FVMState::new(s.clone());
        thread::spawn(move || {
            loop {
                let msg = r.recv().unwrap();
                match msg {
                    CompMsg::NewComponent(name, comp) => { FVMS.new_component(name, comp); },
                    CompMsg::Start(name) => { FVMS.start(name); },
                    CompMsg::RunEnd(name, BoxedComp) => { FVMS.run_end(name, BoxedComp); },
                    CompMsg::AddInputArraySelection(name, port, selection, recv) => { 
                        FVMS.edit_component(name, EditCmp::AddInputArraySelection(port, selection, recv)); 
                    },
                    CompMsg::AddOutputArraySelection(name, port, selection) => { 
                        FVMS.edit_component(name, EditCmp::AddOutputArraySelection(port, selection)); 
                    },
                    CompMsg::ConnectOutputPort(name, port, send, dest, sched) => { 
                        FVMS.edit_component(name, EditCmp::ConnectOutputPort(port, send, dest, sched)); 
                    },
                    CompMsg::ConnectOutputArrayPort(name, port, selection, send, dest, sched) => {
                        FVMS.edit_component(name, EditCmp::ConnectOutputArrayPort(port, selection, send, dest, sched)); 
                    },
                }
            }
        });
            
        FVM { components: HashMap::new(), sender: s, }
    }

    pub fn add_component(&mut self, name: Sstr, c: (BoxedComp, Box<InputSenders>, Box<InputArraySenders>)) {
        self.components.insert(name.clone(), Comp {
            input_senders: c.1,
            input_array_senders: c.2,
        });
        self.sender.send(CompMsg::NewComponent(name, c.0)).expect("add_component : unable to send to fvm state");
    }

    pub fn start(&self, name: Sstr) {
        self.sender.send(CompMsg::Start(name)).expect("start: unable to send to fvm state");
    }

    pub fn connect(&self, comp_out: Sstr, port_out: Sstr, comp_in: Sstr, port_in: Sstr){
        let comp = self.components.get(comp_in).expect("FVM connect : the component doesn't exist");
        let s = comp.input_senders.get_sender(port_in).expect("FVM connect : The comp_in doesn't have the port_in port");
        self.sender.send(CompMsg::ConnectOutputPort(comp_out, port_out, s, comp_in, self.sender.clone())).ok().expect("FVM connect: unable to send to fvm state");
    }

    pub fn connect_array(&self, comp_out: Sstr, port_out: Sstr, selection_out: Sstr, comp_in: Sstr, port_in: Sstr){
        let comp = self.components.get(comp_in).expect("FVM connect : the component doesn't exist");
        let s = comp.input_senders.get_sender(port_in).expect("FVM connect : The comp_in doesn't have the port_in port");
        self.sender.send(CompMsg::ConnectOutputArrayPort(comp_out, port_out, selection_out, s, comp_in, self.sender.clone())).ok().expect("FVM connect: unable to send to fvm state");
    }

    pub fn connect_to_array(&self, comp_out: Sstr, port_out: Sstr, comp_in: Sstr, port_in: Sstr, selection_in: Sstr){
        let comp = self.components.get(comp_in).expect("FVM connect : the component doesn't exist");
        let s = comp.input_array_senders.get_selection_sender(port_in, selection_in).expect("FVM connect : The comp_in doesn't have the selection_in selection of the port_in port");
        self.sender.send(CompMsg::ConnectOutputPort(comp_out, port_out, s, comp_in, self.sender.clone())).ok().expect("FVM connect: unable to send to fvm state");
    }

    pub fn connect_array_to_array(&self, comp_out: Sstr, port_out: Sstr, selection_out: Sstr, comp_in: Sstr, port_in: Sstr, selection_in: Sstr){
        let comp = self.components.get(comp_in).expect("FVM connect : the component doesn't exist");
        let s = comp.input_array_senders.get_selection_sender(port_in, selection_in).expect("FVM connect : The comp_in doesn't have the selection_in selection of the port_in port");
        self.sender.send(CompMsg::ConnectOutputArrayPort(comp_out, port_out, selection_out, s, comp_in, self.sender.clone())).ok().expect("FVM connect: unable to send to fvm state");
    }

    pub fn add_input_array_selection(&mut self, comp: Sstr, port: Sstr, selection: Sstr) {
        let mut comp_in = self.components.get_mut(comp).expect("FVM add_input_array_selection : the component doesn't exist");
        let (s, r) = comp_in.input_array_senders.get_sender_receiver(port).expect("FVM add_input_array_selection : The port doesn't exist");
        comp_in.input_array_senders.add_selection_sender(port, selection, s);
        self.sender.send(CompMsg::AddInputArraySelection(comp, port, selection, r)).ok().expect("FVM add_input_array_selection : Unable to send to fvm state");
    }

    pub fn add_output_array_selection(&self, comp: Sstr, port: Sstr, selection: Sstr) {
        self.sender.send(CompMsg::AddOutputArraySelection(comp, port, selection)).ok().expect("FVM add_output_array_selection : Unable to send to fvm state");
    }

    // FOR DEBUG
    pub fn get_sender(&self, comp: Sstr, port: Sstr) -> Box<Any> {
        let comp = self.components.get(comp).expect("FVM get_sender : the component doesn't exist");
        comp.input_senders.get_sender(port).expect("FVM connect : The comp_in doesn't have the port_in port")
    }
    pub fn get_array_sender(&self, comp: Sstr, port: Sstr, selection: Sstr) -> Box<Any> {
        let comp = self.components.get(comp).expect("FVM get_sender : the component doesn't exist");
        comp.input_array_senders.get_selection_sender(port, selection).expect("FVM connect : The comp_in doesn't have the port_in port")
    }
}

enum EditCmp {
    AddInputArraySelection(Sstr, Sstr, Box<Any + Send + 'static>),
    AddOutputArraySelection(Sstr, Sstr),
    ConnectOutputPort(Sstr, Box<Any + Send + 'static>, Sstr, Sender<CompMsg>),
    ConnectOutputArrayPort(Sstr, Sstr, Box<Any + Send + 'static>, Sstr, Sender<CompMsg>),
}

struct CompState {
    comp: Option<BoxedComp>,
    can_run: bool,
    edit_msgs: Vec<EditCmp>,
    connections: usize,
}

struct FVMState {
    fvm_sender: Sender<CompMsg>,
    components: HashMap<Sstr, CompState>,
}

impl FVMState {
    fn new(s: Sender<CompMsg>) -> Self {
        FVMState {
            fvm_sender: s,
            components: HashMap::new(),
        }
    }

    fn new_component(&mut self, name: Sstr, comp: BoxedComp) {
        self.components.insert(name, CompState { 
            comp: Some(comp), 
            can_run: false, 
            edit_msgs: vec![],
            connections: 0,
        });
    }

    fn start(&mut self, name: Sstr) {
        let start = {
            let mut comp = self.components.get_mut(name).expect("FVMState start : component not found");
            comp.can_run = true;
            comp.comp.is_some()
        };
        if start {
            self.run(name);
        }
    }

    fn run_end(&mut self, name: Sstr, box_comp: BoxedComp) {
        let must_restart = {
            let mut comp = self.components.get_mut(name).expect("FVMState RunEnd : component doesn't exist");
            let must_restart = box_comp.is_ips();
            comp.comp = Some(box_comp);
            must_restart
        };
        if must_restart {
            self.run(name);
        }
    }

    fn run(&mut self, name: Sstr) {
        println!("Starting {}", name);
        let mut o_comp = self.components.get_mut(name).expect("FVMSate run : component doesn't exist");
        let mut b_comp = mem::replace(&mut o_comp.comp, None).expect("FVMState run : cannot run if already running");
        let fvm_s = self.fvm_sender.clone();
        thread::spawn(move || {
            b_comp.run();
            fvm_s.send(CompMsg::RunEnd(name, b_comp)).expect("FVMState run : unable to send RunEnd");
        });
    }

    fn edit_component(&mut self, name: Sstr, msg: EditCmp){
        let mut comp = self.components.get_mut(name).expect("FVMState AddInputArraySelection : component doesn't exist");
        if let Some(ref mut c) = comp.comp {
            match msg {
                EditCmp::AddInputArraySelection(port, selection, recv) => {
                        c.add_selection_receiver(port, selection, recv);
                }
                EditCmp::AddOutputArraySelection(port, selection) => {
                        c.add_output_selection(port, selection);
                }
                EditCmp::ConnectOutputPort(port, send, dest, sched) => {
                        c.connect(port, send, dest, sched);
                }
                EditCmp::ConnectOutputArrayPort(port, selection, send, dest, sched) => {
                        c.connect_array(port, selection, send, dest, sched);
                }
            }
        } else {
            comp.edit_msgs.push(msg);
        }

    }
}   

