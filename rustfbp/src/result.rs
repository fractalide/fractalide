extern crate capnp;

use std::fmt;

use std::error;
use std::result;
use std::io;
use std::string;
use std::sync::mpsc;

use ports::IP;
use scheduler::CompMsg;

pub type Result<T> = result::Result<T, Error>;

#[derive(Debug)]
pub enum Error {
    Capnp(capnp::Error),
    CapnpNIS(capnp::NotInSchema),
    IO(io::Error),
    FromUtf8(string::FromUtf8Error),
    Mpsc(mpsc::RecvError),
    MpscTryRecv(mpsc::TryRecvError),
    Misc(String),
    MpscSend,
    OutputPortNotConnected,
    ComponentNotFound,
    PortNotFound,
    SelectionNotFound,
    CannotSendToScheduler,
    CannotReceive,
    CannotSend,
    CannotWrite,
    CannotRead,
    CannotRemove,
    BadMessageInfo,
}

impl fmt::Display for Error {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match *self {
            Error::Capnp(ref err) => write!(f, "Cap'n Proto error: {}", err),
            Error::CapnpNIS(ref err) => write!(f, "Cap'n Proto error: {}", err),
            Error::IO(ref err) => write!(f, "IO error : {}", err),
            Error::FromUtf8(ref err) => write!(f, "From Utf8 error : {}", err),
            Error::Mpsc(ref err) => write!(f, "Mpsc error : {}", err),
            Error::MpscTryRecv(ref err) => write!(f, "Mpsc error : {}", err),
            Error::Misc(ref err) => write!(f, "Misc error : {}", err),
            Error::MpscSend => write!(f, "Mpsc error : cannot send"),
            Error::OutputPortNotConnected => write!(f, "OutputSender : Port not connected"),
            Error::ComponentNotFound => write!(f, "Scheduler error : Component not found"),
            Error::PortNotFound => write!(f, "Component error : Port not found"),
            Error::SelectionNotFound => write!(f, "Component error : Selection not found"),
            Error::CannotSendToScheduler => write!(f, "Scheduler error : Cannot send to scheduler state"),
            Error::CannotRemove => write!(f, "Scheduler error : Cannot remove the component"),
            Error::CannotReceive => write!(f, "Ports error: cannot receive"),
            Error::CannotSend => write!(f, "Ports error: cannot send"),
            Error::CannotWrite => write!(f, "IP error: cannot write"),
            Error::CannotRead => write!(f, "IP error: cannot Read"),
            Error::BadMessageInfo => write!(f, "Ports error : Bad message information"),
        }
    }
}

impl error::Error for Error {
    fn description(&self) -> &str {
        match *self {
            Error::Capnp(ref err) => err.description(),
            Error::CapnpNIS(ref err) => err.description(),
            Error::IO(ref err) => err.description(),
            Error::FromUtf8(ref err) => err.description(),
            Error::Mpsc(ref err) => err.description(),
            Error::MpscTryRecv(ref err) => err.description(),
            Error::Misc(ref err) => &err,
            Error::MpscSend => "Mpsc : cannot send",
            Error::OutputPortNotConnected => "The Output port is not connected",
            Error::ComponentNotFound => "A Component is not found in a scheduler",
            Error::PortNotFound => "A port is not found in a component",
            Error::SelectionNotFound => "A selection in a array port is not found in a component",
            Error::CannotSendToScheduler => "Scheduler error : Cannot send to scheduler state",
            Error::CannotRemove => "Scheduler error : Cannot remove the component",
            Error::CannotReceive => "Ports error: cannot receive",
            Error::CannotSend => "Ports error: cannot send",
            Error::CannotWrite => "IP error: cannot write",
            Error::CannotRead => "IP error: cannot read",
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

impl From<mpsc::SendError<IP>> for Error {
    fn from(_: mpsc::SendError<IP>) -> Error {
        Error::MpscSend
    }
}
