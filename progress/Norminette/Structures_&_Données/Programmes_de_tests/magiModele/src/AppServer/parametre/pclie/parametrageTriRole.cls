/*------------------------------------------------------------------------
File        : parametrageTriRole.cls
Description : ordre d'affichage des types de rôles
Author(s)   : kantena  -  2017/09/29
Notes       :
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametrageTriRole inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/

    constructor public parametrageTriRole():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("TRROL").
    end constructor.
    method public void reload():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        reload("TRROL").
    end method.
    method override public void reload(pczon01 as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: 
        ------------------------------------------------------------------------------*/
        reload("TRROL", pczon01).
    end method.
    method override public void reload(pczon01 as character, pcZon02 as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        reload("TRROL", pczon01, pcZon02).
    end method.
    method public integer getNumeroOrdre():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return integer(int01).
    end method.

end class.
