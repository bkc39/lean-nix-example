/-
Copyright (c) 2026 IncidenceGeometry contributors. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: IncidenceGeometry contributors
-/
import Mathlib.Combinatorics.SimpleGraph.Basic

/-!
# Basic incidence geometries

This module defines a minimal incidence geometry: a type of points, a type of
lines, and an incidence relation between them. It also provides the associated
bipartite incidence graph as a `SimpleGraph`.
-/

namespace IncidenceGeometry

universe u

/-- A basic incidence geometry with points, lines, and an incidence relation. -/
structure Geometry where
  /-- The point type of the geometry. -/
  Point : Type u
  /-- The line type of the geometry. -/
  Line : Type u
  /-- The incidence relation between points and lines. -/
  Inc : Point -> Line -> Prop

/-- Three points are collinear if some line is incident with all three. -/
def Collinear (G : Geometry) (p q r : G.Point) : Prop :=
  Exists fun l : G.Line => G.Inc p l ∧ G.Inc q l ∧ G.Inc r l

/-- The bipartite graph whose edges are incidences between points and lines. -/
def incidenceGraph (G : Geometry) : SimpleGraph (G.Point ⊕ G.Line) where
  Adj x y :=
    match x, y with
    | Sum.inl p, Sum.inr l => G.Inc p l
    | Sum.inr l, Sum.inl p => G.Inc p l
    | _, _ => False
  symm := by
    intro x y h
    cases x <;> cases y <;> simp_all
  loopless := ⟨by
    intro x
    cases x <;> simp⟩

end IncidenceGeometry
