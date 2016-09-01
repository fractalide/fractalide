use nom::*;

named!(pub get_command, chain!(consume_useless_chars ~ cmd:take_while!(is_not_command_end), || cmd));
named!(consume_useless_chars, take_while!(is_whitespace));

fn is_whitespace(c: u8) -> bool {
    c as char == ' ' || c as char == '\t'
}

fn is_not_command_end(c: u8) -> bool {
    c as char != ' ' && c as char != '\n' && c as char != '\t'
}

#[test]
fn check_get_command() {
    let d1 = b"list -select \"names\" -count 30\n";
    let d2 = b"  \t  cd a/path/\n";
    let d3 = b"ls\t a/path/\n";
    let d4 = b" super_long_insane_command_length  a/path/\n";

    match get_command(d1) {
        IResult::Done(_, out) => assert_eq!(out, b"list"),
        IResult::Incomplete(x) => panic!("incomplete: {:?}", x),
        IResult::Error(e) => panic!("error: {:?}", e),
    }
    match get_command(d2) {
        IResult::Done(_, out) => assert_eq!(out, b"cd"),
        IResult::Incomplete(x) => panic!("incomplete: {:?}", x),
        IResult::Error(e) => panic!("error: {:?}", e),
    }
    match get_command(d3) {
        IResult::Done(_, out) => assert_eq!(out, b"ls"),
        IResult::Incomplete(x) => panic!("incomplete: {:?}", x),
        IResult::Error(e) => panic!("error: {:?}", e),
    }
    match get_command(d4) {
        IResult::Done(_, out) => assert_eq!(out, b"super_long_insane_command_length"),
        IResult::Incomplete(x) => panic!("incomplete: {:?}", x),
        IResult::Error(e) => panic!("error: {:?}", e),
    }
}
