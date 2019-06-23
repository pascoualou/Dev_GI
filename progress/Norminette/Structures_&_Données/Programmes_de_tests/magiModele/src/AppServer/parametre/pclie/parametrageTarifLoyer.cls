/*------------------------------------------------------------------------
File        : parametrageTarifLoyer.cls
Description : 
Author(s)   : kantena  -  2017/12/16
Notes       : genoffqt.p
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametrageTarifLoyer inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/

    constructor public parametrageTarifLoyer():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("TFLOY").
    end constructor.

    method public logical isActif():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return this-object:isDbParameter and this-object:zon01 = "00001".
    end method.
end class.
