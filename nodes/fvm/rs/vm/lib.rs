#[macro_use]
extern crate rustfbp;

#[macro_use]
extern crate log;
use rustfbp::edges::core_action::CoreAction;
use rustfbp::edges::core_graph::{CoreGraph, CoreGraphNode, CoreGraphEdge, CoreGraphIMsg, CoreGraphExtIn, CoreGraphExtOut};
use rustfbp::edges::fs_path::FsPath;
use rustfbp::edges::fs_path_option::FsPathOption;
use std::fs;

type BAny = Box<Any + Send>;

agent! {
    input(input: CoreGraph, new_path: FsPathOption, error: BAny),
    output(output: CoreGraph, ask_graph: FsPath, ask_path: FsPath),
    fn run(&mut self) -> Result<Signal>{
        debug!("{:?}", env!("CARGO_PKG_NAME"));
        let mut errors = false;
        let mut graph = CoreGraph::new();

        // retrieve the asked graph
        let mut i_graph = self.input.input.recv()?;

        add_graph(self, (&mut errors, &mut graph), i_graph, "")?;

        if !errors {
            self.output.output.send(graph)?;
        }
        Ok(End)
    }
}
fn add_graph(agent: &ThisAgent, (mut errors, mut graph): (&mut bool, &mut CoreGraph), new_graph: CoreGraph, name: &str) -> Result<()> {

    if new_graph.path == "error" { *errors = true; }

    for e in new_graph.edges {
        graph.edges.push(CoreGraphEdge {
            out_comp: format!("{}-{}", name, e.out_comp),
            out_port: e.out_port,
            out_elem: e.out_elem,
            in_port: e.in_port,
            in_elem: e.in_elem,
            in_comp: format!("{}-{}", name, e.in_comp),
        });
    }
    for n in new_graph.imsgs {
        graph.imsgs.push(CoreGraphIMsg {
            msg: n.msg,
            port: n.port,
            elem: n.elem,
            comp: format!("{}-{}", name, n.comp),
        });
    }

    for n in new_graph.ext_in {
        let comp_name = format!("{}-{}", name, n.in_comp);
        for edge in &mut graph.edges {
            if edge.in_comp == name && edge.in_port == n.port {
                edge.in_comp = comp_name.clone();
                edge.in_port = n.in_port.clone();
            }
        }

        for imsg in &mut graph.imsgs {
            if imsg.comp == name && imsg.port == n.in_port {
                imsg.comp = comp_name.clone();
                imsg.port = n.in_port.clone();
                imsg.elem = n.in_elem.clone();
            }
        }

        // add only if it's the main subnet
        if graph.nodes.len() < 1 {
            graph.ext_in.push(CoreGraphExtIn {
                port: n.port,
                in_port: n.in_port,
                in_elem: n.in_elem,
                in_comp: comp_name,
            });
        }
    }

    for n in new_graph.ext_out {
        let comp_name = format!("{}-{}", name, n.out_comp);
        for edge in &mut graph.edges {
            if edge.out_comp == name && edge.out_port == n.port {
                edge.out_comp = comp_name.clone();
                edge.out_port = n.out_port.clone();
            }
        }

        // add only if it's the main subnet
        if graph.nodes.len() < 1 {
            graph.ext_out.push(CoreGraphExtOut {
                port: n.port,
                out_port: n.out_port,
                out_elem: n.out_elem,
                out_comp: comp_name,
            });
        }
    }

    for n in new_graph.nodes {
        agent.output.ask_path.send(FsPath(n.sort.clone()));

        let FsPathOption(new_path) = agent.input.new_path.recv()?;

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
                // println!("Error in : {}", new_graph.path);
                println!("agent {}({}) doesn't exist", n.name, n.sort);
                *errors = false;
                continue;
            }
        };

        if is_subgraph {
            agent.output.ask_graph.send(FsPath(path))?;

            // retrieve the asked graph
            let mut i_graph = agent.input.input.recv()?;

            add_graph(agent, (&mut errors, &mut graph), i_graph, &format!("{}-{}", name, n.name));
        } else {
            graph.nodes.push(CoreGraphNode {
                name: format!("{}-{}", name, n.name),
                sort: path,
            });
        }
    }
    Ok(())
}
