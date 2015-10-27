use component::{Component, InputSenders, InputArraySenders, CountSender, downcast};
use subnet::{SubNet, Graph};
use std::collections::HashMap;
use std::sync::mpsc::{Sender, SyncSender};
use std::sync::mpsc::channel;
use std::thread;
use std::thread::JoinHandle;

use std::any::Any;
use std::mem;
use std::marker::Reflect;

/// All the messages that can be send between the "exterior scheduler" and the "interior scheduler". 
pub enum CompMsg {
    /// Add a new component. The String is the name, the BoxedComp is the component itself
    NewComponent(String, BoxedComp),
    /// Ask the scheduler to start the component named "String"
    Start(String),
    /// Stop the scheduler
    Halt, HaltState,
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
    /// Disconnect
    Disconnect(String, String),
    DisconnectArray(String, String, String),
    /// Remove
    Remove(String, Sender<SyncMsg>),
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
    pub subnets: HashMap<String, SubNet>,
    sender: Sender<CompMsg>,
    th: JoinHandle<()>,
}

impl Scheduler {
    pub fn new() -> Self {
        let (s, r) = channel();
        let mut sched_s = SchedState::new(s.clone());
        let th = thread::spawn(move || {
            loop {
                let msg = r.recv().unwrap();
                match msg {
                    CompMsg::NewComponent(name, comp) => { sched_s.new_component(name, comp); },
                    CompMsg::Start(name) => { sched_s.start(name); },
                    CompMsg::Halt => { break; },
                    CompMsg::HaltState => { sched_s.halt(); },
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
                    CompMsg::Disconnect(name, port) => {
                        sched_s.edit_component(name, EditCmp::Disconnect(port));
                    },
                    CompMsg::DisconnectArray(name, port, selection) => {
                        sched_s.edit_component(name, EditCmp::DisconnectArray(port, selection));
                    },
                    CompMsg::Remove(name, sync_sender) => {
                        sched_s.remove(name, sync_sender);
                    }
                }
            }
        });
            
        Scheduler { 
            components: HashMap::new(), 
            subnets: HashMap::new(),
            sender: s,
            th: th,
        }
    }

    pub fn add_component(&mut self, name: String, c: (BoxedComp, Box<InputSenders>, Box<InputArraySenders>)) {
        self.components.insert(name.clone(), Comp {
            input_senders: c.1,
            input_array_senders: c.2,
        });
        self.sender.send(CompMsg::NewComponent(name, c.0)).expect("add_component : unable to send to scheduler state");
    }

    pub fn add_subnet(&mut self, name: String, g: &Graph) {
        SubNet::new(g, name, self);
    }

    pub fn start(&self, name: String) {
        match self.subnets.get(&name) {
            None => { self.sender.send(CompMsg::Start(name)).expect("start: unable to send to sched state"); },
            Some(sn) => {
                for n in &sn.start { self.sender.send(CompMsg::Start(n.clone())).expect("start: unable to send to sched state"); }
            },
        }
    }

    pub fn remove_component(&mut self, name: String) -> Result<HashMap<String, (BoxedComp, Box<InputSenders>, Box<InputArraySenders>)>, ()>{
        let (s, r) = channel(); 
        self.sender.send(CompMsg::Remove(name.clone(), s)).expect("Scheduler remove_component: cannot send to the state"); 
        let response = r.recv().unwrap();//expect("Scheduler remove_component: cannot receive from the state");
        match response {
            SyncMsg::Remove(boxed_comp) => {
                let comp = self.components.remove(&name).expect("Scheduler remove_component: the component doesn't exist");
                let mut h = HashMap::new();
                h.insert(name, (boxed_comp, comp.input_senders, comp.input_array_senders));
                Ok(h)
            },
            SyncMsg::CannotRemove => {
                Err(())
            },
        }

    }
    
    pub fn remove_subnet(&mut self, name: String) -> Result<HashMap<String, (BoxedComp, Box<InputSenders>, Box<InputArraySenders>)>, ()> {
        let mut res = HashMap::new();
        let children = {
            let sn = self.subnets.get(&name).expect("the component doesnt exist");
            sn.children.clone()
        };
        for name in children {
            let child = self.remove_component(name.clone());
            if let Ok(child) = child {
                for (key, value) in child.into_iter() {
                    res.insert(key, value);
                }
            } else {
                // TODO Reput already removed component
                for (k, v) in res.into_iter() {
                    self.components.insert(k.clone(), Comp {
                        input_senders: v.1,
                        input_array_senders: v.2,
                    });
                    self.sender.send(CompMsg::NewComponent(k, v.0)).expect("remove_subnet : cannot send to the state");
                }
                return Err(());
            }
        }
        self.subnets.remove(&name);
        Ok(res)
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

    pub fn disconnect(&self, comp_out: String, port_out: String) {
        let (comp_out, port_out) = self.get_subnet_name(comp_out, port_out, VPType::Out);
        self.sender.send(CompMsg::Disconnect(comp_out, port_out)).ok().expect("Scheduler disconnect: unable to send to scheduler state");
    }

    pub fn disconnect_array(&self, comp_out: String, port_out: String, selection:String) {
        let (comp_out, port_out) = self.get_subnet_name(comp_out, port_out, VPType::Out);
        self.sender.send(CompMsg::DisconnectArray(comp_out, port_out, selection)).ok().expect("Scheduler disconnect_array: unable to send to scheduler state");
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
        let option_main = self.subnets.get(&comp);
        let main = match option_main {
            None => { 
                return (comp, port); 
            },
            Some(m) => { m },
        };
        let real_name = match vp_type {
            VPType::In => { main.input_names.get(&port) },
            VPType::Out => { main.output_names.get(&port) },
        };
        if let Some(&(ref c, ref p)) = real_name {
            (c.clone(), p.clone())
        } else {
            (comp, port)
        }
    }

    pub fn join(self) {
        self.sender.send(CompMsg::HaltState).ok().expect("Scheduler join : Cannot send HaltState");
        self.th.join().ok().expect("Scheduelr join : Cannot join the thread");
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
    Disconnect(String),
    DisconnectArray(String, String),
}

pub enum SyncMsg {
    Remove(BoxedComp),
    CannotRemove,
}

struct CompState {
    comp: Option<BoxedComp>,
    can_run: bool,
    edit_msgs: Vec<EditCmp>,
}

struct SchedState {
    sched_sender: Sender<CompMsg>,
    components: HashMap<String, CompState>,
    connections: usize,
    can_halt: bool,
}

impl SchedState {
    fn new(s: Sender<CompMsg>) -> Self {
        SchedState {
            sched_sender: s,
            components: HashMap::new(),
            connections: 0,
            can_halt: false,
        }
    }

    fn new_component(&mut self, name: String, comp: BoxedComp) {
        self.components.insert(name, CompState { 
            comp: Some(comp), 
            can_run: false, 
            edit_msgs: vec![],
        });
    }

    fn remove(&mut self, name: String, sync_sender: Sender<SyncMsg>) {
        let must_remove = {
            let mut o_comp = self.components.get_mut(&name).expect("SchedState remove : component doesn't exist");
            let b_comp = mem::replace(&mut o_comp.comp, None);
            if let Some(boxed_comp) = b_comp {
                sync_sender.send(SyncMsg::Remove(boxed_comp)).expect("SchedState remove : cannot send to the channel");
                true
            } else {
                sync_sender.send(SyncMsg::CannotRemove).expect("SchedState remove : cannot send to the channel");
                false
            }
        };
        if must_remove { self.components.remove(&name); }
    }

    fn start(&mut self, name: String) {
        let start = {
            let mut comp = self.components.get_mut(&name).expect("SchedState start : component not found");
            comp.can_run = true;
            comp.comp.is_some()
        };
        if start {
            self.connections += 1;
            self.run(name);
        } 
    }

    fn halt(&mut self) {
        self.can_halt = true;
        if self.connections <= 0 {
            self.sched_sender.send(CompMsg::Halt).ok().expect("SchedState RunEnd : Cannot send Halt");
        }
    }

    fn run_end(&mut self, name: String, mut box_comp: BoxedComp) {
        let must_restart = {
            let mut comp = self.components.get_mut(&name).expect("SchedState RunEnd : component doesn't exist");
            let vec = mem::replace(&mut comp.edit_msgs, vec![]);
            for msg in vec {
                Self::edit_one_comp(&mut box_comp, msg);
            }
            let must_restart = box_comp.is_ips();
            comp.comp = Some(box_comp);
            must_restart
        };
        if must_restart {
            self.run(name);
        } else {
            self.connections -= 1;
            if self.connections <= 0 && self.can_halt {
                self.sched_sender.send(CompMsg::Halt).ok().expect("SchedState RunEnd : Cannot send Halt");
            }
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
            let mut c = c;
            Self::edit_one_comp(&mut c, msg); 
        } else {
            comp.edit_msgs.push(msg);
        }
    }

    fn edit_one_comp(c: &mut BoxedComp, msg: EditCmp) {
        match msg {
            EditCmp::AddInputArraySelection(port, selection, recv) => {
                    c.add_selection_receiver(port, selection, recv);
            },
            EditCmp::AddOutputArraySelection(port, selection) => {
                    c.add_output_selection(port, selection);
            },
            EditCmp::ConnectOutputPort(port, send, dest, sched) => {
                    c.connect(port, send, dest, sched);
            },
            EditCmp::ConnectOutputArrayPort(port, selection, send, dest, sched) => {
                    c.connect_array(port, selection, send, dest, sched);
            },
            EditCmp::Disconnect(port) => {
                c.disconnect(port);
            },
            EditCmp::DisconnectArray(port, selection) => {
                c.disconnect_array(port, selection);
            },
        }
    }
}   

