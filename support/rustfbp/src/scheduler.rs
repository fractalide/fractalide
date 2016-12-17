//! manages the execution of a FBP graph.
//!
//! It had two main parts : the "exterior scheduler" and the "interior scheduler".
//!
//! The exterior scheduler is an API to easily manage the scheduler.
//!
//! The interior scheduler is the actual state of the scheduler. It is edited by sending messages.
//! The messages are send by the exterior scheduler and the agents of the Graph.


extern crate libloading;
extern crate threadpool;

use self::threadpool::ThreadPool;

use result;
use result::Result;

use ports::{IPSender, IPReceiver, IP};
use agent::Agent;

use std::collections::HashMap;
use std::sync::mpsc::{Sender, Receiver};
use std::sync::mpsc::channel;
use std::sync::mpsc::sync_channel;

use std::thread;
use std::thread::JoinHandle;

use std::mem;


/// A boxed comp is a agent that can be send between thread
pub type BoxedComp = Box<Agent + Send>;
// TODO : manage "can_run": allow a user to pause a agent

/// All the messages that can be send between the "exterior scheduler" and the "interior scheduler".
pub enum CompMsg {
    /// Add a new agent. The String is the name, the BoxedComp is the agent itself
    NewAgent(String, BoxedComp),
    /// Stop the scheduler
    Halt,
    /// Try to stop the sheduler state
    HaltState,
    /// Start a agent
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
    AddInputArraySelection(String, String, String, IPReceiver),
    /// Remove an selection in an array input port
    RemoveInputArraySelection(String, String, String),
    /// Add an selection in an array output port
    AddOutputArraySelection(String, String, String),
    /// Signal the end of an execution
    RunEnd(String, BoxedComp),
    /// Set the receiver of an input port
    SetReceiver(String, String, Receiver<IP>),
    /// The agent received an IP
    Inc(String),
    /// The agent read an IP
    Dec(String),
    /// Remove a agent
    Remove(String, Sender<SyncMsg>),
}

pub enum Signal {
    End,
    Continue,
}

/// This structure keep all the information for the "exterior scheduler".
///
/// These information must be accessible for the user of the scheduler
pub struct Comp {
    /// Keep the IPSender of the input ports
    pub inputs: HashMap<String, IPSender>,
    /// Keep the IPSender of the array input ports
    pub inputs_array: HashMap<String, HashMap<String, IPSender>>,
    /// The type of the agent
    pub sort: String,
    /// True if a agent had no input port
    pub start: bool,
}

/// the exterior scheduler. The end user use the methods of this structure.
pub struct Scheduler {
    /// Keep the dylib of the loaded agents
    pub cache: AgentCache,
    /// Keep the agent
    pub agents: HashMap<String, Comp>,
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
                    CompMsg::NewAgent(name, comp) => { sched_s.new_agent(name, comp) },
                    CompMsg::Start(name) => { sched_s.start(name) },
                    CompMsg::Halt => { break; },
                    CompMsg::HaltState => { sched_s.halt() },
                    CompMsg::RunEnd(name, boxed_comp) => { sched_s.run_end(name, boxed_comp) },
                    CompMsg::AddInputArraySelection(name, port, selection, recv) => {
                        sched_s.edit_agent(name, EditCmp::AddInputArraySelection(port, selection, recv))
                    },
                    CompMsg::RemoveInputArraySelection(name, port, selection) => {
                        sched_s.edit_agent(name, EditCmp::RemoveInputArraySelection(port, selection))
                    },
                    CompMsg::AddOutputArraySelection(name, port, selection) => {
                        sched_s.edit_agent(name, EditCmp::AddOutputArraySelection(port, selection))
                    },
                    CompMsg::ConnectOutputPort(comp_out, port_out, sender) => {
                        sched_s.edit_agent(comp_out, EditCmp::ConnectOutputPort(port_out, sender))
                    },
                    CompMsg::ConnectOutputArrayPort(comp_out, port_out, selection_out, sender) => {
                        sched_s.edit_agent(comp_out, EditCmp::ConnectOutputArrayPort(port_out, selection_out, sender))
                    },
                    CompMsg::SetReceiver(comp, port, receiver) => {
                        sched_s.edit_agent(comp, EditCmp::SetReceiver(port, receiver))
                    },
                    CompMsg::Disconnect(name, port) => {
                        sched_s.edit_agent(name, EditCmp::Disconnect(port))
                    },
                    CompMsg::DisconnectArray(name, port, selection) => {
                        sched_s.edit_agent(name, EditCmp::DisconnectArray(port, selection))
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
            cache: AgentCache::new(),
            agents: HashMap::new(),
            sender: s,
            error_receiver: error_r,
            th: th,
        }
    }

    /// Add a agent to the scheduler
    ///
    /// The sort is a complete path to the dylib
    ///
    /// # Example
    ///
    /// ```rust,ignore
    /// try!(sched.add_node("add", "/home/xxx/agents/add.so");
    /// ```
    pub fn add_node(&mut self, name: &str, sort: &str) -> Result<()> {
        let name = name.to_string();
        let (comp, senders) = self.cache.create_comp(sort, name.clone(), self.sender.clone()).expect("cannot create comp");
        let start = !comp.is_input_ports();
        self.sender.send(CompMsg::NewAgent(name.clone(), comp)).expect("Cannot send to sched state");
        let s_acc = try!(senders.get("acc").ok_or(result::Error::PortNotFound(name.clone(), "acc".into()))).clone();
        self.agents.insert(name.clone(),
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
    /// Start all the agent that have no input ports
    ///
    /// # Example
    ///
    /// ```rust,ignore
    /// sched.start();
    /// ```
    pub fn start(&self) {
        for (name, comp) in &self.agents {
            if comp.start {
                self.sender.send(CompMsg::Start(name.clone())).expect("start: unable to send to sched state");
            }
        }
    }

    /// Start the agent `name` if it has no input port
    ///
    /// # Example
    ///
    /// ```rust,ignore
    /// try!(sched.start_if_needed("add"));
    /// ```
    pub fn start_if_needed(&self, name: &str) -> Result<()> {
        self.agents.get(name).ok_or(result::Error::AgentNotFound(name.into()))
            .and_then(|comp| {
                if comp.start {
                    self.sender.send(CompMsg::Start(name.into())).expect("start_if_needed");
                }
                Ok(())
            })
    }

    /// Start a agent, even if it has an input port
    ///
    /// # Example
    /// ```rust,ignore
    /// sched.start_agent("add");
    /// ```
    pub fn start_agent(&self, name: String) {
        self.sender.send(CompMsg::Start(name)).expect("start: unable to send to sched state");
    }

    /// Remove a agent form the scheduler and retrieve all the information
    ///
    /// # Example
    /// ```rust,ignore
    /// let (boxed_comp, comp) = try!(sched.remove_agent("add"));
    /// assert!(boxed_comp.is_input_ports());
    /// ```
    pub fn remove_agent(&mut self, name: String) -> Result<(BoxedComp, Comp)>{
        let (s, r) = channel();
        self.sender.send(CompMsg::Remove(name.clone(), s)).expect("Scheduler remove_agent: cannot send to the state");
        let response = try!(r.recv());
        match response {
            SyncMsg::Remove(boxed_comp) => {
                Ok((boxed_comp, try!(self.agents.remove(&name).ok_or(result::Error::AgentNotFound(name.into())))))
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
        let (r, s) = IPReceiver::new(
            comp_name.clone(),
            self.sender.clone(),
            true
        );
        try!(self.agents.get_mut(&comp_name).ok_or(result::Error::AgentNotFound(comp_name.clone()))
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
        if let Some(comp) = self.agents.get(&comp) {
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
    /// Usefull for replacing a agent
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
    /// Usefull for replacing a agent
    ///
    /// # Example
    /// ```rust,ignore
    /// try!(sched.set_array_receiver("add".into(), "inputs".into(), "1".into(), recv));
    /// ```
    pub fn set_array_receiver(&self, comp: String, port: String, selection: String, receiver: IPReceiver) -> Result<()> {
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
        self.agents.get(comp).ok_or(result::Error::AgentNotFound(comp.into()))
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
        self.agents.get(comp).ok_or(result::Error::AgentNotFound(comp.into()))
            .and_then(|c| {
                c.inputs_array.get(port).ok_or(result::Error::PortNotFound(comp.into(), port.into()))
                    .and_then(|p| {
                        p.get(selection).ok_or(result::Error::SelectionNotFound(comp.into(), port.into(), selection.into()))
                            .map(|s| { s.clone() })
                    })
            })
    }

    /// Get the edge of an input port
    ///
    /// # Example
    /// ```rust,ignore
    /// let edge = try!(sched.get_schema_input("add", "input"));
    /// ```
    pub fn get_schema_input(&self, comp: &str, port: &str) -> Result<String> {
        self.agents.get(comp).ok_or(result::Error::AgentNotFound(comp.into()))
            .and_then(|c| {
                self.cache.get_schema_input(&c.sort, port)
            })
    }

    /// Get the edge of an array input port
    ///
    /// # Example
    /// ```rust,ignore
    /// let edge = try!(sched.get_schema_input_array("add", "inputs"));
    /// ```
    pub fn get_schema_input_array(&self, comp: &str, port: &str) -> Result<String> {
        self.agents.get(comp).ok_or(result::Error::AgentNotFound(comp.into()))
            .and_then(|c| {
                self.cache.get_schema_input_array(&c.sort, port)
            })
    }

    /// Get the edge of an output port
    ///
    /// # Example
    /// ```rust,ignore
    /// let edge = try!(sched.get_schema_output("add", "output"));
    /// ```
    pub fn get_schema_output(&self, comp: &str, port: &str) -> Result<String> {
        self.agents.get(comp).ok_or(result::Error::AgentNotFound(comp.into()))
            .and_then(|c| {
                self.cache.get_schema_output(&c.sort, port)
            })
    }

    /// Get the edge of an array output port
    ///
    /// # Example
    /// ```rust,ignore
    /// let edge = try!(sched.get_schema_output_array("add", "outputs"));
    /// ```
    pub fn get_schema_output_array(&self, comp: &str, port: &str) -> Result<String> {
        self.agents.get(comp).ok_or(result::Error::AgentNotFound(comp.into()))
            .and_then(|c| {
                self.cache.get_schema_output_array(&c.sort, port)
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
    AddInputArraySelection(String, String, IPReceiver),
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

/// Internal representation of a agent
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
    agents: HashMap<String, CompState>,
    connections: usize,
    can_halt: bool,
    pool: ThreadPool,
}

impl SchedState {
    fn new(s: Sender<CompMsg>) -> Self {
        SchedState {
            sched_sender: s,
            agents: HashMap::new(),
            connections: 0,
            can_halt: false,
            pool: ThreadPool::new(8),
        }
    }

    fn inc(&mut self, name: String) -> Result<()> {
        // silent error for exterior ports
        let mut start = false;
        if let Some(ref mut comp) = self.agents.get_mut(&name) {
            comp.ips += 1;
            start = comp.ips > 0 && comp.comp.is_some();
        }
        if start { self.run(name); }
        Ok(())
    }

    fn dec(&mut self, name: String) -> Result<()> {
        // silent error for exterior ports
        if let Some(ref mut comp) = self.agents.get_mut(&name) {
            comp.ips -= 1;
        }
        Ok(())
    }

    fn new_agent(&mut self, name: String, comp: BoxedComp) -> Result<()> {
        self.agents.insert(name, CompState {
            comp: Some(comp),
            can_run: false,
            edit_msgs: vec![],
            ips: 0,
        });
        Ok(())
    }

    fn remove(&mut self, name: String, sync_sender: Sender<SyncMsg>) -> Result<()>{
        let must_remove = {
            let mut o_comp = self.agents.get_mut(&name).expect("SchedState remove : agent doesn't exist");
            let b_comp = mem::replace(&mut o_comp.comp, None);
            if let Some(boxed_comp) = b_comp {
                sync_sender.send(SyncMsg::Remove(boxed_comp)).expect("SchedState remove : cannot send to the channel");
                true
            } else {
                sync_sender.send(SyncMsg::CannotRemove).expect("SchedState remove : cannot send to the channel");
                false
            }
        };
        if must_remove { self.agents.remove(&name); }
        Ok(())
    }

    fn start(&mut self, name: String) -> Result<()> {
        let start = {
            let mut comp = self.agents.get_mut(&name).expect("SchedState start : agent not found");
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
            let mut comp = self.agents.get_mut(&name).expect("SchedState RunEnd : agent doesn't exist");
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
        let mut o_comp = self.agents.get_mut(&name).expect("SchedSate run : agent doesn't exist");
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

    fn edit_agent(&mut self, name: String, msg: EditCmp) -> Result<()> {
        let mut comp = self.agents.get_mut(&name).expect("SchedState edit_agent : agent doesn't exist");
        if let Some(ref mut c) = comp.comp {
            let mut c = c;
            try!(Self::edit_one_comp(&mut c, msg));
        } else {
            comp.edit_msgs.push(msg);
        }
        Ok(())
    }

    fn edit_one_comp(mut c: &mut BoxedComp, msg: EditCmp) -> Result<()> {
        // let mut c = c.get_ports();
        match msg {
            EditCmp::AddInputArraySelection(port, selection, recv) => {
                // try!(c.add_input_receiver(&port, selection, recv));
                c.add_inarr_element(&port, selection, recv)?;
            },
            EditCmp::RemoveInputArraySelection(port, selection) => {
                unimplemented!();
                // try!(c.remove_array_receiver(&port, &selection));
            }
            EditCmp::AddOutputArraySelection(port, selection) => {
                unimplemented!();
                //try!(c.add_output_selection(&port, selection));
            },
            EditCmp::ConnectOutputPort(port_out, his) => {
                c.connect(&port_out, his)?;
            },
            EditCmp::ConnectOutputArrayPort(port_out, selection_out, his) => {
                c.connect_array(&port_out, selection_out, his)?;
            },
            EditCmp::SetReceiver(port, hir) => {
                unimplemented!();
                //c.set_receiver(port, hir);
            }
            EditCmp::Disconnect(port) => {
                unimplemented!();
                //try!(c.disconnect(port));
            },
            EditCmp::DisconnectArray(port, selection) => {
                unimplemented!();
                //try!(c.disconnect_array(port, selection));
            },
        }
        Ok(())
    }
}

/// Contains all the information of a dylib agents
#[allow(dead_code)]
pub struct AgentLoader {
    lib: libloading::Library,
    create: extern "C" fn(String, Sender<CompMsg>) -> Result<(Box<Agent + Send>, HashMap<String, IPSender>)>,
    get_schema_input: extern "C" fn(&str) -> Result<String>,
    get_schema_input_array: extern "C" fn(&str) -> Result<String>,
    get_schema_output: extern "C" fn(&str) -> Result<String>,
    get_schema_output_array: extern "C" fn(&str) -> Result<String>,
}

/// Keep all the dylib agents and load them
pub struct AgentCache {
    cache: HashMap<String, AgentLoader>,
}

impl AgentCache {
    ///  create a new AgentCache
    ///
    /// # Example
    /// ```rust,ignore
    /// let cc = AgentCache::new();
    /// ```
    pub fn new() -> Self {
        AgentCache {
            cache: HashMap::new(),
        }
    }

    /// Load a new agent from the system file
    ///
    /// # Example
    /// ```rust,ignore
    /// try!(cc.create_comp("/home/xxx/agents/add.so", "add", sched_sender));
    /// ```
    pub fn create_comp(&mut self, path: &str, name: String, sender: Sender<CompMsg>) -> Result<(Box<Agent + Send>, HashMap<String, IPSender>)> {
        if !self.cache.contains_key(path) {
            let lib_comp = libloading::Library::new(path).expect("cannot load");

            let new_comp: extern fn(String, Sender<CompMsg>) -> Result<(Box<Agent + Send>, HashMap<String, IPSender>)> = unsafe {
                *(lib_comp.get(b"create_agent\0").expect("cannot find create method"))
            };

            let get_in : extern fn(&str) -> Result<String> = unsafe {
                *(lib_comp.get(b"get_schema_input\0").expect("cannot find get input method"))
            };

            let get_in_a : extern fn(&str) -> Result<String> = unsafe {
                *(lib_comp.get(b"get_schema_input_array\0").expect("cannot find get input method"))
            };

            let get_out : extern fn(&str) -> Result<String> = unsafe {
                *(lib_comp.get(b"get_schema_output\0").expect("cannot find get output method"))
            };

            let get_out_a : extern fn(&str) -> Result<String> = unsafe {
                *(lib_comp.get(b"get_schema_output_array\0").expect("cannot find get output method"))
            };

            self.cache.insert(path.into(),
                              AgentLoader {
                                  lib: lib_comp,
                                  create: new_comp,
                                  get_schema_input: get_in,
                                  get_schema_input_array: get_in_a,
                                  get_schema_output: get_out,
                                  get_schema_output_array: get_out_a,
                              });
        }
        if let Some(loader) = self.cache.get(path){
            (loader.create)(name, sender)
        } else {
            unreachable!()
        }
    }

    /// Get the edge of an input port
    ///
    /// # Example
    /// ```rust,ignore
    /// cc.get_schema_input("add", "input");
    /// ```
    pub fn get_schema_input(&self, comp: &str, port: &str) -> Result<String> {
        self.cache.get(comp).ok_or(result::Error::AgentNotFound(comp.into()))
            .map(|comp| {
                (comp.get_schema_input)(port).expect("cannot get")
            })
    }

    /// Get the edge of an array input port
    ///
    /// # Example
    /// ```rust,ignore
    /// cc.get_schema_input_array("add", "inputs");
    /// ```
    pub fn get_schema_input_array(&self, comp: &str, port: &str) -> Result<String> {
        self.cache.get(comp).ok_or(result::Error::AgentNotFound(comp.into()))
            .map(|comp| {
                (comp.get_schema_input_array)(port).expect("cannot get")
            })
    }

    /// Get the edge of an output port
    ///
    /// # Example
    /// ```rust,ignore
    /// cc.get_schema_output("add", "output");
    /// ```
    pub fn get_schema_output(&self, comp: &str, port: &str) -> Result<String> {
        self.cache.get(comp).ok_or(result::Error::AgentNotFound(comp.into()))
            .map(|comp| {
                (comp.get_schema_output)(port).expect("cannot get")
            })
    }

    /// Get the edge of an array output port
    ///
    /// # Example
    /// ```rust,ignore
    /// cc.get_schema_output_array("add", "outputs");
    /// ```
    pub fn get_schema_output_array(&self, comp: &str, port: &str) -> Result<String> {
        self.cache.get(comp).ok_or(result::Error::AgentNotFound(comp.into()))
            .map(|comp| {
                (comp.get_schema_output_array)(port).expect("cannot get")
            })
    }
}

unsafe impl Send for AgentCache {}
