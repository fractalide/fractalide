{ stdenv, writeTextFile, capnproto, capnpc-rust, genName }:
{ src, schema, edges ? [], ... } @ args:

let
name = genName src;
edgeText = writeTextFile {
  name = name;
  text = schema;
  executable = false;
};

in stdenv.mkDerivation (args // {
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
    struct=$(grep -m 2 -c 'struct' ${edgeText} || true )
    enum=$(grep -m 2 -c 'enum' ${edgeText} || true)
    total=$(($struct+$enum))
    if [ $struct -gt 1 ]
    then
      echo "***************"
      echo ""
      echo "    ERROR"
      echo ""
      echo "    '${name}' schema failed to build"
      echo "    Schema '${name}' may only contain a single instance of the keywords 'struct'."
      echo ""
      echo "    This is to ensure name clashes don't happen, if you have a better solution please make a patch."
      echo ""
      echo "    Please ensure you have given your Cap'n Proto Schema Data Type a correct hierarchical name."
      echo "    If the schema is in a fractal called net_http please ensure that the *entire* namespace in CamelCase is factored in."
      echo "    e.g.: NetHttpRequestHeader or NetHttpRequestVersion is correct"
      echo "          RequestHeader or RequestVersion is not correct"
      echo ""
      echo "***************"
      exit 1
    elif [ $enum -gt 1 ]
    then
      echo "***************"
      echo ""
      echo "    Warning: multiple enum uses detected in schema '${name}'."
      echo ""
      echo "    If the 'enum' is at root level, please split out the into it's own schema. The 'enum' name should be a fully qualified name"
      echo "    Such as 'NetHttpRequestMethod' and not 'RequestMethod'"
      echo ""
      echo "***************"
    elif [ $total -gt 1 ]
    then
      echo "***************"
      echo ""
      echo "    Warning: multiple enum and struct uses detected in schema '${name}'."
      echo ""
      echo "    Please ensure root level 'enum' and 'struct' are split out the into it's own schema."
      echo "    The 'enum' and 'struct' name should be a fully qualified name such as 'NetHttpRequestMethod' and not 'RequestMethod'"
      echo ""
      echo "***************"
    else
      cp ${edgeText} $out/src/edge.capnp
      ${capnproto}/bin/capnp compile -o${capnpc-rust}/bin/capnpc-rust:$out/src/  $out/src/edge.capnp --src-prefix $out/src/ -I "/"
    fi

  '';
})
