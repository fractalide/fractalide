#[macro_use]
extern crate rustfbp;
extern crate capnp;

use self::rustfbp::scheduler::{Scheduler};
use self::rustfbp::loader::{ComponentBuilder};
use self::rustfbp::ports::Ports;

use self::rustfbp::allocator::{Allocator, HeapSenders, HeapIP, HeapIPReceiver};

use std::thread;


mod contracts {
    include!("/nix/store/c91f6cqyn5cbnik5fsnqdbc1azfddg4x-path/src/contract_capnp.rs");
}
use contracts::path;

pub fn main() {
    println!("Hello, fractalide!");


    let file = ComponentBuilder::new("/nix/store/0d4vasxj0xj57z2933f5aafckffvwdij-file-open/lib/libfile_open.so");
    let print = ComponentBuilder::new("/nix/store/mj3rp1la0gzd7lh03znb54y7v6pc8dzh-file-print/lib/libfile_print.so");

    let mut sched = Scheduler::new();
    sched.add_component("open".into(), &file);
    sched.add_component("print".into(), &print);

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

    let mut msg = capnp::message::Builder::new_default();
    {
        let mut number = msg.init_root::<path::Builder>();
        number.set_path("/home/denis/test.txt");
    }

    let mut ip = sched.allocator.ip.build_empty();
    ip.write_builder(&msg);

    p.send("s".into(), ip).expect("unable to send to comp");

    sched.join();

}
