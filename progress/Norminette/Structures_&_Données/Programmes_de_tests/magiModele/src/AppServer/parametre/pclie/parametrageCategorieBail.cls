/*------------------------------------------------------------------------
File        : parametrageCategorieBail.cls
Description : Mise a jour des paramètres categorie de Bail
Author(s)   : kantena  -  2018/01/02
Notes       : Attention, il y a aussi "PFBA1" avec un 1 pas un i !!!!!!!!!!!!!
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametrageCategorieBail inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/

    constructor public parametrageCategorieBail():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("PFBAI").
    end constructor.
    constructor public parametrageCategorieBail(pcZon01 as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("PFBAI", pcZon01).
    end constructor.

    method public logical isActif():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return this-object:zon01 = "00001".  // oui
    end method.
    method public character getCategorie():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return this-object:zon02.
    end method.

end class.
