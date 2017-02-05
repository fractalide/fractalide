#![feature(alloc_system)]

extern crate alloc_system;

#[macro_use]
extern crate rustfbp;
extern crate capnp;

use self::rustfbp::scheduler::{Scheduler, Comp};
use self::rustfbp::ports::{Msg};

use std::collections::HashMap;
use std::env;

fn main() {
    run(&env::args().nth(1).unwrap());
}

mod edge_capnp {
    include!("edge_capnp.rs");
}
use edge_capnp::core_action;

#[allow(unused_must_use)]
fn run(path_fbp: &str) {

    let mut sched = Scheduler::new();
    sched.add_node("open", "fs_file_open.so").expect("cannot add node");
    sched.add_node("lex", "core_parser_lexical.so").expect("cannot add node");
    sched.add_node("sem", "core_parser_semantic.so").expect("cannot add node");
    sched.add_node("vm", "core_vm.so").expect("cannot add node");
    sched.add_node("errors", "core_errors.so").expect("cannot add node");
    sched.add_node("graph_print", "core_parser_graph_print.so").expect("cannot add node");
    sched.add_node("graph_check", "core_parser_graph_check.so").expect("cannot add node");
    sched.add_node("sched", "core_scheduler.so").expect("cannot add node");
    sched.add_node("imsg", "core_capnp_encode.so").expect("cannot add node");
    sched.add_node("core_find_edge", "core_find_edge.so").expect("cannot add node");
    sched.add_node("core_find_node", "core_find_node.so").expect("cannot add node");

    // open(fs_file_open) output -> input lex(core_parser_lexical)
    // lex() output -> input sem(core_parser_semantic)
    // sem() output -> input graph_check(core_parser_graph_check)
    // graph_check() output -> input vm(core_vm)
    // graph_check() error -> semantic_error errors(core_errors)
    sched.connect("open", "output", "lex", "input").expect("cannot connect");
    sched.connect("lex", "output", "sem", "input").expect("cannot connect");
    sched.connect("sem", "output", "graph_check", "input").expect("cannot connect");
    sched.connect("graph_check", "output", "vm", "input").expect("cannot connect");
    sched.connect("graph_check", "error", "errors", "semantic_error").expect("cannot connect");

    // open() error -> file_error errors()
    // sem() error -> semantic_error errors()
    // errors() output -> input vm()
    sched.connect("open", "error", "errors", "file_error").expect("cannot connect");
    sched.connect("sem", "error", "errors", "semantic_error").expect("cannot connect");
    sched.connect("errors", "output", "vm", "input").expect("cannot connect");

    // reccursive part
    // vm() ask_graph -> input open()
    sched.connect("vm", "ask_graph", "open", "input").expect("cannot connect");

    // With Graph print
    // sched.connect("vm", "output", "graph_print", "input").expect("cannot connect");
    // sched.connect("graph_print", "output", "sched", "graph").expect("cannot connect");

    // Without Graph print
    // vm() output -> graph sched(core_scheduler)
    // sched() ask_path -> input core_find_edge(core_find_edge)
    // core_find_edge() output -> edge_path sched()
    // vm() ask_path -> input core_find_node()
    // core_find_node() output -> new_path vm()
    sched.connect("vm", "output", "sched", "graph").expect("cannot connect");
    sched.connect("sched", "ask_path", "core_find_edge", "input").expect("cannot connect");
    sched.connect("core_find_edge", "output", "sched", "edge_path").expect("cannot connect");
    sched.connect("vm", "ask_path", "core_find_node", "input").expect("cannot connect");
    sched.connect("core_find_node", "output", "vm", "new_path").expect("cannot connect");

    // IMsg part
    // sched() imsg_path -> path imsg()
    // sched() imsg_edge -> edge imsg()
    // sched() imsg_input -> input imsg()
    // imsg() output -> imsg sched()
    // imsg() ask_graph -> input vm()
    sched.connect("sched", "imsg_path", "imsg", "path").expect("cannot connect");
    sched.connect("sched", "imsg_edge", "imsg", "edge").expect("cannot connect");
    sched.connect("sched", "imsg_input", "imsg", "input").expect("cannot connect");
    sched.connect("imsg", "output", "sched", "imsg").expect("cannot connect");
    sched.connect("sched", "ask_graph", "vm", "input").expect("cannot connect ask_graph");

    let add = sched.get_sender("sched", "action").expect("action of sched not found");

    // Send the first Msg to the scheduler
    let mut start_msg = Msg::new();
    {
        let builder: core_action::Builder = start_msg.build_schema();
        let mut add = builder.init_add();
        add.set_name("main");
        add.set_comp(&path_fbp);
    }
    add.send(start_msg).expect("cannot send start_msg");

    // Send the halt msg
    let mut halt_msg = Msg::new();
    {
        let mut builder: core_action::Builder = halt_msg.build_schema();
        builder.set_halt(());
    }
    add.send(halt_msg).expect("cannot send halt_msg");

    // Wait for the end of the execution
    sched.join();
}
