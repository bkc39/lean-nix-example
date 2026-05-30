/-
Copyright (c) 2026 IncidenceGeometry contributors. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: IncidenceGeometry contributors
-/
import IncidenceGeometry.Basic

open IncidenceGeometry

namespace IncidenceGeometryTest

inductive Point
  | p
  | q
  | r
  deriving DecidableEq

inductive Line
  | l
  deriving DecidableEq

def testGeometry : Geometry where
  Point := Point
  Line := Line
  Inc _ _ := True

example : Collinear testGeometry Point.p Point.q Point.r := by
  exact ⟨Line.l, trivial, trivial, trivial⟩

example : (incidenceGraph testGeometry).Adj (Sum.inl Point.p) (Sum.inr Line.l) := by
  trivial

end IncidenceGeometryTest

def main : IO UInt32 :=
  pure 0
