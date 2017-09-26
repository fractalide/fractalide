module Scheduler

import Control.Monad.State

data Tree a = Empty
            | Node (Tree a) a (Tree a)

testTree : Tree String
testTree = Node (Node (Node Empty "Node1" Empty) "Node2"
                      (Node Empty "Node3" Empty)) "Node4"
                (Node Empty "Node5" (Node Empty "Node6" Empty))

flatten : Tree a -> List a
flatten Empty = []
flatten (Node left val right) = flatten left ++ val :: flatten right

export
link : (sched : String) -> (from : String) -> (frport : String) -> (toport : String) -> (to : String) -> String
link sched from frport toport to = sched ++ " " ++ from ++ " " ++ frport ++ " " ++ toport ++ " " ++ to
