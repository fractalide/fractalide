#[macro_use]
extern crate rustfbp;
extern crate iron;
extern crate mount;
extern crate staticfile;
extern crate capnp;

use iron::status;
use iron::Iron;
use mount::Mount;
use staticfile::Static;
use std::path::Path;


component! {
    clone, contracts(path, domain_port, url)
    inputs(www_dir: path, domain_port: domain_port, url: url),
    inputs_array(),
    outputs(),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip = try!(self.ports.recv("www_dir"));
        let www_dir: path::Reader = try!(ip.get_root());
        let www_dir = try!(www_dir.get_path());

        let mut url_ip = try!(self.ports.recv("url"));
        let url: url::Reader = try!(url_ip.get_root());
        let url = try!(url.get_url());

        let mut domain_ip = try!(self.ports.recv("domain_port"));
        let domain_port: domain_port::Reader = try!(domain_ip.get_root());
        let domain_port = try!(domain_port.get_domain_port());

        let mut mount = Mount::new();
        mount.mount(url, Static::new(Path::new(www_dir)));
        Iron::new(mount).http(domain_port).unwrap();
        Ok(())
    }
}
