#![feature(raw)]
#![feature(reflect_marker)]
#![feature(concat_idents)]

extern crate nanomsg;
extern crate libloading;

pub mod component;

/// manages the execution of a FBP graph.
///
/// It had two main parts : the "exterior scheduler" and the "interior scheduler".
///
/// The exterior scheduler is an API to easily manage the scheduler.
///
/// The interior scheduler is the actual state of the scheduler. It is edited by sending messages. 
/// The messages are send by the exterior scheduler and the components of the Graph.
pub mod scheduler;
pub mod subnet;

pub mod loader;
pub mod ports;
pub mod result;
