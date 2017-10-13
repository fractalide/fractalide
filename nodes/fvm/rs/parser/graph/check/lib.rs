#[macro_use]
extern crate rustfbp;
extern crate capnp;

agent! {
    input(input: CoreGraph),
    output(output: CoreGraph, error: CoreSemanticError),
    fn run(&mut self) -> Result<Signal> {
        let error;
        let graph = self.input.input.recv()?;

        let mut errors: Vec<String> = Vec::new();

        {
        let mut nodes = HashMap::new();
            for n in &graph.nodes {
                let name = &n.name;
                let sort = &n.sort;
                let insert = match nodes.get(name) {
                    Some(v) => {
                        if v as &str == "" { true }
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
                    nodes.insert(name, sort);
                }
            }


            let mut edges = HashMap::new();
            for n in &graph.edges {
                if !nodes.contains_key(&n.out_comp) {
                    errors.push(format!("Uninstantiated node \"{0}()\"\n  Ensure you have included the type of the agent in this manner: \"{0}(${{agent_name}})\"", n.out_comp));
                }
                if !nodes.contains_key(&n.in_comp) {
                    errors.push(format!("Uninstantiated node \"{0}()\"\n  Ensure you have included the type of the agent in this manner: \"{0}(${{agent_name}})\"", n.in_comp));
                }

                let sender = if let Some(ref select) = n.out_elem {
                    format!("{}() {}[{}]", n.out_comp, n.out_port, select)
                } else {
                    format!("{}() {}", n.out_comp, n.out_port)
                };

                let receiver = if let Some(ref select) = n.in_elem {
                    format!("{}() {}[{}]", n.in_comp, n.in_port, select)
                } else {
                    format!("{}() {}", n.in_comp, n.in_port)
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

            let mut inputs = HashMap::new();
            for n in &graph.ext_in {
                let input = &n.port;
                let receiver = if let Some(ref select) = n.in_elem {
                    format!("{}() {}[{}]", n.in_comp, n.in_port, select)
                } else {
                    format!("{}() {}", n.in_comp, n.in_port)
                };
                {
                    let mut v = inputs.entry(input).or_insert(Vec::new());
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
                let _ = self.output.error.send(
                    CoreSemanticError { path: "".into(),
                                        parsing: errors });
                error = true;
            } else { error = false }
        }

        if !error {
            let _ = self.output.output.send(graph);
        }

        Ok(End)
    }
}
