class Point
    constructor: (@x, @y) ->

    abs: () -> Math.hypot(@x, @y)


class IShape
    contains: (p) -> false


class Rectangle
    constructor: (lower_left, upper_right) ->
        if lower_left.y > upper_right.y
            @lower_left = upper_right
            @upper_right = lower_left
        else
            @lower_left = lower_left
            @upper_right = upper_right    

    contains: (p) ->
        ((@lower_left.y <= p.y <= @upper_right.y) and
         (@lower_left.x <= p.x <= @upper_right.x))


class Circle
    constructor: (@origin, @radius) ->

    contains: (p) ->
        hypot(@origin.x - p.x, @origin.y - p.y) <= @radius


module.exports = 
    Circle: Circle
    IShape: IShape
    Point: Point
    Rectangle: Rectangle
    
