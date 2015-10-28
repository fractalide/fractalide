   with import <nixpkgs> {};
   {
     rustfbpEnv = myEnvFun {
       name = "rustfbp";
       buildInputs = [ stdenv rustcMaster cargo];

     };
   }
