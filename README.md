![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/fractalide.png)
# Fractalide
 _**Simple Rust Microservices**_

 [![LICENSE](https://img.shields.io/badge/license-MPLv2-blue.svg)](LICENSE)
 [![Join the chat at https://gitter.im/fractalide](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/fractalide?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

## Welcome

**Fractalide provides a Flow-based programming language, a build system and an approach to distribution, with the aim of making efficient microservices simple to reason about.**

The canonical source of this project is hosted on [GitLab](https://gitlab.com/fractalide/fractalide), and is the preferred place for contributions, however if you do not wish to use GitLab, feel free to make issues, on the mirror. However pull requests will only be accepted on GitLab, to make it easy to maintain.

Rich Hickey almost exactly describes how Fractalide works [here](https://www.youtube.com/watch?v=ROor6_NGIWU).
Once you've absorbed what he has to say, it'll be much easier to approach this material.

## Features
Fractalide stands on the shoulders of giants by combining the strengths of each language into one programming model.

|Op |Technology |Safe|Zero-cost Abstractions|Reuse|Reproducible|Distributed Type System| Concurrent| Service Config Man.|
|---|-----------|-----|----------------------|---------|----------|------------------------|----------|--------------------
|   |NixOS      |     |                      |         |          |                        |          |✔
|+  |Nix Expr   |     |                      |         |✔         |                        |          |
|+  |Rust       |✔    |✔                    |         |          |                        |✔         |
|+  |Flow-based Programming |    |           |✔       |          |                        |✔         |
|+  |Cap'n Proto|     |                      |         |          |✔                      |          |
|=  |Fractalide Model |✔   |✔                |✔       |✔         |✔                       |✔        |✔

The most unique and interesting combination is that of the `Reproducible` and `Reusable` features. Reusable dataflow functions, compiled to shared objects occupy nix derivations, it's these derivations that make true reproducibility possible. This is no small feat!

Though all is not well! We were forced to partially compromise the zero-cost abstractions feature during graph load time as an implemention of a Flow-based runtime costs, but the gains of an inherently concurrent system with dataflow `agents` that are entirely reusable make it worth it. We feel entitled to check off zero-cost abstractions because `agents` may take advantage of zero-cost libraries available on crates.io, but `agents` must be run by the fractalide runtime.

#### Graph setup and tear down:
* First remove the `'${prim_u64}:(u64=0)' ->  input ` from [here]( https://github.com/fractalide/fractalide/blob/master/nodes/bench/default.nix#L6)

```
$ nix-build --argstr node bench
$ sudo nice -n -20 perf stat -r 10 -d ./result

 Performance counter stats for './result' (10 runs):

       7890.225492      task-clock (msec)         #    1.438 CPUs utilized            ( +-  0.50% )
           233,755      context-switches          #    0.030 M/sec                    ( +-  0.44% )
             2,310      cpu-migrations            #    0.293 K/sec                    ( +- 20.29% )
            45,226      page-faults               #    0.006 M/sec                    ( +-  0.04% )
    22,499,581,894      cycles                    #    2.852 GHz                      ( +-  0.56% )  (50.24%)
   <not supported>      stalled-cycles-frontend
   <not supported>      stalled-cycles-backend
    22,888,513,721      instructions              #    1.02  insns per cycle          ( +-  0.12% )  (62.66%)
     3,862,239,901      branches                  #  489.497 M/sec                    ( +-  0.05% )  (74.09%)
        15,973,363      branch-misses             #    0.41% of all branches          ( +-  0.85% )  (74.19%)
     8,666,236,052      L1-dcache-loads           # 1098.351 M/sec                    ( +-  0.35% )  (63.78%)
       167,742,960      L1-dcache-load-misses     #    1.94% of all L1-dcache hits    ( +-  1.20% )  (30.47%)
        50,599,472      LLC-loads                 #    6.413 M/sec                    ( +-  1.23% )  (26.61%)
         2,381,819      LLC-load-misses           #    4.71% of all LL-cache hits     ( +-  2.48% )  (37.83%)

       5.485212375 seconds time elapsed                                          ( +-  0.53% )

```
5.485212375 seconds to setup and tear down 10,000 `agents`.

#### Graph setup, tear down, message pass and compute:
* Next, insert `'${prim_u64}:(u64=0)' ->  input` to [here]( https://github.com/fractalide/fractalide/blob/master/nodes/bench/default.nix#L6)

```
$ nix-build --argstr node bench
$ sudo nice -n -20 perf stat -r 10 -d ./result

 Performance counter stats for './result' (10 runs):

       8852.363289      task-clock (msec)         #    1.429 CPUs utilized            ( +-  0.75% )
           276,398      context-switches          #    0.031 M/sec                    ( +-  0.56% )
             2,770      cpu-migrations            #    0.313 K/sec                    ( +- 19.76% )
            82,334      page-faults               #    0.009 M/sec                    ( +-  0.02% )
    24,528,934,839      cycles                    #    2.771 GHz                      ( +-  0.78% )  (49.99%)
   <not supported>      stalled-cycles-frontend
   <not supported>      stalled-cycles-backend
    24,190,047,542      instructions              #    0.99  insns per cycle          ( +-  0.13% )  (62.46%)
     4,085,706,131      branches                  #  461.538 M/sec                    ( +-  0.09% )  (74.10%)
        17,515,189      branch-misses             #    0.43% of all branches          ( +-  0.58% )  (74.18%)
     9,269,142,016      L1-dcache-loads           # 1047.081 M/sec                    ( +-  0.33% )  (64.24%)
       194,587,384      L1-dcache-load-misses     #    2.10% of all L1-dcache hits    ( +-  0.58% )  (30.41%)
        60,394,475      LLC-loads                 #    6.822 M/sec                    ( +-  1.38% )  (26.17%)
         2,946,358      LLC-load-misses           #    4.88% of all LL-cache hits     ( +-  2.99% )  (37.57%)

       6.195577571 seconds time elapsed                                          ( +-  0.63% )

```
6.195577571 seconds to setup, tear down and relay an incrementing integer daisy chain style between 10,000 `agents`.

#### Message pass and compute:
```
>>> 6.195577571 - 5.485212375
0.7103651960000006
```
This just gives you a feel for the system, 0.7 seconds to do 10,000 message sends and increments.

An important note, we've done *no* optimizations yet.

Lastly, we've also chosen to eschew `cargo` in favour of `nixcrates` which gives us a hermetically sealed build environment. We need help getting 1:1 compatibility with `cargo` but the early stages look very promising as a large majority of the top downloaded crates are buildable.

## Problem 1
* Language level modules become tightly coupled with the rest of the code.

## Solution
* Fractalide comes with its own actor oriented, message passing, declarative dataflow programming language called Flowscript (Flow-based programming (FBP) to be specific). Flowscript makes the concept of data flowing through a system into be a first class citizen, thus, easily manipulated by the programmer/designer.
* Flowscript enforces well-factored, independent `agents` within a single process that have strict boundaries and standardized API.
* This standardized API is key to `agent` composition and is achieved via a coordination layer called a `subgraph`, which describes how `agents` are connected and compose together. A `subgraph`, from an interface perspective, is indistinguishable from a Rust `agent`, this, neatly, allows for layers of abstraction which fall away at runtime.
* These `agents` are black boxes which are only dependent on data and not any other `agent`.
* Fractalide [agents](https://crates.io/crates/rustfbp) are Rust macros that compile to a shared library with a C ABI.
* Our choice of actors *do not have any* methods calls, but *do have* the typical functional `input-transform-output` approach which allows us to keep things simple to reason about. In other words, you're not going to find many any Remote Method Invocation here.

## Problem 2
* It's easy to disrespect API contracts in many microservices setups.

## Solution
* The Unix Pipe concept typically requires one to parse arbitrary `stdin`, which is troublesome, unless you're using Cap'n Proto schema which conveniently hands structured data to you.
* Each `Edge` in a Fractalide `Subgraph`/`Graph` of `Nodes` is actually a Cap'n Proto schema.
* Say a Fractalide upstream `Node` `U` might use `Edge` `X` to send data to downstream `Node` `D`, each `Node` will reference exactly the same `Edge` `X` by name alone, hence guaranteeing the two `agents` use the same schema. Indeed, one cannot connect the graph if `U`'s output port and `D`'s input port aren't the same `Edge`. Say you change `Edge` `X`'s schema, `nix` will lazily recompile `Node` `U` and `D` and the type checks will fail. Thus you're sure arbitrary changes to `Edges` will cause dependent `Nodes` to fail. Allowing you to have extremely high confidence that APIs are respected. This kind of behaviour isn't exhibited in other microservice deployments where components construct arbitrary JSON data structures.
* Fractalide `agents` communicate using `Cap'n Proto`schema , which is *`a type system for distributed systems`*, and is *`infinitely faster`* than protocol buffers ([read the website](http://capnproto.org)). Even better yet, Cap'n Proto schema can be extended without breaking `agents` with a different versions. That would be a problem if we weren't in complete control of versioning in a distributed system.

## Problem 3
* Knowing what versions and dependencies is a nightmare in many microservice setups. Especially when rolling back.

## Solution
* [Nix](http://nixos.org/nix) is a declarative lazy language and will make the system reflect your system description exactly.
* [Nixops](http://nixos.org/nixops) provides the means to do code delivery, whilst ensuring the entire cluster is at the expected version.
* Due to `nix`'s declarative behaviour, each service is intelligent enough to automatically setup its own dependencies such as a silo'ed data persistence store. They may also draw from the wealth of [crates.io](https://crates.io), allowing for non-trivial `agents` to be built easily.
* You might want to start learning `nix` with these fun [quizzes](https://nixcloud.io/tour/?id=1).

## Problem 4
* Updating a single or multiple service/s in an entire cluster of nodes can be hard in many microservices setups.

## Solution
* `nixops` will only stop, update and start a service if there has been a change to it, otherwise the service will continue working as per normal.

## Problem 5
* Security and business interests rarely align these days.

## Solution
##### Security
* Fractalide's `agents` are very strict about accepting data. Strongly inspired by the [langsec work](http://langsec.org) of Meredith Patterson, Len Sassaman and Dan Kaminsky. Fractalide makes use of the [Nom](https://github.com/Geal/nom) parser combinator, implemented by Geoffroy Couprie, to parse Flowscript. Components cannot connect together unless they use the same [Cap'n Proto](https://capnproto.org/) schema, which is implemented by David Renshaw, and the brain child of Kenton Varda. Of course, [Rust](https://www.rust-lang.org/), a high level systems language helps us prevent an entire class of buffer overflow exploits, without sacrificing speed for safety.

##### Business
* Flowscript allows for a separation of business logic and `agent` implementation logic. Thus programmers can easily own areas of code, or practise ["Sovereign Software Development"](https://top.fse.guru/the-civilized-alternative-to-agile-tribalism-4c60d01428c0), and given the [fast moving nature](https://medium.com/@bryanedds/living-in-the-age-of-software-fuckery-8859f81ca877) of business, a programmer can reuse `agents` and quickly manipulate data flowing through the system, or ideally, train the suits to manipulate the business logic themselves. Fractalide attempts to hand tools and techniques to the programmer to survive in such an environment.

### Steps towards stable release.
- [x] [Flowscript](https://en.wikipedia.org/wiki/Flow-based_programming) - a declarative dataflow language a little more suited to distributed computing.
- [x] [Fractals](fractals/README.md) - allowing you to create your own repositories outside the canonical Fractalide repository.
- [x] [HTTP support](https://github.com/fractalide/fractal_net_http).
- [ ] [Service composition](https://github.com/fractalide/fractal_workbench/blob/master/service.nix).
- [ ] Deployable example of a simple microservices setup.
- [ ] Documentation.
- [x] Remove cargo.
- [x] Stabilize `nodes`, `edges`, `subgraphs` and `agents` API.
- [x] Cap'n Proto schema composition.
- [ ] Reduce heap allocations.
- [X] Upgrade `nom` parser combinator to 2.0.
- [ ] 1.0 Stabilization version.

### Quick start
Fractalide supports whatever platform [Nix](http://nixos.org/nix) runs on. Quite possibly your package manager already has the `nix` [package](https://hydra.nixos.org/job/nix/master/release#tabs-constituents), please check first.
For the most efficient way forward, ensure you're using [NixOS](http://nixos.org), The Purely Functional Linux Distribution.

This codebase is currently in huge flux before stabilization, but at least you can build an agent using the new [nixcrates](https://github.com/fractalide/nixcrates) approach. Should hopefully be back to normal in a few days.
```
$ git clone https://github.com/fractalide/fractalide.git
$ cd fractalide
$ nix-build --argstr node workbench_test
$ ./result
```

### Documentation
* [Nodes](./nodes/README.md)
* [Edges](./edges/README.md)
* [Services](./services/README.md)
* [Fractals](./fractals/README.md)
* [RustFBP](https://docs.rs/rustfbp)

### Contributing to Fractalide
* The contributors are listed in [AUTHORS](./AUTHORS) (add yourself).
* Fractalide uses the [C4.2 (Collective Code Construction Contract)](CONTRIBUTING.md) process for contributions. Please read this if you are unfamiliar with it.
* Fractalide grows by the slow and careful accretion of simple, minimal solutions to real problems faced by many people.

### Consulting and Support
Name | Info | Language
-----|------|---------
[Stewart Mackenzie](mailto:setori88@gmail.com) | Founder and maintainer of Fractalide | English
[Denis Michiels](mailto:dmichiels@mailoo.org) | Founder and maintainer of Fractalide | French

### License
The project license is specified in LICENSE.
Fractalide is free software; you can redistribute it and/or modify it under the terms of the Mozilla Public License Version 2 as approved by the Free Software Foundation.

### Social
Follow us on [twitter](https://twitter.com/fractalide)

### Thanks
* Peter Van Roy
* Pieter Hintjens
* Joachim Schiele & Paul Seitz of [Nixcloud](https://nixcloud.io) who we commissioned to implement  [nixcrates](https://github.com/fractalide/nixcrates)
