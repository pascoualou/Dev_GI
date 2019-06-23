/*------------------------------------------------------------------------
File        : parametragePrelevementAutomatique.cls
Description :
Author(s)   : kantena  -  2017/09/29
Notes       :
------------------------------------------------------------------------*/

class parametre.pclie.parametragePrelevementAutomatique inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/
    constructor public parametragePrelevementAutomatique():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("PRLAU").
    end constructor.
    method public logical isPrelevementAutomatique():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: agence/service
        ------------------------------------------------------------------------------*/
        return (this-object:zon01 = "00001").
    end method.
    method public logical isPrelevementMensuel():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: agence/service
        ------------------------------------------------------------------------------*/
        return (this-object:zon06 = "00001").
    end method.
    method public integer getNombreJoursPrelevement():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: agence/service
        ------------------------------------------------------------------------------*/
        return integer(trim(this-object:zon02)).
    end method.
    method public character getCodeMoisPrelevement():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: agence/service
        ------------------------------------------------------------------------------*/
        return string(integer(this-object:zon05), "99999").
    end method.
 
end class.
