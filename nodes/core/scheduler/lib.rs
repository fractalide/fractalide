#[macro_use]
extern crate rustfbp;
use rustfbp::scheduler::{Scheduler};
use std::mem;
use std::str;

extern crate capnp;

#[derive(Debug)]
pub struct Subgraph {
    nodes: Vec<String>,
    ext_in: HashMap<String, (String, String)>,
    ext_out: HashMap<String, (String, String)>,
}
impl Subgraph {
    pub fn new() -> Subgraph {
        Subgraph {
            nodes: vec![],
            ext_in: HashMap::new(),
            ext_out: HashMap::new(),
        }
    }
}

pub struct Portal {
    sched: Scheduler,
    subnet: HashMap<String, Subgraph>,
}

impl Portal {
    fn new() -> Portal {
        Portal {
            sched: Scheduler::new(),
            subnet: HashMap::new(),
        }
    }
}

agent! {
    input(action: core_action,
           graph: core_graph,
           imsg: any),
    output(error: error,
            ask_graph: core_graph,
            imsg_path: fs_path,
            imsg_edge: prim_text,
            imsg_input: prim_text),
    outarr(outputs: any),
    portal(Portal => Portal::new()),
    fn run(&mut self) -> Result<Signal> {

        let mut msg = self.input.action.recv()?;
        let mut reader: core_action::Reader = msg.read_schema()?;

        match reader.which()? {
            core_action::Which::Add(add) => {
                let mut add = add?;
                let name = add.get_name()?;
                let mut ask_msg = Msg::new();
                {
                    let mut builder: core_graph::Builder = ask_msg.build_schema();
                    builder.set_path(add.get_comp()?);
                    {
                        let mut nodes = builder.borrow().init_nodes().init_list(1);
                        nodes.borrow().get(0).set_name(add.get_name()?);
                        nodes.borrow().get(0).set_sort(add.get_comp()?);
                    }
                }
                self.output.ask_graph.send(ask_msg)?;
                add_graph(self, name)?;
            },
            core_action::Which::Remove(remove) => {
                let name = remove?;
                if let Some(subnet) = self.portal.subnet.remove(name) {
                    for node in subnet.nodes {
                        self.portal.sched.remove_agent(node)?;
                    }
                } else {
                    self.portal.sched.remove_agent(name)?;
                }
            },
            core_action::Which::Connect(connect) => {
                let connect = connect?;
                let mut o_name = connect.get_o_name()?;
                let mut o_port = connect.get_o_port()?;
                let o_selection = connect.get_o_selection()?;
                if let Some(subnet) = self.portal.subnet.get(o_name) {
                    if let Some(port) = subnet.ext_out.get(o_port) {
                        o_name = &port.0;
                        o_port = &port.1;
                    }
                }
                let mut i_name = connect.get_i_name()?;
                let mut i_port = connect.get_i_port()?;
                let i_selection = connect.get_i_selection()?;
                if let Some(subnet) = self.portal.subnet.get(i_name) {
                    if let Some(port) = subnet.ext_in.get(i_port) {
                        i_name = &port.0;
                        i_port = &port.1;
                    }
                }
                try!(connect_ports(&mut self.portal.sched,
                        o_name, o_port, o_selection,
                        i_name, i_port, i_selection));
            },
            // TODO : add selection (array port management)
            core_action::Which::ConnectSender(connect) => {
                let connect = connect?;
                let mut name: String = connect.get_name()?.into();
                let mut port: String = connect.get_port()?.into();
                let selection: String = connect.get_selection()?.into();
                if let Some(subnet) = self.portal.subnet.get(&name) {
                    if let Some(p) = subnet.ext_out.get(&port) {
                        name = p.0.clone();
                        port = p.1.clone();
                    }
                }
                let sender = self.outarr.outputs.get(connect.get_output()?)
                    .ok_or(result::Error::Misc("Element not found".into()))?;
                // TODO
                // try!(self.portal.sched.sender.send(CompMsg::ConnectOutputPort(name, port, sender.clone())));
            },
            core_action::Which::Send(send) => {
                let send = send?;
                let mut comp = send.get_comp()?;
                let mut port = send.get_port()?;
                let selection = send.get_selection()?;
                if let Some(subnet) = self.portal.subnet.get(comp) {
                    if let Some(subnet_port) = subnet.ext_in.get(port) {
                        comp = &subnet_port.0;
                        port = &subnet_port.1;
                    }
                }
                let msg = self.input.action.recv()?;
                let sender = if selection == "" {
                    self.portal.sched.get_sender(comp, port)?
                } else {
                    self.portal.sched.get_array_sender(comp, port, selection)?
                };
                sender.send(msg)?;
            },
            core_action::Which::Halt(v) => {
                let sched = mem::replace(&mut self.portal.sched, Scheduler::new());
                sched.join();
                return Ok(End);
            }
        }
        Ok(Continue)
    }
}

fn add_graph(mut agent: &mut ThisAgent, name: &str) -> Result<()> {
    let mut msg = agent.input.graph.recv()?;
    let i_graph: core_graph::Reader = msg.read_schema()?;

    let mut subnet = Subgraph::new();
    for n in i_graph.borrow().get_nodes()?.get_list()?.iter() {
        subnet.nodes.push(n.get_name()?.into());
        agent.portal.sched.add_node(n.get_name()?, n.get_sort()?);
    }

    for e in i_graph.borrow().get_edges()?.get_list()?.iter() {
        let o_name = e.get_o_name()?;
        let o_port = e.get_o_port()?;
        let o_selection = e.get_o_selection()?;
        let i_port = e.get_i_port()?;
        let i_selection = e.get_i_selection()?;
        let i_name = e.get_i_name()?;

        connect_ports(&mut agent.portal.sched,
                o_name, o_port, o_selection,
                i_name, i_port, i_selection)?;
    }

    for ext in i_graph.borrow().get_external_inputs()?.get_list()?.iter() {
        let name = ext.get_name()?;
        let comp = ext.get_comp()?;
        let port = ext.get_port()?;
        subnet.ext_in.insert(name.into(), (comp.into(), port.into()));
    }
    for ext in i_graph.borrow().get_external_outputs()?.get_list()?.iter() {
        let name = ext.get_name()?;
        let comp = ext.get_comp()?;
        let port = ext.get_port()?;
        subnet.ext_out.insert(name.into(), (comp.into(), port.into()));
    }

    for imsg in i_graph.borrow().get_imsgs()?.get_list()?.iter() {

        let comp = imsg.get_comp()?;
        let port = imsg.get_port()?;
        let input = imsg.get_imsg()?;

        let (edge, input, option_action) = split_input(input)?;

        let mut edge_list = edge.split('.');
        let base_schema_path = match edge_list.next(){
            Some(p) => {p.into()},
            None => {"".to_string()}
        };
        let schema_path = format!("{}/edge.capnp", base_schema_path);
        let class_name = match edge_list.next() {
            Some(c) => { c },
            None => {"failed_to_find_edge"},
        };

        let sender = if imsg.get_selection()? == "" {
            agent.portal.sched.get_sender(imsg.get_comp()?, imsg.get_port()?)?
        } else {
            agent.portal.sched.get_array_sender(imsg.get_comp()?, imsg.get_port()?, imsg.get_selection()?)?
        };

        let mut new_out = Msg::new();
        {
            let mut path = new_out.build_schema::<fs_path::Builder>();
            path.set_path(&schema_path);
        }
        agent.output.imsg_path.send(new_out)?;

        let mut new_out = Msg::new();
        {
            let mut path = new_out.build_schema::<prim_text::Builder>();
            path.set_text(&class_name);
        }
        agent.output.imsg_edge.send(new_out)?;

        let mut new_out = Msg::new();
        {
            let mut path = new_out.build_schema::<prim_text::Builder>();
            path.set_text(&input);
        }
        agent.output.imsg_input.send(new_out)?;

        let mut imsg = agent.input.imsg.recv()?;
        option_action.map(|action| { imsg.action = action; });
        sender.send(imsg)?;
    }

    // Start all agents without input port
    for n in &subnet.nodes {
        agent.portal.sched.start_if_needed(n as &str)?;
    }

    // Remember the subnet
    agent.portal.subnet.insert(name.into(), subnet);

    Ok(())
}

fn split_input(s: &str) -> Result<(String, String, Option<String>)> {
    let pos = s.find(":").ok_or(result::Error::Misc("bad definition of imsg".into()))?;
    let (a, b) = s.split_at(pos);
    let (_, b) = b.split_at(1);
    let pos2 = b.find("~");
    if let Some(pos) = pos2 {
        let (b, c) = b.split_at(pos);
        let (_, c) = c.split_at(1);
        return Ok((a.into(), b.into(), Some(c.into())));
    };
    Ok((a.into(), b.into(), None))
}

fn connect_ports(sched: &mut Scheduler, o_name: &str, o_port: &str, o_selection: &str,
           i_name: &str, i_port: &str, i_selection: &str) -> Result<()> {
    match (&o_selection[..], &i_selection[..]) {
        ("", "") => {
            sched.connect(o_name, o_port, i_name, i_port)?;
        },
        (_, "") => {
            // try!(sched.add_output_array_selection(o_name.clone(), o_port.clone(), o_selection.clone()));
            sched.connect_array(o_name, o_port, o_selection, i_name, i_port)?;
        },
        ("", _) => {
            sched.soft_add_input_array_element(i_name.clone(), i_port.clone(), i_selection.clone())?;
            sched.connect_to_array(o_name, o_port, i_name, i_port, i_selection)?;
        },
        _ => {
            // try!(sched.add_output_array_selection(o_name.clone(), o_port.clone(), o_selection.clone()));
            sched.soft_add_input_array_element(i_name.clone(), i_port.clone(), i_selection.clone())?;
            sched.connect_array_to_array(o_name, o_port, o_selection, i_name, i_port, i_selection)?;
        }
    }
    Ok(())
}
