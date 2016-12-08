# Edge Collection

### What?

An `Edge` is a bounded buffer message passing channel between two ports belonging to their respective `agents`.

Terms:
* A `contract` is defined as: The Cap'n Proto schema on the output port of the upstream `agent` MUST be the same as the Cap'n Proto schema on the input port of the downstream `agent`. If the two  are the same, the `contract` is said to be satisfied, otherwise it is unsatisfied.

There are three phases building up to a successful `Edge` formation:
* During `agent development time` an `agent`'s port is assigned a Cap'n Proto schema.
* During `subgraph development time` the syntax `->` or `=>` is used to instruct an upstream `agent`'s port to connect to a downstream `agent`'s port at run-time. It represents a `connection` between two `nodes`. Though it is not yet an `edge` because the `contract` might not be satisfied.
* Lastly, the graph is successfully loaded into the virtual machine without errors. This act means all `agent` `contracts` were satisfied, and all `subgraph` `connections` are now classified as `edges`.

Once an `edge` is formed, it becomes a bounded buffer message passing channel, which can only contain `messages` with data in the shape of whatever the Cap'n Proto schema is.

So despite you seeing only Cap'n Proto schema in this directory, the concept of an `Edge` is  more profound. Hence we would prefer naming this concept after it's grandest manifestation, and in the process, the name encapsulates all of the above information. The name should also tie in with the concept of a `node` in graph theory, as such we use `nodes` and `edges` to construct `subgraphs`.

#### Exposed Edge

When developing a `subgraph` there comes a time when the developer wants to inject data into an `agent` or another `subgraph`. One needs to use an `exposed edge` which has this syntax:

``` nix
{ subgraph, nodes, edges }:

subgraph {
  src = ./.;
  flowscript = with nodes; with edges; ''
    '${maths_boolean}:(boolean=true)' -> INPUT_PORT NAME()
  '';
}
```

`Exposed edges` allow `agents` to be kick started. Due to the dataflow nature of `agents` they will politely wait for data before they start doing anything. This is the equivalent of passing the path of a data source to some executable on the command line. Without the argument the program would just sit or fail. Another way of looking at it might be a pipeline that has come to the surface to accept some form of input.

#### Hidden Edge

`Hidden edges` are represented with this syntax `->` and `=>`, and they are used to control the flow direction of the data. Hence the process of programming a `subgraph` is essentially digging ditches and laying pipes.

* From one `agent` to another `agent`:

``` nix
{ subgraph, nodes, edges }:

subgraph {
  src = ./.;
  flowscript = with nodes; with edges; ''
    agent1() output -> input agent2()
  '';
}
```
* Into a `subgraph`:

``` nix
{ subgraph, nodes, edges }:

subgraph {
  src = ./.;
  flowscript = with nodes; with edges; ''
    output => input subgraph()
  '';
}
```
* Out of a `subgraph`:

``` nix
{ subgraph, nodes, edges }:

subgraph {
  src = ./.;
  flowscript = with nodes; with edges; ''
    agent() output => output
  '';
}
```


### Why?

Contracts between components are critical for creating [living systems](https://hintjens.gitbooks.io/social-architecture/content/chapter6.html).

### Who?

Typically `subgraph` developers will be interested in `hidden and exposed edges`.

### Where?

The `edges` directory is where all the schema go:

```
├── key
│   └── value
│       └── default.nix
├── list
│   ├── command
│   │   └── default.nix
│   ├── text
│   │   └── default.nix
│   ├── triple
│   │   └── default.nix
│   └── tuple
│       └── default.nix
├── maths
│   ├── boolean
│   │   └── default.nix
│   └── number
│       └── default.nix
```

### How?

`Edges` may depend on other `edges`.

The `{ edge, edges }:` lambda passes in two arguments, the `edge` builder and `edges` which consists of every `Edge` or `Edge Namespace` in the system.
The `edge` building function accepts these arguments:
  * The `src` attribute is used to derive an `Edge` name based on location in the directory hierarchy.
  * The `edges` attribute resolve transitive dependencies and ensures your `agent` has all the needed files to type check.
  * a [Cap 'n Proto](https://capnproto.org) `schema`. This is the heart of the contract, this is where you may create potentially complex deep hierarchies of structured data. Please read more about the [schema language](https://capnproto.org/language.html).

``` nix
{ edge, edges }:

edge {
  src = ./.;
  edge = with edges; [ command ];
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
