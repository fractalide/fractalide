extern crate vm;

use std::env;

fn main() {
  vm::run(&env::args().nth(1).unwrap_or(String::from("nix-replace-me")));
}
