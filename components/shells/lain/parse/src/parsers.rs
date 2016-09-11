use std::borrow::Cow;
use std::str::from_utf8;
use nom::space;
use nom::IResult::*;
use std::str::FromStr;
use std::fmt;
use std::error;
use nom;
use std::iter;

#[derive(Debug)]
pub struct ParserError {
    data: String
}
impl fmt::Display for ParserError {
    fn fmt(&self, fmt: &mut fmt::Formatter) -> fmt::Result {
        write!(fmt, "{}", self.data)
    }
}
impl error::Error for ParserError {
    fn description(&self) -> &str {
        &self.data
    }
}
impl<'a> From<nom::Err<&'a [u8]>> for ParserError {
    fn from(e: nom::Err<&'a [u8]>) -> ParserError {
        ParserError {
            data: format!("Error: {:?}", e)
        }
    }
}

#[derive(PartialEq, Debug)]
pub enum Command<'a> {
    Named(Cow<'a, str>),
    Numeric(u16)
}
impl<'a> fmt::Display for Command<'a> {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match *self {
            Command::Named(ref s) => write!(f, "{}", s),
            Command::Numeric(n) => write!(f, "{}", n)
        }
    }
}

#[derive(Debug)]
pub struct PipeSection<'a> {
    pub command: Command<'a>,
    pub params: Vec<&'a str>
}
impl<'a> fmt::Display for PipeSection<'a> {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let mut ret = "".to_string();
        ret.push_str(format!("{} ", self.command).as_ref());
        for param in self.params.iter() {
            ret.push_str(format!("{} ", param).as_ref());
        }
        write!(f, "{}", ret)
    }
}
fn is_not_command_end(c: u8) -> bool {
    c as char != '\r' || c as char != '\n' || c as char != ' ' || c as char == '\t'
}

fn is_whitespace(c: u8) -> bool {
    c as char == ' ' || c as char == '\t'
}

named!(word_parser <&[u8], &str>,dbg_dmp!(chain!(consume_useless_chars ~ cmd: map_res!(take_until!(" "), from_utf8), || cmd)));
named!(consume_useless_chars, take_while!(is_whitespace));
named!(eol <&[u8], &str>, dbg_dmp!(map_res!(take_until!("\r"), from_utf8)));
named!(command_parser <&[u8], Command>,
    chain!(
        cmd: word_parser,
        || {
            match FromStr::from_str(cmd) {
                Ok(numericcmd) => Command::Numeric(numericcmd),
                Err(_) => Command::Named(cmd.into())
            }
        }
    )
);
named!(message_parser <&[u8], PipeSection>,
    chain!(
        parsed_command: command_parser ~
        parsed_params: map_res!(take_until_and_consume!(":"), from_utf8)? ~
        parsed_trailing: eol,
        || {
            let params = match parsed_params {
                Some(p) => {
                    let _: &str = p;
                    p.split_whitespace()
                    .chain(iter::repeat(parsed_trailing).take(1))
                    .collect()
                },
                None => parsed_trailing.split_whitespace().collect()
            };
            PipeSection {
                command: parsed_command,
                params: params
            }
        }
    )
);

pub fn parse_pipe_section(input: &str) -> Result<PipeSection, ParserError> {
    match message_parser(input.as_bytes()) {
        Done(_, msg) => Ok(msg),
        Incomplete(i) => Err(ParserError {
            data: format!("Incomplete: {:?}", i)
        }),
        Error(e) => Err(From::from(e))
    }
}

#[test]
fn check_parse_pipe_section() {
    //let d1 = " list select:\"names\"\r";
    let d1 = "list \r";
    let d2 = " \t cd a/path/\r";
    let d3 = "ls a/path/\r";
    let d4 = "super_long_insane_command_length  a/path/\r";
    match parse_pipe_section(d1) {
        Ok(out) => {
            match out.command {
                Command::Named(cow) => {assert_eq!(cow, "list")},
                Command::Numeric(_) => {},
            }
        },
        Err(error) => panic!("an error occurred: {}", error),
    }
    match parse_pipe_section(d2) {
        Ok(out) => {
            match out.command {
                Command::Named(cow) => {assert_eq!(cow, "cd")},
                Command::Numeric(_) => {},
            }
        },
        Err(error) => panic!("an error occurred: {}", error),
    }
    match parse_pipe_section(d3) {
        Ok(out) => {
            match out.command {
                Command::Named(cow) => {assert_eq!(cow, "ls")},
                Command::Numeric(_) => {},
            }
        },
        Err(error) => panic!("an error occurred: {}", error),
    }
    match parse_pipe_section(d4) {
        Ok(out) => {
            match out.command {
                Command::Named(cow) => {assert_eq!(cow, "super_long_insane_command_length")},
                Command::Numeric(_) => {},
            }
        },
        Err(error) => panic!("an error occurred: {}", error),
    }
}
