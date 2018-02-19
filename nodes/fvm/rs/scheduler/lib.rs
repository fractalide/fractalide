#[macro_use]
extern crate rustfbp;
#[macro_use]
extern crate log;
use rustfbp::scheduler::{Scheduler};
use std::mem;
use std::str;
use std::fs::File;
use rustfbp::edges::core_graph::CoreGraph;
use rustfbp::edges::core_action::CoreAction;
use rustfbp::edges::core_scheduler::{CoreScheduler, CoreSchedulerSubnet};
use rustfbp::edges::core_graph::{CoreGraphNode, CoreGraphEdge, CoreGraphIMsg, CoreGraphExtIn, CoreGraphExtOut};

extern crate capnp;

type BAny = Box<Any + Send>;

agent! {
    input(action: CoreAction,
           graph: CoreGraph),
    output(// error: error,
            ask_graph: CoreGraph),
    outarr(outputs: BAny),
    accumulator(CoreScheduler),
    fn run(&mut self) -> Result<Signal> {
debug!("{:?}", env!("CARGO_PKG_NAME"));
        let mut acc = if let Ok(acc) = self.input.accumulator.try_recv() {
            acc
        } else {
            CoreScheduler::new()
        };

        let action = self.input.action.recv()?;
        match action {
            CoreAction::Add(add) => {
                let mut g = CoreGraph::new();
                g.path = add.comp.clone();
                g.nodes.push(CoreGraphNode {
                    name: add.name.clone(),
                    sort: add.comp,
                });
                self.output.ask_graph.send(g);
                add_graph(self, &add.name, &mut acc)?;
            }
            CoreAction::Halt => {
                let sched = mem::replace(&mut acc.sched, Scheduler::new());
                sched.join();
                return Ok(End);
            }
            _ => { unimplemented!() }
        }

        self.output.accumulator.send(acc)?;
        Ok(Continue)
        /*
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
                if let Some(subnet) = self.state.subnet.remove(name) {
                    for node in subnet.nodes {
                        self.state.sched.remove_agent(node)?;
                    }
                } else {
                    self.state.sched.remove_agent(name)?;
                }
            },
            core_action::Which::Connect(connect) => {
                let connect = connect?;
                let mut o_name = connect.get_o_name()?;
                let mut o_port = connect.get_o_port()?;
                let o_selection = connect.get_o_selection()?;
                if let Some(subnet) = self.state.subnet.get(o_name) {
                    if let Some(port) = subnet.ext_out.get(o_port) {
                        o_name = &port.0;
                        o_port = &port.1;
                    }
                }
                let mut i_name = connect.get_i_name()?;
                let mut i_port = connect.get_i_port()?;
                let i_selection = connect.get_i_selection()?;
                if let Some(subnet) = self.state.subnet.get(i_name) {
                    if let Some(port) = subnet.ext_in.get(i_port) {
                        i_name = &port.0;
                        i_port = &port.1;
                    }
                }
                try!(connect_ports(&mut self.state.sched,
                        o_name, o_port, o_selection,
                        i_name, i_port, i_selection));
            },
            // TODO : add selection (array port management)
            core_action::Which::ConnectSender(connect) => {
                let connect = connect?;
                let mut name: String = connect.get_name()?.into();
                let mut port: String = connect.get_port()?.into();
                let selection: String = connect.get_selection()?.into();
                if let Some(subnet) = self.state.subnet.get(&name) {
                    if let Some(p) = subnet.ext_out.get(&port) {
                        name = p.0.clone();
                        port = p.1.clone();
                    }
                }
                let sender = self.outarr.outputs.get(connect.get_output()?)
                    .ok_or(result::Error::Misc("Element not found".into()))?;
                // TODO
                // try!(self.state.sched.sender.send(CompMsg::ConnectOutputPort(name, port, sender.clone())));
            },
            core_action::Which::Send(send) => {
                let send = send?;
                let mut comp = send.get_comp()?;
                let mut port = send.get_port()?;
                let selection = send.get_selection()?;
                if let Some(subnet) = self.state.subnet.get(comp) {
                    if let Some(subnet_port) = subnet.ext_in.get(port) {
                        comp = &subnet_port.0;
                        port = &subnet_port.1;
                    }
                }
                let msg = self.input.action.recv()?;
                let sender = if selection == "" {
                    self.state.sched.get_sender(comp, port)?
                } else {
                    self.state.sched.get_array_sender(comp, port, selection)?
                };
                sender.send(msg)?;
            },
        }
        */
    }
}

fn add_graph(mut agent: &mut ThisAgent, name: &str, acc: &mut CoreScheduler) -> Result<()> {
    let i_graph = agent.input.graph.recv()?;

    let mut subnet = CoreSchedulerSubnet::new();
    for n in i_graph.nodes {
        subnet.nodes.push(n.name.clone());
        acc.sched.add_node(n.name, n.sort);
    }

    for e in i_graph.edges {
        match (e.out_elem, e.in_elem) {
            (None, None) => {
                acc.sched.connect(e.out_comp, e.out_port,
                                  e.in_comp, e.in_port)?;
            }
            (Some(out_elem), None) => {
                acc.sched.connect_array(e.out_comp, e.out_port, out_elem,
                                        e.in_comp, e.in_port)?;
            }
            (None, Some(in_elem)) => {
                acc.sched.connect_to_array(e.out_comp, e.out_port,
                                           e.in_comp, e.in_port, in_elem)?;
            }
            (Some(out_elem), Some(in_elem)) => {
                acc.sched.connect_array_to_array(e.out_comp, e.out_port, out_elem,
                                                 e.in_comp, e.in_port, in_elem)?;
            }
        }
    }

    for ext in i_graph.ext_in {
        subnet.ext_in.insert(ext.port, (ext.in_comp, ext.in_port));
    }
    for ext in i_graph.ext_out {
        subnet.ext_out.insert(ext.port, (ext.out_comp, ext.out_port));
    }

    for imsg in i_graph.imsgs {
        // TODO: manage action
        let sender = if let Some(elem) = imsg.elem {
            acc.sched.get_array_sender(imsg.comp, imsg.port, elem)?
        } else {
            acc.sched.get_sender(imsg.comp, imsg.port)?
        };

        // let sender = sender.downcast::<MsgSender<String>>().expect("cannot downcast the sender");

        sender.send(imsg.msg)?;
    }

    // Start all agents without input port
    for n in &subnet.nodes {
        acc.sched.start_if_needed(n as &str)?;
    }

    // Remember the subnet
    acc.subnets.insert(name.into(), subnet);

    Ok(())
}
/*
fn split_input(s: &str) -> Result<(String, Option<String>)> {
    let pos2 = s.find("~");
    if let Some(pos) = pos2 {
        let (a, b) = s.split_at(pos);
        let (_, b) = b.split_at(1);
        return Ok((a.into(), Some(b.into())));
    };
    Ok((s.into(), None))
}
*/
