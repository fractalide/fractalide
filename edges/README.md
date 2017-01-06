# Edge Collection

### What?

An `Edge` is a bounded buffer message passing channel between two ports belonging to their respective `agents`.

Terms:
* A `contract` is defined as: The Cap'n Proto schema on the output port of the upstream `agent` MUST be the same as the Cap'n Proto schema on the input port of the downstream `agent`. If the two  are the same, the `contract` is said to be satisfied, otherwise it is unsatisfied.

There are three phases building up to a successful `Edge` formation:
* During `agent development time` an `agent`'s port is assigned a Cap'n Proto schema.
* During `subgraph development time` the syntax `->` or `=>` is used to instruct an upstream `agent`'s port to connect to a downstream `agent`'s port later at run-time. It represents a `connection` between two `nodes`. Though it is not yet an `edge` because the `contract` might not be satisfied.
* Lastly, the graph is successfully loaded into the virtual machine without errors. This act means all `agent` `contracts` were satisfied, and all `subgraph` `connections` are now classified as `edges`.

Once an `edge` is formed, it becomes a bounded buffer message passing channel, which can only contain `messages` with data in the shape of whatever the Cap'n Proto schema is.

So despite you seeing only Cap'n Proto schema in this directory, the concept of an `Edge` is  more profound. Hence we would prefer naming this concept after it's grandest manifestation, and in the process, the name encapsulates all of the above information. The name should also tie in with the concept of a `node` in graph theory, as such we use `nodes` and `edges` to construct `subgraphs`.

#### Exposed Edge or iMsg

When developing a `subgraph` there comes a time when the developer wants to inject data into an `agent` or another `subgraph`. One needs to use an `exposed edge` or an `imsg` (initial message) which has this syntax:

``` nix
{ subgraph, nodes, edges }:

subgraph {
  src = ./.;
  flowscript = with nodes; with edges; ''
    '${prim_bool}:(boolean=true)' -> INPUT_PORT NAME()
  '';
}
```

`Exposed edges` or `imsgs` kick start `agents` into action, otherwise they won't start. Due to the dataflow nature of `agents` they will politely wait for data before they start doing anything. This is the equivalent of passing the path of a data source to some executable on the command line. Without the argument the program would just sit or fail. Another way of looking at it might be a pipeline that has come to the surface to accept some form of input.

We use the name `exposed edge` to differentiate between a `hidden edge`, but by far the most common usage is `imsg` and `edge`.

#### Hidden Edge or Edge

`Hidden edges` are represented with this syntax `->` and `=>`, and are used to control the direction flowing data. Hence the process of programming a `subgraph` is essentially digging ditches and laying pipelines between buildings.

Examples of `hidden edges`

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

* Contracts between components are critical for creating [living systems](https://hintjens.gitbooks.io/social-architecture/content/chapter6.html).
* Schema ensure we do not need to parse strangely formatted `stdin` data.
* A `node` does one and only one thing, and the schema represents a language the `node` speaks. If you want a `node` to do something, you have to speak it's language.

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

#### Naming of Cap'n Proto `structs` and `enums`

Please use CamelCase for `struct` and `enum` names. The naming should reflect this manner:

* if the schema is in folder `/edges/maths/boolean` then the `struct` should have name `MathsBoolean`.
* if the schema is in `fractal` `/edges/net/http/response` then the `struct` should have name `NetHttpResponse`.

The same naming applies for Cap'n Proto `enums` and `interfaces`. It's crucial this naming is adopted.

#### One struct per Fractalide schema

We prefer composition of schema, and the schema must have fully qualified struct names.
Hence, this is example shouldn't be used:

``` nix
{ edge, edges }:

edge {
  src = ./.;
  edge = with edges; [ command ];
  schema = with edges; ''
    @0xf61e7fcd2b18d862;
    struct Person {
      name @0 :Text;
      birthdate @3 :Date;

      email @1 :Text;
      phones @2 :List(PhoneNumber);

      struct PhoneNumber {
        number @0 :Text;
        type @1 :Type;

        enum Type {
          mobile @0;
          home @1;
          work @2;
        }
      }
    }

    struct Date {
      year @0 :Int16;
      month @1 :UInt8;
      day @2 :UInt8;
    }
  '';
}
```
The `Date` name can collide!

Schema are pulled into `agent`'s scope just before compile time, now we are unable to predict what combinations will happen.
So if we have two schema that have `struct Date ...` then a name collision will take place.
Therefore to avoid this scenario please put `struct Date ...` into it's own schema and import it via this mechanism.

#### Cap'n Proto import

Fractalide resolves transitive dependencies for you but you have to use this method:

``` nix
{ edge, edges }:

edge {
  src = ./.;
  edge = with edges; [ command ];
  schema = with edges; ''
    @0xf61e7fcd2b18d862;
    using CommandInstanceName = import "${command}/src/edge.capnp";
    struct ListCommand {
        commands @0 :List(CommandInstanceName.Command);
    }
  '';
}
```

You must pull explicitly mention the `edge` you want to import via the `  edge = with edges; [ command ];`
Then you must `import` it via this mechanism: `using CommandInstanceName = import "${command}/src/edge.capnp";`
and lastly use it `... commands @0 :List(CommandInstanceName.Command); ...`

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

Now that you've had a basic introduction to the `Services` collection, you might want to head on over to

1. [Nodes](../nodes/README.md)
2. [Services](../services/README.md)
3. [Fractals](../fractals/README.md)
4. [HOWTO](../HOWTO.md)
