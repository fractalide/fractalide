extern crate capnp;

#[macro_use]
extern crate rustfbp;

component! {
    clone,
    inputs(input: any),
    inputs_array(),
    outputs(),
    outputs_array(clone: any),
    option(),
    acc(),
    fn run(&mut self) {

        // Get the path
        let mut ip = self.ports.recv("input".into()).expect("file_open : unable to receive from input");

        for p in self.ports.get_output_selections("clone").expect("no clone output") {
            self.ports.send_array("clone".into(), p, ip.clone()).expect("clone : cannot send ");
        }
    }
}
