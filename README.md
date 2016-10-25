![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/fractalide.png)
# Fractalide
 _**Simple Rust Microservices**_

 [![LICENSE](https://img.shields.io/badge/license-MPLv2-blue.svg)](LICENSE)
 [![Join the chat at https://gitter.im/fractalide](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/fractalide?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

## Welcome

**Fractalide is a programming platform that intends to make efficient microservices simple to reason about.**

Where [simple is made easy](https://www.infoq.com/presentations/Simple-Made-Easy).

The canonical source of this project is hosted on [GitLab](https://gitlab.com/fractalide/fractalide), and is the preferred place for contributions, however if you do not wish to use GitLab, feel free to make issues, on the mirror. However pull requests will only be accepted on GitLab, to make it easy to maintain.

## Problem 1
Non-trivial applications today do not compose very well, nor pipe data from one application/microservice to another simply and easily.

## Solution
Fractalide comes with its own actor oriented dataflow programming language called Flowscript (Flow-based programming (FBP) to be specific). Flowscript makes the concept of data flowing through a system into be a first class citizen, thus, easily manipulated by the programmer/designer.

* Our choice of actors *do not have* methods calls, but *do have* the functional input-transform-output approach meaning we keep things simple to reason about.
* Fractalide components are Rust macros that compile to a shared library with a C ABI. The components have a standardized API that forbids state leakage.
* This standardized API is key to component composition. Composition is achieved via a coordination layer called a `subnet` or a sub-network of components, which describes how components are connected and compose together. A `subnet`, on an interface level, is indistinguishable from a Rust component, this, neatly, allows for abstraction layers which fall away during runtime.
* Each component is intelligent enough to automatically setup its own dependencies such as silo'ed data persistence stores. This is thanks to [Nix](http://nixos.org/nix)'s declarative abilities and rich package set which can be explored [here](http://nixos.org/nixos/packages.html). Declarative dependencies are more simple to reason about.
* Components communicate using [Cap'n Proto](http://capnproto.org), which is *`a type system for distributed systems`*. Therefore unlike typical microservice platforms, Fractalide allows one to start off with a monolith type infrastructure, where the word "monolith", in this sense, describes a system without network barriers between components, yet, when you wish to introduce a networking boundary between components, the use of Cap'n Proto makes it simpler to achieve *than* having to wrap HTTP layers around each component in more traditional microservice setups.
* The Unix Pipe concept typically requires one to parse `stdin`, which can be troublesome, unless you're using Cap'n Proto contracts which conveniently hands structured data to you.
* Each Fractalide component draws from the wealth of [crates.io](https://crates.io), allowing for non-trivial components to be built.

## Problem 2
Security and business interests rarely align these days.

## Solution
##### Security
Fractalide's components are very strict about accepting data. Strongly inspired by the [langsec work](http://langsec.org) of Meredith Patterson, Len Sassaman and Dan Kaminsky. Fractalide makes use of the [Nom](https://github.com/Geal/nom) parser combinator, implemented by Geoffroy Couprie, to parse Flowscript. Components cannot connect together unless they use the same [Cap'n Proto](https://capnproto.org/) contracts, which is implemented by David Renshaw, and the brain child of Kenton Varda. Of course, [Rust](https://www.rust-lang.org/), a high level systems language helps us prevent an entire class of buffer overflow exploits, without sacrificing speed for safety.
##### Business
Flowscript allows for a separation of business logic and component implementation logic. Thus programmers can easily own areas of code, or practise ["Sovereign Software Development"](https://top.fse.guru/the-civilized-alternative-to-agile-tribalism-4c60d01428c0), and given the [fast moving nature](https://medium.com/@bryanedds/living-in-the-age-of-software-fuckery-8859f81ca877) of business, a programmer can reuse components and quickly manipulate data flowing through the system, or ideally, train the suits to manipulate the business logic themselves. Basically Fractalide is an attempt at ameliorating the above *fast moving nature* of business.

### Layers
- [x] Actor based coordination language that coordinates Rust components, which pass Cap'n Proto contract messages.
- [x] Specialization satellite [repositories](https://github.com/fractalide/frac_example_satellite_repo). Allowing you to create your own applications outside of the canonical Fractalide repository.
- [ ] HTTP finite state machine implementation, needed for a decent microservice setup.
- [ ] 1.0 Stabilization version.
- [ ] Community collaboration: Please do send useful, well documented, well implemented components upstream. This is a [living system](https://hintjens.gitbooks.io/social-architecture/content/chapter6.html) that uses the [C4](http://rfc.zeromq.org/spec:42/C4/) so we'll all benefit from your components.

### Setup
Fractalide supports whatever platform [Nix](http://nixos.org/nix) runs on. Quite possibly your package manager already has the `nix` [package](https://hydra.nixos.org/job/nix/master/release#tabs-constituents), please check first.
For the most efficient way forward, ensure you're using [NixOS](http://nixos.org), The Purely Functional Linux Distribution. (Do help out with NixOS and Rust, they're both doing [really well](https://octoverse.github.com/)!)
```
$ NIX_PATH="nixpkgs=https://github.com/NixOS/nixpkgs/archive/125ffff089b6bd360c82cf986d8cc9b17fc2e8ac.tar.gz:fractalide=https://github.com/fractalide/fractalide/archive/master.tar.gz"
$ export NIX_PATH
$ git clone https://gitlab.com/fractalide/frac_example_wrangle.git
$ cd frac_example_wrangle
$ nix-build
```
* The first build will make you wait a long time. Thereafter only components that change will be recompiled.
```
$ ./result/bin/example_wrangle
```
If you want to install `example_wrangle` into your environment directly, thus accessible from the command line:
```
$ cd frac_example_wrangle
$ nix-env -i -f default.nix
$ example_wrangle
```
### Developing your own application:

---
```
$ NIX_PATH="nixpkgs=https://github.com/NixOS/nixpkgs/archive/125ffff089b6bd360c82cf986d8cc9b17fc2e8ac.tar.gz:fractalide=https://github.com/fractalide/fractalide/archive/master.tar.gz"
$ export NIX_PATH
$ git clone https://github.com/fractalide/frac_example_satellite_repo.git
$ cd frac_example_satellite_repo
$ nix-build
```
* see how it works, then
* delete the `.git` folder
```
$ git init
```
* Start adding components and subnets to the `components` and `contracts` folders.
* ensure you [expose](https://github.com/fractalide/frac_example_satellite_repo/blob/master/default.nix#L7-L8) the correct toplevel component in your root folder `default.nix`
```
$ nix-build
```
* [expose](https://github.com/fractalide/fractalide/blob/master/components/example/satellite/repo/default.nix#L18-L19) your subnet to your clone of fractalide if you want to take advantage of Incremental Compilation.
```
$ cd /path/to/fractalide/clone
$ nix-build --argstr debug true --argstr cache $(./support/buildCache.sh) --argstr subnet your_amazing_app
```
---
### Incremental Builds
Fractalide expands the nix-build system for incremental builds. The Incremental Builds only work when debug is enabled. They also need the path to a cache folder.
The cache folder can be created from an old result by the buildCache.sh script. Per default the cache folder is saved in the /tmp folder of your system.

Here is an example how you can build with the Incremental Build System:

```
$ nix-build --argstr debug true --argstr cache $(./support/buildCache.sh) --argstr subnet example_satellite_repo
```
If you're using NixOS, please ensure you have not set `nix.useSandbox = true;`, otherwise Incremental Compilation will fail.

## Consulting and Support
Name | Email | Info
-----|-------|-----
Stewart Mackenzie | setori88@gmail.com | Founder and maintainer of Fractalide.
Denis Michiels | dmichiels@gmail.com | Founder and maintainer of Fractalide.

Consulting not limited to just Fractalide work, but Rust gigs in general.

### Contributing to Fractalide
The contributors are listed in `fractalide/support/upkeepers.nix` (add yourself).

Please read this document BEFORE you send a patch:
* Fractalide uses the [C4.2 (Collective Code Construction Contract)](http://rfc.zeromq.org/spec:42/C4/) process for contributions. Please read this if you are unfamiliar with it.
Fractalide grows by the slow and careful accretion of simple, minimal solutions to real problems faced by many people. Some people seem to not understand this. So in case of doubt:
* Each patch defines one clear and agreed problem, and one clear, minimal, plausible solution. If you come with a large, complex problem and a large, complex solution, you will provoke a negative reaction from Fractalide maintainers and users.
* We will usually merge patches aggressively, without a blocking review. If you send us bad patches, without taking the care to read and understand our rules, that reflects on you. Do NOT expect us to do your homework for you.
* As rapidly we will merge poor quality patches, we will remove them again. If you insist on arguing about this and trying to justify your changes, we will simply ignore you and your patches. If you still insist, we will ban you.
* Fractalide is not a sandbox where "anything goes until the next stable release". If you want to experiment, please work in your own projects.

### License
The project license is specified in LICENSE.
Fractalide is free software; you can redistribute it and/or modify it under the terms of the Mozilla Public License Version 2 as approved by the Free Software Foundation.

### Donations
Help keep the lights on by donating Bitcoin to `19njauHnbST9aL7m7QL89BDedrPMSrG92e`.

### The Mozilla Manifesto
This project supports the [Mozilla Manifesto](https://www.mozilla.org/en-US/about/manifesto/). These principles guide our mission to promote openness, innovation & opportunity on the Internet.
