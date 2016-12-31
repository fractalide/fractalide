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

Lastly, we've also chosen to eschew `cargo` in favour of `nixcrates` which gives us a hermetically sealed build environment. We need help getting 1:1 compatibility with `cargo` but the early stages look very promising as a large majority of the top downloaded crates are buildable.

## Quick feel of the system

#### A = (Graph setup + tear down):

```
$ nix-build --argstr node bench_load
/nix/store/ij8jri0z1k5n447f9s0x5yfx5p9iqnnf-bench_load

$ sudo nice -n -20 perf stat -r 10 -d ./result

 Performance counter stats for './result' (10 runs):

       5397.977660      task-clock (msec)         #    1.465 CPUs utilized            ( +-  0.63% )
           204,241      context-switches          #    0.038 M/sec                    ( +-  0.73% )
             3,400      cpu-migrations            #    0.630 K/sec                    ( +- 22.68% )
            41,365      page-faults               #    0.008 M/sec                    ( +-  0.04% )
    15,024,216,407      cycles                    #    2.783 GHz                      ( +-  0.82% )  (50.25%)
   <not supported>      stalled-cycles-frontend  
   <not supported>      stalled-cycles-backend   
    15,651,196,604      instructions              #    1.04  insns per cycle          ( +-  0.15% )  (62.85%)
     2,555,892,181      branches                  #  473.491 M/sec                    ( +-  0.09% )  (74.17%)
        11,337,183      branch-misses             #    0.44% of all branches          ( +-  0.55% )  (74.11%)
     5,914,501,986      L1-dcache-loads           # 1095.688 M/sec                    ( +-  0.37% )  (62.87%)
       145,243,685      L1-dcache-load-misses     #    2.46% of all L1-dcache hits    ( +-  1.22% )  (30.43%)
        38,047,116      LLC-loads                 #    7.048 M/sec                    ( +-  0.74% )  (26.35%)
         2,309,527      LLC-load-misses           #    6.07% of all LL-cache hits     ( +-  1.71% )  (37.76%)

       3.684139058 seconds time elapsed                                          ( +-  0.56% )
```

#### B = (Graph setup + tear down + message pass + increment):

```

$ nix-build --argstr node bench
/nix/store/mfl206ccv86wvyi2ra5296l8n1bks24x-bench

$ sudo nice -n -20 perf stat -r 10 -d ./result

 Performance counter stats for './result' (10 runs):

       6638.755996      task-clock (msec)         #    1.443 CPUs utilized            ( +-  0.57% )
           268,864      context-switches          #    0.040 M/sec                    ( +-  0.47% )
             3,047      cpu-migrations            #    0.459 K/sec                    ( +- 10.08% )
            82,417      page-faults               #    0.012 M/sec                    ( +-  0.03% )
    18,012,749,608      cycles                    #    2.713 GHz                      ( +-  0.66% )  (50.10%)
   <not supported>      stalled-cycles-frontend  
   <not supported>      stalled-cycles-backend   
    18,396,303,772      instructions              #    1.02  insns per cycle          ( +-  0.10% )  (62.48%)
     3,008,536,908      branches                  #  453.178 M/sec                    ( +-  0.06% )  (73.97%)
        13,396,472      branch-misses             #    0.45% of all branches          ( +-  1.01% )  (74.08%)
     6,955,828,023      L1-dcache-loads           # 1047.761 M/sec                    ( +-  0.50% )  (63.04%)
       184,998,022      L1-dcache-load-misses     #    2.66% of all L1-dcache hits    ( +-  0.81% )  (29.73%)
        49,018,759      LLC-loads                 #    7.384 M/sec                    ( +-  0.99% )  (26.13%)
         3,032,354      LLC-load-misses           #    6.19% of all LL-cache hits     ( +-  1.56% )  (37.74%)

       4.601455409 seconds time elapsed                                          ( +-  0.66% )


```
#### (Message Passing + Increment) = B - A:

```
>>> 4.601455409 - 3.684139058
0.9173163509999998
```

This just gives you a *feel* for the system:
* `3.7 secs` to setup `10,000` [rust agents](./nodes/bench/inc/lib.rs) + teardown `10,000` agents.
* `4.6 sces` to setup `10,000` agents + message pass `10,000` times + increment `10,000` times + teardown `10,000` `agents`.
* `0.9 sec` to message pass `10,000` times + increment `10,000` times.

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
- [x] Reduce heap allocations.
- [X] Upgrade `nom` parser combinator to 2.0.
- [ ] 1.0 Stabilization version.

### Quick start
Fractalide is meant to be run on [NixOS](http://nixos.org/nixos), though if you're not going to be doing any service configuration management then many of the `subgraphs` will execute on the [nix](http://nixos.org/nix) package manage which should be on your linux distro's package manager:
For the most efficient way forward, ensure you're using [NixOS](http://nixos.org), The Purely Functional Linux Distribution.

So from a fresh install of NixOS (using the `nixos-unstable` channel) we'll build the `fractalide virtual machine (fvm)` and execute the humble NAND logic gate on it.
```
$ git clone https://github.com/fractalide/fractalide.git
$ cd fractalide
$ time nix-build --argstr node test_nand
...
/nix/store/zld4d7zc80wh38qhn00jqgc6lybd2cdi-test_nand

real    2m40.590s
user    0m0.338s
sys     0m0.079s
$ ./result
boolean : false
```

Let's benchmark the setup, teardown, message passes and increments of `10,000` messages between `10,000` agents, note the `fvm` is now already built, so it won't be built again unless you make a change to it.

```
$ time nix-build --argstr node bench
/nix/store/r4gb7k9hsv2iblzh1pj21wbg6mc21xab-bench

real    0m7.437s
user    0m0.301s
sys     0m0.048s
$ sudo nice -n -20 perf stat -r 10 -d ./result
(see results above)
```
Now let's benchmark just the setup and teardown, note the `nodes/bench/inc` `agent` is previously built and tucked away in it's own `nix derivation`.

```
$ time nix-build --argstr node bench_load
/nix/store/w1yln248p0788byxvhpmdw2y4cz44gvv-bench_load

real    0m2.259s
user    0m0.304s
sys     0m0.038s
$ sudo nice -n -20 perf stat -r 10 -d ./result
(see results above)
```

For the sake of consistency, let's increment `2` instead of `1` in `nodes/bench/inc`, and recompile:

```
$ time nix-build --argstr node bench
/nix/store/cqzgazshva4j1rz9fqxjqak513ijggvm-bench

real    0m7.103s
user    0m0.300s
sys     0m0.046s
```

The system will only lazily compile code that has changed. If you change a low level Cap'n Proto schema everything that depends on that called schema will be recompiled automatically.

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
