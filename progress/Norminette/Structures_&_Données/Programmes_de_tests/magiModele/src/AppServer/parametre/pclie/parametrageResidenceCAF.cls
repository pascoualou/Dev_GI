/*------------------------------------------------------------------------
File        : parametreResidenceCAF.cls
Description : 
Author(s)   : kantena - 2018/05/31
Notes       :
derniere revue: 2018/06/06 - phm: OK 
------------------------------------------------------------------------*/
block-level on error undo, throw.

class parametre.pclie.parametrageResidenceCAF inherits parametre.pclie.pclie:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    constructor public parametrageResidenceCAF():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("CDCAF").
    end constructor.

    constructor public parametrageResidenceCAF(pcZon01 as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("CDCAF", pcZon01).
    end constructor.

end class.
