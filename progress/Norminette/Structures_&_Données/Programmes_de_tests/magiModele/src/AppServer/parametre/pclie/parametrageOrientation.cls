/*------------------------------------------------------------------------
File        : parametrageOrientation.cls
Description : Gestion des parametres Orientation
Author(s)   : kantena  -  2017/09/29
Notes       : pclorien.p
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametrageOrientation inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/

    constructor public parametrageOrientation():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("ORIEN").
    end constructor.

end class.
