#[macro_use]
extern crate clap;
use clap::{App, Arg};

fn main() {
    let matches = App::new("fractalide")
    .author("Stewart Mackenzie <setori88@gmail.com>")
    .version(&crate_version!()[..])
    .about("Server of Fractalide Flow-based Programming components.")
    .arg(Arg::with_name("host")
        .index(1)
        .required(true)
        .help("host to listen on: <host>:<port> i.e. \"localhost:8000\""))
    .arg(Arg::with_name("log")
        .index(2)
        .required(true)
        .help("location of logfile, typically \"/var/fractalide/fractal.log\""))
    .arg(Arg::with_name("debug")
        .short("d")
        .help("Turn on debugging."))
    .arg(Arg::with_name("verbosity")
        .short("v")
        .multiple(true)
        .help("Output verbosity level."))
    .get_matches();

    match matches.occurrences_of("verbosity") {
        0 => (),
        1 => println!("Critical debug info on"),
        2 => println!("General debug info on"),
        3 | _ => println!("Print everything..."),
    }
    if matches.is_present("debug") {
        println!("Print something.")
    }
    if let Some(port) = matches.value_of("host"){
        println!("Using host: {}", port);
    }
    if let Some(log) = matches.value_of("log"){
        println!("Using logfile: {}", log);
    }
}
