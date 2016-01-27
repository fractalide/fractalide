extern crate libloading;

use std::path::Path;
use std::env::{ args };
use libloading::{ Library, Symbol };

fn main() {
  let slave = Library::new(
    Path::new("./libfvm.so")
    ).expect("load the library error.");

  let foo: Symbol<extern fn(&str) > = unsafe {
    slave.get(b"run\0").expect("not found run function.")
  };

  foo(&args().nth(1).unwrap_or(String::from("/home/test.subnet")));
}
