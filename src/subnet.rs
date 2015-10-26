use component::{Component, ComponentConnect, InputSenders, InputArraySenders};
use super::scheduler::{Scheduler};
use std::collections::HashMap;

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

pub struct SubNet{
    pub input_names: HashMap<String, (String, String)>,
    pub output_names: HashMap<String, (String, String)>,
    pub children: Vec<String>,
    pub start: Vec<String>,
    // pub acc: Vec<String>, TODO : manage the acc port
}
impl SubNet {
    pub fn new(g: &Graph, name: String, sched: &mut Scheduler) { 
        let mut sn = SubNet {
            input_names: HashMap::new(),
            output_names: HashMap::new(),
            children: vec![],
            start: vec![],
        };
        for vp in &g.virtual_input_ports {
            sn.input_names.insert(vp.0.clone(), (format!("{}{}", name, vp.1), vp.2.clone()));
        }
        for vp in &g.virtual_output_ports {
            sn.output_names.insert(vp.0.clone(), (format!("{}{}", name, vp.1), vp.2.clone()));
        }
        for node in &g.nodes {
            sn.children.push(format!("{}{}", name, node.name));
            match node.sort {
                COrG::C(ref fun) => {
                    let comp = fun();
                    if !comp.0.is_input_ports() {
                        sn.start.push(format!("{}{}", name, node.name));
                    }
                    sched.add_component(format!("{}{}", name, node.name), comp);
                }
                COrG::G(ref graph) => {
                    sched.add_subnet(format!("{}{}", name, node.name), &graph);
                }
            }
        }
        sched.subnets.insert(name.clone(), sn);
        for edge in &g.edges {
            match edge {
                &Edge::Simple2simple(ref comp_out, ref port_out, ref comp_in, ref port_in) => { 
                    sched.connect(format!("{}{}", name, comp_out), port_out.clone(), format!("{}{}", name, comp_in), port_in.clone()); 
                },
                &Edge::Simple2array(ref comp_out, ref port_out, ref comp_in, ref port_in, ref selection_in) => { 
                    sched.add_input_array_selection(format!("{}{}", name, comp_in), port_in.clone(), selection_in.clone());
                    sched.connect_to_array(format!("{}{}", name, comp_out), port_out.clone(), comp_in.clone(), format!("{}{}", name, port_in), selection_in.clone()); 
                },
                &Edge::Array2simple(ref comp_out, ref port_out, ref selection_out, ref comp_in, ref port_in) => { 
                    sched.add_output_array_selection(format!("{}{}", name, comp_out), port_out.clone(), selection_out.clone());
                    sched.connect_array(format!("{}{}", name, comp_out), port_out.clone(), selection_out.clone(), format!("{}{}", name, comp_in), port_in.clone()); 
                },
                &Edge::Array2array(ref comp_out, ref port_out, ref selection_out, ref comp_in, ref port_in, ref selection_in) => { 
                    sched.add_input_array_selection(format!("{}{}", name, comp_in), port_in.clone(), selection_in.clone());
                    sched.add_output_array_selection(format!("{}{}", name, comp_out), port_out.clone(), selection_out.clone());
                    sched.connect_array_to_array(format!("{}{}", name, comp_out), port_out.clone(), selection_out.clone(), comp_in.clone(), format!("{}{}", name, port_in), selection_in.clone()); 
                },

            }
        }   
        // for iip in g.iips {
        //     let sender = sched.get_sender(name.clone() + &iip.1, iip.2);
        //     sender.send(iip.0).ok().expect("SubNet IIP : unable to send the IIP");
        // }
    }
}

