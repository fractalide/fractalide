#[macro_use]
extern crate rustfbp;
use rustfbp::component::*;

#[macro_use]
extern crate nom;

extern crate capnp;

mod contract_capnp {
    include!("file.rs");
    include!("fbp_lexical.rs");
}
use contract_capnp::file;
use contract_capnp::lexical;

#[derive(Debug)]
enum Literal {
    Comment,
    Bind,
    External,
    Comp(String, String),
    Port(String, Option<String>),
    IIP(String),
}

use nom::{IResult, AsBytes};
use nom::multispace;

fn ret_bind(i: &[u8]) -> Literal { Literal::Bind }
fn ret_external(i: &[u8]) -> Literal { Literal::External }

named!(comment<&[u8], Literal>, chain!(
    multispace? ~
        tag!(b"//") ~
        is_not!(&[b'\n']),
    || { Literal::Comment }
    ));
named!(bind<&[u8], Literal>, chain!(
    multispace? ~
        bind: map!(tag!(b"->"), ret_bind) ~
        multispace?
    , || { bind }
    ));
named!(external<&[u8], Literal>, chain!(
    multispace? ~
        external: map!(tag!(b"=>"), ret_external) ~
        multispace?
    , || { external }
    ));
named!(iip<&[u8], Literal>, chain!(
    multispace? ~
        tag!(b"'") ~
        iip: is_not!(b"'") ~
        tag!(b"'") ~
        multispace
        , || { Literal::IIP(String::from_utf8(iip.to_vec()).expect("not utf8"))}
    ));
named!(name, is_not!(b"[ ("));
named!(selection, chain!(
    multispace? ~
        tag!(b"[") ~
        selection: is_not!(b"]") ~
        tag!(b"]") ~
        multispace?
    ,
    || { selection }
    ));
named!(sort, chain!(
    multispace? ~
        tag!(b"(") ~
        sort: is_not!(b")")? ~
        tag!(b")") ~
        multispace?
    , || {
        if sort.is_some() { sort.unwrap() }
        else { &[][..] }
    }
    ));

named!(comp_or_port<&[u8], Literal>, chain!(
    multispace? ~
        name: name ~
        sort: opt!(complete!(sort)) ~
        selection: opt!(complete!(selection)) ~
        multispace?
    , || {
        if sort.is_some() {
            Literal::Comp(String::from_utf8(name.to_vec()).expect("not utf8"), String::from_utf8(sort.unwrap().to_vec()).expect("not utf8"))
        } else {
            if selection.is_some() {
                Literal::Port(String::from_utf8(name.to_vec()).expect("not utf8"), Some(String::from_utf8(selection.unwrap().to_vec()).expect("not utf8")))
            } else {
                Literal::Port(String::from_utf8(name.to_vec()).expect("not utf8"), None)
            }
        }
    }
    ));

named!(literal<&[u8], Literal>, alt!(comment | iip | bind | external | comp_or_port));

component! {
    fbp_lexical,
    inputs(input: file),
    inputs_array(),
    outputs(output: fbp_lexical),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) {
        loop {
            // Get one IP
            let mut ip = self.ports.recv("input".into()).expect("file_print : unable to receive from input");
            let file = ip.get_reader().expect("fbp_lexical: cannot get the reader");
            let file: file::Reader = file.get_root().expect("fbp_lexical: not a file_name reader");

            // print it
            match file.which().expect("cannot which") {
                file::Start(path) => {
                    let path = path.unwrap();
                    let mut new_ip = capnp::message::Builder::new_default();
                    {
                        let mut ip = new_ip.init_root::<lexical::Builder>();
                        ip.set_start(&path);
                    }
                    let mut send_ip = self.allocator.ip.build_empty();
                    send_ip.write_builder(&new_ip).expect("fbp_lexical: cannot write");
                    let _ = self.ports.send("output".into(), send_ip);
                },
                file::Text(text) => {
                    let mut new_ip = capnp::message::Builder::new_default();
                    let mut text = text.unwrap().as_bytes();
                    loop {
                        match literal(text) {
                            IResult::Done(rest, lit) => {
                                {
                                    let mut ip = new_ip.init_root::<lexical::Builder>();
                                    match lit {
                                        Literal::Bind => { ip.set_bind(()); },
                                        Literal::External => {ip.set_external(()); },
                                        Literal::Port(name, selection) => {
                                            let mut port = ip.init_port();
                                            port.set_name(&name);
                                            if let Some(s) = selection {
                                                port.set_selection(&s);
                                            } else {
                                                port.set_selection("");
                                            }
                                        },
                                        Literal::Comp(name, sort) => {
                                            let mut comp = ip.init_comp();
                                            comp.set_name(&name);
                                            comp.set_sort(&sort);
                                        },
                                        Literal::IIP(iip) => {
                                            ip.set_iip(&iip);
                                        }
                                        Literal::Comment => { break; }
                                    }
                                }
                                text = rest;
                                let mut send_ip = self.allocator.ip.build_empty();
                                send_ip.write_builder(&new_ip).expect("fbp_lexical: cannot write");
                                let _ = self.ports.send("output".into(), send_ip);
                            },
                            _ => { break;}
                        }
                    }
                    {
                        let mut ip = new_ip.init_root::<lexical::Builder>();
                        ip.set_break(());
                    }
                    let mut send_ip = self.allocator.ip.build_empty();
                    send_ip.write_builder(&new_ip).expect("fbp_lexical: cannot write");
                    let _ = self.ports.send("output".into(), send_ip);
                },
                file::End(path) => {
                    let path = path.unwrap();
                    let mut new_ip = capnp::message::Builder::new_default();
                    {
                        let mut ip = new_ip.init_root::<lexical::Builder>();
                        ip.set_end(&path);
                    }
                    let mut send_ip = self.allocator.ip.build_empty();
                    send_ip.write_builder(&new_ip).expect("fbp_lexical: cannot write");
                    let _ = self.ports.send("output".into(), send_ip);
                    break;
                },
            }
        }

    }


}
