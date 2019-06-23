/*------------------------------------------------------------------------
File        : parametrageActivationEuro.cls
Description :
Author(s)   : kantena  -  2017/09/29
Notes       :
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametrageActivationEuro inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/

    constructor public parametrageActivationEuro():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("ACEUR").
    end constructor.

    method public logical isEuroActif():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return zon01 = "00001".
    end method.
    method override public void create():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        assign
            tppar = "ACEUR"
            zon01 = "00001"
            zon02 = "00002"
            zon03 = string(true)
        .
        super:create().
    end method.
end class.
