/*------------------------------------------------------------------------
File        : tiersContact.cls
Purpose     :  
Author(s)   : kantena - 2017/10/20
Notes       : 
------------------------------------------------------------------------*/
{preprocesseur/famille2tiers.i}
using outils.outilTraduction.
block-level on error undo, throw.

class tiers.classe.tiersContact inherits tiers.classe.tiers:

    constructor public tiersContact():
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        super().
    end constructor.

    constructor public tiersContact (piNumeroTiers as int64):
        /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        super({&TYPETIERS-contact}, piNumeroTiers).
    end constructor.
    
end class.
