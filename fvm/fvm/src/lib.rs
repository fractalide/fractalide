#![feature(alloc_system)]

extern crate alloc_system;

#[macro_use]
extern crate rustfbp;
extern crate capnp;

use self::rustfbp::scheduler::{Scheduler, Comp};
use self::rustfbp::ports::{IP, Ports};

use std::thread;
use std::env;
use std::path::Path;

use std::collections::HashMap;

mod contract_capnp {
    include!("path_capnp.rs");
    include!("fbp_action.rs");
}
use contract_capnp::path;
use contract_capnp::fbp_action;

#[no_mangle]
pub extern "C" fn run(path_fbp: &str) {

    let mut sched = Scheduler::new();
    sched.add_component("open", "fs_file_open.so");
    sched.add_component("lex", "development_fbp_parser_lexical.so");
    sched.add_component("sem", "development_fbp_parser_semantic.so");
    sched.add_component("fvm", "development_fbp_fvm.so");
    sched.add_component("errors", "development_fbp_errors.so");
    sched.add_component("graph_print", "development_fbp_parser_print_graph.so");
    sched.add_component("sched", "development_fbp_scheduler.so");
    sched.add_component("iip", "development_capnp_encode.so");
    sched.add_component("contract_lookup", "contract_lookup.so");
    sched.add_component("halter", "halter.so");

    let (mut p, senders) = Ports::new("exterior".into(), sched.sender.clone(),
                                      vec!["r".into()],
                                      vec![],
                                      vec!["s".into(), "opt".into(), "w".into(),
                                           "h".into(), "add".into()],
                                      vec![]).expect("cannot create");
    sched.components.insert("exterior".into(), Comp {
        inputs: senders,
        inputs_array: HashMap::new(),
        sort: "".into(),
    });

    // Send the start ip for the graph
    p.connect("h".into(), sched.get_sender("halter".into(), "input".into()).unwrap()).expect("unable to connect");
    let start_ip = IP::new();
    p.send("h".into(), start_ip).expect("start");

    p.connect("s".into(), sched.get_sender("open".into(), "input".into()).unwrap()).expect("unable to connect");
    sched.connect("open".into(), "output".into(), "lex".into(), "input".into()).expect("cannot connect");
    sched.connect("lex".into(), "output".into(), "sem".into(), "input".into()).expect("cannot connect");
    sched.connect("sem".into(), "output".into(), "fvm".into(), "input".into()).expect("cannot connect");

    sched.connect("open".into(), "error".into(), "errors".into(), "file_error".into()).expect("cannot connect");
    sched.connect("sem".into(), "error".into(), "errors".into(), "semantic_error".into()).expect("cannot connect");
    sched.connect("errors".into(), "output".into(), "fvm".into(), "input".into()).expect("cannot connect");

    // reccursive part
    sched.connect("fvm".into(), "ask_graph".into(), "open".into(), "input".into()).expect("cannot connect");

    // With Graph print
    // sched.connect("fvm".into(), "output".into(), "graph_print".into(), "input".into()).expect("cannot connect");
    // sched.connect("graph_print".into(), "output".into(), "sched".into(), "input".into()).expect("cannot connect");

    // Without Graph print
    sched.connect("fvm".into(), "output".into(), "sched".into(), "graph".into()).expect("cannot connect");

    sched.connect("sched".into(), "ask_path".into(), "contract_lookup".into(), "input".into()).expect("cannot connect");
    sched.connect("contract_lookup".into(), "output".into(), "sched".into(), "contract_path".into()).expect("cannot connect");

    // IIP part
    sched.connect("sched".into(), "iip_path".into(), "iip".into(), "path".into()).expect("cannot connect");
    sched.connect("sched".into(), "iip_contract".into(), "iip".into(), "contract".into()).expect("cannot connect");
    sched.connect("sched".into(), "iip_input".into(), "iip".into(), "input".into()).expect("cannot connect");
    sched.connect("iip".into(), "output".into(), "sched".into(), "iip".into()).expect("cannot connect");

    sched.connect("sched".into(), "ask_graph".into(), "fvm".into(), "input".into()).expect("cannot connect ask_graph");

    // Send the first IP to the scheduler
    p.connect("add".into(), sched.get_sender("sched".into(), "action".into()).unwrap()).expect("unable to connect");
    let mut start_ip = IP::new();
    {
        let mut builder: fbp_action::Builder = start_ip.init_root();
        let mut add = builder.init_add();
        add.set_name("hello");
        add.set_comp(&path_fbp);
    }
    p.send("add".into(), start_ip).expect("add");

    sched.join();
}
