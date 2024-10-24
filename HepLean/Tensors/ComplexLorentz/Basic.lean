/-
Copyright (c) 2024 Joseph Tooby-Smith. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Joseph Tooby-Smith
-/
import HepLean.Tensors.OverColor.Basic
import HepLean.Tensors.Tree.Dot
import HepLean.SpaceTime.WeylFermion.Contraction
import HepLean.SpaceTime.WeylFermion.Metric
import HepLean.SpaceTime.WeylFermion.Unit
import HepLean.SpaceTime.LorentzVector.Complex.Contraction
import HepLean.SpaceTime.LorentzVector.Complex.Metric
import HepLean.SpaceTime.LorentzVector.Complex.Unit
import HepLean.Mathematics.PiTensorProduct
import HepLean.SpaceTime.PauliMatrices.AsTensor
/-!

## Complex Lorentz tensors

-/

namespace Fermion

open Matrix
open MatrixGroups
open Complex
open TensorProduct
open IndexNotation
open CategoryTheory
open MonoidalCategory

/-- The colors associated with complex representations of SL(2, ℂ) of intrest to physics. -/
inductive Color
  | upL : Color
  | downL : Color
  | upR : Color
  | downR : Color
  | up : Color
  | down : Color

instance : DecidableEq Color := fun x y =>
  match x, y with
  | Color.upL, Color.upL => isTrue rfl
  | Color.downL, Color.downL => isTrue rfl
  | Color.upR, Color.upR => isTrue rfl
  | Color.downR, Color.downR => isTrue rfl
  | Color.up, Color.up => isTrue rfl
  | Color.down, Color.down => isTrue rfl
  /- The false -/
  | Color.upL, Color.downL => isFalse fun h => Color.noConfusion h
  | Color.upL, Color.upR => isFalse fun h => Color.noConfusion h
  | Color.upL, Color.downR => isFalse fun h => Color.noConfusion h
  | Color.upL, Color.up => isFalse fun h => Color.noConfusion h
  | Color.upL, Color.down => isFalse fun h => Color.noConfusion h
  | Color.downL, Color.upL => isFalse fun h => Color.noConfusion h
  | Color.downL, Color.upR => isFalse fun h => Color.noConfusion h
  | Color.downL, Color.downR => isFalse fun h => Color.noConfusion h
  | Color.downL, Color.up => isFalse fun h => Color.noConfusion h
  | Color.downL, Color.down => isFalse fun h => Color.noConfusion h
  | Color.upR, Color.upL => isFalse fun h => Color.noConfusion h
  | Color.upR, Color.downL => isFalse fun h => Color.noConfusion h
  | Color.upR, Color.downR => isFalse fun h => Color.noConfusion h
  | Color.upR, Color.up => isFalse fun h => Color.noConfusion h
  | Color.upR, Color.down => isFalse fun h => Color.noConfusion h
  | Color.downR, Color.upL => isFalse fun h => Color.noConfusion h
  | Color.downR, Color.downL => isFalse fun h => Color.noConfusion h
  | Color.downR, Color.upR => isFalse fun h => Color.noConfusion h
  | Color.downR, Color.up => isFalse fun h => Color.noConfusion h
  | Color.downR, Color.down => isFalse fun h => Color.noConfusion h
  | Color.up, Color.upL => isFalse fun h => Color.noConfusion h
  | Color.up, Color.downL => isFalse fun h => Color.noConfusion h
  | Color.up, Color.upR => isFalse fun h => Color.noConfusion h
  | Color.up, Color.downR => isFalse fun h => Color.noConfusion h
  | Color.up, Color.down => isFalse fun h => Color.noConfusion h
  | Color.down, Color.upL => isFalse fun h => Color.noConfusion h
  | Color.down, Color.downL => isFalse fun h => Color.noConfusion h
  | Color.down, Color.upR => isFalse fun h => Color.noConfusion h
  | Color.down, Color.downR => isFalse fun h => Color.noConfusion h
  | Color.down, Color.up => isFalse fun h => Color.noConfusion h

noncomputable section

/-- The tensor structure for complex Lorentz tensors. -/
def complexLorentzTensor : TensorSpecies where
  C := Fermion.Color
  G := SL(2, ℂ)
  G_group := inferInstance
  k := ℂ
  k_commRing := inferInstance
  FDiscrete := Discrete.functor fun c =>
    match c with
    | Color.upL => Fermion.leftHanded
    | Color.downL => Fermion.altLeftHanded
    | Color.upR => Fermion.rightHanded
    | Color.downR => Fermion.altRightHanded
    | Color.up => Lorentz.complexContr
    | Color.down => Lorentz.complexCo
  τ := fun c =>
    match c with
    | Color.upL => Color.downL
    | Color.downL => Color.upL
    | Color.upR => Color.downR
    | Color.downR => Color.upR
    | Color.up => Color.down
    | Color.down => Color.up
  τ_involution c := by
    match c with
    | Color.upL => rfl
    | Color.downL => rfl
    | Color.upR => rfl
    | Color.downR => rfl
    | Color.up => rfl
    | Color.down => rfl
  contr := Discrete.natTrans fun c =>
    match c with
    | Discrete.mk Color.upL => Fermion.leftAltContraction
    | Discrete.mk Color.downL => Fermion.altLeftContraction
    | Discrete.mk Color.upR => Fermion.rightAltContraction
    | Discrete.mk Color.downR => Fermion.altRightContraction
    | Discrete.mk Color.up => Lorentz.contrCoContraction
    | Discrete.mk Color.down => Lorentz.coContrContraction
  metric := Discrete.natTrans fun c =>
    match c with
    | Discrete.mk Color.upL => Fermion.leftMetric
    | Discrete.mk Color.downL => Fermion.altLeftMetric
    | Discrete.mk Color.upR => Fermion.rightMetric
    | Discrete.mk Color.downR => Fermion.altRightMetric
    | Discrete.mk Color.up => Lorentz.contrMetric
    | Discrete.mk Color.down => Lorentz.coMetric
  unit := Discrete.natTrans fun c =>
    match c with
    | Discrete.mk Color.upL => Fermion.altLeftLeftUnit
    | Discrete.mk Color.downL => Fermion.leftAltLeftUnit
    | Discrete.mk Color.upR => Fermion.altRightRightUnit
    | Discrete.mk Color.downR => Fermion.rightAltRightUnit
    | Discrete.mk Color.up => Lorentz.coContrUnit
    | Discrete.mk Color.down => Lorentz.contrCoUnit
  repDim := fun c =>
    match c with
    | Color.upL => 2
    | Color.downL => 2
    | Color.upR => 2
    | Color.downR => 2
    | Color.up => 4
    | Color.down => 4
  repDim_neZero := fun c =>
    match c with
    | Color.upL => inferInstance
    | Color.downL => inferInstance
    | Color.upR => inferInstance
    | Color.downR => inferInstance
    | Color.up => inferInstance
    | Color.down => inferInstance
  basis := fun c =>
    match c with
    | Color.upL => Fermion.leftBasis
    | Color.downL => Fermion.altLeftBasis
    | Color.upR => Fermion.rightBasis
    | Color.downR => Fermion.altRightBasis
    | Color.up => Lorentz.complexContrBasisFin4
    | Color.down => Lorentz.complexCoBasisFin4
  contr_tmul_symm := fun c =>
    match c with
    | Color.upL => Fermion.leftAltContraction_tmul_symm
    | Color.downL => Fermion.altLeftContraction_tmul_symm
    | Color.upR => Fermion.rightAltContraction_tmul_symm
    | Color.downR => Fermion.altRightContraction_tmul_symm
    | Color.up => Lorentz.contrCoContraction_tmul_symm
    | Color.down => Lorentz.coContrContraction_tmul_symm
  contr_unit := fun c =>
    match c with
    | Color.upL => Fermion.contr_altLeftLeftUnit
    | Color.downL => Fermion.contr_leftAltLeftUnit
    | Color.upR => Fermion.contr_altRightRightUnit
    | Color.downR => Fermion.contr_rightAltRightUnit
    | Color.up => Lorentz.contr_coContrUnit
    | Color.down => Lorentz.contr_contrCoUnit

instance : DecidableEq complexLorentzTensor.C := Fermion.instDecidableEqColor

lemma basis_contr (c : complexLorentzTensor.C) (i : Fin (complexLorentzTensor.repDim c))
    (j : Fin (complexLorentzTensor.repDim (complexLorentzTensor.τ c))) :
    complexLorentzTensor.castToField
    ((complexLorentzTensor.contr.app {as := c}).hom
    (complexLorentzTensor.basis c i ⊗ₜ complexLorentzTensor.basis (complexLorentzTensor.τ c) j)) =
    if i.val = j.val then 1 else 0 :=
  match c with
  | Color.upL => Fermion.leftAltContraction_basis _ _
  | Color.downL => Fermion.altLeftContraction_basis _ _
  | Color.upR => Fermion.rightAltContraction_basis _ _
  | Color.downR => Fermion.altRightContraction_basis _ _
  | Color.up => Lorentz.contrCoContraction_basis _ _
  | Color.down => Lorentz.coContrContraction_basis _ _

end
end Fermion
