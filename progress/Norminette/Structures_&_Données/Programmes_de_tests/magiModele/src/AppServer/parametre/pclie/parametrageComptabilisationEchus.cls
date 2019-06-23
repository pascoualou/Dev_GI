/*------------------------------------------------------------------------
File        : parametrageComptabilisationEchus.cls
Description :
Author(s)   : kantena  -  2017/09/29
Notes       :
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametrageComptabilisationEchus inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/

    constructor public parametrageComptabilisationEchus():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("CPECH", "00001").
    end constructor.

    method public logical isComtabilisationEchu():
        /*------------------------------------------------------------------------------
        Purpose: comptabilisation des echus dans le mois precedent
        Notes:
        ------------------------------------------------------------------------------*/
        return this-object:zon01 = "00001".
    end method.

    method public logical isValidationEchuSepare():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return this-object:zon01 = "00001" and this-object:zon02 = "00001".
    end method.

end class.
