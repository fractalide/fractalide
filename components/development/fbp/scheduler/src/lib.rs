#[macro_use]
extern crate rustfbp;
use rustfbp::scheduler::{Comp, Scheduler};
use std::mem;
use std::str;

extern crate capnp;

#[derive(Debug)]
pub struct Subnet {
    nodes: Vec<String>,
    ext_in: HashMap<String, (String, String)>,
    ext_out: HashMap<String, (String, String)>,
}
impl Subnet {
    pub fn new() -> Subnet {
        Subnet {
            nodes: vec![],
            ext_in: HashMap::new(),
            ext_out: HashMap::new(),
        }
    }
}

pub struct Portal {
    sched: Scheduler,
    subnet: HashMap<String, Subnet>,
}

impl Portal {
    fn new() -> Portal {
        Portal {
            sched: Scheduler::new(),
            subnet: HashMap::new(),
        }
    }
}

component! {
    development_fbp_scheduler, contracts(fbp_graph, path, generic_text, fbp_action)
        inputs(action: fbp_action,
               graph: fbp_graph,
               contract_path: path,
               iip: any),
    inputs_array(),
    outputs(error: error,
            ask_graph: path,
            ask_path: path,
            iip_path: path,
            iip_contract: generic_text,
            iip_input: generic_text),
    outputs_array(outputs: any),
    option(),
    acc(), portal(Portal => Portal::new())
    fn run(&mut self) -> Result<()> {

        let mut ip = try!(self.ports.recv("action"));
        let mut reader: fbp_action::Reader = try!(ip.get_root());

        match try!(reader.which()) {
            fbp_action::Which::Add(add) => {
                let mut add = try!(add);
                let name = try!(add.get_name());
                let mut ask_ip = IP::new();
                {
                    let mut builder: fbp_graph::Builder = ask_ip.init_root();
                    builder.set_path(try!(add.get_comp()));
                    {
                        let mut nodes = builder.borrow().init_nodes(1);
                        nodes.borrow().get(0).set_name(try!(add.get_name()));
                        nodes.borrow().get(0).set_sort(try!(add.get_comp()));
                    }
                }
                try!(self.ports.send("ask_graph", ask_ip));
                try!(add_graph(self, name));
            },
            fbp_action::Which::Remove(remove) => {
                let name = try!(remove);
                if let Some(subnet) = self.portal.subnet.remove(name) {
                    for node in subnet.nodes {
                        try!(self.portal.sched.remove_component(node));
                    }
                } else {
                    try!(self.portal.sched.remove_component(name.into()));
                }
            },
            fbp_action::Which::Connect(connect) => {
                let connect = try!(connect);
                let mut o_name: String = try!(connect.get_o_name()).into();
                let mut o_port: String = try!(connect.get_o_port()).into();
                let o_selection: String = try!(connect.get_o_selection()).into();
                if let Some(subnet) = self.portal.subnet.get(&o_name) {
                    if let Some(port) = subnet.ext_out.get(&o_port) {
                        o_name = port.0.clone();
                        o_port = port.1.clone();
                    }
                }
                let mut i_name: String = try!(connect.get_i_name()).into();
                let mut i_port: String = try!(connect.get_i_port()).into();
                let i_selection: String = try!(connect.get_i_selection()).into();
                if let Some(subnet) = self.portal.subnet.get(&i_name) {
                    if let Some(port) = subnet.ext_in.get(&i_port) {
                        i_name = port.0.clone();
                        i_port = port.1.clone();
                    }
                }
                try!(connect_ports(&mut self.portal.sched,
                        o_name, o_port, o_selection,
                        i_name, i_port, i_selection));
            },
            // TODO : add selection (array port management)
            fbp_action::Which::ConnectSender(connect) => {
                let connect = try!(connect);
                let mut name: String = try!(connect.get_name()).into();
                let mut port: String = try!(connect.get_port()).into();
                let selection: String = try!(connect.get_selection()).into();
                if let Some(subnet) = self.portal.subnet.get(&name) {
                    if let Some(p) = subnet.ext_out.get(&port) {
                        name = p.0.clone();
                        port = p.1.clone();
                    }
                }
                let sender = try!(self.ports.get_array_sender("outputs", try!(connect.get_output())));
                try!(self.portal.sched.sender.send(CompMsg::ConnectOutputPort(name, port, sender)));
            },
            fbp_action::Which::Send(send) => {
                let send = try!(send);
                let mut comp = try!(send.get_comp());
                let mut port = try!(send.get_port());
                let selection = try!(send.get_selection());
                if let Some(subnet) = self.portal.subnet.get(comp) {
                    if let Some(subnet_port) = subnet.ext_in.get(port) {
                        comp = &subnet_port.0;
                        port = &subnet_port.1;
                    }
                }
                let ip = try!(self.ports.recv("action"));
                let sender = if selection == "" {
                    try!(self.portal.sched.get_sender(comp, port))
                } else {
                    try!(self.portal.sched.get_array_sender(comp, port, selection))
                };
                try!(sender.send(ip));
            },
        }
        Ok(())
    }
}

fn add_graph(mut component: &mut development_fbp_scheduler, name: &str) -> Result<()> {
    let mut ip = try!(component.ports.recv("graph"));
    let i_graph: fbp_graph::Reader = try!(ip.get_root());

    let mut subnet = Subnet::new();
    for n in try!(i_graph.borrow().get_nodes()).iter() {
        subnet.nodes.push(try!(n.get_name()).into());
        component.portal.sched.add_component(try!(n.get_name()), try!(n.get_sort()));
    }

    for e in try!(i_graph.borrow().get_edges()).iter() {
        let o_name = try!(e.get_o_name()).into();
        let o_port = try!(e.get_o_port()).into();
        let o_selection: String = try!(e.get_o_selection()).into();
        let i_port = try!(e.get_i_port()).into();
        let i_selection: String = try!(e.get_i_selection()).into();
        let i_name = try!(e.get_i_name()).into();

        try!(connect_ports(&mut component.portal.sched,
                o_name, o_port, o_selection,
                i_name, i_port, i_selection));
    }

    for ext in try!(i_graph.borrow().get_external_inputs()).iter() {
        let name = try!(ext.get_name());
        let comp = try!(ext.get_comp());
        let port = try!(ext.get_port());
        subnet.ext_in.insert(name.into(), (comp.into(), port.into()));
    }
    for ext in try!(i_graph.borrow().get_external_outputs()).iter() {
        let name = try!(ext.get_name());
        let comp = try!(ext.get_comp());
        let port = try!(ext.get_port());
        subnet.ext_out.insert(name.into(), (comp.into(), port.into()));
    }

    let (mut p, senders) = try!(Ports::new("exterior".into(), component.portal.sched.sender.clone(),
                                           vec![],
                                           vec![],
                                           vec!["s".into()],
                                           vec![]));
    component.portal.sched.components.insert("exterior".into(), Comp{
        inputs: senders,
        inputs_array: HashMap::new(),
        sort: "".into(),
        start: false,
    });

    for iip in try!(i_graph.borrow().get_iips()).iter() {

        let comp = try!(iip.get_comp());
        let port = try!(iip.get_port());
        let input = try!(iip.get_iip());

        let (contract, input, option_action) = try!(split_input(input));

        // Get the real path
        let mut new_out = IP::new();
        {
            let mut cont = new_out.init_root::<path::Builder>();
            cont.set_path(&contract);
        }
        try!(component.ports.send("ask_path", new_out));

        let mut contract_path_ip = try!(component.ports.recv("contract_path"));
        let contract_path: path::Reader = try!(contract_path_ip.get_root());

        let c_path = try!(contract_path.get_path());
        let c_path = format!("{}/src/contract.capnp", c_path);

        let mut contract_list: Vec<&str>;
        if contract.contains('-') {
            contract_list = contract.split('-').collect();
        } else {
            contract_list = Vec::new();
            contract_list.push(contract.as_str());
        }
        let c_name = match contract_list.last() {
            Some(c) => { c },
            None => {"failed_to_find_contract"},
        };

        let contract_camel_case = to_camel_case(&c_name);

        if try!(iip.get_selection()) == "" {
            try!(p.connect("s".into(), try!(component.portal.sched.get_sender(try!(iip.get_comp()).into(), try!(iip.get_port()).into()))));
        } else {
            try!(p.connect("s".into(), try!(component.portal.sched.get_array_sender(try!(iip.get_comp()).into(), try!(iip.get_port()).into(), try!(iip.get_selection()).into()))));
        }

        let mut new_out = IP::new();
        {
            let mut path = new_out.init_root::<path::Builder>();
            path.set_path(&c_path);
        }
        try!(component.ports.send("iip_path", new_out));

        let mut new_out = IP::new();
        {
            let mut path = new_out.init_root::<generic_text::Builder>();
            path.set_text(&contract_camel_case);
        }
        try!(component.ports.send("iip_contract", new_out));

        let mut new_out = IP::new();
        {
            let mut path = new_out.init_root::<generic_text::Builder>();
            path.set_text(&input);
        }
        try!(component.ports.send("iip_input", new_out));

        let mut iip = try!(component.ports.recv("iip"));
        option_action.map(|action| { iip.action = action; });
        try!(p.send("s", iip));
    }

    // Start all components without input port
    for n in &subnet.nodes {
        try!(component.portal.sched.start_if_needed(n));
    }

    // Remember the subnet
    component.portal.subnet.insert(name.into(), subnet);

    Ok(())
}

fn to_camel_case(s: &str) -> String {
    let mut result = "".to_string();
    for word in s.split("_") {
        result = format!("{}{}", result, capitalize_first_letter(word));
    }
    result
}

fn capitalize_first_letter(s : &str) -> String {
    use std::ascii::*;
    let mut result_chars : Vec<char> = Vec::new();
    for c in s.chars() { result_chars.push(c) }
    result_chars[0] = (result_chars[0] as u8).to_ascii_uppercase() as char;
    return result_chars.into_iter().collect();
}

fn split_input(s: &str) -> Result<(String, String, Option<String>)> {
    let pos = try!(s.find(":").ok_or(result::Error::Misc("bad definition of iip".into())));
    let (a, b) = s.split_at(pos);
    let (_, b) = b.split_at(1);
    let pos2 = b.find("~");
    if let Some(pos) = pos2 {
        let (b, c) = b.split_at(pos);
        let (_, c) = c.split_at(1);
        return Ok((a.into(), b.into(), Some(c.into())));
    };
    Ok((a.into(), b.into(), None))
}

fn connect_ports(sched: &mut Scheduler, o_name: String, o_port: String, o_selection: String,
           i_name: String, i_port: String, i_selection: String) -> Result<()> {
    match (&o_selection[..], &i_selection[..]) {
        ("", "") => {
            try!(sched.connect(o_name, o_port, i_name, i_port));
        },
        (_, "") => {
            try!(sched.add_output_array_selection(o_name.clone(), o_port.clone(), o_selection.clone()));
            try!(sched.connect_array(o_name, o_port, o_selection, i_name, i_port));
        },
        ("", _) => {
            try!(sched.soft_add_input_array_selection(i_name.clone(), i_port.clone(), i_selection.clone()));
            try!(sched.connect_to_array(o_name, o_port, i_name, i_port, i_selection));
        },
        _ => {
            try!(sched.add_output_array_selection(o_name.clone(), o_port.clone(), o_selection.clone()));
            try!(sched.soft_add_input_array_selection(i_name.clone(), i_port.clone(), i_selection.clone()));
            try!(sched.connect_array_to_array(o_name, o_port, o_selection, i_name, i_port, i_selection));
        }
    }
    Ok(())
}
