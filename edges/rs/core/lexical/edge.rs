#[derive(Debug, Clone)]
pub enum CoreLexical {
    Start(String),
    End(String),
    NotFound(String),
    Token(CoreLexicalToken),
}

#[derive(Debug, Clone)]
pub enum CoreLexicalToken {
    Bind, External, Comment,
    Comp(String, Option<String>),
    Port(String, Option<String>),
    IMsg(String),
    Break,
}
