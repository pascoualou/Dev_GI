/*------------------------------------------------------------------------
File        : parametrageRubriqueExtournable.cls
Description :
Author(s)   : gga  -  2018/08/02
Notes       : 
------------------------------------------------------------------------*/

class parametre.pclie.parametrageRubriqueExtournable inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/
    constructor public parametrageRubriqueExtournable():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("RBEXT").
    end constructor.
    
    method public logical isRubriqueExtournable(piNumeroRubrique as integer):
        /*------------------------------------------------------------------------------
        Purpose: Ancienne Rubrique interdite
        Notes:
        ------------------------------------------------------------------------------*/
        define buffer pclie for pclie.
        for first pclie no-lock
            where pclie.tppar = this-object:tppar 
              and pclie.zon01 = string(piNumeroRubrique, "999"):
            return true.
        end.
        return false.
    end method.
    
end class.
