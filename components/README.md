# Components and Subnets

## Subnets

Components are dependent on: contracts, crates and third party libraries.
Contracts are dependent on: other contracts.
Subnets are dependent on: contracts components and other subnets.

This is the subnet:

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

The `{ component, contracts, crates, pkgs }:` imports the `component` function which builds the rust source code in the folder. The `contracts` argument pulls in every contract available on the system, crates *will* soon pull in only dependent and transitive crates available on https://crates.io and `pkgs` pulls in every third party package available on NixOS, here's the whole list: http://nixos.org/nixos/packages.html

Please note in the next couple of weeks the depsSha256 attribute will be removed.

* the argument `contracts = with contracts; [ maths_boolean ];` allows the programmer to select exactly which contracts are needed for each of the ports
* the argument `crates = with crates; [ rustfbp capnp ];` allows the programmer to pull in selected crates from crates.io as component dependencies. Nix will help us resolve transitive dependencies.
* the argument `osdeps = with pkgs; [ openssl];` allows the programmer to insert operating system level library dependencies such as openssl and well pretty much anything available on nixos

The above attributes are being passed into the component function as arguments.
The component function will do a few things for us, 1) ensure `contracts`, `crates` (soon to happen) and `osdeps` are available in scope, then it pulls in the rust src and compiles it into a shared object file with a C ABI.
So you can reference the name of a component (derived from the folder hierarchy) in a subnet and the component will be lazily compiled.

What does the output of the `component` function that build the `maths_boolean_nand` component look like?

```
/nix/store/dp8s7d3p80q18a3pf2b4dk0bi4f856f8-maths_boolean_nand
└── lib
    └── libcomponent.so
```

The `fvm` is intelligent enough to know how to find the `.../lib/libcomponent.so` library and `dlopen` it.
