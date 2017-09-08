{ mkRustCrate, fetchzip, release, verbose }:
let
    all_crates_0_0_0_ = { dependencies?[], features?[] }: mkRustCrate {
      crateName = "all_crates";
      version = "0.0.0";
      fractalType = "crate";
      src = ./.;
      inherit dependencies features release verbose;
    };
    byteorder_1_1_0_ = { dependencies?[], features?[] }: mkRustCrate {
      crateName = "byteorder";
      version = "1.1.0";
      fractalType = "crate";
      src = fetchzip {
        url = "https://crates.io/api/v1/crates/byteorder/1.1.0/download";
        sha256 = "1i2n0161jm00zvzh4bncgv9zrwa6ydbxdn5j4bx0wwn7rvi9zycp";
        name = "byteorder-1.1.0.tar.gz";
      };
      libName = "byteorder";
      inherit dependencies features release verbose;
    };
    capnp_0_8_11_ = { dependencies?[], features?[] }: mkRustCrate {
      crateName = "capnp";
      version = "0.8.11";
      fractalType = "crate";
      src = fetchzip {
        url = "https://crates.io/api/v1/crates/capnp/0.8.11/download";
        sha256 = "128nyg50z1rjn7psa1vq3888q8w5xkzkgdcjlc492pjzhsr40bdj";
        name = "capnp-0.8.11.tar.gz";
      };
      libPath = "src/lib.rs";
      libName = "capnp";
      inherit dependencies features release verbose;
    };
    capnpc_0_8_7_ = { dependencies?[], features?[] }: mkRustCrate {
      crateName = "capnpc";
      version = "0.8.7";
      fractalType = "crate";
      src = fetchzip {
        url = "https://crates.io/api/v1/crates/capnpc/0.8.7/download";
        sha256 = "0b1kzq316li86hiwx950b8ri61y3mqhfpzc2ycs984hk472f4wiy";
        name = "capnpc-0.8.7.tar.gz";
      };
      libPath = "src/lib.rs";
      libName = "capnpc";
      crateBin = [ {  name = "capnpc-rust";  path = "src/main.rs"; } ];
      inherit dependencies features release verbose;
    };
    kernel32_sys_0_2_2_ = { dependencies?[], features?[] }: mkRustCrate {
      crateName = "kernel32-sys";
      version = "0.2.2";
      fractalType = "crate";
      src = fetchzip {
        url = "https://crates.io/api/v1/crates/kernel32-sys/0.2.2/download";
        sha256 = "1lrw1hbinyvr6cp28g60z97w32w8vsk6pahk64pmrv2fmby8srfj";
        name = "kernel32-sys-0.2.2.tar.gz";
      };
      libName = "kernel32";
      build = "build.rs";
      buildDependencies = [ winapi_build_0_1_1_ ];      inherit dependencies features release verbose;
    };
    lazy_static_0_2_8_ = { dependencies?[], features?[] }: mkRustCrate {
      crateName = "lazy_static";
      version = "0.2.8";
      fractalType = "crate";
      src = fetchzip {
        url = "https://crates.io/api/v1/crates/lazy_static/0.2.8/download";
        sha256 = "1xbpxx7cd5kl60g87g43q80jxyrsildhxfjc42jb1x4jncknpwbl";
        name = "lazy_static-0.2.8.tar.gz";
      };
      inherit dependencies features release verbose;
    };
    libc_0_2_30_ = { dependencies?[], features?[] }: mkRustCrate {
      crateName = "libc";
      version = "0.2.30";
      fractalType = "crate";
      src = fetchzip {
        url = "https://crates.io/api/v1/crates/libc/0.2.30/download";
        sha256 = "1c4gi6r5gbpbw3dmryc98x059awl4003cfz5kd6lqm03gp62wlkw";
        name = "libc-0.2.30.tar.gz";
      };
      inherit dependencies features release verbose;
    };
    libloading_0_4_1_ = { dependencies?[], features?[] }: mkRustCrate {
      crateName = "libloading";
      version = "0.4.1";
      fractalType = "crate";
      src = fetchzip {
        url = "https://crates.io/api/v1/crates/libloading/0.4.1/download";
        sha256 = "0q0y0vg78vm2fs0wry6dwp3ka5nvahzss0099zw5fmdjkj7yw6y9";
        name = "libloading-0.4.1.tar.gz";
      };
      build = "build.rs";
      inherit dependencies features release verbose;
    };
    memchr_1_0_1_ = { dependencies?[], features?[] }: mkRustCrate {
      crateName = "memchr";
      version = "1.0.1";
      fractalType = "crate";
      src = fetchzip {
        url = "https://crates.io/api/v1/crates/memchr/1.0.1/download";
        sha256 = "071m5y0zm9p1k7pzqm20f44ixvmycf71xsrpayqaypxrjwchnkxm";
        name = "memchr-1.0.1.tar.gz";
      };
      libName = "memchr";
      inherit dependencies features release verbose;
    };
    nom_3_2_0_ = { dependencies?[], features?[] }: mkRustCrate {
      crateName = "nom";
      version = "3.2.0";
      fractalType = "crate";
      src = fetchzip {
        url = "https://crates.io/api/v1/crates/nom/3.2.0/download";
        sha256 = "16ccwwqi09ai1yf71gpqhih915m7ixyrwbjf6lmhfdnxp0igg6sw";
        name = "nom-3.2.0.tar.gz";
      };
      inherit dependencies features release verbose;
    };
    num_cpus_1_6_2_ = { dependencies?[], features?[] }: mkRustCrate {
      crateName = "num_cpus";
      version = "1.6.2";
      fractalType = "crate";
      src = fetchzip {
        url = "https://crates.io/api/v1/crates/num_cpus/1.6.2/download";
        sha256 = "0wxfzxsk05xbkph5qcvdqyi334zn0pnpahzi7n7iagxbb68145rm";
        name = "num_cpus-1.6.2.tar.gz";
      };
      inherit dependencies features release verbose;
    };
    rustfbp_0_3_34_ = { dependencies?[], features?[] }: mkRustCrate {
      crateName = "rustfbp";
      version = "0.3.34";
      fractalType = "crate";
      src = ../rustfbp;
      inherit dependencies features release verbose;
    };
    threadpool_1_7_0_ = { dependencies?[], features?[] }: mkRustCrate {
      crateName = "threadpool";
      version = "1.7.0";
      fractalType = "crate";
      src = fetchzip {
        url = "https://crates.io/api/v1/crates/threadpool/1.7.0/download";
        sha256 = "0pcfzhq9m1jggy7h6x7nhybyjq4xrjmbxqhaffrnc7mcm042w5h7";
        name = "threadpool-1.7.0.tar.gz";
      };
      inherit dependencies features release verbose;
    };
    winapi_0_2_8_ = { dependencies?[], features?[] }: mkRustCrate {
      crateName = "winapi";
      version = "0.2.8";
      fractalType = "crate";
      src = fetchzip {
        url = "https://crates.io/api/v1/crates/winapi/0.2.8/download";
        sha256 = "0a45b58ywf12vb7gvj6h3j264nydynmzyqz8d8rqxsj6icqv82as";
        name = "winapi-0.2.8.tar.gz";
      };
      inherit dependencies features release verbose;
    };
    winapi_build_0_1_1_ = { dependencies?[], features?[] }: mkRustCrate {
      crateName = "winapi-build";
      version = "0.1.1";
      fractalType = "crate";
      src = fetchzip {
        url = "https://crates.io/api/v1/crates/winapi-build/0.1.1/download";
        sha256 = "1lxlpi87rkhxcwp2ykf1ldw3p108hwm24nywf3jfrvmff4rjhqga";
        name = "winapi-build-0.1.1.tar.gz";
      };
      libName = "build";
      inherit dependencies features release verbose;
    };

in
rec {
  all_crates_0_0_0 = all_crates_0_0_0_ {
    dependencies = [ capnp_0_8_11 capnpc_0_8_7 nom_3_2_0 rustfbp_0_3_34 ];
  };
  byteorder_1_1_0 = byteorder_1_1_0_ {
    features = [ "std" ];
  };
  capnp_0_8_11 = capnp_0_8_11_ {
    dependencies = [ byteorder_1_1_0 ];
  };
  capnpc_0_8_7 = capnpc_0_8_7_ {
    dependencies = [ capnp_0_8_11 ];
  };
  kernel32_sys_0_2_2 = kernel32_sys_0_2_2_ {
    dependencies = [ winapi_0_2_8 winapi_build_0_1_1 ];
  };
  lazy_static_0_2_8 = lazy_static_0_2_8_ {};
  libc_0_2_30 = libc_0_2_30_ {
    features = [ "use_std" ];
  };
  libloading_0_4_1 = libloading_0_4_1_ {
    dependencies = [ kernel32_sys_0_2_2 lazy_static_0_2_8 winapi_0_2_8 ];
  };
  memchr_1_0_1 = memchr_1_0_1_ {
    dependencies = [ libc_0_2_30 ];
    features = [ "use_std" ];
  };
  nom_3_2_0 = nom_3_2_0_ {
    dependencies = [ memchr_1_0_1 ];
    features = [ "std" "stream" ];
  };
  num_cpus_1_6_2 = num_cpus_1_6_2_ {
    dependencies = [ libc_0_2_30 ];
  };
  rustfbp_0_3_34 = rustfbp_0_3_34_ {
    dependencies = [ capnp_0_8_11 libloading_0_4_1 threadpool_1_7_0 ];
  };
  threadpool_1_7_0 = threadpool_1_7_0_ {
    dependencies = [ num_cpus_1_6_2 ];
  };
  winapi_0_2_8 = winapi_0_2_8_ {};
  winapi_build_0_1_1 = winapi_build_0_1_1_ {};
  all_crates = all_crates_0_0_0;
  byteorder = byteorder_1_1_0;
  capnp = capnp_0_8_11;
  capnpc = capnpc_0_8_7;
  kernel32_sys = kernel32_sys_0_2_2;
  lazy_static = lazy_static_0_2_8;
  libc = libc_0_2_30;
  libloading = libloading_0_4_1;
  memchr = memchr_1_0_1;
  nom = nom_3_2_0;
  num_cpus = num_cpus_1_6_2;
  rustfbp = rustfbp_0_3_34;
  threadpool = threadpool_1_7_0;
  winapi = winapi_0_2_8;
  winapi_build = winapi_build_0_1_1;
}
