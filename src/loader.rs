extern crate libloading;

// TODO : manage the errors

use libloading::{Library, Symbol};

use std::fmt;

pub struct ComponentBuilder {
    lib: Library,
    new: fn(&String, &String) -> *mut u8,
    connect: fn(*mut u8, &String, &String, &String, &String) -> u32,
    connect_array: fn(*mut u8, &String, &String, &String, &String, &String) -> u32, 
    add_output_selection: fn(*mut u8, &String, &String) -> u32,
    add_input_selection: fn(*mut u8, &String, &String) -> u32,
    disconnect: fn(*mut u8, &String) -> u32,
    disconnect_array: fn(*mut u8, &String, &String) -> u32,
    is_input_ports: fn(*mut u8) -> bool,
    run: fn(*mut u8),
    destroy: fn(*mut u8),
}

impl ComponentBuilder {
    pub fn new(path: &'static str) -> Self {
        let comp = libloading::Library::new(path).expect("cannot load");
        
        let new = unsafe {
            *(comp.get(b"create_component\0").expect("cannot find create method"))
        };
        let run: fn(*mut u8) = unsafe {
            *(comp.get(b"run\0").expect("cannot find run method"))
        };
        let connect: fn(*mut u8, &String, &String, &String, &String) -> u32 = unsafe {
            *(comp.get(b"connect\0").expect("cannot find connect method"))
        };
        let connect_array: fn(*mut u8, &String, &String, &String, &String, &String) -> u32 = unsafe {
            *(comp.get(b"connect_array\0").expect("cannot find connect_array method"))
        };
        let add_output_selection: fn(*mut u8, &String, &String) -> u32 = unsafe {
            *(comp.get(b"add_output_selection\0").expect("cannot find add_output_selection method"))
        };
        let add_input_selection: fn(*mut u8, &String, &String) -> u32 = unsafe {
            *(comp.get(b"add_input_selection\0").expect("cannot find add_input_selection method"))
        };
        let disconnect: fn(*mut u8, &String) -> u32 = unsafe {
            *(comp.get(b"disconnect\0").expect("cannot find disconnect method"))
        };
        let disconnect_array: fn(*mut u8, &String, &String) -> u32 = unsafe {
            *(comp.get(b"disconnect_array\0").expect("cannot find disconnect_array method"))
        };
        let is_input_ports: fn(*mut u8) -> bool = unsafe {
            *(comp.get(b"is_input_ports\0").expect("cannot find is_input_ports method"))
        };
        let destroy: fn(*mut u8) = unsafe {
            *(comp.get(b"destroy_component\0").expect("cannot find destroy method"))
        };

        ComponentBuilder {
            lib: comp,
            new: new,
            connect: connect,
            connect_array: connect_array,
            add_output_selection: add_output_selection,
            add_input_selection: add_input_selection,
            disconnect: disconnect,
            disconnect_array: disconnect_array,
            is_input_ports: is_input_ports,
            run: run,
            destroy: destroy,
        }
        
    }

    pub fn build(&self, sched: &String, name: &String) -> Component {
        let c = (self.new)(sched, name);
        Component {
            ptr: c,
            connect: self.connect,
            connect_array: self.connect_array,
            add_output_selection: self.add_output_selection,
            add_input_selection: self.add_input_selection,
            disconnect: self.disconnect,
            disconnect_array: self.disconnect_array,
            is_input_ports: self.is_input_ports,
            run: self.run,
            destroy: self.destroy,
        }
    }
}

impl fmt::Debug for ComponentBuilder {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "ComponentBuilder")
    }
}

pub struct Component {
    ptr: *mut u8,
    connect: fn(*mut u8, &String, &String, &String, &String) -> u32,
    connect_array: fn(*mut u8, &String, &String, &String, &String, &String) -> u32, 
    add_output_selection: fn(*mut u8, &String, &String) -> u32,
    add_input_selection: fn(*mut u8, &String, &String) -> u32,
    disconnect: fn(*mut u8, &String) -> u32,
    disconnect_array: fn(*mut u8, &String, &String) -> u32,
    is_input_ports: fn(*mut u8) -> bool,
    run: fn(*mut u8),
    destroy: fn(*mut u8),
}

impl Component {
    pub fn run(&self) {
        (self.run)(self.ptr);
    }

    pub fn connect(&self, port_out: &String, sched: &String, comp_in: &String, port_in: &String){
        (self.connect)(self.ptr, port_out, sched, comp_in, port_in);
    }

    pub fn connect_array(&self, port_out: &String, selection_out: &String, sched: &String, comp_in: &String, port_in: &String){
        (self.connect_array)(self.ptr, port_out, selection_out, sched, comp_in, port_in);
    }

    pub fn add_output_selection(&self, port_out: &String, selection_out: &String){
        (self.add_output_selection)(self.ptr, port_out, selection_out);
    }

    pub fn add_input_selection(&self, port_in: &String, selection_in: &String){
        (self.add_input_selection)(self.ptr, port_in, selection_in);
    }

    pub fn disconnect(&self, port: &String){
        (self.disconnect)(self.ptr, port);
    }

    pub fn disconnect_array(&self, port: &String, selection: &String){
        (self.disconnect_array)(self.ptr, port, selection);
    }

    pub fn is_input_ports(&self) -> bool{
        (self.is_input_ports)(self.ptr)
    }

}

unsafe impl Send for Component {}

impl Drop for Component {
    fn drop(&mut self) {
        (self.destroy)(self.ptr);
    }
}
