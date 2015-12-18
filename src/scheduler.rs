use loader::{ComponentBuilder, Component};

use result;
use result::Result;

use allocator;
use allocator::{Allocator, HeapIPSender, HeapIPReceiver, HeapSenders};

use subnet::{SubNet, Graph};
use std::collections::HashMap;
use std::sync::mpsc::{Sender, Receiver};
use std::sync::mpsc::channel;
use std::thread;
use std::thread::JoinHandle;

use std::mem;

// TODO : manage "can_run": allow a user to pause a component

/// All the messages that can be send between the "exterior scheduler" and the "interior scheduler". 
pub enum CompMsg {
    /// Add a new component. The String is the name, the BoxedComp is the component itself
    NewComponent(String, Component),
    Halt, HaltState,
    ConnectOutputPort(String, String, Box<HeapIPSender>),
    ConnectOutputArrayPort(String, String, String, Box<HeapIPSender>),
    Disconnect(String, String),
    DisconnectArray(String, String, String),
    AddInputArraySelection(String, String, String, Box<HeapIPReceiver>),
    AddOutputArraySelection(String, String, String),
    RunEnd(String, Component),
    Inc(String),
    Dec(String),
}
    // Remove(String, Sender<SyncMsg>),

/// the exterior scheduler. The end user use the methods of this structure.
pub struct Scheduler {
    pub allocator: Allocator,
    pub inputs: HashMap<String, Box<HeapSenders>>,
    pub inputs_array: HashMap<String, Box<HeapIPSender>>,
    pub subnets: HashMap<String, SubNet>,
    pub sender: Sender<CompMsg>,
    pub error_receiver: Receiver<result::Error>,
    th: JoinHandle<()>,
}

impl Scheduler {
    pub fn new() -> Self {
        let (s, r) = channel();
        let (error_s, error_r) = channel();
        let mut sched_s = SchedState::new(s.clone());
        let th = thread::spawn(move || {
            loop {
                let msg = r.recv().unwrap();
                let res: Result<()> = match msg {
                    CompMsg::NewComponent(name, comp) => { sched_s.new_component(name, comp) },
                    // CompMsg::Start(name) => { sched_s.start(name); },
                    CompMsg::Halt => { break; },
                    CompMsg::HaltState => { sched_s.halt() },
                    CompMsg::RunEnd(name, boxed_comp) => { sched_s.run_end(name, boxed_comp) },
                    CompMsg::AddInputArraySelection(name, port, selection, recv) => {
                        sched_s.edit_component(name, EditCmp::AddInputArraySelection(port, selection, recv))
                    },
                    CompMsg::AddOutputArraySelection(name, port, selection) => {
                        sched_s.edit_component(name, EditCmp::AddOutputArraySelection(port, selection))
                    },
                    CompMsg::ConnectOutputPort(comp_out, port_out, sender) => {
                        sched_s.edit_component(comp_out, EditCmp::ConnectOutputPort(port_out, sender))
                    },
                    CompMsg::ConnectOutputArrayPort(comp_out, port_out, selection_out, sender) => {
                        sched_s.edit_component(comp_out, EditCmp::ConnectOutputArrayPort(port_out, selection_out, sender))
                    },
                    CompMsg::Disconnect(name, port) => {
                        sched_s.edit_component(name, EditCmp::Disconnect(port))
                    },
                    CompMsg::DisconnectArray(name, port, selection) => {
                        sched_s.edit_component(name, EditCmp::DisconnectArray(port, selection))
                    },
                    CompMsg::Inc(dest) => { sched_s.inc(dest) },
                    CompMsg::Dec(dest) => { sched_s.dec(dest) },
                    // CompMsg::Remove(name, sync_sender) => {
                    //     sched_s.remove(name, sync_sender);
                    // }
                };
                res.map_err(|e| { error_s.send(e).expect("cannot send the error"); }).ok();
            }
        });

        Scheduler {
            inputs: HashMap::new(),
            inputs_array: HashMap::new(),
            allocator: Allocator::new(s.clone()),
            subnets: HashMap::new(),
            sender: s,
            error_receiver: error_r,
            th: th,
        }
    }

    pub fn add_component(&mut self, name: String, c: &ComponentBuilder) -> Result<()>{
        let senders = (self.allocator.senders.create)();
        let comp = c.build(&name, &self.allocator, senders);
        let hs = HeapSenders::from_raw(senders);
        let s_acc = try!(hs.get_sender("acc".into()));
        self.inputs.insert(name.clone(), hs);
        self.sender.send(CompMsg::NewComponent(name.clone(), comp)).expect("Cannot send to sched state");
        self.sender.send(CompMsg::ConnectOutputPort(name, "acc".into(), s_acc)).expect("Cannot send to sched state");
        Ok(())
    }

    pub fn add_subnet(&mut self, name: String, g: &Graph) -> Result<()> {
        SubNet::new(g, name, self)
    }

    // pub fn start(&self, name: String) {
    //     match self.subnets.get(&name) {
    //         None => { self.sender.send(CompMsg::Start(name)).expect("start: unable to send to sched state"); },
    //         Some(sn) => {
    //             for n in &sn.start { self.sender.send(CompMsg::Start(n.clone())).expect("start: unable to send to sched state"); }
    //         },
    //     }
    // }

    // pub fn remove_component(&mut self, name: String) -> Result<HashMap<String, (BoxedComp, Box<InputSenders>, Box<InputArraySenders>)>, ()>{
    //     let (s, r) = channel(); 
    //     self.sender.send(CompMsg::Remove(name.clone(), s)).expect("Scheduler remove_component: cannot send to the state"); 
    //     let response = r.recv().unwrap();//expect("Scheduler remove_component: cannot receive from the state");
    //     match response {
    //         SyncMsg::Remove(boxed_comp) => {
    //             let comp = self.components.remove(&name).expect("Scheduler remove_component: the component doesn't exist");
    //             let mut h = HashMap::new();
    //             h.insert(name, (boxed_comp, comp.input_senders, comp.input_array_senders));
    //             Ok(h)
    //         },
    //         SyncMsg::CannotRemove => {
    //             Err(())
    //         },
    //     }

    // }
    // 
    // pub fn remove_subnet(&mut self, name: String) -> Result<HashMap<String, (BoxedComp, Box<InputSenders>, Box<InputArraySenders>)>, ()> {
    //     let mut res = HashMap::new();
    //     let children = {
    //         let sn = self.subnets.get(&name).expect("the component doesnt exist");
    //         sn.children.clone()
    //     };
    //     for name in children {
    //         let child = self.remove_component(name.clone());
    //         if let Ok(child) = child {
    //             for (key, value) in child.into_iter() {
    //                 res.insert(key, value);
    //             }
    //         } else {
    //             // TODO Reput already removed component
    //             for (k, v) in res.into_iter() {
    //                 self.components.insert(k.clone(), Comp {
    //                     input_senders: v.1,
    //                     input_array_senders: v.2,
    //                 });
    //                 self.sender.send(CompMsg::NewComponent(k, v.0)).expect("remove_subnet : cannot send to the state");
    //             }
    //             return Err(());
    //         }
    //     }
    //     self.subnets.remove(&name);
    //     Ok(res)
    // }

    pub fn connect(&self, comp_out: String, port_out: String, comp_in: String, port_in: String) -> Result<()>{
        let (comp_out, port_out) = self.get_subnet_name(comp_out, port_out, VPType::Out);
        let (comp_in, port_in) = self.get_subnet_name(comp_in, port_in, VPType::In);
        let his = try!(self.inputs.get(&comp_in).ok_or(result::Error::ComponentNotFound)
            .and_then(|comp| {
                comp.get_sender(&port_in)
            }));
        self.sender.send(CompMsg::ConnectOutputPort(comp_out, port_out, his)).ok().expect("Scheduler connect: unable to send to sched state");
        Ok(())
    }

    pub fn connect_array(&self, comp_out: String, port_out: String, selection_out: String, comp_in: String, port_in: String) -> Result<()> {
        let (comp_out, port_out) = self.get_subnet_name(comp_out, port_out, VPType::Out);
        let (comp_in, port_in) = self.get_subnet_name(comp_in, port_in, VPType::In);
        let his = try!(self.inputs.get(&comp_in).ok_or(result::Error::ComponentNotFound)
            .and_then(|comp| {
                comp.get_sender(&port_in)
            }));
        self.sender.send(CompMsg::ConnectOutputArrayPort(comp_out, port_out, selection_out, his)).ok().expect("Scheduler connect: unable to send to scheduler state");
        Ok(())
    }

    pub fn connect_to_array(&self, comp_out: String, port_out: String, comp_in: String, port_in: String, selection_in: String) -> Result<()>{
        let (comp_out, port_out) = self.get_subnet_name(comp_out, port_out, VPType::Out);
        let (comp_in, port_in) = self.get_subnet_name(comp_in, port_in, VPType::In);
        let his = try!(self.inputs_array.get(&format!("{}-{}-{}", comp_in, port_in, selection_in)).ok_or(result::Error::ComponentNotFound)
            .and_then(|his| {
                Ok(his.clone())
            }));
        self.sender.send(CompMsg::ConnectOutputPort(comp_out, port_out, his)).ok().expect("Scheduler connect: unable to send to scheduler state");
        Ok(())
    }

    pub fn connect_array_to_array(&self, comp_out: String, port_out: String, selection_out: String, comp_in: String, port_in: String, selection_in: String) -> Result<()>{
        let (comp_out, port_out) = self.get_subnet_name(comp_out, port_out, VPType::Out);
        let (comp_in, port_in) = self.get_subnet_name(comp_in, port_in, VPType::In);
        let his = try!(self.inputs_array.get(&format!("{}-{}-{}", comp_in, port_in, selection_in)).ok_or(result::Error::ComponentNotFound)
            .and_then(|his| {
                Ok(his.clone())
            }));
        self.sender.send(CompMsg::ConnectOutputArrayPort(comp_out, port_out, selection_out, his)).ok().expect("Scheduler connect: unable to send to scheduler state");
        Ok(())
    }

    // pub fn disconnect(&self, comp_out: String, port_out: String) -> Result<()>{
    //     let (comp_out, port_out) = self.get_subnet_name(comp_out, port_out, VPType::Out);
    //     let comp_out = try!(self.components.get(&comp_out).ok_or(result::Error::ComponentNotFound).map(|ad| { ad.clone() }));
    //     self.sender.send(CompMsg::Disconnect(comp_out, port_out)).ok().expect("Scheduler disconnect: unable to send to scheduler state");
    //     Ok(())
    // }

    // pub fn disconnect_array(&self, comp_out: String, port_out: String, selection:String) -> Result<()>{
    //     let (comp_out, port_out) = self.get_subnet_name(comp_out, port_out, VPType::Out);
    //     let comp_out = try!(self.components.get(&comp_out).ok_or(result::Error::ComponentNotFound).map(|ad| { ad.clone() }));
    //     self.sender.send(CompMsg::DisconnectArray(comp_out, port_out, selection)).ok().expect("Scheduler disconnect_array: unable to send to scheduler state");
    //     Ok(())
    // }

    pub fn add_input_array_selection(&mut self, comp: String, port: String, selection: String) -> Result<()>{
        let (comp, port) = self.get_subnet_name(comp, port, VPType::In);
        let (s, r) = self.allocator.channel.build(&comp);
        let r = allocator::HeapIPReceiver::from_raw(r);
        let s = allocator::HeapIPSender::from_raw(s);
        self.inputs_array.insert(format!("{}-{}-{}", comp, port, selection), s);
        self.sender.send(CompMsg::AddInputArraySelection(comp, port, selection, r)).ok().expect("Scheduler add_input_array_selection : Unable to send to scheduler state");
        Ok(())
    }

    pub fn add_output_array_selection(&self, comp: String, port: String, selection: String) -> Result<()>{
        let (comp, port) = self.get_subnet_name(comp, port, VPType::Out);
        self.sender.send(CompMsg::AddOutputArraySelection(comp, port, selection)).ok().expect("Scheduler add_output_array_selection : Unable to send to scheduler state");
        Ok(())
    }

    // pub fn get_sender<T: Any + Send + Sized + Reflect>(&self, comp: String, port: String) -> CountSender<T> {
    //     let (comp, port) = self.get_subnet_name(comp, port, VPType::In);
    //     let r_comp = self.components.get(&comp).expect("Scheduler get_sender : the component doesn't exist");
    //     let sender = r_comp.input_senders.get_sender(port.clone()).expect("Scheduler connect : The comp_in doesn't have the port_in port");
    //     let mut sender: CountSender<T> = downcast(sender);
    //     sender.set_sched(comp, self.sender.clone());
    //     sender
    // }

    // pub fn get_option<T: Any + Send + Sized + Reflect>(&self, comp: String) -> SyncSender<T> {
    //     let (comp, port) = self.get_subnet_name(comp, "option".to_string(), VPType::In);
    //     let r_comp = self.components.get(&comp).expect("Scheduler get_option : the component doesn't exist");
    //     let sender = r_comp.input_senders.get_sender(port.clone()).expect("Scheduler get_option : The comp_in doesn't have the port_in port");
    //     let s: SyncSender<T> = downcast(sender);
    //     s
    // }

    // pub fn get_acc<T: Any + Send + Sized + Reflect>(&self, comp: String) -> SyncSender<T> {
    //     let (comp, port) = self.get_subnet_name(comp, "acc".to_string(), VPType::In);
    //     let r_comp = self.components.get(&comp).expect("Scheduler get_acc : the component doesn't exist");
    //     let sender = r_comp.input_senders.get_sender(port.clone()).expect("Scheduler get_acc : The comp_in doesn't have the port_in port");
    //     let s: SyncSender<T> = downcast(sender);
    //     s
    // }

    // pub fn get_array_sender<T: Any + Send + Sized + Reflect>(&self, comp: String, port: String, selection: String) -> CountSender<T> {
    //     let (comp, port) = self.get_subnet_name(comp, port, VPType::In);
    //     let r_comp = self.components.get(&comp).expect("Scheduler get_sender : the component doesn't exist");
    //     let sender = r_comp.input_array_senders.get_selection_sender(port, selection).expect("Scheduler connect : The comp_in doesn't have the port_in port");
    //     let mut sender: CountSender<T> = downcast(sender);
    //     sender.set_sched(comp, self.sender.clone());
    //     sender
    // }

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
    AddInputArraySelection(String, String, Box<HeapIPReceiver>),
    AddOutputArraySelection(String, String),
    ConnectOutputPort(String, Box<HeapIPSender>),
    ConnectOutputArrayPort(String, String, Box<HeapIPSender>),
    Disconnect(String),
    DisconnectArray(String, String),
}

struct CompState {
    comp: Option<Component>,
    // TODO : manage can_run
    can_run: bool,
    edit_msgs: Vec<EditCmp>,
    ips: isize,
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

    fn inc(&mut self, name: String) -> Result<()> {
        // silent error for exterior ports
        let mut start = false;
        if let Some(ref mut comp) = self.components.get_mut(&name) {
            comp.ips += 1;
            start = comp.ips > 0 && comp.comp.is_some();
        }
        if start { self.run(name); }
        Ok(())
    }

    fn dec(&mut self, name: String) -> Result<()> {
        // silent error for exterior ports
        if let Some(ref mut comp) = self.components.get_mut(&name) {
            comp.ips -= 1;
        }
        Ok(())
    }

    fn new_component(&mut self, name: String, comp: Component) -> Result<()> {
        self.components.insert(name, CompState {
            comp: Some(comp),
            can_run: false,
            edit_msgs: vec![],
            ips: 0,
        });
        Ok(())
    }

    //fn remove(&mut self, name: String, sync_sender: Sender<SyncMsg>) {
    //    let must_remove = {
    //        let mut o_comp = self.components.get_mut(&name).expect("SchedState remove : component doesn't exist");
    //        let b_comp = mem::replace(&mut o_comp.comp, None);
    //        if let Some(boxed_comp) = b_comp {
    //            sync_sender.send(SyncMsg::Remove(boxed_comp)).expect("SchedState remove : cannot send to the channel");
    //            true
    //        } else {
    //            sync_sender.send(SyncMsg::CannotRemove).expect("SchedState remove : cannot send to the channel");
    //            false
    //        }
    //    };
    //    if must_remove { self.components.remove(&name); }
    //}

    // fn start(&mut self, name: String) {
    //     let start = {
    //         let mut comp = self.components.get_mut(&name).expect("SchedState start : component not found");
    //         comp.can_run = true;
    //         comp.comp.is_some()
    //     };
    //     if start {
    //         self.connections += 1;
    //         self.run(name);
    //     } 
    // }

    fn halt(&mut self) -> Result<()> {
        self.can_halt = true;
        if self.connections <= 0 {
            self.sched_sender.send(CompMsg::Halt).ok().expect("SchedState RunEnd : Cannot send Halt");
        }
        Ok(())
    }

    fn run_end(&mut self, name: String, mut box_comp: Component) -> Result<()>{
        let must_restart = {
            let mut comp = self.components.get_mut(&name).expect("SchedState RunEnd : component doesn't exist");
            let vec = mem::replace(&mut comp.edit_msgs, vec![]);
            for msg in vec {
                try!(Self::edit_one_comp(&mut box_comp, msg));
            }
            let must_restart = comp.ips > 0;
            comp.comp = Some(box_comp);
            must_restart
        };
        self.connections -= 1;
        if must_restart {
            self.run(name);
        } else {
            if self.connections <= 0 && self.can_halt {
                self.sched_sender.send(CompMsg::Halt).ok().expect("SchedState RunEnd : Cannot send Halt");
            }
        }
        Ok(())
    }

    fn run(&mut self, name: String) {
        let mut o_comp = self.components.get_mut(&name).expect("SchedSate run : component doesn't exist");
        if let Some(b_comp) = mem::replace(&mut o_comp.comp, None) {
            self.connections += 1;
            let sched_s = self.sched_sender.clone();
            thread::spawn(move || {
                b_comp.run();
                sched_s.send(CompMsg::RunEnd(name, b_comp)).expect("SchedState run : unable to send RunEnd");
            });
        };
    }

    fn edit_component(&mut self, name: String, msg: EditCmp) -> Result<()> {
        let mut comp = self.components.get_mut(&name).expect("SchedState edit_component : component doesn't exist");
        if let Some(ref mut c) = comp.comp {
            let mut c = c;
            try!(Self::edit_one_comp(&mut c, msg));
        } else {
            comp.edit_msgs.push(msg);
        }
        Ok(())
    }

    fn edit_one_comp(c: &mut Component, msg: EditCmp) -> Result<()> {
        match msg {
            EditCmp::AddInputArraySelection(port, selection, recv) => {
                c.add_input_receiver(&port, &selection, recv.to_raw());
            },
            EditCmp::AddOutputArraySelection(port, selection) => {
                c.add_output_selection(&port, &selection);
            },
            EditCmp::ConnectOutputPort(port_out, his) => {
                c.connect(&port_out, his.to_raw());
            },
            EditCmp::ConnectOutputArrayPort(port_out, selection_out, his) => {
                c.connect_array(&port_out, &selection_out, his.to_raw());
            },
            EditCmp::Disconnect(port) => {
                c.disconnect(&port);
            },
            EditCmp::DisconnectArray(port, selection) => {
                c.disconnect_array(&port, &selection);
            },
        }
        Ok(())
    }
}

