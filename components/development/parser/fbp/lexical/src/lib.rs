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

named!(literal<&[u8], Literal>, alt!(iip | bind | external | comp_or_port));

named!(line<&[u8], Vec<Literal> >, many0!(literal));



component! {
    file_open,
    inputs(input: file),
    inputs_array(),
    outputs(output: fbp_lexical),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) {
        println!("hello fbp-lexical");
        loop {
         // Get one IP
         let mut ip = self.ports.recv("input".into()).expect("file_print : unable to receive from input");
         let file = ip.get_reader().expect("file_open: cannot get the reader");
         let file: file::Reader = file.get_root().expect("file_open: not a file_name reader");
         // print it
         match file.which().expect("cannot which") {
          file::Start(path) => { println!("Start : {} ", path.unwrap()); },
             file::Text(text) => {
                 let mut text = text.unwrap().as_bytes();
                 loop {
                     match literal(text) {
                         IResult::Done(rest, lit) => {
                             text = rest;
                             println!("{:?}", lit);
                         },
                         _ => { break;}
                     }
                 }
             },
          file::End(path) => { println!("End : {} ", path.unwrap()); break; },
         }
         // Send outside (don't care about loss)
         let _ = self.ports.send("output".into(), ip);
        }

    }


}
