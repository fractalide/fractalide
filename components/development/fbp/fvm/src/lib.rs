#[macro_use]
extern crate rustfbp;

extern crate capnp;

use std::fs;

mod contract_capnp {
    include!("path.rs");
    include!("option_path.rs");
    include!("fbp_graph.rs");
}
use contract_capnp::path;
use contract_capnp::option_path;
use contract_capnp::graph;

#[derive(Debug)]
struct Graph {
    errors: bool,
    nodes: Vec<(String, String)>,
    edges: Vec<(String, String, String, String, String, String)>,
    iips: Vec<(String, String, String, String)>,
    ext_in: Vec<(String, String, String, String)>,
    ext_out: Vec<(String, String, String, String)>,
}

component! {
    fvm,
    inputs(input: graph, new_path: option_path, error: any),
    inputs_array(),
    outputs(output: graph, ask_graph: text, ask_path: path),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) {
        let mut graph = Graph { errors: false,
            nodes: vec![], edges: vec![], iips: vec![],
            ext_in: vec![], ext_out: vec![],
        };

        // retrieve the asked graph
        let mut ip = self.ports.recv("input".into()).expect("cannot receive");
        let i_graph = ip.get_reader().expect("fvm: cannot get reader");
        let i_graph: graph::Reader = i_graph.get_root().expect("fvm: not a graph");

        add_graph(self, &mut graph, i_graph, "");

        if !graph.errors {
            send_graph(&self, &graph);
        }

    }
}

fn add_graph(component: &fvm, mut graph: &mut Graph, new_graph: graph::Reader, name: &str) {

    if new_graph.get_path().unwrap() == "error" { graph.errors = true; }

    for n in new_graph.borrow().get_edges().unwrap().iter() {
        graph.edges.push((format!("{}-{}", name, n.get_o_name().unwrap()),
                          n.get_o_port().unwrap().into(), n.get_o_selection().unwrap().into(),
                          n.get_i_port().unwrap().into(), n.get_i_selection().unwrap().into(),
                          format!("{}-{}", name, n.get_i_name().unwrap())));
    }
    for n in new_graph.borrow().get_iips().unwrap().iter() {
        graph.iips.push((n.get_iip().unwrap().into(),
                         n.get_port().unwrap().into(), n.get_selection().unwrap().into(),
                         format!("{}-{}", name, n.get_comp().unwrap()) ));
    }
    for n in new_graph.borrow().get_external_inputs().unwrap().iter() {
        // TODO : replace existing links
        for edge in &mut graph.edges {
            if edge.5 == name && edge.3 == n.get_name().unwrap() {
                edge.5 = format!("{}-{}", name, n.get_comp().unwrap());
                edge.3 = n.get_port().unwrap().into();
                edge.4 = n.get_selection().unwrap().into();
            }
        }

        for iip in &mut graph.iips {
            if iip.3 == name && iip.1 == n.get_name().unwrap() {
                iip.3 = format!("{}-{}", name, n.get_comp().unwrap());
                iip.1 = n.get_port().unwrap().into();
                iip.2 = n.get_selection().unwrap().into();
            }
        }
    }
    for n in new_graph.borrow().get_external_outputs().unwrap().iter() {
        for edge in &mut graph.edges {
            if edge.0 == name && edge.1 == n.get_name().unwrap() {
                edge.0 = format!("{}-{}", name, n.get_comp().unwrap());
                edge.1 = n.get_port().unwrap().into();
                edge.2 = n.get_selection().unwrap().into();
            }
        }
    }

    for n in new_graph.borrow().get_nodes().unwrap().iter() {
        let c_sort = n.get_sort().unwrap();
        let c_name = n.get_name().unwrap();

        // get new path
        let mut msg = capnp::message::Builder::new_default();
        {
            let mut path = msg.init_root::<path::Builder>();
            path.set_path(c_sort);
        }
        let mut ip = component.allocator.ip.build_empty();
        ip.write_builder(&mut msg);
        component.ports.send("ask_path".into(), ip).expect("unable to ask graph");

        // retrieve the asked graph
        let mut ip = component.ports.recv("new_path".into()).expect("cannot receive");
        let i_graph = ip.get_reader().expect("fvm: cannot get reader");
        let i_graph: option_path::Reader = i_graph.get_root().expect("fvm: not a graph");

        let new_path: Option<String> = match i_graph.which().unwrap() {
            option_path::Path(p) => { Some(p.unwrap().into()) },
            option_path::None(()) => { None }
        };

        let mut is_subnet = true;
        let path = match new_path {
            Some(hash_name) => {
                let path = format!("{}{}{}", "/nix/store/", hash_name, "/lib/libcomponent.so");
                if fs::metadata(&path).is_ok() {
                    is_subnet = false;
                    path
                } else {
                    format!("{}{}{}", "/nix/store/", hash_name, "/lib/lib.subnet")
                }

            },
            None => {
                println!("Error in {} : ", new_graph.get_path().unwrap());
                println!("component {}({}) doesn't exist", c_name, c_sort);
                graph.errors = true;
                continue;
            }
        };

        if is_subnet {
            let mut msg = capnp::message::Builder::new_default();
            {
                let mut number = msg.init_root::<path::Builder>();
                number.set_path(&path);
            }
            let mut ip = component.allocator.ip.build_empty();
            ip.write_builder(&mut msg);

            component.ports.send("ask_graph".into(), ip).expect("unable to ask graph");

            // retrieve the asked graph
            let mut ip = component.ports.recv("input".into()).expect("cannot receive");
            let i_graph = ip.get_reader().expect("fvm: cannot get reader");
            let i_graph: graph::Reader = i_graph.get_root().expect("fvm: not a graph");

            add_graph(component, &mut graph, i_graph, &format!("{}-{}", name, c_name));
        } else {
            graph.nodes.push((format!("{}-{}", name, c_name).into(), path.into()));
        }
    }
}

fn send_graph(comp: &fvm, graph: &Graph) {
    let mut new_ip = capnp::message::Builder::new_default();
    {
        let mut ip = new_ip.init_root::<graph::Builder>();
        ip.set_path("");
        {
            let mut nodes = ip.borrow().init_nodes(graph.nodes.len() as u32);
            let mut i = 0;
            for n in &graph.nodes {
                nodes.borrow().get(i).set_name(&n.0[..]);
                nodes.borrow().get(i).set_sort(&n.1[..]);
                i += 1;
            }
        }
        {
            let mut edges = ip.borrow().init_edges(graph.edges.len() as u32);
            let mut i = 0;
            for e in &graph.edges {
                edges.borrow().get(i).set_o_name(&e.0[..]);
                edges.borrow().get(i).set_o_port(&e.1[..]);
                edges.borrow().get(i).set_o_selection(&e.2[..]);
                edges.borrow().get(i).set_i_port(&e.3[..]);
                edges.borrow().get(i).set_i_selection(&e.4[..]);
                edges.borrow().get(i).set_i_name(&e.5[..]);
                i += 1;
            }
        }
        {
            let mut iips = ip.borrow().init_iips(graph.iips.len() as u32);
            let mut i = 0;
            for iip in &graph.iips {
                iips.borrow().get(i).set_iip(&iip.0[..]);
                iips.borrow().get(i).set_port(&iip.1[..]);
                iips.borrow().get(i).set_selection(&iip.2[..]);
                iips.borrow().get(i).set_comp(&iip.3[..]);
                i += 1;
            }
        }
        {
            let mut ext = ip.borrow().init_external_inputs(graph.ext_in.len() as u32);
            let mut i = 0;
            for e in &graph.ext_in {
                ext.borrow().get(i).set_name(&e.0[..]);
                ext.borrow().get(i).set_port(&e.1[..]);
                ext.borrow().get(i).set_selection(&e.2[..]);
                ext.borrow().get(i).set_comp(&e.3[..]);
                i += 1;
            }
        }
        {
            let mut ext = ip.borrow().init_external_outputs(graph.ext_out.len() as u32);
            let mut i = 0;
            for e in &graph.ext_out {
                ext.borrow().get(i).set_comp(&e.0[..]);
                ext.borrow().get(i).set_port(&e.1[..]);
                ext.borrow().get(i).set_selection(&e.2[..]);
                ext.borrow().get(i).set_name(&e.3[..]);
                i += 1;
            }
        }
    }
    let mut send_ip = comp.allocator.ip.build_empty();
    send_ip.write_builder(&new_ip).expect("fbp_lexical: cannot write");
    let _ = comp.ports.send("output".into(), send_ip);
}
