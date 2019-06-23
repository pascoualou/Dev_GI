/*------------------------------------------------------------------------
File        : parametrageEditionCRG.cls
Description :
Author(s)   : kantena  -  2017/09/29
Notes       :
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametrageEditionCRG inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/

    constructor public parametrageEditionCRG():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("EDCRG").
    end constructor.

    method public character getCodeTypeEdition():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return if this-object:zon01 > "" then this-object:zon01 else "00001".
    end method.
    method public logical isPresentationJustifBaseHonFac():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return this-object:zon04 = "00001".  // oui
    end method.
    method public logical isDetailHonoraireMensuel():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return this-object:zon05 = "00001".  // oui
    end method.
    method public logical isTrimesDecalePartielFinAnnee():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return this-object:zon06 = "00001".  // oui
    end method.

end class.
