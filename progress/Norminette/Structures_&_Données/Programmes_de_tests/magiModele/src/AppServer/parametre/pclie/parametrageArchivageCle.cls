 
 /*------------------------------------------------------------------------
File        : parametrageArchivageCle.cls
Description : 
Author(s)   : RF  -  2018/01/16
Notes       : 
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametrageArchivageCle inherits parametre.pclie.pclie:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    constructor public parametrageArchivageCle():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: 
        ------------------------------------------------------------------------------*/
        super("HISCG").
    end constructor.
   
    method public logical isArchivageActif():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return zon02 = "00001".
    end method.
    

end class.