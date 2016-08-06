![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/fractalide.png)
# Fractalide
 _**Exploding the design space**_

## Welcome

**Fractalide is a programming platform with an explosive design space**.

The canonical source of this project is hosted on [GitLab](https://gitlab.com/fractalide/fractalide), and is the preferred place for contributions, however if you do not wish to use GitLab, feel free to make issues, on the mirror. However pull requests will only be accepted on GitLab, to make it easy to maintain.

## Problem
Applications are too large and cannot easily be composed in granular ways.

## Solution
Break up applications into components with a strict set of inputs and outputs that have strict data contracts.
This approach dissolves the concept of an application boundary and allows the programmer/designer to compose components into a concept called a subnet (sub network of components). One could create a highly complex GUI subnet many layers deep and simply import it into another more simple subnet. The fluidity of this environment allows programmers to tell this codebase to build many different subnets from an editor, to a cryptocurrency. A simple analogy is; a Lego box contains blocks that can be snapped together into the shape of a horse or a house, except these Lego bricks can be magically shared between the horse and house at the same time.

Lastly, the strict contracts on inputs and outputs, whilst the component's logic being small enough to fit into the brain means it's much harder to create weird machines, a term widely used in [langsec](http://langsec.org). In the words of Meredith Patterson "What you're doing is good! Keep doing it!".

### Design requirements
* fast as greased lightning.
* an extremely low [CONOP](https://en.wikipedia.org/wiki/Concept_of_operations) factor; a single command should suffice to build any subnet, including automatically importing OS dependencies such as OpenSSL etc.
* easy to control data flowing through a system of reusable components with strict contracts on predefined inputs and outputs.

### Layers
- [x] Component Oriented Language built on Rust; components are implemented in Rust.
- [ ] HyperCard implementation; easy to learn, hard to master. Essentially creating a fun minecraft-esque programming environment.
- [ ] Cryptocurrency; gives programmers an incentive to build and support subnets. Noteworthy, this cryptocurrency is open to evolving at a much higher rate than other cryptocurrencies. Due to granular components it's much easier to create blockchain hard forks, whilst still sharing components. A fix to one component propagates to all cryptocurrencies sharing that component. Indeed we'll actively encourage blockchain hard forks, thus incorporating the best ideas of the community. May the best ideas win!
- [ ] Whatever you want, this is a [living system](https://hintjens.gitbooks.io/social-architecture/content/chapter6.html).

### Basic concepts
* **Components**: A component is a Rust library with a C ABI.
* **Ports**: A component has an arbitrary number of input and output ports.
* **IIP**: An Initial Information Packet is a packet of information sent at the start of a component's execution
* **IP**: Information Packets are serialized packets of information sent between components. They are Capnproto contracts

### Easy syntax

Example:

```
SUBNET_INPUT_PORT_NAME => component_input_port COMPONENT_INSTANCE_NAME(${COMPONENT_NAME}) component_output_port => SUBNET_OUTPUT_PORT_NAME
```

* **`=>`**: signifies either a virtual interface input or output of a subnet.
	* `SUBNET_INPUT_PORT_NAME => ...`.
	* `... => SUBNET_OUTPUT_PORT_NAME`.
* **`->`**: signifies a message passing activity.
	* `... component_output_port_name -> component_input_port_name ...`: indicates a serialized Information Packet is passed from the output port called `component_output_port_name` to the input port called `component_input_port_name`.
* **`COMPONENT_INSTANCE_NAME(...)`**: signifies the instantiation of a component. Once instantiated, the programmer may refer to the instance `COMPONENT_INSTANCE_NAME()` without text between the parenthesis.
* **`${...}`**: resolves the component name to the file system path the component is located at.
* **`component_instance_name(${COMPONENT_NAME})`**: is the name of the component, for example `app_counter_add`'s source code can be found in `fractalide/component/app/counter/add`. After compilation, either a textual file are a binary will be generated where all `${app_counter_add}` symbols resolve to `/nix/store/7bpb867x7rvj0i74ahhig5r4h6gampzv-app_counter_add`.
* **`'generic_i64:(number=0)' -> ...`**: represents an **IIP**, the `generic_i64` indicates a **contract** of type `generic_i64` is being used. The `number=0` means the field `number` is being initialized with a `0`.

### A simple counter
(we will run the counter in the `setup` section)
```
input => input in_dispatch(${ip_dispatcher}) output -> input out_dispatch(${ip_dispatcher}) output => output
model(${app_model}) output -> input view(${app_counter_view}) output -> input out_dispatch()
'generic_i64:(number=0)' -> acc model()
out_dispatch() output[add] -> input model()
out_dispatch() output[minus] -> input model()
out_dispatch() output[delta] -> input model()
in_dispatch() output[create] -> input view()
in_dispatch() output[delete] -> input view()
model() compute[add] -> input add(${app_counter_add}) output -> result model()
model() compute[minus] -> input minus(${app_counter_minus}) output -> result model()
model() compute[delta] -> input delta(${app_counter_delta}) output -> result model()
```

### Setup
Please read [Don't pipe to your shell](https://www.seancassidy.me/dont-pipe-to-your-shell.html), then read the script before you execute it. After you are comfortable with it, let's agree that the below one-liner is convenient. If you insist, there is [documentation](http://nixos.org/nix/manual/) to type this stuff manually.

Fractalide supports whatever platform Nix runs on, with the exception of Mac OS as Rust on Nix on Darwin doesn't work.

Run the command below as a user other than root (you will need `sudo`). Quite possibly your Linux package manager already has the `nix` package, please check first.

For the most efficient way forward ensure you're using [NixOS](http://nixos.org), The Purely Functional Linux Distribution.
```
$ git clone https://gitlab.com/fractalide/fractalide.git
$ cd fractalide
$ nix-build --argstr debug true --argstr subnet app_growtest
$ ./result/bin/app_growtest
```
Navigate your browser to `file:///home/user/path/to/fractalide/support/utils/page.html`

If you want to install a subnet into your environment directly, thus accessible from the command line:
```
$ nix-env -i -f default.nix --argstr app_growtest
$ app_growtest
```

### Incremental Builds
Fractalide expands the nix-build system for incremental builds. The Incremental Builds only work when debug is enabled. They also need the path to a cache folder.
The cache folder can be created from an old result by the buildCache.sh script. Per default the cache folder is saved in the /tmp folder of your system.

Here is an example how you can build with the Incremental Build System:

```
nix-build --argstr debug true --argstr cache $(./support/buildCache.sh) --argstr subnet test_sjm
```
If you're using NixOS, please ensure you have not set `nix.useSandbox = true;`, otherwise Incremental Compilation will fail.


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
