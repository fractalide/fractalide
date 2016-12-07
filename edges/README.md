# Contracts

### What?

Contracts allow us to keep components separated yet retain a notion of types. The author of `capnproto-rust` refers to `capnproto` as a `type system for a distributed system`.

### Why?

The use of contracts ensures a component is going to get data it will be able to understand, otherwise it will fail at compile time.

### Who?

Everyone building components must build contracts to transport data.

### Where?

The `contracts` folder is where all the contracts go.

### How?

Contracts may depend on other contracts.

The `{ edge, edges }:` indicates a function with two arguments pulled in, a contract building function called `contract` and every other contract in the system via the `contracts` attribute.
The `contract` building function accepts three arguments:
* `src`: this is the current folder in the hierarchy your contract is situated, a naming function inside the `contract` function will derive the contract name from the folder hierarchy. Typically this will always be `./.`. (if you know how to hide this tell me)
* `contracts`: This argument is critical because there's a mechanism in the `contract` function which works out transitive dependencies. i.e. A `list_command` contract actually contains a `command` contract and a `tuple` contract. Command needs a `tuple`, this process ensures we're able to work out transitive dependencies and hands them to your component just before compilation.
* a [Cap 'n Proto](https://capnproto.org) `schema`. This is the heart of the contract, this is where you may create potentially complex deep hierarchies of structured data. Please read more about the [schema language](https://capnproto.org/language.html).

``` nix
{ edge, edges }:

edge {
  src = ./.;
   command ];
  schema = with edges; ''
    @0xf61e7fcd2b18d862;
    using Command = import "${command}/src/edge.capnp";
    struct ListCommand {
        commands @0 :List(Command.Command);
    }
  '';
}
```

Out of curiosity what does the output of the above `list_command` `contract` function look like?

```
$ cat /nix/store/3s25icpbf1chayvrxwbyxr9qckn7x669-list_command/src/edge.capnp
@0xf61e7fcd2b18d862;
using Command = import "/nix/store/bgh37035cbr49r7mracmdwwjx9sbf4nr-command/src/edge.capnp";

struct ListCommand {
    commands @0 :List(Command.Command);
}
```

The generated Rust code consists of the `list_command`, `command` and `tuple` contract concatenated together. 
