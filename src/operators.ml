let ($) f x = f x

(* FIXME: This one is defined in pervasives (with another name).
   But at the time, caml.inria.fr doesn't respond

   --> actually, neither |> nor @@ are function composition operators
*)
let (=<) f g = fun x -> f (g x)

(* Control.Arrow *)
let ( *** ) f g = fun (x, y) -> (f x, g y)
let ( &&& ) f g = fun x -> (f x, g x)

(* Useful functions for point-free definitions *)
let flip f = fun x y -> f y x
let id : 'a. 'a -> 'a = fun x -> x


let curry f = fun x y -> f (x, y)
