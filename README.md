# Fractalide
Canonical repository for all Fractalide components and the service to serve Fractalide components on a Named Data Network.

Fractalide is a collection of subnet (aka apps) built using Flow-based Programming components.
These components are reusable and can be combined in other subnets ad infinitum.
They are meant to be executed by the [Fractalide Virtual Machine](https://github.com/fractalide/fvm).

The repository consists of `components`, `contracts`, `subnets`, `build support` and a Fractalide service.

### Components
Implemented in [Rust](https://www.rust-lang.org/) they have [capnproto](https://capnproto.org/) `contracts` for each component input and output.

* Your component will be named according to the file hierarchy via [genName](https://github.com/sjmackenzie/fractalide/blob/component-compilation/components/maths/number/add/default.nix#L4).
* Ensure you add your new component to the `component/default.nix` like [such](https://github.com/sjmackenzie/fractalide/blob/component-compilation/components/default.nix#L6).
* To include needed contracts into the component you are developing please ensure you follow this [example](https://github.com/fractalide/fractalide/blob/master/components/maths/number/add/default.nix#L6).
* Ensure you contract exists and the system sees it.

### Contracts
`capnproto` [contracts](https://github.com/fractalide/fractalide/blob/master/contracts/maths/boolean/contract.capnp) clearly define the boundaries of each component.

* Simply copy/paste a contract `default.nix` into your new contract directory [i.e.](https://github.com/sjmackenzie/fractalide/blob/component-compilation/contracts/maths/boolean/default.nix)
* Name your contract file `contract.capnp` [i.e.](https://github.com/sjmackenzie/fractalide/tree/component-compilation/contracts/maths/boolean).
* The `default.nix` will name your contract based on folder hierarchy see [genName](https://github.com/sjmackenzie/fractalide/blob/component-compilation/contracts/maths/boolean/default.nix#L4).
* Ensure you add your new component to the `contracts/default.nix` like [such](https://github.com/sjmackenzie/fractalide/blob/component-compilation/contracts/default.nix#L6).

### Subnets

Subnets allow for abstraction. This is a graph language coordination language that represents the business logic of an application. Subnets may also be seen as a component but the `default.nix` is slightly [different](https://github.com/sjmackenzie/fractalide/blob/component-compilation/components/maths/boolean/not/default.nix#L3) from a [Rust based component](https://github.com/sjmackenzie/fractalide/blob/component-compilation/components/maths/boolean/nand/default.nix#L3).

* Ensure you follow [this](https://github.com/sjmackenzie/fractalide/tree/component-compilation/components/maths/boolean/not) file structure.
* Write your Flow-based Programming syntax in the `lib.subnet` file like [this](https://github.com/sjmackenzie/fractalide/blob/component-compilation/components/maths/boolean/not/lib.subnet).
* Subnets do not have contracts.
* Again, add the subnet to the `components/default.nix` like [such](https://github.com/sjmackenzie/fractalide/blob/component-compilation/contracts/default.nix#L6), following a sane file hierarchy naming.

Develop your `components`, `contracts` and `subnets` such that they may be reused and have sensible names. All contributions will be licensed as MPLv2.

Then run `$ nix-build` in the root directory to build the components.

## Installation

First and foremost, you will need to be running [NixOS](http://nixos.org/). For the things we are doing this is the only sane approach. Go ahead and clone/use the [nixos-infrastructure](https://github.com/fractalide/nixos-infrastructure) and add your own machine [here](https://github.com/fractalide/nixos-infrastructure/tree/master/machines).

Insert the below into your `configuration.nix` file:

```
let
  fractalide = /path/to/fractalide-git-clone-dir;
in
{
  require = [ "${fractalide}/fractalide-module.nix" ];
  services.fractalide.enable = true;
...
}

```
see [example](https://github.com/sjmackenzie/nixos-infrastructure/blob/master/machines/rivergod.nix#L2-L7)

## Development environment

`$ ./dev-shell`

## Build only components

`$ nix-build`

## Build service and components

`$ nix-build -A build release.nix`

## Test service deployment in a VM.

`$ nix-build -A tests.install release.nix`

## Artifacts built
```
environment.variables.FRACTALIDE_CONFIG = /path/to/fractalide-working-dir/fractalide.toml
environment.variables.FRACTALIDE_DATA = /path/to/fractalide-working-dir
```

These artifacts are needed by FVM and the website, later they could be deprecated by the service (once built).

## TODO
Named Data Network to serve NDN Interests for components.
