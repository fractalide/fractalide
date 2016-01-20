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
    include!("fbp_fvm_option.rs");
}
use contract_capnp::path;
use contract_capnp::option;

pub fn main() {
    println!("Hello, fractalide!");

    let file = ComponentBuilder::new("file_open.so");
    let print = ComponentBuilder::new("file_print.so");
    let lex = ComponentBuilder::new("development_parser_fbp_lexical.so");
    let semantic = ComponentBuilder::new("development_parser_fbp_semantic.so");
    let graph_print = ComponentBuilder::new("development_parser_fbp_print_graph.so");
    let fvm = ComponentBuilder::new("development_fvm.so");
    let lookup = ComponentBuilder::new("lookup.so");

    let mut sched = Scheduler::new();
    sched.add_component("open".into(), &file);
    sched.add_component("print".into(), &print);
    sched.add_component("lex".into(), &lex);
    sched.add_component("sem".into(), &semantic);
    sched.add_component("graph_print".into(), &graph_print);
    sched.add_component("fvm".into(), &fvm);
    sched.add_component("lookup".into(), &lookup);

    let senders = (sched.allocator.senders.create)();
    let mut p = Ports::new("exterior".into(), &sched.allocator, senders,
     vec!["r".into()],
     vec![],
     vec!["s".into(), "opt".into()],
     vec![]).expect("cannot create");
    let hs = HeapSenders::from_raw(senders);
    sched.inputs.insert("exterior".into(), hs);

    p.connect("s".into(), sched.get_sender("open".into(), "input".into()).unwrap()).expect("unable to connect");
    p.connect("opt".into(), sched.get_sender("fvm".into(), "option".into()).unwrap()).expect("unable to connect");
    sched.connect("open".into(), "output".into(), "print".into(), "input".into()).expect("cannot connect");
    sched.connect("print".into(), "output".into(), "lex".into(), "input".into()).expect("cannot connect");
    sched.connect("lex".into(), "output".into(), "sem".into(), "input".into()).expect("cannot connect");
    sched.connect("sem".into(), "output".into(), "graph_print".into(), "input".into()).expect("cannot connect");

    sched.connect("graph_print".into(), "output".into(), "fvm".into(), "input".into()).expect("cannot connect");
    // sched.connect("open".into(), "error".into(), "fvm".into(), "file_error".into());
    // sched.connect("sem".into(), "error".into(), "fvm".into(), "semantic_error".into());

    // reccursive part
    sched.connect("fvm".into(), "ask_graph".into(), "open".into(), "input".into());
    sched.connect("fvm".into(), "ask_path".into(), "lookup".into(), "input".into());
    sched.connect("lookup".into(), "output".into(), "fvm".into(), "new_path".into());

    let args: Vec<String> = env::args().collect();
    let mut msg = capnp::message::Builder::new_default();
    {
        let mut number = msg.init_root::<path::Builder>();
        number.set_path(&args[1][..]);
    }

    let mut ip = sched.allocator.ip.build_empty();
    ip.write_builder(&mut msg);
    p.send("s".into(), ip).expect("unable to send to comp");

    let mut msg = capnp::message::Builder::new_default();
    {
        let mut opt = msg.init_root::<option::Builder>();
        opt.set_component("rust-component-lookup.so");
        opt.set_subnet("rust-contract-lookup.so");
    }
    let mut ip = sched.allocator.ip.build_empty();
    ip.write_builder(&mut msg);
    p.send("opt".into(), ip).expect("unable to send opt");


    sched.join();

}
