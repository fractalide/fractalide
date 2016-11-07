# Fractals

## Third party libraries

### What?

`Fractals` are imported 3rd party sets of components, subnets and contracts, this folder hierarchy is the single source of truth regarding where to find each fractal and the relevant scm revision.

### Why?

`Fractals` allow the community to develop their own projects and once ready, plug into this `fractals` folder hierarchy which represents the spine of Fractalide. Once inserted your fractal is available for use by everyone.

### Who?

Anyone making high quality, documented components, subnets and contracts may plug into this folder hierarchy. We use the [C4](../CONTRIBUTING.md) so your `fractals` will be merged in quickly.

### Where?

Each `fractal` needs to have it's own hierarchical folder. For example, HTTP would be placed in the `fractalide/fractals/net/http` folder. The `default.nix` inside that folder describes which external source code repository to retrieve the code from.

### How?

Say you wish to create a `http` project, these are the steps involved:
* ensure you use this folder structure:

```
dev
├── fractalide
│   └── fractals
│       └── net
│           └── http
│               └── default.nix
└── fractals
    ├── fractal_net_http
    └── ... more fractals you've cloned
```
* `$ cd dev/fractals`
* `$ git clone git://github.com/fractalide/fractal_workbench.git fractal_net_http`

The `fractal_workbench` repo provides a minimum correct structure for your `fractal`.
* keep the naming convention `fractal_*` for your repo as it'll be easy for the community to see this is a `fractalide` related project.
* `$ cd dev/fractalide/fractals`
* create your needed hierarchy in the `dev/fractalide/fractals/net/http` folder.
* insert the below code into a file called `default.nix` which sits in the above folder.
```
{ pkgs
  , support
  , contracts
  , components
  , fetchFromGitHub
  , ...}:
let
  fractal = fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_net_http";
    rev = "bb5e7c1f0883d467c6df7b1f4169b3af71b594e0";
    sha256 = "1vs1d3d9lbxnyilx8g45pb01z5cl2z3gy4035h24p28p9v94jx1b";
  };
  /*fractal = ../../../../fractals/fractal_net_http;*/
in
  import fractal {inherit pkgs support contracts components; fractalide = null;}
```

The `pkgs`, `support`, `components`, `contracts` and `fetchFromGitHub` are arguments passed into this closure.
In the `let` expression you'll see details describing the location of the `fractal`. Namely the `owner` is the git repository, `repo` is quite obviously the repository in question, `rev` indicates the git revision you want to import and `sha256` is a neat nix mechanism to assist in deterministic builds. To obtain the correct `sha256` try build your project with an incorrect `sha256` (change the first alpha-numeric character in `1vs1d3d9lbxnyilx8g45pb01z5cl2z3gy4035h24p28p9v94jx1b` to a `2`). Nix will download the repository and check that the actual `sha256` matches what you incorrectly inserted. Nix will tell you what the correct `sha256` is. Copy it and insert the correct `sha256`, replacing `2vs1d3d9lbxnyilx8g45pb01z5cl2z3gy4035h24p28p9v94jx1b`.

Please notice the line:

`/*fractal = ../../../../fractals/fractal_net_http;*/`

This line allows you to clone another `fractal` to your local `fractals` folder then tell nix not to refer to the remote repo but your local clone. Comment out the `fetchFromGitHub` expression and uncomment the above local repo path clone. Please comment this line out when you publish your `fractal` upstream! Please use a relative path compatible with the above folder structure convention as it will work for everyone and we don't have to deal with hunting for the correct folder. Just un/comment and go!

The line:

`import fractal {inherit pkgs support contracts components; fractalide = null;}`

is where we import your closures into `fractalide`'s set of closures. Thus making available your components to everyone.

* The last step is to expose the exact components / contracts to `components/default.nix` and `contracts/default.nix`.
This is done in this manner:

Open `components/default.nix` and seek out the `net_http_components` attribute. This is what it looks like:
`net_http_components = fractals.net_http.components;`
In this case there is no specific top level component you'd wish to expose so the convention `*_components` is used to indicate this. Whereas if you have a specific component you'd wish to expose then you'd name it as such:
`net_http = fractals.net_http.components.http`. Why the `*.http`? well that's what the component is named in the namespace [here](https://github.com/fractalide/fractal_net_http/blob/master/components/default.nix#L5). Please notice the lack of the `*_components` when exporting a single component.

Regarding importing contracts, typically you don't need to import contracts, but the mechanism is there to allow it. Sometimes your subnets will have common generic contracts that demand to be exposed useable across a number of `fractals`, say the [`net_http_contracts.request`](https://github.com/fractalide/fractal_net_http/blob/master/contracts/default.nix#L8)
You'd use a [similar mechanism](https://github.com/fractalide/fractalide/blob/2312ac77fbb09f7a6cb2d29b79496a83aade3852/contracts/default.nix#L31) as above when exposing your contracts.

### Wrap up

The combination of extreme loose coupling between `fractalide` components and not having to manually install dependencies with deterministic nix builds make the process of importing, mixing and matching components feel like you're doing advanced kung-fu. This is one of the best features of `fractalide`.
