/*------------------------------------------------------------------------
File        : parametrageTypeImmeuble.cls
Description :
Author(s)   : kantena  -  2017/09/29
Notes       : pcltpimm_srv.p
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametrageISF inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/

    constructor public parametrageISF():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("ISF00").
    end constructor.
    
    
    method public logical getCalculSituFi():
        return (zon05 = "00001").
    end method.    

end class.
