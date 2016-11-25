![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/fractalide.png)
# Fractalide
 _**Simple Rust Microservices**_

 [![LICENSE](https://img.shields.io/badge/license-MPLv2-blue.svg)](LICENSE)
 [![Join the chat at https://gitter.im/fractalide](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/fractalide?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

## Welcome

**Fractalide provides a Flow-based programming language, a build system and an approach to distribution, with the aim of making efficient microservices simple to reason about.**

Though, *simple to reason about* is not enough, we aim higher, we'd like [simplicity to be made easy](https://www.infoq.com/presentations/Simple-Made-Easy).

The canonical source of this project is hosted on [GitLab](https://gitlab.com/fractalide/fractalide), and is the preferred place for contributions, however if you do not wish to use GitLab, feel free to make issues, on the mirror. However pull requests will only be accepted on GitLab, to make it easy to maintain.

### Donations
Help keep us strong by donating Bitcoin to [15g3WQqYtcrqrno3oxGPi8nNe3hP6rJHo6](https://keybase.io/fractalide).

### Social
Follow us on [twitter](https://twitter.com/fractalide)

## Problem 1
* Language level modules become tightly coupled with the rest of the code.

## Solution
* Fractalide comes with its own actor oriented, message passing, declarative dataflow programming language called Flowscript (Flow-based programming (FBP) to be specific). Flowscript makes the concept of data flowing through a system into be a first class citizen, thus, easily manipulated by the programmer/designer.
* Flowscript (punishingly) enforces well-factored, independent components within a single process that have strict boundaries and standardized API.
* This standardized API is key to component composition and is achieved via a coordination layer called a `subnet` or a sub-network of components, which describes how components are connected and compose together. A `subnet`, from an interface perspective, is indistinguishable from a Rust component, this, neatly, allows for layers of abstraction which fall away at runtime.
* These components are black boxes which are only dependent on data and not any other component.
* Fractalide [components](https://crates.io/crates/rustfbp) are Rust macros that compile to a shared library with a C ABI.
* Our choice of actors *do not have any* methods calls, but *do have* the typical functional `input-transform-output` approach which allows us to keep things simple to reason about. In other words, you're not going to find many 100 millisecond RPC here.

## Problem 2
* It's easy to disrespect API contracts in many microservices setups.

## Solution
* The Unix Pipe concept typically requires one to parse arbitrary `stdin`, which is troublesome, unless you're using Cap'n Proto contracts which conveniently hands structured data to you.
* A Fractalide upstream component `U` might use Contract `X` to send data to downstream component `D`, each component will reference exactly the same Contract `X` by name alone, hence guaranteeing the two components use the same contract. Indeed, one cannot connect the graph if `U`'s output port and `D`'s input port aren't the same contract. Say you change Contract `X`'s schema, nix will lazily recompile Component `U` and `D` and the type checks will fail. Thus you're sure arbitrary changes to contracts will cause dependent components to fail. Allowing you to have extremely high confidence that APIs are respected. This kind of behaviour isn't exhibited in other microservice deployments where components construct arbitrary JSON data structures.
* Fractalide components communicate using `Cap'n Proto` contracts, which is *`a type system for distributed systems`*, and is *`infinitely faster`* than protocol buffers ([read the website](http://capnproto.org)). Even better yet, Cap'n Proto contracts can be extended without breaking components with a different version. That would be a problem if we weren't in complete control of versioning in a distributed system.

## Problem 3
* Knowing what versions and dependencies is a nightmare in many microservice setups. Especially when rolling back.

## Solution
* [Nix](http://nixos.org/nix) is a declarative lazy language and will make the system reflect your system description exactly.
* [Nixops](http://nixos.org/nixops) provides the means to do code delivery, whilst ensuring the entire cluster is at the expected version.
* Due to `nix`'s declarative behaviour, each service is intelligent enough to automatically setup its own dependencies such as a silo'ed data persistence store. They may also draw from the wealth of [crates.io](https://crates.io), allowing for non-trivial components to be built easily.
* You might want to start learning `nix` with these fun [quizzes](https://nixcloud.io/tour/?id=1).

## Problem 4
* Updating a single or multiple service/s in an entire cluster of nodes can be hard in many microservices setups.

## Solution
* `nixops` will only stop, update and start a service if there has been a change to it, otherwise the service will continue working as per normal.

## Problem 5
* Security and business interests rarely align these days.

## Solution
##### Security
* Fractalide's components are very strict about accepting data. Strongly inspired by the [langsec work](http://langsec.org) of Meredith Patterson, Len Sassaman and Dan Kaminsky. Fractalide makes use of the [Nom](https://github.com/Geal/nom) parser combinator, implemented by Geoffroy Couprie, to parse Flowscript. Components cannot connect together unless they use the same [Cap'n Proto](https://capnproto.org/) contracts, which is implemented by David Renshaw, and the brain child of Kenton Varda. Of course, [Rust](https://www.rust-lang.org/), a high level systems language helps us prevent an entire class of buffer overflow exploits, without sacrificing speed for safety.

##### Business
* Flowscript allows for a separation of business logic and component implementation logic. Thus programmers can easily own areas of code, or practise ["Sovereign Software Development"](https://top.fse.guru/the-civilized-alternative-to-agile-tribalism-4c60d01428c0), and given the [fast moving nature](https://medium.com/@bryanedds/living-in-the-age-of-software-fuckery-8859f81ca877) of business, a programmer can reuse components and quickly manipulate data flowing through the system, or ideally, train the suits to manipulate the business logic themselves. Fractalide attempts to hand tools and techniques to the programmer to survive in such an environment.

### Steps towards stable release.
- [x] [Flowscript](https://en.wikipedia.org/wiki/Flow-based_programming) - a declarative dataflow language a little more suited to distributed computing.
- [x] [Fractals](fractals/README.md) - allowing you to create your own repositories outside the canonical Fractalide repository.
- [x] [HTTP support](https://github.com/fractalide/fractal_net_http).
- [ ] [Service composition](https://github.com/fractalide/fractal_workbench/blob/master/service.nix).
- [ ] Deployable example of a simple microservices setup.
- [ ] Documentation.
- [ ] Remove cargo.
- [x] Contract composition.
- [ ] Only Information Packets make heap allocations.
- [ ] Upgrade `nom` parser combinator to 2.0.
- [ ] New `hotswap` `<->`; `disconnect` `-\>`; `remove` `!name()` language tokens.
- [ ] 1.0 Stabilization version.
- [ ] Community collaboration: Please do send useful, well documented, well implemented components upstream. This is a [living system](https://hintjens.gitbooks.io/social-architecture/content/chapter6.html) that uses the [C4](http://rfc.zeromq.org/spec:42/C4/) so we'll all benefit from your components.

### Quick start
Fractalide supports whatever platform [Nix](http://nixos.org/nix) runs on. Quite possibly your package manager already has the `nix` [package](https://hydra.nixos.org/job/nix/master/release#tabs-constituents), please check first.
For the most efficient way forward, ensure you're using [NixOS](http://nixos.org), The Purely Functional Linux Distribution.
```
$ cd <your/development/directory>
$ mkdir fractals && cd fractals
$ git clone https://github.com/fractalide/fractal_workbench.git
$ cd fractal_workbench
$ NIX_PATH="nixpkgs=https://github.com/NixOS/nixpkgs/archive/125ffff089b6bd360c82cf986d8cc9b17fc2e8ac.tar.gz:fractalide=https://github.com/fractalide/fractalide/archive/master.tar.gz" && export NIX_PATH
$ nix-build
```
* You will wait about 4~5 hours to compile rustc. We're working on it...
* a neat hack you can do that'll persist your `rustc` between `nix-collect-garbage` runs is this:
* `$ git clone github.com/nixos/nixpkgs`
* `$ cd nixpkgs`
* `$ git checkout 125ffff`
* `$ nix-build -A rustUnstable.rustc  -o rust-125fff`
* then do not delete the `rust-125fff` symlink.
* this is a temporary hack, which should last about 1~2 weeks
```
$ ./result
```
* Open `firefox`:
* Install and open the `resteasy` firefox plugin
* Post : `http://localhost:8000/todos/`
* Open `"data"`
* Select `"custom"`
* Keep `Mime type` empty
* Put `{ "title": "A new title" }` in the textbox.
* Click `send`
* Notice the `200` response, now be a cool hacker and make a nifty front end please.

You can also mess around with
* `GET http://localhost:8000/todos/ID`
* `DELETE http://localhost:8000/todos/ID`
* `PUT http://localhost:8000/todos/ID`

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
