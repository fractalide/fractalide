use std::sync::mpsc::{Sender, Receiver, SyncSender};
use std::sync::mpsc::sync_channel;
use result;
use result::Result;
use std::marker::PhantomData;
use scheduler::CompMsg;

pub struct MsgSender<Msg> {
    pub sender: SyncSender<(Option<String>, Msg)>,
    pub dest: usize,
    pub sched: Sender<CompMsg<Msg>>,
    must_sched: bool,
}

impl<Msg> MsgSender<Msg> {
    pub fn send<T:Into<Msg>>(&self, mut msg: T) -> Result<()> {
        self.sender.send((None, msg.into()))?;
        if self.must_sched {
            self.sched.send(CompMsg::Inc(self.dest))?;
        }
        Ok(())
    }

    pub fn send_with_action<T:Into<Msg>>(&self, mut msg: T, action: String) -> Result<()> {
        self.sender.send((Some(action), msg.into()))?;
        if self.must_sched {
            self.sched.send(CompMsg::Inc(self.dest))?;
        }
        Ok(())
    }
}

#[derive(Clone)]
pub struct MsgSenderInto<Msg, I> {
    s: MsgSender<Msg>,
    i: PhantomData<I>
}

impl<Msg, I: Into<Msg>> MsgSenderInto<Msg, I> {
    pub fn send(&self, msg: I) -> Result<()> {
        self.s.send(msg.into())
    }
}

impl<Msg> Clone for MsgSender<Msg> {
    fn clone(&self) -> Self {
        MsgSender::<Msg> {
            sender: self.sender.clone(),
            dest: self.dest,
            sched: self.sched.clone(),
            must_sched: self.must_sched,
        }
    }
}

pub trait OutputSend<Msg> {
    fn send<T:Into<Msg>>(&self, msg:T) -> Result<()>;
}

impl<Msg> OutputSend<Msg> for Option<MsgSender<Msg>> {
    fn send<T:Into<Msg>>(&self, msg: T) -> Result<()> {
        if let &Some(ref sender) = self {
            sender.send(msg.into())?;
            Ok(())
        } else {
            Err(result::Error::OutputNotConnected)
        }
    }
}


pub struct MsgReceiver<Msg> {
    id: usize,
    recv: Receiver<(Option<String>, Msg)>,
    sender: MsgSender<Msg>,
    sched: Sender<CompMsg<Msg>>,
    must_sched: bool,
}

impl<Msg> MsgReceiver<Msg> {
    pub fn new(id: usize, sched: Sender<CompMsg<Msg>>, must_sched: bool) -> (MsgReceiver<Msg>, MsgSender<Msg>) {
        let (s, r) = sync_channel(25);
        let s = MsgSender::<Msg> {
            sender: s,
            dest: id,
            must_sched: must_sched,
            sched: sched.clone(),
        };
        let r = MsgReceiver::<Msg> {
            recv: r,
            sender: s.clone(),
            id: id,
            sched: sched,
            must_sched: must_sched,
        };
        (r, s)
    }

    pub fn recv<T:From<Msg>>(&self) -> Result<T> {
        let msg = self.recv.recv()?;
        if self.must_sched {
            self.sched.send(CompMsg::Dec(self.id))?;
        }
        Ok(msg.1.into())
    }

    pub fn recv_with_action<T:From<Msg>>(&self) -> Result<(Option<String>, T)> {
        let msg = self.recv.recv()?;
        if self.must_sched {
            self.sched.send(CompMsg::Dec(self.id))?;
        }
        Ok((msg.0, msg.1.into()))
    }

    pub fn try_recv<T:From<Msg>>(&self) -> Result<T> {
        let msg = self.recv.try_recv()?;
        if self.must_sched {
            self.sched.send(CompMsg::Dec(self.id))?;
        }
        Ok(msg.1.into())
    }

    pub fn try_recv_with_action<T:From<Msg>>(&self) -> Result<(Option<String>, T)> {
        let msg = self.recv.try_recv()?;
        if self.must_sched {
            self.sched.send(CompMsg::Dec(self.id))?;
        }
        Ok((msg.0, msg.1.into()))
    }

    pub fn get_sender(&self) -> MsgSender<Msg> {
        self.sender.clone()
    }
}

pub struct MsgReceiverFrom<Msg, I: From<Msg>> {
    pub r: MsgReceiver<Msg>,
    pub i: PhantomData<I>
}

impl<Msg, I: From<Msg>> MsgReceiverFrom<Msg, I> {

    pub fn new(id: usize, sched: Sender<CompMsg<Msg>>, must_sched: bool) -> (MsgReceiverFrom<Msg, I>, MsgSenderInto<Msg, I>) {
        let (r, s) = MsgReceiver::new(id, sched, must_sched);
        (MsgReceiverFrom { r, i: PhantomData },
         MsgSenderInto { s, i: PhantomData })
    }

    pub fn recv(&self) -> Result<I> {
        self.r.recv()
    }

    pub fn recv_with_action(&self) -> Result<(Option<String>, I)> {
        self.r.recv_with_action()
    }

    pub fn try_recv(&self) -> Result<I> {
        self.r.try_recv()
    }

    pub fn try_recv_with_action<T:From<Msg>>(&self) -> Result<(Option<String>, T)> {
        self.r.try_recv_with_action()
    }

    pub fn get_sender(&self) -> MsgSenderInto<Msg, I> {
        MsgSenderInto {
            s: self.r.sender.clone(),
            i: PhantomData
        }
    }
}
