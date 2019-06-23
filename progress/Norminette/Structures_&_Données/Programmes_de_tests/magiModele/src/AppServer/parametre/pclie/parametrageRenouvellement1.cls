/*------------------------------------------------------------------------
File        : parametrageRenouvellement1.cls
Description : Mise a jour des paramètres categorie de Bail 1
Author(s)   : kantena  -  2018/01/02
Notes       : Attention, il y a aussi "RENOU" avec un U !!!!!!!!!!!!!
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametrageRenouvellement1 inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/

    constructor public parametrageRenouvellement1():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("RENO1").  // 1 (comme un) pas i ni L
    end constructor.
    constructor public parametrageRenouvellement1(pcZon01 as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("RENO1", pcZon01).  // 1 (comme un) pas i ni L
    end constructor.

    method public character getTypeRevision():
        return this-object:zon02.
    end method.
end class.
