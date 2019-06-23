/*------------------------------------------------------------------------
File        : parametrageRubriquesCalculees.cls
Description :
Author(s)   : kantena  -  2017/09/29
Notes       :
------------------------------------------------------------------------*/

class parametre.pclie.parametrageRubriquesCalculees inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/
    constructor public parametrageRubriquesCalculees():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("RUBCL").
    end constructor.
    method public logical isActif():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: agence/service
        ------------------------------------------------------------------------------*/
        return isDbparameter and zon01 <> "00002".
    end method.

end class.
