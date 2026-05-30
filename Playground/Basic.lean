/-
Copyright (c) 2026 Playground contributors. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Playground contributors
-/
import Mathlib.NumberTheory.Real.Irrational

/-!
# Irrationality of `√2`

This module is a small, self-contained development of the classical theorem that
`√2` is irrational. It is structured to exercise the blueprint dependency graph:
a primality fact feeds a descent lemma, which feeds the rational obstruction,
which in turn yields irrationality over the reals.

The pieces are:

* `two_dvd_of_two_dvd_sq`: if `2` divides `n ^ 2` then `2` divides `n`;
* `sq_ne_two_mul_sq`: a coprime pair has no solution to `p ^ 2 = 2 * q ^ 2`;
* `not_exists_rat_sq_eq_two`: no rational squares to `2`;
* `irrational_sqrt_two`: `√2` is irrational.
-/

namespace Playground

/-- If `2` divides `n ^ 2`, then `2` divides `n`. This is the only place the
primality of `2` enters the argument. -/
theorem two_dvd_of_two_dvd_sq {n : ℕ} (h : 2 ∣ n ^ 2) : 2 ∣ n :=
  Nat.prime_two.dvd_of_dvd_pow h

/-- The descent step: a coprime pair `p, q` never satisfies `p ^ 2 = 2 * q ^ 2`.
If it did, then `2 ∣ p` and `2 ∣ q`, contradicting coprimality. -/
theorem sq_ne_two_mul_sq {p q : ℕ} (hcop : Nat.Coprime p q) :
    p ^ 2 ≠ 2 * q ^ 2 := by
  intro heq
  have hp : 2 ∣ p := two_dvd_of_two_dvd_sq ⟨q ^ 2, heq⟩
  obtain ⟨k, rfl⟩ := hp
  have hqsq : q ^ 2 = 2 * k ^ 2 := by ring_nf at heq ⊢; omega
  have hq : 2 ∣ q := two_dvd_of_two_dvd_sq ⟨k ^ 2, hqsq⟩
  have hdvd : (2 : ℕ) ∣ Nat.gcd (2 * k) q := Nat.dvd_gcd ⟨k, rfl⟩ hq
  rw [hcop] at hdvd
  omega

/-- There is no rational number whose square is `2`. This is the elementary
heart of the irrationality of `√2`: a candidate `q` is put over its reduced
numerator and denominator, which are coprime, and `sq_ne_two_mul_sq` rules it
out. -/
theorem not_exists_rat_sq_eq_two : ¬ ∃ q : ℚ, q ^ 2 = 2 := by
  rintro ⟨q, hq⟩
  have hden : (q.den : ℚ) ≠ 0 := by exact_mod_cast q.den_nz
  -- Clear denominators to land in the integers.
  have hint : (q.num : ℤ) ^ 2 = 2 * (q.den : ℤ) ^ 2 := by
    have hqd : (q.num : ℚ) / (q.den : ℚ) = q := Rat.num_div_den q
    rw [← hqd] at hq
    field_simp at hq
    have hQ : (q.num : ℚ) ^ 2 = 2 * (q.den : ℚ) ^ 2 := by linarith [hq]
    exact_mod_cast hQ
  -- Pass to natural numbers via `Int.natAbs`.
  have hnat : q.num.natAbs ^ 2 = 2 * q.den ^ 2 := by
    have := congrArg Int.natAbs hint
    simpa [Int.natAbs_mul, Int.natAbs_pow] using this
  exact sq_ne_two_mul_sq q.reduced hnat

/-- **Irrationality of `√2`.** -/
theorem irrational_sqrt_two : Irrational (Real.sqrt 2) := by
  rintro ⟨q, hq⟩
  -- From `(q : ℝ) = √2` we get `(q : ℝ) ^ 2 = 2`, hence `q ^ 2 = 2` in `ℚ`.
  have hsq : (q : ℝ) ^ 2 = 2 := by
    rw [hq, Real.sq_sqrt (by norm_num)]
  have hq2 : q ^ 2 = 2 := by exact_mod_cast hsq
  exact not_exists_rat_sq_eq_two ⟨q, hq2⟩

end Playground
