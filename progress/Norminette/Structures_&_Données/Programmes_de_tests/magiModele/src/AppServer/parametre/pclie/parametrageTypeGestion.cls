/*------------------------------------------------------------------------
File        : parametrageTypeGestion.cls
Description :
Author(s)   : kantena  -  2017/09/29
Notes       : pcleuges.p
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametrageTypeGestion inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/
    {application/include/combo.i}

    constructor public parametrageTypeGestion():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("EUGES").
    end constructor.

    method public override integer getComboParametre(pcNomCombo as character, output table ttCombo):
        /*------------------------------------------------------------------------------
        Purpose: attention, utilisation zon02 et zon03 (au lieu de zon01 et zon02
        Notes  :
        ------------------------------------------------------------------------------*/
        return getComboParametre(pcNomCombo, 'and pclie.zon04 = "actif" and integer(pclie.zon01) >= 0 by pclie.int01', 'zon02', 'zon03', output table ttCombo by-reference).
    end method.
end class.
