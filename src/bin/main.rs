#[macro_use]
extern crate rustfbp;
extern crate capnp;

use self::rustfbp::scheduler::{Scheduler};
use self::rustfbp::loader::{ComponentBuilder};
use self::rustfbp::ports::{OutputPort};
// use self::rustfbp::subnet::*;

use std::thread;


mod date_capnp {
    include!("./schema/date_capnp.rs");
}
use date_capnp::date;

pub fn main() {
    println!("Hello, fractalide!");

    let mut sched = Scheduler::new("test".into());

    let inc = ComponentBuilder::new("./libinc_date.so");
    let display = ComponentBuilder::new("./libdisplay_date.so");

    sched.add_component("inc".into(), &inc);
    sched.add_component("disp".into(), &display);
    sched.add_component("disp2".into(), &display);

    sched.connect("disp".into(), "output".into(), "inc".into(), "a".into());
    sched.connect("inc".into(), "output".into(), "disp2".into(), "a".into());


    let mut s = OutputPort::new().expect("cannot create sender");
    s.connect("test".into(), "disp".into(), "a".into()).expect("unable to connect");

    let mut msg = capnp::message::Builder::new_default();
    {
        let mut date = msg.init_root::<date::Builder>();
        date.set_year(1989);
        date.set_month(6);
        date.set_day(8);
    }

    thread::sleep_ms(1);
    s.send(&msg).expect("unable to send to comp");

    sched.start_receive();
    sched.join();

}
