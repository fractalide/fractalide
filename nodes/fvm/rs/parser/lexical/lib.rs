#[macro_use]
extern crate rustfbp;
extern crate capnp;

#[macro_use]
extern crate nom;

use nom::{IResult, AsBytes};
use nom::multispace;

use std::str::FromStr;

named!(comment<&[u8], CoreLexicalToken>, do_parse!(
    many0!(multispace) >>
    tag!(b"//") >>
    is_not!("\n") >>
    ( CoreLexicalToken::Comment )
));

named!(bind<&[u8], CoreLexicalToken>, do_parse!(
    ws!(tag!(b"->")) >>
    ( CoreLexicalToken::Bind )
));

named!(external<&[u8], CoreLexicalToken>, do_parse!(
    ws!(tag!(b"=>")) >>
    ( CoreLexicalToken::External )
));

named!(imsg<&[u8], CoreLexicalToken>, do_parse!(
    many0!(multispace) >>
    tag!(b"'") >>
    imsg: map_res!(
        take_until!("'"),
        std::str::from_utf8
    ) >>
    tag!(b"'") >>
    many0!(multispace) >>
    ( CoreLexicalToken::IMsg(imsg.into()) )
));

named!(name<&str>,
    map_res!(
        is_not!(" [("),
        std::str::from_utf8
    )
);

named!(selection<String>, do_parse!(
    many0!(multispace) >>
    tag!(b"[") >>
    selection: map_res!(
        take_until!("]"),
        std::str::from_utf8
    ) >>
    tag!(b"]") >>
    many0!(multispace) >>
    ( selection.to_string() )
));

named!(comp<CoreLexicalToken>, do_parse!(
    many0!(multispace) >>
    name: name >>
    tag!(b"(") >>
        many0!(multispace) >>
        sort: opt!(complete!(map_res!(
            map_res!(
                take_until1!(")"),
                std::str::from_utf8
            ),
        std::str::FromStr::from_str
    ))) >>
    tag!(b")") >>
    ( CoreLexicalToken::Comp(name.into(), sort) )
));

named!(port<CoreLexicalToken>, do_parse!(
    many0!(multispace) >>
    name: name >>
    selection: opt!(complete!(selection)) >>
    many0!(multispace) >>
    ( CoreLexicalToken::Port(name.into(), selection) )
));

named!(comp_or_port<&[u8], CoreLexicalToken>, alt!(complete!(comp) | port));

named!(literal<&[u8], CoreLexicalToken>, alt!(comment | imsg | bind | external | comp_or_port));

agent! {
    input(input: FsFileDesc),
    output(output: CoreLexical),
    fn run(&mut self) -> Result<Signal>{
        let file = self.input.input.recv()?;

        match file {
            FsFileDesc::Start(path) => {
                let _ = self.output.output.send(CoreLexical::Start(path));
                try!(handle_stream(&self));
            },
            _ => { return Err(result::Error::Misc("bad stream".to_string())) }
        }

        Ok(End)
    }
}

fn handle_stream(comp: &ThisAgent) -> Result<()> {
    loop {
        let file = comp.input.input.recv()?;

        // print it
        match file {
            FsFileDesc::Text(text) => {
                let mut text = text.as_bytes();
                loop {
                    match literal(text) {
                        IResult::Done(rest, lit) => {
                            let _ = comp.output.output.send(CoreLexical::Token(lit));
                            text = rest;
                        },
                        _ => { break;}
                    }
                }
                let _ = comp.output.output.send(CoreLexical::Token(CoreLexicalToken::Break));
            },
            FsFileDesc::End(path) => {
                let _ = comp.output.output.send(CoreLexical::End(path));
                break;
            },
            _ => { return Err(result::Error::Misc("Bad stream".to_string())); }
        }
    }
    Ok(())
}
