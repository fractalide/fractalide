#[macro_use]
extern crate rustfbp;
extern crate capnp;

use std::fs;

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
    fvm, contracts(path, fbp_graph)
    inputs(input: fbp_graph, error: any),
    inputs_array(),
    outputs(output: fbp_graph, ask_graph: path),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()>{
        let mut graph = Graph { errors: false,
            nodes: vec![], edges: vec![], iips: vec![],
            ext_in: vec![], ext_out: vec![],
        };

        // retrieve the asked graph
        let mut ip = try!(self.ports.recv("input"));
        let i_graph: fbp_graph::Reader = try!(ip.get_root());

        try!(add_graph(self, &mut graph, i_graph, ""));

        if !graph.errors {
            try!(send_graph(&self, &graph))
        }
        Ok(())
    }
}

fn add_graph(component: &fvm, mut graph: &mut Graph, new_graph: fbp_graph::Reader, name: &str) -> Result<()> {

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
        let comp_name = format!("{}-{}", name, try!(n.get_comp()));
        for edge in &mut graph.edges {
            if edge.5 == name && edge.3 == try!(n.get_name()) {
                edge.5 = comp_name.clone();
                edge.3 = try!(n.get_port()).into();
            }
        }

        for iip in &mut graph.iips {
            if iip.3 == name && iip.1 == try!(n.get_name()) {
                iip.3 = comp_name.clone();
                iip.1 = try!(n.get_port()).into();
                iip.2 = try!(n.get_selection()).into();
            }
        }

        // add only if it's the main subnet
        if graph.nodes.len() < 1 {
            graph.ext_in.push((try!(n.get_name()).into(), comp_name, try!(n.get_port()).into(), try!(n.get_selection()).into()));
        }
    }
    for n in try!(new_graph.borrow().get_external_outputs()).iter() {
        let comp_name = format!("{}-{}", name, try!(n.get_comp()));
        for edge in &mut graph.edges {
            if edge.0 == name && edge.1 == try!(n.get_name()) {
                edge.0 = comp_name.clone();
                edge.1 = try!(n.get_port()).into();
            }
        }

        // add only if it's the main subnet
        if graph.nodes.len() < 1 {
            graph.ext_out.push((try!(n.get_name()).into(), comp_name, try!(n.get_port()).into(), try!(n.get_selection()).into()));
        }
    }

    for n in try!(new_graph.borrow().get_nodes()).iter() {
        let c_sort = try!(n.get_sort());
        let c_name = try!(n.get_name());

        let mut is_subnet = true;
        let path = if fs::metadata(format!("{}{}", c_sort, "/lib/libcomponent.so")).is_ok() {
            is_subnet = false;
            format!("{}{}", c_sort, "/lib/libcomponent.so")
        } else {
            format!("{}{}", c_sort, "/lib/lib.subnet")
        };

        if is_subnet {
            let mut msg = IP::new();
            {
                let mut number = msg.init_root::<path::Builder>();
                number.set_path(&path);
            }
            try!(component.ports.send("ask_graph", msg));

            // retrieve the asked graph
            let mut ip = try!(component.ports.recv("input"));
            let i_graph: fbp_graph::Reader = try!(ip.get_root());

            add_graph(component, &mut graph, i_graph, &format!("{}-{}", name, c_name));
        } else {
            graph.nodes.push((format!("{}-{}", name, c_name).into(), path.into()));
        }
    }
    Ok(())
}

fn send_graph(comp: &fvm, graph: &Graph) -> Result<()> {
    let mut new_ip = IP::new();
    {
        let mut ip = new_ip.init_root::<fbp_graph::Builder>();
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
                ext.borrow().get(i).set_comp(&e.1[..]);
                ext.borrow().get(i).set_port(&e.2[..]);
                ext.borrow().get(i).set_selection(&e.3[..]);
                i += 1;
            }
        }
        {
            let mut ext = ip.borrow().init_external_outputs(graph.ext_out.len() as u32);
            let mut i = 0;
            for e in &graph.ext_out {
                ext.borrow().get(i).set_name(&e.0[..]);
                ext.borrow().get(i).set_comp(&e.1[..]);
                ext.borrow().get(i).set_port(&e.2[..]);
                ext.borrow().get(i).set_selection(&e.3[..]);
                i += 1;
            }
        }
    }
    let _ = comp.ports.send("output", new_ip);
    Ok(())
}
