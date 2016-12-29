{ stdenv, writeTextFile, capnproto, capnpc-rust, genName }:
{ src, schema, edges ? [], ... } @ args:

let
name = genName src;
edgeText = writeTextFile {
  name = name;
  text = schema;
  executable = false;
};

in stdenv.mkCachedDerivation (args // {
  name = name;
  unpackPhase = "true";
  propagatedBuildInputs = edges;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/src
    mkdir -p $out/nix-support
    for i in $edges; do
      echo $i >> $out/nix-support/propagated-build-inputs
    done
    if test $(tr ' ' '\n' < ${edgeText} | grep -c struct) != "1";
    then
      echo "***************"
      echo ""
      echo "Schema build fail"
      echo "Schema '${name}' may only contain one 'struct' keyword"
      echo ""
      echo "A Cap'n Proto schema in Fractalide must only contain one 'struct' keyword."
      echo "You'll need to correctly use the 'import' keyword to compose Cap'n Proto Schema."
      echo ""
      echo "Please ensure you have given your Cap'n Proto Schema Data Type a correct hierarchical name."
      echo "Name clashes will happen down the line if you're not careful about naming your schema."
      echo "Fixing those name clashes are painful, as it involves cleaning up other schema."
      echo ""
      echo "Say for example you create your schema in 'edges/prim/list/text/default.nix' and 'edges/prim/text/default.nix'"
      echo "Please see the contents of 'edges/prim/list/text/default.nix' and notice the name 'PrimListText' is camel case"
      echo "'PrimListText' maps to the directory hierarchy from the 'edges' directory."
      echo "The same rule applies to the name 'PrimText' in the 'edges/prim/text/default.nix' file."
      echo ""
      echo "Please stick to this convention, this allows us to move forward without name clashes!"
      echo ""
      echo "***************"
      exit 1
    fi
    cp ${edgeText} $out/src/edge.capnp
    ${capnproto}/bin/capnp compile -o${capnpc-rust}/bin/capnpc-rust:$out/src/  $out/src/edge.capnp --src-prefix $out/src/ -I "/"
  '';
})
