/*------------------------------------------------------------------------
File        : tiersPrincipal.cls
Purpose     :  
Author(s)   : kantena - 2017/10/20
Notes       : 
------------------------------------------------------------------------*/
{preprocesseur/famille2tiers.i}
using outils.outilTraduction.
block-level on error undo, throw.

class tiers.classe.tiersPrincipal inherits tiers.classe.tiers:

    constructor public tiersPrincipal():
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        super().
    end constructor.

    constructor public tiersPrincipal (piNumeroTiers as int64):
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        super({&TYPETIERS-principal}, piNumeroTiers).
    end constructor.
    
end class.
