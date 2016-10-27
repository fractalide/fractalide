{ pkgs
  , support
  , contracts
  , components
  , fetchFromGitHub
  , ...}:
  let
  repo = fetchFromGitHub {
      owner = "fractalide";
      repo = "frac_net_ndn";
      rev = "360c929e159999a23771a4f64d38a22e3c676b6c";
      sha256 = "09vgj242x20yaxcmi78yaign9m4jnzl2ycgzdbxmfx1siy39fzkg";
    };
  /*repo = ../../../../frac_net_ndn;*/
  net_ndn = import repo {inherit pkgs support contracts components; fractalide = null;};
  in
  net_ndn
