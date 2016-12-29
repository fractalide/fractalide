#[macro_use]
extern crate rustfbp;
extern crate capnp;

use std::fs;

#[derive(Debug)]
struct Graph {
    errors: bool,
    nodes: Vec<(String, String)>,
    edges: Vec<(String, String, String, String, String, String)>,
    imsgs: Vec<(String, String, String, String)>,
    ext_in: Vec<(String, String, String, String)>,
    ext_out: Vec<(String, String, String, String)>,
}

agent! {
    input(input: core_graph, new_path: fs_path_option, error: any),
    output(output: core_graph, ask_graph: fs_path, ask_path: fs_path),
    fn run(&mut self) -> Result<Signal>{
        let mut graph = Graph { errors: false,
            nodes: vec![], edges: vec![], imsgs: vec![],
            ext_in: vec![], ext_out: vec![],
        };

        // retrieve the asked graph
        let mut msg = self.input.input.recv()?;
        let i_graph: core_graph::Reader = msg.read_schema()?;

        add_graph(self, &mut graph, i_graph, "")?;

        if !graph.errors {
            send_graph(&self, &graph)?
        }
        Ok(End)
    }
}

fn add_graph(agent: &ThisAgent, mut graph: &mut Graph, new_graph: core_graph::Reader, name: &str) -> Result<()> {

    if new_graph.get_path()?.get_text()? == "error" { graph.errors = true; }

    for n in new_graph.borrow().get_edges()?.get_list()?.iter() {
        graph.edges.push((format!("{}-{}", name, n.get_o_name()?.get_text()?),
        n.get_o_port()?.get_text()?.into(), n.get_o_selection()?.get_text()?.into(),
        n.get_i_port()?.get_text()?.into(), n.get_i_selection()?.get_text()?.into(),
        format!("{}-{}", name, n.get_i_name()?.get_text()?)));
    }
    for n in new_graph.borrow().get_imsgs()?.get_list()?.iter() {
        graph.imsgs.push((n.get_imsg()?.get_text()?.into(),
        n.get_port()?.get_text()?.into(), n.get_selection()?.get_text()?.into(),
        format!("{}-{}", name, n.get_comp()?.get_text()?) ));
    }
    for n in new_graph.borrow().get_external_inputs()?.get_list()?.iter() {
        let comp_name = format!("{}-{}", name, n.get_comp()?.get_text()?);
        for edge in &mut graph.edges {
            if edge.5 == name && edge.3 == n.get_name()?.get_text()? {
                edge.5 = comp_name.clone();
                edge.3 = n.get_port()?.get_text()?.into();
            }
        }

        for imsg in &mut graph.imsgs {
            if imsg.3 == name && imsg.1 == n.get_name()?.get_text()? {
                imsg.3 = comp_name.clone();
                imsg.1 = n.get_port()?.get_text()?.into();
                imsg.2 = n.get_selection()?.get_text()?.into();
            }
        }

        // add only if it's the main subnet
        if graph.nodes.len() < 1 {
            graph.ext_in.push((
                n.get_name()?.get_text()?.into()
                , comp_name
                , n.get_port()?.get_text()?.into()
                , n.get_selection()?.get_text()?.into()));
        }
    }
    for n in new_graph.borrow().get_external_outputs()?.get_list()?.iter() {
        let comp_name = format!("{}-{}", name, n.get_comp()?.get_text()?);
        for edge in &mut graph.edges {
            if edge.0 == name && edge.1 == n.get_name()?.get_text()? {
                edge.0 = comp_name.clone();
                edge.1 = n.get_port()?.get_text()?.into();
            }
        }

        // add only if it's the main subnet
        if graph.nodes.len() < 1 {
            graph.ext_out.push((
                n.get_name()?.get_text()?.into()
                , comp_name
                , n.get_port()?.get_text()?.into()
                , n.get_selection()?.get_text()?.into()));
        }
    }

    for n in new_graph.borrow().get_nodes()?.get_list()?.iter() {
        let c_sort = n.get_sort()?.get_text()?;
        let c_name = n.get_name()?.get_text()?;

        let mut msg = Msg::new();
        {
            let mut path = msg.build_schema::<fs_path::Builder>();
            path.get_path()?.set_text(&c_sort);
        }
        agent.output.ask_path.send(msg)?;

        let mut msg = agent.input.new_path.recv()?;
        let i_graph: fs_path_option::Reader = msg.read_schema()?;

        let new_path: Option<String> = match i_graph.which()? {
            fs_path_option::Path(p) => { Some(p?.get_text()?.into()) },
            fs_path_option::None(p) => { None }
        };
        let mut is_subgraph = true;
        let path = match new_path {
            Some(hash_name) => {
                let path = format!("{}{}", hash_name.trim(), "/lib/libagent.so");
                if fs::metadata(&path).is_ok() {
                    is_subgraph = false;
                    path
                } else {
                    format!("{}{}", hash_name.trim(), "/lib/lib.subgraph")
                }
            },
            None => {
                println!("Error in : {}", new_graph.get_path()?.get_text()?);
                println!("agent {}({}) doesn't exist", c_name, c_sort);
                graph.errors = false;
                continue;
            }
        };

        if is_subgraph {
            let mut msg = Msg::new();
            {
                let mut number = msg.build_schema::<fs_path::Builder>();
                number.get_path()?.set_text(&path);
            }
            agent.output.ask_graph.send(msg)?;

            // retrieve the asked graph
            let mut msg = agent.input.input.recv()?;
            let i_graph: core_graph::Reader = msg.read_schema()?;

            add_graph(agent, &mut graph, i_graph, &format!("{}-{}", name, c_name));
        } else {
            graph.nodes.push((format!("{}-{}", name, c_name).into(), path.into()));
        }
    }
    Ok(())
}

fn send_graph(comp: &ThisAgent, graph: &Graph) -> Result<()> {
    let mut new_msg = Msg::new();
    {
        let mut msg = new_msg.build_schema::<core_graph::Builder>();
        msg.borrow().get_path()?.set_text("");
        {
            let mut nodes = msg.borrow().init_nodes().init_list(graph.nodes.len() as u32);
            let mut i = 0;
            for n in &graph.nodes {
                nodes.borrow().get(i).get_name()?.set_text(&n.0[..]);
                nodes.borrow().get(i).get_sort()?.set_text(&n.1[..]);
                i += 1;
            }
        }
        {
            let mut edges = msg.borrow().init_edges().init_list(graph.edges.len() as u32);
            let mut i = 0;
            for e in &graph.edges {
                edges.borrow().get(i).get_o_name()?.set_text(&e.0[..]);
                edges.borrow().get(i).get_o_port()?.set_text(&e.1[..]);
                edges.borrow().get(i).get_o_selection()?.set_text(&e.2[..]);
                edges.borrow().get(i).get_i_port()?.set_text(&e.3[..]);
                edges.borrow().get(i).get_i_selection()?.set_text(&e.4[..]);
                edges.borrow().get(i).get_i_name()?.set_text(&e.5[..]);
                i += 1;
            }
        }
        {
            let mut imsgs = msg.borrow().init_imsgs().init_list(graph.imsgs.len() as u32);
            let mut i = 0;
            for imsg in &graph.imsgs {
                imsgs.borrow().get(i).get_imsg()?.set_text(&imsg.0[..]);
                imsgs.borrow().get(i).get_port()?.set_text(&imsg.1[..]);
                imsgs.borrow().get(i).get_selection()?.set_text(&imsg.2[..]);
                imsgs.borrow().get(i).get_comp()?.set_text(&imsg.3[..]);
                i += 1;
            }
        }
        {
            let mut ext = msg.borrow().init_external_inputs().init_list(graph.ext_in.len() as u32);
            let mut i = 0;
            for e in &graph.ext_in {
                ext.borrow().get(i).get_name()?.set_text(&e.0[..]);
                ext.borrow().get(i).get_comp()?.set_text(&e.1[..]);
                ext.borrow().get(i).get_port()?.set_text(&e.2[..]);
                ext.borrow().get(i).get_selection()?.set_text(&e.3[..]);
                i += 1;
            }
        }
        {
            let mut ext = msg.borrow().init_external_outputs().init_list(graph.ext_out.len() as u32);
            let mut i = 0;
            for e in &graph.ext_out {
                ext.borrow().get(i).get_name()?.set_text(&e.0[..]);
                ext.borrow().get(i).get_comp()?.set_text(&e.1[..]);
                ext.borrow().get(i).get_port()?.set_text(&e.2[..]);
                ext.borrow().get(i).get_selection()?.set_text(&e.3[..]);
                i += 1;
            }
        }
    }
    let _ = comp.output.output.send(new_msg);
    Ok(())
}
