extern crate toml;
extern crate regex;
extern crate tempdir;
extern crate clap;
extern crate serde;
extern crate serde_json;
#[macro_use]
extern crate serde_derive;
#[macro_use]
extern crate log;
extern crate env_logger;
extern crate rusqlite;

use regex::Regex;
use std::process::Command;
use std::io::{Read, Write, BufWriter};
use clap::{Arg, App};
use std::str::from_utf8;
use std::collections::{BTreeMap, BTreeSet};
use std::path::{Path, PathBuf};

#[derive(Debug, Clone, PartialEq, Eq, Default, PartialOrd, Ord)]
pub struct Crate {
    pub name: String,
    pub major: usize,
    pub minor: usize,
    pub patch: usize,
    pub subpatch: String,
    pub vsn: usize,
}

#[derive(Debug, PartialEq, Eq, Default, Clone)]
pub struct Dep {
    pub cr: Crate,
    pub path: Option<PathBuf>,
    pub features: Vec<String>,
    pub default_features: bool,
    pub conditional_features: Vec<ConditionalFeature>,
}

#[derive(Debug, PartialEq, Eq)]
pub struct Meta {
    pub src: Src,
    pub dependencies: BTreeMap<String, Dep>,
    pub declared_dependencies: BTreeSet<String>,
    pub build_dependencies: BTreeMap<String, Dep>,
    pub crate_file: String,
    pub lib_name: String,
    pub proc_macro: bool,
    pub plugin: bool,
    pub default_features: Vec<String>,
    pub declared_features: BTreeSet<String>,
    pub use_default_features: Option<bool>,
    pub build: String,
    pub features: BTreeSet<String>,
    pub implied_features: Vec<ConditionalFeature>,
    pub bins: Vec<Bin>
}

#[derive(Debug, PartialEq, Eq)]
pub struct Bin {
    pub path: Option<String>,
    pub name: Option<String>,
}

#[derive(Debug, PartialEq, Eq, Clone)]
pub struct ConditionalFeature {
    pub feature: String,
    pub dep_feature: String,
}

#[derive(Debug, PartialEq, Eq)]
pub enum Src {
    FetchCrate { sha256: String },
    Path { path: PathBuf }
}

use std::str::FromStr;
impl FromStr for Crate {
    type Err = ();
    fn from_str(s: &str) -> Result<Crate, Self::Err> {
        let re = Regex::new(r"(\S*)-(\d*)\.(\d*)\.(\d*)(-(\S*))?").unwrap();
        let cap = re.captures(s).unwrap();
        let name = cap.get(1).unwrap().as_str().to_string();
        let major = cap.get(2).unwrap().as_str().parse().unwrap();
        let minor = cap.get(3).unwrap().as_str().parse().unwrap();
        let patch = cap.get(4).unwrap().as_str().parse().unwrap();
        let subpatch = cap.get(6).map(|x| x.as_str().to_string()).unwrap_or(String::new());
        let vsn = format!("{}{}{}", major, minor, patch).parse::<usize>().unwrap();
        Ok(Crate {
            name: name, major: major, minor: minor, patch: patch, subpatch: subpatch, vsn: vsn,
        })
    }
}

fn nix_name(name: &str) -> String {
    name.chars().map(|c| match c {
        '-' => '_',
        c => c
    }).collect()
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Prefetch {
    sha256: String,
    path: String,
}

#[derive(Debug)]
pub struct Cache {
    cache: rusqlite::Connection,
}

impl Cache {
    fn new<P:AsRef<Path>>(file: P) -> Self {

        let conn = rusqlite::Connection::open(
            file,
        ).unwrap();

        conn.execute("CREATE TABLE IF NOT EXISTS fetches (
                  id              INTEGER PRIMARY KEY,
                  name            TEXT NOT NULL,
                  sha256          TEXT NOT NULL,
                  path            TEXT NOT NULL)", &[]).unwrap();
        Cache {
            cache: conn,
        }
    }

    fn get(&mut self, url: &str) -> Option<Prefetch> {
        let mut get_stmt = self.cache.prepare("SELECT sha256, path FROM fetches WHERE name = ?1").unwrap();
        let pre: Option<Prefetch> = get_stmt.query_map(&[&url], |row| {
            Prefetch {
                sha256: row.get(0),
                path: row.get(1),
            }
        }).unwrap().next().and_then(|x| x.ok());
        pre
    }

    fn insert(&mut self, url: &str, prefetch: &Prefetch) {
        let mut insert_stmt = self.cache.prepare("INSERT INTO fetches(name, sha256, path) VALUES(?1, ?2, ?3)").unwrap();
        insert_stmt.execute(&[&url, &prefetch.sha256, &prefetch.path.as_str()]).unwrap();
    }
}

fn print_deps<'a, W:Write, I:Iterator<Item = &'a Dep>>(mut w: W, deps: I) -> Result<(), std::io::Error> {

    write!(w, " [")?;
    for i in deps {
        write!(w, " {}_{}_{}_{}", nix_name(&i.cr.name), i.cr.major, i.cr.minor, i.cr.patch)?;
    }
    write!(w, " ];")?;
    Ok(())
}

impl Crate {

    fn output_package_call<W:Write>(&self, mut w: W, n_indent: usize, meta: &Meta) -> Result<(), std::io::Error> {
        let mut indent = String::new();
        for _ in 0..n_indent {
            indent.push(' ');
        }
        write!(w, "{}{}_{}_{}_{} = {}_{}_{}_{}_ {{", indent,
               nix_name(&self.name), self.major, self.minor, self.patch,
               nix_name(&self.name), self.major, self.minor, self.patch
        )?;

        if !meta.dependencies.is_empty() {
            write!(w, "\n{}  dependencies =", indent)?;
            print_deps(&mut w, meta.dependencies.iter()
                       .filter(|&(_, c)| c.cr.name.len() > 0)
                       .map(|x| x.1))?;
        }

        if !meta.features.is_empty() {
            write!(w, "\n{}  features = [", indent)?;
            for i in meta.features.iter() {
                write!(w, " \"{}\"", i)?;
            }
            write!(w, " ];")?;
        }
        if !meta.dependencies.is_empty() || !meta.features.is_empty() {
            write!(w, "\n{}", indent)?;
        }
        writeln!(w, "}};")?;
        Ok(())
    }

    fn output_package<W:Write>(&self, mut w: W, n_indent: usize, meta: &Meta) -> Result<(), std::io::Error> {
        let mut indent = String::new();
        for _ in 0..n_indent {
            indent.push(' ');
        }
        write!(w, "{}{}_{}_{}_{}_ = {{ dependencies?[], features?[] }}: build-rust-package {{\n", indent, nix_name(&self.name), self.major, self.minor, self.patch)?;
        // writeln!(w, "build-rust-package {{")?;
        writeln!(w, "{}  crateName = \"{}\";", indent, self.name)?;
        let version = if self.subpatch.len() > 0 {
            format!("{}.{}.{}-{}", self.major, self.minor, self.patch, self.subpatch)
        } else {
            format!("{}.{}.{}", self.major, self.minor, self.patch)
        };

        writeln!(w, "{}  version = \"{}\";", indent, version)?;
        writeln!(w, "{}  fractalType = \"crate\";", indent)?;

        match meta.src {
            Src::FetchCrate { ref sha256 } => {
                writeln!(w, "{}  src = fetchzip {{", indent)?;
                writeln!(w, "{}    url = \"https://crates.io/api/v1/crates/{}/{}/download\";", indent, self.name, version)?;
                writeln!(w, "{}    sha256 = \"{}\";", indent, sha256)?;
                // Here, the .tar.gz ensures nix known how to unpack
                // (even though it's already unpacked).
                writeln!(w, "{}    name = \"{}-{}.tar.gz\";", indent, self.name, version)?;
                writeln!(w, "{}  }};", indent)?;
            }
            Src::Path { ref path } => {
                let s = path.to_string_lossy();
                writeln!(w, "{}  src = {};", indent, if s.len() > 0 { &s } else { "./." })?;
            }
        }
        if meta.crate_file.len() > 0 {
            writeln!(w, "{}  libPath = \"{}\";", indent, meta.crate_file)?;
        }
        if meta.lib_name.len() > 0 {
            writeln!(w, "{}  libName = \"{}\";", indent, meta.lib_name)?;
        }
        if meta.proc_macro {
            writeln!(w, "{}  procMacro = {};", indent, meta.proc_macro)?;
        }
        if meta.plugin {
            writeln!(w, "{}  plugin = {};", indent, meta.plugin)?;
        }
        if meta.bins.len() > 0 {
            write!(w, "{}  crateBin = [ ", indent)?;
            for bin in meta.bins.iter() {
                write!(w, "{{ ")?;
                if let Some(ref name) = bin.name {
                    write!(w, " name = \"{}\"; ", name)?;
                }
                if let Some(ref path) = bin.path {
                    write!(w, " path = \"{}\"; ", path)?;
                }
                write!(w, "}} ")?;
            }
            writeln!(w, "];")?;
        }
        if meta.build.len() > 0 {
            writeln!(w, "{}  build = \"{}\";", indent, meta.build)?;
            if meta.build_dependencies.len() > 0 {
                write!(w, "{}  buildDependencies =", indent)?;
                print_deps(&mut w, meta.build_dependencies.iter()
                           .filter(|&(_, c)| c.cr.name.len() > 0)
                           .map(|x| x.1))?;
            }
        }
        writeln!(w, "{}  inherit dependencies features release verbose;", indent)?;
        writeln!(w, "{}}};", indent)?;
        Ok(())
    }

    fn output_toplevel_indirection<W:Write>(&self, mut w: W, n_indent: usize) -> Result<(), std::io::Error> {
        let mut indent = String::new();
        for _ in 0..n_indent {
            indent.push(' ');
        }
        write!(w, "{}{} = {}_{}_{}_{};\n", indent,
               nix_name(&self.name),
               nix_name(&self.name), self.major, self.minor, self.patch
        )?;
        Ok(())
    }

    fn prefetch_path(&self, cache: &mut Cache) -> Result<Prefetch, std::io::Error> {

        let version = if self.subpatch.len() > 0 {
            format!("{}.{}.{}-{}", self.major, self.minor, self.patch, self.subpatch)
        } else {
            format!("{}.{}.{}", self.major, self.minor, self.patch)
        };
        let url = format!("https://crates.io/api/v1/crates/{}/{}/download", self.name, version);

        if let Some(prefetch) = cache.get(&url) {
            if std::fs::metadata(&prefetch.path).is_ok() {
                return Ok(prefetch.clone())
            }
        }

        println!("Prefetching {}-{}", self.name, version);
        debug!("url = {:?}", url);
        let prefetch = Command::new("nix-prefetch-url")
            .args(&[ &url, "--unpack", "--name", &(self.name.clone() + "-" + &version) ][..])
            .output()?;

        let sha256:String = from_utf8(&prefetch.stdout).unwrap().trim().to_string();
        let path = {
            debug!("{:?}", from_utf8(&prefetch.stderr));
            let path_re = Regex::new("path is ‘([^’]*)’").unwrap();
            let cap = path_re.captures(from_utf8(&prefetch.stderr).unwrap()).unwrap();
            cap.get(1).unwrap().as_str()
        };
        let pre = Prefetch { sha256: sha256, path: path.to_string() };
        cache.insert(&url, &pre);
        Ok(pre)
    }


    fn prefetch(&self, cache: &mut Cache, path: Option<&Path>) -> Result<Meta, std::io::Error> {
        let (crate_path, src) = if let Some(path) = path {
            debug!("path: {:?}", path);
            (path.to_path_buf(), Src::Path { path: path.to_path_buf() })
        } else {
            let prefetch = self.prefetch_path(cache)?;
            (Path::new(&prefetch.path).to_path_buf(),
             Src::FetchCrate { sha256: prefetch.sha256 })
        };

        let cargo_toml_path = crate_path.join("Cargo.toml");
        debug!("cargo_toml: {:?}", cargo_toml_path);

        let mut f = std::fs::File::open(&cargo_toml_path).unwrap();
        let mut toml = String::new();
        f.read_to_string(&mut toml).unwrap();
        let mut v:toml::Value = toml::de::from_str(&toml).unwrap();
        let v = v.as_table_mut().unwrap();

        let crate_file = {
            if let Some(crate_file) = v.get("lib") {
                let crate_file = crate_file.as_table().unwrap();
                if let Some(lib_path) = crate_file.get("path") {
                    lib_path.as_str().unwrap().to_string()
                } else {
                    String::new()
                }
            } else {
                String::new()
            }
        };
        let lib_name = {
            if let Some(crate_file) = v.get("lib") {
                if let Some(name) = crate_file.get("name") {
                    name.as_str().unwrap().to_string()
                } else {
                    String::new()
                }
            } else {
                String::new()
            }
        };
        let bins = {
            if let Some(toml::Value::Array(bins)) = v.remove("bin") {
                bins.into_iter().map(|mut x| {
                    let bin = x.as_table_mut().unwrap();
                    Bin {
                        name: if let Some(toml::Value::String(s)) = bin.remove("name") { Some(s) } else { None },
                        path: if let Some(toml::Value::String(s)) = bin.remove("path") { Some(s) } else { None },
                    }
                }).collect()
            } else {
                Vec::new()
            }
        };
        let proc_macro = {
            if let Some(crate_file) = v.get("lib") {
                if let Some(&toml::Value::Boolean(proc_macro)) = crate_file.get("proc-macro") {
                    proc_macro
                } else {
                    false
                }
            } else {
                false
            }
        };

        let plugin = {
            if let Some(crate_file) = v.get("lib") {
                if let Some(&toml::Value::Boolean(plugin)) = crate_file.get("plugin") {
                    plugin
                } else {
                    false
                }
            } else {
                false
            }
        };

        let build = {
            let package = v.get("package").unwrap();
            if let Some(build) = package.as_table().unwrap().get("build") {
                build.as_str().unwrap().to_string()
            } else {
                String::new()
            }
        };

        let (dependencies, implied) = make_dependencies(&crate_path, v.get("dependencies"), v.get("features"));
        let (build_dependencies, build_implied) = make_dependencies(&crate_path, v.get("build-dependencies"), v.get("features"));
        debug!("dependencies {:?}", dependencies);
        let mut default_features = Vec::new();
        let mut declared_features = BTreeSet::new();

        if let Some(features) = v.get("features") {
            let features = features.as_table().unwrap();
            if let Some(default) = features.get("default") {
                default_features.extend(
                    default.as_array().unwrap().into_iter().map(|x| x.as_str().unwrap().to_string())
                )
            }
            for (f, _) in features.iter() {
                if f != "default" {
                    declared_features.insert(f.to_string());
                }
            }
        }

        let mut declared_dependencies = BTreeSet::new();
        if let Some(deps) = v.get("dependencies") {
            if let Some(deps) = deps.as_table() {
                for (f, _) in deps.iter() {
                    declared_dependencies.insert(f.clone());
                }
            }
        }
        if let Some(deps) = v.get("dev-dependencies") {
            if let Some(deps) = deps.as_table() {
                for (f, _) in deps.iter() {
                    declared_dependencies.insert(f.clone());
                }
            }
        }

        Ok(Meta {
            src: src,
            dependencies: dependencies,
            declared_dependencies: declared_dependencies,
            build_dependencies: build_dependencies,
            crate_file: crate_file,
            lib_name: lib_name,
            proc_macro: proc_macro,
            plugin: plugin,
            default_features: default_features,
            declared_features: declared_features,
            use_default_features: None,
            features: BTreeSet::new(),
            build: build,
            implied_features: implied,
            bins: bins
        })
    }
}

fn make_dependencies(base_path: &Path, deps: Option<&toml::Value>, features: Option<&toml::Value>) -> (BTreeMap<String, Dep>, Vec<ConditionalFeature>) {
    let mut dependencies = BTreeMap::new();
    let mut cond = Vec::new();
    if let Some(deps) = deps {
        for (name, dep) in deps.as_table().unwrap() {
            let name = name.to_string();
            debug!("dep {:?}", dep);
            if let Some(dep) = dep.as_table() {
                let enabled_features = if let Some(features) = dep.get("features") {
                    features
                        .as_array().unwrap()
                        .into_iter()
                        .map(|x| x.as_str().unwrap().to_string())
                        .collect()
                } else {
                    Vec::new()
                };
                let path = if let (Some(path), None) = (dep.get("path"), dep.get("version")) {
                    Some(path.as_str().unwrap().to_string())
                } else {
                    None
                };

                let mut dep = Dep {
                    cr: Crate::default(),
                    path: if let Some(path) = path {
                        Some(base_path.join(path))
                    } else {
                        None
                    },
                    features: enabled_features,
                    default_features: dep.get("default-features").map(|x| x.as_bool().unwrap()).unwrap_or(true),
                    conditional_features: Vec::new(),
                };
                dep.cr.name.push_str(&name);
                dependencies.insert(name, dep);
            }
        }
    }

    if let Some(features) = features {
        for (a, b) in features.as_table().unwrap().iter() {
            // println!("a {:?}, b {:?}", a, b);
            for b in b.as_array().unwrap() {
                if let Some(b) = b.as_str() {
                    let mut b = b.split('/');
                    match (b.next(), b.next()) {
                        (Some(c), Some(d)) => {
                            if let Some(dep) = dependencies.get_mut(c) {
                                debug!("conditional: {:?} {:?} {:?}", c, a, d);
                                dep.conditional_features.push(ConditionalFeature {
                                    feature: a.to_string(),
                                    dep_feature: d.to_string()
                                })
                            }
                        }
                        (Some(c), None) => {
                            // println!("conditional: {:?} {:?} {:?}", c, a, d);
                            cond.push(ConditionalFeature {
                                feature: a.to_string(),
                                dep_feature: c.to_string()
                            })
                        }
                        _ => {}
                    }
                }
            }
        }
    }

    (dependencies, cond)
}


fn main() {
    env_logger::init().unwrap_or(());
    let matches = App::new("generate-nix-pkg")
        .version("0.1")
        .author("pmeunier <pe@pijul.org>")
        .about("Generate a nix derivation set from a cargo registry")
        .arg(Arg::with_name("lockfile")
             .value_name("LOCKFILE")
             .help("Input Cargo.lock file")
             .required(true)
             .takes_value(true))
        .arg(Arg::with_name("src")
             .long("--src")
             .help("Source of the main project")
             .takes_value(true))
        .arg(Arg::with_name("indirection")
             .long("--indirection")
             .short("-i")
             .help("Write top level indirections i.e. `void = void_1_0_2;`"))
        .arg(Arg::with_name("minimal_imports")
             .long("--minimal_imports")
             .short("-m")
             .help("Write `{ build-rust-package, fetchzip, verbose, release }:` instead of `with import <nixpkgs> {};`"))
        .arg(Arg::with_name("target")
             .value_name("TARGET")
             .long("--output")
             .short("-o")
             .help("Output of this command (a nix file)")
             .takes_value(true))
        .get_matches();

    let mut cr = Path::new(matches.value_of("lockfile").unwrap()).to_path_buf();
    let indirection = matches.is_present("indirection");
    let minimal_imports = matches.is_present("minimal_imports");
    let mut lock: toml::Value = {
        let mut lockfile = std::fs::File::open(&cr).unwrap();
        let mut toml = String::new();
        lockfile.read_to_string(&mut toml).unwrap();
        toml::de::from_str(&toml).unwrap()
    };

    let packages = lock.as_table_mut().unwrap().remove("package").unwrap();
    let packages = packages.as_array().unwrap();

    cr.set_extension("toml");

    let (mut deps, cond) = {
        let mut cargofile = std::fs::File::open(&cr).unwrap();
        let mut toml = String::new();
        cargofile.read_to_string(&mut toml).unwrap();
        let v:toml::Value = toml::de::from_str(&toml).unwrap();
        let v = v.as_table().unwrap();

        make_dependencies(cr.parent().unwrap(), v.get("dependencies"), v.get("features"))
         // make_dependencies(cr.parent().unwrap(), v.get("dev-dependencies"), v.get("features")))
    };

    debug!("main deps: {:?} {:?}", cr, deps);

    let ver_re = Regex::new(r"(\d*)\.(\d*)\.(\d*)(-(\S*))?").unwrap();

    // Loading the cache (a map between package versions and Nix store paths).
    let mut cache_path = std::env::home_dir().unwrap();
    cache_path.push(".cargo");
    std::fs::create_dir_all(&cache_path).unwrap();
    cache_path.push("nix-cache");
    let mut cache = Cache::new(&cache_path);

    // Compute the meta-information for all packages in the lock file.
    let base_path = cr.parent().unwrap();
    debug!("base_path: {:?}", base_path);

    let mut all_packages = BTreeMap::new();

    let mut unknown_packages = Vec::new();
    // Here we need to compute a fixpoint of dependencies to resolve
    // all sources. This is because local sources are sometimes
    // referenced not only from this package's Cargo.toml, but from
    // this package's (transitive) dependencies, in which case the
    // only way to know where they are is to go down the dependency
    // tree (because they are not in the Cargo.lock).
    let mut packages_fixpoint = packages.clone();
    while packages_fixpoint.len() > 0 {
        for package in packages_fixpoint.drain(..) {

            let (a, b, c, d) = {
                let version = package.as_table().unwrap().get("version").unwrap().as_str().unwrap();
                let cap = ver_re.captures(&version).unwrap();
                (cap.get(1).unwrap().as_str().parse().unwrap(),
                 cap.get(2).unwrap().as_str().parse().unwrap(),
                 cap.get(3).unwrap().as_str().parse().unwrap(),
                 cap.get(5).map(|x| x.as_str().to_string()).unwrap_or(String::new()))
            };

            let name = package.as_table().unwrap().get("name").unwrap().as_str().unwrap().to_string();
            let source_is_crates_io =
                package.as_table().unwrap().get("source").and_then(|x| x.as_str()) == Some("registry+https://github.com/rust-lang/crates.io-index");
            debug!("name = {:?}", name);

            let cra = Crate {
                major: a, minor: b, patch: c, subpatch: d,
                vsn: format!("{}{}{}", a, b, c).parse::<usize>().unwrap(),
                name: name
            };

            let meta = {
                debug!("deps: {:?}", deps);
                let path = if let Some(ref dep) = deps.get(&cra.name) {
                    if let Some(ref p) = dep.path {
                        debug!("path {:?}", p);
                        Some(Path::new(p))
                    } else {
                        None
                    }
                } else {
                    None
                };

                if path.is_some() || source_is_crates_io {
                    cra.prefetch(&mut cache, path).ok()
                } else {
                    None
                }
            };
            if let Some(mut meta) = meta {

                for (a, b) in meta.dependencies.iter().chain(meta.build_dependencies.iter()) {
                    deps.insert(a.to_string(), b.clone());
                }


                if let Some(deps) = package.get("dependencies") {
                    update_deps(&cra, deps, &mut meta)
                }
                if let Some(deps) = package.get("build-dependencies") {
                    update_deps(&cra, deps, &mut meta)
                }

                all_packages.insert(cra, meta);
            } else {
                unknown_packages.push(package)
            }
        }
        std::mem::swap(&mut packages_fixpoint, &mut unknown_packages)
    }

    // Adding the root crate, the one we're compiling.
    let root = lock.as_table_mut().unwrap().remove("root").unwrap();
    let root = root.as_table().unwrap();
    let version = root.get("version").unwrap().as_str().unwrap();
    let (a, b, c, d) = {
        let cap = ver_re.captures(&version).unwrap();
        (cap.get(1).unwrap().as_str().parse().unwrap(),
         cap.get(2).unwrap().as_str().parse().unwrap(),
         cap.get(3).unwrap().as_str().parse().unwrap(),
         cap.get(5).map(|x| x.as_str().to_string()).unwrap_or(String::new()))
    };
    let name = root.get("name").unwrap().as_str().unwrap().to_string();
    debug!("name = {:?}", name);
    if let Some(dep) = deps.get(&name) {
        debug!("dep = {:?}", dep);
    }
    let main_cra = Crate {
        major: a, minor: b, patch: c, subpatch: d,
        vsn: format!("{}{}{}", a, b, c).parse::<usize>().unwrap(),
        name: name
    };
    let mut meta = {
        let path = Some(base_path);
        let meta = main_cra.prefetch(&mut cache, path).unwrap();
        meta
    };

    debug!("root = {:?}", root);
    if let Some(deps) = root.get("dependencies") {
        update_deps(&main_cra, deps, &mut meta)
    }
    if let Some(deps) = root.get("build-dependencies") {
        update_deps(&main_cra, deps, &mut meta)
    }

    all_packages.insert(main_cra.clone(), meta);

    // Now resolve all features.
    resolve_features(&main_cra, &mut all_packages);

    // And output.
    let mut nix_file:Box<Write> = if let Some(nix) = matches.value_of("target") {
        Box::new(BufWriter::new(std::fs::File::create(nix).unwrap()))
    } else {
        Box::new(BufWriter::new(std::io::stdout()))
    };
    if minimal_imports {
        nix_file.write_all(b"{ build-rust-package, fetchzip, release, verbose }:
let
").unwrap();
    } else {
        nix_file.write_all(b"with import <nixpkgs> {};
let release = true;
    verbose = true;
").unwrap();
    }
    for (cra, meta) in all_packages.iter() {
        cra.output_package(&mut nix_file, 4, &meta).unwrap()
    }
    nix_file.write_all(b"\nin\nrec {\n").unwrap();
    for (cra, meta) in all_packages.iter() {
        cra.output_package_call(&mut nix_file, 2, &meta).unwrap();
    }
    if indirection {
        // Work out `crate_name = crate_name_x_y_z` only if cli -i arg says so
        let indirections = resolve_latest_indirection(&all_packages);
        for (_, cra) in indirections.iter() {
            cra.output_toplevel_indirection(&mut nix_file, 2).unwrap();
        }
    }

    nix_file.write_all(b"}\n").unwrap();
}

fn update_deps(cra: &Crate, deps:&toml::Value, meta: &mut Meta)  {
    let dep_re = Regex::new(r"^(\S*) (\d*)\.(\d*)\.(\d*)(-(\S*))?").unwrap();
    for dep in deps.as_array().unwrap() {
        let dep = dep.as_str().unwrap();
        let cap = dep_re.captures(&dep).unwrap();
        if cap.get(1).unwrap().as_str() != cra.name {
            let (a, b, c, d) = {
                (cap.get(2).unwrap().as_str().parse().unwrap(),
                 cap.get(3).unwrap().as_str().parse().unwrap(),
                 cap.get(4).unwrap().as_str().parse().unwrap(),
                 cap.get(6).map(|x| x.as_str().to_string()).unwrap_or(String::new()))
            };
            let name = cap.get(1).unwrap().as_str().to_string();
            let mut entry = meta.dependencies.entry(name.clone()).or_insert(Dep::default());
            entry.cr.major = a;
            entry.cr.minor = b;
            entry.cr.patch = c;
            entry.cr.subpatch = d;
            entry.cr.vsn = format!("{}{}{}", a, b, c).parse::<usize>().unwrap();
            entry.cr.name = name;
            entry.default_features = true;
        }
    }
}

fn resolve_features(cr: &Crate, packages: &mut BTreeMap<Crate, Meta>) {
    debug!("cr: {:?}", cr);
    if cr.name.len() == 0 {
        return
    }
    let dependencies = if let Some(package) = packages.get(cr){
        package.dependencies.clone().into_iter().filter(|&(_, ref dep)| {
            packages.get(&dep.cr).is_some()
        }).collect()
    } else {
        BTreeMap::new()
    };
    packages.get_mut(cr).unwrap().dependencies = dependencies.clone();

    {
        let meta = packages.get_mut(cr).unwrap();

        match meta.use_default_features {
            Some(false) => {},
            _ => {
                for i in meta.default_features.iter() {
                    if meta.declared_dependencies.get(i).is_none()
                        || meta.dependencies.get(i).is_some() {

                        meta.features.insert(i.clone());
                    }
                }
            }
        }

        debug!("meta: {:?}", meta.implied_features);
        let mut feature_added = true;
        while feature_added {
            feature_added = false;
            for cond in meta.implied_features.iter() {

                debug!("feature: {:?}", meta.features);
                debug!("declared_feature: {:?}", meta.declared_features);
                debug!("dependencies: {:?}", meta.dependencies);
                // If we have that feature.
                if meta.features.get(&cond.feature).is_some()
                    && meta.features.get(&cond.dep_feature).is_none()
                    && (meta.declared_dependencies.get(&cond.dep_feature).is_none()
                        || meta.dependencies.get(&cond.dep_feature).is_some()) {

                        meta.features.insert(cond.dep_feature.clone());
                        feature_added = true
                    }
            }
        }
    }

    for (_, dep) in dependencies.iter() {

        // Default features
        if !dep.default_features {
            if let Some(d) = packages.get_mut(&dep.cr) {
                d.use_default_features = if let Some(true) = d.use_default_features {
                    Some(true)
                } else {
                    Some(false)
                }
            }
        }

        for f in dep.features.iter() {
            debug!("{:?} -> {:?}.{:?}", cr, dep.cr, f);
            if let Some(d) = packages.get_mut(&dep.cr) {
                if d.declared_dependencies.get(f.as_str()).is_none()
                    || d.dependencies.get(f.as_str()).is_some() {
                    d.features.insert(f.clone());
                }
            }
        }

        for f in dep.conditional_features.iter() {

            if packages.get(&cr).unwrap().features.get(&f.feature).is_some() {

                debug!("{:?} -> {:?}.{:?}", cr, dep.cr, f);
                if let Some(d) = packages.get_mut(&dep.cr) {

                    // If this feature either is not a dependency, or is enabled.
                    if d.declared_dependencies.get(&f.dep_feature).is_none()
                        || d.dependencies.get(&f.dep_feature).is_some() {

                        d.features.insert(f.dep_feature.clone());
                    }
                }
            }
        }

        resolve_features(&dep.cr, packages)
    }

}

fn resolve_latest_indirection(packages: &BTreeMap<Crate, Meta>) -> BTreeMap<String, &Crate> {
    let mut indirections = BTreeMap::<String, &Crate>::new();
    for (cra, _) in packages.iter() {
        let name = &cra.name;
        let key_present = indirections.contains_key(name);
        if key_present == false {
            indirections.insert(name.to_owned(), cra);
        } else {
            if let Some(ind_cra) = indirections.get_mut(name) {
                if cra.vsn > ind_cra.vsn {
                    debug!("{}-{} > {}-{}", cra.name, cra.vsn, ind_cra.name, ind_cra.vsn );
                    *ind_cra = cra;
                }
            }
        }
    }
    indirections
}
