/-
Copyright (c) 2025 Joseph Tooby-Smith. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Joseph Tooby-Smith
-/
import HepLean.PerturbationTheory.WickContraction.TimeSet
import HepLean.PerturbationTheory.Algebras.FieldOpAlgebra.StaticWickTheorem
import HepLean.Meta.Remark.Basic
/-!

# Wick's theorem for normal ordered lists

-/

namespace FieldSpecification
variable {𝓕 : FieldSpecification}
open CrAnAlgebra
namespace FieldOpAlgebra
open WickContraction
open EqTimeOnly

lemma timeOrder_ofFieldOpList_eqTimeOnly (φs : List 𝓕.States) :
    timeOrder (ofFieldOpList φs) = ∑ (φsΛ : EqTimeOnly φs),
     φsΛ.1.sign • φsΛ.1.timeContract.1 * 𝓣(𝓝(ofFieldOpList [φsΛ.1]ᵘᶜ)):= by
  rw [static_wick_theorem φs]
  let e2 : WickContraction φs.length ≃ {φsΛ // φsΛ ∈ EqTimeOnly φs} ⊕ {φsΛ // ¬ φsΛ ∈ EqTimeOnly φs} :=
    (Equiv.sumCompl (Membership.mem (EqTimeOnly φs))).symm
  rw [← e2.symm.sum_comp]
  simp only [Equiv.symm_symm, Algebra.smul_mul_assoc, Fintype.sum_sum_type,
    Equiv.sumCompl_apply_inl, Equiv.sumCompl_apply_inr, map_add, map_sum, map_smul, e2]
  conv_lhs =>
    enter [2, 2, x]
    rw [timeOrder_timeOrder_left]
    rw [timeOrder_staticContract_of_not_mem _ x.2]
  simp
  congr
  funext x
  rw [staticContract_eq_timeContract]
  rw [timeOrder_timeContract_mul_of_mem_left]
  exact x.2

lemma timeOrder_ofFieldOpList_eq_eqTimeOnly_empty (φs : List 𝓕.States) :
    timeOrder (ofFieldOpList φs) =  𝓣(𝓝(ofFieldOpList φs)) +
    ∑ (φsΛ : {φsΛ // φsΛ ∈ EqTimeOnly φs ∧ φsΛ ≠ empty}),
     φsΛ.1.sign • φsΛ.1.timeContract.1 * 𝓣(𝓝(ofFieldOpList [φsΛ.1]ᵘᶜ)) := by
  let e1 : EqTimeOnly φs ≃ {φsΛ : EqTimeOnly φs // φsΛ.1 = empty} ⊕ {φsΛ : EqTimeOnly φs // ¬ φsΛ.1 = empty} :=
     (Equiv.sumCompl fun (a : EqTimeOnly φs) => a.1 = empty).symm
  rw [timeOrder_ofFieldOpList_eqTimeOnly, ← e1.symm.sum_comp]
  simp [e1]
  congr 1
  · let e2 : { φsΛ :  EqTimeOnly φs // φsΛ.1 = empty } ≃ Unit := {
      toFun := fun x => (), invFun := fun x => ⟨⟨empty, by simp⟩, rfl⟩,
      left_inv a := by
        ext
        simp [a.2], right_inv a := by simp }
    rw [← e2.symm.sum_comp]
    simp [e2, sign_empty]
  · let e2 : { φsΛ :  EqTimeOnly φs // ¬ φsΛ.1 = empty } ≃
      {φsΛ // φsΛ ∈ EqTimeOnly φs ∧ φsΛ ≠ empty} := {
        toFun := fun x => ⟨x, ⟨x.1.2, x.2⟩⟩, invFun := fun x => ⟨⟨x.1, x.2.1⟩, x.2.2⟩,
        left_inv a := by rfl, right_inv a := by rfl }
    rw [← e2.symm.sum_comp]
    rfl

lemma normalOrder_timeOrder_ofFieldOpList_eq_eqTimeOnly_empty (φs : List 𝓕.States) :
    𝓣(𝓝(ofFieldOpList φs)) =  𝓣(ofFieldOpList φs) -
    ∑ (φsΛ : {φsΛ // φsΛ ∈ EqTimeOnly φs ∧ φsΛ ≠ empty}),
     φsΛ.1.sign • φsΛ.1.timeContract.1 * 𝓣(𝓝(ofFieldOpList [φsΛ.1]ᵘᶜ)) := by
  rw [timeOrder_ofFieldOpList_eq_eqTimeOnly_empty]
  simp

lemma normalOrder_timeOrder_ofFieldOpList_eq_haveEqTime_sum_not_haveEqTime (φs : List 𝓕.States) :
    𝓣(𝓝(ofFieldOpList φs)) =  (∑ (φsΛ : {φsΛ : WickContraction φs.length // ¬ HaveEqTime φsΛ}),
     φsΛ.1.sign • φsΛ.1.timeContract.1 * 𝓝(ofFieldOpList [φsΛ.1]ᵘᶜ))
     + (∑ (φsΛ : {φsΛ : WickContraction φs.length // HaveEqTime φsΛ}),
     φsΛ.1.sign • φsΛ.1.timeContract.1 * 𝓝(ofFieldOpList [φsΛ.1]ᵘᶜ))
     - ∑ (φsΛ : {φsΛ // φsΛ ∈ EqTimeOnly φs ∧ φsΛ ≠ empty}),
     φsΛ.1.sign • φsΛ.1.timeContract.1 * 𝓣(𝓝(ofFieldOpList [φsΛ.1]ᵘᶜ)) := by
  rw [normalOrder_timeOrder_ofFieldOpList_eq_eqTimeOnly_empty]
  rw [wicks_theorem]
  let e1 : WickContraction φs.length ≃ {φsΛ //  HaveEqTime φsΛ} ⊕  {φsΛ // ¬ HaveEqTime φsΛ} := by
    exact (Equiv.sumCompl HaveEqTime).symm
  rw [← e1.symm.sum_comp]
  simp [e1]
  rw [add_comm]

lemma haveEqTime_wick_sum_eq_split (φs : List 𝓕.States) :
    (∑ (φsΛ : {φsΛ : WickContraction φs.length // HaveEqTime φsΛ}),
     φsΛ.1.sign • φsΛ.1.timeContract.1 * 𝓝(ofFieldOpList [φsΛ.1]ᵘᶜ)) =
    ∑ (φsΛ : {φsΛ // φsΛ ∈ EqTimeOnly φs ∧ φsΛ ≠ empty}), (sign φs ↑φsΛ • (φsΛ.1).timeContract *
    ∑ φssucΛ : { φssucΛ : WickContraction [φsΛ.1]ᵘᶜ.length // ¬φssucΛ.HaveEqTime },
      sign [φsΛ.1]ᵘᶜ φssucΛ •
      (φssucΛ.1).timeContract * normalOrder (ofFieldOpList [φssucΛ.1]ᵘᶜ)) := by
  let f : WickContraction φs.length → 𝓕.FieldOpAlgebra := fun φsΛ =>
    φsΛ.sign • φsΛ.timeContract.1 * 𝓝(ofFieldOpList [φsΛ]ᵘᶜ)
  change ∑ (φsΛ : {φsΛ : WickContraction φs.length // HaveEqTime φsΛ}), f φsΛ.1 = _
  rw [sum_haveEqTime]
  congr
  funext φsΛ
  simp only [ f]
  conv_lhs =>
    enter [2, φsucΛ]
    enter [1]
    rw [join_sign_timeContract φsΛ.1 φsucΛ.1]
  conv_lhs =>
    enter [2, φsucΛ]
    rw [mul_assoc]
  rw [← Finset.mul_sum]
  congr
  funext φsΛ'
  simp
  congr 1
  rw [@join_uncontractedListGet]


lemma normalOrder_timeOrder_ofFieldOpList_eq_not_haveEqTime_sub_inductive (φs : List 𝓕.States) :
    𝓣(𝓝(ofFieldOpList φs)) = (∑ (φsΛ : {φsΛ : WickContraction φs.length // ¬ HaveEqTime φsΛ}),
     φsΛ.1.sign • φsΛ.1.timeContract.1 * 𝓝(ofFieldOpList [φsΛ.1]ᵘᶜ))
      + ∑ (φsΛ : {φsΛ // φsΛ ∈ EqTimeOnly φs ∧ φsΛ ≠ empty}),
        sign φs ↑φsΛ • (φsΛ.1).timeContract *
        (∑ φssucΛ : { φssucΛ : WickContraction [φsΛ.1]ᵘᶜ.length // ¬ φssucΛ.HaveEqTime },
      sign [φsΛ.1]ᵘᶜ φssucΛ • (φssucΛ.1).timeContract * normalOrder (ofFieldOpList [φssucΛ.1]ᵘᶜ) -
       𝓣(𝓝(ofFieldOpList [φsΛ.1]ᵘᶜ))) := by
  rw [normalOrder_timeOrder_ofFieldOpList_eq_haveEqTime_sum_not_haveEqTime]
  rw [add_sub_assoc]
  congr 1
  rw [haveEqTime_wick_sum_eq_split]
  simp
  rw [← Finset.sum_sub_distrib]
  congr 1
  funext x
  simp
  rw [← smul_sub, ← mul_sub]

lemma wicks_theorem_normal_order_empty : 𝓣(𝓝(ofFieldOpList [])) = ∑ (φsΛ : {φsΛ : WickContraction ([] : List 𝓕.States).length // ¬ HaveEqTime φsΛ}),
     φsΛ.1.sign • φsΛ.1.timeContract.1 * 𝓝(ofFieldOpList [φsΛ.1]ᵘᶜ)  := by
  let e2 : {φsΛ : WickContraction ([] : List 𝓕.States).length // ¬ HaveEqTime φsΛ} ≃ Unit :=
    {
      toFun := fun x => (),
      invFun := fun x => ⟨empty, by simp⟩,
      left_inv := by
        intro a
        simp
        apply Subtype.eq
        apply Subtype.eq
        simp [empty]
        ext i
        simp
        by_contra hn
        have h2 := a.1.2.1 i hn
        rw [@Finset.card_eq_two] at h2
        obtain ⟨a, b, ha, hb, hab⟩ := h2
        exact Fin.elim0 a,
      right_inv := by intro a; simp}
  rw [← e2.symm.sum_comp]
  simp [e2, sign_empty]
  have h1' : ofFieldOpList (𝓕 := 𝓕) [] = ofCrAnFieldOpList [] := by rfl
  rw [h1']
  rw [normalOrder_ofCrAnFieldOpList]
  simp
  rw [ofCrAnFieldOpList, timeOrder_eq_ι_timeOrderF]
  rw [timeOrderF_ofCrAnList]
  simp

theorem wicks_theorem_normal_order : (φs : List 𝓕.States) →
    𝓣(𝓝(ofFieldOpList φs)) = ∑ (φsΛ : {φsΛ : WickContraction φs.length // ¬ HaveEqTime φsΛ}),
     φsΛ.1.sign • φsΛ.1.timeContract.1 * 𝓝(ofFieldOpList [φsΛ.1]ᵘᶜ)
  | [] => wicks_theorem_normal_order_empty
  | φ :: φs => by
    rw [normalOrder_timeOrder_ofFieldOpList_eq_not_haveEqTime_sub_inductive]
    simp only [ Algebra.smul_mul_assoc, ne_eq, add_right_eq_self]
    apply Finset.sum_eq_zero
    intro φsΛ hφsΛ
    simp only [smul_eq_zero]
    right
    have ih := wicks_theorem_normal_order [φsΛ.1]ᵘᶜ
    rw [ih]
    simp
termination_by φs => φs.length
decreasing_by
  simp only [uncontractedListGet, List.length_cons, List.length_map, gt_iff_lt]
  rw [uncontractedList_length_eq_card]
  have hc := uncontracted_card_eq_iff φsΛ.1
  simp [φsΛ.2.2] at hc
  have hc' := uncontracted_card_le φsΛ.1
  simp_all
  omega


end FieldOpAlgebra
end FieldSpecification
