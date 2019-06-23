/*------------------------------------------------------------------------
File        : parametrageInsitu.cls
Description : 
Author(s)   : kantena  -  2017/12/16
Notes       : genoffqt.p
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametrageInsitu inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/

    constructor public parametrageInsitu():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("INSITU").
    end constructor.

    method public logical isActif():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return this-object:isDbParameter and this-object:zon01 = "00001".
    end method.
end class.
