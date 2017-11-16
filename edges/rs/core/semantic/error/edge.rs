#[derive(Debug, Clone)]
pub struct CoreSemanticError {
    pub path: String,
    pub parsing: Vec<String>,
}
