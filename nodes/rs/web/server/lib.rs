#[macro_use]
extern crate rustfbp;
extern crate iron;
extern crate mount;
extern crate staticfile;


use iron::status;
use iron::Iron;
use mount::Mount;
use staticfile::Static;
use std::path::Path;


agent! {
    web_server, edges(path, domain_port, url)
    inputs(www_dir: path, domain_port: domain_port, url: url),
    inputs_array(),
    outputs(),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
debug!("{:?}", env!("CARGO_PKG_NAME"));
        let mut ip = try!(self.ports.recv("www_dir"));
        let www_dir: path::Reader = try!(ip.read_schema());
        let www_dir = try!(www_dir.get_path());

        let mut url_ip = try!(self.ports.recv("url"));
        let url: url::Reader = try!(url_ip.read_schema());
        let url = try!(url.get_url());

        let mut domain_ip = try!(self.ports.recv("domain_port"));
        let domain_port: domain_port::Reader = try!(domain_ip.read_schema());
        let domain_port = try!(domain_port.get_domain_port());

        let mut mount = Mount::new();
        mount.mount(url, Static::new(Path::new(www_dir)));
        Iron::new(mount).http(domain_port).unwrap();
        Ok(())
    }
}
