#[macro_use]
extern crate rustfbp;
extern crate capnp;

use self::rustfbp::scheduler::{Scheduler};
use self::rustfbp::loader::{ComponentBuilder};
use self::rustfbp::ports::Ports;

use self::rustfbp::allocator::{Allocator, HeapSenders, HeapIP, HeapIPReceiver};

use std::thread;
use std::env;

mod contract_capnp {
    include!("path_capnp.rs");
}
use contract_capnp::path;

#[no_mangle]
pub extern "C" fn run(path_fbp: &str) {
    println!("Hello, fractalide!");

    let file = ComponentBuilder::new("file_open.so");
    let print = ComponentBuilder::new("file_print.so");
    let lex = ComponentBuilder::new("development_fbp_parser_lexical.so");
    let semantic = ComponentBuilder::new("development_fbp_parser_semantic.so");
    let graph_print = ComponentBuilder::new("development_fbp_parser_print_graph.so");
    let fvm = ComponentBuilder::new("development_fbp_fvm.so");
    let errors = ComponentBuilder::new("development_fbp_errors.so");
    let sched_comp = ComponentBuilder::new("development_fbp_scheduler.so");
    let component_lookup = ComponentBuilder::new("component_lookup.so");
    let contract_lookup = ComponentBuilder::new("contract_lookup.so");


    let mut sched = Scheduler::new();
    sched.add_component("open".into(), &file);
    sched.add_component("lex".into(), &lex);
    sched.add_component("sem".into(), &semantic);
    sched.add_component("fvm".into(), &fvm);
    sched.add_component("errors".into(), &errors);
    sched.add_component("graph_print".into(), &graph_print);
    sched.add_component("sched".into(), &sched_comp);
    sched.add_component("component_lookup".into(), &component_lookup);
    sched.add_component("contract_lookup".into(), &contract_lookup);


    let senders = (sched.allocator.senders.create)();
    let mut p = Ports::new("exterior".into(), &sched.allocator, senders,
       vec!["r".into()],
       vec![],
       vec!["s".into(), "opt".into()],
       vec![]).expect("cannot create");
    let hs = HeapSenders::from_raw(senders);
    sched.inputs.insert("exterior".into(), hs);

    p.connect("s".into(), sched.get_sender("open".into(), "input".into()).unwrap()).expect("unable to connect");
    sched.connect("open".into(), "output".into(), "lex".into(), "input".into()).expect("cannot connect");
    sched.connect("lex".into(), "output".into(), "sem".into(), "input".into()).expect("cannot connect");
    sched.connect("sem".into(), "output".into(), "fvm".into(), "input".into()).expect("cannot connect");

    sched.connect("open".into(), "error".into(), "errors".into(), "file_error".into());
    sched.connect("sem".into(), "error".into(), "errors".into(), "semantic_error".into());
    sched.connect("errors".into(), "output".into(), "fvm".into(), "input".into());

    // reccursive part
    sched.connect("fvm".into(), "ask_graph".into(), "open".into(), "input".into());
    sched.connect("fvm".into(), "ask_path".into(), "component_lookup".into(), "input".into());
    sched.connect("component_lookup".into(), "output".into(), "fvm".into(), "new_path".into());

    sched.connect("fvm".into(), "output".into(), "graph_print".into(), "input".into());
    sched.connect("graph_print".into(), "output".into(), "sched".into(), "input".into());

    let args: Vec<String> = env::args().collect();
    let mut msg = capnp::message::Builder::new_default();
    {
        let mut number = msg.init_root::<path::Builder>();
        number.set_path(&path_fbp);
    }

    let mut ip = sched.allocator.ip.build_empty();
    ip.write_builder(&mut msg);
    p.send("s".into(), ip).expect("unable to send to comp");

    sched.join();
}
