extern crate nanomsg;
extern crate capnp;

use std::fmt;

use std::error;
use std::result;
use std::io;
use std::string;

pub type Result<T> = result::Result<T, Error>;

#[derive(Debug)]
pub enum Error {
    Nano(nanomsg::Error),
    Capnp(capnp::Error),
    IO(io::Error),
    FromUtf8(string::FromUtf8Error),
    OutputPortNotConnected,
    NanomsgCannotShutdown,
    ComponentNotFound,
    PortNotFound,
    SelectionNotFound,
    CannotSendToScheduler,
    BadMessageInfo,
}

impl fmt::Display for Error {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match *self {
            Error::Nano(ref err) => write!(f, "Nanomsg error: {}", err),
            Error::Capnp(ref err) => write!(f, "Cap'n Proto error: {}", err),
            Error::IO(ref err) => write!(f, "IO error : {}", err),
            Error::FromUtf8(ref err) => write!(f, "From Utf8 error : {}", err),
            Error::NanomsgCannotShutdown => write!(f, "Nanomsg error : cannot shutdown"),
            Error::OutputPortNotConnected => write!(f, "OutputSender : Port not connected"),
            Error::ComponentNotFound => write!(f, "Scheduler error : Component not found"),
            Error::PortNotFound => write!(f, "Component error : Port not found"),
            Error::SelectionNotFound => write!(f, "Component error : Selection not found"),
            Error::CannotSendToScheduler => write!(f, "Scheduler error : Cannot send to scheduler state"),
            Error::BadMessageInfo => write!(f, "Ports error : Bad message information"),
        }
    }
}

impl error::Error for Error {
    fn description(&self) -> &str {
        match *self {
            Error::Nano(ref err) => err.description(),
            Error::Capnp(ref err) => err.description(),
            Error::IO(ref err) => err.description(),
            Error::FromUtf8(ref err) => err.description(),
            Error::OutputPortNotConnected => "The Output port is not connected",
            Error::NanomsgCannotShutdown => "Nanomsg cannot shutdown a socket",
            Error::ComponentNotFound => "A Component is not found in a scheduler",
            Error::PortNotFound => "A port is not found in a component",
            Error::SelectionNotFound => "A selection in a array port is not found in a component",
            Error::CannotSendToScheduler => "Scheduler error : Cannot send to scheduler state",
            Error::BadMessageInfo => "Ports error : cannot receive the message, wrong bit information",
        }
    }

    fn cause(&self) -> Option<&error::Error> {
        match *self {
            Error::Nano(ref err) => Some(err),
            Error::Capnp(ref err) => Some(err),
            Error::IO(ref err) => Some(err),
            Error::FromUtf8(ref err) => Some(err),
            _ => None
        }
    }
}

impl From<nanomsg::Error> for Error {
    fn from(err: nanomsg::Error) -> Error {
        Error::Nano(err)
    }
}

impl From<capnp::Error> for Error {
    fn from(err: capnp::Error) -> Error {
        Error::Capnp(err)
    }
}

impl From<io::Error> for Error {
    fn from(err: io::Error) -> Error {
        Error::IO(err)
    }
}

impl From<string::FromUtf8Error> for Error {
    fn from(err: string::FromUtf8Error) -> Error {
        Error::FromUtf8(err)
    }
}
