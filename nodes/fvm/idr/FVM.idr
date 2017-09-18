module Main

StringOrInt : Bool -> Type
StringOrInt x = case x of
              True => Int
              False => String

getStringOrInt : (x : Bool) -> String
getStringOrInt x = case x of
                    True => cast 94
                    False => "ninety four"

valToString : (x : Bool) -> StringOrInt x -> String
valToString x val = case x of
                True => cast val
                False => val

main : IO ()
main = putStrLn (valToString True 98)

-- fs_file_open.so
-- core_parser_lexical.so
