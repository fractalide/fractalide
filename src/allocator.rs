extern crate capnp;

use self::capnp::message::{HeapAllocator, Builder};

use std::mem::transmute;
use std::sync::mpsc::channel;
use std::sync::mpsc::{Sender, Receiver};
use std::collections::HashMap;

use result;
use result::Result;

// TODO : send +1 -1 on send/receive 

/*
 *  Memory object
 */

/*
    HeapIP
*/
#[repr(C)]
pub struct HeapIP {
    pub ip: Vec<u8>,
}

extern "C" fn create_ip() -> *mut HeapIP {
    let ip = Box::new(HeapIP { ip: vec![], });
    let ip: *mut HeapIP = unsafe { transmute(ip) };
    ip
}

extern "C" fn create_ptr() -> *mut HeapIP {
    0 as *mut HeapIP
}

extern "C" fn write_msg(ip: *mut HeapIP, msg: &Builder<HeapAllocator>) {
    unsafe {
        capnp::serialize::write_message(&mut (*ip).ip, msg);
    }
}

extern "C" fn borrow_ip<'a>(ip: *mut HeapIP) -> *const Vec<u8> {
    unsafe {
        & (*ip).ip as *const Vec<u8>
    }
}

extern "C" fn drop_ip(ip: *mut HeapIP) {
    let _ip: Box<HeapIP> = unsafe { transmute(ip) };
    println!("Drop the HeapIP");
}

/*
    IPSender
*/
#[repr(C)]
pub struct HeapIPSender {
    pub sender: Sender<*mut HeapIP>,
}

pub extern "C" fn send_ip(sender: *const HeapIPSender, mut msg: *mut HeapIP) -> i8 {
    unsafe {
        match (*sender).sender.send(msg) {
            Ok(()) => 0,
            Err(_) => -1,
        }
    }
}

extern "C" fn drop_sender(sender: *const HeapIPSender) {
    let _ip: Box<HeapIPSender> = unsafe { transmute(sender) };
    println!("Drop the Sender");
}

/*
HeapSenders
 */
#[repr(C)]
pub struct HeapSenders{
    pub senders: HashMap<String, *const HeapIPSender>,
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
}

extern "C" fn recv_ip(receiver: *const HeapIPReceiver) -> *mut HeapIP {
    unsafe {
        match (*receiver).receiver.recv() {
            Ok(ip) => { ip },
            Err(_) => { 0 as *mut HeapIP },
        }
    }
}

extern "C" fn try_recv_ip(receiver: *const HeapIPReceiver) -> *mut HeapIP {
    unsafe {
        match (*receiver).receiver.try_recv() {
            Ok(ip) => {
                ip
            },
            Err(_) => { 0 as *mut HeapIP },
        }
    }
}

extern "C" fn drop_receiver(receiver: *const HeapIPReceiver) {
    let _ip: Box<HeapIPReceiver> = unsafe { transmute(receiver) };
    println!("Drop the receiver");
}

#[repr(C)]
pub struct HeapChannel {
    pub sender: *const HeapIPSender,
    pub receiver: *const HeapIPReceiver,
}

extern "C" fn create_channel() -> *mut HeapChannel {
    let (s, r): (Sender<*mut HeapIP>, Receiver<*mut HeapIP>) = channel();
    let s = Box::new(HeapIPSender { sender: s });
    let r = Box::new(HeapIPReceiver { receiver: r });
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
    pub fn new() -> Self {
        Allocator {
            ip: IPBuilder::new(),
            channel: ChannelBuilder::new(),
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
    write_msg: extern fn(*mut HeapIP, &Builder<HeapAllocator>),
    borrow: extern fn(*mut HeapIP) -> *const Vec<u8>,
    drop: extern fn(*mut HeapIP),
}

impl IPBuilder {
    pub fn new() -> Self {
        IPBuilder {
            create: create_ip,
            create_ptr: create_ptr,
            write_msg: write_msg,
            borrow: borrow_ip,
            drop: drop_ip,
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
            borrow: self.borrow,
            drop: self.drop
        }
    }

    pub fn build(&self, ptr: *mut HeapIP) -> IP {
        IP {
            ptr: ptr,
            must_drop: true,
            write_msg: self.write_msg,
            borrow: self.borrow,
            drop: self.drop
        }
    }
}

impl Clone for IPBuilder {
    fn clone(&self) -> Self {
        IPBuilder {
            create: self.create,
            create_ptr: self.create_ptr,
            write_msg: self.write_msg,
            borrow: self.borrow,
            drop: self.drop,
        }
    }
}

pub struct ChannelBuilder {
    create: extern fn() -> *mut HeapChannel,
    get_r: extern fn(*mut HeapChannel) -> *const HeapIPReceiver,
    get_s: extern fn(*mut HeapChannel) -> *const HeapIPSender,
    send: extern fn(*const HeapIPSender, *mut HeapIP) -> i8,
    recv: extern fn(*const HeapIPReceiver) -> *mut HeapIP,
    try_recv: extern fn(*const HeapIPReceiver) -> *mut HeapIP,
    drop_send: extern fn(*const HeapIPSender),
    drop_recv: extern fn(*const HeapIPReceiver),
}

impl ChannelBuilder {
    pub fn new() -> Self {
        ChannelBuilder {
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

    pub fn build_raw(&self) -> *mut HeapChannel {
        (self.create)()
    }

    pub fn build(&self) -> (*const HeapIPSender, *const HeapIPReceiver) {
        let chan = (self.create)();
        let s = (self.get_s)(chan);
        let r = (self.get_r)(chan);
        (s, r)
    }

    pub fn build_sender(&self, sender: *const HeapIPSender) -> IPSender {
        IPSender {
            sender: sender,
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
    write_msg: extern fn(*mut HeapIP, &Builder<HeapAllocator>),
    borrow: extern fn(*mut HeapIP) -> *const Vec<u8>,
    drop: extern fn(*mut HeapIP),
}

impl IP {
    pub fn write(&mut self, msg: &Builder<HeapAllocator>) {
        (self.write_msg)(self.ptr, msg);
    }

    pub fn clone(self) -> Vec<u8> {
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

pub struct IPSender {
    sender: *const HeapIPSender,
    send: extern fn(*const HeapIPSender, *mut HeapIP) -> i8,
    drop: extern fn(*const HeapIPSender),
}
impl IPSender {
    pub fn send(&self, mut ip: IP) -> Result<()>{
        match (self.send)(self.sender, ip.unwrap()) {
            0 => {
                ip.must_drop = false;
                Ok(())
            },
            _ => {
                Err(result::Error::CannotSend)
            }
        }
    }
}

impl Drop for IPSender {
    fn drop(&mut self) {
        (self.drop)(self.sender);
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
