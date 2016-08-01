#!/usr/bin/env nix-shell
#! nix-shell -i python -p python pythonPackages.configobj

# this script sets up a new rustfbp component
# by reading the utils/component.ini which you have configured
# then:
# * writing the cargo.toml file
# * writing the default.nix file
# * writing the lib.rs file
# * then runs `cargo generate-lockfile` on the component to create the lockfile
# * inserting the component into components/default.nix

from configobj import ConfigObj
config = ConfigObj("component.ini")

def write_cargo_deps(deps):
    toml = "rustfbp = \"*\"\ncapnp = \"*\"\n"
    for crate in deps:
        toml += crate + " = \"" + deps[crate] + "\"\n"
    return toml

def cargo_toml (component_name, cargo_deps):
    cargo_toml_template = """
[package]
name = \"""" + component_name + """\"
version = "0.1.0"
authors = ["test <test@test.com>"]

[lib]
name = \"""" + component_name + """\"
crate-type = ["dylib"]

[dependencies]
""" + write_cargo_deps(cargo_deps)
    return cargo_toml_template

def write_contracts(ports, nix):
    contracts = ""
    contract_set = set()
    for port_type in ports:
        for port in ports[port_type]:
            contract_set.add(ports[port_type][port])
    if nix:
        contracts += ' '.join(map("\"{0}\"".format, contract_set))
    else:
        contracts += ", ".join(contract_set)
    return contracts

def default_nix (component_description, ports):
    default_nix = """
{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts [""" + write_contracts(ports, True) + """];
  depsSha256 = "1m6n74fm7k99pp13j5d5yyp4j0znc0s10958hhyyh3shq9rj8862";

  meta = with stdenv.lib; {
    description = "Component: """ + component_description + """";
    homepage = https://gitlab.com/fractalide/fractalide/tree/master/components/maths/boolean/nand;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
    """
    return default_nix

def write_externs(deps):
    externs = "#![feature(question_mark)]\n#[macro_use]\nextern crate rustfbp;\nextern crate capnp;\n"
    for crate in deps:
        externs += "extern crate " + crate + ";\n"
    return externs

def write_input_output_array_ports(ports):
    formatted_port_types = []
    for port_type in ports:
        port_list = []
        start = port_type + "("
        for port in ports[port_type]:
            port_list.append(port + ": " + ports[port_type][port])
        formatted_port_types.append(start + ", ".join(map("{0}".format, port_list)) + "),")
    return "\n  ".join(formatted_port_types)

def write_extra_ports(extra_ports):
    e_ports = "  option(" + extra_ports["option"] + "),\n  acc(" + extra_ports["acc"] + "), "
    if extra_ports["portal"] == "true":
        e_ports += "portal()"
    return e_ports

def write_simple_input_extractor(port, contract):
    ip = "ip_" + port
    reader = port + "_reader"
    return """
    let """ + port + """ = {
        let mut """ + ip + """ = self.ports.recv(\"""" + port + """\")?;
        let """ + reader + """: """ + contract + """::Reader = """ + ip + """.get_root()?;
        """ + reader + """.get_XXX() // read contract: """ + contract + """ to replace XXX
    };"""

def write_simple_input_extractors(simple_inputs):
    simple_input_extractors = ""
    for port in simple_inputs:
        simple_input_extractors += write_simple_input_extractor(port, simple_inputs[port])
    return simple_input_extractors

def write_inputs_array_extractor(port, contract):
    ip = "ip_" + port
    reader = port + "_reader"
    return """
    let """ + port + """ = {
        let mut """ + ip + """ = self.ports.recv(\"""" + port + """\")?;
        let """ + reader + """: """ + contract + """::Reader = """ + ip + """.get_root()?;
        """ + reader + """.get_XXX() // read contract: """ + contract + """ to replace XXX
    };"""

def write_inputs_array_extractors(input_arrays):
    input_array_extractors = ""
    for port in input_arrays:
        input_array_extractors += write_inputs_array_extractor(port, input_arrays[port])
    return input_array_extractors

def write_simple_outputs_extractor(port, contract):
    out_ip = "out_ip_" + port
    return """
    let mut """ + out_ip + """ = IP::new();
    {
      let mut variable = """ + out_ip + """.init_root::<""" + contract + """::Builder>();
      variable.set_XXX(YYY); // read contract: """ + contract + """ to replace XXX
    }"""

def write_simple_outputs_extractors(simple_outputs):
    simple_outputs_extractors = ""
    for port in simple_outputs:
        simple_outputs_extractors += write_simple_outputs_extractor(port, simple_outputs[port])
    return simple_outputs_extractors

def write_outputs_array_extractor(port, contract):
    out_ip = "out_ip_" + port
    return """
    let mut """ + out_ip + """ = IP::new();
    {
      let mut variable = """ + out_ip + """.init_root::<""" + contract + """::Builder>();
      variable.set_XXX(YYY); // read contract: """ + contract + """ to replace XXX
    }"""

def write_outputs_array_extractors(outputs_array):
    outputs_array_extractors = ""
    for port in outputs_array:
        outputs_array_extractors += write_outputs_array_extractor(port, outputs_array[port])
    return outputs_array_extractors

def write_ip_extractors(ports):
    extractors = ""
    for port_type in ports:
        if port_type == "inputs":
            extractors += write_simple_input_extractors(ports[port_type])
        if port_type == "inputs_array":
            extractors += write_inputs_array_extractors(ports[port_type])
        if port_type == "outputs":
            extractors += write_simple_outputs_extractors(ports[port_type])
        if port_type == "outputs_array":
            extractors += write_outputs_array_extractors(ports[port_type])
    return extractors

def write_simple_outputs_send(port):
    out_ip = "out_ip_" + port
    return """
    self.ports.send(\"""" + port + """\", """ + out_ip + """)?;"""

def write_simple_outputs_sends(simple_outputs):
    simple_outputs_sends = ""
    for port in simple_outputs:
        simple_outputs_sends += write_simple_outputs_send(port)
    return simple_outputs_sends

def write_outputs_array_send(port):
    out_ip = "out_ip_" + port
    return """
    for p in self.ports.get_output_selections(\"""" + port + """\")? {
        self.ports.send_array(\"""" + port + """\", &p, """ + out_ip + """.clone())?;
    }"""

def write_outputs_array_sends(outputs_array):
    outputs_array_sends = ""
    for port in outputs_array:
        outputs_array_sends += write_outputs_array_send(port)
    return outputs_array_sends

def write_sends(ports):
    sends = ""
    for port_type in ports:
        if port_type == "outputs":
            sends += write_simple_outputs_sends(ports[port_type])
        if port_type == "outputs_array":
            sends += write_outputs_array_sends(ports[port_type])
    return sends

def lib_rs(component_name, ports, cargo_deps, extra_ports):
    lib_rs = write_externs(cargo_deps) + """
component! {
  """ + component_name + """, contracts(""" + write_contracts(ports, False) + """)
  """ + write_input_output_array_ports(ports) + "\n" + write_extra_ports(extra_ports) + """
  fn run(&mut self) -> Result<()> {
    """ + write_ip_extractors(ports) + write_sends(ports) + """
    Ok(())
  }
}
    """
    return lib_rs

print cargo_toml(config['component_name'], config['cargo dependencies'])
print default_nix(config['component_description'], config['ports'])
print lib_rs(config['component_name'], config['ports'], config['cargo dependencies'], config['extra ports'])
