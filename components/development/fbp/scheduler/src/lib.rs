#[macro_use]
extern crate rustfbp;
use rustfbp::scheduler::{Scheduler};
use rustfbp::loader::{ComponentBuilder};

extern crate capnp;

mod contract_capnp {
    include!("fbp_graph.rs");
    include!("maths_boolean.rs");
}
use contract_capnp::graph;
use contract_capnp::boolean;

component! {
    schedulder,
    inputs(input: graph),
    inputs_array(),
    outputs(error: error),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {

        let mut sched = Scheduler::new();

        // retrieve the asked graph
        let mut ip = try!(self.ports.recv("input".into()));
        let i_graph = try!(ip.get_reader());
        let i_graph: graph::Reader = try!(i_graph.get_root());

        for n in try!(i_graph.borrow().get_nodes()).iter() {
            sched.add_component_from_sort(try!(n.get_name()), try!(n.get_sort()));
        }

        for e in try!(i_graph.borrow().get_edges()).iter() {
            let o_name = try!(e.get_o_name()).into();
            let o_port = try!(e.get_o_port()).into();
            let o_selection: String = try!(e.get_o_selection()).into();
            let i_port = try!(e.get_i_port()).into();
            let i_selection: String = try!(e.get_i_selection()).into();
            let i_name = try!(e.get_i_name()).into();

            match (try!(e.get_o_selection()), try!(e.get_i_selection())) {
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
        }

        let senders = (sched.allocator.senders.create)();
        let mut p = try!(Ports::new("exterior".into(), &sched.allocator, senders,
                               vec![],
                               vec![],
                               vec!["s".into()],
                               vec![]));
        let hs = HeapSenders::from_raw(senders);
        sched.inputs.insert("exterior".into(), hs);

        for iip in try!(i_graph.borrow().get_iips()).iter() {

            let mut new_out = capnp::message::Builder::new_default();
            {
                let mut boolean = new_out.init_root::<boolean::Builder>();
                boolean.set_boolean(try!(iip.get_iip()) == "true");
            }

            if try!(iip.get_selection()) == "" {
                try!(p.connect("s".into(), try!(sched.get_sender(try!(iip.get_comp()).into(), try!(iip.get_port()).into()))));
            } else {
                try!(p.connect("s".into(), try!(sched.get_array_sender(try!(iip.get_comp()).into(), try!(iip.get_port()).into(), try!(iip.get_selection()).into()))));
            }

            let mut ip = sched.allocator.ip.build_empty();
            ip.write_builder(&mut new_out);
            try!(p.send("s".into(), ip));
        }
        sched.join();
        Ok(())
    }
}
