# Fractalide
Canonical repository for all Fractalide applications.

Fractalide is a collection of subnets (aka apps) built using Flow-based Programming components.

"Flow-based Programming defines applications as networks of "black box" processes, which exchange data across predefined connections by message passing, where the connections are specified externally to the processes. These black box processes can be reconnected endlessly to form different applications without having to be changed internally. FBP is thus naturally component-oriented."

Subnets are meant to be executed by the [Fractalide Virtual Machine](https://github.com/fractalide/fvm).

The repository consists of `components`, `contracts`, `subnets`, `build support` and a Fractalide service.

### Components
Implemented in [Rust](https://www.rust-lang.org/) they have [capnproto](https://capnproto.org/) `contracts` for each component's inputs and outputs.

Things to be aware of when implementing components:
* Your component will be named according to the file hierarchy it sits in by [genName](https://github.com/sjmackenzie/fractalide/blob/component-compilation/components/maths/number/add/default.nix#L4).
* Ensure you add your new component to the `component/default.nix` like [such](https://github.com/sjmackenzie/fractalide/blob/component-compilation/components/default.nix#L6).
* Include needed contracts into the component you are developing by following this [example](https://github.com/fractalide/fractalide/blob/master/components/maths/number/add/default.nix#L6).
* Ensure you contract exists and the system sees it.

### Contracts
`capnproto` [contracts](https://github.com/fractalide/fractalide/blob/master/contracts/maths/boolean/contract.capnp) clearly define the boundaries of each component.

* Copy and paste a contract's `default.nix` into your new contract directory [i.e.](https://github.com/sjmackenzie/fractalide/blob/component-compilation/contracts/maths/boolean/default.nix) (They are generic).
* Name your contract file `contract.capnp` [i.e.](https://github.com/sjmackenzie/fractalide/tree/component-compilation/contracts/maths/boolean).
* The `default.nix` will name your contract properly based on folder hierarchy its sitting in, see [genName](https://github.com/sjmackenzie/fractalide/blob/component-compilation/contracts/maths/boolean/default.nix#L4).
* Ensure you add your new component to the `contracts/default.nix` like [such](https://github.com/sjmackenzie/fractalide/blob/component-compilation/contracts/default.nix#L6).

### Subnets

Subnets allow for abstraction. This is a graph coordination language layer that represents the business logic of an application. The interface of a subnet is the same as a component but the `default.nix` is slightly [different](https://github.com/sjmackenzie/fractalide/blob/component-compilation/components/maths/boolean/not/default.nix#L3) from a [Rust component](https://github.com/sjmackenzie/fractalide/blob/component-compilation/components/maths/boolean/nand/default.nix#L3).

* Ensure you follow [this](https://github.com/sjmackenzie/fractalide/tree/component-compilation/components/maths/boolean/not) file structure.
* Write your Flow-based Programming syntax in the `lib.subnet` file like [this](https://github.com/sjmackenzie/fractalide/blob/component-compilation/components/maths/boolean/not/lib.subnet).
* Subnets do not have contracts.
* Again, add the subnet to the `components/default.nix` like [such](https://github.com/sjmackenzie/fractalide/blob/component-compilation/contracts/default.nix#L6), following a sane file hierarchy naming.

Develop your `components`, `contracts` and `subnets` in such that they may be reused and have sensible descriptive names. All contributions will be licensed as MPLv2.

Run `$ nix-build` in the root directory to build the components.

## Installation

First and foremost, you will need to be running [NixOS](http://nixos.org/). This is the only sane approach. Go ahead and clone/use the [nixos-infrastructure](https://github.com/fractalide/nixos-infrastructure) and add your own machine [here](https://github.com/fractalide/nixos-infrastructure/tree/master/machines).

Insert the below into your `configuration.nix` file:

```
{
  require = [ "/path/to/fractalide-git-clone/fractalide-module.nix" ];
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
environment.variables.FRACTALIDE_CONFIG = /var/fractalide/fractalide.toml
environment.variables.FRACTALIDE_DATA = /var/fractalide
```

These artifacts are needed by FVM and the website, later they could be deprecated by the service (once built).

## TODO
Named Data Network to serve NDN Interests for components.
