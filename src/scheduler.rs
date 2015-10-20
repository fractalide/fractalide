use component::{Component, InputSenders, InputArraySenders, CountSender, downcast};
use subnet::{SubNet, Graph};
use std::collections::HashMap;
use std::sync::mpsc::{Sender, SyncSender};
use std::sync::mpsc::channel;
use std::thread;

use std::any::Any;
use std::mem;
use std::marker::Reflect;

/// All the messages that can be send between the "exterior scheduler" and the "interior scheduler". 
pub enum CompMsg {
    /// Add a new component. The String is the name, the BoxedComp is the component itself
    NewComponent(String, BoxedComp),
    /// Ask the scheduler to start the component named "String"
    Start(String),
    /// Tell the scheduler that the component "BoxedComp" name "String" end his run
    RunEnd(String, BoxedComp),
    /// Tell to add a selection to an input array port
    AddInputArraySelection(String, String, String, Box<Any + Send + 'static>),
    /// Tell to ad a selection to an output array port
    AddOutputArraySelection(String, String, String),
    /// Connect an Output port
    ConnectOutputPort(String, String, Box<Any + Send + 'static>, String, Sender<CompMsg>),
    /// Connect an Output array port
    ConnectOutputArrayPort(String, String, String, Box<Any + Send + 'static>, String, Sender<CompMsg>),
}

/// Retains each component information for the "exterior scheduler"
pub struct Comp {
    input_senders: Box<InputSenders>,
    input_array_senders: Box<InputArraySenders>,
}

/// Represent a component in a Box 
pub type BoxedComp = Box<Component + Send + 'static>;

/// the exterior scheduler. The end user use the methods of this structure.
pub struct Scheduler {
    /// Will be private, public for debug
    pub components: HashMap<String, Comp>,
    sender: Sender<CompMsg>,
    /// Used by the subnets
    pub subnet_input_names: HashMap<String, (String, String)>,
    /// Used by the subnets
    pub subnet_output_names: HashMap<String, (String, String)>,
    /// Used by the subnets
    pub subnet_start: HashMap<String, Vec<String>>,
}

impl Scheduler {
    pub fn new() -> Self {
        let (s, r) = channel();
        let mut sched_s = SchedState::new(s.clone());
        thread::spawn(move || {
            loop {
                let msg = r.recv().unwrap();
                match msg {
                    CompMsg::NewComponent(name, comp) => { sched_s.new_component(name, comp); },
                    CompMsg::Start(name) => { sched_s.start(name); },
                    CompMsg::RunEnd(name, boxed_comp) => { sched_s.run_end(name, boxed_comp); },
                    CompMsg::AddInputArraySelection(name, port, selection, recv) => { 
                        sched_s.edit_component(name, EditCmp::AddInputArraySelection(port, selection, recv)); 
                    },
                    CompMsg::AddOutputArraySelection(name, port, selection) => { 
                        sched_s.edit_component(name, EditCmp::AddOutputArraySelection(port, selection)); 
                    },
                    CompMsg::ConnectOutputPort(name, port, send, dest, sched) => { 
                        sched_s.edit_component(name, EditCmp::ConnectOutputPort(port, send, dest, sched)); 
                    },
                    CompMsg::ConnectOutputArrayPort(name, port, selection, send, dest, sched) => {
                        sched_s.edit_component(name, EditCmp::ConnectOutputArrayPort(port, selection, send, dest, sched)); 
                    },
                }
            }
        });
            
        Scheduler { 
            components: HashMap::new(), 
            sender: s,
            subnet_input_names: HashMap::new(),
            subnet_output_names: HashMap::new(),
            subnet_start: HashMap::new(),
        }
    }

    pub fn add_component(&mut self, name: String, c: (BoxedComp, Box<InputSenders>, Box<InputArraySenders>)) {
        self.components.insert(name.clone(), Comp {
            input_senders: c.1,
            input_array_senders: c.2,
        });
        self.sender.send(CompMsg::NewComponent(name, c.0)).expect("add_component : unable to send to scheduler state");
    }

    pub fn add_subnet(&mut self, name: String, g: Graph) {
        SubNet::new(g, name, self);
    }

    pub fn start(&self, name: String) {
        match self.subnet_start.get(&name) {
            None => { self.sender.send(CompMsg::Start(name)).expect("start: unable to send to sched state"); },
            Some(vec) => {
                for n in vec { self.sender.send(CompMsg::Start(n.clone())).expect("start: unable to send to sched state"); }
            },
        }
    }

    pub fn connect(&self, comp_out: String, port_out: String, comp_in: String, port_in: String){
        let (comp_out, port_out) = self.get_subnet_name(comp_out, port_out, VPType::Out);
        let (comp_in, port_in) = self.get_subnet_name(comp_in, port_in, VPType::In);
        let comp = self.components.get(&comp_in).expect("Scheduler connect : the component doesn't exist");
        let s = comp.input_senders.get_sender(port_in.clone()).expect("Scheduler connect : The comp_in doesn't have the port_in port");
        self.sender.send(CompMsg::ConnectOutputPort(comp_out, port_out, s, comp_in, self.sender.clone())).ok().expect("Scheduler connect: unable to send to sched state");
    }

    pub fn connect_array(&self, comp_out: String, port_out: String, selection_out: String, comp_in: String, port_in: String){
        let (comp_out, port_out) = self.get_subnet_name(comp_out, port_out, VPType::Out);
        let (comp_in, port_in) = self.get_subnet_name(comp_in, port_in, VPType::In);
        let comp = self.components.get(&comp_in).expect("Scheduler connect : the component doesn't exist");
        let s = comp.input_senders.get_sender(port_in.clone()).expect("Scheduler connect : The comp_in doesn't have the port_in port");
        self.sender.send(CompMsg::ConnectOutputArrayPort(comp_out, port_out, selection_out, s, comp_in, self.sender.clone())).ok().expect("Scheduler connect: unable to send to scheduler state");
    }

    pub fn connect_to_array(&self, comp_out: String, port_out: String, comp_in: String, port_in: String, selection_in: String){
        let (comp_out, port_out) = self.get_subnet_name(comp_out, port_out, VPType::Out);
        let (comp_in, port_in) = self.get_subnet_name(comp_in, port_in, VPType::In);
        let comp = self.components.get(&comp_in).expect("Scheduler connect : the component doesn't exist");
        let s = comp.input_array_senders.get_selection_sender(port_in.clone(), selection_in.clone()).expect("Scheduler connect : The comp_in doesn't have the selection_in selection of the port_in port");
        self.sender.send(CompMsg::ConnectOutputPort(comp_out, port_out, s, comp_in, self.sender.clone())).ok().expect("Scheduler connect: unable to send to scheduler state");
    }

    pub fn connect_array_to_array(&self, comp_out: String, port_out: String, selection_out: String, comp_in: String, port_in: String, selection_in: String){
        let (comp_out, port_out) = self.get_subnet_name(comp_out, port_out, VPType::Out);
        let (comp_in, port_in) = self.get_subnet_name(comp_in, port_in, VPType::In);
        let comp = self.components.get(&comp_in).expect("Scheduler connect : the component doesn't exist");
        let s = comp.input_array_senders.get_selection_sender(port_in.clone(), selection_in.clone()).expect("Scheduler connect : The comp_in doesn't have the selection_in selection of the port_in port");
        self.sender.send(CompMsg::ConnectOutputArrayPort(comp_out, port_out, selection_out, s, comp_in, self.sender.clone())).ok().expect("Scheduler connect: unable to send to scheduler state");
    }

    pub fn add_input_array_selection(&mut self, comp: String, port: String, selection: String) {
        let (comp, port) = self.get_subnet_name(comp, port, VPType::In);
        let mut comp_in = self.components.get_mut(&comp).expect("Scheduler add_input_array_selection : the component doesn't exist");
        if comp_in.input_array_senders.get_selection_sender(port.clone(), selection.clone()).is_some() { return; }
        let (s, r) = comp_in.input_array_senders.get_sender_receiver(port.clone()).expect("Scheduler add_input_array_selection : The port doesn't exist");
        comp_in.input_array_senders.add_selection_sender(port.clone(), selection.clone(), s);
        self.sender.send(CompMsg::AddInputArraySelection(comp, port, selection, r)).ok().expect("Scheduler add_input_array_selection : Unable to send to scheduler state");
    }

    pub fn add_output_array_selection(&self, comp: String, port: String, selection: String) {
        let (comp, port) = self.get_subnet_name(comp, port, VPType::Out);
        self.sender.send(CompMsg::AddOutputArraySelection(comp, port, selection)).ok().expect("Scheduler add_output_array_selection : Unable to send to scheduler state");
    }

    pub fn get_sender<T: Any + Send + Sized + Reflect>(&self, comp: String, port: String) -> CountSender<T> {
        let (comp, port) = self.get_subnet_name(comp, port, VPType::In);
        let r_comp = self.components.get(&comp).expect("Scheduler get_sender : the component doesn't exist");
        let sender = r_comp.input_senders.get_sender(port.clone()).expect("Scheduler connect : The comp_in doesn't have the port_in port");
        let mut sender: CountSender<T> = downcast(sender);
        sender.set_sched(comp, self.sender.clone());
        sender
    }

    pub fn get_option<T: Any + Send + Sized + Reflect>(&self, comp: String) -> SyncSender<T> {
        let (comp, port) = self.get_subnet_name(comp, "option".to_string(), VPType::In);
        let r_comp = self.components.get(&comp).expect("Scheduler get_option : the component doesn't exist");
        let sender = r_comp.input_senders.get_sender(port.clone()).expect("Scheduler get_option : The comp_in doesn't have the port_in port");
        let s: SyncSender<T> = downcast(sender);
        s
    }

    pub fn get_acc<T: Any + Send + Sized + Reflect>(&self, comp: String) -> SyncSender<T> {
        let (comp, port) = self.get_subnet_name(comp, "acc".to_string(), VPType::In);
        let r_comp = self.components.get(&comp).expect("Scheduler get_acc : the component doesn't exist");
        let sender = r_comp.input_senders.get_sender(port.clone()).expect("Scheduler get_acc : The comp_in doesn't have the port_in port");
        let s: SyncSender<T> = downcast(sender);
        s
    }

    pub fn get_array_sender<T: Any + Send + Sized + Reflect>(&self, comp: String, port: String, selection: String) -> CountSender<T> {
        let (comp, port) = self.get_subnet_name(comp, port, VPType::In);
        let r_comp = self.components.get(&comp).expect("Scheduler get_sender : the component doesn't exist");
        let sender = r_comp.input_array_senders.get_selection_sender(port, selection).expect("Scheduler connect : The comp_in doesn't have the port_in port");
        let mut sender: CountSender<T> = downcast(sender);
        sender.set_sched(comp, self.sender.clone());
        sender
    }

    fn get_subnet_name(&self, comp: String, port: String, vp_type: VPType) -> (String, String) {
        let concat = comp.clone() + &port;
        let real_name = match vp_type {
            VPType::In => { self.subnet_input_names.get(&concat) },
            VPType::Out => { self.subnet_output_names.get(&concat) },
        };
        if let Some(&(ref c, ref p)) = real_name {
            self.get_subnet_name(c.clone(), p.clone(), vp_type)
        } else {
            (comp, port)
        }
    }
}

enum VPType {
    In, Out
}

enum EditCmp {
    AddInputArraySelection(String, String, Box<Any + Send + 'static>),
    AddOutputArraySelection(String, String),
    ConnectOutputPort(String, Box<Any + Send + 'static>, String, Sender<CompMsg>),
    ConnectOutputArrayPort(String, String, Box<Any + Send + 'static>, String, Sender<CompMsg>),
}

struct CompState {
    comp: Option<BoxedComp>,
    can_run: bool,
    edit_msgs: Vec<EditCmp>,
    connections: usize, // TODO : graceful shutdown
}

struct SchedState {
    sched_sender: Sender<CompMsg>,
    components: HashMap<String, CompState>,
}

impl SchedState {
    fn new(s: Sender<CompMsg>) -> Self {
        SchedState {
            sched_sender: s,
            components: HashMap::new(),
        }
    }

    fn new_component(&mut self, name: String, comp: BoxedComp) {
        self.components.insert(name, CompState { 
            comp: Some(comp), 
            can_run: false, 
            edit_msgs: vec![],
            connections: 0,
        });
    }

    fn start(&mut self, name: String) {
        // println!("Start {}", name);
        let start = {
            let mut comp = self.components.get_mut(&name).expect("SchedState start : component not found");
            comp.can_run = true;
            comp.comp.is_some()
        };
        if start {
            self.run(name);
        } 
    }

    fn run_end(&mut self, name: String, box_comp: BoxedComp) {
        let must_restart = {
            let mut comp = self.components.get_mut(&name).expect("SchedState RunEnd : component doesn't exist");
            let must_restart = box_comp.is_ips();
            comp.comp = Some(box_comp);
            must_restart
        };
        if must_restart {
            self.run(name);
        }
    }

    fn run(&mut self, name: String) {
        let mut o_comp = self.components.get_mut(&name).expect("SchedSate run : component doesn't exist");
        let mut b_comp = mem::replace(&mut o_comp.comp, None).expect("SchedState run : cannot run if already running");
        let sched_s = self.sched_sender.clone();
        thread::spawn(move || {
            b_comp.run();
            sched_s.send(CompMsg::RunEnd(name, b_comp)).expect("SchedState run : unable to send RunEnd");
        });
    }

    fn edit_component(&mut self, name: String, msg: EditCmp){
        let mut comp = self.components.get_mut(&name).expect("SchedState edit_component : component doesn't exist");
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

