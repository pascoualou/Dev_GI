/*------------------------------------------------------------------------
File        : parametrageGestionCommerciaux.cls
Description :
Author(s)   : kantena  -  2017/09/29
Notes       : pclgesco.p
------------------------------------------------------------------------*/

class parametre.pclie.parametrageGestionCommerciaux inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/
    constructor public parametrageGestionCommerciaux():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("GESCO").
    end constructor.
    method public logical isActif():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: agence/service
        ------------------------------------------------------------------------------*/
        return isDbparameter and zon01 <> "00002".
    end method.

end class.
