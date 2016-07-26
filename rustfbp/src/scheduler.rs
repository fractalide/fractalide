//! manages the execution of a FBP graph.
//!
//! It had two main parts : the "exterior scheduler" and the "interior scheduler".
//!
//! The exterior scheduler is an API to easily manage the scheduler.
//!
//! The interior scheduler is the actual state of the scheduler. It is edited by sending messages.
//! The messages are send by the exterior scheduler and the components of the Graph.


extern crate libloading;
extern crate threadpool;

use self::threadpool::ThreadPool;

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


/// A boxed comp is a component that can be send between thread
pub type BoxedComp = Box<Component + Send>;
// TODO : manage "can_run": allow a user to pause a component

/// All the messages that can be send between the "exterior scheduler" and the "interior scheduler".
pub enum CompMsg {
    /// Add a new component. The String is the name, the BoxedComp is the component itself
    NewComponent(String, BoxedComp),
    /// Stop the scheduler
    Halt,
    /// Try to stop the sheduler state
    HaltState,
    /// Start a component
    Start(String),
    /// Connect the output port
    ConnectOutputPort(String, String, IPSender),
    /// Connect the array output port
    ConnectOutputArrayPort(String, String, String, IPSender),
    /// Disconnect an output port
    Disconnect(String, String),
    /// Disconnect an array output port
    DisconnectArray(String, String, String),
    /// Add an selection in an array input port
    AddInputArraySelection(String, String, String, Receiver<IP>),
    /// Remove an selection in an array input port
    RemoveInputArraySelection(String, String, String),
    /// Add an selection in an array output port
    AddOutputArraySelection(String, String, String),
    /// Signal the end of an execution
    RunEnd(String, BoxedComp),
    /// Set the receiver of an input port
    SetReceiver(String, String, Receiver<IP>),
    /// The component received an IP
    Inc(String),
    /// The component read an IP
    Dec(String),
    /// Remove a component
    Remove(String, Sender<SyncMsg>),
}

/// This structure keep all the information for the "exterior scheduler".
///
/// These information must be accessible for the user of the scheduler
pub struct Comp {
    /// Keep the IPSender of the input ports
    pub inputs: HashMap<String, IPSender>,
    /// Keep the IPSender of the array input ports
    pub inputs_array: HashMap<String, HashMap<String, IPSender>>,
    /// The type of the component
    pub sort: String,
    /// True if a component had no input port
    pub start: bool,
}

/// the exterior scheduler. The end user use the methods of this structure.
pub struct Scheduler {
    /// Keep the dylib of the loaded components
    pub cache: ComponentCache,
    /// Keep the component
    pub components: HashMap<String, Comp>,
    /// A sender to send message to the scheduler
    pub sender: Sender<CompMsg>,
    /// Received the error from the "interior scheduler"
    pub error_receiver: Receiver<result::Error>,
    th: JoinHandle<()>,
}

impl Scheduler {
    /// Create a new scheduler
    ///
    /// # Example
    ///
    /// ```rust,ignore
    /// let sched = Scheduler::new();
    /// ```
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
                    CompMsg::RemoveInputArraySelection(name, port, selection) => {
                        sched_s.edit_component(name, EditCmp::RemoveInputArraySelection(port, selection))
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

    /// Add a component to the scheduler
    ///
    /// The sort is a complete path to the dylib
    ///
    /// # Example
    ///
    /// ```rust,ignore
    /// try!(sched.add_component("add", "/home/xxx/components/add.so");
    /// ```
    pub fn add_component(&mut self, name: &str, sort: &str) -> Result<()> {
        let name = name.to_string();
        let (comp, senders) = self.cache.create_comp(sort, name.clone(), self.sender.clone()).expect("cannot create comp");
        let start = !comp.is_input_ports();
        self.sender.send(CompMsg::NewComponent(name.clone(), comp)).expect("Cannot send to sched state");
        let s_acc = try!(senders.get("acc").ok_or(result::Error::PortNotFound(name.clone(), "acc".into()))).clone();
        self.components.insert(name.clone(),
                               Comp {
                                   inputs: senders,
                                   inputs_array: HashMap::new(),
                                   sort: sort.into(),
                                   start: start,
                               });
        self.sender.send(CompMsg::ConnectOutputPort(name, "acc".into(), s_acc)).expect("Cannot send to sched state");
        Ok(())
    }

    /// Start the scheduler
    ///
    /// Start all the component that have no input ports
    ///
    /// # Example
    ///
    /// ```rust,ignore
    /// sched.start();
    /// ```
    pub fn start(&self) {
        for (name, comp) in &self.components {
            if comp.start {
                self.sender.send(CompMsg::Start(name.clone())).expect("start: unable to send to sched state");
            }
        }
    }

    /// Start the component `name` if it has no input port
    ///
    /// # Example
    ///
    /// ```rust,ignore
    /// try!(sched.start_if_needed("add"));
    /// ```
    pub fn start_if_needed(&self, name: &str) -> Result<()> {
        self.components.get(name).ok_or(result::Error::ComponentNotFound(name.into()))
            .and_then(|comp| {
                if comp.start {
                    self.sender.send(CompMsg::Start(name.into())).expect("start_if_needed");
                }
                Ok(())
            })
    }

    /// Start a component, even if it has an input port
    ///
    /// # Example
    /// ```rust,ignore
    /// sched.start_component("add");
    /// ```
    pub fn start_component(&self, name: String) {
        self.sender.send(CompMsg::Start(name)).expect("start: unable to send to sched state");
    }

    /// Remove a component form the scheduler and retrieve all the information
    ///
    /// # Example
    /// ```rust,ignore
    /// let (boxed_comp, comp) = try!(sched.remove_component("add"));
    /// assert!(boxed_comp.is_input_ports());
    /// ```
    pub fn remove_component(&mut self, name: String) -> Result<(BoxedComp, Comp)>{
        let (s, r) = channel();
        self.sender.send(CompMsg::Remove(name.clone(), s)).expect("Scheduler remove_component: cannot send to the state");
        let response = try!(r.recv());
        match response {
            SyncMsg::Remove(boxed_comp) => {
                Ok((boxed_comp, try!(self.components.remove(&name).ok_or(result::Error::ComponentNotFound(name.into())))))
            },
            SyncMsg::CannotRemove => {
                Err(result::Error::CannotRemove(name.into()))
            },
        }
    }

    /// Connect a simple output port to a simple input port
    ///
    /// # Example
    /// ```rust,ignore
    /// try!(sched.connect("add", "output", "display", "input"));
    /// ```
    pub fn connect(&self, comp_out: String, port_out: String, comp_in: String, port_in: String) -> Result<()>{
        let sender = try!(self.get_sender(&comp_in, &port_in));
        self.sender.send(CompMsg::ConnectOutputPort(comp_out, port_out, sender)).ok().expect("Scheduler connect: unable to send to sched state");
        Ok(())
    }

    /// Connect a array output port to a simple input port
    ///
    /// # Example
    /// ```rust,ignore
    /// try!(sched.connect_array("add", "outputs", "1", "display", "input"));
    /// ```
    pub fn connect_array(&self, comp_out: String, port_out: String, selection_out: String, comp_in: String, port_in: String) -> Result<()> {
        let sender = try!(self.get_sender(&comp_in, &port_in));
        self.sender.send(CompMsg::ConnectOutputArrayPort(comp_out, port_out, selection_out, sender)).ok().expect("Scheduler connect: unable to send to scheduler state");
        Ok(())
    }

    /// Connect a simple output port to an array input port
    ///
    /// # Example
    /// ```rust,ignore
    /// try!(sched.connect_to_array("add", "output", "display", "inputs", "1"));
    /// ```
    pub fn connect_to_array(&self, comp_out: String, port_out: String, comp_in: String, port_in: String, selection_in: String) -> Result<()>{
        let sender = try!(self.get_array_sender(&comp_in, &port_in, &selection_in));
        self.sender.send(CompMsg::ConnectOutputPort(comp_out, port_out, sender)).ok().expect("Scheduler connect: unable to send to scheduler state");
        Ok(())
    }

    /// Connect an array output port to an array input port
    ///
    /// # Example
    /// ```rust,ignore
    /// try!(sched.connect_array_to_array("add", "outputs", "1", "display", "inputs", "1"));
    /// ```
    pub fn connect_array_to_array(&self, comp_out: String, port_out: String, selection_out: String, comp_in: String, port_in: String, selection_in: String) -> Result<()>{
        let sender = try!(self.get_array_sender(&comp_in, &port_in, &selection_in));
        self.sender.send(CompMsg::ConnectOutputArrayPort(comp_out, port_out, selection_out, sender)).ok().expect("Scheduler connect: unable to send to scheduler state");
        Ok(())
    }

    /// disconnect an output port
    ///
    /// # Example
    /// ```rust,ignore
    /// try!(sched.disconnect("add", "output"));
    /// ```
    pub fn disconnect(&self, comp_out: String, port_out: String) -> Result<()>{
        self.sender.send(CompMsg::Disconnect(comp_out, port_out)).ok().expect("Scheduler disconnect: unable to send to scheduler state");
        Ok(())
    }

    /// disconnect an array output port
    ///
    /// # Example
    /// ```rust,ignore
    /// try!(sched.disconnect_array("add", "outputs", "1"));
    /// ```
    pub fn disconnect_array(&self, comp_out: String, port_out: String, selection:String) -> Result<()>{
        self.sender.send(CompMsg::DisconnectArray(comp_out, port_out, selection)).ok().expect("Scheduler disconnect_array: unable to send to scheduler state");
        Ok(())
    }

    /// Add a selection in an input array port
    ///
    /// # Example
    /// ```rust,ignore
    /// try!(sched.add_input_array_selection("add".into(), "inputs".into(), "1".into()));
    /// ```
    pub fn add_input_array_selection(&mut self, comp_name: String, port: String, selection: String) -> Result<()>{
        let (s, r) = sync_channel(25);
        let s = IPSender {
            sender: s,
            dest: comp_name.clone(),
            sched: self.sender.clone(),
        };
        try!(self.components.get_mut(&comp_name).ok_or(result::Error::ComponentNotFound(comp_name.clone()))
            .and_then(|mut comp| {
                if !comp.inputs_array.contains_key(&port) {
                    comp.inputs_array.insert(port.clone(), HashMap::new());
                }
                comp.inputs_array.get_mut(&port).ok_or(result::Error::SelectionNotFound(comp_name.clone(), port.clone(), selection.clone()))
                    .and_then(|mut port| {
                        port.insert(selection.clone(), s);
                        Ok(())
                    })
            }));
        self.sender.send(CompMsg::AddInputArraySelection(comp_name, port, selection, r)).ok().expect("Scheduler add_input_array_selection : Unable to send to scheduler state");
        Ok(())
    }

    // pub fn remove_input_array_selection(&mut self, comp: String, port: String, selection: String) -> Result<()> {
    //     // TODO
    // }

    /// Add a selection in an input array port, only if this selection exists not yet
    ///
    /// # Example
    /// ```rust,ignore
    /// try!(sched.soft_add_input_array_selection("add".into(), "inputs".into(), "1".into()));
    /// ```
    pub fn soft_add_input_array_selection(&mut self, comp: String, port: String, selection: String) -> Result<()> {
        let mut res = true;
        if let Some(comp) = self.components.get(&comp) {
            if let Some(port) = comp.inputs_array.get(&port) {
                if let Some(_) = port.get(&selection) {
                    res = false;
                }
            }
        }
        if res {
            self.add_input_array_selection(comp, port, selection)
        } else {
            Ok(())
        }
    }

    /// Add a selection in an output array port
    ///
    /// # Example
    /// ```rust,ignore
    /// try!(sched.add_output_array_selection("add".into(), "inputs".into(), "1".into()));
    /// ```
    pub fn add_output_array_selection(&self, comp: String, port: String, selection: String) -> Result<()>{
        self.sender.send(CompMsg::AddOutputArraySelection(comp, port, selection)).ok().expect("Scheduler add_output_array_selection : Unable to send to scheduler state");
        Ok(())
    }

    /// Change the receiver of an input port.
    ///
    /// Usefull for replacing a component
    ///
    /// # Example
    /// ```rust,ignore
    /// try!(sched.set_receiver("add".into(), "input".into(), recv));
    /// ```
    pub fn set_receiver(&self, comp: String, port: String, receiver: Receiver<IP>) -> Result<()> {
        self.sender.send(CompMsg::SetReceiver(comp, port, receiver)).expect("scheduler cannot send");
        Ok(())
    }

    /// Change the receiver of an array input port.
    ///
    /// Usefull for replacing a component
    ///
    /// # Example
    /// ```rust,ignore
    /// try!(sched.set_array_receiver("add".into(), "inputs".into(), "1".into(), recv));
    /// ```
    pub fn set_array_receiver(&self, comp: String, port: String, selection: String, receiver: Receiver<IP>) -> Result<()> {
        self.sender.send(CompMsg::AddInputArraySelection(comp, port, selection, receiver)).expect("scheduler cannot send");
        Ok(())
    }

    /// Get the sender of a input port
    ///
    /// # Example
    /// ```rust,ignore
    /// let sender = try!(sched.get_sender("add", "input"));
    /// ```
    pub fn get_sender(&self, comp: &str, port: &str) -> Result<IPSender> {
        self.components.get(comp).ok_or(result::Error::ComponentNotFound(comp.into()))
            .and_then(|c| {
                c.inputs.get(port).ok_or(result::Error::PortNotFound(comp.into(), port.into()))
                    .map(|s| { s.clone() })
            })
    }

    /// Get the sender of an array input port
    ///
    /// # Example
    /// ```rust,ignore
    /// let sender = try!(sched.get_array_sender("add", "input", "1"));
    /// ```
    pub fn get_array_sender(&self, comp: &str, port: &str, selection: &str) -> Result<IPSender> {
        self.components.get(comp).ok_or(result::Error::ComponentNotFound(comp.into()))
            .and_then(|c| {
                c.inputs_array.get(port).ok_or(result::Error::PortNotFound(comp.into(), port.into()))
                    .and_then(|p| {
                        p.get(selection).ok_or(result::Error::SelectionNotFound(comp.into(), port.into(), selection.into()))
                            .map(|s| { s.clone() })
                    })
            })
    }

    /// Get the contract of an input port
    ///
    /// # Example
    /// ```rust,ignore
    /// let contract = try!(sched.get_contract_input("add", "input"));
    /// ```
    pub fn get_contract_input(&self, comp: &str, port: &str) -> Result<String> {
        self.components.get(comp).ok_or(result::Error::ComponentNotFound(comp.into()))
            .and_then(|c| {
                self.cache.get_contract_input(&c.sort, port)
            })
    }

    /// Get the contract of an array input port
    ///
    /// # Example
    /// ```rust,ignore
    /// let contract = try!(sched.get_contract_input_array("add", "inputs"));
    /// ```
    pub fn get_contract_input_array(&self, comp: &str, port: &str) -> Result<String> {
        self.components.get(comp).ok_or(result::Error::ComponentNotFound(comp.into()))
            .and_then(|c| {
                self.cache.get_contract_input_array(&c.sort, port)
            })
    }

    /// Get the contract of an output port
    ///
    /// # Example
    /// ```rust,ignore
    /// let contract = try!(sched.get_contract_output("add", "output"));
    /// ```
    pub fn get_contract_output(&self, comp: &str, port: &str) -> Result<String> {
        self.components.get(comp).ok_or(result::Error::ComponentNotFound(comp.into()))
            .and_then(|c| {
                self.cache.get_contract_output(&c.sort, port)
            })
    }

    /// Get the contract of an array output port
    ///
    /// # Example
    /// ```rust,ignore
    /// let contract = try!(sched.get_contract_output_array("add", "outputs"));
    /// ```
    pub fn get_contract_output_array(&self, comp: &str, port: &str) -> Result<String> {
        self.components.get(comp).ok_or(result::Error::ComponentNotFound(comp.into()))
            .and_then(|c| {
                self.cache.get_contract_output_array(&c.sort, port)
            })
    }

    /// Wait for the end of the scheduler
    ///
    /// # Example
    /// ```rust,ignore
    /// sched.join();
    /// // The sched is terminated
    /// ```
    pub fn join(self) {
        self.sender.send(CompMsg::HaltState).ok().expect("Scheduler join : Cannot send HaltState");
        self.th.join().ok().expect("Scheduelr join : Cannot join the thread");
    }
}

enum EditCmp {
    AddInputArraySelection(String, String, Receiver<IP>),
    RemoveInputArraySelection(String, String),
    AddOutputArraySelection(String, String),
    ConnectOutputPort(String, IPSender),
    ConnectOutputArrayPort(String, String, IPSender),
    SetReceiver(String, Receiver<IP>),
    Disconnect(String),
    DisconnectArray(String, String),
}

/// To be removed, replace by async msg
pub enum SyncMsg {
    Remove(BoxedComp),
    CannotRemove,
}

/// Internal representation of a component
struct CompState {
    comp: Option<BoxedComp>,
    // TODO : manage can_run
    can_run: bool,
    edit_msgs: Vec<EditCmp>,
    ips: isize,
}

/// The state of the internal scheduler
struct SchedState {
    sched_sender: Sender<CompMsg>,
    components: HashMap<String, CompState>,
    connections: usize,
    can_halt: bool,
    pool: ThreadPool,
}

impl SchedState {
    fn new(s: Sender<CompMsg>) -> Self {
        SchedState {
            sched_sender: s,
            components: HashMap::new(),
            connections: 0,
            can_halt: false,
            pool: ThreadPool::new(8),
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
    #[allow(unused_must_use)]
    fn run(&mut self, name: String) {
        let mut o_comp = self.components.get_mut(&name).expect("SchedSate run : component doesn't exist");
        if let Some(mut b_comp) = mem::replace(&mut o_comp.comp, None) {
            self.connections += 1;
            let sched_s = self.sched_sender.clone();
            self.pool.execute(move || {
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
            EditCmp::RemoveInputArraySelection(port, selection) => {
                try!(c.remove_array_receiver(&port, &selection));
            }
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

/// Contains all the information of a dylib components
#[allow(dead_code)]
pub struct ComponentLoader {
    lib: libloading::Library,
    create: extern "C" fn(String, Sender<CompMsg>) -> Result<(Box<Component + Send>, HashMap<String, IPSender>)>,
    get_contract_input: extern "C" fn(&str) -> Result<String>,
    get_contract_input_array: extern "C" fn(&str) -> Result<String>,
    get_contract_output: extern "C" fn(&str) -> Result<String>,
    get_contract_output_array: extern "C" fn(&str) -> Result<String>,
}

/// Keep all the dylib components and load them
pub struct ComponentCache {
    cache: HashMap<String, ComponentLoader>,
}

impl ComponentCache {
    ///  create a new ComponentCache
    ///
    /// # Example
    /// ```rust,ignore
    /// let cc = ComponentCache::new();
    /// ```
    pub fn new() -> Self {
        ComponentCache {
            cache: HashMap::new(),
        }
    }

    /// Load a new component from the system file
    ///
    /// # Example
    /// ```rust,ignore
    /// try!(cc.create_comp("/home/xxx/components/add.so", "add", sched_sender));
    /// ```
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

    /// Get the contract of an input port
    ///
    /// # Example
    /// ```rust,ignore
    /// cc.get_contract_input("add", "input");
    /// ```
    pub fn get_contract_input(&self, comp: &str, port: &str) -> Result<String> {
        self.cache.get(comp).ok_or(result::Error::ComponentNotFound(comp.into()))
            .map(|comp| {
                (comp.get_contract_input)(port).expect("cannot get")
            })
    }

    /// Get the contract of an array input port
    ///
    /// # Example
    /// ```rust,ignore
    /// cc.get_contract_input_array("add", "inputs");
    /// ```
    pub fn get_contract_input_array(&self, comp: &str, port: &str) -> Result<String> {
        self.cache.get(comp).ok_or(result::Error::ComponentNotFound(comp.into()))
            .map(|comp| {
                (comp.get_contract_input_array)(port).expect("cannot get")
            })
    }

    /// Get the contract of an output port
    ///
    /// # Example
    /// ```rust,ignore
    /// cc.get_contract_output("add", "output");
    /// ```
    pub fn get_contract_output(&self, comp: &str, port: &str) -> Result<String> {
        self.cache.get(comp).ok_or(result::Error::ComponentNotFound(comp.into()))
            .map(|comp| {
                (comp.get_contract_output)(port).expect("cannot get")
            })
    }

    /// Get the contract of an array output port
    ///
    /// # Example
    /// ```rust,ignore
    /// cc.get_contract_output_array("add", "outputs");
    /// ```
    pub fn get_contract_output_array(&self, comp: &str, port: &str) -> Result<String> {
        self.cache.get(comp).ok_or(result::Error::ComponentNotFound(comp.into()))
            .map(|comp| {
                (comp.get_contract_output_array)(port).expect("cannot get")
            })
    }
}

unsafe impl Send for ComponentCache {}
