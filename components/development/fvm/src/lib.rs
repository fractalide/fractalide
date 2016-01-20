#[macro_use]
extern crate rustfbp;

extern crate capnp;

mod contract_capnp {
    include!("path.rs");
    include!("fbp_graph.rs");
    include!("fbp_fvm_option.rs");
}
use contract_capnp::path;
use contract_capnp::graph;
use contract_capnp::option;

#[derive(Debug)]
struct Graph {
    nodes: Vec<(String, String)>,
    edges: Vec<(String, String, String, String, String, String)>,
    iips: Vec<(String, String, String, String)>,
    ext_in: Vec<(String, String, String, String)>,
    ext_out: Vec<(String, String, String, String)>,
}

component! {
    fvm,
    inputs(input: graph, error: any),
    inputs_array(),
    outputs(ask_graph: text, give_graph: graph),
    outputs_array(),
    option(fbp_option),
    acc(),
    fn run(&mut self) {
        let mut graph = Graph {
            nodes: vec![], edges: vec![], iips: vec![],
            ext_in: vec![], ext_out: vec![],
        };

        // retrieve the path of the map files
        let mut ip = self.recv_option();
        let opt = ip.get_reader().expect("fvm: cannot get reader");
        let opt: option::Reader = opt.get_root().expect("fvm: not an option");
        println!("{}\n{}", opt.get_component().unwrap(), opt.get_subnet().unwrap());


        // retrieve the asked graph
        let mut ip = self.ports.recv("input".into()).expect("cannot receive");
        let i_graph = ip.get_reader().expect("fvm: cannot get reader");
        let i_graph: graph::Reader = i_graph.get_root().expect("fvm: not a graph");

        add_graph(self, &mut graph, i_graph, "");
        println!("{:#?}", graph);

    }
}

fn add_graph(component: &fvm, mut graph: &mut Graph, new_graph: graph::Reader, name: &str) {

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
        if c_sort == "not"  || c_sort == "not2" {
            // TODO : get the graph of not
            let mut msg = capnp::message::Builder::new_default();
            {
                let mut number = msg.init_root::<path::Builder>();
                if c_sort == "not" { number.set_path("/home/denis/test2.fbp"); }
                else { number.set_path("/home/denis/test3.fbp"); }
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
            // TODO : it's a component, replace the path
            graph.nodes.push((format!("{}-{}", name, c_name).into(), c_sort.into()));
        }
    }
}

    // PRINT ERRORS
    /*
        match self.ports.try_recv("semantic_error".into()) {
            Ok(mut ip) => {
                let error = ip.get_reader().expect("fbp_print_graph : cannot get reader");
                let error: semantic_error::Reader = error.get_root().expect("fbp_print_graph : not a literal");

                println!("Graph at : {}", error.get_path().unwrap());
                let parsing = error.get_parsing().unwrap();
                for i in 0..parsing.len() {
                    println!("{}", parsing.get(i).unwrap());
                }
            }
            _ => {}
        };
        match self.ports.try_recv("file_error".into()) {
            Ok(mut ip) => {
                let error = ip.get_reader().expect("fbp_print_graph : cannot get reader");
                let error: file_error::Reader = error.get_root().expect("fbp_print_graph : not a literal");
                println!("File not exist at : {}", error.get_not_found().unwrap());
            }
            _ => {}
        };
    */
