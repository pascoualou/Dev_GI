/*------------------------------------------------------------------------
File        : parametrageMotifIndisponibilite.cls
Description :
Author(s)   : kantena  -  2017/09/29
Notes       :
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametrageMotifIndisponibilite inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/

    constructor public parametrageMotifIndisponibilite():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("SLO00").
    end constructor.
    constructor public parametrageMotifIndisponibilite(pcZon01 as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("SLO00", pcZon01).
    end constructor.
    method public void reload():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        reload("SLO00").
    end method.
    method override public void reload(pczon01 as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: 
        ------------------------------------------------------------------------------*/
        reload("SLO00", pczon01).
    end method.
    method public character getLibelleMotif():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: 
        ------------------------------------------------------------------------------*/
        return zon02.
    end method.

end class.
