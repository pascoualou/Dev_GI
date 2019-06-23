/*------------------------------------------------------------------------
File        : parametragePeriodiciteQuittancement.cls
Description : Périodicité du traitement du quittancement
Author(s)   : kantena  -  2017/09/29
Notes       : pclqtper.p, iniqtper.p
    
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametragePeriodiciteQuittancement inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/

    constructor public parametragePeriodiciteQuittancement():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("QTPER").
    end constructor.

    method public logical isAvance():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return int02 = 1.
    end method.
    method public integer getNombreMoisQuittance():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  : valeur par défaut : 1
        ------------------------------------------------------------------------------*/
        if this-object:isDbParameter
        then return if this-object:zon01 = "00003" then 3 else 1.      
        return 1.                                                      
    end method.    
    method public integer periodiciteQuittancement():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        integer(zon01) no-error.
        if error-status:error then do:
            error-status:error = false no-error.
            return 0.
        end.
        return integer(zon01).
    end method.

   method public character geCodeEditCab():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
       return if int03 > 0 then string(int03, "99999") else "".
       
   end method.
   
end class.
