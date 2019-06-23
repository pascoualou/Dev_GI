/*------------------------------------------------------------------------
File        : parametrageHonoraireLocataire.cls
Description :
Author(s)   : kantena  -  2017/09/29
Notes       : pclholoc.p
------------------------------------------------------------------------*/

class parametre.pclie.parametrageHonoraireLocataire inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/
    constructor public parametrageHonoraireLocataire():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("HOLOC").
    end constructor.
    method public logical isActif():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: agence/service
        ------------------------------------------------------------------------------*/
        return zon01 = "00001".
    end method.

end class.
