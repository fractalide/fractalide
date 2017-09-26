{ buffet }:
let
  callPackage = buffet.pkgs.lib.callPackageWith ( buffet.support // buffet );
# insert in alphabetical order in relevant section to reduce conflicts
in
# Schemas will undergo stability changes depending on any node (node-x) in any fractal becoming stable.
# It is the responsibility of that node-x's author to discuss with the author of the schema in question
# to stabilize the schema.
{
  # raw
  PrimListText = callPackage ./prim/list/text {};
  KvKeyTValT = callPackage ./kv/key/t/val/t {};
  KvKeyTValI64 = callPackage ./kv/key/t/val/i64 {};
  KvListKeyTValT = callPackage ./kv/list/key/t/val/t {};
  NtupTupleTt = callPackage ./ntup/tuple/tt {};
  NtupTupleTb = callPackage ./ntup/tuple/tb {};
  NtupTripleTtt = callPackage ./ntup/triple/ttt {};
  NtupQuadrupleU32u32u32f32 = callPackage ./ntup/quadruple/u32u32u32f32 {};
  NtupListTupleTt = callPackage ./ntup/list/tuple/tt {};
  NtupListTripleTtt = callPackage ./ntup/list/triple/ttt {};
  NtupListTupleTb = callPackage ./ntup/list/tuple/tb {};
  FsListPath = callPackage ./fs/list/path {};
  FsPathOption = callPackage ./fs/path/option {};
  FsPath = callPackage ./fs/path {};
  FsFileDesc = callPackage ./fs/file/desc {};
  FsFileError = callPackage ./fs/file/error {};
  NetHttpEdges = buffet.fractals.net_http.edges.capnp;
  NetNdnEdges = buffet.fractals.net_ndn.edges.capnp;
  NetProtocolDomainPort = callPackage ./net/protocol/domain/port {};
  NetUrl = callPackage ./net/url {};

  # draft
  CoreAction = callPackage ./core/action {};
  CoreActionAdd = callPackage ./core/action/add {};
  CoreActionSend = callPackage ./core/action/send {};
  CoreActionConnect = callPackage ./core/action/connect {};
  CoreActionConnectSender = callPackage ./core/action/connect/sender {};
  CoreGraph = callPackage ./core/graph {};
  CoreGraphEdge = callPackage ./core/graph/edge {};
  CoreGraphExt = callPackage ./core/graph/ext {};
  CoreGraphImsg = callPackage ./core/graph/imsg {};
  CoreGraphListEdge = callPackage ./core/graph/list/edge {};
  CoreGraphListExt = callPackage ./core/graph/list/ext {};
  CoreGraphListImsg = callPackage ./core/graph/list/imsg {};
  CoreGraphListNode = callPackage ./core/graph/list/node {};
  CoreGraphNode = callPackage ./core/graph/node {};
  CoreLexical = callPackage ./core/lexical {};
  CoreSemanticError = callPackage ./core/semantic/error {};
  PrimBool = callPackage ./prim/bool {};
  PrimI8 = callPackage ./prim/i8 {};
  PrimI16 = callPackage ./prim/i16 {};
  PrimI32 = callPackage ./prim/i32 {};
  PrimI64 = callPackage ./prim/i64 {};
  PrimU8 = callPackage ./prim/u8 {};
  PrimU16 = callPackage ./prim/u16 {};
  PrimU32 = callPackage ./prim/u32 {};
  PrimU64 = callPackage ./prim/u64 {};
  PrimF32 = callPackage ./prim/f32 {};
  PrimF64 = callPackage ./prim/f64 {};
  PrimText = callPackage ./prim/text {};
  PrimData = callPackage ./prim/data {};
  PrimVoid = callPackage ./prim/void {};

  # stable

  # deprecated

  # legacy
}
