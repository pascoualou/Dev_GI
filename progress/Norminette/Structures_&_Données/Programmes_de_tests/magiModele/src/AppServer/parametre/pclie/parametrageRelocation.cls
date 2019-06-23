/*------------------------------------------------------------------------
File        : parametrageRelocation.cls
Description :
Author(s)   : kantena  -  2017/09/29
Notes       : pclreloc.p
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametrageRelocation inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/

    constructor public parametrageRelocation():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: zon10: sauvegarde des rubriques de quittancement
               zon02: 
               zon03: modèles word 'hab|..@com|..@com|..'
               zon04: modèles word 'hab|..@com|..'
               zon05: modèles word 'dlg|..'
               zon06: modèles word '00069|...@00022|..'
               zon07:
               zon10: modèles word 'aa|bb@cc|dd......'
        ------------------------------------------------------------------------------*/
        super("RELOC").
    end constructor.

    method public logical isActif():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return zon01 = "00001".  // oui
    end method.

end class.
