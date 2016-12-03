# Components and Subnets

## Subnets

### What?

`Subnets` are essentially buckets that contain other components, subnets and contracts, this is the implementation. These buckets also have pipes, where each pipe connects to the ports of other `components` or `subnets`, in other words, the interface. 

### Why?

Composition is a very important part of programming. A `subnet` allows one to compose `components`, other `subnets` and `contracts` and expose a nice simple interface to users. These `subnets` may be recombined in as many ways as `components`, indeed from an interface perspective they are identical to `components`.

### Who?

Typically experts in a domain will operate here. These people most likely are not programmers and prefer focusing on the Science vs getting tangled in the weeds of code. Programmers will find `subnets` very important because this allows them to create more powerful hierarchies of components.

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

See those `default.nix` files? Those are `subnets`, the other names are directories containing rust `components`. Typically a `default.nix` in a directory with `components` will contain exactly those rust `components` in the subnet. It's a neat way to keep things organized and at a simple glance of the directory structure you're able to have an idea of the architecture of the program. By the way, in the `nix` world a `default.nix` file means you can simply reference the parent directory and `nix` will look for the `default.nix` file, an equivalent in the `rust` world is the `lib.rs` and `mod.rs` naming conventions.

### How?

The `nix` level `default.nix` file requires you make decisions about 3 types of dependencies.
* What `contracts` are needed?
* What `components` are needed?
* What `subnets` are needed in your `subnet`?

``` nix
{ subnet, components, contracts }:

subnet {
 src = ./.;
 flowscript = with components; with contracts; ''
  '${maths_boolean}:(boolean=true)' -> a nand(${maths_boolean_nand}) output -> input io_print(${maths_boolean_print})
  '${maths_boolean}:(boolean=true)' -> b nand()
 '';
}
```


The `{ subnet, contracts, components }:` arguments pass in a subnet buiding function called `subnet`, every other contract and every other component (or namespace of components).

The subnet example is more simple, in this example the FBP flowscript code is actually in the text portion of one of the function arguments called `flowscript`.
You already understand the `src` attribute, the new concept is the `flowscript` attribute.
Here we bring every  contract and component into the scope between the opening '' and closing '' double single quotes of the `flowscript` attribute, allowing us to construct flow based programming subnets.

The `${maths_boolean}:(boolean=true)' ->` bit of flowscript is a typed Initial Information Packet.

The above attributes are being passed into the subnet function as function arguments.
The subnet function assists us inthat each flowscript argument undergoes a compilation step resolving every name between a ``${...}`` into a `*.subnet` text file with absolute paths to other subnets or compiled components!
This approach is lazy and only referenced names will be compiled. So this could be the top level component of a many hundred deep hierarchy and the whole hierarchy will be compiled lazily.

This is what the output looks like:
```
$ cat /nix/store/1syrjhi6jvbvs5rvzcjn4z3qkabwss7m-test_sjm/lib/lib.subnet
'/nix/store/fx46blm272yca7n3gdynwxgyqgw90pr5-maths_boolean:(boolean=true)' -> a nand(/nix/store/7yzx8fp81fl6ncawk2ag2nvfc5l950xb-maths_boolean_nand) output -> input io_print(/nix/store/k67wiy6z4f1vnv35vdyzcqpwvp51j922-maths_boolean_print)
'/nix/store/fx46blm272yca7n3gdynwxgyqgw90pr5-maths_boolean:(boolean=true)' -> b nand()
```

This file can then be fed into the `fvm`or fractalide virtual machine.

### Flowscript syntax is easy

Everything between the opening `''` and `''` attribute value is `flowscript`, i.e:
``` nix
{ subnet, components, contracts }:

subnet {
  src = ./.;
  flowscript = with components; with contracts; ''
                       <---- here
  '';
}
```
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
#### Connecting and initializing two components:
``` nix
{ subnet, components, contracts }:

subnet {
  src = ./.;
  flowscript = with components; with contracts; ''
    component1(${name_of_component}) output_port -> input_port component2(${name_of_component2})
  '';
}
```
#### Creating an Initial Input Packet
``` nix
{ subnet, components, contracts }:

subnet {
  src = ./.;
  flowscript = with components; with contracts; ''
    '${maths_boolean}:(boolean=true)' -> a variable_name(${name_of_component})
  '';
}
```
#### More complex Initial Input Packet
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
[Learn](../contracts/README.md) more about Information Packets.
#### Creating a subnet input port
``` nix
{ subnet, components, contracts }:

subnet {
  src = ./.;
  flowscript = with components; with contracts; ''
    subnet_input => input_port variable_name(${name_of_component})
  '';
}
```
#### Creating a subnet output port
``` nix
{ subnet, components, contracts }:

subnet {
  src = ./.;
  flowscript = with components; with contracts; ''
     variable_name(${name_of_component}) output_port => subnet_output
  '';
}
```
#### Subnet initialization:
``` nix
{ subnet, components, contracts }:

subnet {
  src = ./.;
  flowscript = with components; with contracts; ''
    subnet_name(${name_of_subnet})
  '';
}
```
#### Initializing a subnet and component then connecting them:
``` nix
{ subnet, components, contracts }:

subnet {
  src = ./.;
  flowscript = with components; with contracts; ''
    subnet(${name_of_subnet})
    component(${name_of_component})
    subnet() subnet_output -> input_port component()
  '';
}
```
#### Hierarchical naming:
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

The component and contract names seem long and irritating. Fractalide uses a hierarchical naming structure.
So you can find the `maths_boolean_nand` component by going to the `fractalide/components/maths/boolean/nand` directory.
The same logic applies to the contracts. Though we also support namespaces. So from time to time you might see something like this:

#### Array ports:
``` nix
{ subnet, components, contracts }:

subnet {
  src = ./.;
  flowscript = with components; with contracts; ''
    db_path => input clone(${ip_clone})
    clone() clone[1] => db_path1
    clone() clone[2] => db_path2
    clone() clone[3] => db_path3
    clone() clone[4] => db_path4
  '';
}
```
Note the `clone() clone[1]`. This is an `array output port`, there is an equivalent `array input port` with similar syntax and the contents between the `[` and `]` is a string, so don't be mislead by the numbers.
There are two types of component ports, a `simple port` and an `array port`. The `array port` allows one to, depending on component logic, replicate, fan-out and a whole bunch of other things.

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
    clone() clone[3] -> db_path delete(${app_todo_components.todo_delete})
    clone() clone[4] -> db_path patch(${app_todo_components.todo_patch})

    http() GET[/todos/.+] -> input get() response -> response http()
    http() POST[/todos/?] -> input post() response -> response http()
    http() DELETE[/todos/.+] -> input delete() response -> response http()
    http() PATCH[/todos/.+] -> input patch()
    http() PUT[/todos/.+] -> input patch() response -> response http()
  '';
}
```
Notice the `net_http_components` and `app_todo_components` namespaces. Some [fractals](../fractals/README.md) might deliberately expose a sort of toolkit one may take tools and use. As is the case with the `net_http_components.http` component.
When you see a `xxx_components.yyy` you know immediately this is a namespace.
Lastly, notice the advanced usage of `array ports` with this example: `GET[/todos/.+]`, the element name is actually a `regular expression` and the implementation of that component is slightly more [advanced](https://github.com/fractalide/fractal_net_http/blob/master/components/http/src/lib.rs#L149)!



## Components

Components depend on contracts, crates and operating system libraries.

### What?

Components are Rust `dylib` libraries with a C ABI. They have predefined inputs and outputs. The Fractalide scheduler understands how to load these libraries.

Note, typically one uses `cargo` to construct correctly formatted arguments to the `rustc` compiler. In this case we've chosen to replace `cargo` with `nix` scripts that correctly format arguments to the `rustc` compiler. There was too much cognitive dissonance happening between `nix` an immutable package manager calling `cargo` an immutable package manager. The choice has so far worked out very well indeed.

### Why?

Data needs to be transformed. Rust an efficient, zero-cost abstractions seem like a very good choice of implementation language for these components.

### Who?

Typically programmers will develop these components. They specialize on making these components as efficient as possible, while people who focus on the Science give the requirements.  

### Where?

The `components` are found in the `components` directory.

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
Typically when you see a `lib.rs` in the same directory as a `default.nix` you know that `default.nix` is not a `subnet` but a `component`.

### How?

The `nix` level `default.nix` file requires you make 3 decisions.
* What `contracts` the `component` will use.
* What `crates` are present in the `component`.
* What `operating system level dependencies` or `osdeps` are needed to correctly run this `component`.

In all the above cases transitive deps are resolved for you.

``` nix
{ component, contracts, crates, pkgs }:

component {
  src = ./.;
  contracts = with contracts; [ maths_boolean ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [ openssl ];
  depsSha256 = "0pzvnvhmzv1bbp5gfgmak3bsizhszw4bal0vaz30xmmd5yx5ciqj";
}
```

The `{ component, contracts, crates, pkgs }:` imports the `component` function which builds the rust source code in the directory. The `contracts` argument pulls in every contract available on the system, crates *will* soon pull in only dependent and transitive crates available on https://crates.io and `pkgs` pulls in every third party package available on NixOS, here's the whole list: http://nixos.org/nixos/packages.html

Please note in the next couple of weeks the depsSha256 attribute will be removed.

* the argument `contracts = with contracts; [ maths_boolean ];` allows the programmer to select exactly which contracts are needed for each of the ports
* the argument `crates = with crates; [ rustfbp capnp ];` allows the programmer to pull in selected crates from crates.io as component dependencies. Nix will help us resolve transitive dependencies.
* the argument `osdeps = with pkgs; [ openssl];` allows the programmer to insert operating system level library dependencies such as openssl and well pretty much anything available on nixos

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
