/*------------------------------------------------------------------------
File        : parametreNatureLot
Purpose     : 
Author(s)   : devweb1  -  2017/11/08
Notes       : 
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.syspr.parametrageNatureLot inherits parametre.syspr.syspr:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/

    constructor public parametrageNatureLot(pcCodeParam as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("NTLOT", pcCodeParam).
    end constructor.

    method public integer getNbPieceMinimum():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return integer(entry(1, this-object:zone2, "@")).
    end method.

    method public integer getNbPieceMaximum():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        if num-entries(this-object:zone2, "@")>= 2
        then return integer(entry(2, this-object:zone2, "@")).
        return 0.
    end method.

    method public logical isDivisible():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return (num-entries(this-object:zone2, "@")>= 4 and entry(4, this-object:zone2, "@") = "D").
    end method.

end class.