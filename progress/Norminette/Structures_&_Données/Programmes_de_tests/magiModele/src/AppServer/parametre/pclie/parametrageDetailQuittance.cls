/*------------------------------------------------------------------------
File        : parametrageDetailQuittance.cls
Description :
Author(s)   : kantena  -  2018/01/05
Notes       :
------------------------------------------------------------------------*/
block-level on error undo, throw.

class parametre.pclie.parametrageDetailQuittance inherits parametre.pclie.pclie:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/

    constructor public parametrageDetailQuittance():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("DAQUI").
    end constructor.

    method public logical isEuroActif():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return this-object:zon01 = "00001".
    end method.

end class.
