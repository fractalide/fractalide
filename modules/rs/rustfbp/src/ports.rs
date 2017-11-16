use std::sync::mpsc::{Sender, Receiver, SyncSender};
use std::sync::mpsc::sync_channel;
use result;
use result::Result;

use scheduler::CompMsg;

pub struct MsgSender<T> {
    pub sender: SyncSender<(Option<String>, T)>,
    pub dest: usize,
    pub sched: Sender<CompMsg>,
    must_sched: bool,
}

impl<T> MsgSender<T> {
    pub fn send(&self, mut msg: T) -> Result<()> {
        self.sender.send((None, msg))?;
        if self.must_sched {
            self.sched.send(CompMsg::Inc(self.dest))?;
        }
        Ok(())
    }

    pub fn send_with_action(&self, mut msg: T, action: String) -> Result<()> {
        self.sender.send((Some(action), msg))?;
        if self.must_sched {
            self.sched.send(CompMsg::Inc(self.dest))?;
        }
        Ok(())
    }
}

impl<T> Clone for MsgSender<T> {
    fn clone(&self) -> Self {
        MsgSender::<T> {
            sender: self.sender.clone(),
            dest: self.dest,
            sched: self.sched.clone(),
            must_sched: self.must_sched,
        }
    }
}

pub trait OutputSend<T> {
    fn send(&self, msg:T) -> Result<()>;
}

impl<T> OutputSend<T> for Option<MsgSender<T>> {
    fn send(&self, msg: T) -> Result<()> {
        if let &Some(ref sender) = self {
            sender.send(msg)?;
            Ok(())
        } else {
            Err(result::Error::OutputNotConnected)
        }
    }
}


pub struct MsgReceiver<T> {
    id: usize,
    recv: Receiver<(Option<String>, T)>,
    sender: MsgSender<T>,
    sched: Sender<CompMsg>,
    must_sched: bool,
}

impl<T> MsgReceiver<T> {
    pub fn new(id: usize, sched: Sender<CompMsg>, must_sched: bool) -> (MsgReceiver<T>, MsgSender<T>) {
        let (s, r) = sync_channel(25);
        let s = MsgSender::<T> {
            sender: s,
            dest: id,
            must_sched: must_sched,
            sched: sched.clone(),
        };
        let r = MsgReceiver::<T> {
            recv: r,
            sender: s.clone(),
            id: id,
            sched: sched,
            must_sched: must_sched,
        };
        (r, s)
    }

    pub fn recv(&self) -> Result<T> {
        let msg = self.recv.recv()?;
        if self.must_sched {
            self.sched.send(CompMsg::Dec(self.id))?;
        }
        Ok(msg.1)
    }

    pub fn recv_with_action(&self) -> Result<(Option<String>, T)> {
        let msg = self.recv.recv()?;
        if self.must_sched {
            self.sched.send(CompMsg::Dec(self.id))?;
        }
        Ok(msg)
    }

    pub fn try_recv(&self) -> Result<T> {
        let msg = self.recv.try_recv()?;
        if self.must_sched {
            self.sched.send(CompMsg::Dec(self.id))?;
        }
        Ok(msg.1)
    }

    pub fn try_recv_with_action(&self) -> Result<(Option<String>, T)> {
        let msg = self.recv.try_recv()?;
        if self.must_sched {
            self.sched.send(CompMsg::Dec(self.id))?;
        }
        Ok(msg)
    }

    pub fn get_sender(&self) -> MsgSender<T> {
        self.sender.clone()
    }
}
