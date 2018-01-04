module Geometry

open System


type Point<'a> = { x: 'a; y: 'a }


type Shape<'a> = Point<'a> -> bool


let circle origin radius p =
    let dx = origin.x - p.x |> float
    let dy = origin.y - p.y |> float
    let hypot = dx*dx + dy*dy |> Math.Sqrt
    hypot <= radius


let rectangle lower_left upper_right p =
    ((lower_left.x <= p.x) &&
     (p.x <= upper_right.x) &&
     (lower_left.y <= p.y) &&
     (p.y <= upper_right.y))


let square lower_left side_length =
    rectangle lower_left { x=lower_left.x+side_length;
                           y=lower_left.y+side_length }


let translate shape difference p =
    shape { x=p.x-difference.x; y=p.y-difference.y }


let union shape_1 shape_2 p =
    shape_1 p || shape_2 p
