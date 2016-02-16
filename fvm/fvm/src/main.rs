extern crate fvm;

use std::env;

fn main() {
  fvm::run(&env::args().nth(1).unwrap_or(String::from("nix-replace-me")));
}
