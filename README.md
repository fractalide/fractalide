# Fractalide
Canonical repository for all Fractalide components and the service to serve Fractalide components on a Named Data Network.

## Installation

Insert the below into your `configuration.nix` file:

```
let
  fractalide = /path/to/fractalide-git-clone-dir;
in
{
  require = [ "${fractalide}/fractalide-module.nix" ];
  services.fractalide.enable = true;
...
}

```
see [example](https://github.com/sjmackenzie/nixos-infrastructure/blob/master/machines/rivergod.nix#L2-L7)

## Development environment

`$ ./dev-shell`

## Build only components

`$ nix-build`

## Build service and components

`$ nix-build -A build release.nix`

## Test service deployment in a VM.

`$ nix-build -A tests.install release.nix`

## Artifacts built
```
environment.variables.FRACTALIDE_CONFIG = /path/to/fractalide-working-dir/fractalide.toml
environment.variables.FRACTALIDE_DATA = /path/to/fractalide-working-dir
```

These artifacts are needed by FVM and the website, later they could be deprecated by the service (once built).

## TODO
Named Data Network to serve NDN Interests for components.
