/*------------------------------------------------------------------------
File        : parametrageTypeArrondi.cls
Description : 
Author(s)   : kantena  -  2018/01/02
Notes       :
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametrageTypeArrondi inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/

    constructor public parametrageTypeArrondi():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("CDARR").
    end constructor.

    method public character getTypeTroncatureLoyer():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return if this-object:isDbParameter then this-object:zon01 else "1".
    end method.
    method public character getTypeArrondiLoyer():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return if this-object:isDbParameter then this-object:zon02 else "00001".
    end method.
    method public character getTypeTroncatureRevision():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return if this-object:isDbParameter then this-object:zon03 else "1".
    end method.
    method public character getTypeArrondiRevision():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return if this-object:isDbParameter then this-object:zon04 else "00001".
    end method.
end class.
