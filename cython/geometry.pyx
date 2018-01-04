from cpython.mem cimport PyMem_Malloc, PyMem_Realloc, PyMem_Free

cdef extern from "math.h":
    double hypot(double, double)
    double M_PI


cdef class Point:
    cdef public double x, y

    def __cinit__(self, double x, double y):
        self.x = x
        self.y = y

    def __abs__(self):
        return hypot(self.x, self.y)

    def __eq__(self, other):
        if isinstance(other, Point):
            return self.x == other.x and self.y == other.y
        return False

    def __ne__(self, other):
        if isinstance(other, Point):
            return self.x != other.x and self.y != other.y
        return True

    def __add__(self, Point other):
        return Point(self.x + other.x, self.y + other.y)

    def __sub__(self, Point other):
        return Point(self.x - other.x, self.y - other.y)

    def __mul__(self, double scale):
        return Point(self.x * scale, self.y * scale)

    def __truediv__(self, double scale):
        return Point(self.x / scale, self.y / scale)

    def __floordiv__(self, double scale):
        return Point(self.x // scale, self.y // scale)

    def __format__(self, fmt):
        return f'({self.x:{fmt}}, {self.y:{fmt}})'
    
    def __repr__(self):
        return f'Point({self.x}, {self.y})'

    def __str__(self):
        return f'({self.x}, {self.y})'

    def __iter__(self):
        yield self.x
        yield self.y


cdef class Region:
    cpdef bint contains(self, Point p) except *:
        return False

    def __contains__(self, Point p):
        return self.contains(p)

    def __and__(self, Region other):
        return FunctionalRegion(lambda p: self.contains(p) and other.contains(p))

    def __or__(self, Region other):
        return Union(self, other)

    def __xor__(self, Region other):
        return FunctionalRegion(lambda p: self.contains(p) ^ other.contains(p))

    def __neg__(self):
        return FunctionalRegion(lambda p: not self.contains(p))

    def __sub__(self, Region other):
        return FunctionalRegion(lambda p: self.contains(p) and not other.contains(p))


cdef class Union(Region):
    cdef readonly int _len
    cdef readonly list regions

    def __cinit__(self, regions):
        if not isinstance(regions, list):
            regions = list(regions)
        self.regions = regions
        self._len = len(regions)

    cpdef bint contains(self, Point p):
        cdef int i
        for i in range(self._len):
            if self.regions[i].contains(p):
                return True
        return False


cdef class FunctionalRegion(Region):
    """
    Helper class to help represent the union/intersection/negation
    etc. of Region objects. 

    For high performance, this classes should probably be migrated 
    to an individual class which implements it's own '.contains(Point)'
    method instead.
    """
    cdef readonly object fn
    cdef readonly unicode repr

    def __cinit__(self, fn):
        self.fn = fn

    cpdef bint contains(self, Point p):
        return self.fn(p)


def translate(Region reg, Point delta):
    def translated(Point p):
        return reg.contains(p - delta)
    return FunctionalRegion(translated)


cdef class Circle(Region):
    cdef readonly Point origin
    cdef readonly double radius

    def __cinit__(self, Point origin, double radius):
        self.origin = origin
        self.radius = radius

    cpdef bint contains(self, Point p) except *:
        return hypot(self.origin.x - p.x, self.origin.y - p.y) <= self.radius

    def __repr__(self):
        return f'Circle({self.origin!r}, {self.radius})'

    @property
    def area(self):
        return M_PI * self.radius * self.radius


cpdef Region ring(Point origin, double in_radius, double out_radius):
    return Circle(origin, out_radius) - Circle(origin, in_radius)


cdef class Ring(Region):
    cdef:
        Point origin
        double in_radius, out_radius

    def __cinit__(self, Point origin, double in_radius, double out_radius):
        self.origin = origin
        self.in_radius = in_radius
        self.out_radius = out_radius

    def __repr__(self):
        return f'Ring({self.origin!r}, {self.in_radius}, {self.out_radius})'

    cpdef bint contains(self, Point p):
        return (
            self.in_radius
            <= hypot(self.origin.x - p.x, self.origin.y - p.y)
            <= self.out_radius
        )


cdef class Rectangle(Region):
    cdef readonly Point left_corner, right_corner

    def __cinit__(self, Point left_corner, Point right_corner):
        self.left_corner = left_corner
        self.right_corner = right_corner

    cpdef bint contains(self, Point p) except *:
        return (
            self.left_corner.x <= p.x <= self.right_corner.x
            and self.left_corner.y <= p.y <= self.right_corner.y
        )

    @property
    def area(self):
        return abs((self.left_corner.x - self.right_corner.x)
                   * (self.left_corner.y - self.right_corner.y))


cpdef Rectangle square(Point left_corner, double length):
    return Rectangle(
        left_corner,
        Point(left_corner.x + length, left_corner.y + length)
    )


cdef class Triangle(Region):
    cdef Point p0, p1, p2

    def __cinit__(self, Point p0, Point p1, Point p2):
        if p0 == p1 or p1 == p2 or p0 == p2:
            raise ValueError('A triangle requires distinct points.')
        self.p0 = p0
        self.p1 = p1
        self.p2 = p2

    def __repr__(self):
        return f'Triangle({self.p0!r}, {self.p1!r}, {self.p2!r})'

    @property
    def area(self):
        cdef Point p0, p1, p2
        p0, p1, p2 = self.p0, self.p1, self.p2
        return 0.5 *(-p1.y*p2.x
                     + p0.y*(-p1.x + p2.x)
                     + p0.x*(p1.y - p2.y)
                     + p1.x*p2.y)

    cpdef bint contains(self, Point p) except *:
        cdef:
            double a, s, t
            Point p0 = self.p0, p1 = self.p1, p2 = self.p2
        
        a = self.area
        s = 1/(2*a)*(p0.y*p2.x - p0.x*p2.y
                     + (p2.y - p0.y)*p.x
                     + (p0.x - p2.x)*p.y)
        t = 1/(2*a)*(p0.x*p1.y - p0.y*p1.x
                     + (p0.y - p1.y)*p.x
                     + (p1.x - p0.x)*p.y)
        return 0 <= s <= 1 and 0 <= t <= 1

