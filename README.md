# Fractalide

Canonical repository for all Fractalide applications and the Fractalide Virtual Machine.

Fractalide is a collection of subnets (aka apps) built using Flow-based Programming components.

"Flow-based Programming defines applications as networks of "black box" processes, which exchange data across predefined connections by message passing, where the connections are specified externally to the processes. These black box processes can be reconnected endlessly to form different applications without having to be changed internally. FBP is thus naturally component-oriented."

Subnets are meant to be executed by the [Fractalide Virtual Machine](https://github.com/fractalide/fractalide/tree/master/fvm).

The repository consists of `components`, `contracts`, `subnets`, `build support` and a Fractalide CI service which serves components and subnets.

### Components
Implemented in [Rust](https://www.rust-lang.org/) components have [capnproto](https://capnproto.org/) `contracts` for each input and output. Components do one thing, do it well, and are highly reusable.

Things to be aware of when implementing components:
* Your component will be named according to the file hierarchy it sits in by [genName](https://github.com/fractalide/fractalide/blob/master/components/development/parser/fbp/lexical/default.nix#L4).
* Ensure you add your new component to the `component/default.nix` like [such](https://github.com/fractalide/fractalide/blob/master/components/default.nix#L7).
* Include needed contracts into the component you are developing by following this [example](https://github.com/fractalide/fractalide/blob/master/components/development/parser/fbp/lexical/default.nix#L6).
* Ensure your contracts exists. Nix compiles the contracts during the buildPhase and copies the generated capnproto source code into a `/tmp/build-folder/` for later component compilation.

### Contracts
`capnproto` [contracts](https://github.com/fractalide/fractalide/blob/master/contracts/fbp/lexical/contract.capnp) clearly define the boundaries of each component. We subscribe to [langsec](http://langsec.org/) and strictly define what is allowed into a component.

Things to be aware of when implementing contracts:
* Copy and paste a contract's `default.nix` into your new contract directory [i.e.](https://github.com/fractalide/fractalide/blob/master/contracts/fbp/lexical/default.nix) (They are generic).
* Name your contract `contract.capnp` [i.e.](https://github.com/fractalide/fractalide/tree/master/contracts/fbp/lexical).
* The `default.nix` will name your contract properly based on folder hierarchy it's sitting in, see [genName](https://github.com/fractalide/fractalide/blob/master/build-support/buildFractalideContract.nix#L4).
* Ensure you add your new component to the `contracts/default.nix` like [such](https://github.com/fractalide/fractalide/blob/master/contracts/default.nix).

### Subnets

Subnets allow for generalization. This is a graph coordination language layer that represents the business logic of an application. The interface of a subnet is the same as a component but the implementation is quite different, notice the `default.nix` is slightly [different](https://github.com/fractalide/fractalide/blob/master/components/maths/boolean/not/default.nix) from a [Rust component](https://github.com/fractalide/fractalide/blob/master/components/maths/boolean/nand/default.nix).

Things to be aware of when implementing subnets:
* Ensure you follow [this](https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/not) file structure.
* Write your Flow-based Programming syntax in the (mandatory) `lib.subnet` file like [this](https://github.com/fractalide/fractalide/blob/master/components/maths/boolean/not/lib.subnet).
* Subnets do not have contracts.
* Again, don't forget to add the subnet to the `components/default.nix`, following a sane file hierarchy naming scheme (which determines the name of your subnet).

Develop your `components`, `contracts` and `subnets` in such that they may be reused and have sensible descriptive names. All contributions will be licensed as MPLv2.

Run `$ nix-build` in the root directory to build the components.

## Hydra Service

Hydra is NixOS own Continuous Integration server. We use it to serve freshly built components (before we move onto the Named Data Networking phase.)

```
{
  require = [ "/path/to/fractalide-git-clone/utils/hydra-service.nix" ];
...
}

```

## Building the `FVM` and components.

First and foremost, you will need to be running [NixOS](http://nixos.org/). This is the only sane approach to managing the fast moving dependencies of Rust, and all the components + contracts.

## Debug build

`$ nix-build --argstr buildType debug`

build a single component:

`$ nix-build --argstr buildType debug -A components.maths_boolean_nand`

## Release build

`$ nix-build -A components.maths_boolean_nand`

## Running the `fvm` when developing:

`./result/bin/fvm </path/to/a/filename.subnet>`

## Installing the `fvm` into your `nix` environment

`$ nix-env -i fvm -f default.nix`

## TODO
Named Data Network to serve NDN Interests for components.
