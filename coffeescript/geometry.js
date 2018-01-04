// Generated by CoffeeScript 2.1.1
(function() {
  var Circle, IShape, Point, Rectangle;

  Point = class Point {
    constructor(x, y) {
      this.x = x;
      this.y = y;
    }

    abs() {
      return Math.hypot(this.x, this.y);
    }

  };

  IShape = class IShape {
    contains(p) {
      return false;
    }

  };

  Rectangle = class Rectangle {
    constructor(lower_left, upper_right) {
      if (lower_left.y > upper_right.y) {
        this.lower_left = upper_right;
        this.upper_right = lower_left;
      } else {
        this.lower_left = lower_left;
        this.upper_right = upper_right;
      }
    }

    contains(p) {
      var ref, ref1;
      return ((this.lower_left.y <= (ref = p.y) && ref <= this.upper_right.y)) && ((this.lower_left.x <= (ref1 = p.x) && ref1 <= this.upper_right.x));
    }

  };

  Circle = class Circle {
    constructor(origin, radius) {
      this.origin = origin;
      this.radius = radius;
    }

    contains(p) {
      return hypot(this.origin.x - p.x, this.origin.y - p.y) <= this.radius;
    }

  };

  module.exports = {
    Circle: Circle,
    IShape: IShape,
    Point: Point,
    Rectangle: Rectangle
  };

}).call(this);