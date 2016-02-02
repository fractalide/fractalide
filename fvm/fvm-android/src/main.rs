#[cfg(target_os = "android")]
#[macro_use]
extern crate android_glue;

#[cfg(target_os = "android")]
android_start!(main);

extern crate fvm;
use std::env;

fn main() {
  fvm::run(&env::args().nth(1).unwrap_or(String::from("/home/test.subnet")));
}
