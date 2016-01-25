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
    fn run(&mut self) {

        let mut sched = Scheduler::new();

        // retrieve the asked graph
        let mut ip = self.ports.recv("input".into()).expect("cannot receive");
        let i_graph = ip.get_reader().expect("fvm: cannot get reader");
        let i_graph: graph::Reader = i_graph.get_root().expect("fvm: not a graph");

        for n in i_graph.borrow().get_nodes().unwrap().iter() {
            sched.add_component_from_sort(n.get_name().unwrap(), n.get_sort().unwrap());
        }

        for e in i_graph.borrow().get_edges().unwrap().iter() {
            let o_name = e.get_o_name().unwrap().into();
            let o_port = e.get_o_port().unwrap().into();
            let o_selection: String = e.get_o_selection().unwrap().into();
            let i_port = e.get_i_port().unwrap().into();
            let i_selection: String = e.get_i_selection().unwrap().into();
            let i_name = e.get_i_name().unwrap().into();

            match (e.get_o_selection().unwrap(), e.get_i_selection().unwrap()) {
                ("", "") => {
                    sched.connect(o_name, o_port, i_name, i_port).expect("cannot connect");
                },
                (_, "") => {
                    sched.add_output_array_selection(o_name.clone(), o_port.clone(), o_selection.clone()).expect("cannot add");
                    sched.connect_array(o_name, o_port, o_selection, i_name, i_port).expect("cannot connect");
                },
                ("", _) => {
                    sched.soft_add_input_array_selection(i_name.clone(), i_port.clone(), i_selection.clone()).expect("cannot add");
                    sched.connect_to_array(o_name, o_port, i_name, i_port, i_selection).expect("cannot connect");
                },
                _ => {
                    sched.add_output_array_selection(o_name.clone(), o_port.clone(), o_selection.clone()).expect("cannot add");
                    sched.soft_add_input_array_selection(i_name.clone(), i_port.clone(), i_selection.clone()).expect("cannot add");
                    sched.connect_array_to_array(o_name, o_port, o_selection, i_name, i_port, i_selection).expect("cannot connect");
                }
            }
        }

        let senders = (sched.allocator.senders.create)();
        let mut p = Ports::new("exterior".into(), &sched.allocator, senders,
                               vec![],
                               vec![],
                               vec!["s".into()],
                               vec![]).expect("cannot create");
        let hs = HeapSenders::from_raw(senders);
        sched.inputs.insert("exterior".into(), hs);

        for iip in i_graph.borrow().get_iips().unwrap().iter() {

            let mut new_out = capnp::message::Builder::new_default();
            {
                let mut boolean = new_out.init_root::<boolean::Builder>();
                boolean.set_boolean(iip.get_iip().unwrap() == "true");
            }

            if iip.get_selection().unwrap() == "" {
                p.connect("s".into(), sched.get_sender(iip.get_comp().unwrap().into(), iip.get_port().unwrap().into()).unwrap()).expect("unable to connect");
            } else {
                p.connect("s".into(), sched.get_array_sender(iip.get_comp().unwrap().into(), iip.get_port().unwrap().into(), iip.get_selection().unwrap().into()).unwrap()).expect("unable to connect");
            }

            let mut ip = sched.allocator.ip.build_empty();
            ip.write_builder(&mut new_out);
            p.send("s".into(), ip).expect("unable to send to comp");
        }
        sched.join();
    }
}
