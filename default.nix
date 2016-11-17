{ debug ? "--release"
, subnet ? null
, local-rustfbp ? ""
, cache ? null
, test ? null
, ...} @argsInput:
let
#get the old pkgs if given from an parameter, else import it
pkgsOld = if argsInput ? pkgs then argsInput.pkgs
else import <nixpkgs> {};
lib = pkgs.lib;
#expand the old pkgs with mkCachedDerivation
pkgs = pkgsOld.overridePackages(self: super: rec {
  stdenv = super.stdenv // {
    # mkCachedDerivation is like a normal mkDerivation but it copies the target folder
    # and creates a MD5SUM for every file into the 'cache' output.

    # if the old cache variable is set to the output created earlier it uses the old target folder
    # this helps to speed up the build process since cargo does not have to build everything from scratch.

    # the MD5SUMs are needed to find files that have been changed.

    # if your using this make sure that you correctly call the preConfiguration and the
    # preInstall Hook!
    mkCachedDerivation =
     if isNull cache || debug != "true" then
      super.stdenv.mkDerivation
      else
      args:
       let
        #extend the old arguments
        preCon = if args ? preConfigure && lib.isString args.preConfigure  then args.preConfigure else "";
        preIn = if args ? preInstall && lib.isString args.preInstall then args.preInstall else " ";
        outp = if args? outputs && lib.isList args.outputs then args.outputs else [];

        inputs = args.buildInputs ++ args.nativeBuildinputs;

        name = args.name;
        version = args.version;

        #argsNew is like args but with all the needed changes
        argsNew = args //
        {
          # We will output to $out as normal, but also to $cache
          outputs = [ "out" "cache"] ++ lib.remove "out" outp;

          preConfigure = ''
             # Before we do anything, capture the MD5 sums of all source files.
             # We will compare against this in subsequent builds.
            mkdir -p $cache
            mkdir -p $cache/$name
            touch $cache/$name/MD5SUMS
            find . -type f | xargs md5sum | sort > $cache/$name/MD5SUMS

            # check if cache directory exists
            if [ ! -h "${cache}/$name" ]; then
              echo "Warning: ${cache}/$name does not exist, proceeding without cache. A new cache will be created here: $cache."
            else if [ -d ${cache}/$name/target ] && [ -f ${cache}/$name/MD5SUMS ]; then
              #echo "CACHE HIT for $name"
              # Restore the old target/ directory, with its MD5SUMS from the cache
              cp -r ${cache}/$name/target ./
              chmod +w -R ./target
              cp ${cache}/$name/MD5SUMS ./MD5SUMS

              # Touch any files whose MD5SUM has changed since the last build
              join $cache/$name/MD5SUMS MD5SUMS -v 1 | cut -d' ' -f 2 | while read filename; do
                #echo "$filename" has changed
                touch "$filename" || true
              done

              # Touch all target/ files to be 2 hours in the past.
              # Note that source code will be last modified in 1970 *by default*
              # but changed to the current time by the loop above.
              find ./target -print | while read filename; do
                touch -d "$(date -R -r "$filename") - 2 hours" "$filename"
              done
            #else
              #echo "CACHE NOT HIT for $name "
            fi
           fi
          '' + preCon;

          preInstall = ''
            #copy all target/* files into the new cache
            mkdir -p $cache
            mkdir -p $out
            mkdir -p $cache/$name
            if [ -d ./target  ]; then
                cp -R ./target $cache/$name/
            #else
                #echo "Warning: ./target NOT COPIED $name"
            fi
            if [ ! -h $out/buildCache ]; then
              ln -s $cache/ $out/buildCache
            fi
          '' + preIn;
        };
      in
        # caching is only enabled when debug is true
        if debug == "true" then
          super.stdenv.mkDerivation argsNew
        else
          super.stdenv.mkDerivation args;
  };
});

isValidSubnet = (builtins.head (lib.attrVals [subnet] components));
defaultSubnet = if (builtins.isAttrs isValidSubnet) then isValidSubnet else null;
support = import ./support { inherit pkgs debug test local-rustfbp components contracts; };
services = import ./services { inherit fractals; };
fractals = import ./fractals { inherit pkgs support components contracts; };
components = import ./components { inherit pkgs support fractals contracts; };
contracts = import ./contracts { inherit pkgs support fractals contracts; };
fvm = import ./support/fvm { inherit pkgs support components contracts; };
in
{
  inherit components support contracts services fractals pkgs;
  result = if subnet == null
  then fvm
  else pkgs.writeTextFile {
    name = defaultSubnet.name;
    text = "${fvm}/bin/fvm ${defaultSubnet}";
    executable = true;};
}
