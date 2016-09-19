use nom::*;

named!(pub basic_cmds, alt!(cd | ls | pwd));
fn is_not_cell_end(c: u8) -> bool {
    c as char != '|' && c as char != '\n'
}
named!(get_args, take_while!(is_not_cell_end));

named!(cd, chain!(
    tag!("pwd") ~
    args: get_args ,
    || b"shells_lain_commands_pwd"
));
named!(ls, chain!(
    tag!("ls") ~
    args: get_args ,
    || b"shells_lain_commands_ls"
));
named!(pwd, chain!(
    tag!("cd") ~
    args: get_args ,
    || b"shells_lain_commands_cd"
));
