#[macro_use]
extern crate rustfbp;

#[macro_use]
extern crate log;

use std::fs::File;

agent! {
    // input(input: prim_u64),
    // output(output: prim_u64),
    rsinput(a: bool, b: bool, input: Pair),
    rsoutput(res: bool, output: Pair),
    fn run(&mut self) -> Result<Signal> {
        debug!("{:?}", env!("CARGO_PKG_NAME"));
        println!("Ok");
        // let (act, msg) = self.rsinput.input.recv_with_action()?;
        let a = self.rsinput.a.recv()?;
        let b = self.rsinput.b.recv()?;
        let res = ! (a && b);
        println!("{} {} -> {}", a, b, res);
        self.rsoutput.res.send(res)?;
        // self.rsoutput.output.send(msg)?;
        Ok(End)
    }
}
