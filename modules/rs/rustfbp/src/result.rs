extern crate capnp;

use std::fmt;

use std::error;
use std::result;
use std::io;
use std::string;
use std::sync::mpsc;

use scheduler::CompMsg;

pub type Result<T> = result::Result<T, Error>;

#[derive(Debug)]
pub enum Error {
    BadSchema(String, String, String, String, String, String),
    Capnp(capnp::Error),
    CapnpNIS(capnp::NotInSchema),
    IO(io::Error),
    FromUtf8(string::FromUtf8Error),
    Mpsc(mpsc::RecvError),
    MpscTryRecv(mpsc::TryRecvError),
    Misc(String),
    MpscSend,
    AgentNotFound(String),
    OutputPortNotConnected(String, String),
    OutputNotConnected,
    ArrayOutputPortNotConnected(String, String, String),
    PortNotFound(String, String),
    PortDontExist(String),
    ElementNotFound(String, String, String),
    CannotRemove(String),
    BadMessageInfo,
}

impl fmt::Display for Error {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match *self {
            Error::BadSchema(ref oc, ref op, ref os, ref ic, ref ip, ref is) => write!(f, "Cap'n Proto Schema mismatch between {}() {} -> {} {}(), found {} -> {}", oc, op, ip, ic, os, is),
            Error::Capnp(ref err) => write!(f, "Cap'n Proto error: {}", err),
            Error::CapnpNIS(ref err) => write!(f, "Cap'n Proto error: {}", err),
            Error::IO(ref err) => write!(f, "IO error : {}", err),
            Error::FromUtf8(ref err) => write!(f, "From Utf8 error : {}", err),
            Error::Mpsc(ref err) => write!(f, "Mpsc error : {}", err),
            Error::MpscTryRecv(ref err) => write!(f, "Mpsc error : {}", err),
            Error::Misc(ref err) => write!(f, "Misc error : {}", err),
            Error::MpscSend => write!(f, "Mpsc error : cannot send"),
            Error::OutputPortNotConnected(ref c, ref p) => write!(f, "OutputSender : Port {} of agent {} is not connected", p, c),
            Error::OutputNotConnected => write!(f, "OutputSender : Port not connected"),
            Error::ArrayOutputPortNotConnected(ref c, ref p, ref s) => write!(f, "OutputSender : Element {} Port {} of agent {} is not connected", s, p, c),
            Error::AgentNotFound(ref c) => write!(f, "Scheduler error : agent {} is not found", c),
            Error::PortNotFound(ref c, ref p) => write!(f, "agent error : Port {} of agent {} is not found", p, c),
            Error::PortDontExist(ref p) => write!(f, "agent error : Port {} doesn't exist", p),
            Error::ElementNotFound(ref c, ref p, ref s) => write!(f, "agent error : Element {} on port {} of agent {} is not found", s, p, c),
            Error::CannotRemove(ref c) => write!(f, "Scheduler error : Cannot remove agent {}", c),
            Error::BadMessageInfo => write!(f, "Ports error : Bad message information"),
        }
    }
}

impl error::Error for Error {
    fn description(&self) -> &str {
        match *self {
            Error::BadSchema(..) => "Bad schema",
            Error::Capnp(ref err) => err.description(),
            Error::CapnpNIS(ref err) => err.description(),
            Error::IO(ref err) => err.description(),
            Error::FromUtf8(ref err) => err.description(),
            Error::Mpsc(ref err) => err.description(),
            Error::MpscTryRecv(ref err) => err.description(),
            Error::Misc(ref err) => &err,
            Error::MpscSend => "Mpsc : cannot send",
            Error::OutputPortNotConnected(..) => "Output port not connected",
            Error::OutputNotConnected => "Output port not connected",
            Error::ArrayOutputPortNotConnected(..) => "Array Output port not connect",
            Error::AgentNotFound(..) => "Agent not found",
            Error::PortNotFound(..) => "Port not found",
            Error::PortDontExist(..) => "Port not found",
            Error::ElementNotFound(..) => "Element not found",
            Error::CannotRemove(..) => "Cannot remove agent",
            Error::BadMessageInfo => "Ports error : cannot receive the message, wrong bit information",
        }
    }

    fn cause(&self) -> Option<&error::Error> {
        match *self {
            Error::Capnp(ref err) => Some(err),
            Error::CapnpNIS(ref err) => Some(err),
            Error::IO(ref err) => Some(err),
            Error::FromUtf8(ref err) => Some(err),
            Error::Mpsc(ref err) => Some(err),
            Error::MpscTryRecv(ref err) => Some(err),
            _ => None
        }
    }
}

impl From<capnp::Error> for Error {
    fn from(err: capnp::Error) -> Error {
        Error::Capnp(err)
    }
}

impl From<capnp::NotInSchema> for Error {
    fn from(err: capnp::NotInSchema) -> Error {
        Error::CapnpNIS(err)
    }
}

impl From<String> for Error {
    fn from(err: String) -> Error {
        Error::Misc(err)
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

impl From<mpsc::RecvError> for Error {
    fn from(err: mpsc::RecvError) -> Error {
        Error::Mpsc(err)
    }
}

impl From<mpsc::TryRecvError> for Error {
    fn from(err: mpsc::TryRecvError) -> Error {
        Error::MpscTryRecv(err)
    }
}

impl From<mpsc::SendError<CompMsg>> for Error {
    fn from(_: mpsc::SendError<CompMsg>) -> Error {
        Error::MpscSend
    }
}

impl<T> From<mpsc::SendError<(Option<String>, T)>> for Error {
    fn from(_: mpsc::SendError<(Option<String>, T)>) -> Error {
        Error::MpscSend
    }
}
