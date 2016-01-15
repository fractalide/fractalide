#[macro_use]
extern crate rustfbp;
use rustfbp::component::*;

extern crate capnp;

mod contract_capnp {
    include!("fbp_graph.rs");
    include!("fbp_lexical.rs");
}
use contract_capnp::graph;
use contract_capnp::lexical;

#[derive(Debug)]
struct Graph {
    nodes: Vec<(String, String)>,
    edges: Vec<(String, String, String, String, String, String)>,
    iips: Vec<(String, String, String, String)>,
    ext_in: Vec<(String, String, String, String)>,
    ext_out: Vec<(String, String, String, String)>,
}

#[derive(PartialEq, Debug)]
enum State {
    Break, Comp, Port, IIP,
    CompPort, CompPortBind, CompPortBindPort,
    CompPortExternal, CompPortExternalPort,
    PortExternal, PortExternalPort,
    IIPBind, IIPBindPort,
    Error
}
use State::*;


enum Literal {
    Comp(String, String),
    Port(String, String),
    IIP(String),
    Bind, External,
}

component! {
    fbp_semantic,
    inputs(input: fbp_lexical),
    inputs_array(),
    outputs(output: fbp_graph),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) {
        let mut ip = self.ports.recv("input".into()).expect("fbp_semantic : unable to receive");
        let literal = ip.get_reader().expect("fbp_semantic : cannot get reader");
        let literal: lexical::Reader = literal.get_root().expect("fbp_semantic : not a literal");
        let literal = literal.which().expect("fbp_semantic : cannot which");

        match literal {
            lexical::Start(path) => {
                match handle_stream(&self) {
                    Ok(graph) => { send_graph(&self, &graph) },
                    Err(errors) => {
                        let mut new_ip = capnp::message::Builder::new_default();
                        {
                            let mut ip = new_ip.init_root::<graph::Builder>();
                            {
                                let mut ip = ip.init_errors();
                                {
                                    let mut nodes = ip.borrow().init_parsing(errors.len() as u32);
                                    let mut i = 0;
                                    for n in &errors {
                                        nodes.borrow().set(i, &n[..]);
                                        i += 1;
                                    }
                                }
                            }
                        }
                        let mut send_ip = self.allocator.ip.build_empty();
                        send_ip.write_builder(&new_ip).expect("fbp_lexical: cannot write");
                        let _ = self.ports.send("output".into(), send_ip);
                    },
                }
            }
            lexical::NotFound(path) => {
                // send notFound oustise
                let mut new_ip = capnp::message::Builder::new_default();
                let mut send_ip = self.allocator.ip.build_empty();
                {
                    let mut ip = new_ip.init_root::<graph::Builder>();
                    ip.init_errors().set_not_found(path.expect("not a path"));
                }
                send_ip.write_builder(&new_ip).expect("file_open: cannot write");
                self.ports.send("output".into(), send_ip).expect("file_open: cannot send start");
            }
            _ => { panic!("bad stream") },
        }
    }
}

fn handle_stream(comp: &fbp_semantic) -> std::result::Result<Graph, Vec<String>> {
    let mut state = Break;
    let mut stack: Vec<Literal> = vec![];
    let mut graph = Graph {
        nodes: vec![],
        edges: vec![],
        iips: vec![],
        ext_in: vec![],
        ext_out: vec![]
    };
    let mut errors: Vec<String> = vec![];
    let mut line: usize = 1;

    loop {

        let mut ip = comp.ports.recv("input".into()).expect("fbp_semantic : unable to receive");
        let literal = ip.get_reader().expect("fbp_semantic : cannot get reader");
        let literal: lexical::Reader = literal.get_root().expect("fbp_semantic : not a literal");
        let literal = literal.which().expect("fbp_semantic : cannot which");
        match literal {
            lexical::End(_) => {
                break;
            },
            lexical::Token(t) => {
                let token = t.which().expect("cannot which token");
                if state == Error {
                    if let lexical::token::Break(()) = token {
                        if state != CompPortBind && state != IIPBind { state = Break; }
                    }
                    else if let lexical::token::Comp(_) = token {
                        state = Break;
                    }
                    else { continue; }
                }
                match token {
                    lexical::token::Bind(_) => {
                        state = match state {
                            CompPort => { CompPortBind },
                            IIP => { IIPBind },
                            _ => {
                                errors.push(format!("line {} : -> found, one of {} expected", line, get_expected(&state)));
                                Error
                            },
                        };
                    },
                    lexical::token::External(_) => {
                        state = match state {
                            CompPort => { CompPortExternal },
                            Port => { PortExternal },
                            _ => {
                                errors.push(format!("line {} : => found, one of {} expected", line, get_expected(&state)));
                                Error
                            },
                        };
                    },
                    lexical::token::Port(port) => {
                        stack.push(Literal::Port(port.get_name().unwrap().to_string(), port.get_selection().unwrap().to_string()));
                        state = match state {
                            Comp => { CompPort },
                            CompPortBind => { CompPortBindPort },
                            CompPortExternal => {
                                let in_p = stack.pop().unwrap();
                                let out_p = stack.pop().unwrap();
                                let out_c = stack.pop().unwrap();
                                {
                                    let (in_p_n, _) = if let Literal::Port(n, s) = in_p { (n, s) } else { unreachable!() };
                                    let (out_c_n, _) = if let Literal::Comp(ref n, ref s) = out_c { (n, s) } else { unreachable!() };
                                    let (out_p_n, out_p_s) = if let Literal::Port(n, s) = out_p { (n, s) } else { unreachable!() };
                                    graph.ext_out.push((out_c_n.clone(), out_p_n, out_p_s, in_p_n));
                                }
                                CompPortExternalPort },
                            Break => { Port },
                            PortExternal => { PortExternalPort },
                            IIPBind => { IIPBindPort },
                            _ => {
                                errors.push(format!("line {} : Port {}[{}] found, one of {} expected", line, port.get_name().unwrap(), port.get_selection().unwrap(), get_expected(&state)));
                                Error
                            },
                        };
                    },
                    lexical::token::Comp(comp) => {
                        if comp.get_sort().unwrap() != "" {
                            graph.nodes.push((comp.get_name().unwrap().to_string(), comp.get_sort().unwrap().to_string()));
                        }
                        stack.push(Literal::Comp(comp.get_name().unwrap().to_string(), comp.get_sort().unwrap().to_string()));
                        state = match state {
                            CompPortBindPort => {
                                let in_c = stack.pop().unwrap();
                                let in_p = stack.pop().unwrap();
                                let out_p = stack.pop().unwrap();
                                let out_c = stack.pop().unwrap();
                                {
                                    let (in_c_n, _) = if let Literal::Comp(ref n, ref s) = in_c { (n, s) } else { unreachable!() };
                                    let (in_p_n, in_p_s) = if let Literal::Port(n, s) = in_p { (n, s) } else { unreachable!() };
                                    let (out_p_n, out_p_s) = if let Literal::Port(n, s) = out_p { (n, s) } else { unreachable!() };
                                    let (out_c_n, _) = if let Literal::Comp(n, s) = out_c { (n, s) } else { unreachable!() };
                                    graph.edges.push((out_c_n, out_p_n, out_p_s, in_p_n, in_p_s, in_c_n.clone()));
                                }
                                stack.push(in_c);
                                Comp
                            },
                            PortExternalPort => {
                                let in_c = stack.pop().unwrap();
                                let in_p = stack.pop().unwrap();
                                let out_p = stack.pop().unwrap();
                                {
                                    let (in_c_n, _) = if let Literal::Comp(ref n, ref s) = in_c { (n, s) } else { unreachable!() };
                                    let (in_p_n, in_p_s) = if let Literal::Port(n, s) = in_p { (n, s) } else { unreachable!() };
                                    let (out_p_n, out_p_s) = if let Literal::Port(n, s) = out_p { (n, s) } else { unreachable!() };
                                    graph.ext_in.push((out_p_n, in_p_n, in_p_s, in_c_n.clone()));
                                }
                                stack.push(in_c);
                                Comp
                            }
                            IIPBindPort => {
                                let in_c = stack.pop().unwrap();
                                let in_p = stack.pop().unwrap();
                                let iip = stack.pop().unwrap();
                                {
                                    let (in_c_n, _) = if let Literal::Comp(ref n, ref s) = in_c { (n, s) } else { unreachable!() };
                                    let (in_p_n, in_p_s) = if let Literal::Port(n, s) = in_p { (n, s) } else { unreachable!() };
                                    let iip = if let Literal::IIP(iip) = iip { iip } else { unreachable!() };
                                    graph.iips.push((iip, in_p_n, in_p_s, in_c_n.clone()));
                                }
                                stack.push(in_c);
                                Comp
                            }
                            Break => { Comp },
                            _ => {
                                errors.push(format!("line {} : Comp {}({}) found, one of {} expected", line, comp.get_name().unwrap(), comp.get_sort().unwrap(), get_expected(&state)));
                                Error
                            },
                        }
                    },
                    lexical::token::Iip(iip) => {
                        let iip = iip.expect("no iip");
                        stack.push(Literal::IIP(iip.to_string()));
                        state = match state {
                            Break => { IIP },
                            _ => {
                                errors.push(format!("line {} : IIP '{}' found, one of {} expected", line, iip, get_expected(&state)));
                                Error
                            },
                        };
                    },
                    lexical::token::Break(_) => {
                        line += 1;
                        state = match state {
                            CompPortBind => { state },
                            IIPBind => { state },
                            _ => {
                                stack.clear();
                                Break
                            },
                        };
                    }
                }
            },
            _ => { panic!("bad stream"); },
        }
    }
    if errors.len() > 0 {
        Err(errors)
    } else {
        Ok(graph)
    }
}

fn get_expected(state: &State) -> String {
    match *state {
        Break => { "[Component, Port, IIP, NewLine]".into() },
        Comp => { "[Port, NewLine]".into() },
        Port => { "[Component, ->, =>]".into() },
        IIP => { "[->]".into() },
        CompPort => { "[->, =>]".into() },
        CompPortBind => { "[Port]".into() },
        CompPortBindPort => { "[Component]".into() },
        CompPortExternal => { "[Port]".into() },
        CompPortExternalPort => { "[NewLine]".into() },
        PortExternal => { "[Port]".into() },
        PortExternalPort => { "[Component]".into() },
        IIPBind => { "[Port]".into() },
        IIPBindPort => { "[Component]".into() },
        Error => { unreachable!() }
    }
}

fn send_graph(comp: &fbp_semantic, graph: &Graph) {
    let mut new_ip = capnp::message::Builder::new_default();
    {
        let mut ip = new_ip.init_root::<graph::Builder>();
        {
            let mut ip = ip.init_graph();
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
    }
    let mut send_ip = comp.allocator.ip.build_empty();
    send_ip.write_builder(&new_ip).expect("fbp_lexical: cannot write");
    let _ = comp.ports.send("output".into(), send_ip);
}
