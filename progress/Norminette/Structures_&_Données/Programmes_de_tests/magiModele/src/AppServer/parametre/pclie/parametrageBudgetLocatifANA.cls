/*------------------------------------------------------------------------
File        : parametrageBudgetLocatifANA.cls
Description :
Author(s)   : kantena  -  2017/09/29
Notes       : 
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametrageBudgetLocatifANA inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/
    define public property gcListeRubriquesTVA     as character no-undo get. set.
    define public property gcListeSousRubriquesTVA as character no-undo get. set.

    constructor public parametrageBudgetLocatifANA():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: On récupère la liste des rubriques dans zon02 et zon03
        ------------------------------------------------------------------------------*/
        super("BUDL1", "ANA").
        for each pclie no-lock
            where pclie.tppar = "BUDL1"
              and pclie.zon01 = "ANA"
              and pclie.zon07 = zon07:
            assign
                gcListeRubriquesTVA     = substitute("&1,&2", gcListeRubriquesTVA, pclie.zon02)
                gcListeSousRubriquesTVA = substitute("&1,&2", gcListeSousRubriquesTVA, pclie.zon03)
            .
        end.
        assign
            gcListeRubriquesTVA     = trim(gcListeRubriquesTVA, ',')
            gcListeSousRubriquesTVA = trim(gcListeSousRubriquesTVA, ',')
        .
    end constructor.
    constructor public parametrageBudgetLocatifANA(pcModeleBudget as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("BUDL1", substitute('where zon01 = "ANA" and zon07="&1"', pcModeleBudget)).
        for each pclie no-lock
            where pclie.tppar = "BUDL1"
              and pclie.zon01 = "ANA"
              and pclie.zon07 = pcModeleBudget:
            assign
                gcListeRubriquesTVA     = substitute("&1,&2", gcListeRubriquesTVA, pclie.zon02)
                gcListeSousRubriquesTVA = substitute("&1,&2", gcListeSousRubriquesTVA, pclie.zon03)
            .
        end.
        assign
            gcListeRubriquesTVA     = trim(gcListeRubriquesTVA, ',')
            gcListeSousRubriquesTVA = trim(gcListeSousRubriquesTVA, ',')
        .
    end constructor.

    method override public void create():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: zon03: Extra-comptable, zon05: Prorata TVA, zon02: Reprise solde
        ------------------------------------------------------------------------------*/
        assign
            tppar = "BUDL1"
            zon01 = "RUB"
        .
        super:create().
    end method.

end class.
