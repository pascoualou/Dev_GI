 
 /*------------------------------------------------------------------------
    File        : parametrageThemeCourrier
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : kantena
    Created     : Tue Oct 24 17:33:49 CEST 2017
    Notes       : 
  ----------------------------------------------------------------------*/
block-level on error undo, throw.

class parametre.pclie.parametrageThemeCourrier inherits parametre.pclie.pclie:

    constructor public parametrageThemeCourrier(pcTypeCorrepondance as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("THEME-COURRIER", pcTypeCorrepondance).

    end constructor.
    
    method public character getTheme ():
        return zon02.
    end method.
    
end class.