{ lib
  , stdenv
  , git
  , purescript
  , purspkgsSupport
  , genName
  , unifySchema
}:

{ type ? ""}:

{ name ? null
  , src ? null
  , mods ? []
  , edges ? []
  , ...
} @ args:

let
  compName = if name == null then genName src else name;
  nearPureDeps = purspkgsSupport.pureDeps mods mods;
  unifiedSchema = unifySchema {
    name = compName;
    edges = edges;
    target = "rs";
  };
in stdenv.mkDerivation (args // rec {
  name = compName;
  inherit src mods;
  buildInputs = [purescript];
  pureDeps = lib.unique nearPureDeps ;
  phases = [ "unpackPhase" "configurePhase" "buildPhase" "installPhase" ];
  buildPhase = args.buildPhase or ''
    echo "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    echo "=====> building purescript ${type}: ${compName} "
    echo "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    ${purspkgsSupport.symlinkCalc (purspkgsSupport.pureDeps mods mods)}
    ${
      if type == "agent" then ''
        ln -s ${unifiedSchema}/edge_capnp.rs edge_capnp.rs
        mkdir ./output
        psc lib.purs 'purelibs/*/src/**/*.purs' -o ./output
        psc-bundle output/**/{index,foreign}.js --module Main --main Main --output output.js
      '' else ""}
  '';

  installPhase = ''
    mkdir -p $out
    cp output.js $out/libagent.js

    cat > $out/index.html <<EOF
    <!doctype html>
    <html>
      <body>
      <h1>check console</h1>
        <script>
    EOF

    cat $out/libagent.js >>$out/index.html

    cat >> $out/index.html <<EOF
        </script>
      </body>
    </html>
    EOF
    echo paste the below in your browser
    echo $out/index.html


  '';
})
