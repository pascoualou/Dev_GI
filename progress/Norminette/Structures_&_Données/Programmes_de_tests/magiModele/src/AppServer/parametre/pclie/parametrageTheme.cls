/*------------------------------------------------------------------------
File        : parametrageTheme.cls
Description : Saisie/modification des thèmes de classement pour les évènements
Author(s)   : kantena  -  2017/09/29
Notes       : pcltheme.p
              Attention, L'appel aux getCombo... doit se faire sans l'option "by-reference"
              
DM 2017/12/15 revue ged-versement20171206.00              
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametrageTheme inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/
    {application/include/combo.i}

    constructor public parametrageTheme():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("THEME").
    end constructor.

    constructor public parametrageTheme(pcCodeTheme as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("THEME", pcCodeTheme).
    end constructor.
    

    method public integer getComboParametreThemeTravaux(pcNomCombo as character, output table ttCombo):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
        return getComboParametre(pcNomCombo, 'and pclie.zon03 = "yes"', 'zon01', 'zon02', output table ttCombo by-reference).
    end method.

    method public integer getComboParametreThemeGED(pcNomCombo as character, output table ttCombo):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
        return getComboParametre(pcNomCombo, 'and pclie.zon05 = "O"', 'zon01', 'zon02', output table ttCombo by-reference).
    end method.

    method public integer getComboParametreThemeGIExtranet(pcNomCombo as character, output table ttCombo):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
        return getComboParametre(pcNomCombo, 'and (pclie.zon04 = "TRUE" or pclie.zon04 = "YES")', 'zon01', 'zon02', output table ttCombo by-reference).
    end method.
end class.
