![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/fractalide.png)
# Fractalide
 _**Simple Rust Microservices**_

 [![LICENSE](https://img.shields.io/badge/license-MPLv2-blue.svg)](LICENSE)
 [![Join the chat at https://gitter.im/fractalide](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/fractalide?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

## Welcome

**Fractalide is a programming platform that intends to make efficient microservices simple to reason about.**

Though, *simple to reason about* is not enough, we aim higher, we'd like [simplicity to be made easy](https://www.infoq.com/presentations/Simple-Made-Easy).

The canonical source of this project is hosted on [GitLab](https://gitlab.com/fractalide/fractalide), and is the preferred place for contributions, however if you do not wish to use GitLab, feel free to make issues, on the mirror. However pull requests will only be accepted on GitLab, to make it easy to maintain.

### Donations
Help keep us strong by donating Bitcoin to [15g3WQqYtcrqrno3oxGPi8nNe3hP6rJHo6](https://keybase.io/fractalide).

### Social
Follow us on [twitter](https://twitter.com/fractalide)

## Problem 1
* Non-trivial applications today do not compose very well, nor pipe data from one application/microservice to another simply and easily.
* Functions within an application compose well, but that same power of composition doesn't exist beyond the executable's boundary. In other words it's not easy to compose reusable executables.

## Solution
* Fractalide comes with its own actor oriented declarative dataflow programming language called Flowscript (Flow-based programming (FBP) to be specific). Flowscript makes the concept of data flowing through a system into be a first class citizen, thus, easily manipulated by the programmer/designer.
* The programmer defines strict boundaries with an interface condusive to composition and abstraction so the same powers of composition can be expressed when composing reusable executables.

More info:
  * Our choice of actors *do not have any* methods calls, but *do have* the typical functional `input-transform-output` approach which allows us to keep things simple to reason about. In other words, you're not going to find much RPC here.
  * These components are black boxes which are only dependent on data and not any other component.
  * Fractalide [components](https://crates.io/crates/rustfbp) are Rust macros that compile to a shared library with a C ABI. The components have a standardized API that forbids state leakage.
  * This standardized API is key to component composition and is achieved via a coordination layer called a `subnet` or a sub-network of components, which describes how components are connected and compose together. A `subnet`, from an interface perspective, is indistinguishable from a Rust component, this, neatly, allows for layers of abstraction which fall away at runtime.
  * Each component is intelligent enough to automatically setup its own dependencies such as a silo'ed data persistence store. This is thanks to [Nix](http://nixos.org/nix)'s declarative abilities and rich package set which can be explored [here](http://nixos.org/nixos/packages.html). Declarative dependencies are more simple to reason about.
  * Components communicate using [Cap'n Proto](http://capnproto.org), which is *`a type system for distributed systems`*. Therefore unlike typical microservice platforms, Fractalide allows one to start off with a monolith type infrastructure, where the word "monolith", in this sense, describes a system without network barriers between components, yet, when you wish to introduce a networking boundary between components, the use of Cap'n Proto makes it simpler to achieve *than* having to wrap HTTP layers around each component in more traditional microservice setups.
  * The Unix Pipe concept typically requires one to parse `stdin`, which can be troublesome, unless you're using Cap'n Proto contracts which conveniently hands structured data to you.
  * Each Fractalide component draws from the wealth of [crates.io](https://crates.io), allowing for non-trivial components to be built.

## Problem 2
Security and business interests rarely align these days.

## Solution
##### Security
Fractalide's components are very strict about accepting data. Strongly inspired by the [langsec work](http://langsec.org) of Meredith Patterson, Len Sassaman and Dan Kaminsky. Fractalide makes use of the [Nom](https://github.com/Geal/nom) parser combinator, implemented by Geoffroy Couprie, to parse Flowscript. Components cannot connect together unless they use the same [Cap'n Proto](https://capnproto.org/) contracts, which is implemented by David Renshaw, and the brain child of Kenton Varda. Of course, [Rust](https://www.rust-lang.org/), a high level systems language helps us prevent an entire class of buffer overflow exploits, without sacrificing speed for safety.
##### Business
Flowscript allows for a separation of business logic and component implementation logic. Thus programmers can easily own areas of code, or practise ["Sovereign Software Development"](https://top.fse.guru/the-civilized-alternative-to-agile-tribalism-4c60d01428c0), and given the [fast moving nature](https://medium.com/@bryanedds/living-in-the-age-of-software-fuckery-8859f81ca877) of business, a programmer can reuse components and quickly manipulate data flowing through the system, or ideally, train the suits to manipulate the business logic themselves. Fractalide attempts to hand tools and techniques to the programmer to survive in such an environment.

### Steps towards stable release.
- [x] Flowscript - a declarative dataflow language a little more suited to distributed computing.
- [x] [Fractals](https://github.com/fractalide/fractal_workbench) - allowing you to create your own repositories outside the canonical Fractalide repository.
- [x] [HTTP support](https://github.com/fractalide/fractal_net_http).
- [ ] Service composition
- [ ] Working, deployable example of a simple microservices setup - please give feedback!
- [ ] Documentation - please give feedback!
- [ ] Remove cargo
- [ ] 1.0 Stabilization version.
- [ ] Community collaboration: Please do send useful, well documented, well implemented components upstream. This is a [living system](https://hintjens.gitbooks.io/social-architecture/content/chapter6.html) that uses the [C4](http://rfc.zeromq.org/spec:42/C4/) so we'll all benefit from your components.

### Quick start
Fractalide supports whatever platform [Nix](http://nixos.org/nix) runs on. Quite possibly your package manager already has the `nix` [package](https://hydra.nixos.org/job/nix/master/release#tabs-constituents), please check first.
For the most efficient way forward, ensure you're using [NixOS](http://nixos.org), The Purely Functional Linux Distribution. (Do help out with NixOS and Rust, they're both doing [really well](https://octoverse.github.com/)!)
```
$ cd <your/development/directory>
$ mkdir fractals && cd fractals
$ git clone https://github.com/fractalide/fractal_workbench.git
$ cd fractal_workbench
$ NIX_PATH="nixpkgs=https://github.com/NixOS/nixpkgs/archive/125ffff089b6bd360c82cf986d8cc9b17fc2e8ac.tar.gz:fractalide=https://github.com/fractalide/fractalide/archive/master.tar.gz" && export NIX_PATH
$ nix-build
```
* The first build will make you wait a long time. Thereafter only components that change will be recompiled.
* Build times will improve as soon as these two issues [1](https://github.com/rust-lang/cargo/issues/3215) [2](https://github.com/NixOS/nixpkgs/issues/18111) are fixed, and cargo on nixpkgs supports the [official mechanism](http://doc.crates.io/source-replacement.html) for using pre-downloaded dependencies. It means Fractalide can use a version of nixpkgs where dependencies have been built by Hydra, and can benefit from binary package distribution.
```
$ ./result/bin/workbench
```
navigate to:
* [localhost:8000](http://localhost:8000/)
* [localhost:8000/fractalide](http://localhost:8000/fractalide)

### Building your own fractals

A `fractal` is a fractalide 3rd party library. [Learn more](fractals/README.md)

### Consulting and Support
Name | Email | Info
-----|-------|-----
Stewart Mackenzie | setori88@gmail.com | Founder and maintainer of Fractalide.
Denis Michiels | dmichiels@gmail.com | Founder and maintainer of Fractalide.

Consulting not limited to just Fractalide work, but Rust gigs in general.

### Contributing to Fractalide
* The contributors are listed in `fractalide/support/upkeepers.nix` (add yourself).
* Fractalide uses the [C4.2 (Collective Code Construction Contract)](CONTRIBUTING.md) process for contributions. Please read this if you are unfamiliar with it.
* Fractalide grows by the slow and careful accretion of simple, minimal solutions to real problems faced by many people.

### Documentation
* [RustFBP](https://docs.rs/rustfbp) provides all the needed functionality to allow for declarative dataflow.
* [Build your own Fractal](https://github.com/fractalide/fractalide/blob/master/fractals/README.md)

### License
The project license is specified in LICENSE.
Fractalide is free software; you can redistribute it and/or modify it under the terms of the Mozilla Public License Version 2 as approved by the Free Software Foundation.
