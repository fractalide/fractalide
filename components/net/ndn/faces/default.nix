{ stdenv, buildFractalideSubnet, upkeepers
  , ...}:

buildFractalideSubnet rec {
  src = ./.;
  subnet = ''
// interests flow into the router via sockets and eventually other mediums (RF, lasers, etc), and from applications.
// app_interest indicates that the interest arose from a local application. It will be registered as a face.
// ideally `app_interest` should be a socket.

  ""
  interest => wrap wrap(${net_ndn_wrap_interest}) out ->
  forward => out
  '';

  meta = with stdenv.lib; {
    description = "Subnet: net_ndn_face; Named Data Networking";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/ndn/face;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
