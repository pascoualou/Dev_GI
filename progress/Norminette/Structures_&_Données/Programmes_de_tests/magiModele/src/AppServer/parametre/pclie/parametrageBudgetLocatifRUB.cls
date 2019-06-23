/*------------------------------------------------------------------------
File        : parametrageBudgetLocatifRUB.cls
Description :
Author(s)   : kantena  -  2017/09/29
Notes       : 
derniere revue: 2018/04/23 - phm: KO
          La méthode duplicationModele n'est pas utilisée.
------------------------------------------------------------------------*/
using oerealm.magiToken.
block-level on error undo, throw.

class parametre.pclie.parametrageBudgetLocatifRUB inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/
    {adblib/include/pclie.i}
    define public property gcListeRubriquesTVA as character no-undo get. set.

    constructor public parametrageBudgetLocatifRUB():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: On récupère la liste des rubriques dans zon02.
        ------------------------------------------------------------------------------*/
        super("BUDL1", "RUB").
        for each pclie no-lock
            where pclie.tppar = "BUDL1"
              and pclie.zon01 = "RUB"
              and pclie.zon07 = this-object:zon07:
              gcListeRubriquesTVA = gcListeRubriquesTVA + ',' + pclie.zon02.   
        end.
        gcListeRubriquesTVA = trim(gcListeRubriquesTVA, ',').
    end constructor.

    constructor public parametrageBudgetLocatifRUB(pcModeleBudget as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("BUDL1", substitute('where zon01 = "RUB" and zon07="&1"', pcModeleBudget)).
        for each pclie no-lock
            where pclie.tppar = "BUDL1"
              and pclie.zon01 = "RUB"
              and pclie.zon07 = pcModeleBudget:
              gcListeRubriquesTVA = gcListeRubriquesTVA + ',' + pclie.zon02.   
        end.
        gcListeRubriquesTVA = trim(gcListeRubriquesTVA, ',').
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
