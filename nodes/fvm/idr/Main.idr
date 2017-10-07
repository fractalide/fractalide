module Main

import Agent
import Scheduler

main : IO ()
main = putStrLn (Scheduler.link "Scheduler" "Agent-from" "from-port" "to-port" "To-agent")


-- fs_file_open.so
-- core_parser_lexical.so
