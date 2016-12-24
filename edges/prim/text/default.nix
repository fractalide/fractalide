{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
    @0xb1fc090ed4d12aee;

    # Text is always UTF-8 encoded and NUL-terminated.

    struct PrimText {
            text @0 :Text;
    }
  '';
}
