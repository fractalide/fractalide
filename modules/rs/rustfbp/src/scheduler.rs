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
use env_logger;
use result;
use result::Result;

use ports::{MsgSender, MsgReceiver};
use agent::Agent;

use std::borrow::Cow;
use std::any::Any;

use std::collections::HashMap;
use std::sync::mpsc::{Sender, Receiver};
use std::sync::mpsc::channel;

use std::thread;
use std::thread::JoinHandle;

use std::mem;
use std;
use std::io::Write;
use agent;
use edges;

/// A boxed comp is a agent that can be send between thread
pub type BoxedComp = Box<Agent + Send>;
// TODO : manage "can_run": allow a user to pause a agent

/// All the messages that can be send between the "exterior scheduler" and the "interior scheduler".
pub enum CompMsg<Msg> {
    /// Add a new agent. The String is the name, the BoxedComp is the agent itself
    NewAgent(usize, String, BoxedComp),
    /// Stop the scheduler
    Halt,
    /// Try to stop the sheduler state
    HaltState,
    /// Start a agent
    Start(usize),
    /// Connect the output port
    ConnectOutputPort(usize, String, MsgSender<Msg>),
    /// Connect the array output port
    ConnectOutputArrayPort(usize, String, String, MsgSender<Msg>),
    /// Disconnect an output port
    Disconnect(usize, String),
    /// Disconnect an array output port
    DisconnectArray(usize, String, String),
    /// Add an element in an array input port
    AddInputArrayElement(usize, String, String, MsgReceiver<Msg>),
    /// Remove an element in an array input port
    RemoveInputArrayElement(usize, String, String),
    /// Add an element in an array output port
    AddOutputArrayElement(usize, String, String),
    /// Signal the end of an execution
    RunEnd(usize, BoxedComp, Result<Signal>),
    /// Set the receiver of an input port
    SetReceiver(usize, String, MsgReceiver<Msg>),
    /// The agent received an Msg
    Inc(usize),
    /// The agent read an Msg
    Dec(usize),
    /// Remove a agent
    Remove(usize, Sender<SyncMsg>),
}

pub enum Signal {
    End,
    Continue,
}

/// This structure keep all the information for the "exterior scheduler".
///
/// These information must be accessible for the user of the scheduler
pub struct Comp<Msg> {
    pub id: usize,
    /// Keep the MsgSender of the input ports
    pub inputs: HashMap<String, MsgSender<Msg>>,
    /// Keep the MsgSender of the array input ports
    pub inputs_array: HashMap<String, HashMap<String, MsgSender<Msg>>>,
    /// The type of the agent
    pub sort: String,
    /// True if a agent had no input port
    pub start: bool,
}

/// the exterior scheduler. The end user use the methods of this structure.
pub struct Scheduler {
    /// Keep the dylib of the loaded agents
    pub cache: AgentCache<edges::Msg>,
    /// Keep the agent
    pub agents: HashMap<String, Comp<edges::Msg>>,
    /// A sender to send message to the scheduler
    pub sender: Sender<CompMsg<edges::Msg>>,
    /// Received the error from the "interior scheduler"
    pub error_receiver: Receiver<result::Error>,
    id: usize,
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
                let msg = r.recv().expect("no message received");
                let res: Result<()> = match msg {
                    CompMsg::NewAgent(id, name, comp) => { sched_s.new_agent(id, name, comp) },
                    CompMsg::Start(name) => { sched_s.start(name) },
                    CompMsg::Halt => { break; },
                    CompMsg::HaltState => { sched_s.halt() },
                    CompMsg::RunEnd(name, boxed_comp, res) => { sched_s.run_end(name, boxed_comp, res) },
                    CompMsg::AddInputArrayElement(name, port, element, recv) => {
                        sched_s.edit_agent(name, EditCmp::AddInputArrayElement(port, element, recv))
                    },
                    CompMsg::RemoveInputArrayElement(name, port, element) => {
                        sched_s.edit_agent(name, EditCmp::RemoveInputArrayElement(port, element))
                    },
                    CompMsg::AddOutputArrayElement(name, port, element) => {
                        sched_s.edit_agent(name, EditCmp::AddOutputArrayElement(port, element))
                    },
                    CompMsg::ConnectOutputPort(comp_out, port_out, sender) => {
                        sched_s.edit_agent(comp_out, EditCmp::ConnectOutputPort(port_out, sender))
                    },
                    CompMsg::ConnectOutputArrayPort(comp_out, port_out, element_out, sender) => {
                        sched_s.edit_agent(comp_out, EditCmp::ConnectOutputArrayPort(port_out, element_out, sender))
                    },
                    CompMsg::SetReceiver(comp, port, receiver) => {
                        sched_s.edit_agent(comp, EditCmp::SetReceiver(port, receiver))
                    },
                    CompMsg::Disconnect(name, port) => {
                        sched_s.edit_agent(name, EditCmp::Disconnect(port))
                    },
                    CompMsg::DisconnectArray(name, port, element) => {
                        sched_s.edit_agent(name, EditCmp::DisconnectArray(port, element))
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
            id: 0,
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
    pub fn add_node<'a, A, B>(&mut self, name: A, sort: B) -> Result<()> where
        A: Into<Cow<'a, str>>,
        B: Into<Cow<'a, str>>
    {
        let name = name.into().into_owned();
        let sort = sort.into().into_owned();
        let (comp, senders) = self.cache.create_comp(&sort, self.id, self.sender.clone()).expect("cannot create comp");
        let start = !comp.is_input_ports();
        self.sender.send(CompMsg::NewAgent(self.id, name.clone(), comp)).expect("Cannot send to sched state");
        //let s_acc = try!(senders.get("accumulator").ok_or(result::Error::PortNotFound(name.clone(), "accumulator".into()))).clone();
        self.agents.insert(name.clone(),
                               Comp {
                                   id: self.id,
                                   inputs: senders,
                                   inputs_array: HashMap::new(),
                                   sort: sort,
                                   start: start,
                               });
        // self.sender.send(CompMsg::ConnectOutputPort(self.id, "accumulator".into(), s_acc)).expect("Cannot send to sched state");
        self.id += 1;
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
        for comp in self.agents.values() {
            if comp.start {
                self.sender.send(CompMsg::Start(comp.id)).expect("start: unable to send to sched state");
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
    pub fn start_if_needed<'a, A: Into<Cow<'a, str>>>(&self, name: A) -> Result<()> {
        let name = name.into().into_owned();
        self.agents.get(&name).ok_or(result::Error::AgentNotFound(name.clone()))
            .and_then(|comp| {
                if comp.start {
                    self.sender.send(CompMsg::Start(comp.id)).expect("start_if_needed");
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
    pub fn start_agent<'a, A>(&self, name: A) -> Result<()> where
        A: Into<Cow<'a, str>>
    {
        let name = name.into();
        let comp = self.agents.get(&name as &str).ok_or(result::Error::AgentNotFound(name.into_owned()))?;
        self.sender.send(CompMsg::Start(comp.id)).expect("start: unable to send to sched state");
        Ok(())
    }

    /// Remove a agent form the scheduler and retrieve all the information
    ///
    /// # Example
    /// ```rust,ignore
    /// let (boxed_comp, comp) = try!(sched.remove_agent("add"));
    /// assert!(boxed_comp.is_input_ports());
    /// ```
    pub fn remove_agent<'a, A: Into<Cow<'a, str>>>(&mut self, name: A) -> Result<(BoxedComp, Comp<edges::Msg>)>{
        /*
        let name = name.into().into_owned();
        let (s, r) = channel();
        {
            let comp = self.agents.get(&name).ok_or(result::Error::AgentNotFound(name.clone()))?;
            self.sender.send(CompMsg::Remove(comp.id, s)).expect("Scheduler remove_agent: cannot send to the state");
        }
        let response = try!(r.recv());
        match response {
            SyncMsg::Remove(boxed_comp) => {
                Ok((boxed_comp, try!(self.agents.remove(&name).ok_or(result::Error::AgentNotFound(name.into())))))
            },
            SyncMsg::CannotRemove => {
                Err(result::Error::CannotRemove(name))
            },
        }
         */
        unimplemented!()
    }

    /// Connect a simple output port to a simple input port
    ///
    /// # Example
    /// ```rust,ignore
    /// try!(sched.connect("add", "output", "display", "input"));
    /// ```
    pub fn connect<'a, A, B, C, D>(&self, comp_out: A, port_out: B, comp_in: C, port_in: D) -> Result<()> where
        A: Into<Cow<'a, str>>,
        B: Into<Cow<'a, str>>,
        C: Into<Cow<'a, str>>,
        D: Into<Cow<'a, str>>
    {
        let comp_out = comp_out.into().into_owned();
        let port_out = port_out.into().into_owned();
        let comp_in = &*(comp_in.into());
        let port_in = &*(port_in.into());
        // Check schema
        let sort_in = self.agents.get(comp_in).ok_or(result::Error::AgentNotFound(comp_in.into()))?;
        let sort_out = self.agents.get(&comp_out).ok_or(result::Error::AgentNotFound(comp_out.clone()))?;
        let in_schema = self.cache.get_schema_input(&sort_in.sort, port_in)?;
        let out_schema = self.cache.get_schema_output(&sort_out.sort, &port_out)?;
        if in_schema != "BAny" && out_schema != "BAny" && in_schema != out_schema {
            return Err(result::Error::BadSchema(comp_out.clone(), port_out.clone(), out_schema, comp_in.into(), port_in.into(), in_schema));
        }

        let sender = try!(self.get_sender(comp_in, port_in));
        let comp = self.agents.get(&comp_out).ok_or(result::Error::AgentNotFound(comp_out.clone()))?;
        self.sender.send(CompMsg::ConnectOutputPort(comp.id, port_out, sender)).ok().expect("Scheduler connect: unable to send to sched state");
        Ok(())
    }

    /// Connect a array output port to a simple input port
    ///
    /// # Example
    /// ```rust,ignore
    /// try!(sched.connect_array("add", "outputs", "1", "display", "input"));
    /// ```
    pub fn connect_array<'a, A, B, C, D, E>(&self, comp_out: A, port_out: B, element_out: C, comp_in: D, port_in: E) -> Result<()> where
        A: Into<Cow<'a, str>>,
        B: Into<Cow<'a, str>>,
        C: Into<Cow<'a, str>>,
        D: Into<Cow<'a, str>>,
        E: Into<Cow<'a, str>>
    {
        let comp_out = comp_out.into().into_owned();
        let port_out = port_out.into().into_owned();
        let element_out = element_out.into().into_owned();
        let comp_in = &*(comp_in.into());
        let port_in = &*(port_in.into());
        // Check schema
        let sort_in = self.agents.get(comp_in).ok_or(result::Error::AgentNotFound(comp_in.into()))?;
        let sort_out = self.agents.get(&comp_out).ok_or(result::Error::AgentNotFound(comp_out.clone()))?;
        let in_schema = self.cache.get_schema_input(&sort_in.sort, port_in)?;
        let out_schema = self.cache.get_schema_output_array(&sort_out.sort, &port_out)?;
        if in_schema != "BAny" && out_schema != "BAny" && in_schema != out_schema {
            return Err(result::Error::BadSchema(comp_out.clone(), port_out.clone(), out_schema, comp_in.into(), port_in.into(), in_schema));
        }

        let sender = try!(self.get_sender(comp_in, port_in));
        let comp = self.agents.get(&comp_out).ok_or(result::Error::AgentNotFound(comp_out.clone()))?;
        self.sender.send(CompMsg::ConnectOutputArrayPort(comp.id, port_out, element_out, sender)).ok().expect("Scheduler connect: unable to send to scheduler state");
        Ok(())
    }

    /// Connect a simple output port to an array input port
    ///
    /// # Example
    /// ```rust,ignore
    /// try!(sched.connect_to_array("add", "output", "display", "inputs", "1"));
    /// ```
    pub fn connect_to_array<'a, A, B, C, D, E>(&self, comp_out: A, port_out: B, comp_in: C, port_in: D, element_in: E) -> Result<()> where
        A: Into<Cow<'a, str>>,
        B: Into<Cow<'a, str>>,
        C: Into<Cow<'a, str>>,
        D: Into<Cow<'a, str>>,
        E: Into<Cow<'a, str>>
    {
        let comp_out = comp_out.into().into_owned();
        let port_out = port_out.into().into_owned();
        let comp_in = &*(comp_in.into());
        let port_in = &*(port_in.into());
        let element_in = &*(element_in.into());
        // Check schema
        let sort_in = self.agents.get(comp_in).ok_or(result::Error::AgentNotFound(comp_in.into()))?;
        let sort_out = self.agents.get(&comp_out).ok_or(result::Error::AgentNotFound(comp_out.clone()))?;
        let in_schema = self.cache.get_schema_input_array(&sort_in.sort, port_in)?;
        let out_schema = self.cache.get_schema_output(&sort_out.sort, &port_out)?;
        if in_schema != "BAny" && out_schema != "BAny" && in_schema != out_schema {
            return Err(result::Error::BadSchema(comp_out.clone(), port_out.clone(), out_schema, comp_in.into(), port_in.into(), in_schema));
        }

        let sender = try!(self.get_array_sender(comp_in, port_in, element_in));
        let comp = self.agents.get(&comp_out).ok_or(result::Error::AgentNotFound(comp_out.clone()))?;
        self.sender.send(CompMsg::ConnectOutputPort(comp.id, port_out, sender)).ok().expect("Scheduler connect: unable to send to scheduler state");
        Ok(())
    }

    /// Connect an array output port to an array input port
    ///
    /// # Example
    /// ```rust,ignore
    /// try!(sched.connect_array_to_array("add", "outputs", "1", "display", "inputs", "1"));
    /// ```
    pub fn connect_array_to_array<'a, A, B, C, D, E, F>(&self, comp_out: A, port_out: B, element_out: C, comp_in: D, port_in: E, element_in: F) -> Result<()> where
        A: Into<Cow<'a, str>>,
        B: Into<Cow<'a, str>>,
        C: Into<Cow<'a, str>>,
        D: Into<Cow<'a, str>>,
        E: Into<Cow<'a, str>>,
        F: Into<Cow<'a, str>>
    {
        let comp_out = comp_out.into().into_owned();
        let port_out = port_out.into().into_owned();
        let element_out = element_out.into().into_owned();
        let comp_in = &*(comp_in.into());
        let port_in = &*(port_in.into());
        let element_in = &*(element_in.into());
        // Check schema
        let sort_in = self.agents.get(comp_in).ok_or(result::Error::AgentNotFound(comp_in.into()))?;
        let sort_out = self.agents.get(&comp_out).ok_or(result::Error::AgentNotFound(comp_out.clone()))?;
        let in_schema = self.cache.get_schema_input_array(&sort_in.sort, port_in)?;
        let out_schema = self.cache.get_schema_output_array(&sort_out.sort, &port_out)?;
        if in_schema != "BAny" && out_schema != "BAny" && in_schema != out_schema {
            return Err(result::Error::BadSchema(comp_out.clone(), port_out.clone(), out_schema, comp_in.into(), port_in.into(), in_schema));
        }

        let sender = try!(self.get_array_sender(comp_in, port_in, element_in));
        let comp = self.agents.get(&comp_out).ok_or(result::Error::AgentNotFound(comp_out.clone()))?;
        self.sender.send(CompMsg::ConnectOutputArrayPort(comp.id, port_out, element_out, sender)).ok().expect("Scheduler connect: unable to send to scheduler state");
        Ok(())
    }

    /// disconnect an output port
    ///
    /// # Example
    /// ```rust,ignore
    /// try!(sched.disconnect("add", "output"));
    /// ```
    pub fn disconnect<'a, A, B>(&self, comp_out: A, port_out: B) -> Result<()> where
        A: Into<Cow<'a, str>>,
        B: Into<Cow<'a, str>>,
    {
        let comp_out = comp_out.into().into_owned();
        let port_out = port_out.into().into_owned();
        let comp = self.agents.get(&comp_out).ok_or(result::Error::AgentNotFound(comp_out.clone()))?;
        self.sender.send(CompMsg::Disconnect(comp.id, port_out)).ok().expect("Scheduler disconnect: unable to send to scheduler state");
        Ok(())
    }

    /// disconnect an array output port
    ///
    /// # Example
    /// ```rust,ignore
    /// try!(sched.disconnect_array("add", "outputs", "1"));
    /// ```
    pub fn disconnect_array<'a, A, B, C>(&self, comp_out: A, port_out: B, element: C) -> Result<()> where
        A: Into<Cow<'a, str>>,
        B: Into<Cow<'a, str>>,
        C: Into<Cow<'a, str>>,
    {
        let comp_out = comp_out.into().into_owned();
        let port_out = port_out.into().into_owned();
        let element = element.into().into_owned();
        let comp = self.agents.get(&comp_out).ok_or(result::Error::AgentNotFound(comp_out.clone()))?;
        self.sender.send(CompMsg::DisconnectArray(comp.id, port_out, element)).ok().expect("Scheduler disconnect_array: unable to send to scheduler state");
        Ok(())
    }

    /// Add a element in an input array port
    ///
    /// # Example
    /// ```rust,ignore
    /// try!(sched.add_input_array_element("add".into(), "inputs".into(), "1".into()));
    /// ```
    pub fn add_input_array_element<'a, A, B, C>(&mut self, comp_name: A, port: B, element: C) -> Result<()> where
        A: Into<Cow<'a, str>>,
        B: Into<Cow<'a, str>>,
        C: Into<Cow<'a, str>>,
    {
        // TODO: the cache must create the channel of the right type
        let comp_name = comp_name.into().into_owned();
        let port = port.into().into_owned();
        let element = element.into().into_owned();

        let (r, s, comp_id) = {
            let comp = self.agents.get(&comp_name).ok_or(result::Error::AgentNotFound(comp_name.clone()))?;
            let (r, s) = self.cache.create_input_array(&comp.sort, &port, comp.id, self.sender.clone(), true)?;
            (r, s, comp.id)
        };

        try!(self.agents.get_mut(&comp_name).ok_or(result::Error::AgentNotFound(comp_name.clone()))
            .and_then(|mut comp| {
                if !comp.inputs_array.contains_key(&port) {
                    comp.inputs_array.insert(port.clone(), HashMap::new());
                }
                comp.inputs_array.get_mut(&port).ok_or(result::Error::ElementNotFound(comp_name.clone(), port.clone(), element.clone()))
                    .and_then(|mut port| {
                        port.insert(element.clone(), s);
                        Ok(())
                    })
            }));
        self.sender.send(CompMsg::AddInputArrayElement(comp_id, port, element, r)).ok().expect("Scheduler add_input_array_element : Unable to send to scheduler state");
        Ok(())
    }

    // pub fn remove_input_array_element(&mut self, comp: String, port: String, element: String) -> Result<()> {
    //     // TODO
    // }

    /// Add a element in an input array port, only if this element exists not yet
    ///
    /// # Example
    /// ```rust,ignore
    /// try!(sched.soft_add_input_array_element("add".into(), "inputs".into(), "1".into()));
    /// ```
    pub fn soft_add_input_array_element<'a, A, B, C>(&mut self, comp: A, port: B, element: C) -> Result<()> where
        A: Into<Cow<'a, str>>,
        B: Into<Cow<'a, str>>,
        C: Into<Cow<'a, str>>
    {
        let mut res = true;
        let comp = comp.into();
        let port = port.into();
        let element = element.into();
        {
            let c = &(comp) as &str;
            let p = &(port) as &str;
            let e = &(element) as &str;
            if let Some(comp) = self.agents.get(c) {
                if let Some(port) = comp.inputs_array.get(p) {
                    if let Some(_) = port.get(e) {
                        res = false;
                    }
                }
            }
        }
        if res {
            self.add_input_array_element(comp, port, element)
        } else {
            Ok(())
        }
    }

    /// Add a element in an output array port
    ///
    /// # Example
    /// ```rust,ignore
    /// try!(sched.add_output_array_element("add".into(), "inputs".into(), "1".into()));
    /// ```
    pub fn add_output_array_element<'a, A, B, C>(&self, comp: A, port: B, element: C) -> Result<()> where
        A: Into<Cow<'a, str>>,
        B: Into<Cow<'a, str>>,
        C: Into<Cow<'a, str>>
    {
        let comp = comp.into();
        let port = port.into().into_owned();
        let element = element.into().into_owned();
        let comp = self.agents.get(&comp as &str).ok_or(result::Error::AgentNotFound(comp.into_owned()))?;
        self.sender.send(CompMsg::AddOutputArrayElement(comp.id, port, element)).ok().expect("Scheduler add_output_array_element : Unable to send to scheduler state");
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
    pub fn set_receiver<'a, A, B>(&self, comp: A, port: B, receiver: MsgReceiver<edges::Msg>) -> Result<()> where
        A: Into<Cow<'a, str>>,
        B: Into<Cow<'a, str>>,
    {
        let comp = comp.into();
        let port = port.into().into_owned();
        let comp = self.agents.get(&comp as &str).ok_or(result::Error::AgentNotFound(comp.into_owned()))?;
        self.sender.send(CompMsg::SetReceiver(comp.id, port, receiver)).expect("scheduler cannot send");
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
    pub fn set_array_receiver<'a, A, B, C>(&self, comp: A, port: B, element: C, receiver: MsgReceiver<edges::Msg>) -> Result<()> where
        A: Into<Cow<'a, str>>,
        B: Into<Cow<'a, str>>,
        C: Into<Cow<'a, str>>
    {
        let comp = comp.into();
        let port = port.into().into_owned();
        let element = element.into().into_owned();
        let comp = self.agents.get(&comp as &str).ok_or(result::Error::AgentNotFound(comp.into_owned()))?;
        self.sender.send(CompMsg::AddInputArrayElement(comp.id, port, element, receiver)).expect("scheduler cannot send");
        Ok(())
    }

    /// Get the sender of a input port
    ///
    /// # Example
    /// ```rust,ignore
    /// let sender = try!(sched.get_sender("add", "input"));
    /// ```
    pub fn get_sender<'a, A, B>(&self, comp: A, port: B) -> Result<MsgSender<edges::Msg>> where
        A: Into<Cow<'a, str>>,
        B: Into<Cow<'a, str>>,
    {
        let comp = comp.into();
        let port = port.into();
        let c = self.agents.get(&comp as &str).ok_or(result::Error::AgentNotFound(comp.to_string()))?;
        let t = &c.sort;
        let s = c.inputs.get(&port as &str).ok_or(result::Error::PortNotFound(comp.to_string(), port.to_string()))?;
        self.cache.clone_input(t, &port, s)
    }

    /// Get the sender of an array input port
    ///
    /// # Example
    /// ```rust,ignore
    /// let sender = try!(sched.get_array_sender("add", "input", "1"));
    /// ```
    pub fn get_array_sender<'a, A, B, C>(&self, comp: A, port: B, element: C) -> Result<MsgSender<edges::Msg>> where
        A: Into<Cow<'a, str>>,
        B: Into<Cow<'a, str>>,
        C: Into<Cow<'a, str>>,
    {
        let comp = comp.into();
        let port = port.into();
        let element = element.into();
        let c = self.agents.get(&comp as &str).ok_or(result::Error::AgentNotFound(comp.to_string()))?;
        let t = &c.sort;
        let p = c.inputs_array.get(&port as &str).ok_or(result::Error::PortNotFound(comp.to_string(), port.to_string()))?;
        let s = p.get(&element as &str).ok_or(result::Error::ElementNotFound(comp.to_string(), port.to_string(), element.to_string()))?;
        self.cache.clone_input_array(t, &port, s)
    }

    /// Get the edge of an input port
    ///
    /// # Example
    /// ```rust,ignore
    /// let edge = try!(sched.get_schema_input("add", "input"));
    /// ```
    pub fn get_schema_input<'a, A, B>(&self, comp: A, port: B) -> Result<String> where
        A: Into<Cow<'a, str>>,
        B: Into<Cow<'a, str>>,
    {
        let comp = comp.into();
        let port = port.into();
        self.agents.get(&comp as &str).ok_or(result::Error::AgentNotFound(comp.to_string()))
            .and_then(|c| {
                self.cache.get_schema_input(&c.sort, &port as &str)
            })
    }

    /// Get the edge of an array input port
    ///
    /// # Example
    /// ```rust,ignore
    /// let edge = try!(sched.get_schema_input_array("add", "inputs"));
    /// ```
    pub fn get_schema_input_array<'a, A, B>(&self, comp: A, port: B) -> Result<String> where
        A: Into<Cow<'a, str>>,
        B: Into<Cow<'a, str>>,
    {
        let comp = comp.into();
        let port = port.into();
        self.agents.get(&comp as &str).ok_or(result::Error::AgentNotFound(comp.to_string()))
            .and_then(|c| {
                self.cache.get_schema_input_array(&c.sort, &port as &str)
            })
    }

    /// Get the edge of an output port
    ///
    /// # Example
    /// ```rust,ignore
    /// let edge = try!(sched.get_schema_output("add", "output"));
    /// ```
    pub fn get_schema_output<'a, A, B>(&self, comp: A, port: B) -> Result<String> where
        A: Into<Cow<'a, str>>,
        B: Into<Cow<'a, str>>,
    {
        let comp = comp.into();
        let port = port.into();
        self.agents.get(&comp as &str).ok_or(result::Error::AgentNotFound(comp.to_string()))
            .and_then(|c| {
                self.cache.get_schema_output(&c.sort, &port as &str)
            })
    }

    /// Get the edge of an array output port
    ///
    /// # Example
    /// ```rust,ignore
    /// let edge = try!(sched.get_schema_output_array("add", "outputs"));
    /// ```
    pub fn get_schema_output_array<'a, A, B>(&self, comp: A, port: B) -> Result<String> where
        A: Into<Cow<'a, str>>,
        B: Into<Cow<'a, str>>,
    {
        let comp = comp.into();
        let port = port.into();
        self.agents.get(&comp as &str).ok_or(result::Error::AgentNotFound(comp.to_string()))
            .and_then(|c| {
                self.cache.get_schema_output_array(&c.sort, &port as &str)
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

enum EditCmp<Msg> {
    AddInputArrayElement(String, String, MsgReceiver<Msg>),
    RemoveInputArrayElement(String, String),
    AddOutputArrayElement(String, String),
    ConnectOutputPort(String, MsgSender<Msg>),
    ConnectOutputArrayPort(String, String, MsgSender<Msg>),
    SetReceiver(String, MsgReceiver<Msg>),
    Disconnect(String),
    DisconnectArray(String, String),
}

/// To be removed, replace by async msg
pub enum SyncMsg {
    Remove(BoxedComp),
    CannotRemove,
}

/// Internal representation of a agent
struct CompState<Msg> {
    comp: Option<BoxedComp>,
    name: String,
    // TODO : manage can_run
    is_run: bool,
    can_run: bool,
    edit_msgs: Vec<EditCmp<Msg>>,
    ips: isize,
}

/// The state of the internal scheduler
struct SchedState<Msg> {
    sched_sender: Sender<CompMsg<Msg>>,
    agents: HashMap<usize, CompState<Msg>>,
    running: usize,
    can_halt: bool,
    pool: ThreadPool,
}

impl SchedState<edges::Msg> {
    fn new(s: Sender<CompMsg<edges::Msg>>) -> Self {
        SchedState {
            sched_sender: s,
            agents: HashMap::new(),
            running: 0,
            can_halt: false,
            pool: ThreadPool::new(8),
        }
    }

    fn inc(&mut self, id: usize) -> Result<()> {
        // silent error for exterior ports
        let mut start = false;
        if let Some(ref mut comp) = self.agents.get_mut(&id) {
            comp.ips += 1;
            start = comp.ips > 0 && comp.comp.is_some();
        }
        if start { self.run(id); }
        Ok(())
    }

    fn dec(&mut self, id: usize) -> Result<()> {
        // silent error for exterior ports
        if let Some(ref mut comp) = self.agents.get_mut(&id) {
            comp.ips -= 1;
        }
        Ok(())
    }

    fn new_agent(&mut self, id: usize, name: String, comp: BoxedComp) -> Result<()> {
        self.agents.insert(id, CompState {
            comp: Some(comp),
            name: name,
            is_run: false,
            can_run: false,
            edit_msgs: vec![],
            ips: 0,
        });
        Ok(())
    }

    fn remove(&mut self, id: usize, sync_sender: Sender<SyncMsg>) -> Result<()>{
        let must_remove = {
            let mut o_comp = self.agents.get_mut(&id).expect("SchedState remove : agent doesn't exist");
            let b_comp = mem::replace(&mut o_comp.comp, None);
            if let Some(boxed_comp) = b_comp {
                sync_sender.send(SyncMsg::Remove(boxed_comp)).expect("SchedState remove : cannot send to the channel");
                true
            } else {
                sync_sender.send(SyncMsg::CannotRemove).expect("SchedState remove : cannot send to the channel");
                false
            }
        };
        if must_remove { self.agents.remove(&id); }
        Ok(())
    }

    fn start(&mut self, id: usize) -> Result<()> {
        let start = {
            let mut comp = self.agents.get_mut(&id).expect("SchedState start : agent not found");
            comp.can_run = true;
            comp.comp.is_some()
        };
        if start {
            self.run(id);
        }
        Ok(())
    }

    fn halt(&mut self) -> Result<()> {
        self.can_halt = true;
        if self.running <= 0 {
            self.sched_sender.send(CompMsg::Halt).ok().expect("SchedState RunEnd : Cannot send Halt");
        }
        Ok(())
    }

    fn run_end(&mut self, id: usize, mut box_comp: BoxedComp, res: Result<Signal>) -> Result<()>{
        let must_restart = {
            let mut comp = self.agents.get_mut(&id).expect("SchedState RunEnd : agent doesn't exist");
            for msg in comp.edit_msgs.drain(..) {
                try!(Self::edit_one_comp(&mut box_comp, msg));
            }
            let must_restart = comp.ips > 0;
            comp.comp = Some(box_comp);
            if let Ok(Signal::End) = res {
                if comp.is_run {
                    self.running -= 1;
                    comp.is_run = false;
                }
            } else if let Err(e) = res {
                println!("{} fails : {}", comp.name, e);
            }
            must_restart
        };
        if must_restart {
            self.run(id);
        } else {
            if self.running <= 0 && self.can_halt {
                self.sched_sender.send(CompMsg::Halt).ok().expect("SchedState RunEnd : Cannot send Halt");
            }
        }
        Ok(())
    }
    #[allow(unused_must_use)]
    fn run(&mut self, id: usize) {
        let mut o_comp = self.agents.get_mut(&id).expect("SchedSate run : agent doesn't exist");
        if let Some(mut b_comp) = mem::replace(&mut o_comp.comp, None) {
            if !o_comp.is_run {
                self.running += 1;
                o_comp.is_run = true;
            }
            let sched_s = self.sched_sender.clone();
            self.pool.execute(move || {
                let res = b_comp.run();
                sched_s.send(CompMsg::RunEnd(id, b_comp, res)).expect("SchedState run : unable to send RunEnd");
            });
        };
    }

    fn edit_agent(&mut self, id: usize, msg: EditCmp<edges::Msg>) -> Result<()> {
        let mut comp = self.agents.get_mut(&id).expect("SchedState edit_agent : agent doesn't exist");
        if let Some(ref mut c) = comp.comp {
            let mut c = c;
            try!(Self::edit_one_comp(&mut c, msg));
        } else {
            comp.edit_msgs.push(msg);
        }
        Ok(())
    }

    fn edit_one_comp(mut c: &mut BoxedComp, msg: EditCmp<edges::Msg>) -> Result<()> {
        // let mut c = c.get_ports();
        match msg {
            EditCmp::AddInputArrayElement(port, element, recv) => {
                // try!(c.add_input_receiver(&port, element, recv));
                c.add_inarr_element(&port, element, recv)?;
            },
            EditCmp::RemoveInputArrayElement(_port, _element) => {
                unimplemented!();
                // try!(c.remove_array_receiver(&port, &element));
            }
            EditCmp::AddOutputArrayElement(_port, _element) => {
                unimplemented!();
                //try!(c.add_output_element(&port, element));
            },
            EditCmp::ConnectOutputPort(port_out, his) => {
                c.connect(&port_out, his)?;
            },
            EditCmp::ConnectOutputArrayPort(port_out, element_out, his) => {
                c.connect_array(&port_out, element_out, his)?;
            },
            EditCmp::SetReceiver(_port, _hir) => {
                unimplemented!();
                //c.set_receiver(port, hir);
            }
            EditCmp::Disconnect(_port) => {
                unimplemented!();
                //try!(c.disconnect(port));
            },
            EditCmp::DisconnectArray(_port, _element) => {
                unimplemented!();
                //try!(c.disconnect_array(port, element));
            },
        }
        Ok(())
    }
}

/// Contains all the information of a dylib agents
#[allow(dead_code)]
pub struct AgentLoader<Msg> {
    lib: libloading::Library,
    create: extern "C" fn(usize, Sender<CompMsg<Msg>>) -> Result<(Box<Agent + Send>, HashMap<String, MsgSender<Msg>>)>,
    clone_input: extern "C" fn(&str, &MsgSender<Msg>) -> Result<MsgSender<Msg>>,
    clone_input_array: extern "C" fn(&str, &MsgSender<Msg>) -> Result<MsgSender<Msg>>,
    create_input_array: extern "C" fn(&str, usize, Sender<CompMsg<Msg>>, bool) -> Result<(MsgReceiver<Msg>, MsgSender<Msg>)>,
    get_schema_input: extern "C" fn(&str) -> Result<String>,
    get_schema_input_array: extern "C" fn(&str) -> Result<String>,
    get_schema_output: extern "C" fn(&str) -> Result<String>,
    get_schema_output_array: extern "C" fn(&str) -> Result<String>,
}

/// Keep all the dylib agents and load them
pub struct AgentCache<Msg> {
    cache: HashMap<String, AgentLoader<Msg>>,
}

impl<Msg> AgentCache<Msg> {
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
    pub fn create_comp(&mut self, path: &str, id: usize, sender: Sender<CompMsg<Msg>>) -> Result<(Box<Agent + Send>, HashMap<String, MsgSender<Msg>>)> {
        if !self.cache.contains_key(path) {
            let lib_comp = libloading::Library::new(path).expect("cannot load");
            let new_comp: extern fn(usize, Sender<CompMsg<Msg>>) -> Result<(Box<Agent + Send>, HashMap<String, MsgSender<Msg>>)> = unsafe {
                *(lib_comp.get(b"create_agent\0").expect("cannot find create method"))
            };

            let clone_in: extern fn(&str, &MsgSender<Msg>) -> Result<MsgSender<Msg>> = unsafe {
                *(lib_comp.get(b"clone_input\0").expect("cannot find clone_input method"))
            };

            let clone_in_a: extern fn(&str, &MsgSender<Msg>) -> Result<MsgSender<Msg>> = unsafe {
                *(lib_comp.get(b"clone_input_array\0").expect("cannot find clone_input_array method"))
            };

            let create_in_a: extern fn(&str, usize, Sender<CompMsg<Msg>>, bool) -> Result<(MsgReceiver<Msg>, MsgSender<Msg>)> = unsafe {
                *(lib_comp.get(b"create_input_array\0").expect("cannot ifnd create_input_array method"))
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
                                  clone_input: clone_in,
                                  clone_input_array: clone_in_a,
                                  create_input_array: create_in_a,
                                  get_schema_input: get_in,
                                  get_schema_input_array: get_in_a,
                                  get_schema_output: get_out,
                                  get_schema_output_array: get_out_a,
                              });
        }
        if let Some(loader) = self.cache.get(path){
            (loader.create)(id, sender)
        } else {
            unreachable!()
        }
    }

    pub fn clone_input(&self, comp_str: &str, port: &str, sender: &MsgSender<Msg>) -> Result<MsgSender<Msg>> {
        self.cache.get(comp_str).ok_or(result::Error::AgentNotFound(comp_str.into()))
            .map(|comp| {
                (comp.clone_input)(port, sender).expect("cannot clone input")
            })
    }

    pub fn clone_input_array(&self, comp: &str, port: &str, sender: &MsgSender<Msg>) -> Result<MsgSender<Msg>> {
        self.cache.get(comp).ok_or(result::Error::AgentNotFound(comp.into()))
            .map(|comp| {
                (comp.clone_input_array)(port, sender).expect("cannot clone input")
            })
    }

    pub fn create_input_array(&self, comp: &str, port: &str, id: usize, sched: Sender<CompMsg<Msg>>, mc: bool) -> Result<(MsgReceiver<Msg>, MsgSender<Msg>)> {
        self.cache.get(comp).ok_or(result::Error::AgentNotFound(comp.into()))
            .map(|comp| {
                (comp.create_input_array)(port, id, sched, mc).expect("cannot create input array")
            })
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

unsafe impl<Msg> Send for AgentCache<Msg> {}
