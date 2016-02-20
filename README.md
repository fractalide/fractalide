# Fractalide

Fractalide is a programming platform which removes three classes of errors.
* [Memory safety](https://en.wikipedia.org/wiki/Rust_(programming_language))
* [Dependency hell](https://en.wikipedia.org/wiki/Dependency_hell)
* [Code reuse](http://www.jpaulmorrison.com/fbp/fbp2.htm)

## Memory Safety

Fractalide components are implemented in Rust, a language which gives the programmer [fearless control](http://blog.rust-lang.org/2015/04/10/Fearless-Concurrency.html) over speed, concurrency and memory safety.

## Dependency Hell

Fractalide uses [Nix](http://nixos.org/nix/) as a replacement for [make](https://www.gnu.org/software/make/). Indeed, it seems Fractalide is the first programming language to exclusively use nix as a [package manager](https://www.youtube.com/watch?v=dQLO5CWuGVk). Each component is able to setup it's own OS environment, which might include database drivers written in C, specific versions of an executable or pull in a programming language like python. The package manager is lazily evaluated, thus only those dependencies needed will be compiled. This allows us to have an extremely large repository filled with possibly millions of components.

## Code reuse

The use of Flow-based programming gives us the ability to combine and concatenate programs in ways never anticipated. Much like the BASH shell coordinates the execution of GNU utils and other executables in neat, sneaky ways. This is a sign of a high reusability factor.

"Flow-based Programming defines applications as networks of "black box" processes, which exchange data across predefined connections by message passing, where the connections are specified externally to the processes. These black box processes can be reconnected endlessly to form different applications without having to be changed internally. FBP is thus naturally component-oriented." - J Paul Morrison.

Flow script is just a coordination language for Rust shared objects.

A contrived example of displaying the output of an XOR gate to the terminal:
```
'maths_boolean:(boolean=false)' -> a xor(maths_boolean_xor) output -> input disp(maths_boolean_print)
'maths_boolean:(boolean=false)' -> b xor()
```

Explanation:

* `'maths_boolean:(boolean=false)'` is an `IIP (Initial Information Packet)` which tells the virtual machine to use the `maths_boolean` capnproto contract which can be found in the `contracts/maths/boolean` folder. The `:(boolean=false)` bit puts the value `false` into the `boolean` field of `maths_boolean`
* `->` means message pass the `IIP` to the input `a` of `xor()`. `xor()` is an initialized variable of the type `maths_boolean_xor` which can be found in `components/maths/boolean/xor` folder. Thereafter you may simply refer to `xor()` without the `maths_boolean_xor`.
* `output` is the output of `xor` which feeds into `input` of `disp()`, which is of type `maths_boolean_print` located in `components/maths/boolean/print`
* Contract `maths_boolean` looks like this: [maths_boolean](https://github.com/fractalide/fractalide/blob/master/contracts/maths/boolean/contract.capnp)
* `maths_boolean_xor` is a subnet which looks like this: [maths_boolean_xor](https://github.com/fractalide/fractalide/blob/master/components/maths/boolean/xor/default.nix)
* `maths_boolean_print` is implemented in Rust, and is a shared library, it looks like this: [maths_boolean_print](https://github.com/fractalide/fractalide/blob/master/components/maths/boolean/print/src/lib.rs)

For more details, follow the setup steps below which will show you how to compile the [docs](https://github.com/fractalide/fractalide/blob/master/components/docs/default.nix). This component will teach you how to build a NOT logic gate.

From there, you go native.

## Setup

Run this command as a user other than root (you will need `sudo`). To uninstall simply `rm -fr /nix`. See this [blog post](https://www.domenkozar.com/2014/01/02/getting-started-with-nix-package-manager/) for more detailed information.

`$ curl https://nixos.org/nix/install | sh` (ignore if on nixos)

`$ source ~/.nix-profile/etc/profile.d/nix.sh` (ignore if on nixos)

`$ git clone git://github.com/fractalide/fractalide`

`$ cd fractalide`

`$  nix-build --argstr debug true --argstr subnet docs`

Congratulations, you just built your first Fractalide executable, now let's run it:

`$ ./result/bin/docs`

This serves up the Quick Start manual section on [http://localhost:8083/docs/manual.html](http://localhost:8083/docs/manual.html).

This is what the code you just ran [looks like](https://github.com/fractalide/fractalide/blob/master/components/docs/default.nix#L12-L15).

Happy Hacking!
