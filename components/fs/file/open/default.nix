{ component, contracts }:

component {
  src = ./.;
  contracts = with contracts; [ file_desc path file_error ];
  depsSha256 = "1cq1bbrpznzkawi9pxpigxh5ykxrc427a43mrjg8dc636hxklvnk";
}
