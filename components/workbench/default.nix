{ pkgs
  , support
  , contracts
  , components
  , stdenv
  , buildFractalideSubnet
  , net_http_components
  , net_http_contracts
  , app_todo_components
  , app_todo_contracts
  , ...}:
   buildFractalideSubnet rec {
   src = ./.;
   subnet = ''
   http(${net_http_components.http})

   '${net_http_contracts.address}:(address="0.0.0.0:8000")' -> listen http()

   // GET
   http() GET[/todos/.+] -> input get(${app_todo_components.get}) response ->
       response http()

   // POST
   http() POST[/todos/?] -> input post(${app_todo_components.post}) response ->
       response http()

   // DELETE
   http() DELETE[/todos/.+] -> input delete(${app_todo_components.delete}) response ->
        response http()

   // PATCH
   http() PATCH[/todos/.+] -> input patch(${app_todo_components.patch})
   http() PUT[/todos/.+] -> input patch() response ->
       response http()
   '';

   meta = with stdenv.lib; {
    description = "Subnet: Counter app";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/test;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
