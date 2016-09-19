use nom::*;
use std::io::prelude::*;
use std::fs::File;
mod error;
use self::error::{
    CharError,
    CliError,
    Position,
    SizeError,
};

mod basic_cmds;
use self::basic_cmds::basic_cmds;
use std::str;

named!(consume_useless_chars, take_while!(is_whitespace));
named!(get_cmd_args, alt!(basic_cmds));
fn is_whitespace(c: u8) -> bool {
    c as char == ' ' || c as char == '\t'
}
fn is_not_cell_end(c: u8) -> bool {
    c as char != '|' && c as char != '\n'
}

macro_rules! separated_list2 (
  ($i:expr, $sep:ident!( $($args:tt)* ), $submac:ident!( $($args2:tt)* )) => (
    {
      let mut res = ::std::vec::Vec::new();
      let mut input = $i;

      // get the first element
      let first = $submac!(input, $($args2)*);

      if let IResult::Done(i, o) = first {
         if i.len() == input.len() {
            let err : IResult<&[u8], Vec<Vec<String>>, CliError> = IResult::Error(Err::Position(ErrorKind::SeparatedList, input)); err
          } else {
            res.push(o);
            input = i;

            loop {
              // get the separator first
              if let IResult::Done(i2,_) = $sep!(input, $($args)*) {
                println!("{:?}", String::from_utf8_lossy(i2));
                if i2.len() == input.len() {
                  break;
                }
                input = i2;

                // get the element next
                if let IResult::Done(i3,o3) = $submac!(input, $($args2)*) {
                  res.push(o3);
                  input = i3;
                  if i3.len() == input.len() {
                    break;
                  }
                } else {
                  break;
                }
              } else {
                break;
              }
            }
            IResult::Done(input, res)
          }
      } else if let IResult::Incomplete(i) = first {
        IResult::Incomplete(i)
      } else {
        IResult::Done(input, ::std::vec::Vec::new())
      }
    }
  );
  ($i:expr, $submac:ident!( $($args:tt)* ), $g:expr) => (
    separated_list!($i, $submac!($($args)*), call!($g));
  );
  ($i:expr, $f:expr, $submac:ident!( $($args:tt)* )) => (
    separated_list!($i, call!($f), $submac!($($args)*));
  );
  ($i:expr, $f:expr, $g:expr) => (
    separated_list!($i, call!($f), call!($g));
  );
);


fn get_column_value(input: &[u8], pos: Position) -> IResult<&[u8], &[u8], CliError> {
    let (i, cell) = try_parse!(input,
        fix_error!(CliError,
            preceded!(
                opt!(consume_useless_chars),
                get_cmd_args
            )
        )
    );

    if i.len() == 0 {
        //IResult::Incomplete(Needed::Unknown)
        IResult::Done(i, cell)
    } else if is_not_cell_end(i[0]) {
        let p = Position { line: pos.line, column: pos.column + input.offset(i) };
        IResult::Error(Err::Code(ErrorKind::Custom(
            CliError::InvalidCharacter(CharError::new('|', i[0] as char, &p))
        )))
    } else {
        IResult::Done(i, cell)
    }
}

fn get_string_column_value(input: &[u8], pos: Position) -> IResult<&[u8], String, CliError> {
    map_res!(input,
        map_res!(
            dbg_dmp!(
                apply!(get_column_value, Position::new(pos.line, pos.column))
            ),
            str::from_utf8
        ),
        |d| {
            str::FromStr::from_str(d)
        }
    )
}

fn comma_then_column<'a>(input: &'a [u8], pos: &Position) -> IResult<&'a [u8], String, CliError> {
    preceded!(input,
        fix_error!(CliError, char!('|')),
        apply!(get_string_column_value, Position::new(pos.line, pos.column))
    )
}

fn many_comma_then_column(input: &[u8], pos: Position) -> IResult<&[u8], Vec<String>, CliError> {
    many0!(
        input,
        apply!(comma_then_column, &pos)
    )
}
fn get_line_values<'a>(entry: &'a[u8], ret: &mut Vec<String>, line: usize) -> IResult<&'a[u8], &'a[u8], CliError> {
    if entry.len() == 0 {
        IResult::Done(entry, entry)
    } else {
        let (i, col) = try_parse!(entry, apply!(get_string_column_value, Position::new(line, ret.len())));
        ret.push(col);

        match fix_error!(i, CliError, separated_list2!(
            char!('\n'),
            apply!(many_comma_then_column, Position::new(line, ret.len()))
        )) {
            IResult::Done(i, v)    => {
                let v : Vec<Vec<String>> = v;
                for c in v {
                    for sub_c in c {
                        ret.push(sub_c);
                    }
                }
                IResult::Done(i, &entry[..entry.offset(i)])
            },
            IResult::Incomplete(i) => IResult::Incomplete(i),
            IResult::Error(e)      => IResult::Error(e)
        }
    }
}
fn get_lines_values(mut ret: Vec<Vec<String>>, entry: &[u8]) -> Result<Vec<Vec<String>>, CliError> {
    let mut input = entry;
    let mut line  = 0;
    loop {
        let mut v: Vec<String> = Vec::new();
        match get_line_values(input, &mut v, line) {
            IResult::Error(Err::Code(ErrorKind::Custom(e))) => return Err(e),
            IResult::Error(_)                               => return Err(CliError::GenericError),
            IResult::Incomplete(_)                          => {
                // did we reach the end of file?
                break
            }
            IResult::Done(i,_)                              => {
                input = i;
                line += 1;
                ret.push(v);
                if input.len() == 0 {
                    break;
                }
            },
        }
    }

    Ok(ret)
}

pub fn parse_lain_lang_from_slice(entry: &[u8]) -> Result<Vec<Vec<String>>, CliError> {
    get_lines_values(vec!(), entry)
}

pub fn parse_lain_lang_from_file(filename: &str) -> Result<Vec<Vec<String>>, CliError> {
    let mut f = File::open(filename).unwrap();
    let mut buffer = vec!();

    f.read_to_end(&mut buffer).unwrap();
    parse_lain_lang_from_slice(&buffer)
}

pub fn parse_lain_lang(entry: &str) -> Result<Vec<Vec<String>>, CliError> {
    parse_lain_lang_from_slice(entry.as_bytes())
}
#[test]
fn check_get_cmd_args() {
    let f = b"cd\nls|pwd\n";
    let g = b"ls | ls|pwd\n";

    match get_cmd_args(f) {
        IResult::Done(_, out) => assert_eq!(out, b"shells_lain_commands_cd"),
        IResult::Incomplete(x) => panic!("incomplete: {:?}", x),
        IResult::Error(e) => panic!("error: {:?}", e),
    }
    match get_cmd_args(g) {
        IResult::Done(_, out) => assert_eq!(out, b"shells_lain_commands_ls"),
        IResult::Incomplete(x) => panic!("incomplete: {:?}", x),
        IResult::Error(e) => panic!("error: {:?}", e),
    }
}


#[test]
fn check_get_line_values() {

    let mut cells = vec!();
    let res = get_line_values(b"cd|pwd|ls\n", &mut cells, 0);
    println!("res: {:?}", res);
    assert_eq!(cells, vec!("shells_lain_commands_cd".to_owned()
                            , "shells_lain_commands_pwd".to_owned()
                            , "shells_lain_commands_ls".to_owned()));

    let mut cells = vec!();
    get_line_values(b"cd|ls\n", &mut cells, 0);
    assert_eq!(cells, vec!("shells_lain_commands_cd".to_owned()
                    , "shells_lain_commands_ls".to_owned()
                    //, "".to_owned()
                ));

    let mut cells = vec!();
    get_line_values(b"cd|ls|cd|ls\n", &mut cells, 0);
    assert_eq!(cells, vec!("shells_lain_commands_cd".to_owned()
                    , "shells_lain_commands_ls".to_owned()
                    , "shells_lain_commands_cd".to_owned()
                    , "shells_lain_commands_ls".to_owned()));

    // let mut cells = vec!();
    // let e = get_line_values(b"cd |ls|pwd", &mut cells, 0);
    // assert_eq!(e,
    //     IResult::Error(Err::Code(ErrorKind::Custom(
    //         CliError::InvalidCharacter(CharError::new('|', ' ', &Position::new(0, 5)))
    //     )))
    // );
}


// #[test]
// fn check_get_lines_values() {
//     let f = b"cd|ls\nps|pwd\ngrep|nc\n";
//
//     assert_eq!(get_lines_values(vec!(), f),
//                Ok(vec!(
//                        vec!("cd".to_owned(), "ls".to_owned()),
//                        vec!("ps".to_owned(), "pwd".to_owned()),
//                        vec!("grep".to_owned(), "nc".to_owned()))));
//     let f = b"cd|ls\nps|pwd\ngrep|nc";
//
//     assert_eq!(get_lines_values(vec!(), f),
//                Ok(vec!(
//                        vec!("cd".to_owned(), "ls".to_owned()),
//                        vec!("ps".to_owned(), "pwd".to_owned()),
//                        vec!("grep".to_owned(), "nc".to_owned()))));
// }

// #[test]
// fn check_parse_lain_lang() {
//     let f = "cd|ls\nps|pwd\ngrep|nc\ngrep2|grep3|nc2\n";
//
//     assert_eq!(parse_lain_lang(f),
//                Ok(vec!(
//                        vec!("cd".to_owned(), "ls".to_owned()),
//                        vec!("ps".to_owned(), "pwd".to_owned()),
//                        vec!("grep".to_owned(), "nc".to_owned()),
//                        vec!("grep2".to_owned(), "grep3".to_owned(), "nc2".to_owned()))));
// }
