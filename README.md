![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/fractalide.png)
# Fractalide
 _**Simple Rust Microservices**_

 [![LICENSE](https://img.shields.io/badge/license-MPLv2-blue.svg)](LICENSE)
 [![Join the chat at https://gitter.im/fractalide](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/fractalide?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

## Welcome

**Fractalide provides a Flow-based programming language, a build system and an approach to distribution, with the aim of making efficient microservices simple to reason about.**

The canonical source of this project is hosted on [GitLab](https://gitlab.com/fractalide/fractalide), and is the preferred place for contributions, however if you do not wish to use GitLab, feel free to make issues, on the mirror. However pull requests will only be accepted on GitLab, to make it easy to maintain.

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

## What's new from different perspectives

### Nix Programmers

Fractalide brings _*safe fast reusable black-box*_ dataflow functions and a means to compose them.

### Rust Programmers

Fractalide brings _*reproducible reusable black-box*_ dataflow functions, a means to compose them and a system configuration management using the [congruent model](https://www.usenix.org/legacy/event/lisa02/tech/full_papers/traugott/traugott_html/).

### Flow-based Programmers

Fractalide brings _*safe fast reproducible*_ classical Flow-based programming components, and a system configuration management using the [congruent model](https://www.usenix.org/legacy/event/lisa02/tech/full_papers/traugott/traugott_html/).

## Problem 0 (Justify NixOS)
* The vast majority of system configuration management solutions use either the divergent or convergent model.

We're going to quote Steve Traugott's excellent work vebatim.

### Divergent
![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/divergent.png)

"One quick way to tell if a shop is divergent is to ask how changes are made on production hosts, how those same changes are incorporated into the baseline build for new or replacement hosts, and how they are made on hosts that were down at the time the change was first deployed. If you get different answers, then the shop is likely divergent.

The symptoms of divergence include unpredictable host behavior, unscheduled downtime, unexpected package and patch installation failure, unclosed security vulnerabilities, significant time spent "firefighting", and high troubleshooting and maintenance costs." - Steve Traugott

### Convergent
![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/convergent.png)

"The baseline description in a converging infrastructure is characteristically an incomplete description of machine state. You can quickly detect convergence in a shop by asking how many files are currently under management control. If an approximate answer is readily available and is on the order of a few hundred files or less, then the shop is likely converging legacy machines on a file-by-file basis.

A convergence tool is an excellent means of bringing some semblance of order to a chaotic infrastructure. Convergent tools typically work by sampling a small subset of the disk - via a checksum of one or more files, for example - and taking some action in response to what they find. The samples and actions are often defined in a declarative or descriptive language that is optimized for this use. This emulates and preempts the firefighting behavior of a reactive human systems administrator - "see a problem, fix it." Automating this process provides great economies of scale and speed over doing the same thing manually.

Because convergence typically includes an intentional process of managing a specific subset of files, there will always be unmanaged files on each host. Whether current differences between unmanaged files will have an impact on future changes is undecidable, because at any point in time we do not know the entire set of future changes, or what files they will depend on.

It appears that a central problem with convergent administration of an initially divergent infrastructure is that there is no documentation or knowledge as to when convergence is complete. One must treat the whole infrastructure as if the convergence is incomplete, whether it is or not. So without more information, an attempt to converge formerly divergent hosts to an ideal configuration is a never-ending process. By contrast, an infrastructure based upon first loading a known baseline configuration on all hosts, and limited to purely orthogonal and non-interacting sets of changes, implements congruence. Unfortunately, this is not the way most shops use convergent tools..." - Steve Traugott

## Solution
### Congruent
![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/congruent.png)

"By definition, divergence from baseline disk state in a congruent environment is symptomatic of a failure of code, administrative procedures, or security. In any of these three cases, we may not be able to assume that we know exactly which disk content was damaged. It is usually safe to handle all three cases as a security breach: correct the root cause, then rebuild.

You can detect congruence in a shop by asking how the oldest, most complex machine in the infrastructure would be rebuilt if destroyed. If years of sysadmin work can be replayed in an hour, unattended, without resorting to backups, and only user data need be restored from tape, then host management is likely congruent.

Rebuilds in a congruent infrastructure are completely unattended and generally faster than in any other; anywhere from ten minutes for a simple workstation to two hours for a node in a complex high-availability server cluster (most of that two hours is spent in blocking sleeps while meeting barrier conditions with other nodes).

Symptoms of a congruent infrastructure include rapid, predictable, "fire-and-forget" deployments and changes. Disaster recovery and production sites can be easily maintained or rebuilt on demand in a bit-for-bit identical state. Changes are not tested for the first time in production, and there are no unforeseen differences between hosts. Unscheduled production downtime is reduced to that caused by hardware and application problems; firefighting activities drop considerably. Old and new hosts are equally predictable and maintainable, and there are fewer host classes to maintain. There are no ad-hoc or manual changes. We have found that congruence makes cost of ownership much lower, and reliability much higher, than any other method." - Steve Traugott

Fractalide does not violate the congruent model of Nix, and it's why NixOS is a dependency. Appreciation for safety has extended beyond the (Rust) application boundary into infrastructure as a whole.

## Problem 1 (Justify Rust)
* A language needed to be chosen to implement Fractalide. Now as Fractalide is primarily a Flow-based programming environment, it would be beneficial to choose a language that at least gets concurrency right.

## Solution
Rust was a perfect fit. The concept of ownership is critical in Flow-based Programming. The Flow-based scheduler is typically responsible for tracking every Information Packet (IP) as it flows through the system. Fortunately Rust excels at getting the concept of ownership right. To the point of leveraging this concept that a garbage collector is not needed. Indeed, different forms of concurrency can be layered on Rust's ownership concept. One very neat advantage Rust gives us is that we can very elegantly implement Flow-based Programming's idea of concurrency. This makes our scheduler extremely lightweight as it doesn't need to track IPs at all. Once an IP isn't owned by any component, Rust makes it wink out of existance, no harm to anyone.

## Problem 2 (Justify Flow-based Programming + Nix)
* Language level modules become tightly coupled with the rest of the code, moving around these modules also poses a problem.

## Solution
A neat outcome we never anticipated when combining FBP and Nix. This is the peanut butter and jam combination. It requires a bit of explaining, so hang tight.

### Reproducibility
Nix is a content addressable store, so is git, so is docker, except that docker's SHA resolution is at container level and git's SHA resolution is at changeset level. Nix on the other hand has a SHA resolution at package level, it's known as a `derivation` and if you're trying to create a reproducible system this is the correct resolution. Too big and you're copying around large container sized images that occupy gigabytes of space, too small and you run into problems of git not being able to scale to support hundreds of binaries that build an operating system.

Nix also keeps track of all the dependent derivations, build steps and other attributes of the derivation to be built. Using this method it's quite possible to have a number of python interpreters living side-by-side without conflicting. One can merely by name pull python 2.7 into an environment, and in another environment pull in python 3.

Indeed the sheer power of these simple `derivations` is what allows the Nix community to compose an entire operating system, NixOS. This is what makes NixOS a congruent configuration management system, and congruent systems are reproducible systems. They have to be.

### Reusability
Flow-based programming in our books has delivered on it's promise. Components are reusable, they are clean and composable. It's a very nice way to program computers. Though, we found, the larger the network of components grow the more overhead required to build, manage versioning, package, connect, test and distribute all these moving pieces. This really doesn't play to FBP's advantage, indeed we'll go as far as to say it's the primary reason FBP hasn't become mainstream. The negatives outweigh the positives. Still there is this beautiful reusable side that is highly advantageous! If only we could take the good parts?

### Reproducibility + Reusability
Quite by chance, when nix is assigned the resposibility of declaratively building fbp components, a magic thing happens. All that overhead of having to build, manage and package gets manually done once by the component author, and completely disappears for everyone else! We're left with a neat reusable and reproducible fbp components, which can be called into scope by name and name alone! This to us is quite nice.

Indeed, it's possible to call an extremely complex hierarchy of potentially 1000 nodes, where each node might have different crates.io dependencies and nix will ensure the entire hierarchy is correctly built and made available.

## Problem 3 (Justify Capnproto)
* It's easy to disrespect API contracts in many microservices setups.

## Solution
* The Unix Pipe concept typically requires one to parse arbitrary `stdin`, which is troublesome, unless you're using Cap'n Proto schema which conveniently hands structured data to you.
* Each `Edge` in a Fractalide `Subgraph`/`Graph` of `Nodes` is actually a Cap'n Proto schema.
* Say a Fractalide upstream `Node` `U` might use `Edge` `X` to send data to downstream `Node` `D`, each `Node` will reference exactly the same `Edge` `X` by name alone, hence guaranteeing the two `agents` use the same schema. Indeed, one cannot connect the graph if `U`'s output port and `D`'s input port aren't the same `Edge`. Say you change `Edge` `X`'s schema, `nix` will lazily recompile `Node` `U` and `D` and the type checks will fail. Thus you're sure arbitrary changes to `Edges` will cause dependent `Nodes` to fail. Allowing you to have extremely high confidence that APIs are respected. This kind of behaviour isn't exhibited in other microservice deployments where components construct arbitrary JSON data structures.
* Fractalide `agents` communicate using `Cap'n Proto`schema , which is *`a type system for distributed systems`*, and is *`infinitely faster`* than protocol buffers ([read the website](http://capnproto.org)). Even better yet, Cap'n Proto schema can be extended without breaking `agents` with a different versions. That would be a problem if we weren't in complete control of versioning in a distributed system.

### Steps towards stable release.
- [x] [Flowscript](https://en.wikipedia.org/wiki/Flow-based_programming) - a declarative dataflow language a little more suited to distributed computing.
- [x] [Fractals](fractals/README.md) - allowing you to create your own repositories outside the canonical Fractalide repository.
- [x] [HTTP support](https://github.com/fractalide/fractal_net_http).
- [x] [Service composition](https://github.com/fractalide/fractal_workbench/blob/master/service.nix).
- [x] Deployable example of a simple microservices setup.
- [x] Documentation.
- [x] Remove cargo.
- [x] Stabilize `nodes`, `edges`, `subgraphs` and `agents` API.
- [x] Cap'n Proto schema composition.
- [x] Reduce heap allocations.
- [X] Upgrade `nom` parser combinator to 2.0.
- [ ] 1.0 Stabilization version.

### The mandatory Hello-like World example.

From a fresh install of NixOS (using the `nixos-unstable` channel) we'll build the `fractalide virtual machine (fvm)` and execute the humble NAND logic gate on it.
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

### Documentation
* [Nodes](./nodes/README.md)
* [Edges](./edges/README.md)
* [Services](./services/README.md)
* [Fractals](./fractals/README.md)
* [HOWTO](./HOWTO.md)
* [RustFBP](https://docs.rs/rustfbp)

### Contributing to Fractalide
* Contributors are listed in [AUTHORS](./AUTHORS). Copyright is distributed far and wide throughout the community to prevent corporate takeovers and lockins.
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
