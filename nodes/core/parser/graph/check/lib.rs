#[macro_use]
extern crate rustfbp;
extern crate capnp;

agent! {
    input(input: core_graph),
    output(output: core_graph, error: core_semantic_error),
    fn run(&mut self) -> Result<Signal> {
        let error;
        let mut msg = try!(self.input.input.recv());
        {
            let graph: core_graph::Reader = try!(msg.read_schema());

            let mut errors: Vec<String> = Vec::new();

            let mut nodes: HashMap<String, String> = HashMap::new();
            for n in graph.borrow().get_nodes()?.get_list()?.iter() {
                let name = n.get_name()?;
                let sort = n.get_sort()?;
                let insert = match nodes.get(name) {
                    Some(v) => {
                        if v == "" { true }
                        else {
                            if sort != "" {
                                errors.push(format!("The node \"{}()\" has been declared more than once : {} and {}", name, v, sort));
                            }
                            false
                        }
                    }
                    None => { true }
                };
                if insert {
                    nodes.insert(name.into(), sort.into());
                }
            }

            let mut edges: HashMap<String, Vec<String>> = HashMap::new();
            for n in graph.borrow().get_edges()?.get_list()?.iter() {
                if !nodes.contains_key(n.get_o_name()?) {
                    errors.push(format!("Uninstantiated node \"{0}()\"\n  Ensure you have included the type of the agent in this manner: \"{0}(${{agent_name}})\"", n.get_o_name()?));
                }
                if !nodes.contains_key(n.get_i_name()?) {
                    errors.push(format!("Uninstantiated node \"{0}()\"\n  Ensure you have included the type of the agent in this manner: \"{0}(${{agent_name}})\"", n.get_i_name()?));
                }
                let sender = if n.get_o_selection()? == "" {
                    format!("{}() {}", n.get_o_name()?, n.get_o_port()?)
                } else {
                    format!("{}() {}[{}]", n.get_o_name()?, n.get_o_port()?, n.get_o_selection()?)
                };
                let receiver = if n.get_i_selection()? == "" {
                    format!("{}() {}", n.get_i_name()?, n.get_i_port()?)
                } else {
                    format!("{}() {}[{}]", n.get_i_name()?, n.get_i_port()?, n.get_i_selection()?)
                };
                {
                    let mut v = edges.entry(sender).or_insert(Vec::new());
                    v.push(receiver);
                }

                for (k, v) in &edges {
                    if v.len() > 1 {
                        let mut error: String = "There is a forbidden one-2-many simple port connection :\n".into();
                        for e in v {
                            error = format!("{}{} -> {}\n", error, k, e);
                        }
                        error = format!("{}Please use the msg_clone agent\n", error);
                        errors.push(error);
                    }
                }
            }
            let mut inputs: HashMap<String, Vec<String>> = HashMap::new();
            for n in graph.borrow().get_external_inputs()?.get_list()?.iter() {
                let input = n.get_name()?;
                let receiver = if n.get_selection()? == "" {
                    format!("{}() {}", n.get_comp()?, n.get_port()?)
                } else {
                    format!("{}() {}[{}]", n.get_comp()?, n.get_port()?, n.get_selection()?)
                };
                {
                    let mut v = inputs.entry(input.into()).or_insert(Vec::new());
                    v.push(receiver);
                }
                for (k, v) in &inputs {
                    if v.len() > 1 {
                        let mut error: String = "There is a forbidden one-2-many simple port connection :\n".into();
                        for e in v {
                            error = format!("{}{} => {}\n", error, k, e);
                        }
                        error = format!("{}Please use the msg_clone agent\n", error);
                        errors.push(error);
                    }
                }
            }


            if errors.len() > 0 {
                let mut new_msg = Msg::new();
                {
                    let mut new_msg = new_msg.build_schema::<core_semantic_error::Builder>();
                    new_msg.set_path(try!(graph.get_path()));
                    {
                        let mut nodes = new_msg.init_parsing(errors.len() as u32);
                        let mut i = 0;
                        for n in &errors {
                            nodes.borrow().set(i, &n[..]);
                            i += 1;
                        }
                    }
                }
                let _ = self.output.error.send(new_msg);
                error = true;
            } else { error = false }
        }

        if !error {
            let _ = self.output.output.send(msg);
        }

        Ok(End)
    }
}
