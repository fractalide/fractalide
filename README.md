# Fractalide

Canonical repository for all Fractalide applications and the Fractalide Virtual Machine.

Fractalide is a collection of subnets (aka apps) built using Flow-based Programming components.

"Flow-based Programming defines applications as networks of "black box" processes, which exchange data across predefined connections by message passing, where the connections are specified externally to the processes. These black box processes can be reconnected endlessly to form different applications without having to be changed internally. FBP is thus naturally component-oriented." - J Paul Morrison.

Subnets are meant to be executed by the [Fractalide Virtual Machine](https://github.com/fractalide/fractalide/tree/master/fvm).

The repository consists of `rustfbp`, `components`, `contracts`, `subnets`, `build support`, `Fractalide Virtual Machine` and a Fractalide CI service which serves components and subnets.

### Components
Implemented in [Rust](https://www.rust-lang.org/) components have [capnproto](https://capnproto.org/) `contracts` for each input and output. Components do one thing, do it well, and are highly reusable. All components are licensed as MPLv2.

Things to be aware of when implementing components:
* Your component will be named according to the file hierarchy it sits in by [genName](https://github.com/fractalide/fractalide/blob/master/components/development/parser/fbp/lexical/default.nix#L4).
* Ensure you add your new component to the `component/default.nix` like [such](https://github.com/fractalide/fractalide/blob/master/components/default.nix#L7).
* Include needed contracts into the component you are developing by following this [example](https://github.com/fractalide/fractalide/blob/master/components/development/parser/fbp/lexical/default.nix#L6).
* Ensure your contracts exists. Nix compiles the contracts during the buildPhase and copies the generated capnproto source code into a `/tmp/build-folder/` for later component compilation.

### Contracts
`capnproto` [contracts](https://github.com/fractalide/fractalide/blob/master/contracts/fbp/lexical/contract.capnp) clearly define the boundaries of each component. We subscribe to [langsec](http://langsec.org/) and strictly define what is allowed into a component. All contracts are licensed as MPLv2.

Things to be aware of when implementing contracts:
* Copy and paste a contract's `default.nix` into your new contract directory [i.e.](https://github.com/fractalide/fractalide/blob/master/contracts/fbp/lexical/default.nix) (They are generic).
* Name your contract `contract.capnp` [i.e.](https://github.com/fractalide/fractalide/tree/master/contracts/fbp/lexical).
* The `default.nix` will name your contract properly based on folder hierarchy it's sitting in, see [genName](https://github.com/fractalide/fractalide/blob/master/build-support/buildFractalideContract.nix#L4).
* Ensure you add your new component to the `contracts/default.nix` like [such](https://github.com/fractalide/fractalide/blob/master/contracts/default.nix).

### Subnets

Subnets allow for generalization. This is a graph coordination language layer that represents the business logic of an application. The interface of a subnet is the same as a component but the implementation is quite different, notice the `default.nix` is slightly [different](https://github.com/fractalide/fractalide/blob/master/components/maths/boolean/not/default.nix) from a [Rust component](https://github.com/fractalide/fractalide/blob/master/components/maths/boolean/nand/default.nix). All subnets are licensed as MPLv2.

Things to be aware of when implementing subnets:
* Ensure you follow [this](https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/not) file structure.
* Write your Flow-based Programming syntax in the (mandatory) `lib.subnet` file like [this](https://github.com/fractalide/fractalide/blob/master/components/maths/boolean/not/lib.subnet).
* Subnets do not have contracts.
* Again, don't forget to add the subnet to the `components/default.nix`, following a sane file hierarchy naming scheme (which determines the name of your subnet).

### Build-support

A bunch of nix scripts needed to tie this code base together. (Thanks nixos.org community!)

### Rustfbp

This is the domain of fractalide hackers, most people shouldn't need to interact with this codebase. Everything revolves around this bit of code. If you make a pull request here you'll need to sign a Contributors License Agreement, the license of this code is AGPL-v3-or-later.

### FVM

The Fractalide Virtual Machine which is the sole build artifact and executable needed for running subnets.


## Setup

### Install Nix build tool (replaces `make`)
Run this command as a user other than root (you will need `sudo`). To uninstall simply `rm -fr /nix`. See this [blog post](https://www.domenkozar.com/2014/01/02/getting-started-with-nix-package-manager/) for more detailed information.

`$ curl https://nixos.org/nix/install | sh`

`$ source ~/.nix-profile/etc/profile.d/nix.sh`

`$ git clone git://github.com/fractalide/fractalide`

`$ cd fractalide`

`$ nix-build`

## Debug build

`$ nix-build --argstr debug true`

build a single component:

`$ nix-build --argstr debug true -A components.maths_boolean_nand`

## Release build

`$ nix-build`

build a single component:

`$ nix-build -A components.maths_boolean_nand`

## Running `fvm` when developing:

`$ ./result/bin/fvm ~/path/to/test.subnet`

Here is an example for you to run:

`test.subnet`
```
'false' -> a xor(maths_boolean_xor) output -> input disp(maths_boolean_print)
'false' -> b xor()
```

### Pro tip

`$ nix-shell --argstr debug true -A components.maths_boolean_nand`

`$ cd components/maths/boolean/nand`

`$ eval "$buildPhase"`

`$ cargo build`

repeat till component is done

`$ git checkout Cargo.*`

`$ rm src/maths_boolean.rs` (or any other `capnp` generated file copied into the `src` folder)

`<ctrl-d>`

ensure you delete any nix generated files/changes before committing!

This approach allows you to keep around your `target` folder so you don't have to build from scratch each time via `$nix-build --argstr debug true -A components.maths_boolean_nand`.

## Installing `fvm` into your `nix` environment

`$ nix-env -i fvm -f default.nix`

## Hydra Service

Hydra is NixOS own Continuous Integration server. We use it to serve freshly built components (before we move onto the Named Data Networking phase.).

```
{
  require = [ "/path/to/fractalide-git-clone/utils/hydra-service.nix" ];
...
}
```
