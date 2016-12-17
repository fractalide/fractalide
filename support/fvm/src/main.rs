
#![feature(alloc_system)]

extern crate alloc_system;

#[macro_use]
extern crate rustfbp;
extern crate capnp;

use self::rustfbp::scheduler::{Scheduler, Comp};
use self::rustfbp::ports::{IP};

use std::collections::HashMap;
use std::env;

fn main() {
    run(&env::args().nth(1).unwrap());
}

mod edge_capnp {
    include!("path_capnp.rs");
    include!("fbp_action.rs");
}
use edge_capnp::fbp_action;

#[allow(unused_must_use)]
fn run(path_fbp: &str) {

    let mut sched = Scheduler::new();
    sched.add_node("open", "fs_file_open.so").expect("cannot add node");
    sched.add_node("lex", "nucleus_flow_parser_lexical.so").expect("cannot add node");
    sched.add_node("sem", "nucleus_flow_parser_semantic.so").expect("cannot add node");
    sched.add_node("vm", "nucleus_flow_vm.so").expect("cannot add node");
    sched.add_node("errors", "nucleus_flow_errors.so").expect("cannot add node");
    sched.add_node("graph_print", "nucleus_flow_parser_graph_print.so").expect("cannot add node");
    sched.add_node("graph_check", "nucleus_flow_parser_graph_check.so").expect("cannot add node");
    sched.add_node("sched", "nucleus_flow_scheduler.so").expect("cannot add node");
    sched.add_node("iip", "nucleus_capnp_encode.so").expect("cannot add node");
    sched.add_node("nucleus_find_edge", "nucleus_find_edge.so").expect("cannot add node");
    sched.add_node("nucleus_find_node", "nucleus_find_node.so").expect("cannot add node");
    sched.add_node("halter", "halter.so").expect("cannot add node");

    // Send the start ip for the graph
    let h = sched.get_sender("halter".into(), "input".into()).expect("halter not found");
    let start_ip = IP::new();
    h.send(start_ip).expect("start");

    sched.connect("open".into(), "output".into(), "lex".into(), "input".into()).expect("cannot connect");
    sched.connect("lex".into(), "output".into(), "sem".into(), "input".into()).expect("cannot connect");
    sched.connect("sem".into(), "output".into(), "graph_check".into(), "input".into()).expect("cannot connect");
    sched.connect("graph_check".into(), "output".into(), "vm".into(), "input".into()).expect("cannot connect");
    sched.connect("graph_check".into(), "error".into(), "errors".into(), "semantic_error".into()).expect("cannot connect");

    sched.connect("open".into(), "error".into(), "errors".into(), "file_error".into()).expect("cannot connect");
    sched.connect("sem".into(), "error".into(), "errors".into(), "semantic_error".into()).expect("cannot connect");
    sched.connect("errors".into(), "output".into(), "vm".into(), "input".into()).expect("cannot connect");

    // reccursive part
    sched.connect("vm".into(), "ask_graph".into(), "open".into(), "input".into()).expect("cannot connect");

    // With Graph print
    // sched.connect("vm".into(), "output".into(), "graph_print".into(), "input".into()).expect("cannot connect");
    // sched.connect("graph_print".into(), "output".into(), "sched".into(), "graph".into()).expect("cannot connect");

    // Without Graph print
    sched.connect("vm".into(), "output".into(), "sched".into(), "graph".into()).expect("cannot connect");

    sched.connect("sched".into(), "ask_path".into(), "nucleus_find_edge".into(), "input".into()).expect("cannot connect");
    sched.connect("nucleus_find_edge".into(), "output".into(), "sched".into(), "edge_path".into()).expect("cannot connect");

    sched.connect("vm".into(), "ask_path".into(), "nucleus_find_node".into(), "input".into()).expect("cannot connect");
    sched.connect("nucleus_find_node".into(), "output".into(), "vm".into(), "new_path".into()).expect("cannot connect");

    // IIP part
    sched.connect("sched".into(), "iip_path".into(), "iip".into(), "path".into()).expect("cannot connect");
    sched.connect("sched".into(), "iip_edge".into(), "iip".into(), "edge".into()).expect("cannot connect");
    sched.connect("sched".into(), "iip_input".into(), "iip".into(), "input".into()).expect("cannot connect");
    sched.connect("iip".into(), "output".into(), "sched".into(), "iip".into()).expect("cannot connect");

    sched.connect("sched".into(), "ask_graph".into(), "vm".into(), "input".into()).expect("cannot connect ask_graph");

    let add = sched.get_sender("sched".into(), "action".into()).expect("action of sched not found");

    // Send the first IP to the scheduler
    let mut start_ip = IP::new();
    {
        let builder: fbp_action::Builder = start_ip.build_schema();
        let mut add = builder.init_add();
        add.set_name("main");
        add.set_comp(&path_fbp);
    }
    add.send(start_ip).expect("cannot send start_ip");
    sched.join();
}
