![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/fractalide.png)
# Fractalide
 _**Reusable Reproducible Rust Microservices**_

 [![LICENSE](https://img.shields.io/badge/license-MPLv2-blue.svg)](LICENSE)
 [![Join the chat at https://gitter.im/fractalide](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/fractalide?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

## Welcome

## What is this?

Fractalide is a free and open source service programming platform using dataflow graphs. Graph nodes represent computations, while graph edges represent typed data (may also describe tensors) communicated between them. This flexible architecture can be applied to many different computation problems, initially the focus will be Microservices to be expanded out into the Internet of Things.

Fractalide is in the same vein as the [NSA's Niagrafiles](https://en.wikipedia.org/wiki/Apache_NiFi) (now known as [Apache-NiFi](https://nifi.apache.org/)) or [Google's TensorFlow](https://en.wikipedia.org/wiki/TensorFlow) but stripped of all Java, Python and GUI bloat. Fractalide faces big corporate players like [Ab Initio](http://abinitio.com/), a company that charges a lot of money for dataflow solutions.

Truly reusable and reproducible efficient nodes is what differentiates Fractalide from the others. It's this feature that allows open communities to mix and match nodes quickly and easily.

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

Fractalide brings _*safe, fast, reusable, black-box*_ dataflow functions and a means to compose them.

*Tagline: "Nixpkgs is not enough! Here have 'Nixfuncs' too."*

### Rust Programmers

Fractalide brings _*reproducible, reusable, black-box*_ dataflow functions, a means to compose them and a [congruent](https://www.usenix.org/legacy/event/lisa02/tech/full_papers/traugott/traugott_html/) model of configuration management.

*Tagline: Safety extended beyond the application boundary into infrastructure.*

### Flow-based Programmers

Fractalide brings _*safe fast reproducible*_ classical Flow-based programming components, and a [congruent](https://www.usenix.org/legacy/event/lisa02/tech/full_papers/traugott/traugott_html/) model of configuration management.

*Tagline: Reproducible components!*

### Programmers

Fractalide brings _*safe, fast, reusable, reproducible, black-box*_ dataflow functions, a means to compose them and a [congruent](https://www.usenix.org/legacy/event/lisa02/tech/full_papers/traugott/traugott_html/) model of configuration management.

*Tagline: Here, have a beer!*

## Problem 0
* Language level modules become tightly coupled with the rest of the code, moving around these modules also poses a problem.

## Solution
An unanticipated outcome occurred when combining FBP and Nix. It's become our peanut butter and jam combination, so to say, but requires a bit of explaining, so hang tight.

### Reproducibility
Nix is a content addressable store, so is git, so is docker, except that docker's SHA resolution is at container level and git's SHA resolution is at changeset level. Nix on the other hand has a SHA resolution at package level, and it's known as a `derivation`. If you're trying to create reproducible systems this is the correct resolution. Too big and you're copying around large container sized images with multiple versions occupying gigabytes of space, too small and you run into problems of git not being able to scale to support thousands of binaries that build an operating system. Therefore Nix subsumes Docker.

Indeed it's these simple `derivations` that allow python 2.7 and 3.0 to exist side-by-side without conflicts. It's what allows the Nix community to compose an entire operating system, NixOS. These `derivations` are what makes NixOS a congruent configuration management system, and congruent systems are reproducible systems. They have to be.

### Reusability
Flow-based programming in our books has delivered on its promise. In our system FBP components are known as a `nodes` and they are reusable, clean and composable. It's a very nice way to program computers. Though, we've found, the larger the network of `nodes`, the more overhead required to build, manage, version, package, connect, test and distribute all these moving pieces. This really doesn't weigh well against FBP's advantages. Still, there is this beautiful reusable side that is highly advantageous! If only we could take the good parts?

### Reproducibility + Reusability
When nix is assigned the responsibility of declaratively building fbp `nodes`, a magic thing happens. All that manual overhead of having to build, manage and package etc gets done once and only once by the `node` author, and completely disappears for everyone thereafter. We're left with the reusable good parts that FBP has to offer. Indeed the greatest overhead a `node` user has, is typing the `node`'s name. We've gone further and distilled the overhead to a few lines, no more intimidating than a typical config file such as `Cargo.toml`:

``` nix
{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ PrimText FsPath ];
  crates = with crates; [ rustfbp capnp rusqlite ];
  osdeps = with pkgs; [ sqlite pkgconfig ];
}
```

Now just to be absolutely clear of the implications; it's possible to call an extremely complex community developed hierarchy of potentially 1000+ nodes, where each node might have different http://crates.io dependencies, they might have OS level dependencies such as `openssl` etc and nix will ensure the entire hierarchy is correctly built and made available. All this is done by just typing the `node` name and issuing a build command.

It's this feature that sets us apart from Google TensorFlow and Apache-NiFi. It contains the DNA to build a massive sprawling community of open source programmers, this and the C4, that is. It's our hope anyway!

## Problem 1
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

Fractalide does not violate the congruent model of Nix, and it's why NixOS is a dependency. Appreciation for safety has extended beyond the application boundary into infrastructure as a whole.

## Problem 2
* A language needed to be chosen to implement Fractalide. Now as Fractalide is primarily a Flow-based programming environment, it would be beneficial to choose a language that at least gets concurrency right.

## Solution
Rust was a perfect fit. The concept of ownership is critical in Flow-based Programming. The Flow-based scheduler is typically responsible for tracking every Information Packet (IP) as it flows through the system. Fortunately Rust excels at getting the concept of ownership right. To the point of leveraging this concept that a garbage collector is not needed. Indeed, different forms of concurrency can be layered on Rust's ownership concept. One very neat advantage Rust gives us is that we can very elegantly implement Flow-based Programming's idea of concurrency. This makes our scheduler extremely lightweight as it doesn't need to track IPs at all. Once an IP isn't owned by any component, Rust makes it wink out of existance, no harm to anyone.

## Problem 3
* It's easy to disrespect API contracts in a distributed services setup.

## Solution
We wanted to ensure there was no ambiguity about the shape of the data a node receives. Also if the shape of data changes, the error must be caught at compile time. Cap'n Proto schema fits these requirements, and fits them *perfectly* when nix builds the `nodes` calling the Cap'n Proto schema. Because, if a schema changes, nix will register the change and will rebuild everything (`nodes` and `subgraphs`) that depends on that schema, thus catching the error. We've also made it such, during graph load time `agents` cannot connect their ports unless they use the same Cap'n Proto schema. This is a very nice safety property.

### Steps towards BETA release.
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
- [x] Upgrade `nom` parser combinator to 2.0.
- [x] 1.0 Beta version.

### Steps towards STABLE release.
- [ ] tokio-rs integration
- [ ] nixpkgs lands support for [this](https://github.com/systemd/systemd/blob/master/NEWS#L53) feature in systemd 232
- [ ] [nixcrates](https://github.com/fractalide/nixcrates) needs some more work to whittle down crates that don't build
- [ ] stable release

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
* We don't do feature requests. If you can't create the feature yourself then you need to put money on the table and the job will be handed to a trustworthy community contributor. This prevents burn out. Though bugfixes will be quickly seen to!

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
