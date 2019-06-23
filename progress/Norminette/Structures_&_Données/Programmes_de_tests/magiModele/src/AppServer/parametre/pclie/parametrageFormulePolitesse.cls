  /*------------------------------------------------------------------------
    File        : parametrageFormulePolitesse
    Purpose     : 
    Description : 
    Author(s)   : kantena
    Created     : Thu Jan 18 11:05:00 CET 2018
    Notes       : 
  ----------------------------------------------------------------------*/

using parametre.pclie.pclie.

block-level on error undo, throw.

class parametre.pclie.parametrageFormulePolitesse inherits pclie: 

    constructor public parametrageFormulePolitesse():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("FOPOL").

    end constructor.

    constructor public parametrageFormulePolitesse(pcZon01 as character, pcZon02 as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("FOPOL", pcZon01, pcZon02).

    end constructor.

    constructor public parametrageFormulePolitesse(pcZon01 as character, pcZon02 as character, pcZon03 as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("FOPOL", pcZon01, pcZon02, pcZon03).

    end constructor.

    method public character getFormule1():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return this-object:zon04.

    end method.
    
    method public character getFormule2():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return this-object:zon05.

    end method.
    
end class.