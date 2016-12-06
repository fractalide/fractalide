# Components Collection

The `Components` collection consists of `Interfaces` and `Objects`. An `Interface` or an `Object` may be referred to as a `Component`.

## Interfaces

### What?

An `Interface` consists of an implementation and an interface aspect. The implementation is constructed using a simple language called `Flowscript` which describes how data flows through `Objects` and other `Interfaces`. The interface aspect of an `Interface` consists of exposing a minimal set of well named `ports`, thus hiding complexity.

A simple analogy would be this gentleman's pocket watch.

![Image Alt](http://www.kirkwood.edu/pdf/uploaded/835/watchcalls_35.gif)

### Why?

Composition is an important part of programming, allowing one to hide implementation detail.

### Who?

People who want to focus on the Science tend to work at these higher abstractions, they'd prefer not getting caught up in the details of programming low level components and hand specifications to programmers who'll make efficient, reusable and safe components. Though programmers will find `Interfaces` indispensable as they allow for powerful abstractions.

### Where?

The `Components` directory is where all `Objects` and `Interfaces` go. Typically one might structure a hierarchy like such:

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

See the above `default.nix` files? Those are `Interfaces` and they hide the entire directory level they reside in from higher levels in the hierarchy. Thus `processchunk` (an `Interface`) looks like yet another `Component` to `wrangle` (another `interface`). Indeed `wrangle` is completely unable to distinguish between an `Object` and an `Interface`.

### How?

The `Interface` `default.nix` requires you make decisions about two types of dependencies.
* What `contracts` are needed?
* What `components` are needed?

Lastly:
* How to connect the lot to best solve your problem.

``` nix
{ interface, components, contracts }:

interface {
 src = ./.;
 flowscript = with components; with contracts; ''
  '${maths_boolean}:(boolean=true)' -> a nand(${maths_boolean_nand})
  '${maths_boolean}:(boolean=true)' -> b nand()
  nand() output -> input io_print(${maths_boolean_print})
 '';
}
```

![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/subnet_ex10.png)

* The `{ interface, contracts, components }:` lambda passes in three arguments, the `interface` builder, `contracts` which consists of every `Contract` or `Contract Namespace`, and the `components` argument which consists of every `Component` and `Component Namespace` in the system.
* The `interface` building function accepts these arguments:
  * The `src` attribute is used to derive an `Interface` name based on location in the directory hierarchy.
  * The `flowscript` attribute defines the business logic. Here data flowing through a system becomes a first class citizen that can be manipulated. `Contracts` and `Components` are brought into scope between the opening '' and closing '' double single quotes by using the `with components; with contracts;` syntax.
* `Nix` assists us greatly, in that each `component` name (the stuff between the curly quotes ``${...}``) undergoes a compilation step resolving every name into an absolute `/path/to/compiled/lib.subnet` text file and `/path/to/compiled/libcomponent.so` shared object.
* This compilation is lazy and only referenced names will be compiled. In other words `Interface` could be a top level `Interface` of a many layer deep hierarchy and only referenced `Components` will be compiled in a lazy fashion, *not* the entire `fractalide/components` folder.

This is the output of the above `Interface`'s compilation:
```
$ cat /nix/store/1syrjhi6jvbvs5rvzcjn4z3qkabwss7m-test_sjm/lib/lib.subnet
'/nix/store/fx46blm272yca7n3gdynwxgyqgw90pr5-maths_boolean:(boolean=true)' -> a nand(/nix/store/7yzx8fp81fl6ncawk2ag2nvfc5l950xb-maths_boolean_nand)
'/nix/store/fx46blm272yca7n3gdynwxgyqgw90pr5-maths_boolean:(boolean=true)' -> b nand()
nand() output -> input io_print(/nix/store/k67wiy6z4f1vnv35vdyzcqpwvp51j922-maths_boolean_print)
```

Mother of the Flying Spaghetti Monster, what is that? Those hashes hint at something powerful, projects like `docker` and `git` implement this type of content addressable store, except `docker`'s granularity is at container level, and `git`'s granularity is at every changeset. Our granularity is at package or library level. It allows for reproducible, deterministic systems, instead of copying around "zipped" archives, that quickly max out your hard drive.

### Flowscript syntax is easy

Everything between the opening `''` and closing `''` is `flowscript`, i.e:
``` nix
{ interface, components, contracts }:

interface {
  src = ./.;
  flowscript = with components; with contracts; ''
                       <---- here
  '';
}
```
![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/subnet_ex0.png)


#### Component initialization:
``` nix
{ interface, components, contracts }:

interface {
  src = ./.;
  flowscript = with components; with contracts; ''
    variable_name(${name_of_component})
  '';
}
```
![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/subnet_ex1.png)

#### Referencing a previously initialized component (with a comment):
``` nix
{ interface, components, contracts }:

interface {
  src = ./.;
  flowscript = with components; with contracts; ''
    variable_name(${name_of_component}) // <──┐
    variable_name()                     // <──┴─ same instance
  '';
}
```
![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/subnet_ex1.png)

#### Connecting and initializing two components:
``` nix
{ interface, components, contracts }:

interface {
  src = ./.;
  flowscript = with components; with contracts; ''
    comp1(${name_of_component}) output_port -> input_port comp2(${name_of_component2})
  '';
}
```
![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/subnet_ex3.png)

#### Creating an Initial Information Packet
``` nix
{ interface, components, contracts }:

interface {
  src = ./.;
  flowscript = with components; with contracts; ''
    '${maths_boolean}:(boolean=true)' -> a comp(${name_of_component})
  '';
}
```
![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/subnet_ex4.png)

#### More complex Initial Information Packet
``` nix
{ interface, contracts, components }:

interface {
  src = ./.;
  flowscript = with contracts; with components; ''
   td(${ui_js_components.flex})
   '${js_create}:(type="div", style=[(key="display", val="flex"), (key="flex-direction", val="column")])~create' -> input td()
  '';
}
```
![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/subnet_ex5.png)

[Learn](../contracts/README.md) more about Information Packets.
#### Creating an interface input port
``` nix
{ interface, components, contracts }:

interface {
  src = ./.;
  flowscript = with components; with contracts; ''
    interface_input => input comp(${name_of_component})
  '';
}
```
![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/subnet_ex6.png)

#### Creating an interface output port
``` nix
{ interface, components, contracts }:

interface {
  src = ./.;
  flowscript = with components; with contracts; ''
     comp(${name_of_component}) output => interface_output
  '';
}
```
![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/subnet_ex7.png)

#### Interface initialization:
``` nix
{ interface, components, contracts }:

interface {
  src = ./.;
  flowscript = with components; with contracts; ''
    interface(${name_of_interface})
  '';
}
```
![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/subnet_ex8.png)

#### Initializing a interface and component then connecting them:
``` nix
{ interface, components, contracts }:

interface {
  src = ./.;
  flowscript = with components; with contracts; ''
    interface(${name_of_interface})
    component(${name_of_component})
    interface() output -> input component()
  '';
}
```
![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/subnet_ex9.png)

#### Output array port:
``` nix
{ interface, components, contracts }:

interface {
  src = ./.;
  flowscript = with components; with contracts; ''
    db_path => input clone(${ip_clone})
    clone() clone[0] => db_path0
    clone() clone[1] => db_path1
    clone() clone[2] => db_path2
    clone() clone[3] => db_path3
  '';
}
```
![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/subnet_ex11.png)

Note the `clone[1]`, this is an `array output port` and in this particular `Interface` `Information Packets` are being replicated, a copy for each port element. The content between the `[` and `]` is a string, so don't be misled by the integers. There are two types of component ports, a `simple port` (which doesn't have array elements) and an `array port` (with array elements). The `array port` allows one to, depending on component logic, replicate, fan-out and a whole bunch of other things.

#### Input array port:
``` nix
{ interface, components, contracts }:

interface {
  src = ./.;
  flowscript = with components; with contracts; ''
    add0 => add[0] adder(${path_to_adder})
    add1 => add[1] adder()
    add2 => add[2] adder()
    add3 => add[3] adder() output -> output
  '';
}
```
![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/subnet_ex15.png)

`Array ports` are used when the number of ports are unknown at `Object` development time, but known when the `Object` is used in an `Interface`. The `adder` `Object` demonstrates this well, it has an `array input port` which allows `Interface` developers to choose how many integers they want to add together. It really doesn't make sense to implement an adder with two simple input ports then be constrained when you need to add three numbers together.

#### Hierarchical naming:
``` nix
{ interface, components, contracts }:

interface {
  src = ./.;
  flowscript = with components; with contracts; ''
    input => input clone(${ip_clone})
    clone() clone[0] -> a nand(${maths_boolean_nand})
    clone() clone[1] -> b nand() output => output
  '';
}
```
![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/subnet_ex13.png)

The `Component` and `Contract` names, i.e.: `${maths_boolean_nand}` are too long! Fractalide uses a hierarchical naming scheme. So you can find the `maths_boolean_not` component by going to the [maths/boolean/not](./maths/boolean/not/default.nix) directory. The whole goal of this is to avoid name shadowing among potentially hundreds to thousands of components.

Explanation of the `Interface`:

This `Interface` takes an input of type [maths_boolean](../contracts/maths/boolean/default.nix) over the input port. The `Information Packet` is cloned by the `clone` component and the result is pushed out on the `array port` `clone` using elements `[0]` and `[1]`. The `nand()` component then performs a `NAND` boolean logic operation and outputs a `maths_boolean` data type, which is then sent over the `Interface` output port `output`.

The above implements the `not` boolean logic component.

#### Abstraction powers:
``` nix
{ interface, components, contracts }:

interface {
  src = ./.;
  flowscript = with components; with contracts; ''
    '${maths_boolean}:(boolean=true)' -> a nand(${maths_boolean_nand})
    '${maths_boolean}:(boolean=true)' -> b nand()
    nand() output -> input not(${maths_boolean_not})
    not() output -> input print(${maths_boolean_print})
  '';
}
```
![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/subnet_ex14.png)

Notice we're using the `not` component implemented earlier. One can build hierarchies many layers deep without suffering a run-time performance penalty. Once the graph is loaded into memory, all `Interfaces` fall away, like water, after an artificial gravity generator engages, leaving only `Objects` connected to `Objects`.

#### Namespaces
``` nix
{ interface, components, contracts }:

interface {
  src = ./.;
  flowscript = with components; with contracts; ''
    listen => listen http(${net_http_components.http})
    db_path => input clone(${ip_clone})
    clone() clone[1] -> db_path get(${app_todo_components.todo_get})
    clone() clone[2] -> db_path post(${app_todo_components.todo_post})
    clone() clone[3] -> db_path del(${app_todo_components.todo_delete})
    clone() clone[4] -> db_path patch(${app_todo_components.todo_patch})

    http() GET[/todos/.+] -> input get() response -> response http()
    http() POST[/todos/?] -> input post() response -> response http()
    http() DELETE[/todos/.+] -> input del() response -> response http()
    http() PATCH[/todos/.+] -> input patch()
    http() PUT[/todos/.+] -> input patch() response -> response http()
  '';
}
```
![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/subnet_ex12.png)

Notice the `net_http_components` and `app_todo_components` namespaces. Some [fractals](../fractals/README.md) deliberately export a collection of `Objects` and `Interfaces`. As is the case with the `net_http_components.http` component.
When you see a `fullstop` `.`, i.e. `xxx_components.yyy` you immediately know this is a namespace. It's also a programming convention to use the `_components` suffix.
Lastly, notice the advanced usage of `array ports` with this example: `GET[/todos/.+]`, the element label is actually a `regular expression` and the implementation of that component is slightly more [advanced](https://github.com/fractalide/fractal_net_http/blob/master/components/http/src/lib.rs#L149)!



## Objects

### What?

Executable `Interfaces` are defined as a network of `Objects`, which exchange typed data across predefined connections by message passing, where the connections are specified externally to the processes. These `Objects`  can be reconnected endlessly to form different `Interfaces` without having to be changed internally.

### Why?

Functions in a programming language should be placed in a content addressable store, this is the horizontal plane. The vertical plane should be constructed using unique addresses into this content addressable store, critically each address should solve a single problem, and may do so by referencing multiple other unique addresses in the content addressable store. Users must not have knowledge of these unique addresses but a translation process should occur from a human readable name to a universally unique address. Read [more](http://erlang.org/pipermail/erlang-questions/2011-May/058768.html) about the problem.

Once you have the above, you have truly reusable functions. Fractalide components are just this, and it makes the below so much easier to achieve:
```
* Open source collaboration
* Peer review of components
* Reproducible applications
* Reusable clean components
```

### Who?

Typically programmers will develop `Objects`. They specialize in making `Objects` as efficient and reusable as possible, while people who focus on the Science give the requirements and use the components. Just as a hammer is designed to be reused, so components should be designed for reuse.

### Where?

The `Objects` are found in this `components` directory, or the `components` directory of a [fractal](../fractals/README.md).

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
Typically when you see a `lib.rs` in the same directory as a `default.nix` you know it's an `Object`.

### How?

The `Object` `default.nix` requires you make decisions about three types of dependencies.
* What `contracts` are needed?
* What `crates` from [crates.io](https://crates.io) are needed?
* What `osdeps` or `operating system level dependencies` are needed?

In all the above cases transitive dependencies are resolved for you.

``` nix
{ object, contracts, crates, pkgs }:

let
  rustfbp = crates.rustfbp { vsn = "0.3.21"; };
  capnp = crates.capnp { vsn = "0.7.4"; };
in
object {
  src = ./.;
  contracts = with contracts; [ maths_boolean ];
  crates = [ rustfbp capnp ];
  osdeps = with pkgs; [ openssl ];
}
```

The `{ object, contracts, crates, pkgs }:` lambda imports:
* The `object` function which builds the rust `lib.rs` source code in the same directory.
* The `contracts` attributeset consists of every contract available on the system.
* The `crates` attributeset consists of every package on https://crates.io.
* The `pkgs` pulls in every third party package available on NixOS, here's the whole list: http://nixos.org/nixos/packages.html
Note only those dependencies and their transitive dependencies will be pulled into scope and compiled, if their binaries aren't available. So you get a source distribution with a binary distribution optimization.

What does the output of the `component` function that build the `maths_boolean_nand` component look like?


```
/nix/store/dp8s7d3p80q18a3pf2b4dk0bi4f856f8-maths_boolean_nand
└── lib
    └── libcomponent.so
```
