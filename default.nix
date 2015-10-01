   with import <nixpkgs> {};
   {
     fractalideEnv = myEnvFun {
       name = "fractalide";
       buildInputs = [ stdenv rustcMaster cargo];

     };
   }
