use component::{Component, ComponentConnect, InputSenders, InputArraySenders};
use super::scheduler::{Scheduler};
use std::collections::HashMap;

trait Renamer {
    fn rename(&self, a: String, b: String) -> (String, String);
}
impl Renamer for HashMap<String, (String, String)> {
    fn rename(&self, a: String, b: String) -> (String, String){
        match self.get(&format!("{}{}",a,b)) {
            None => { (a, b) },
            Some(&(ref na, ref nb)) => {
                (na.clone(), nb.clone())
            }
        }
    }
}

#[derive(Clone)]
pub struct GraphBuilder {
    nodes: Vec<Node>,
    edges: Vec<Edge>,
    virtual_input_ports: Vec<VirtualPort>,
    virtual_output_ports: Vec<VirtualPort>,
    iips: Vec<IIP>,
    virtual_inputs: HashMap<String, (String, String)>,
    virtual_outputs: HashMap<String, (String, String)>,
}

impl GraphBuilder { 
    pub fn new() -> Self {
        GraphBuilder {
            nodes: vec![],
            edges: vec![],
            virtual_input_ports: vec![],
            virtual_output_ports: vec![],
            iips: vec![],
            virtual_inputs: HashMap::new(),
            virtual_outputs: HashMap::new(),
        }
    }

    pub fn add_component(&mut self, name: String, f: fn() -> (Box<Component + Send>, Box<InputSenders>, Box<InputArraySenders>)) -> Self {
        self.nodes.push(Node { 
            name: name,
            sort: COrG::C(f),
        });
        self.clone()
    }

    pub fn add_subnet(&mut self, name: String, g: &Graph) -> Self {
        for vp in &g.virtual_input_ports {
            self.virtual_inputs.insert(format!("{}{}", name, vp.0.clone()), (format!("{}{}", name, vp.1), vp.2.clone()));
        }
        for vp in &g.virtual_output_ports {
            self.virtual_outputs.insert(format!("{}{}", name, vp.0.clone()), (format!("{}{}", name, vp.1), vp.2.clone()));
        }
        for node in &g.nodes {
            match node.sort {
                COrG::C(ref fun) => {
                    self.add_component(format!("{}{}", name, node.name), fun.clone());
                }
                COrG::G(_) => {
                    panic!("The graph must be flat");
                }
            }
        }
        for edge in &g.edges {
            match edge {
                &Edge::Simple2simple(ref comp_out, ref port_out, ref comp_in, ref port_in) => { 
                    self.add_simple2simple(format!("{}{}", name, comp_out), port_out.clone(), format!("{}{}", name, comp_in), port_in.clone()); 
                },
                &Edge::Simple2array(ref comp_out, ref port_out, ref comp_in, ref port_in, ref selection_in) => { 
                    self.add_simple2array(format!("{}{}", name, comp_out), port_out.clone(), comp_in.clone(), format!("{}{}", name, port_in), selection_in.clone()); 
                },
                &Edge::Array2simple(ref comp_out, ref port_out, ref selection_out, ref comp_in, ref port_in) => { 
                    self.add_array2simple(format!("{}{}", name, comp_out), port_out.clone(), selection_out.clone(), format!("{}{}", name, comp_in), port_in.clone()); 
                },
                &Edge::Array2array(ref comp_out, ref port_out, ref selection_out, ref comp_in, ref port_in, ref selection_in) => { 
                    self.add_array2array(format!("{}{}", name, comp_out), port_out.clone(), selection_out.clone(), comp_in.clone(), format!("{}{}", name, port_in), selection_in.clone()); 
                },

            }
        }   
        self.clone()
    
    }

    fn add_simple2simple(&mut self, c_out: String, p_out: String, c_in: String, p_in: String) -> Self {
        let (c_out, p_out) = self.virtual_outputs.rename(c_out, p_out);
        let (c_in, p_in) = self.virtual_inputs.rename(c_in, p_in);
        self.edges.push(Edge::Simple2simple(c_out, p_out, c_in, p_in));
        self.clone()
    }

    fn add_simple2array(&mut self, c_out: String, p_out: String, c_in: String, p_in: String, s_in: String) -> Self {
        let (c_out, p_out) = self.virtual_outputs.rename(c_out, p_out);
        let (c_in, p_in) = self.virtual_inputs.rename(c_in, p_in);
        self.edges.push(Edge::Simple2array(c_out, p_out, c_in, p_in, s_in));
        self.clone()
    }

    fn add_array2simple(&mut self, c_out: String, p_out: String, s_out: String, c_in: String, p_in: String) -> Self {
        let (c_out, p_out) = self.virtual_outputs.rename(c_out, p_out);
        let (c_in, p_in) = self.virtual_inputs.rename(c_in, p_in);
        self.edges.push(Edge::Array2simple(c_out, p_out, s_out, c_in, p_in));
        self.clone()
    }

    fn add_array2array(&mut self, c_out: String, p_out: String, s_out: String, c_in: String, p_in: String, s_in: String) -> Self {
        let (c_out, p_out) = self.virtual_outputs.rename(c_out, p_out);
        let (c_in, p_in) = self.virtual_inputs.rename(c_in, p_in);
        self.edges.push(Edge::Array2array(c_out, p_out, s_out, c_in, p_in, s_in));
        self.clone()
    }
    
    pub fn edges(self) -> Graph {
        Graph {
            nodes: self.nodes,
            edges: self.edges,
            virtual_input_ports: self.virtual_input_ports,
            virtual_output_ports: self.virtual_output_ports,
            iips: self.iips,
            virtual_inputs: self.virtual_inputs,
            virtual_outputs: self.virtual_outputs,
        }
    }
}

#[derive(Clone, Debug)]
pub struct Graph {
    nodes: Vec<Node>,
    edges: Vec<Edge>,
    virtual_input_ports: Vec<VirtualPort>,
    virtual_output_ports: Vec<VirtualPort>,
    iips: Vec<IIP>,
    virtual_inputs: HashMap<String, (String, String)>,
    virtual_outputs: HashMap<String, (String, String)>,
}

impl Graph {
    pub fn add_simple2simple(&mut self, c_out: String, p_out: String, c_in: String, p_in: String) -> Self {
        let (c_out, p_out) = self.virtual_outputs.rename(c_out, p_out);
        let (c_in, p_in) = self.virtual_inputs.rename(c_in, p_in);
        self.edges.push(Edge::Simple2simple(c_out, p_out, c_in, p_in));
        self.clone()
    }

    pub fn add_simple2array(&mut self, c_out: String, p_out: String, c_in: String, p_in: String, s_in: String) -> Self {
        let (c_out, p_out) = self.virtual_outputs.rename(c_out, p_out);
        let (c_in, p_in) = self.virtual_inputs.rename(c_in, p_in);
        self.edges.push(Edge::Simple2array(c_out, p_out, c_in, p_in, s_in));
        self.clone()
    }

    pub fn add_array2simple(&mut self, c_out: String, p_out: String, s_out: String, c_in: String, p_in: String) -> Self {
        let (c_out, p_out) = self.virtual_outputs.rename(c_out, p_out);
        let (c_in, p_in) = self.virtual_inputs.rename(c_in, p_in);
        self.edges.push(Edge::Array2simple(c_out, p_out, s_out, c_in, p_in));
        self.clone()
    }

    pub fn add_array2array(&mut self, c_out: String, p_out: String, s_out: String, c_in: String, p_in: String, s_in: String) -> Self {
        let (c_out, p_out) = self.virtual_outputs.rename(c_out, p_out);
        let (c_in, p_in) = self.virtual_inputs.rename(c_in, p_in);
        self.edges.push(Edge::Array2array(c_out, p_out, s_out, c_in, p_in, s_in));
        self.clone()
    }
    
    pub fn add_virtual_input_port(&mut self, n: String, c: String, p: String) -> Self {
        let (c, p) = self.virtual_inputs.rename(c, p);
        self.virtual_input_ports.push(VirtualPort(n, c, p));
        self.clone()
    }

    pub fn add_virtual_output_port(&mut self, n: String, c: String, p: String) -> Self {
        let (c, p) = self.virtual_outputs.rename(c, p);
        self.virtual_output_ports.push(VirtualPort(n, c, p));
        self.clone()
    }
    
}


#[derive(Clone, Debug)]
pub struct Node{
    pub name: String,
    pub sort: COrG,
}

#[derive(Clone, Debug)]
pub enum COrG {
    C(fn() -> (Box<Component + Send>, Box<InputSenders>, Box<InputArraySenders>)),
    G(Graph),
}

#[derive(Clone, Debug)]
pub enum Edge {
    Simple2simple(String, String, String, String),
    Simple2array(String, String, String, String, String),
    Array2simple(String, String, String, String, String),
    Array2array(String, String, String, String, String, String),
}

#[derive(Clone, Debug)]
pub struct VirtualPort(pub String, pub String, pub String);

#[derive(Clone, Debug)]
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
                COrG::G(_) => {
                    panic!("Impossible : the graph must be flat");
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

