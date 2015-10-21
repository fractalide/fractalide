use component::{Component, ComponentConnect, InputSenders, InputArraySenders};
use super::scheduler::{Scheduler};

#[derive(Clone)]
pub struct Graph {
    pub nodes: Vec<Node>,
    pub edges: Vec<Edge>,
    pub virtual_input_ports: Vec<VirtualPort>,
    pub virtual_output_ports: Vec<VirtualPort>,
    pub iips: Vec<IIP>,
}


#[derive(Clone)]
pub struct Node{
    pub name: String,
    pub sort: COrG,
}

#[derive(Clone)]
pub enum COrG {
    C(fn() -> (Box<Component + Send>, Box<InputSenders>, Box<InputArraySenders>)),
    G(Graph),
}

#[derive(Clone)]
pub enum Edge {
    Simple2simple(String, String, String, String),
    Simple2array(String, String, String, String, String),
    Array2simple(String, String, String, String, String),
    Array2array(String, String, String, String, String, String),
}

#[derive(Clone)]
pub struct VirtualPort(pub String, pub String, pub String);

#[derive(Clone)]
pub struct IIP(String, pub String, pub String);

pub struct SubNet;
impl SubNet {
    pub fn new(g: &Graph, name: String, sched: &mut Scheduler) { 
        // TODO Make virtual input and output different
        for vp in &g.virtual_input_ports {
            sched.subnet_input_names.insert(name.clone() + &vp.0, (name.clone() + &vp.1, vp.2.clone()));
        }
        for vp in &g.virtual_output_ports {
            sched.subnet_output_names.insert(name.clone() + &vp.0, (name.clone() + &vp.1, vp.2.clone()));
        }
        let mut start = vec![];
        for node in &g.nodes {
            match node.sort {
                COrG::C(ref fun) => {
                    let comp = fun();
                    if !comp.0.is_input_ports() {
                        start.push(name.clone() + &node.name);
                    }
                    sched.add_component(name.clone() + &node.name, comp);
                }
                COrG::G(ref graph) => {
                    sched.add_subnet(name.clone() + &node.name, &graph);
                }
            }
        }
        sched.subnet_start.insert(name.clone(), start);
        for edge in &g.edges {
            match edge {
                &Edge::Simple2simple(ref comp_out, ref port_out, ref comp_in, ref port_in) => { 
                    sched.connect(name.clone() + &comp_out, port_out.clone(), name.clone() + &comp_in, port_in.clone()); 
                },
                &Edge::Simple2array(ref comp_out, ref port_out, ref comp_in, ref port_in, ref selection_in) => { 
                    sched.add_input_array_selection(name.clone() + &comp_in, port_in.clone(), selection_in.clone());
                    sched.connect_to_array(name.clone() + &comp_out, port_out.clone(), comp_in.clone(), name.clone() + &port_in, selection_in.clone()); 
                },
                &Edge::Array2simple(ref comp_out, ref port_out, ref selection_out, ref comp_in, ref port_in) => { 
                    sched.add_output_array_selection(name.clone() + &comp_out, port_out.clone(), selection_out.clone());
                    sched.connect_array(name.clone() + &comp_out, port_out.clone(), selection_out.clone(), name.clone() + &comp_in, port_in.clone()); 
                },
                &Edge::Array2array(ref comp_out, ref port_out, ref selection_out, ref comp_in, ref port_in, ref selection_in) => { 
                    sched.add_input_array_selection(name.clone() + &comp_in, port_in.clone(), selection_in.clone());
                    sched.add_output_array_selection(name.clone() + &comp_out, port_out.clone(), selection_out.clone());
                    sched.connect_array_to_array(name.clone() + &comp_out, port_out.clone(), selection_out.clone(), comp_in.clone(), name.clone() + &port_in, selection_in.clone()); 
                },

            }
        }   
        // for iip in g.iips {
        //     let sender = sched.get_sender(name.clone() + &iip.1, iip.2);
        //     sender.send(iip.0).ok().expect("SubNet IIP : unable to send the IIP");
        // }
    }
}

