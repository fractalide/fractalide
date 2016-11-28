{ component, contracts }:

component {
  src = ./.;
  contracts = with contracts; [file_desc list_command];
  depsSha256 = "1iiq49yvnf8cpxvnxvvy4h3vy26xkzf5lc73p06xjw5d7282bwj0";
}
