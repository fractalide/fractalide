#[macro_use]
extern crate rustfbp;
extern crate capnp;

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

agent! {
    input(input: CoreLexical),
    output(output: CoreGraph, error: CoreSemanticError),
    fn run(&mut self) -> Result<Signal> {
        let literal = self.input.input.recv()?;

        match literal {
            CoreLexical::Start(path) => {
                match handle_stream(&self)? {
                    Ok(mut graph) => {
                        graph.path = path;
                        self.output.output.send(graph);
                    },
                    Err(errors) => {
                        let err = CoreSemanticError {
                            path: path,
                            parsing: errors,
                        };
                        let _ = self.output.error.send(err);
                    },
                }
            }
            _ => { return Err(result::Error::Misc("bad stream".to_string())); },
        }
        Ok(End)
    }
}

fn handle_stream(comp: &ThisAgent) -> Result<std::result::Result<CoreGraph, Vec<String>>> {
    let mut state = Break;
    let mut stack: Vec<CoreLexicalToken> = vec![];
    let mut graph = CoreGraph::new();
    let mut errors: Vec<String> = vec![];
    let mut line: usize = 1;

    loop {
        let literal = comp.input.input.recv()?;
        match literal {
            CoreLexical::End(_) => {
                break;
            },
            CoreLexical::Token(token) => {
                match token {
                    CoreLexicalToken::Bind => {
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
                    CoreLexicalToken::External => {
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
                    CoreLexicalToken::Port(name, elem) => {
                        state = match state {
                            Compo => { stack.push(CoreLexicalToken::Port(name, elem)); CompPort },
                            CompPortBind => { stack.push(CoreLexicalToken::Port(name, elem)); CompPortBindPort },
                            CompPortExternal => {
                                let out_p = stack.pop().ok_or(result::Error::Misc("stack problem".into()))?;
                                let out_c = stack.pop().ok_or(result::Error::Misc("stack problem".into()))?;
                                {
                                    let in_p_n = name;
                                    let (out_c_n, _) = if let CoreLexicalToken::Comp(n, s) = out_c { (n, s) } else { unreachable!() };
                                    let (out_p_n, out_p_s) = if let CoreLexicalToken::Port(n, s) = out_p { (n, s) } else { unreachable!() };
                                    graph.ext_out.push(CoreGraphExtOut{
                                        port: in_p_n,
                                        out_port: out_p_n,
                                        out_elem: out_p_s,
                                        out_comp: out_c_n,
                                    });
                                }
                                CompPortExternalPort },
                            Break => { stack.push(CoreLexicalToken::Port(name, elem)); Port },
                            PortExternal => { stack.push(CoreLexicalToken::Port(name, elem)); PortExternalPort },
                            ErrorS => { stack.push(CoreLexicalToken::Port(name, elem)); ErrorS },
                            IMSGBind => { stack.push(CoreLexicalToken::Port(name, elem)); IMSGBindPort },
                            _ => {
                                errors.push(format!("line {} : Found port \"{}[{}]\", when \"{}\" was expected.", line, name, elem.unwrap_or("".into()), get_expected(&state)));
                                ErrorS
                            },
                        };
                    },
                    CoreLexicalToken::Comp(name, sort) => {
                        if let Some(ref s) = sort {
                            if s != "" {
                                graph.nodes.push(CoreGraphNode {
                                    name: name.clone(),
                                    sort: s.clone(),
                                });
                            }
                        }
                        state = match state {
                            CompPortBindPort => {
                                let in_p = stack.pop().ok_or(result::Error::Misc("stack problem".into()))?;
                                let out_p = stack.pop().ok_or(result::Error::Misc("stack problem".into()))?;
                                let out_c = stack.pop().ok_or(result::Error::Misc("stack problem".into()))?;
                                {
                                    let in_c_n = name.clone();
                                    let (in_p_n, in_p_s) = if let CoreLexicalToken::Port(n, s) = in_p { (n, s) } else { unreachable!() };
                                    let (out_p_n, out_p_s) = if let CoreLexicalToken::Port(n, s) = out_p { (n, s) } else { unreachable!() };
                                    let (out_c_n, _) = if let CoreLexicalToken::Comp(n, s) = out_c { (n, s) } else { unreachable!() };
                                    graph.edges.push(CoreGraphEdge {
                                        out_comp: out_c_n,
                                        out_port: out_p_n,
                                        out_elem: out_p_s,
                                        in_port: in_p_n,
                                        in_elem: in_p_s,
                                        in_comp: in_c_n,
                                    });
                                }
                                stack.push(CoreLexicalToken::Comp(name, sort));
                                Compo
                            },
                            PortExternalPort => {
                                let in_p = stack.pop().ok_or(result::Error::Misc("stack problem".into()))?;
                                let out_p = stack.pop().ok_or(result::Error::Misc("stack problem".into()))?;
                                {
                                    let in_c_n = name.clone();
                                    let (in_p_n, in_p_s) = if let CoreLexicalToken::Port(n, s) = in_p { (n, s) } else { unreachable!() };
                                    let (out_p_n, out_p_s) = if let CoreLexicalToken::Port(n, s) = out_p { (n, s) } else { unreachable!() };
                                    graph.ext_in.push(CoreGraphExtIn {
                                        port: out_p_n,
                                        in_port: in_p_n,
                                        in_elem: in_p_s,
                                        in_comp: in_c_n,
                                    });
                                }
                                stack.push(CoreLexicalToken::Comp(name, sort));
                                Compo
                            }
                            IMSGBindPort => {
                                let in_p = stack.pop().ok_or(result::Error::Misc("stack problem".into()))?;
                                let imsg = stack.pop().ok_or(result::Error::Misc("stack problem".into()))?;
                                {
                                    let in_c_n = name.clone();
                                    let (in_p_n, in_p_s) = if let CoreLexicalToken::Port(n, s) = in_p { (n, s) } else { unreachable!() };
                                    let imsg = if let CoreLexicalToken::IMsg(imsg) = imsg { imsg } else { unreachable!() };
                                    graph.imsgs.push(CoreGraphIMsg {
                                        msg: imsg,
                                        port: in_p_n,
                                        elem: in_p_s,
                                        comp: in_c_n,
                                    });
                                }
                                stack.push(CoreLexicalToken::Comp(name, sort));
                                Compo
                            }
                            Break => {
                                stack.push(CoreLexicalToken::Comp(name, sort));
                                Compo
                            },
                            ErrorS => { Compo },
                            _ => {
                                errors.push(format!("line {} : Found agent \"{}({})\", when \"{}\" was expected.", line, name, sort.unwrap_or("".into()), get_expected(&state)));
                                ErrorS
                            },
                        }
                    },
                    CoreLexicalToken::IMsg(imsg) => {
                        state = match state {
                            ErrorS => { stack.push(CoreLexicalToken::IMsg(imsg)); IMSG },
                            Break => { stack.push(CoreLexicalToken::IMsg(imsg)); IMSG },
                            _ => {
                                errors.push(format!("line {} : Found an IMSG \"{}\", when \"{}\" was expected.", line, imsg, get_expected(&state)));
                                ErrorS
                            },
                        };
                    },
                    CoreLexicalToken::Break => {
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
                    },
                    CoreLexicalToken::Comment => {
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
