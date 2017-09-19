#![allow(dead_code)]
enum Person {
    Engineer,
    Scientist,
    Height(i32),
    Weight(i32),
    Info { name: String, height: i32 }
}

fn inspect(p: Person) {
    match p {
        Person::Engineer  => println!("Is an engineer!"),
        Person::Scientist => println!("Is a scientist!"),
        Person::Height(i) => println!("Has a height of {}.", i),
        Person::Weight(i) => println!("Has a weight of {}.", i),
        Person::Info { name, height } => {
            println!("{} is {} tall!", name, height);
        },
    }
}
