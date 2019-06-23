/*------------------------------------------------------------------------
File        : tiersSecondaire.cls
Purpose     :  
Author(s)   : kantena - 2017/10/20
Notes       : 
------------------------------------------------------------------------*/
{preprocesseur/famille2tiers.i}
using outils.outilTraduction.
block-level on error undo, throw.

class tiers.classe.tiersSecondaire inherits tiers.classe.tiers:

    constructor public tiersSecondaire():
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        super().
    end constructor.

    constructor public tiersSecondaire (piNumeroTiers as int64):
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        super({&TYPETIERS-secondaire}, piNumeroTiers).
    end constructor.

end class.
