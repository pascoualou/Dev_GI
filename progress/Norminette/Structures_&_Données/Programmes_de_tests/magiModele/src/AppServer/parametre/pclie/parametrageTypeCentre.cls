/*------------------------------------------------------------------------
File        : parametrageTypeCentre.cls
Description :
Author(s)   : kantena  -  2017/09/29
Notes       : fasie.i
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametrageTypeCentre inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/

    constructor public parametrageTypeCentre():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("CDSIE").
    end constructor.

    method public logical isGesTypeCentre():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return zon01 = "00001".
    end method.

end class.
