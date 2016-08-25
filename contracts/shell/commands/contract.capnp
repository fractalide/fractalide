@0xafd2d34a29d48dbd;

struct ShellCommands {
  commands @0 :List(Command);
}

struct Command {
       key @0 :Text;
       val @1 :Text;
}
