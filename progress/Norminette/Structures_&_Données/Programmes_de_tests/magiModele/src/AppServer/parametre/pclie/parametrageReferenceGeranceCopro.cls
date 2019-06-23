/*------------------------------------------------------------------------
File        : parametrageReferenceGeranceCopro.cls
Description :
Author(s)   : kantena  -  2017/09/29
Notes       :
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametrageReferenceGeranceCopro inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/

    constructor public parametrageReferenceGeranceCopro():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("RFCLI").
    end constructor.

    method public character getReferenceGerance():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return zon01.
    end method.
    method public character getReferenceCopro():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return zon02.
    end method.

end class.
