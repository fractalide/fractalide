{ subnet, components, contracts }:

subnet {
  src = ./.;
  subnet = with components; with contracts; ''
  '${js_create}:(type="div", style=[(key="display", val="flex"), (key="flex-direction", val="column")])~create' -> input td(${ui_js_flex}) output -> input page(${ui_js_page})
  '${generic_text}:(text="initial")~create' -> input edit(${ui_js_edit}) output -> places[1] td()
  '${js_create}:(type="span", text="hello")~create' -> input t(${ui_js_tag}) output -> places[2] td()
  '';
}
