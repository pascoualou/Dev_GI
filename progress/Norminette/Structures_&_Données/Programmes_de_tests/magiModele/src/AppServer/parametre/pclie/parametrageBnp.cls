/*------------------------------------------------------------------------
File        : parametrageBnp.cls
Description : Mise a jour des paramètres BNP
Author(s)   : GGA  -  2018/11/23
Notes       : 
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametrageBnp inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/

    constructor public parametrageBnp():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("BNP_MDM").
    end constructor.

    method public character getUrl():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: 
        ------------------------------------------------------------------------------*/
        return zon02.
    end method.
    
end class.
