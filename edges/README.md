# Edge Collection

### What?

An `Edge` is a bounded buffer message passing channel between two ports belonging to their respective `agents`.

Terms:
* A `contract` is defined as: The Cap'n Proto schema on the output port of the upstream `agent` MUST be the same as the Cap'n Proto schema on the input port of the downstream `agent`. If the two `schemas` are the same, the `contract` is said to be satisfied, otherwise it is unsatisfied.

There are three phases building up to a successful `Edge` formation:
* During `agent development time` an `agent`'s port is assigned a Cap'n Proto schema.
* During `subgraph development time` the syntax `->` or `=>` is used to instruct an upstream `agent`'s port to connect to a downstream `agent`'s port at run-time. It represents a `connection` between two `nodes`. Though it is not yet an `edge` because the `contract` might not be satisfied.
* Lastly, the graph is successfully loaded into the virtual machine without errors. This act means all `agent` `contracts` were satisfied, and all `subgraph` connections are now classified as `edges`.

Once an `Edge` is formed, it becomes a bounded buffer message passing channel, which can only contain `messages` with data in the shape of whatever the Cap'n Proto schema is.

So despite you seeing only Cap'n Proto schemas in this directory, the concept of an `Edge` is  more profound. Hence we would prefer naming this concept after it's grandest manifestation, and in the process, the name encapsulates all of the above information. The name should also tie in with the concept of a `node` in graph theory, as such we use `nodes` and `edges` to construct `subgraphs`.

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
