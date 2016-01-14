#[macro_use]
extern crate rustfbp;
extern crate capnp;

use self::rustfbp::scheduler::{Scheduler};
use self::rustfbp::loader::{ComponentBuilder};
use self::rustfbp::ports::Ports;

use self::rustfbp::allocator::{Allocator, HeapSenders, HeapIP, HeapIPReceiver};

use std::thread;
use std::env;



mod contracts {
    include!("/nix/store/df7r145xfifhvaxh3j52izpqmqqk4kby-path/src/contract_capnp.rs");
}
use contracts::path;

pub fn main() {
    println!("Hello, fractalide!");

    let config = env::var("FRACTALIDE_CONFIG").expect("cannot read FRACTALIDE_CONFIG");
    println!("location of config = {}", config);


    let file = ComponentBuilder::new("/nix/store/f5s69qwlf8jysgcwlrpj7g4wgih8l09l-file_open/lib/libcomponent.so");
    let print = ComponentBuilder::new("/nix/store/gy89qycq12r4j370q9cggj70yd5zhb3y-file_print/lib/libcomponent.so");
    let lex = ComponentBuilder::new("/nix/store/7m5rf0m88mxqshbf8rvgpakvhdm64s7f-development_parser_fbp_lexical/lib/libcomponent.so");
    let semantic = ComponentBuilder::new("/nix/store/a4y0fbx4asq1pnzg4w2miw31d90lgys2-development_parser_fbp_semantic/lib/libcomponent.so");
    let graph_print = ComponentBuilder::new("/nix/store/ln3pahm77pqfj85md1z7454qsnzmh37j-development_parser_fbp_print_graph/lib/libcomponent.so");

    let mut sched = Scheduler::new();
    sched.add_component("open".into(), &file);
    sched.add_component("print".into(), &print);
    sched.add_component("lex".into(), &lex);
    sched.add_component("sem".into(), &semantic);
    sched.add_component("graph_print".into(), &graph_print);

    let senders = (sched.allocator.senders.create)();
    let mut p = Ports::new("exterior".into(), &sched.allocator, senders,
                           vec!["r".into()],
                           vec![],
                           vec!["s".into()],
                           vec![]).expect("cannot create");
    let hs = HeapSenders::from_raw(senders);
    sched.inputs.insert("exterior".into(), hs);

    p.connect("s".into(), sched.get_sender("open".into(), "input".into()).unwrap()).expect("unable to connect");
    sched.connect("open".into(), "output".into(), "print".into(), "input".into()).expect("cannot connect");
    sched.connect("print".into(), "output".into(), "lex".into(), "input".into()).expect("cannot connect");
    sched.connect("lex".into(), "output".into(), "sem".into(), "input".into()).expect("cannot connect");
    sched.connect("sem".into(), "output".into(), "graph_print".into(), "input".into()).expect("cannot connect");

    let mut msg = capnp::message::Builder::new_default();
    {
        let mut number = msg.init_root::<path::Builder>();
        number.set_path("/home/denis/test.fbp");
    }

    let mut ip = sched.allocator.ip.build_empty();
    ip.write_builder(&mut msg);

    p.send("s".into(), ip).expect("unable to send to comp");

    sched.join();

}
