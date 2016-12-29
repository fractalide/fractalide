# Nodes collection

The `Nodes` collection consists of `Subgraphs` and `Agents`. A `Subgraph` or an `Agent` may be referred to as a `Node`.

## Subgraphs

### What?

A `Subgraph` consists of an implementation and an interface. The interface is implemented using a simple `interface description language` called `Flowscript` which describes how data flows through `Agents` and other `Subgraphs`. The result is an interface that consists of a minimal set of well named `ports`, thus hiding complexity.

A simple analogy would be this gentleman's pocket watch.

![Image Alt](http://www.kirkwood.edu/pdf/uploaded/835/watchcalls_35.gif)

### Why?

Composition is an important part of programming, allowing one to hide implementation detail.

### Who?

People who want to focus on the Science tend to work at these higher abstractions, they'd prefer not getting caught up in the details of programming low level nodes and hand specifications to programmers who'll make efficient, reusable and safe `Agents`. Though programmers will find `Subgraphs` indispensable as they allow for powerful abstractions.

### Where?

The `Nodes` directory is where all `Agents` and `Subgraphs` go. Typically one might structure a hierarchy like such:

```
── wrangle
   ├── default.nix <------
   ├── aggregate
   ├── anonymize
   ├── print
   ├── processchunk
   │   ├── default.nix <------
   │   ├── agg_chunk_triples
   │   ├── convert_json_vector
   │   ├── extract_keyvalue
   │   ├── file_open
   │   └── iterate_paths
   └── stats
```

See the above `default.nix` files? Those are `Subgraphs` and they hide the entire directory level they reside in from higher levels in the hierarchy. Thus `processchunk` (a `Subgraph`) looks like yet another `Node` to `wrangle` (another `Subgraph`). Indeed `wrangle` is completely unable to distinguish between an `Agent` and a `Subgraph`.

### How?

The `Subgraph` `default.nix` requires you make decisions about two types of dependencies.
* What `Nodes` are needed?
* What `Edges` are needed?

``` nix
{ subgraph, nodes, edges }:

subgraph {
  src = ./.;
  edges = with edges; [ ];
  flowscript = with nodes; with edges; ''
    nand(${maths_boolean_nand})
    '${prim_bool}:(boolean=true)' -> a nand()
    '${prim_bool}:(boolean=true)' -> b nand()
    nand() output -> input io_print(${maths_boolean_print})
  '';
}
```

![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/subnet_ex10.png)

* The `{ subgraph, nodes, edges }:` lambda passes in three arguments, the `subgraph` builder, `edges` which consists of every `Edge` or `Edge Namespace`, and the `nodes` argument which consists of every `Node` and `Node Namespace` in the system.
* The `subgraph` building function accepts these arguments:
  * The `src` attribute is used to derive a `Subgraph` name based on location in the directory hierarchy.
  * The `edges` attribute works out the transitive dependencies of each `exposed edge` or `imsg` (initial message).
  * The `flowscript` attribute defines the business logic. Here data flowing through a system becomes a first class citizen that can be manipulated. `Nodes` and `Edges` are brought into scope between the opening '' and closing '' double single quotes by using the `with nodes; with edges;` syntax.
* `Nix` assists us greatly, in that each `node` name (the stuff between the curly quotes ``${...}``) undergoes a compilation step resolving every name into an absolute `/path/to/compiled/lib.subgraph` text file and `/path/to/compiled/libagent.so` shared object.
* This compilation is lazy and only referenced names will be compiled. In other words `Subgraph` could be a top level `Subgraph` of a many layer deep hierarchy and only referenced `Nodes` will be compiled in a lazy fashion, *not* the entire `fractalide/nodes` folder.

This is the output of the above `Subgraph`'s compilation:
```
$ cat /nix/store/1syrjhi6jvbvs5rvzcjn4z3qkabwss7m-test_sjm/lib/lib.subgraph
nand(/nix/store/7yzx8fp81fl6ncawk2ag2nvfc5l950xb-maths_boolean_nand)
'/nix/store/fx46blm272yca7n3gdynwxgyqgw90pr5-prim_bool:(boolean=true)' -> a nand()
'/nix/store/fx46blm272yca7n3gdynwxgyqgw90pr5-prim_bool:(boolean=true)' -> b nand()
nand() output -> input io_print(/nix/store/k67wiy6z4f1vnv35vdyzcqpwvp51j922-maths_boolean_print)
```

Mother of the Flying Spaghetti Monster, what is that? One really doesn't need to be concerned about this target, as it's meant to be processed by the `Fractalide Virtual Machine`. It's worth noting that those hashes hint at something powerful. Projects like `docker` and `git` implement this type of content addressable store. Except `docker`'s granularity is at container level, and `git`'s granularity is at revision level. Our granularity is at package or library level. It allows for reproducible, deterministic systems, instead of copying around "zipped" archives, that quickly max out your hard drive.

### Flowscript syntax is easy

Everything between the opening `''` and closing `''` is `flowscript`, i.e:
``` nix
{ subgraph, nodes, edges }:

subgraph {
  src = ./.;
  edges = with edges; [ ];
  flowscript = with nodes; with edges; ''
                       <---- here
  '';
}
```
![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/subnet_ex0.png)


#### Agent initialization:
``` nix
{ subgraph, nodes, edges }:

subgraph {
  src = ./.;
  edges = with edges; [ ];
  flowscript = with nodes; with edges; ''
    agent_name(${name_of_agent})
  '';
}
```
![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/subnet_ex1.png)

#### Referencing a previously initialized agent (with a comment):
``` nix
{ subgraph, nodes, edges }:

subgraph {
  src = ./.;
  edges = with edges; [ ];
  flowscript = with nodes; with edges; ''
    agent_name(${name_of_agent}) // <──┐
    agent_name()                 // <──┴─ same instance
  '';
}
```
![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/subnet_ex1.png)

#### Connecting and initializing two agents:
``` nix
{ subgraph, nodes, edges }:

subgraph {
  src = ./.;
  edges = with edges; [ ];
  flowscript = with nodes; with edges; ''
    agent1(${name_of_agent1}) output_port -> input_port agent2(${name_of_agent2})
  '';
}
```
![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/subnet_ex3.png)

#### Creating an [Exposed Edge](../edges/README.md)
``` nix
{ subgraph, nodes, edges }:

subgraph {
  src = ./.;
  edges = with edges; [ prim_bool ];
  flowscript = with nodes; with edges; ''
    '${prim_bool}:(boolean=true)' -> a agent(${name_of_agent})
  '';
}
```
![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/subnet_ex4.png)

#### More complex Exposed Edge
``` nix
{ subgraph, edges, nodes }:

subgraph {
  src = ./.;
  edges = with edges; [ js_create ];
  flowscript = with edges; with nodes; ''
    td(${ui_js_nodes.flex})
    '${js_create}:(type="div", style=[(key="display", val="flex"), (key="flex-direction", val="column")])~create' -> input td()
  '';
}
```
![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/subnet_ex5.png)

[Learn](../edges/README.md) more about `Edges`.
#### Creating an subgraph input port
``` nix
{ subgraph, nodes, edges }:

subgraph {
  src = ./.;
  edges = with edges; [ ];
  flowscript = with nodes; with edges; ''
    subgraph_input => input agent(${name_of_agent})
  '';
}
```
![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/subnet_ex6.png)

#### Creating an subgraph output port
``` nix
{ subgraph, nodes, edges }:

subgraph {
  src = ./.;
  edges = with edges; [ ];
  flowscript = with nodes; with edges; ''
    agent(${name_of_agent}) output => subgraph_output
  '';
}
```
![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/subnet_ex7.png)

#### Subgraph initialization:
``` nix
{ subgraph, nodes, edges }:

subgraph {
  src = ./.;
  edges = with edges; [ ];
  flowscript = with nodes; with edges; ''
    subgraph(${name_of_subgraph})
  '';
}
```
![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/subnet_ex8.png)

#### Initializing a subgraph and agent then connecting them:
``` nix
{ subgraph, nodes, edges }:

subgraph {
  src = ./.;
  edges = with edges; [ ];
  flowscript = with nodes; with edges; ''
    subgraph(${name_of_subgraph})
    agent(${name_of_agent})
    subgraph() output -> input agent()
  '';
}
```
![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/subnet_ex9.png)

#### Output array port:
``` nix
{ subgraph, nodes, edges }:

subgraph {
  src = ./.;
  edges = with edges; [ ];
  flowscript = with nodes; with edges; ''
    db_path => input clone(${msg_clone})
    clone() clone[0] => db_path0
    clone() clone[1] => db_path1
    clone() clone[2] => db_path2
    clone() clone[3] => db_path3
  '';
}
```
![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/subnet_ex11.png)

Note the `clone[1]`, this is an `array output port` and in this particular `Subgraph` `Messages` are being replicated, a copy for each port element. The content between the `[` and `]` is a string, so don't be misled by the integers. There are two types of node ports, a `simple port` (which doesn't have array elements) and an `array port` (with array elements).

#### Input array port:
``` nix
{ subgraph, nodes, edges }:

subgraph {
  src = ./.;
  edges = with edges; [ ];
  flowscript = with nodes; with edges; ''
    add0 => add[0] adder(${path_to_adder})
    add1 => add[1] adder()
    add2 => add[2] adder()
    add3 => add[3] adder() output -> output
  '';
}
```
![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/subnet_ex15.png)

`Array ports` are used when the number of ports are unknown at `Agent` development time, but known when the `Agent` is used in a `Subgraph`. The `adder` `Agent` demonstrates this well, it has an `array input port` which allows `Subgraph` developers to choose how many integers they want to add together. It really doesn't make sense to implement an adder with two fixed simple input ports then be constrained when you need to add three numbers together.

#### Hierarchical naming:
``` nix
{ subgraph, nodes, edges }:

subgraph {
  src = ./.;
  edges = with edges; [ ];
  flowscript = with nodes; with edges; ''
    input => input clone(${msg_clone})
    clone() clone[0] -> a nand(${maths_boolean_nand})
    clone() clone[1] -> b nand() output => output
  '';
}
```
![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/subnet_ex13.png)

The `Node` and `Edge` names, i.e.: `${maths_boolean_nand}` seem quite long. Fractalide uses a hierarchical naming scheme. So you can find the `maths_boolean_not` node by going to the [maths/boolean/not](./maths/boolean/not/default.nix) directory. The whole goal of this is to avoid name shadowing among potentially hundreds to thousands of nodes.

Explanation of the `Subgraph`:

This `Subgraph` takes an input of `Hidden Edge` type [prim_bool](../edges/maths/boolean/default.nix) over the `input` port. A `Message` is cloned by the `clone` node and the result is pushed out on the `array output port` `clone` using elements `[0]` and `[1]`. The `nand()` node then performs a `NAND` boolean logic operation and outputs a `prim_bool` data type, which is then sent over the `Subgraph` output port `output`.

The above implements the `not` boolean logic operation.

#### Abstraction powers:
``` nix
{ subgraph, nodes, edges }:

subgraph {
  src = ./.;
  edges = with edges; [ prim_bool ];
  flowscript = with nodes; with edges; ''
    '${prim_bool}:(boolean=true)' -> a nand(${maths_boolean_nand})
    '${prim_bool}:(boolean=true)' -> b nand()
    nand() output -> input not(${maths_boolean_not})
    not() output -> input print(${maths_boolean_print})
  '';
}
```
![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/subnet_ex14.png)

Notice we're using the `not` node implemented earlier. One can build hierarchies many layers deep without suffering a run-time performance penalty. Once the graph is loaded into memory, all `Subgraphs` fall away, like water, after an artificial gravity generator engages, leaving only `Agents` connected to `Agents`.

#### Namespaces
``` nix
{ subgraph, nodes, edges }:

subgraph {
  src = ./.;
  edges = with edges; [ ];
  flowscript = with nodes; with edges; ''
    listen => listen http(${net_http_nodes.http})
    db_path => input clone(${msg_clone})
    clone() clone[1] -> db_path get(${app_todo_nodes.todo_get})
    clone() clone[2] -> db_path post(${app_todo_nodes.todo_post})
    clone() clone[3] -> db_path del(${app_todo_nodes.todo_delete})
    clone() clone[4] -> db_path patch(${app_todo_nodes.todo_patch})

    http() GET[/todos/.+] -> input get() response -> response http()
    http() POST[/todos/?] -> input post() response -> response http()
    http() DELETE[/todos/.+] -> input del() response -> response http()
    http() PATCH[/todos/.+] -> input patch()
    http() PUT[/todos/.+] -> input patch() response -> response http()
  '';
}
```
![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/subnet_ex12.png)

Notice the `net_http_nodes` and `app_todo_nodes` namespaces. Some [fractals](../fractals/README.md) deliberately export a collection of `Nodes`. As is the case with the `net_http_nodes.http` node.
When you see a `fullstop` `.`, i.e. `xxx_nodes.yyy` you immediately know this is a namespace. It's also a programming convention to use the `_nodes` suffix.
Lastly, notice the advanced usage of `array ports` with this example: `GET[/todos/.+]`, the element label is actually a `regular expression` and the implementation of that node is slightly more [advanced](https://github.com/fractalide/fractal_net_http/blob/master/nodes/http/src/lib.rs#L149)!

## Agents

### What?

Executable `Subgraphs` are defined as a network of `Agents`, which exchange typed data across predefined connections by message passing, where the connections are specified externally to the processes. These `Agents`  can be reconnected endlessly to form different executable `Subgraphs` without having to be changed internally.

### Why?

Functions in a programming language should be placed in a content addressable store, this is the horizontal plane. The vertical plane should be constructed using unique addresses into this content addressable store, critically each address should solve a single problem, and may do so by referencing multiple other unique addresses in the content addressable store. Users must not have knowledge of these unique addresses but a translation process should occur from a human readable name to a universally unique address. Read [more](http://erlang.org/pipermail/erlang-questions/2011-May/058768.html) about the problem.

Once you have the above, you have truly reusable functions. Fractalide nodes are just this, and it makes the below so much easier to achieve:
```
* Open source collaboration
* Open peer review of nodes
* Nice clean reusable nodes
* Reproducible applications
```

### Who?

Typically programmers will develop `Agents`. They specialize in making `Agents` as efficient and reusable as possible, while people who focus on the Science give the requirements and use the `Subgraphs`. Just as a hammer is designed to be reused, so `Subgraphs` and `Agents` should be designed for reuse.

### Where?

The `Agents` are found in this `nodes` directory, or the `nodes` directory of a [fractal](../fractals/README.md).

```
processchunk
├── default.nix
├── agg_chunk_triples
│   ├── default.nix <---
│   └── lib.rs
├── convert_json_vector
│   ├── default.nix <---
│   └── lib.rs
├── extract_keyvalue
│   ├── default.nix <---
│   └── lib.rs
├── file_open
│   ├── default.nix <---
│   └── lib.rs
└── iterate_paths
    ├── default.nix <---
    └── lib.rs
```
Typically when you see a `lib.rs` in the same directory as a `default.nix` you know it's an `Agent`.

### How?

An `Agent` consists of two parts:
* a `nix` `default.nix` file that sets up an environment to satisfy `rustc`.
* a `rust` `lib.rs` file implements your `agent`.

#### The `agent` Nix function.

The `agent` function in the `default.nix` requires you make decisions about three types of dependencies.
* What `edges` are needed?
* What `crates` from [crates.io](https://crates.io) are needed?
* What `osdeps` or `operating system level dependencies` are needed?

``` nix
{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ prim_bool ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [ openssl ];
}
```

* The `{ agent, edges, crates, pkgs }:` lambda imports: The `edges` attribute which consists of every `edge` available on the system. The `crates` attribute set consists of every `crate` on https://crates.io. Lastly the `pkgs` pulls in every third party package available on NixOS, here's the whole [list](http://nixos.org/nixos/packages.html).
* The `agent` function builds the rust `lib.rs` source code, and accepts these arguments:
  * The `src` attribute is used to derive an `Agent` name based on location in the directory hierarchy.
  * The `edges` lazily compiles schema and composite schema ensuring their availability.
  * The `crates` specifies exactly which `crates` are needed in scope.
  * The `osdeps` specifies exactly which `pkgs`, or third party `operating system level libraries` such as `openssl` needed in scope.

Only specified dependencies and their transitive dependencies will be pulled into scope once the `agent` compilation starts.

This is the output of the above `agent`'s compilation:

```
/nix/store/dp8s7d3p80q18a3pf2b4dk0bi4f856f8-maths_boolean_nand
└── lib
    └── libagent.so
```

#### The `agent!` Rust macro

This is the heart of `Fractalide`. Everything revolves around this `API`. The below is an implementation of the `${maths_boolean_nand}` `agent` seen earlier.

``` rust
#[macro_use]
extern crate rustfbp;
extern crate capnp;

agent! {
  input(a: prim_bool, b: prim_bool),
  output(output: prim_bool),
  fn run(&mut self) -> Result<Signal> {
    let a = {
      let mut ip_a = self.input.a.recv()?;
      let a_reader: prim_bool::Reader = ip_a.read_schema()?;
      a_reader.get_boolean()
    };
    let b = {
      let mut ip_b = self.input.b.recv()?;
      let b_reader: prim_bool::Reader = ip_b.read_schema()?;
      b_reader.get_boolean()
    };

    let mut out_ip = IP::new();
    {
      let mut boolean = out_ip.build_schema::<prim_bool::Builder>();
      boolean.set_boolean(if a == true && b == true {false} else {true});
    }
    self.output.output.send(out_ip)?;
    Ok(End)
  }
}
```

An explanation of each of the items should be given.
All expresions are optional except for the `run` function.

##### `input`:
``` rust
agent! {
  input(input_name: prim_bool),
  fn run(&mut self) -> Result<Signal> {
    let a = {
      let mut a_msg = self.input.input_name.recv()?;
      let a_reader: prim_bool::Reader = a_msg.read_schema()?;
      a_reader.get_boolean()
    };
    Ok(End)
  }
}
```
The `input` port, is a bounded buffer simple input channel that carries Cap'n Proto schemas as messages.

##### `inarr`:
``` rust
agent! {
  inarr(input_array_name: prim_bool),
  fn run(&mut self) -> Result<Signal> {
    for ins in self.inarr.input_array_name.values() {
      let a = {
        let mut a_msg = ins.recv()?;
        let a_reader: prim_bool::Reader = a_msg.read_schema()?;
        a_reader.get_boolean()
      };
    }
    Ok(End)
  }
}
```
The `inarr` is an input array port, which consists of multiple elements of a port.
They are used when the `Subgraph` developer needs multiple elements of a port, for example an `adder` has multiple input elements. This `adder` `agent` may be used in many scenarios where the amount of inputs are unknown at `agent development time`.

##### `output`:
``` rust
agent! {
  output(output_name: prim_bool),
  fn run(&mut self) -> Result<Signal> {
    let mut msg_out = msg::new();
    {
      let mut boolean = msg_out.build_schema::<prim_bool::Builder>();
      boolean.set_boolean(true);
    }
    self.output.output_name.send(msg_out)?;
    Ok(End)
  }
}
```
The humble simple output port. It doesn't have elements and is fixed at `subgraph development time`.
##### `outarr`:
``` rust
agent! {
  input(input: any),
  outarr(clone: any),
  fn run(&mut self) -> Result<Signal> {
    let msg = self.input.input.recv()?;
    for p in self.outarr.clone.elements()? {
        self.outarr.clone.send( &p, msg.clone())?;
    }
    Ok(End)
  }
}
```
The `outarr` port is an `output array port`. It contains elements which may be expanded at `subgraph development time`.

##### `portal`:
``` rust
#[macro_use]
extern crate rustfbp;
extern crate capnp;
extern crate nanomsg;

use nanomsg::{Socket, Protocol};
pub struct Portal {
    socket: Option<Socket>,
}

impl Portal {
    fn new() -> Portal {
        Portal {
            socket: None,
        }
    }
}

agent! {
  input(connect: prim_text, ip: any),
  portal(Portal => Portal::new()),
  fn run(&mut self) -> Result<Signal> {
    if let Ok(mut ip) = self.inputs.connect.try_recv() {
        let reader: prim_text::Reader = ip.read_schema()?;
        let mut socket = Socket::new(Protocol::Push)
            .or(Err(result::Error::Misc("Cannot create socket".into())))?;
        socket.bind(reader.get_text()?)
            .or(Err(result::Error::Misc("Cannot connect socket".into())))?;
        self.portal.socket = Some(socket);
    }

    if let Ok(ip) = self.inputs.ip.try_recv() {
        if let Some(ref mut socket) = self.portal.socket {
            socket.write(&ip.vec[..]);
        }
    }
    Ok(End)
  }
}
```
![Image Alt](https://lh5.ggpht.com/owLgzEVCKQ4n2fWCMbQtzp0ScBdC0G6vQgFZAiTDfaJPVp7qTi1V3vuago1nWAuAdw=w300)

This feature is named after Valve's `portal` game. A `Portal` allows us to keep complex state hanging around if needed. Basically, you shoot a couple of portals and throw your state through one portal, catching it as it falls out the other portal on the next function run.

##### `option`:
``` rust
agent! {
  option(prim_bool),
  fn run(&mut self) -> Result<Signal> {
    let mut opt = self.option.recv();
    let opt_reader: prim_bool::Reader = opt.read_schema()?;
    let opt_boolean = opt_reader.get_boolean()?;
    Ok(End)
  }
}
```
The `option` port gives the `subgraph` developer a way to send in parameters such as a connection string and the message will not be consumed and thrown away, that message may be read on every function run. Whereas other ports will consume and throw away the message.

##### `accumulator`:
``` rust
agent! {
  accumulator(prim_bool),
  fn run(&mut self) -> Result<Signal> {
    let mut acc = self.ports.accumulator.recv()?;
    let acc_reader: prim_bool::Reader = ip_acc.read_schema()?;
    let acc_boolean = acc_reader.get_boolean()?;
    Ok(End)
  }
}
```
The `accumulator` gives the `subgraph` developer a way to start counting at a certain number. This port isn't used so often.
##### `run`:
This function does the actual processing and is the only mandatory expression of this macro.
