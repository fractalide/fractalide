#[macro_use]
extern crate rustfbp;

#[macro_use]
extern crate nom;

extern crate capnp;

mod contract_capnp {
    include!("file_desc.rs");
    include!("fbp_lexical.rs");
}
use contract_capnp::file_desc;
use contract_capnp::fbp_lexical;

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
    comp,
    inputs(input: file_desc),
    inputs_array(),
    outputs(output: fbp_lexical),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()>{
        // Get one IP
        let mut ip = try!(self.ports.recv("input"));
        let file: file_desc::Reader = try!(ip.get_root());

        // print it
        match try!(file.which()) {
            file_desc::Start(path) => {
                let path = try!(path);
                let mut new_ip = IP::new();
                {
                    let mut ip = new_ip.init_root::<fbp_lexical::Builder>();
                    ip.set_start(&path);
                }
                let _ = self.ports.send("output", new_ip);
                try!(handle_stream(&self));
            },
            _ => { return Err(result::Error::Misc("bad stream".to_string())) }
        }

        Ok(())
    }
}

fn handle_stream(comp: &comp) -> Result<()> {
    loop {
        // Get one IP
        let mut ip = try!(comp.ports.recv("input"));
        let file: file_desc::Reader = try!(ip.get_root());

        // print it
        match try!(file.which()) {
            file_desc::Text(text) => {
                let mut text = try!(text).as_bytes();
                loop {
                    match literal(text) {
                        IResult::Done(rest, lit) => {
                            let mut send_ip = IP::new();
                            {
                                let mut ip = send_ip.init_root::<fbp_lexical::Builder>();
                                match lit {
                                    Literal::Bind => { ip.init_token().set_bind(()); },
                                    Literal::External => {ip.init_token().set_external(()); },
                                    Literal::Port(name, selection) => {
                                        let mut port = ip.init_token().init_port();
                                        port.set_name(&name);
                                        if let Some(s) = selection {
                                            port.set_selection(&s);
                                        } else {
                                            port.set_selection("");
                                        }
                                    },
                                    Literal::Comp(name, sort) => {
                                        let mut comp = ip.init_token().init_comp();
                                        comp.set_name(&name);
                                        comp.set_sort(&sort);
                                    },
                                    Literal::IIP(iip) => {
                                        ip.init_token().set_iip(&iip);
                                    }
                                    Literal::Comment => { break; }
                                }
                            }
                            text = rest;
                            let _ = comp.ports.send("output", send_ip);
                        },
                        _ => { break;}
                    }
                }
                let mut new_ip = IP::new();
                {
                    let mut ip = new_ip.init_root::<fbp_lexical::Builder>();
                    ip.init_token().set_break(());
                }
                let _ = comp.ports.send("output", new_ip);
            },
            file_desc::End(path) => {
                let path = try!(path);
                let mut new_ip = IP::new();
                {
                    let mut ip = new_ip.init_root::<fbp_lexical::Builder>();
                    ip.set_end(&path);
                }
                let _ = comp.ports.send("output", new_ip);
                break;
            },
            _ => { return Err(result::Error::Misc("Bad stream".to_string())); }
        }
    }
    Ok(())
}
