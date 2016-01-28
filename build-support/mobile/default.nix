# Copyright (c) 2012 Sander van der Burg

# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

{ nixpkgs ? <nixpkgs>
, systems ? [ "x86_64-linux" ]
, buildPlatformVersions ? [ "16" ]
, emulatePlatformVersions ? [ "16" ]
, abiVersions ? [ "armeabi-v7a" ]
}:

rec {
  fractalide_debug = builtins.listToAttrs (map (system:
    let
      pkgs = import nixpkgs { inherit system; };
    in
    { name = "host_"+system;
      value = builtins.listToAttrs (map (buildPlatformVersion:
        { name = "build_" + buildPlatformVersion;
          value = import ./fvm {
            inherit (pkgs) androidenv;
            platformVersion = buildPlatformVersion;
            release = false;
          };
        }
      ) buildPlatformVersions);
    }
  ) systems);

  fractalide_release = builtins.listToAttrs (map (system:
    let
      pkgs = import nixpkgs { inherit system; };
    in
    { name = "host_"+system;
      value = builtins.listToAttrs (map (buildPlatformVersion:
        { name = "build_" + buildPlatformVersion;
          value = import ./fvm {
            inherit (pkgs) androidenv;
            platformVersion = buildPlatformVersion;
            release = true;
          };
        }
      ) buildPlatformVersions);
    }
  ) systems);

  emulate_fractalide_debug = builtins.listToAttrs (map (system:
    let
      pkgs = import nixpkgs { inherit system; };
    in
    { name = "host_"+system;
      value = builtins.listToAttrs (map (buildPlatformVersion:
        { name = "build_" + buildPlatformVersion;
          value = builtins.listToAttrs (map (emulatePlatformVersion:

            { name = "emulate_" + emulatePlatformVersion;
              value = builtins.listToAttrs (map (abiVersion:

                { name = abiVersion;
                  value = import ./emulate-fvm {
                    inherit (pkgs) androidenv;
                    inherit abiVersion;
                    platformVersion = emulatePlatformVersion;
                    fractalide = builtins.getAttr "build_${buildPlatformVersion}" (builtins.getAttr "host_${system}" fractalide_debug);
                  };
                }
              ) abiVersions);
            }
          ) emulatePlatformVersions);
        }
      ) buildPlatformVersions);
    }
  ) systems);

  emulate_fractalide_release = builtins.listToAttrs (map (system:
    let
      pkgs = import nixpkgs { inherit system; };
    in
    { name = "host_"+system;
      value = builtins.listToAttrs (map (buildPlatformVersion:
        { name = "build_" + buildPlatformVersion;
          value = builtins.listToAttrs (map (emulatePlatformVersion:

            { name = "emulate_" + emulatePlatformVersion;
              value = builtins.listToAttrs (map (abiVersion:

                { name = abiVersion;
                  value = import ./emulate-fvm {
                    inherit (pkgs) androidenv;
                    inherit abiVersion;
                    platformVersion = emulatePlatformVersion;
                    fractalide = builtins.getAttr "build_${buildPlatformVersion}" (builtins.getAttr "host_${system}" fractalide_release);
                  };
                }
              ) abiVersions);
            }
          ) emulatePlatformVersions);
        }
      ) buildPlatformVersions);
    }
  ) systems);
}
