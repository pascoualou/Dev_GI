/*------------------------------------------------------------------------
File        : parametrageBudgetLocatif.cls
Description :
Author(s)   : kantena  -  2017/09/29
Notes       : 
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametrageBudgetLocatif inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/

    constructor public parametrageBudgetLocatif():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("BUDLO", "00001").
    end constructor.
    constructor public parametrageBudgetLocatif(pcModeleBudget as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super().
        super:reloadDynamique(substitute('where tppar="&1" and zon07="&2"', "BUDLO", pcModeleBudget)).
    end constructor.

    method public logical isBudgetLocatifActif():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return this-object:zon01 = "00001" and this-object:zon07 = "000".
    end method.
    method override public void create():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: zon03: Extra-comptable, zon05: Prorata TVA, zon02: Reprise solde
        ------------------------------------------------------------------------------*/
        assign
            this-object:tppar = "BUDLO"
            this-object:zon01 = if this-object:zon01 > "" then this-object:zon01 else "00001"
            this-object:zon04 = if this-object:zon04 > "" then this-object:zon04 else "100-537,190-704,130-357"  // rubriques analytiques a exclure 
            this-object:zon06 = if this-object:zon06 > "" then this-object:zon06 else ""                         // rubriques Quittancement a exclure 
            this-object:zon07 = if this-object:zon07 > "" then this-object:zon07 else "000"                      // Numero Modele budget
            this-object:fgact = if this-object:fgact > "" then this-object:fgact else "yes"
        .
        super:create().
    end method.
    
    method override public void reload(pcModeleBudget as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super:reloadDynamique(substitute('where tppar="&1" and zon07="&2"', "BUDLO", pcModeleBudget)).
    end method.

end class.
