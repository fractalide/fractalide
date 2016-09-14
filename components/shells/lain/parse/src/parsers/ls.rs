use nom::{multispace};

named!(cd<(&[u8], &[u8])>, chain!(multispace? ~ tag!("ls") ~ multispace?, || b"shells_lain_commands_ls"));
