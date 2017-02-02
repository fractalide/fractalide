{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
    # Text is always UTF-8 encoded and NUL-terminated.

    struct PrimText {
            text @0 :Text;
    }
  '';
}
