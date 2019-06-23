/*------------------------------------------------------------------------
File        : parametrageImmobilierEntreprise.cls
Description : Gestion Immobilier d'Entreprise
Author(s)   : kantena  -  2017/09/29
Notes       : pclgesie.p
------------------------------------------------------------------------*/

class parametre.pclie.parametrageImmobilierEntreprise inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/
    constructor public parametrageImmobilierEntreprise():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("GESIE").
    end constructor.
    method public logical isActif():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: agence/service
        ------------------------------------------------------------------------------*/
        return isDbparameter and zon01 <> "00002".
    end method.
    method public logical isOkEcran():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: agence/service
        ------------------------------------------------------------------------------*/
        return isDbparameter and zon01 = "00001" and zon02 = "00001".
    end method.

end class.
