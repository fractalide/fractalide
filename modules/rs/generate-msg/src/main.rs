extern crate syn;
use std::io::Read;

fn main() {
    let mut args = std::env::args();
    args.next();
    let mut s = String::new();
    let mut enum_elements = Vec::new();
    while let Some(module) = args.next() {
        if let Some(path) = args.next() {
            println!("pub mod {} {{", to_module_name(&module));
            let mut f = std::fs::File::open(path).unwrap();
            s.clear();
            f.read_to_string(&mut s).unwrap();
            for l in s.lines() {
                println!("  {}", l)
            }
            generate_edges(to_module_name(&module), &s, &mut enum_elements);
            println!("}}");
        }
    }
    println!("pub enum Msg {{");
    for &(n, ref module, ref typ) in enum_elements.iter() {
        println!("  Msg{}({}::{}),", n, module, typ);
    }
    println!("}}");
    println!("impl Msg {{
  fn debug(&self) -> &str {{
    match *self {{");
    for &(n, ref module, ref typ) in enum_elements.iter() {
        println!("      Msg::Msg{}(_) => \"{}::{}\",", n, module, typ);
    }
    println!("    }}
  }}
}}");

    for &(n, ref module, ref typ) in enum_elements.iter() {
        println!("impl From<Msg> for {}::{} {{
  fn from(t: Msg) -> {}::{} {{
    match t {{
      Msg::Msg{}(x) => x,
      _ => panic!(\"expected type {}::{}, received {{}} in crate {{:?}}\", t.debug(), env!(\"CARGO_PKG_NAME\"))
    }}
  }}
}}", module, typ, module, typ, n, module, typ);
        println!("impl From<{}::{}> for Msg {{
  fn from(t: {}::{}) -> Msg {{
    Msg::Msg{}(t)
  }}
}}", module, typ, module, typ, n);
    }
}

fn to_module_name(s: &str) -> String {
    let mut out = String::new();
    let mut is_first = true;
    for c in s.chars() {
        if c.is_uppercase() {
            if !is_first {
                out.push('_')
            }
            out.extend(c.to_lowercase())
        } else {
            out.push(c)
        }
        is_first = false;
    }
    out
}

fn generate_edges(module: String, input: &str, enum_elements: &mut Vec<(usize, String, String)>) {
    let input = syn::parse_file(input).unwrap();
    for i in input.items.iter() {
        let n = enum_elements.len();
        match *i {
            syn::Item::Enum(ref en) if en.generics.params.is_empty() => {
                if let syn::Visibility::Public(_) = en.vis {
                    enum_elements.push((n, module.clone(), en.ident.to_string()));
                }
            }
            syn::Item::Struct(ref en)if en.generics.params.is_empty()  => {
                if let syn::Visibility::Public(_) = en.vis {
                    enum_elements.push((n, module.clone(), en.ident.to_string()));
                }
            }
            syn::Item::Type(ref en)if en.generics.params.is_empty()  => {
                if let syn::Visibility::Public(_) = en.vis {
                    enum_elements.push((n, module.clone(), en.ident.to_string()));
                }
            }
            syn::Item::Union(ref en)if en.generics.params.is_empty()  => {
                if let syn::Visibility::Public(_) = en.vis {
                    enum_elements.push((n, module.clone(), en.ident.to_string()));
                }
            }
            _ => {}
        }
    }
}
