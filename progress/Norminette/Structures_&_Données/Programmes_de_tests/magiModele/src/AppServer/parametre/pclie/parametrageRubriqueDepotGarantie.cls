/*------------------------------------------------------------------------
File        : parametrageRubriqueDepotGarantie.cls
Description :
Author(s)   : kantena  -  2017/09/29
Notes       :
------------------------------------------------------------------------*/

class parametre.pclie.parametrageRubriqueDepotGarantie inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/
    constructor public parametrageRubriqueDepotGarantie():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("RUBDG").
    end constructor.
    method public character getListeRubrique():
        /*------------------------------------------------------------------------------
        Purpose: attention, liste des rubriques séparées par ";"
        Notes:
        ------------------------------------------------------------------------------*/
        return this-object:zon01.
    end method.

end class.
