# Components and Subnets

## Subnets

### What?

`Subnets` are essentially buckets with holes in them. Each hole is a `port` and connects to other `components` or `subnets` ports which are contained in the bucket. `Subnets` may also have [contracts](../components/README.md) as a dependency, they are used for an important concept called an `Initial Information Packet` or `IIP`, to be described later.

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
