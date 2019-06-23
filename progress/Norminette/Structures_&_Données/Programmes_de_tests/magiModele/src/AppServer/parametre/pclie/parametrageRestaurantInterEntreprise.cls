/*------------------------------------------------------------------------
File        : parametrageRestaurantInterEntreprise.cls
Description : Gestion restaurant inter entreprise
Author(s)   : GGA - 2019/01/04
Notes       : 
------------------------------------------------------------------------*/

class parametre.pclie.parametrageRestaurantInterEntreprise inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/
    constructor public parametrageRestaurantInterEntreprise():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("GERIE").
    end constructor.
    method public logical isActif():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: 
        ------------------------------------------------------------------------------*/
        return isDbparameter and zon01 = "00001".
    end method.

end class.
