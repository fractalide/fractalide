![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/fractalide.png)
# Fractalide
 _**"A shell for today, for tomorrow, for forever." - Lain**_

 [![LICENSE](https://img.shields.io/badge/license-MPLv2-blue.svg)](LICENSE)
 [![Join the chat at https://gitter.im/fractalide](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/fractalide?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

## Welcome

**Fractalide is a rolling release programming platform, with the aim of making software distribution cheaper and easier, yet forcing the programmer to implement high quality, modular, message passing components; all presented via familiar shell, called Lain.**

The canonical source of this project is hosted on [GitLab](https://gitlab.com/fractalide/fractalide), and is the preferred place for contributions, however if you do not wish to use GitLab, feel free to make issues, on the mirror. However pull requests will only be accepted on GitLab, to make it easy to maintain.

## Problem 1
Devops today leans towards distributing software via hyped container technologies, that, in most cases, bundle messy code.

## Solution
The Lain shell makes use of [Nix](http://nixos.org/nix) as its package manager, which properly solves an entire class of errors, that named "dependency hell".

## Problem 2
Applications today do not compose very well, nor pipe data from one application to another easily.

## Solution
Lain comes with its own actor oriented dataflow programming language (Flow-based programming) called Flowscript, implemented in Rust. Flowscript makes the concept of data flowing through a system to be a first class citizen, thus easily manipulable by the programmer/designer.
At a top level, component hierarchies are exposed to Lain (the shell), they know how to compose and pipe data between components. The goal is to allow users to easily transition between a fully expressive graph language and the shell type environment, thus giving a strong ability to compose components together is a fast and effective manner.

## Problem 3
Security and business interests rarely align these days.

## Solution
##### Security
Fractalide's components are very strict about what data they accept. Strongly inspired by the [work](http://langsec.org) of Meredith Patterson, Dan Kaminsky, Len Sassaman. Fractalide makes use of the [Nom](https://github.com/Geal/nom) parser combinator, implemented by Geoffroy Couprie, and [Capnproto](https://capnproto.org/) contracts extensively. Of course, [Rust](https://www.rust-lang.org/), a high level systems language helps us prevent an entire class of buffer overflow exploits, without sacrificing speed for safety.
##### Business
Flowscript allows for a separation of business logic and component implementation logic. Thus programmers can specialize on easily specifiable components and the suits can design and easily make changes to their business logic, without the need of programmer intervention.

### Layers
- [x] Actor language built on Rust; components are implemented in Rust, message passing via Capnproto contracts.
- [ ] A shell called Lain, she controls her little universe.
- [ ] Whatever you want to build, this is a [living system](https://hintjens.gitbooks.io/social-architecture/content/chapter6.html).

### Setup
Fractalide supports whatever platform [Nix](http://nixos.org/nix) runs on. Quite possibly your package manager already has the `nix` package, please check first.
For the most efficient way forward, ensure you're using [NixOS](http://nixos.org), The Purely Functional Linux Distribution.
```
$ git clone https://gitlab.com/fractalide/fractalide.git
$ cd fractalide
$ nix-build
$ ./result/bin/lain
```
If you want to install Lain into your environment directly, thus accessible from the command line:
```
$ cd fractalide
$ nix-env -i -f default.nix
$ lain
```

### Incremental Builds
Fractalide expands the nix-build system for incremental builds. The Incremental Builds only work when debug is enabled. They also need the path to a cache folder.
The cache folder can be created from an old result by the buildCache.sh script. Per default the cache folder is saved in the /tmp folder of your system.

Here is an example how you can build with the Incremental Build System:

```
nix-build --argstr debug true --argstr cache $(./support/buildCache.sh) --argstr subnet test_sjm
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

### The Mozilla Manifesto
This project supports the [Mozilla Manifesto](https://www.mozilla.org/en-US/about/manifesto/). These principles guide our mission to promote openness, innovation & opportunity on the Internet.
