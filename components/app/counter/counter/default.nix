{ subnet, components, contracts }:

subnet {
  src = ./.;
  flowscript = with components; with contracts; ''
  counter(${app_counter_card}) output -> input page(${ui_js_components.page})
  '${app_counter}:(value=42)~create' -> input counter()
  '';
}
