use capnp;
use capnp::message::{Builder, Reader, ReaderOptions};
use capnp::serialize::{OwnedSegments};
use std::mem;
use std::mem::transmute;
use std::sync::mpsc::channel;
use std::sync::mpsc::{Sender, Receiver};
use std::collections::HashMap;
use std::io::{Write};
use std::io;

use result;
use result::Result;

use scheduler::CompMsg;

/*
 *  Memory object
 */

/*
    HeapIP
*/
#[repr(C)]
pub struct HeapIP {
    pub ip: Vec<u8>,
    pub last_write: usize,
}

extern "C" fn create_ip() -> *mut HeapIP {
    let ip = Box::new(HeapIP { ip: vec![], last_write: 0, });
    let ip: *mut HeapIP = unsafe { transmute(ip) };
    ip
}

extern "C" fn create_ptr() -> *mut HeapIP {
    0 as *mut HeapIP
}

extern "C" fn write_msg(ip: *mut HeapIP, buf: &[u8]) -> i8 {
    unsafe {
        match (*ip).ip.write(buf) {
            Ok(num) => {
                (*ip).last_write = num;
                0
            },
            Err(_) => { -1 }
        }
    }
}

extern "C" fn get_last_write(ip: *mut HeapIP) -> usize {
    unsafe {
        (*ip).last_write
    }
}

extern "C" fn clone_ip(ip: *mut HeapIP) -> *mut HeapIP {
    unsafe {
        let ip = Box::new(HeapIP {
            ip: (*ip).ip.clone(),
            last_write: 0, });
        let ip: *mut HeapIP = unsafe { transmute(ip) };
        ip
    }
}

extern "C" fn flush(ip: *mut HeapIP) -> i8 {
    unsafe {
        match (*ip).ip.flush() {
            Ok(_) => 0,
            Err(_) => -1,
        }
    }
}

extern "C" fn borrow_ip(ip: *mut HeapIP) -> *const Vec<u8> {
    unsafe {
        & (*ip).ip as *const Vec<u8>
    }
}

extern "C" fn clear_ip(ip: *mut HeapIP) {
    unsafe {
        (*ip).ip.clear();
    }
}

extern "C" fn drop_ip(ip: *mut HeapIP) {
    let _ip: Box<HeapIP> = unsafe { transmute(ip) };
    // println!("Drop the HeapIP");
}

/*
    IPSender
*/
#[repr(C)]
pub struct HeapIPSender {
    pub sender: Sender<*mut HeapIP>,
    pub sched: Sender<CompMsg>,
    pub dest: String,
}

impl HeapIPSender {
    pub fn from_raw(ptr: *const HeapIPSender) -> Box<HeapIPSender> {
        unsafe { transmute(ptr) }
    }

    pub fn to_raw(self: Box<Self>) -> *const HeapIPSender {
        let s: *const HeapIPSender = unsafe { transmute(self) };
        s
    }
}

impl Clone for HeapIPSender {
    fn clone(&self) -> Self {
        HeapIPSender {
            sender: self.sender.clone(),
            sched: self.sched.clone(),
            dest: self.dest.clone(),
        }
    }
}

pub extern "C" fn send_ip(sender: *const HeapIPSender, msg: *mut HeapIP) -> i8 {
    unsafe {
        match (*sender).sender.send(msg) {
            Ok(()) => {
                match (*sender).sched.send(CompMsg::Inc((*sender).dest.clone())) {
                    Ok(()) => 0,
                    Err(_) => -1,
                }
            },
            Err(_) => -1,
        }
    }
}

extern "C" fn drop_sender(sender: *const HeapIPSender) {
    let _ip: Box<HeapIPSender> = unsafe { transmute(sender) };
    // println!("Drop the Sender");
}

/*
HeapSenders
 */
#[repr(C)]
pub struct HeapSenders{
    pub senders: HashMap<String, *const HeapIPSender>,
}

impl HeapSenders {
    pub fn from_raw(hs: *mut HeapSenders) -> Box<HeapSenders> {
        unsafe { transmute(hs) }
    }

    pub fn get_sender(&self, name: &str) -> Result<Box<HeapIPSender>> {
        self.senders.get(name).ok_or(result::Error::PortNotFound)
            .and_then(|n| {
                let sender: HeapIPSender = unsafe {(**n).clone()};
                let sender: Box<HeapIPSender> = Box::new(sender);
                Ok(sender)
            })
    }
}

impl Drop for HeapSenders {
    fn drop(&mut self) {
        for &s in self.senders.values() {
            let _s: Box<HeapIPSender> = unsafe { transmute(s) };
            // println!("Drop unused HeapIPSender");
        }
    }
}

extern "C" fn create_senders() -> *mut HeapSenders {
    let senders = Box::new(HeapSenders { senders: HashMap::new(), });
    let senders: *mut HeapSenders = unsafe { transmute(senders) };
    senders
}

pub extern fn add_ptr(sender: *mut HeapSenders, name: &String, msg: *const HeapIPSender) {
    unsafe {
        (*sender).senders.insert(name.clone(), msg);
    }
}

extern "C" fn drop_senders(sender: *mut HeapSenders) {
    let _sched: Box<HeapSenders> = unsafe { transmute(sender) };
}

/*
    IPReceiver
*/
#[repr(C)]
pub struct HeapIPReceiver {
    pub receiver: Receiver<*mut HeapIP>,
    pub sched: Sender<CompMsg>,
    pub dest: String,
}

impl HeapIPReceiver {
    pub fn to_raw(self: Box<Self>) -> *const HeapIPReceiver {
        let s: *const HeapIPReceiver = unsafe { transmute(self) };
        s
    }

    pub fn from_raw(hs: *const HeapIPReceiver) -> Box<HeapIPReceiver> {
        unsafe { transmute(hs) }
    }
}

extern "C" fn recv_ip(receiver: *const HeapIPReceiver) -> *mut HeapIP {
    unsafe {
        match (*receiver).receiver.recv() {
            Ok(ip) => {
                match (*receiver).sched.send(CompMsg::Dec((*receiver).dest.clone())){
                    Ok(()) => { ip },
                    Err(_) => { 0 as *mut HeapIP },
                }
            },
            Err(_) => { 0 as *mut HeapIP },
        }
    }
}

extern "C" fn try_recv_ip(receiver: *const HeapIPReceiver) -> *mut HeapIP {
    unsafe {
        match (*receiver).receiver.try_recv() {
            Ok(ip) => {
                match (*receiver).sched.send(CompMsg::Dec((*receiver).dest.clone())){
                    Ok(()) => { ip },
                    Err(_) => { 0 as *mut HeapIP },
                }
            },
            Err(_) => { 0 as *mut HeapIP },
        }
    }
}

extern "C" fn drop_receiver(receiver: *const HeapIPReceiver) {
    let _ip: Box<HeapIPReceiver> = unsafe { transmute(receiver) };
    // println!("Drop the receiver");
}

#[repr(C)]
pub struct HeapChannel {
    pub sender: *const HeapIPSender,
    pub receiver: *const HeapIPReceiver,
}

extern "C" fn create_channel(name: &String, sched: &Sender<CompMsg>) -> *mut HeapChannel {
    let (s, r): (Sender<*mut HeapIP>, Receiver<*mut HeapIP>) = channel();
    let s = Box::new(HeapIPSender {
        sender: s,
        sched: sched.clone(),
        dest: name.clone(),
    });
    let r = Box::new(HeapIPReceiver {
        receiver: r,
        sched: sched.clone(),
        dest: name.clone(),
    });
    let s: *const HeapIPSender = unsafe { transmute(s) };
    let r: *const HeapIPReceiver = unsafe { transmute(r) };

    let channel = HeapChannel {
        sender: s,
        receiver: r,
    };
    unsafe { transmute(Box::new(channel))}
}

extern "C" fn get_receiver(ptr: *mut HeapChannel) -> *const HeapIPReceiver {
    unsafe {
        (*ptr).receiver
    }
}

extern "C" fn get_sender(ptr: *mut HeapChannel) -> *const HeapIPSender {
    unsafe {
        (*ptr).sender
    }
}

/*
 *  FFI
 */

#[derive(Clone)]
pub struct Allocator {
    pub ip: IPBuilder,
    pub channel: ChannelBuilder,
    pub senders: SendersBuilder,
}

impl Allocator {
    pub fn new(sched: Sender<CompMsg>) -> Self {
        Allocator {
            ip: IPBuilder::new(),
            channel: ChannelBuilder::new(sched),
            senders: SendersBuilder::new(),
        }
    }
}

pub struct SendersBuilder {
    pub create: extern fn() -> *mut HeapSenders,
    add_ptr: extern fn(*mut HeapSenders, &String, *const HeapIPSender),
    pub drop: extern fn(*mut HeapSenders),
}
impl SendersBuilder {
    pub fn new() -> Self {
        SendersBuilder {
            create: create_senders,
            add_ptr: add_ptr,
            drop: drop_senders,
        }
    }

    pub fn build(&self, ptr: *mut HeapSenders) -> Senders {
        Senders {
            senders: ptr,
            add_ptr: self.add_ptr,
            drop: self.drop,
        }
    }
}

impl Clone for SendersBuilder {
    fn clone(&self) -> Self {
        SendersBuilder {
            create: self.create,
            add_ptr: self.add_ptr,
            drop: self.drop,
        }
    }
}

pub struct IPBuilder {
    create: extern fn() -> *mut HeapIP,
    create_ptr: extern fn() -> *mut HeapIP,
    write_msg: extern fn(*mut HeapIP, &[u8]) -> i8,
    get_last_write: extern fn(*mut HeapIP) -> usize,
    flush: extern fn(*mut HeapIP) -> i8,
    borrow: extern fn(*mut HeapIP) -> *const Vec<u8>,
    clear: extern fn(*mut HeapIP),
    drop: extern fn(*mut HeapIP),
    clone: extern fn(*mut HeapIP) -> *mut HeapIP,
}

impl IPBuilder {
    pub fn new() -> Self {
        IPBuilder {
            create: create_ip,
            create_ptr: create_ptr,
            write_msg: write_msg,
            get_last_write: get_last_write,
            flush: flush,
            borrow: borrow_ip,
            clear: clear_ip,
            drop: drop_ip,
            clone: clone_ip,
        }
    }

    pub fn build_unitialized(&self) -> *mut HeapIP {
        (self.create_ptr)()
    }

    pub fn build_empty(&self) -> IP {
        let ptr = (self.create)();
        IP {
            ptr: ptr,
            must_drop: true,
            write_msg: self.write_msg,
            get_last_write: self.get_last_write,
            flush: self.flush,
            borrow: self.borrow,
            clear: self.clear,
            drop: self.drop,
            clone: self.clone,
        }
    }

    pub fn build(&self, ptr: *mut HeapIP) -> IP {
        IP {
            ptr: ptr,
            must_drop: true,
            write_msg: self.write_msg,
            get_last_write: self.get_last_write,
            flush: self.flush,
            borrow: self.borrow,
            clear: self.clear,
            drop: self.drop,
            clone: self.clone,
        }
    }
}

impl Clone for IPBuilder {
    fn clone(&self) -> Self {
        IPBuilder {
            create: self.create,
            create_ptr: self.create_ptr,
            write_msg: self.write_msg,
            get_last_write: self.get_last_write,
            flush: self.flush,
            borrow: self.borrow,
            clear: self.clear,
            drop: self.drop,
            clone: self.clone,
        }
    }
}

pub struct ChannelBuilder {
    sched: Sender<CompMsg>,
    create: extern fn(name: &String, sched: &Sender<CompMsg>) -> *mut HeapChannel,
    get_r: extern fn(*mut HeapChannel) -> *const HeapIPReceiver,
    get_s: extern fn(*mut HeapChannel) -> *const HeapIPSender,
    send: extern fn(*const HeapIPSender, *mut HeapIP) -> i8,
    recv: extern fn(*const HeapIPReceiver) -> *mut HeapIP,
    try_recv: extern fn(*const HeapIPReceiver) -> *mut HeapIP,
    drop_send: extern fn(*const HeapIPSender),
    drop_recv: extern fn(*const HeapIPReceiver),
}

impl ChannelBuilder {
    pub fn new(sched: Sender<CompMsg>) -> Self {
        ChannelBuilder {
            sched: sched,
            create: create_channel,
            get_r: get_receiver,
            get_s: get_sender,
            send: send_ip,
            recv: recv_ip,
            try_recv: try_recv_ip,
            drop_send: drop_sender,
            drop_recv: drop_receiver,
        }
    }

    pub fn build_raw(&self, name: &String) -> *mut HeapChannel {
        (self.create)(name, &self.sched)
    }

    pub fn build(&self, name: &String) -> (*const HeapIPSender, *const HeapIPReceiver) {
        let chan = (self.create)(name, &self.sched);
        let s = (self.get_s)(chan);
        let r = (self.get_r)(chan);
        (s, r)
    }

    pub fn build_sender(&self, sender: *const HeapIPSender) -> IPSender {
        IPSender {
            sender: Some(sender),
            send: self.send,
            drop: self.drop_send,
        }
    }

    pub fn build_receiver(&self, receiver: *const HeapIPReceiver) -> IPReceiver {
        IPReceiver {
            receiver: receiver,
            recv: self.recv,
            try_recv: self.try_recv,
            drop: self.drop_recv,
        }
    }

    pub fn get_sender(&self, chan: *mut HeapChannel) -> *const HeapIPSender {
        (self.get_s)(chan)
    }

    pub fn get_receiver(&self, chan: *mut HeapChannel) -> *const HeapIPReceiver {
        (self.get_r)(chan)
    }
}

impl Clone for ChannelBuilder {
    fn clone(&self) -> Self {
        ChannelBuilder {
            sched: self.sched.clone(),
            create: self.create,
            get_r: self.get_r,
            get_s: self.get_s,
            send: self.send,
            recv: self.recv,
            try_recv: self.try_recv,
            drop_send: self.drop_send,
            drop_recv: self.drop_recv,
        }
    }
}

pub struct IP {
    pub ptr: *mut HeapIP,
    pub must_drop: bool,
    write_msg: extern fn(*mut HeapIP, &[u8]) -> i8,
    get_last_write: extern fn(*mut HeapIP) -> usize,
    flush: extern fn(*mut HeapIP) -> i8,
    borrow: extern fn(*mut HeapIP) -> *const Vec<u8>,
    clear: extern fn(*mut HeapIP),
    drop: extern fn(*mut HeapIP),
    clone: extern fn(*mut HeapIP) -> *mut HeapIP,
}

impl IP {
    pub fn get_reader(&mut self) -> Result<Reader<OwnedSegments>> {
        let msg = self.clone_value();
        Ok(try!(capnp::serialize::read_message(&mut &msg[..], ReaderOptions::new())))
    }

    pub fn write_builder<A>(&mut self, builder: &capnp::message::Builder<A>) -> Result<()>
        where A: capnp::message::Allocator {
            (self.clear)(self.ptr);
            let mut s = self;
            Ok(try!(capnp::serialize::write_message(&mut s, builder)))
    }

    pub fn clone_value(&mut self) -> Vec<u8> {
        unsafe { (*(self.borrow)(self.ptr)).clone() }
    }

    pub fn unwrap(&mut self) -> *mut HeapIP {
        self.ptr
    }
}

impl Drop for IP {
    fn drop(&mut self) {
        if self.must_drop {
            (self.drop)(self.ptr);
        }
    }
}

impl Clone for IP {
    fn clone(&self) -> Self {
        IP {
            ptr: (self.clone)(self.ptr),
            must_drop: true,
            write_msg: self.write_msg,
            get_last_write: self.get_last_write,
            flush: self.flush,
            borrow: self.borrow,
            clear: self.clear,
            drop: self.drop,
            clone: self.clone,
        }
    }
}

impl Write for IP {
    fn write(&mut self, buf: &[u8]) -> io::Result<usize> {
        match (self.write_msg)(self.ptr, buf) {
            0 => {
                Ok((self.get_last_write)(self.ptr))
            }
            _ => {
                Err(io::Error::new(io::ErrorKind::Other, "Cannot write"))
            }
        }
    }

    fn flush(&mut self) -> io::Result<()> {
        match (self.flush)(self.ptr) {
            0 => Ok(()),
            _ => Err(io::Error::new(io::ErrorKind::Other, "Cannot flush"))
        }
    }
}

pub struct IPSender {
    sender: Option<*const HeapIPSender>,
    send: extern fn(*const HeapIPSender, *mut HeapIP) -> i8,
    drop: extern fn(*const HeapIPSender),
}
impl IPSender {
    pub fn send(&self, mut ip: IP) -> Result<()>{
        if let Some(sender) = self.sender {
            match (self.send)(sender, ip.unwrap()) {
                0 => {
                    ip.must_drop = false;
                    Ok(())
                },
                _ => {
                    Err(result::Error::CannotSend)
                }
            }
        } else {
            Err(result::Error::CannotSend)
        }
    }

    // TODO : change result
    pub fn to_raw(mut self) -> Result<*const HeapIPSender> {
        mem::replace(&mut self.sender, None).ok_or(result::Error::CannotSend)
    }
}

impl Drop for IPSender {
    fn drop(&mut self) {
        if let Some(ptr) = self.sender {
            (self.drop)(ptr);
        }
    }
}

pub struct IPReceiver {
    receiver: *const HeapIPReceiver,
    recv: extern fn(*const HeapIPReceiver) -> *mut HeapIP,
    try_recv: extern fn(*const HeapIPReceiver) -> *mut HeapIP,
    drop: extern fn(*const HeapIPReceiver),
}
impl IPReceiver {
    pub fn recv(&self) -> Result<*mut HeapIP> {
        let ip = (self.recv)(self.receiver);
        if ip as usize == 0 {
            return Err(result::Error::CannotReceive);
        }
        Ok(ip)
    }

    pub fn try_recv(&self) -> Result<*mut HeapIP> {
        let ip = (self.try_recv)(self.receiver);
        if ip as usize == 0 {
            return Err(result::Error::CannotReceive);
        }
        Ok(ip)
    }
}

impl Drop for IPReceiver {
    fn drop(&mut self) {
       (self.drop)(self.receiver);
    }
}

// TODO : remove drop? It's the scheduler that will drop the senders...
pub struct Senders {
    senders: *mut HeapSenders,
    add_ptr: extern fn(*mut HeapSenders, &String, *const HeapIPSender),
    drop: extern fn(*mut HeapSenders),
}

impl Senders {
    pub fn add_ptr(&self, name: &String, sender: *const HeapIPSender) {
        (self.add_ptr)(self.senders, name, sender);
    }
}

unsafe impl Send for HeapIPSender {}
unsafe impl Send for HeapIPReceiver {}
unsafe impl Send for IPReceiver {}
unsafe impl Send for HeapIP {}
