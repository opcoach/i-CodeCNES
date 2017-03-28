subroutine mri_equa_vrai_t1_t2 (model, jul1950_t1, jul1950_t2, mat_pass, retour)

! (C) Copyright CNES - MSLIB - 1998-2003

!************************************************************************
!
! But:  Calcul de la matrice de passage du repere EQUAtorial VRAI a T1 au repere EQUAtorial VRAI a T2.
! ===
!
! Note d'utilisation: - Routine interne
! ==================   
!
!$Historique
! ==========
!   + Version 1.0 (SP 269 ed01 rev00): creation a partir de la routine MRQQVV de la MSLIB f77
!                         (Date: 09/1998 - Realisation: Veronique Lepine)
!   + Version 2.0 (DE 362 ed01 rev00): suppression des commentaires sur la limitation sur les dates et des codes retour
!                         (Date: 08/1999 - Realisation: Sylvain Vresk)
!   + Version 4.1 (DE globale 482 ed01 rev00): Corrections qualite
!                         (Date: 05/2003 - Realisation: Veronique Lepine)
!   + Version 6.5 : DM-ID 548 : diminution du nombre de fichiers sources
!                   (Date: 10/2006 - Realisation: Atos origin)
!   + Version 6.6 : DM-ID 616 remplacement des modules de constantes *_mslib 
!       par le module global parametre_mslib
!                   (Date: 05/2007 - Realisation: Atos origin)
!   + Version 6.8 : DM-ID 859 : utilisation de transpose3 et matmul3
!                   (Date: 03/2008 - Realisation: Atos origin)
!   + Version 6.9 : DM-ID 1058 : Suppression des warnings G95
!                   (Date: 09/2008 - Realisation: Atos origin)
!VERSION:V6.13:FA-ID:1410:30/09/2010:Ajout marqueur fin historique
!
!Revision 362 2013/02/15 bbjc
!DM-ID 1513: Suppression des warnings de compilation
!
!$FinHistorique
!
!************************************************************************

! Modules
! =======
use int_rep_fondamentaux, only : mr_obli_moy
use int_rep_fondamentaux, only : mr_nuta
use int_rep_fondamentaux, only : mr_mat_nuta
use int_rep_internes, only : mri_equa_M_equa_V

use type_mslib
use parametre_mslib


! Declarations
! ============
implicit none

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

integer, intent(in)                 :: model      ! indicateur du modele --> pm_lieske_wahr: LIESKE + WAHR
type(tm_jour_sec), intent(in)       :: jul1950_t1 ! date du repere initial
type(tm_jour_sec), intent(in)       :: jul1950_t2 ! date du repere final

real(pm_reel), dimension(3,3), intent(out) :: mat_pass ! matrice de passage
integer, intent(out)                ::  retour

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Autres declarations
! -------------------
real(pm_reel)                  :: obli_moy    ! obliquite moyenne a t1
type(tm_nuta)                  :: nuta        ! nutation en longitude et en obliquite a t1
type(tm_code_retour)           :: code_retour, code_retour_local
real(pm_reel), dimension(3,3)  :: mat_nuta    ! matrice de nutation
real(pm_reel), dimension(3,3)  :: mat_pass1, mat_pass2                 ! matrices intermediaire
integer                        ::  modele_precession, modele_nutation  ! indicateurs des modeles de precession et de nutation
                                                                       ! associes a "model" en entree

character(len=pm_longueur_info_utilisateur), parameter :: info_utilisateur = &
                     '@(#) Fichier MSLIB mri_equa_vrai_t1_t2.f90: derniere modification V6.13 >'

! Ne pas toucher a la ligne suivante
character(len=pm_longueur_rcs_id), parameter :: rcs_id =' $Id: mri_equa_vrai_t1_t2.f90 362 2013-02-15 18:01:28Z bbjc $ '

!************************************************************************

! initialisation de la valeur du code retour
! ..........................................
retour = pm_OK

if (model == pm_lieske_wahr) then

   ! calcul de la matrice de passage du repere equatorial vrai a t1 au repere equatorial vrai a t2
   ! avec le modele de precession de Lieske et le modele de nutation de Wahr (epoque de base : J2000)

   modele_precession = pm_lieske
   modele_nutation   = pm_wahr

   ! ======================
   ! obliquite moyenne a t1
   ! ======================

   call mr_obli_moy(modele_precession, jul1950_t1, obli_moy, code_retour)
   ! pas de test de retour car il ne peut etre que nul (controles deja effectues)

   ! ==========================================
   ! nutation en longitude et en obliquite a t1
   ! ==========================================

   call mr_nuta(modele_nutation, jul1950_t1, nuta, code_retour)
   ! pas de test de retour car il ne peut etre que nul (controles deja effectues)

   ! ===================
   ! matrice de nutation
   ! ===================

   call mr_mat_nuta(nuta, obli_moy, mat_nuta, code_retour)
   ! pas de test de retour car il ne peut etre que nul (controles deja effectues)

   ! =======================
   ! transposition de matrice
   ! =======================

   call mu_transpose3(mat_nuta,mat_pass1,code_retour_local)
   ! Le code retour n est pas teste car pas d erreur possible

   ! ===============================================================
   ! calcul de la matrice de passage du repere equatorial moyen a t1
   ! au repere  equatorial vrai a t2
   ! ===============================================================

   call mri_equa_M_equa_V(model, jul1950_t1, jul1950_t2, mat_pass2, retour)
   ! pas de test de retour car il ne peut etre que nul (controles deja effectues)

   ! =================
   ! produit matriciel
   ! =================

   call mu_matmul3(mat_pass2,mat_pass1,mat_pass,code_retour_local)
   ! Le code retour n est pas teste car pas d erreur possible
   ! pas d'erreur possible donc pas de test dur code retour

else    !   modele inconnu

   retour = pm_err_ind_model

end if

end subroutine mri_equa_vrai_t1_t2
