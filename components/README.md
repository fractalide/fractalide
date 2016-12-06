# Components and Subnets

## Subnets

### What?

`Subnets` have an implementation and an interface. The implementation consists of composing `components`, other `subnets` and `contracts` together and deciding on the interface. The interface consists of exposing a minimal set of well named `ports` that solve the user's problem.

A simple analogy would be this gentleman's pocket watch.

![Image Alt](http://www.kirkwood.edu/pdf/uploaded/835/watchcalls_35.gif)

### Why?

Composition is an important part of programming, allowing one to hide implementation detail. Allowing the user of your `subnet` to reason about high level problems, without getting caught up in low level details.

### Who?

People who want to focus on the Science tend to work at these higher abstractions, they'd prefer not getting caught up in the details of programming low level components and prefer handing specifications to programmers who'll make efficient, reusable and safe components. Though programmers will find `subnets` indispensable as they allow for powerful hierarchies of components and subnets.

### Where?

The `components` directory is where all the `subnets` go. Typically one might structure a hierarchy like such:

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

See those `default.nix` files? Those are `subnets`. The other names are directories containing rust `components`. Typically a `default.nix` in a directory with `components` will contain exactly those rust `components` in the subnet. It's a neat way to keep things organized and at a glance you're able to have an idea of the architecture of the program. By the way, in the `nix` world a `default.nix` file means you can simply reference the parent directory and `nix` will look for the `default.nix` file, an equivalent in the `rust` world is the `lib.rs` and `mod.rs` naming conventions.

### How?

The `subnet` `default.nix` requires you make decisions about three types of dependencies.
* What `contracts` are needed?
* What `components` and `subnets` are needed?
* How to connect the lot to best solve your problem.

``` nix
{ subnet, components, contracts }:

subnet {
 src = ./.;
 flowscript = with components; with contracts; ''
  '${maths_boolean}:(boolean=true)' -> a nand(${maths_boolean_nand})
  '${maths_boolean}:(boolean=true)' -> b nand()
  nand() output -> input io_print(${maths_boolean_print})
 '';
}
```

![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/subnet_ex10.png)

* The `{ subnet, contracts, components }:` passes in 3 arguments, the `subnet` building function called `subnet`, `contracts` is every other contract or contract namespace and `components` is every other `subnet` and `component` in the system. Both `subnets` and `components` are bundled into the `components` argument.
* The `subnet` building function accepts these arguments:
  * The `src` attribute derives a subnet name based on location in the directory hierarchy.
  * The `flowscript` attribute defines the business logic. Here data flowing through a system becomes a first class citizen that can be manipulated. `Contracts`, `components` and `subnets` are brought into scope between the opening '' and closing '' double single quotes by using the `with components; with contracts;` syntax.
* `Nix` assists us greatly, in that each `component`/`subnet` name (the stuff between the curly quotes ``${...}``) undergoes a compilation step resolving every name into an absolute `/path/to/compiled/lib.subnet` text file and `/path/to/compiled/libcomponent.so` shared object.
* This approach is lazy and only referenced names will be compiled. In other words `subnet` could be a top level `subnet` of a many  layer deep hierarchy and the only that hierarchy of referenced names will be compiled in a lazy fashion, *not* the entire `fractalide/components` folder.

This is the output of the above `subnet`'s compilation:
```
$ cat /nix/store/1syrjhi6jvbvs5rvzcjn4z3qkabwss7m-test_sjm/lib/lib.subnet
'/nix/store/fx46blm272yca7n3gdynwxgyqgw90pr5-maths_boolean:(boolean=true)' -> a nand(/nix/store/7yzx8fp81fl6ncawk2ag2nvfc5l950xb-maths_boolean_nand)
'/nix/store/fx46blm272yca7n3gdynwxgyqgw90pr5-maths_boolean:(boolean=true)' -> b nand()
nand() output -> input io_print(/nix/store/k67wiy6z4f1vnv35vdyzcqpwvp51j922-maths_boolean_print)
```

Mother of the Flying Spaghetti Monster, what is that? Thankfully, you'll not need to care about the *read only* output. In a similar vein, projects like `docker` also implement this type of registry logic, except `docker`'s granularity is at container level. We've adopted a package or library granularity instead. It allows for reproducible, deterministic systems, instead of copying around "zipped" archives, that quickly max out your hard drive.

### Flowscript syntax is easy

Everything between the opening `''` and closing `''` is `flowscript`, i.e:
``` nix
{ subnet, components, contracts }:

subnet {
  src = ./.;
  flowscript = with components; with contracts; ''
                       <---- here
  '';
}
```
![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/subnet_ex0.png)


#### Component initialization:
``` nix
{ subnet, components, contracts }:

subnet {
  src = ./.;
  flowscript = with components; with contracts; ''
    variable_name(${name_of_component})
  '';
}
```
![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/subnet_ex1.png)

#### Referencing a previously initialized component (with a comment):
``` nix
{ subnet, components, contracts }:

subnet {
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
{ subnet, components, contracts }:

subnet {
  src = ./.;
  flowscript = with components; with contracts; ''
    comp1(${name_of_component}) output_port -> input_port comp2(${name_of_component2})
  '';
}
```
![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/subnet_ex3.png)

#### Creating an Initial Information Packet
``` nix
{ subnet, components, contracts }:

subnet {
  src = ./.;
  flowscript = with components; with contracts; ''
    '${maths_boolean}:(boolean=true)' -> a comp(${name_of_component})
  '';
}
```
![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/subnet_ex4.png)

#### More complex Initial Information Packet
``` nix
{ subnet, contracts, components }:

subnet {
  src = ./.;
  flowscript = with contracts; with components; ''
   td(${ui_js_components.flex})
   '${js_create}:(type="div", style=[(key="display", val="flex"), (key="flex-direction", val="column")])~create' -> input td()
  '';
}
```
![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/subnet_ex5.png)

[Learn](../contracts/README.md) more about Information Packets.
#### Creating a subnet input interface port
``` nix
{ subnet, components, contracts }:

subnet {
  src = ./.;
  flowscript = with components; with contracts; ''
    subnet_input => input comp(${name_of_component})
  '';
}
```
![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/subnet_ex6.png)

#### Creating a subnet output interface port
``` nix
{ subnet, components, contracts }:

subnet {
  src = ./.;
  flowscript = with components; with contracts; ''
     comp(${name_of_component}) output => subnet_output
  '';
}
```
![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/subnet_ex7.png)

#### Subnet initialization:
``` nix
{ subnet, components, contracts }:

subnet {
  src = ./.;
  flowscript = with components; with contracts; ''
    subnet(${name_of_subnet})
  '';
}
```
![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/subnet_ex8.png)

#### Initializing a subnet and component then connecting them:
``` nix
{ subnet, components, contracts }:

subnet {
  src = ./.;
  flowscript = with components; with contracts; ''
    subnet(${name_of_subnet})
    component(${name_of_component})
    subnet() output -> input component()
  '';
}
```
![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/subnet_ex9.png)

#### Output array port:
``` nix
{ subnet, components, contracts }:

subnet {
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

Note the `clone[1]`, this is an `array output port` and in this particular component `Information Packets` are being replicated, a copy for each port element. The content between the `[` and `]` is a string, so don't be misled by the integers. There are two types of component ports, a `simple port` (which doesn't have array elements) and an `array port` (with array elements). The `array port` allows one to, depending on component logic, replicate, fan-out and a whole bunch of other things.

#### Input array port:
``` nix
{ subnet, components, contracts }:

subnet {
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

`Array ports` are used when the number of ports are unknown at component development time, but known when the component is used in a subnet. The `adder` component demonstrates this well, it has an `array input port` which allows `subnet` developers to choose how many integers they want to add together. It really doesn't make sense to implement an adder with two simple input ports then be constrained when you need to add three numbers together.

#### Hierarchical naming:
``` nix
{ subnet, components, contracts }:

subnet {
  src = ./.;
  flowscript = with components; with contracts; ''
    input => input clone(${ip_clone})
    clone() clone[0] -> a nand(${maths_boolean_nand})
    clone() clone[1] -> b nand() output => output
  '';
}
```
![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/subnet_ex13.png)

The component and contract names, i.e.: `${maths_boolean_nand}` are too long! Fractalide uses a hierarchical naming scheme. So you can find the `maths_boolean_not` component by going to the [maths/boolean/not](./maths/boolean/not/default.nix) directory. The same logic applies to the contracts. The whole goal of this is to avoid name collisions and yet be able to have potentially hundreds to thousands of components.

Explanation of the subnet:

This `subnet` takes an input of type [maths_boolean](../contracts/maths/boolean/default.nix). The `Information Packet` is cloned by the `clone` component and the result is pushed out on the `array port` `clone` using elements `[0]` and `[1]`. The `nand()` component then performs a `NAND` boolean logic operation and outputs a `maths_boolean` data type, which is then sent over the `subnet` output port `output`.

The above implements the `not` boolean logic component.

#### Abstraction powers:
``` nix
{ subnet, components, contracts }:

subnet {
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

Notice we're using the `not` `subnet` interface implemented earlier. It's hard to distinguish between a `component` and a `subnet` from an interface perspective, this provides a powerful method to hide implementation logic. One can build hierarchies many layers deep without suffering a run-time performance penalty. Once the graph is loaded into memory, all `subnets` fall away, like water, after an artificial gravity generator engages, leaving only rust `components` connected to rust `components`.

#### Namespaces
``` nix
{ subnet, components, contracts }:

subnet {
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

Notice the `net_http_components` and `app_todo_components` namespaces. Some [fractals](../fractals/README.md) deliberately export a collection of `components` and `subnets`. As is the case with the `net_http_components.http` component.
When you see a `fullstop` `.`, i.e. `xxx_components.yyy` you immediately know this is a namespace. It's also a programming convention to use the `_components` suffix.
Lastly, notice the advanced usage of `array ports` with this example: `GET[/todos/.+]`, the element label is actually a `regular expression` and the implementation of that component is slightly more [advanced](https://github.com/fractalide/fractal_net_http/blob/master/components/http/src/lib.rs#L149)!



## Components

### What?

Components define applications as a network of black box processes, which exchange typed data across predefined connections by message passing, where the connections are specified externally to the processes. These black box processes can be reconnected endlessly to form different applications without having to be changed internally. Though, the word 'applications' was used to convey meaning, in actuality there is no different between an application and just another component. This allows almost insane levels of mix-and-matching to occur.

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

Typically programmers will develop Rust components. They specialize in making components as efficient and reusable as possible, while people who focus on the Science give the requirements and use the components. Just as a hammer is designed to be reused, so components should be designed for reuse.

### Where?

The `components` are found in the `components` directory, i.e. this directory, or the `components` directory in a [fractal](../fractals/README.md).

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
Typically when you see a `lib.rs` in the same directory as a `default.nix` you know it's a `component`.

### How?

The `component` `default.nix` requires you make decisions about three types of dependencies.
* What `contracts` are needed?
* What `crates` from [crates.io](https://crates.io) are needed?
* What `osdeps` or `operating system level dependencies` are needed?

In all the above cases transitive dependencies are resolved for you.

``` nix
{ component, contracts, crates, pkgs }:

let
  rustfbp = crates.rustfbp { vsn = "0.3.21"; };
  capnp = crates.capnp { vsn = "0.7.4"; };
in
component {
  src = ./.;
  contracts = with contracts; [ maths_boolean ];
  crates = [ rustfbp capnp ];
  osdeps = with pkgs; [ openssl ];
}
```

The `{ component, contracts, crates, pkgs }:` lambda imports:
* The `component` function which builds the rust `lib.rs` source code in the same directory.
* The `contracts` attributeset consists of every contract available on the system.
* The `crates` attributeset consists of every package on https://crates.io.
* The `pkgs` pulls in every third party package available on NixOS, here's the whole list: http://nixos.org/nixos/packages.html
Note only those dependencies and their transitive dependencies will be pulled into scope and compiled, if their binaries aren't available. So you get a source distribution with a binary distribution optimization.

* the argument `contracts = with contracts; [ maths_boolean ];` allows the programmer to select exactly which contracts are needed for each of the ports
* the argument `crates = with crates; [ rustfbp { vsn = "0.3.21"; } capnp { vsn = "0.7.4"; } ];` allows the programmer to pull in selected crates from crates.io as component dependencies. Nix will help us resolve transitive dependencies.
* the argument `osdeps = with pkgs; [ openssl];` allows the programmer to insert operating system level library dependencies such as openssl and well pretty much anything available on nixos

Note, typically one uses `cargo` to construct correctly formatted arguments to the `rustc` compiler. In this case we've chosen to replace `cargo` with `nix` scripts that correctly format arguments to the `rustc` compiler. There was too much cognitive dissonance happening between `nix` an immutable package manager calling `cargo` an immutable package manager. The choice has so far worked out very well indeed.

The above attributes are being passed into the component function as arguments.
The component function will do a few things for us, 1) ensure `contracts`, `crates` (soon to happen) and `osdeps` are available in scope, then it pulls in the rust src and compiles it into a shared object file with a C ABI.
So you can reference the name of a component (derived from the directory hierarchy) in a subnet and the component will be lazily compiled.

What does the output of the `component` function that build the `maths_boolean_nand` component look like?

```
/nix/store/dp8s7d3p80q18a3pf2b4dk0bi4f856f8-maths_boolean_nand
└── lib
    └── libcomponent.so
```

The `fvm` is intelligent enough to know how to find the `.../lib/libcomponent.so` library and `dlopen` it.
