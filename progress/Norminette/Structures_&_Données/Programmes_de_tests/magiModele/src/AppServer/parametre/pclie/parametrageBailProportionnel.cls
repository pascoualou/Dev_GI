/*------------------------------------------------------------------------
File        : parametrageBailProportionnel.cls
Description :
Author(s)   : kantena  -  2017/09/29
Notes       :
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametrageBailProportionnel inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/

    constructor public parametrageBailProportionnel():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("BAIPR").
    end constructor.

    method public decimal getPourcentageRevision():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return this-object:mnt01.
    end method.
    method public character getCodeRubriqueLoyer():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return this-object:zon01.
    end method.
    method public int64 getNumeroRubriqueLoyer():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return this-object:int01.
    end method.

end class.
