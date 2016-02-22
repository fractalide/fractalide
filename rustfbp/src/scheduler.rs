extern crate libloading;

use result;
use result::Result;

use ports::{IPSender, IP};
use component::Component;

use std::collections::HashMap;
use std::sync::mpsc::{Sender, Receiver};
use std::sync::mpsc::channel;
use std::sync::mpsc::sync_channel;

use std::thread;
use std::thread::JoinHandle;

use std::mem;


pub type BoxedComp = Box<Component + Send>;
// TODO : manage "can_run": allow a user to pause a component

/// All the messages that can be send between the "exterior scheduler" and the "interior scheduler".
pub enum CompMsg {
    /// Add a new component. The String is the name, the BoxedComp is the component itself
    NewComponent(String, BoxedComp),
    Halt, HaltState,
    Start(String),
    ConnectOutputPort(String, String, IPSender),
    ConnectOutputArrayPort(String, String, String, IPSender),
    Disconnect(String, String),
    DisconnectArray(String, String, String),
    AddInputArraySelection(String, String, String, Receiver<IP>),
    AddOutputArraySelection(String, String, String),
    RunEnd(String, BoxedComp),
    SetReceiver(String, String, Receiver<IP>),
    Inc(String),
    Dec(String),
    Remove(String, Sender<SyncMsg>),
}

pub struct Comp {
    pub inputs: HashMap<String, IPSender>,
    pub inputs_array: HashMap<String, HashMap<String, IPSender>>,
    pub sort: String,
}

/// the exterior scheduler. The end user use the methods of this structure.
pub struct Scheduler {
    pub cache: ComponentCache,
    pub components: HashMap<String, Comp>,
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
                    CompMsg::Start(name) => { sched_s.start(name) },
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
                    CompMsg::SetReceiver(comp, port, receiver) => {
                        sched_s.edit_component(comp, EditCmp::SetReceiver(port, receiver))
                    },
                    CompMsg::Disconnect(name, port) => {
                        sched_s.edit_component(name, EditCmp::Disconnect(port))
                    },
                    CompMsg::DisconnectArray(name, port, selection) => {
                        sched_s.edit_component(name, EditCmp::DisconnectArray(port, selection))
                    },
                    CompMsg::Inc(dest) => { sched_s.inc(dest) },
                    CompMsg::Dec(dest) => { sched_s.dec(dest) },
                    CompMsg::Remove(name, sync_sender) => {
                        sched_s.remove(name, sync_sender)
                    }
                };
                res.map_err(|e| { error_s.send(e).expect("cannot send the error"); }).ok();
            }
        });

        Scheduler {
            cache: ComponentCache::new(),
            components: HashMap::new(),
            sender: s,
            error_receiver: error_r,
            th: th,
        }
    }

    pub fn add_component(&mut self, name: &str, sort: &str) -> Result<()> {
        let name = name.to_string();
        let (comp, senders) = self.cache.create_comp(sort, name.clone(), self.sender.clone()).expect("cannot create comp");
        self.sender.send(CompMsg::NewComponent(name.clone(), comp)).expect("Cannot send to sched state");
        let s_acc = try!(senders.get("acc").ok_or(result::Error::PortNotFound)).clone();
        self.components.insert(name.clone(),
                               Comp {
                                   inputs: senders,
                                   inputs_array: HashMap::new(),
                                   sort: sort.into(),
                               });
        self.sender.send(CompMsg::ConnectOutputPort(name, "acc".into(), s_acc)).expect("Cannot send to sched state");
        Ok(())
    }

    pub fn start(&self, name: String) {
        self.sender.send(CompMsg::Start(name)).expect("start: unable to send to sched state");
    }

    pub fn remove_component(&mut self, name: String) -> Result<(BoxedComp, Comp)>{
        let (s, r) = channel();
        self.sender.send(CompMsg::Remove(name.clone(), s)).expect("Scheduler remove_component: cannot send to the state");
        let response = try!(r.recv());
        match response {
            SyncMsg::Remove(boxed_comp) => {
                Ok((boxed_comp, try!(self.components.remove(&name).ok_or(result::Error::ComponentNotFound))))
            },
            SyncMsg::CannotRemove => {
                Err(result::Error::CannotRemove)
            },
        }
    }

    pub fn connect(&self, comp_out: String, port_out: String, comp_in: String, port_in: String) -> Result<()>{
        let sender = try!(self.get_sender(&comp_in, &port_in));
        self.sender.send(CompMsg::ConnectOutputPort(comp_out, port_out, sender)).ok().expect("Scheduler connect: unable to send to sched state");
        Ok(())
    }

    pub fn connect_array(&self, comp_out: String, port_out: String, selection_out: String, comp_in: String, port_in: String) -> Result<()> {
        let sender = try!(self.get_sender(&comp_in, &port_in));
        self.sender.send(CompMsg::ConnectOutputArrayPort(comp_out, port_out, selection_out, sender)).ok().expect("Scheduler connect: unable to send to scheduler state");
        Ok(())
    }

    pub fn connect_to_array(&self, comp_out: String, port_out: String, comp_in: String, port_in: String, selection_in: String) -> Result<()>{
        let sender = try!(self.get_array_sender(&comp_in, &port_in, &selection_in));
        self.sender.send(CompMsg::ConnectOutputPort(comp_out, port_out, sender)).ok().expect("Scheduler connect: unable to send to scheduler state");
        Ok(())
    }

    pub fn connect_array_to_array(&self, comp_out: String, port_out: String, selection_out: String, comp_in: String, port_in: String, selection_in: String) -> Result<()>{
        let sender = try!(self.get_array_sender(&comp_in, &port_in, &selection_in));
        self.sender.send(CompMsg::ConnectOutputArrayPort(comp_out, port_out, selection_out, sender)).ok().expect("Scheduler connect: unable to send to scheduler state");
        Ok(())
    }

    pub fn disconnect(&self, comp_out: String, port_out: String) -> Result<()>{
        self.sender.send(CompMsg::Disconnect(comp_out, port_out)).ok().expect("Scheduler disconnect: unable to send to scheduler state");
        Ok(())
    }

    pub fn disconnect_array(&self, comp_out: String, port_out: String, selection:String) -> Result<()>{
        self.sender.send(CompMsg::DisconnectArray(comp_out, port_out, selection)).ok().expect("Scheduler disconnect_array: unable to send to scheduler state");
        Ok(())
    }

    pub fn add_input_array_selection(&mut self, comp: String, port: String, selection: String) -> Result<()>{
        let (s, r) = sync_channel(25);
        let s = IPSender {
            sender: s,
            dest: comp.clone(),
            sched: self.sender.clone(),
        };
        try!(self.components.get_mut(&comp).ok_or(result::Error::ComponentNotFound)
            .and_then(|mut comp| {
                if !comp.inputs_array.contains_key(&port) {
                    comp.inputs_array.insert(port.clone(), HashMap::new());
                }
                comp.inputs_array.get_mut(&port).ok_or(result::Error::SelectionNotFound)
                    .and_then(|mut port| {
                        port.insert(selection.clone(), s);
                        Ok(())
                    })
            }));
        self.sender.send(CompMsg::AddInputArraySelection(comp, port, selection, r)).ok().expect("Scheduler add_input_array_selection : Unable to send to scheduler state");
        Ok(())
    }

    pub fn soft_add_input_array_selection(&mut self, comp: String, port: String, selection: String) -> Result<()> {
        let mut res = true;
        if let Some(comp) = self.components.get(&comp) {
            if let Some(port) = comp.inputs_array.get(&port) {
                if let Some(_) = port.get(&selection) {
                    res = true;
                }
            }
        }
        if res {
            self.add_input_array_selection(comp, port, selection)
        } else {
            Ok(())
        }
    }

    pub fn add_output_array_selection(&self, comp: String, port: String, selection: String) -> Result<()>{
        self.sender.send(CompMsg::AddOutputArraySelection(comp, port, selection)).ok().expect("Scheduler add_output_array_selection : Unable to send to scheduler state");
        Ok(())
    }

    pub fn set_receiver(&self, comp: String, port: String, receiver: Receiver<IP>) -> Result<()> {
        self.sender.send(CompMsg::SetReceiver(comp, port, receiver)).expect("scheduler cannot send");
        Ok(())
    }

    pub fn set_array_receiver(&self, comp: String, port: String, selection: String, receiver: Receiver<IP>) -> Result<()> {
        self.sender.send(CompMsg::AddInputArraySelection(comp, port, selection, receiver)).expect("scheduler cannot send");
        Ok(())
    }

    pub fn get_sender(&self, comp: &str, port: &str) -> Result<IPSender> {
        self.components.get(comp).ok_or(result::Error::ComponentNotFound)
            .and_then(|c| {
                c.inputs.get(port).ok_or(result::Error::PortNotFound)
                    .map(|s| { s.clone() })
            })
    }

    pub fn get_array_sender(&self, comp: &str, port: &str, selection: &str) -> Result<IPSender> {
        self.components.get(comp).ok_or(result::Error::ComponentNotFound)
            .and_then(|c| {
                c.inputs_array.get(port).ok_or(result::Error::PortNotFound)
                    .and_then(|p| {
                        p.get(selection).ok_or(result::Error::SelectionNotFound)
                            .map(|s| { s.clone() })
                    })
            })
    }

    pub fn get_contract_input(&self, comp: &str, port: &str) -> Result<String> {
        self.components.get(comp).ok_or(result::Error::ComponentNotFound)
            .and_then(|c| {
                self.cache.get_contract_input(&c.sort, port)
            })
    }

    pub fn get_contract_input_array(&self, comp: &str, port: &str) -> Result<String> {
        self.components.get(comp).ok_or(result::Error::ComponentNotFound)
            .and_then(|c| {
                self.cache.get_contract_input_array(&c.sort, port)
            })
    }

    pub fn get_contract_output(&self, comp: &str, port: &str) -> Result<String> {
        self.components.get(comp).ok_or(result::Error::ComponentNotFound)
            .and_then(|c| {
                self.cache.get_contract_output(&c.sort, port)
            })
    }

    pub fn get_contract_output_array(&self, comp: &str, port: &str) -> Result<String> {
        self.components.get(comp).ok_or(result::Error::ComponentNotFound)
            .and_then(|c| {
                self.cache.get_contract_output_array(&c.sort, port)
            })
    }

    pub fn join(self) {
        self.sender.send(CompMsg::HaltState).ok().expect("Scheduler join : Cannot send HaltState");
        self.th.join().ok().expect("Scheduelr join : Cannot join the thread");
    }
}

enum EditCmp {
    AddInputArraySelection(String, String, Receiver<IP>),
    AddOutputArraySelection(String, String),
    ConnectOutputPort(String, IPSender),
    ConnectOutputArrayPort(String, String, IPSender),
    SetReceiver(String, Receiver<IP>),
    Disconnect(String),
    DisconnectArray(String, String),
}

pub enum SyncMsg {
    Remove(BoxedComp),
    CannotRemove,
}

struct CompState {
    comp: Option<BoxedComp>,
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

    fn new_component(&mut self, name: String, comp: BoxedComp) -> Result<()> {
        self.components.insert(name, CompState {
            comp: Some(comp),
            can_run: false,
            edit_msgs: vec![],
            ips: 0,
        });
        Ok(())
    }

    fn remove(&mut self, name: String, sync_sender: Sender<SyncMsg>) -> Result<()>{
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
        Ok(())
    }

    fn start(&mut self, name: String) -> Result<()> {
        let start = {
            let mut comp = self.components.get_mut(&name).expect("SchedState start : component not found");
            comp.can_run = true;
            comp.comp.is_some()
        };
        if start {
            self.run(name);
        }
        Ok(())
    }

    fn halt(&mut self) -> Result<()> {
        self.can_halt = true;
        if self.connections <= 0 {
            self.sched_sender.send(CompMsg::Halt).ok().expect("SchedState RunEnd : Cannot send Halt");
        }
        Ok(())
    }

    fn run_end(&mut self, name: String, mut box_comp: BoxedComp) -> Result<()>{
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
        if let Some(mut b_comp) = mem::replace(&mut o_comp.comp, None) {
            self.connections += 1;
            let sched_s = self.sched_sender.clone();
            thread::spawn(move || {
                let res = b_comp.run();
                if let Err(e) = res {
                    println!("{} fails : {}", name, e);
                }
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

    fn edit_one_comp(mut c: &mut BoxedComp, msg: EditCmp) -> Result<()> {
        let mut c = c.get_ports();
        match msg {
            EditCmp::AddInputArraySelection(port, selection, recv) => {
                try!(c.add_input_receiver(&port, selection, recv));
            },
            EditCmp::AddOutputArraySelection(port, selection) => {
                try!(c.add_output_selection(&port, selection));
            },
            EditCmp::ConnectOutputPort(port_out, his) => {
                try!(c.connect(port_out, his));
            },
            EditCmp::ConnectOutputArrayPort(port_out, selection_out, his) => {
                try!(c.connect_array(port_out, selection_out, his));
            },
            EditCmp::SetReceiver(port, hir) => {
                c.set_receiver(port, hir);
            }
            EditCmp::Disconnect(port) => {
                try!(c.disconnect(port));
            },
            EditCmp::DisconnectArray(port, selection) => {
                try!(c.disconnect_array(port, selection));
            },
        }
        Ok(())
    }
}

#[allow(dead_code)]
pub struct ComponentLoader {
    lib: libloading::Library,
    create: extern "C" fn(String, Sender<CompMsg>) -> Result<(Box<Component + Send>, HashMap<String, IPSender>)>,
    get_contract_input: extern "C" fn(&str) -> Result<String>,
    get_contract_input_array: extern "C" fn(&str) -> Result<String>,
    get_contract_output: extern "C" fn(&str) -> Result<String>,
    get_contract_output_array: extern "C" fn(&str) -> Result<String>,
}

pub struct ComponentCache {
    cache: HashMap<String, ComponentLoader>,
}

impl ComponentCache {
    pub fn new() -> Self {
        ComponentCache {
            cache: HashMap::new(),
        }
    }

    pub fn create_comp(&mut self, path: &str, name: String, sender: Sender<CompMsg>) -> Result<(Box<Component + Send>, HashMap<String, IPSender>)> {
        if !self.cache.contains_key(path) {
            let lib_comp = libloading::Library::new(path).expect("cannot load");

            let new_comp: extern fn(String, Sender<CompMsg>) -> Result<(Box<Component + Send>, HashMap<String, IPSender>)> = unsafe {
                *(lib_comp.get(b"create_component\0").expect("cannot find create method"))
            };

            let get_in : extern fn(&str) -> Result<String> = unsafe {
                *(lib_comp.get(b"get_contract_input\0").expect("cannot find get input method"))
            };

            let get_in_a : extern fn(&str) -> Result<String> = unsafe {
                *(lib_comp.get(b"get_contract_input_array\0").expect("cannot find get input method"))
            };

            let get_out : extern fn(&str) -> Result<String> = unsafe {
                *(lib_comp.get(b"get_contract_output\0").expect("cannot find get output method"))
            };

            let get_out_a : extern fn(&str) -> Result<String> = unsafe {
                *(lib_comp.get(b"get_contract_output_array\0").expect("cannot find get output method"))
            };

            self.cache.insert(path.into(),
                              ComponentLoader {
                                  lib: lib_comp,
                                  create: new_comp,
                                  get_contract_input: get_in,
                                  get_contract_input_array: get_in_a,
                                  get_contract_output: get_out,
                                  get_contract_output_array: get_out_a,
                              });
        }
        if let Some(loader) = self.cache.get(path){
            (loader.create)(name, sender)
        } else {
            unreachable!()
        }
    }

    pub fn get_contract_input(&self, comp: &str, port: &str) -> Result<String> {
        self.cache.get(comp).ok_or(result::Error::ComponentNotFound)
            .map(|comp| {
                (comp.get_contract_input)(port).expect("cannot get")
            })
    }

    pub fn get_contract_input_array(&self, comp: &str, port: &str) -> Result<String> {
        self.cache.get(comp).ok_or(result::Error::ComponentNotFound)
            .map(|comp| {
                (comp.get_contract_input_array)(port).expect("cannot get")
            })
    }

    pub fn get_contract_output(&self, comp: &str, port: &str) -> Result<String> {
        self.cache.get(comp).ok_or(result::Error::ComponentNotFound)
            .map(|comp| {
                (comp.get_contract_output)(port).expect("cannot get")
            })
    }

    pub fn get_contract_output_array(&self, comp: &str, port: &str) -> Result<String> {
        self.cache.get(comp).ok_or(result::Error::ComponentNotFound)
            .map(|comp| {
                (comp.get_contract_output_array)(port).expect("cannot get")
            })
    }
}
