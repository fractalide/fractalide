#[macro_use]
extern crate rustfbp;
extern crate capnp;

#[macro_use]
extern crate nom;

#[derive(Debug)]
enum Literal {
    Comment,
    Bind,
    External,
    Comp(String, String),
    Port(String, Option<String>),
    IMSG(String),
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
named!(imsg<&[u8], Literal>, chain!(
    multispace? ~
        tag!(b"'") ~
        imsg: is_not!(b"'") ~
        tag!(b"'") ~
        multispace
        , || { Literal::IMSG(String::from_utf8(imsg.to_vec()).expect("not utf8"))}
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

named!(literal<&[u8], Literal>, alt!(comment | imsg | bind | external | comp_or_port));

agent! {
    input(input: file_desc),
    output(output: fbp_lexical),
    fn run(&mut self) -> Result<Signal>{
        // Get one MSG
        let mut msg = try!(self.input.input.recv());
        let file: file_desc::Reader = try!(msg.read_schema());

        // print it
        match try!(file.which()) {
            file_desc::Start(path) => {
                let path = try!(path);
                let mut new_msg = Msg::new();
                {
                    let mut msg = new_msg.build_schema::<fbp_lexical::Builder>();
                    msg.set_start(&path);
                }
                let _ = self.output.output.send(new_msg);
                try!(handle_stream(&self));
            },
            _ => { return Err(result::Error::Misc("bad stream".to_string())) }
        }

        Ok(End)
    }
}

fn handle_stream(comp: &ThisAgent) -> Result<()> {
    loop {
        // Get one Msg
        let mut msg = try!(comp.input.input.recv());
        let file: file_desc::Reader = try!(msg.read_schema());

        // print it
        match try!(file.which()) {
            file_desc::Text(text) => {
                let mut text = try!(text).as_bytes();
                loop {
                    match literal(text) {
                        IResult::Done(rest, lit) => {
                            let mut send_msg = Msg::new();
                            {
                                let msg = send_msg.build_schema::<fbp_lexical::Builder>();
                                match lit {
                                    Literal::Bind => { msg.init_token().set_bind(()); },
                                    Literal::External => {msg.init_token().set_external(()); },
                                    Literal::Port(name, selection) => {
                                        let mut port = msg.init_token().init_port();
                                        port.set_name(&name);
                                        if let Some(s) = selection {
                                            port.set_selection(&s);
                                        } else {
                                            port.set_selection("");
                                        }
                                    },
                                    Literal::Comp(name, sort) => {
                                        let mut comp = msg.init_token().init_comp();
                                        comp.set_name(&name);
                                        comp.set_sort(&sort);
                                    },
                                    Literal::IMSG(imsg) => {
                                        msg.init_token().set_imsg(&imsg);
                                    }
                                    Literal::Comment => { break; }
                                }
                            }
                            text = rest;
                            let _ = comp.output.output.send(send_msg);
                        },
                        _ => { break;}
                    }
                }
                let mut new_msg = Msg::new();
                {
                    let msg = new_msg.build_schema::<fbp_lexical::Builder>();
                    msg.init_token().set_break(());
                }
                let _ = comp.output.output.send(new_msg);
            },
            file_desc::End(path) => {
                let path = try!(path);
                let mut new_msg = Msg::new();
                {
                    let mut msg = new_msg.build_schema::<fbp_lexical::Builder>();
                    msg.set_end(&path);
                }
                let _ = comp.output.output.send(new_msg);
                break;
            },
            _ => { return Err(result::Error::Misc("Bad stream".to_string())); }
        }
    }
    Ok(())
}
