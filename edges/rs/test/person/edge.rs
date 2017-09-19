#[derive(Debug)]
struct Person<'a> {
    name: &'a str,
    age: u8
}
