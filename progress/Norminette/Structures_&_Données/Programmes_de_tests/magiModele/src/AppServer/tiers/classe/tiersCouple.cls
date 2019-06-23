/*------------------------------------------------------------------------
File        : tiersCouple.cls
Purpose     : 
Author(s)   : kantena - 2018/01/17
Notes       : 
------------------------------------------------------------------------*/
{preprocesseur/famille2tiers.i}
using tiers.classe.tiers.
using outils.outilTraduction.
block-level on error undo, throw.

class tiers.classe.tiersCouple inherits tiers.classe.tiersMultiple: 

    constructor public tiersCouple(piNumeroTiers as int64):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super(piNumeroTiers).
    end constructor.

    method public character getNomComplet():
        /*------------------------------------------------------------------------------
         Purpose: Retourne le nom complet
         Notes:
        ------------------------------------------------------------------------------*/
        if tiersPrincipal:codeSousFamille = {&SOUSFAMILLETIERS-epoux}
        then return outilTraduction:getLibelle(701761) + " " + tiersPrincipal:getNom().

        // Concubins & F-F & H-F & H-H    TODO  Traduction "et" ??? 
        return tiersPrincipal:getLibelleCivilite() + " " + tiersPrincipal:getNom() + " et " + tiersPrincipal:getLibelleCivilite() + " " + tiersSecondaire:getNom().
    end method.

    method public character getNomUsuelPrincipal():
        /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return trim(this-object:tiersPrincipal:nom).
    end method.
    
    method public character getNomUsuelSecondaire():
        /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return trim(this-object:tiersSecondaire:nom).
    end method.

end class.
