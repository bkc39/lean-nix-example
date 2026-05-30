/-
Copyright (c) 2026 Playground contributors. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Playground contributors
-/
import Playground.Basic

open Playground

namespace PlaygroundTest

example : (2 : ℕ) ∣ 6 → (2 : ℕ) ∣ 36 := fun h => by
  have : (36 : ℕ) = 6 ^ 2 := by norm_num
  exact this ▸ Dvd.dvd.pow h (by norm_num)

example {n : ℕ} (h : 2 ∣ n ^ 2) : 2 ∣ n := two_dvd_of_two_dvd_sq h

example : ¬ ∃ q : ℚ, q ^ 2 = 2 := not_exists_rat_sq_eq_two

example : Irrational (Real.sqrt 2) := Playground.irrational_sqrt_two

end PlaygroundTest

def main : IO UInt32 :=
  pure 0
