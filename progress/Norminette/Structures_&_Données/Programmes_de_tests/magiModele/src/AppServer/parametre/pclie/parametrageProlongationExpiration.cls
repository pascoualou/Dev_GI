/*------------------------------------------------------------------------
File        : parametrageProlongationExpiration.cls
Description :
Author(s)   : kantena  -  2017/09/29
Notes       :
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametrageProlongationExpiration inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/

    constructor public parametrageProlongationExpiration():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("FGEXP").
    end constructor.

    method public logical isQuittancementProlonge():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return this-object:zon01 = "00001".
    end method.

end class.
