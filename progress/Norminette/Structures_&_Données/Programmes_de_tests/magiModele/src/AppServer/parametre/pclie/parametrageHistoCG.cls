/*------------------------------------------------------------------------
File        : parametrageHistoCG.cls
Description : 
Author(s)   : kantena  -  2017/12/16
Notes       : genoffqt.p
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametrageHistoCG inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/

    constructor public parametrageHistoCG():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("HISCG").
    end constructor.

    method public logical isArchivageCle():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return this-object:zon02 = "00001".
    end method.
    method public date getDateNormalisation():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        if this-object:isArchivageCle() then do:
            date(this-object:zon03) no-error.
            if not error-status:error then return date(this-object:zon03).
        end.
        error-status:error = false.
        return ?.
    end method.
end class.
