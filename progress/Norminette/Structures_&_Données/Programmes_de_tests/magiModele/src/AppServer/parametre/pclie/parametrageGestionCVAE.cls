/*------------------------------------------------------------------------
File        : parametrageGestionCVAE.cls
Description :
Author(s)   : kantena  -  2017/09/29
Notes       : pclgcvae.p
------------------------------------------------------------------------*/

class parametre.pclie.parametrageGestionCVAE inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/
    constructor public parametrageGestionCVAE():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("GCVAE").
    end constructor.
    method public logical isActif():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: agence/service
        ------------------------------------------------------------------------------*/
        return isDbparameter and zon01 <> "00002".
    end method.

end class.
