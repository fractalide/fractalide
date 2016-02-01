#![feature(alloc_system)]

extern crate alloc_system;

#[macro_use]
extern crate rustfbp;
extern crate capnp;

use self::rustfbp::scheduler::{Scheduler};
use self::rustfbp::ports::{IP, Ports};

use std::thread;
use std::env;
use std::path::Path;

mod contract_capnp {
    include!("path_capnp.rs");
}
use contract_capnp::path;

fn build_path(path: &'static str) -> Option<String> {
    let pstr = env::current_exe().unwrap();
    let parent_dir = Path::new(&pstr).parent();
    parent_dir.and_then(|s| s.to_str()).map(|s| {format!("{}/../bootstrap/{}", s, path)}).expect("not a file name")
}

#[no_mangle]
pub extern "C" fn run(path_fbp: &str) {

    let mut sched = Scheduler::new();
    sched.add_component("open", &build_path("file_open.so"));
    sched.add_component("lex", &build_path("development_fbp_parser_lexical.so"));
    sched.add_component("sem", &build_path("development_fbp_parser_semantic.so"));
    sched.add_component("fvm", &build_path("development_fbp_fvm.so"));
    sched.add_component("errors", &build_path("development_fbp_errors.so"));
    sched.add_component("graph_print", &build_path("development_fbp_parser_print_graph.so"));
    sched.add_component("sched", &build_path("development_fbp_scheduler.so"));
    sched.add_component("component_lookup", &build_path("component_lookup.so"));
    sched.add_component("contract_lookup", &build_path("contract_lookup.so"));


    let (mut p, senders) = Ports::new("exterior".into(), sched.sender.clone(),
                                      vec!["r".into()],
                                      vec![],
                                      vec!["s".into(), "opt".into()],
                                      vec![]).expect("cannot create");
    sched.inputs.insert("exterior".into(), senders);

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

    let mut ip = IP::new();
    ip.write_builder(&mut msg);
    p.send("s".into(), ip).expect("unable to send to comp");

    sched.join();
}
