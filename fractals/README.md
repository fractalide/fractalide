# Fractals

## Third party Fractalide libraries

### What?

`Fractals` are importable 3rd party sets of components, subnets and contracts, this folder hierarchy is the single source of truth regarding where to find each community fractal.

### Why?

`Fractals` allow the community to develop their own projects in their own git repository, and once ready, may plug into `dev/fractalide/fractals` folder hierarchy which represents the spine of Fractalide. Once inserted your `fractal` is available for use by everyone.

### Who?

Anyone making high quality, documented components, subnets and contracts may plug into this folder hierarchy. We use the [C4](../CONTRIBUTING.md) so your `fractals` will be merged in quickly.

### Where?

Each `fractal` needs to have it's own hierarchical folder. For example, HTTP would be placed in the `fractalide/fractals/net/http` folder.

### How?
Say you wish to create a `http` project, these are the exact steps involved:
* Ensure you use this directory structure convention:
```
dev
├── fractalide
│   └── fractals
│       └── net
│           └── http
│               └── default.nix
└── fractals
    ├── fractal_net_http
    └── ... more community fractals cloned
```
* `$ cd <your/development/directory>` #hereafter called `dev`
* `$ git clone https://gitlab.com/fractalide/fractalide.git`
* `$ NIX_PATH="nixpkgs=https://github.com/NixOS/nixpkgs/archive/125ffff089b6bd360c82cf986d8cc9b17fc2e8ac.tar.gz:fractalide=/path/to/dev/fractalide" && export NIX_PATH`
Take note when setting the `NIX_PATH` environment variable, it must include the path to your newly cloned `fractalide` repo i.e.: `NIX_PATH=...:fractalide=/path/to/dev/fractalide`
* when you start a new shell just type `<ctrl>-r` then type `125ff` this will search your command history for this command, or just persist it in you `~/.bashrc` file.
* `$ mkdir dev/fractals && cd dev/fractals`
* `$ git clone git://github.com/fractalide/fractal_workbench.git fractal_net_http`
The `fractal_workbench` repo provides a minimum correct structure for your `fractal`.  Keep the repo naming convention `fractal_*` for your repo as it'll be easy for the community to see this is a `fractalide` related project.
* `$ cd dev/fractalide/fractals`
* create your needed directory hierarchy `dev/fractalide/fractals/net/http/default.nix`.
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

* Note about the above expression:
  * The `pkgs`, `support`, `components`, `contracts` and `fetchFromGitHub` are arguments passed into this closure.
  * The `let` expression contains a `fetchFromGitHub` expression describing the location of the `fractal`.
  	* Namely the `owner` is the git repository,
  	* `repo` is the git repository in question
  	* `rev` indicates the git revision you want to import and
  	* `sha256` is a neat `nix` mechanism to assist in deterministic builds. To obtain the correct `sha256` try build your project with an incorrect `sha256` (change the first alpha-numeric character in `1vs1d3d9lbxnyilx8g45pb01z5cl2z3gy4035h24p28p9v94jx1b` to a `2`). Nix will download the repository and check that the actual `sha256` matches against what you incorrectly inserted. Nix will tell you what the correct `sha256` is. Copy it and insert the correct `sha256`, replacing `2vs1d3d9lbxnyilx8g45pb01z5cl2z3gy4035h24p28p9v94jx1b`.
  * Please notice the line: `/*fractal = ../../../../fractals/fractal_net_http;*/` This line allows you to clone a `fractal` to your local `/dev/fractals` folder then tell nix not to refer to the remote repo but your local clone. Comment out the `fetchFromGitHub` expression and uncomment the above local repo path clone.  Please ensure this line is commented out when you publish your `fractal` upstream! Please use a relative path compatible with the above directory structure convention as it will work for everyone and we don't have to hunt for the correct folder. Just un/comment and go!
  * The line: `import fractal {inherit pkgs support contracts components; fractalide = null;}` is where we import your closures into `fractalide`'s set of closures. Thus making available your components to everyone.

* The last step is to expose the exact components / contracts to `dev/fractalide/components/default.nix` and `dev/fractalide/contracts/default.nix`.
This is done in this manner:
	* Open `dev/fractalide/components/default.nix` and seek out the `net_http_components` attribute. This is what it looks like:
`net_http_components = fractals.net_http.components;`
In this case there is no specific top level component you'd wish to expose so the convention `*_components` is used to indicate this. Whereas if you have a specific component you'd wish to expose then you'd name it as such:
`net_http = fractals.net_http.components.http`. Why the `*.http`? well that's what the component is named in the namespace [here](https://github.com/fractalide/fractal_net_http/blob/master/components/default.nix#L5). Please notice the lack of the `*_components` when exporting a single component.
	* Regarding importing contracts, typically you don't need to import contracts, but there are times when you need a special contract which must operate on the public side of the `fractal` and thus useable across a number of `fractals`, say the [`net_http_contracts.request`](https://github.com/fractalide/fractal_net_http/blob/master/contracts/default.nix#L8)
You'd use a [similar mechanism](https://github.com/fractalide/fractalide/blob/2312ac77fbb09f7a6cb2d29b79496a83aade3852/contracts/default.nix#L31) as above when exposing your contracts.

### Incremental Builds
Fractalide expands the nix-build system for incremental builds. The Incremental Builds only work when debug is enabled. They also need the path to a cache folder.
The cache folder can be created from an old result by the `buildCache.sh` script. Per default the cache folder is saved in the `/tmp` folder of your system.

Here is an example how you can build with the Incremental Build System:

```
$ cd dev/fractalide
$ nix-build --argstr debug true --argstr cache $(./support/buildCache.sh) --argstr subnet workbench
```
If you're using NixOS, please ensure you have not set `nix.useSandbox = true;`, otherwise Incremental Compilation will fail.

### Two ways to execute your fractal

* Executed directly from the `fractal`.
	* advantages
		* faster to test by just issuing the `nix-build` command
		* convenient for CI & CD of you specific subnet
		* don't have to plug it into `dev/fractalide/fractals`
	* disadvantages
		* no incremental recompilation
* Executed from the `fractalide`.
	* advatages
		* Incremental recompilation needed for development
	* disadvantages
		* wetware needed to plug into `dev/fractalide/fractals` to get incremental recompilation
		* long build command

#### Executing from within Fractalide

* `$ cd dev/fractalide`
* `$ nix-build  --argstr debug true --argstr cache $(./support/buildCache.sh)  --argstr subnet workbench`
* `$ ./result/bin/workbench`

#### Executing from with the Fractal
* `$ cd /dev/fractals/fractal_workbench`
* `$ nix-build`
* `$ ./result/bin/workbench`
