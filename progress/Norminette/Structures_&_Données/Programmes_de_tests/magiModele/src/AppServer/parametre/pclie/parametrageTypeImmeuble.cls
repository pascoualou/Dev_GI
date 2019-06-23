/*------------------------------------------------------------------------
File        : parametrageTypeImmeuble.cls
Description :
Author(s)   : kantena  -  2017/09/29
Notes       : pcltpimm_srv.p
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametrageTypeImmeuble inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/

    constructor public parametrageTypeImmeuble():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("TPIMM").
    end constructor.

end class.
