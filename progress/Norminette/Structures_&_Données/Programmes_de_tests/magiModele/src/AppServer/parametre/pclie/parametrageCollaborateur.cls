/*------------------------------------------------------------------------
File        : parametrageCollaborateur.cls
Description : Parametrage des taches des collaborateurs d'agence
Author(s)   : kantena  -  2017/09/29
Notes       : pclprcol.p
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametrageCollaborateur inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/

    constructor public parametrageCollaborateur():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("PRCOL").
    end constructor.
    constructor public parametrageCollaborateur(pcZon01 as character, pcZon02 as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: pcZon01=pcTypeContrat, pcZon02=pcNatureContrat, pcZon03=pcTypeRole
        ------------------------------------------------------------------------------*/
        super("PRCOL", pcZon01, pcZon02).
    end constructor.
    method override public void reload(pcZon01 as character, pcZon02 as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: 
        ------------------------------------------------------------------------------*/
        reload("PRCOL", pcZon01, pcZon02).
    end method.
    method public logical isActif():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: 
        ------------------------------------------------------------------------------*/
        return zon03 = "TRUE".
    end method.

end class.
