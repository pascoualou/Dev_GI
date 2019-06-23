 
 /*------------------------------------------------------------------------
    File        : fusionQuittance
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : kantena
    Created     : Thu Feb 01 16:19:51 CET 2018
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

block-level on error undo, throw.

class bureautique.fusion.classe.fusionQuittance:
    /*------------------------------------------------------------------------------
    purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define public property LbDatUse                     as character no-undo get. set.
    define public property LbDatBai                     as character no-undo get. set.
    define public property montantloyer                 as decimal   no-undo get. set.
    define public property montantloyerBail             as decimal   no-undo get. set.
    define public property montantcharge                as decimal   no-undo get. set.
    define public property montantchargeBail            as decimal   no-undo get. set.
    define public property montantchargeFixe            as decimal   no-undo get. set.
    define public property montantFrais                 as decimal   no-undo get. set.
    define public property montantFraisBail             as decimal   no-undo get. set.
    define public property montantDroit                 as decimal   no-undo get. set.
    define public property montantDroitBail             as decimal   no-undo get. set.
    define public property montantDossier               as decimal   no-undo get. set.
    define public property montantDossierBail           as decimal   no-undo get. set.
    define public property montantHonoraire             as decimal   no-undo get. set.
    define public property montantHonoraireBail         as decimal   no-undo get. set.
    define public property montantTva                   as decimal   no-undo get. set.
    define public property montantTvaBail               as decimal   no-undo get. set.
    define public property montantEtat                  as decimal   no-undo get. set.
    define public property montantEtatBail              as decimal   no-undo get. set.
    define public property montantDepotGarantie         as decimal   no-undo get. set.
    define public property montantDepotGarantieBail     as decimal   no-undo get. set.
    define public property montantChargesAnnuel         as decimal   no-undo get. set.
    define public property montantChargesAnnuelBail     as decimal   no-undo get. set.
    define public property montantLoyerAnnuel           as decimal   no-undo get. set.
    define public property montantLoyerAnnuelBail        as decimal   no-undo get. set.
    define public property montantLoyerChargesAnnuel     as decimal   no-undo get. set.
    define public property montantLoyerChargesAnnuelBail as decimal   no-undo get. set.
    define public property montantTotalQuittance        as decimal   no-undo get. set.
    define public property descriptifLoyer              as character no-undo get. set.
    define public property descriptifLoyerBail          as character no-undo get. set.

    constructor public fusionQuittance ():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/

    end constructor.

end class.