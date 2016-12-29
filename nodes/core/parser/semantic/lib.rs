#[macro_use]
extern crate rustfbp;
extern crate capnp;

#[derive(Debug)]
struct Graph {
    nodes: Vec<(String, String)>,
    edges: Vec<(String, String, String, String, String, String)>,
    imsgs: Vec<(String, String, String, String)>,
    ext_in: Vec<(String, String, String, String)>,
    ext_out: Vec<(String, String, String, String)>,
}

#[derive(PartialEq, Debug)]
enum State {
    Break, Compo, Port, IMSG,
    CompPort, CompPortBind, CompPortBindPort,
    CompPortExternal, CompPortExternalPort,
    PortExternal, PortExternalPort,
    IMSGBind, IMSGBindPort,
    ErrorS
}
use State::*;


enum Literal {
    Comp(String, String),
    Port(String, String),
    IMSG(String),
    Bind, External,
}

agent! {
    input(input: core_lexical),
    output(output: core_graph, error: core_semantic_error),
    fn run(&mut self) -> Result<Signal> {
        let mut msg = self.input.input.recv()?;
        let literal: core_lexical::Reader = msg.read_schema()?;
        let literal = literal.which()?;

        match literal {
            core_lexical::Start(path) => {
                match handle_stream(&self)? {
                    Ok(graph) => { send_graph(&self, path?, &graph)? },
                    Err(errors) => {
                        let mut new_msg = Msg::new();
                        {
                            let mut msg = new_msg.build_schema::<core_semantic_error::Builder>();
                            // msg.set_path(path?);
                            msg.borrow().set_path(path?);
                            {
                                let mut nodes = msg.borrow().init_parsing(errors.len() as u32);
                                let mut i = 0;
                                for n in &errors {
                                    nodes.borrow().set(i, &n[..]);
                                    i += 1;
                                }
                            }
                        }
                        let _ = self.output.error.send(new_msg);
                    },
                }
            }
            _ => { return Err(result::Error::Misc("bad stream".to_string())); },
        }
        Ok(End)
    }
}

fn handle_stream(comp: &ThisAgent) -> Result<std::result::Result<Graph, Vec<String>>> {
    let mut state = Break;
    let mut stack: Vec<Literal> = vec![];
    let mut graph = Graph {
        nodes: vec![],
        edges: vec![],
        imsgs: vec![],
        ext_in: vec![],
        ext_out: vec![]
    };
    let mut errors: Vec<String> = vec![];
    let mut line: usize = 1;

    loop {

        let mut msg = comp.input.input.recv()?;
        let literal: core_lexical::Reader = msg.read_schema()?;
        let literal = literal.which()?;
        match literal {
            core_lexical::End(_) => {
                break;
            },
            core_lexical::Token(t) => {
                let token = t.which()?;
                match token {
                    core_lexical::token::Bind(_) => {
                        state = match state {
                            CompPort => { CompPortBind },
                            ErrorS => { ErrorS },
                            IMSG => { IMSGBind },
                            _ => {
                                errors.push(format!("line {} : Found a \"->\", when \"{}\" was expected.", line, get_expected(&state)));
                                ErrorS
                            },
                        };
                    },
                    core_lexical::token::External(_) => {
                        state = match state {
                            CompPort => { CompPortExternal },
                            Port => { PortExternal },
                            ErrorS => { ErrorS },
                            _ => {
                                errors.push(format!("line {} : Found a \"=>\", when \"{}\" was expected.", line, get_expected(&state)));
                                ErrorS
                            },
                        };
                    },
                    core_lexical::token::Port(port) => {
                        stack.push(Literal::Port(port.get_name()?.to_string(), port.get_selection()?.to_string()));
                        state = match state {
                            Compo => { CompPort },
                            CompPortBind => { CompPortBindPort },
                            CompPortExternal => {
                                let in_p = stack.pop().ok_or(result::Error::Misc("stack problem".into()))?;
                                let out_p = stack.pop().ok_or(result::Error::Misc("stack problem".into()))?;
                                let out_c = stack.pop().ok_or(result::Error::Misc("stack problem".into()))?;
                                {
                                    let (in_p_n, _) = if let Literal::Port(n, s) = in_p { (n, s) } else { unreachable!() };
                                    let (out_c_n, _) = if let Literal::Comp(ref n, ref s) = out_c { (n, s) } else { unreachable!() };
                                    let (out_p_n, out_p_s) = if let Literal::Port(n, s) = out_p { (n, s) } else { unreachable!() };
                                    graph.ext_out.push((out_c_n.clone(), out_p_n, out_p_s, in_p_n));
                                }
                                CompPortExternalPort },
                            Break => { Port },
                            PortExternal => { PortExternalPort },
                            ErrorS => { ErrorS },
                            IMSGBind => { IMSGBindPort },
                            _ => {
                                errors.push(format!("line {} : Found port \"{}[{}]\", when \"{}\" was expected.", line, port.get_name()?, port.get_selection()?, get_expected(&state)));
                                ErrorS
                            },
                        };
                    },
                    core_lexical::token::Comp(comp) => {
                        if comp.get_sort()? != "" {
                            graph.nodes.push((comp.get_name()?.to_string(), comp.get_sort()?.to_string()));
                        }
                        stack.push(Literal::Comp(comp.get_name()?.to_string(), comp.get_sort()?.to_string()));
                        state = match state {
                            CompPortBindPort => {
                                let in_c = stack.pop().ok_or(result::Error::Misc("stack problem".into()))?;
                                let in_p = stack.pop().ok_or(result::Error::Misc("stack problem".into()))?;
                                let out_p = stack.pop().ok_or(result::Error::Misc("stack problem".into()))?;
                                let out_c = stack.pop().ok_or(result::Error::Misc("stack problem".into()))?;
                                {
                                    let (in_c_n, _) = if let Literal::Comp(ref n, ref s) = in_c { (n, s) } else { unreachable!() };
                                    let (in_p_n, in_p_s) = if let Literal::Port(n, s) = in_p { (n, s) } else { unreachable!() };
                                    let (out_p_n, out_p_s) = if let Literal::Port(n, s) = out_p { (n, s) } else { unreachable!() };
                                    let (out_c_n, _) = if let Literal::Comp(n, s) = out_c { (n, s) } else { unreachable!() };
                                    graph.edges.push((out_c_n, out_p_n, out_p_s, in_p_n, in_p_s, in_c_n.clone()));
                                }
                                stack.push(in_c);
                                Compo
                            },
                            PortExternalPort => {
                                let in_c = stack.pop().ok_or(result::Error::Misc("stack problem".into()))?;
                                let in_p = stack.pop().ok_or(result::Error::Misc("stack problem".into()))?;
                                let out_p = stack.pop().ok_or(result::Error::Misc("stack problem".into()))?;
                                {
                                    let (in_c_n, _) = if let Literal::Comp(ref n, ref s) = in_c { (n, s) } else { unreachable!() };
                                    let (in_p_n, in_p_s) = if let Literal::Port(n, s) = in_p { (n, s) } else { unreachable!() };
                                    let (out_p_n, out_p_s) = if let Literal::Port(n, s) = out_p { (n, s) } else { unreachable!() };
                                    graph.ext_in.push((out_p_n, in_p_n, in_p_s, in_c_n.clone()));
                                }
                                stack.push(in_c);
                                Compo
                            }
                            IMSGBindPort => {
                                let in_c = stack.pop().ok_or(result::Error::Misc("stack problem".into()))?;
                                let in_p = stack.pop().ok_or(result::Error::Misc("stack problem".into()))?;
                                let imsg = stack.pop().ok_or(result::Error::Misc("stack problem".into()))?;
                                {
                                    let (in_c_n, _) = if let Literal::Comp(ref n, ref s) = in_c { (n, s) } else { unreachable!() };
                                    let (in_p_n, in_p_s) = if let Literal::Port(n, s) = in_p { (n, s) } else { unreachable!() };
                                    let imsg = if let Literal::IMSG(imsg) = imsg { imsg } else { unreachable!() };
                                    graph.imsgs.push((imsg, in_p_n, in_p_s, in_c_n.clone()));
                                }
                                stack.push(in_c);
                                Compo
                            }
                            Break => { Compo },
                            ErrorS => { stack = vec![stack.pop().ok_or(result::Error::Misc("stack problem".into()))?]; Compo },
                            _ => {
                                errors.push(format!("line {} : Found agent \"{}({})\", when \"{}\" was expected.", line, comp.get_name()?, comp.get_sort()?, get_expected(&state)));
                                ErrorS
                            },
                        }
                    },
                    core_lexical::token::Imsg(imsg) => {
                        let imsg = imsg?;
                        stack.push(Literal::IMSG(imsg.to_string()));
                        state = match state {
                            ErrorS => { IMSG },
                            Break => { IMSG },
                            _ => {
                                errors.push(format!("line {} : Found an IMSG \"{}\", when \"{}\" was expected.", line, imsg, get_expected(&state)));
                                ErrorS
                            },
                        };
                    },
                    core_lexical::token::Break(_) => {
                        line += 1;
                        state = match state {
                            CompPortBind => { state },
                            IMSGBind => { state },
                            Compo => { stack.clear(); Break },
                            CompPortExternalPort => { stack.clear(); Break },
                            Break => { Break },
                            ErrorS => { ErrorS },
                            _ => {
                                errors.push(format!("line {} : Found a \"\n\" or (new line), when \"{}\" was expected.", line, get_expected(&state)));
                                ErrorS
                            },
                        };
                    }
                }
            },
            _ => { panic!("bad stream"); },
        }
    }
    if errors.len() > 0 {
        Ok(Err(errors))
    } else {
        Ok(Ok(graph))
    }
}

fn get_expected(state: &State) -> String {
    match *state {
        Break => { "[Component, Port, IMSG, NewLine]".into() },
        Compo => { "[Port, NewLine]".into() },
        Port => { "[Component, ->, =>]".into() },
        IMSG => { "[->]".into() },
        CompPort => { "[->, =>]".into() },
        CompPortBind => { "[Port]".into() },
        CompPortBindPort => { "[Component]".into() },
        CompPortExternal => { "[Port]".into() },
        CompPortExternalPort => { "[NewLine]".into() },
        PortExternal => { "[Port]".into() },
        PortExternalPort => { "[Component]".into() },
        IMSGBind => { "[Port]".into() },
        IMSGBindPort => { "[Component]".into() },
        ErrorS => { unreachable!() }
    }
}

fn send_graph(comp: &ThisAgent, path: &str, graph: &Graph) -> Result<()> {
    let mut new_msg = Msg::new();
    {
        let mut msg = new_msg.build_schema::<core_graph::Builder>();
        msg.borrow().set_path(path);
        {
            let mut nodes = msg.borrow().init_nodes().init_list(graph.nodes.len() as u32);
            let mut i = 0;
            for n in &graph.nodes {
                nodes.borrow().get(i).set_name(&n.0[..]);
                nodes.borrow().get(i).set_sort(&n.1[..]);
                i += 1;
            }
        }
        {
            let mut edges = msg.borrow().init_edges().init_list(graph.edges.len() as u32);
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
            let mut imsgs = msg.borrow().init_imsgs().init_list(graph.imsgs.len() as u32);
            let mut i = 0;
            for imsg in &graph.imsgs {
                imsgs.borrow().get(i).set_imsg(&imsg.0[..]);
                imsgs.borrow().get(i).set_port(&imsg.1[..]);
                imsgs.borrow().get(i).set_selection(&imsg.2[..]);
                imsgs.borrow().get(i).set_comp(&imsg.3[..]);
                i += 1;
            }
        }
        {
            let mut ext = msg.borrow().init_external_inputs().init_list(graph.ext_in.len() as u32);
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
            let mut ext = msg.borrow().init_external_outputs().init_list(graph.ext_out.len() as u32);
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
    let _ = comp.output.output.send(new_msg);
    Ok(())
}
