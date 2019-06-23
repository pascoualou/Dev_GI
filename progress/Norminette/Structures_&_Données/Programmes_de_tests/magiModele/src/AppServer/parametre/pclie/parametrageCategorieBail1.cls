/*------------------------------------------------------------------------
File        : parametrageCategorieBail1.cls
Description : Mise a jour des paramètres categorie de Bail 1
Author(s)   : kantena  -  2018/01/02
Notes       : Attention, il y a aussi "PFBAI" avec un i pas un 1 (comme un) pas L  !!!!!!!!!!!!!
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametrageCategorieBail1 inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/

    constructor public parametrageCategorieBail1():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("PFBA1").  // 1 (comme un) pas i ni L
    end constructor.
    constructor public parametrageCategorieBail1(pcZon01 as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("PFBA1", pcZon01).  // 1 (comme un) pas i ni L
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
