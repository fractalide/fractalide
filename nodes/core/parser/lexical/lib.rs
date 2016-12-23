#[macro_use]
extern crate rustfbp;
extern crate capnp;

#[macro_use]
extern crate nom;

#[derive(Debug)]
enum Literal<'a> {
    Comment,
    Bind,
    External,
    Comp(&'a str, &'a str),
    Port(&'a str, Option<&'a str>),
    IMSG(&'a str),
}

use nom::{IResult, AsBytes};
use nom::multispace;

named!(comment<&[u8], Literal>, do_parse!(
    many0!(multispace) >>
    tag!(b"//") >>
    is_not!("\n") >>
    ( Literal::Comment )
));

named!(bind<&[u8], Literal>, do_parse!(
    ws!(tag!(b"->")) >>
    ( Literal::Bind )
));

named!(external<&[u8], Literal>, do_parse!(
    ws!(tag!(b"=>")) >>
    ( Literal::External )
));

named!(imsg<&[u8], Literal>, do_parse!(
    many0!(multispace) >>
    tag!(b"'") >>
    imsg: map_res!(
        take_until!("'"),
        std::str::from_utf8
    ) >>
    tag!(b"'") >>
    many0!(multispace) >>
    ( Literal::IMSG(imsg) )
));

named!(name<&str>,
    map_res!(
        is_not!(" [("),
        std::str::from_utf8
    )
);

named!(selection<&str>, do_parse!(
    many0!(multispace) >>
    tag!(b"[") >>
    selection: map_res!(
        take_until!("]"),
        std::str::from_utf8
    ) >>
    tag!(b"]") >>
    many0!(multispace) >>
    ( selection )
));

named!(sort<&str>, do_parse!(
    many0!(multispace) >>
    tag!(b"(") >>
    sort: map_res!(
        take_until!(")"),
        std::str::from_utf8
    ) >>
    tag!(b")") >>
    many0!(multispace) >>
    ( sort )
));

named!(comp_or_port<&[u8], Literal>, do_parse!(
    many0!(multispace) >>
    name: name >>
    sort: opt!(complete!(sort)) >>
    selection: opt!(complete!(selection)) >>
    many0!(multispace) >>
    (
        if sort.is_some() {
            Literal::Comp(name, sort.unwrap())
        } else {
            Literal::Port(name, selection)
        }
    )
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
