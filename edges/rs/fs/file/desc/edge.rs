#[derive(Debug, Clone)]
pub enum FsFileDesc {
    Start(String),
    End(String),
    Text(String),
}
