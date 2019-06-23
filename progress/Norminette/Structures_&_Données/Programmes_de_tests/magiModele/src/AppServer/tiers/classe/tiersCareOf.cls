/*------------------------------------------------------------------------
File        : tiersCareOf.cls
Purpose     :  
Author(s)   : kantena - 2017/10/20
Notes       : 
------------------------------------------------------------------------*/
{preprocesseur/famille2tiers.i}
using outils.outilTraduction.
block-level on error undo, throw.

class tiers.classe.tiersCareOf inherits tiers.classe.tiers:

    constructor public tiersCareOf():
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        super().
    end constructor.

    constructor public tiersCareOf(piNumeroTiers as int64):
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        super({&TYPETIERS-careOf}, piNumeroTiers).
    end constructor.
    
    method override public character getNom():
        /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
         return (if this-object:prenom > "" then trim(this-object:prenom) + " " else "") + trim(this-object:nom).
    end method.

    method override public character getNomComplet():
        /*------------------------------------------------------------------------------
         Purpose: Retourne le nom complet du C/O
         Notes:
        ------------------------------------------------------------------------------*/
         return "C/O " + this-object:getTitre() + this-object:getNom().
    end method.

end class.
