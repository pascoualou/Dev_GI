/*------------------------------------------------------------------------
File        : parametrageRenouvellement.cls
Description : Mise a jour des paramètres renouvellement
Author(s)   : kantena  -  2018/01/02
Notes       : Attention, il y a aussi "RENO1" avec un 1 (comme un) pas i ni L  !!!!!!!!!!!!!
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametrageRenouvellement inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/

    constructor public parametrageRenouvellement():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("RENOU").  // 1 (comme un) pas i ni L
    end constructor.
    constructor public parametrageRenouvellement(pcZon01 as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("RENOU", pcZon01).  // 1 (comme un) pas i ni L
    end constructor.

    method public character getTypeRevision():
        return this-object:zon02.
    end method.
end class.
