![Image Alt](https://raw.githubusercontent.com/fractalide/fractalide/master/doc/images/fractalide.png)
# Fractalide
 _**Cheapest Disseminations Ever**_

## Welcome

**Fractalide is a Browser for a Named Data Network**.

The canonical source of this project is hosted on [GitLab](https://gitlab.com/fractalide/fractalide), and is the preferred place for contributions, however if you do not wish to use GitLab, feel free to make issues, on the mirror. However pull requests will only be accepted on GitLab, to make it easy to maintain.

## Problem
Disseminations over a point-to-point communications system (TCP/IP) are costly and technically complex, requiring expensive hardware and engineers to overcome the problem. Look at the company valuations of the Internet Giants to get a rough idea of how costly this problem is.

## Solution
Named Data Networking builds the concept of dissemination into the protocol, making disseminations extremely cheap, yet retaining use of the ubiquitous TCP/IP network, as Named Data Networking is an optional TCP/IP overlay.

### Rationale for a Named Data Network Browser
TCP/IP blossomed after the HTTP browser was created, so, it's anticipated, that Named Data Networking will blossom once a Named Data Networking browser is created.

### Design requirements
Our design requirements are:
* blazingly fast.
* easy to create applications.
* application components must be modular and reusable, making it friendly for dissemination.
* encrypt data, not channels.
* support multiple architectures.

### Layers
- [x] Component Oriented Language built on Rust (completed)
- [ ] HyperCard implementation (in progress)
- [ ] Name Data Networking implementation (in progress)
- [ ] Crypto-contract implementation

### Basic concepts
* **Components**: A component is a Rust library with a C ABI.
* **Ports**: A component has an arbitrary number of input and output ports.
* **IIP**: An Initial Information Packet is a packet of information sent at the start of a component's execution
* **IP**: Information Packets are serialized packets of information sent between components. They are Capnproto contracts

### Easy syntax

Example:

`INTERFACE_IN => component_input INSTANCE_NAME(${COMPONENT_NAME}) component_output => INTERFACE_OUT`

* **`=>`**: signifies either an interface input or output.
	* `INTERFACE_INPUT_NAME => ...` .
	* `... => INTERFACE_OUTPUT_NAME`.
* **`->`**: signifies a message passing activity.
	* `... component_output_port_name -> component_input_port_name ...`: indicates a serialized Information Packet is passed from the output port called `component_output_port_name` to the input port called `component_input_port_name`.
* **`COMPONENT_INSTANCE_NAME(...)`**: signifies the instantiation of a component. Once instantiated, the programmer may refer to the instance `COMPONENT_INSTANCE_NAME()` without text between the parenthesis.
* **`${...}`**: resolves the component name to the file system path the component is located at.
* **`component_instance_name(${COMPONENT_NAME})`**: is the name of the component, for example `app_counter_add`'s source code can be found in `fractalide/component/app/counter/add`. After compilation, either a textual file are a binary will be generated where all `${app_counter_add}` symbols resolve to `/nix/store/7bpb867x7rvj0i74ahhig5r4h6gampzv-app_counter_add`.
* `'generic_i64:(number=0)' -> ...`: represents an **IIP**, the `generic_i64` indicates a **contract** of type `generic_i64` is being used. The `number=0` means the field `number` is being initialized with a `0`.



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

* `$ curl https://nixos.org/nix/install | sh` _(ignore if on nixos, or if you installed `nix` via your package manager)_
* `$ source ~/.nix-profile/etc/profile.d/nix.sh` _(ignore if on nixos, or if you installed `nix` via your package manager)_
* `$ git clone https://gitlab.com/fractalide/fractalide.git`
* `$ cd fractalide`
* `$  nix-build --argstr debug true --argstr subnet app_growtest`
* `$ ./result/bin/app_growtest`
* navigate your browser to `file:///home/user/path/to/fractalide/page.html`
* To uninstall simply `rm -fr /nix` _(ignore if on nixos, or if you installed `nix` via your package manager)_.

Happy Hacking!


### Contributing to Fractalide

The contributors are listed in `fractalide/build-support/upkeepers.nix` (add yourself).

Please read this document BEFORE you send a patch:

* Fractalide uses the [C4.1 (Collective Code Construction Contract)](http://rfc.zeromq.org/spec:22) process for contributions. Please read this if you are unfamiliar with it.

Fractalide grows by the slow and careful accretion of simple, minimal solutions to real problems faced by many people. Some people seem to not understand this. So in case of doubt:

* Each patch defines one clear and agreed problem, and one clear, minimal, plausible solution. If you come with a large, complex problem and a large, complex solution, you will provoke a negative reaction from Fractalide maintainers and users.

* We will usually merge patches aggressively, without a blocking review. If you send us bad patches, without taking the care to read and understand our rules, that reflects on you. Do NOT expect us to do your homework for you.

* As rapidly we will merge poor quality patches, we will remove them again. If you insist on arguing about this and trying to justify your changes, we will simply ignore you and your patches. If you still insist, we will ban you.

* Fractalide is not a sandbox where "anything goes until the next stable release". If you want to experiment, please work in your own projects.


### License

The project license is specified in LICENSE.

Fractalide is free software; you can redistribute it and/or modify it under the terms of the Mozilla Public License Version 2 as approved by the Free Software Foundation.
