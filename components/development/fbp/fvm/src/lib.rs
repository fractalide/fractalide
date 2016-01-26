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
    fn run(&mut self) -> Result<()>{
        let mut graph = Graph { errors: false,
            nodes: vec![], edges: vec![], iips: vec![],
            ext_in: vec![], ext_out: vec![],
        };

        // retrieve the asked graph
        let mut ip = try!(self.ports.recv("input".into()));
        let i_graph = try!(ip.get_reader());
        let i_graph: graph::Reader = try!(i_graph.get_root());

        try!(add_graph(self, &mut graph, i_graph, ""));

        if !graph.errors {
            try!(send_graph(&self, &graph))
        }
        Ok(())
    }
}

fn add_graph(component: &fvm, mut graph: &mut Graph, new_graph: graph::Reader, name: &str) -> Result<()> {

    if try!(new_graph.get_path()) == "error" { graph.errors = true; }

    for n in try!(new_graph.borrow().get_edges()).iter() {
        graph.edges.push((format!("{}-{}", name, try!(n.get_o_name())),
                          try!(n.get_o_port()).into(), try!(n.get_o_selection()).into(),
                          try!(n.get_i_port()).into(), try!(n.get_i_selection()).into(),
                          format!("{}-{}", name, try!(n.get_i_name()))));
    }
    for n in try!(new_graph.borrow().get_iips()).iter() {
        graph.iips.push((try!(n.get_iip()).into(),
                         try!(n.get_port()).into(), try!(n.get_selection()).into(),
                         format!("{}-{}", name, try!(n.get_comp())) ));
    }
    for n in try!(new_graph.borrow().get_external_inputs()).iter() {
        // TODO : replace existing links
        for edge in &mut graph.edges {
            if edge.5 == name && edge.3 == try!(n.get_name()) {
                edge.5 = format!("{}-{}", name, try!(n.get_comp()));
                edge.3 = try!(n.get_port()).into();
                edge.4 = try!(n.get_selection()).into();
            }
        }

        for iip in &mut graph.iips {
            if iip.3 == name && iip.1 == try!(n.get_name()) {
                iip.3 = format!("{}-{}", name, try!(n.get_comp()));
                iip.1 = try!(n.get_port()).into();
                iip.2 = try!(n.get_selection()).into();
            }
        }
    }
    for n in try!(new_graph.borrow().get_external_outputs()).iter() {
        for edge in &mut graph.edges {
            if edge.0 == name && edge.1 == try!(n.get_name()) {
                edge.0 = format!("{}-{}", name, try!(n.get_comp()));
                edge.1 = try!(n.get_port()).into();
                edge.2 = try!(n.get_selection()).into();
            }
        }
    }

    for n in try!(new_graph.borrow().get_nodes()).iter() {
        let c_sort = try!(n.get_sort());
        let c_name = try!(n.get_name());

        // get new path
        let mut msg = capnp::message::Builder::new_default();
        {
            let mut path = msg.init_root::<path::Builder>();
            path.set_path(c_sort);
        }
        let mut ip = component.allocator.ip.build_empty();
        ip.write_builder(&mut msg);
        try!(component.ports.send("ask_path".into(), ip));

        // retrieve the asked graph
        let mut ip = try!(component.ports.recv("new_path".into()));
        let i_graph = try!(ip.get_reader());
        let i_graph: option_path::Reader = try!(i_graph.get_root());

        let new_path: Option<String> = match try!(i_graph.which()) {
            option_path::Path(p) => { Some(try!(p).into()) },
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
                println!("Error in {} : ", try!(new_graph.get_path()));
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

            try!(component.ports.send("ask_graph".into(), ip));

            // retrieve the asked graph
            let mut ip = try!(component.ports.recv("input".into()));
            let i_graph = try!(ip.get_reader());
            let i_graph: graph::Reader = try!(i_graph.get_root());

            add_graph(component, &mut graph, i_graph, &format!("{}-{}", name, c_name));
        } else {
            graph.nodes.push((format!("{}-{}", name, c_name).into(), path.into()));
        }
    }
    Ok(())
}

fn send_graph(comp: &fvm, graph: &Graph) -> Result<()> {
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
    try!(send_ip.write_builder(&new_ip));
    let _ = comp.ports.send("output".into(), send_ip);
    Ok(())
}
