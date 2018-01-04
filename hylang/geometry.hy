#!/usr/bin/env hy
(import attr)
(import [functools [wraps]])
(import [math [hypot]])

(import [toolz [compose]])

(require [hy.extra.anaphoric [*]])


(with-decorator attr.s
   (defclass Point []
      [x (attr.ib) y (attr.ib)]

      (defn --iter-- [self]
         (yield-from [self.x self.y]))

      (defn --add-- [self [x y]]
         (Point (+ self.x x) (+ self.y y)))

      (defn --sub-- [self [x y]]
         (Point (- self.x x) (- self.y y)))

      (defn --mul-- [self scale]
         (Point (* self.x scale) (* self.y scale)))

      (defn --div-- [self scale]
         (Point (/ self.x scale) (/ self.y scale)))

      (defn --truediv-- [self scale]
         (Point (// self.x scale) (// self.y scale)))))


(with-decorator attr.s
   (defclass Region []
      [predicate (attr.ib)]

      (defn --contains-- [self point]
         (self.predicate point))

      (defn --or-- [self other]
         (Region (xi or (in x1 self) (in x1 other))))

      (defn --and-- [self other]
         (Region (xi and (in x1 self) (in x1 other))))

      (defn --xor-- [self other]
         (Region (xi ^ (in x1 self) (in x1 other))))))


(defn region [shape-func]
   ((wraps shape-func) (compose Region shape-func)))


(defmacro defshape [&rest body]
   `(with-decorator region
        (defn ~@body)))


(defshape circle [radius &optional [origin (Point 0 0)]]
   (fn [point]
      (<= (apply hypot (- point origin)) radius)))


(defshape rectangle [lower-left upper-right]
   (fn [point]
      (and (<= lower-left.x point.x upper-right.x)
           (<= lower-left.y point.y upper-right.y))))


(defn square [lower-left side-len]
   (rectangle lower-left (+ lower-left (Point side-len side-len))))
