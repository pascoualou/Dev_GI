/*------------------------------------------------------------------------
File        : parametrageCodeESI.cls
Description :
Author(s)   : kantena  -  2017/09/29
Notes       : pclcdesi.p
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametrageCodeESI inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/

    constructor public parametrageCodeESI():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("CDESI").
    end constructor.
    constructor public parametrageCodeESI(pcZon01 as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("CDESI", pcZon01).
    end constructor.
end class.
