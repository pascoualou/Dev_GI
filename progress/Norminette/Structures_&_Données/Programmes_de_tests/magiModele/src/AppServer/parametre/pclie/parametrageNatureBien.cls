/*------------------------------------------------------------------------
File        : parametrageNatureBien.cls
Description : Parametrage client : Nature de Bien
Author(s)   : kantena  -  2017/09/29
Notes       : pclntbie.p
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametrageNatureBien inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/

    constructor public parametrageNatureBien():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("NTBIE").
    end constructor.

end class.
