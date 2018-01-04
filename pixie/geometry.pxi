(ns geometry
  (:require [pixie.math :refer [hypot]]
            [pixie.stdlib :as std]))


(defrecord Point [^Number x, ^Number y])


(defn circle
  ([^Number radius]
   (circle (->Point 0 0) radius))
  ([^Point origin, ^Number radius]
   (fn [^Point p]
     (let [o_x (:x origin)
           o_y (:y origin)
           x (:x p)
           y (:y p)
           dx (- o_x x)
           dy (- o_y y)]
       (>= radius (hypot dx dy))))))


(defn rectangle [^Point bottom-left, ^Number width, ^Number height]
  (fn [^Point p]
    (let [max-x (+ (:x bottom-left) width)
          min-x (:x bottom-left)
          max-y (+ (:y bottom-left) height)
          min-y (:y bottom-left)]
      (and (>= max-x (:x p) min-x)
           (>= max-y (:y p) min-y)))))


(defn square [^Point bottom-left, ^Number side-length]
  (rectangle bottom-left side-length side-length))


(defn or [& shapes]
  (fn [^Point p]
    (apply std/or
           (map (fn [shape] (shape p)) shapes))))


(defn and [& shapes]
  (fn [^Point p]
    (apply std/and
           (map (fn [shape] (shape p)) shapes))))


