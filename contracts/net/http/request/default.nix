{stdenv, buildFractalideContract, upkeepers, ...}:

buildFractalideContract rec {
  src = ./.;
  contract = ''
  @0x992391bf15f6322d;

  struct NetHttpRequest {
    id @0 :UInt64;
    url @1 :Text;
    method @2 :Method;
    headers @3 :List(Header);
    httpVersion @4 :Version;
    content @5 :Text;
  }

  struct Version {
    main @0 :UInt8;
    sub @1 :UInt8;
  }
  enum Method {
    get @0;
    patch @1;
    head @2;
    post @3;
    put @4;
    delete @5;
    connect @6;
    options @7;
    trace @8;
  }

  struct Header {
    key @0 :Text;
    value @1 :Text;
  }
  '';

  meta = with stdenv.lib; {
    description = "Contract: Describes an http request";
    homepage = https://github.com/fractalide/fractalide/tree/master/contracts/maths/boolean;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
