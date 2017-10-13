#[derive(Debug, Clone)]
pub struct CoreGraph {
    pub path: String,
    pub nodes: Vec<CoreGraphNode>,
    // out() p[s] -> p[s] in()
    pub edges: Vec<CoreGraphEdge>,
    // 'imsg' -> p[s] in()
    pub imsgs: Vec<CoreGraphIMsg>,
    // p => p[s] in()
    pub ext_in: Vec<CoreGraphExtIn>,
    // out() p[s] => p
    pub ext_out: Vec<CoreGraphExtOut>,
}

impl CoreGraph {
    pub fn new() -> Self {
        CoreGraph {
            path: String::new(),
            nodes: Vec::new(),
            edges: Vec::new(),
            imsgs: Vec::new(),
            ext_in: Vec::new(),
            ext_out: Vec::new(),
        }
    }
}

#[derive(Debug, Clone)]
pub struct CoreGraphNode {
    pub name: String,
    pub sort: String,
}

#[derive(Debug, Clone)]
pub struct CoreGraphEdge {
    pub out_comp: String,
    pub out_port: String,
    pub out_elem: Option<String>,
    pub in_port: String,
    pub in_elem: Option<String>,
    pub in_comp: String,
}

#[derive(Debug, Clone)]
pub struct CoreGraphIMsg {
    pub msg: String,
    pub port: String,
    pub elem: Option<String>,
    pub comp: String
}

#[derive(Debug, Clone)]
pub struct CoreGraphExtIn {
    pub port: String,
    pub in_port: String,
    pub in_elem: Option<String>,
    pub in_comp: String,
}

#[derive(Debug, Clone)]
pub struct CoreGraphExtOut {
    pub port: String,
    pub out_port: String,
    pub out_elem: Option<String>,
    pub out_comp: String,
}
