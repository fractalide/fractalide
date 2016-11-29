#[macro_use]
extern crate rustfbp;
extern crate capnp;

component! {
    nucleus_flow_parser_graph_check, contracts(fbp_graph, fbp_semantic_error)
    inputs(input: fbp_graph),
    inputs_array(),
    outputs(output: fbp_graph, error: fbp_semantic_error),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let error;
        let mut ip = try!(self.ports.recv("input"));
        {
            let graph: fbp_graph::Reader = try!(ip.read_contract());

            let mut errors: Vec<String> = Vec::new();

            let mut nodes: HashMap<String, String> = HashMap::new();
            for n in try!(graph.borrow().get_nodes()).iter() {
                let name = try!(n.get_name());
                let sort = try!(n.get_sort());
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
            for n in try!(graph.borrow().get_edges()).iter() {
                if !nodes.contains_key(try!(n.get_o_name())) {
                    errors.push(format!("Uninstantiated node \"{0}()\"\n  Ensure you have included the type of the component in this manner: \"{0}(${{component_name}})\"", try!(n.get_o_name())));
                }
                if !nodes.contains_key(try!(n.get_i_name())) {
                    errors.push(format!("Uninstantiated node \"{0}()\"\n  Ensure you have included the type of the component in this manner: \"{0}(${{component_name}})\"", try!(n.get_i_name())));
                }
                let sender = if try!(n.get_o_selection()) == "" {
                    format!("{}() {}", try!(n.get_o_name()), try!(n.get_o_port()))
                } else {
                    format!("{}() {}[{}]", try!(n.get_o_name()), try!(n.get_o_port()), try!(n.get_o_selection()))
                };
                let receiver = if try!(n.get_i_selection()) == "" {
                    format!("{}() {}", try!(n.get_i_name()), try!(n.get_i_port()))
                } else {
                    format!("{}() {}[{}]", try!(n.get_i_name()), try!(n.get_i_port()), try!(n.get_i_selection()))
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
                        error = format!("{}Please use the ip_clone component\n", error);
                        errors.push(error);
                    }
                }
            }
            let mut inputs: HashMap<String, Vec<String>> = HashMap::new();
            for n in try!(graph.borrow().get_external_inputs()).iter() {
                let input = try!(n.get_name());
                let receiver = if try!(n.get_selection()) == "" {
                    format!("{}() {}", try!(n.get_comp()), try!(n.get_port()))
                } else {
                    format!("{}() {}[{}]", try!(n.get_comp()), try!(n.get_port()), try!(n.get_selection()))
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
                        error = format!("{}Please use the ip_clone component\n", error);
                        errors.push(error);
                    }
                }
            }


            if errors.len() > 0 {
                let mut new_ip = IP::new();
                {
                    let mut new_ip = new_ip.build_contract::<fbp_semantic_error::Builder>();
                    new_ip.set_path(try!(graph.get_path()));
                    {
                        let mut nodes = new_ip.init_parsing(errors.len() as u32);
                        let mut i = 0;
                        for n in &errors {
                            nodes.borrow().set(i, &n[..]);
                            i += 1;
                        }
                    }
                }
                let _ = self.ports.send("error", new_ip);
                error = true;
            } else { error = false }
        }

        if !error {
            let _ = self.ports.send("output", ip);
        }

        Ok(())
    }
}
