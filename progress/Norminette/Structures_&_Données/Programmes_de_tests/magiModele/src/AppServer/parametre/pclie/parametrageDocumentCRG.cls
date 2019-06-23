/*------------------------------------------------------------------------
File        : parametrageDocumentCRG.cls
Description :
Author(s)   : kantena  -  2017/09/29
Notes       :
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametrageDocumentCRG inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/

    constructor public parametrageDocumentCRG():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("CLCRG").
    end constructor.

    method public character getCodeClassement():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return if this-object:zon01 > "" then this-object:zon01 else "00002". 
    end method.
    method public logical isEditerDGSiResultantEgal0():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return entry(1, this-object:zon02, "|") = "00001". 
    end method.
    method public logical isEditerCoordonnesGestionnaire():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        if num-entries(this-object:zon02, "|") >= 2 
        then return entry(2, this-object:zon02, "|") = "00001".
        return false.
    end method.
    method public logical isReleveRecapitulatifFinAnnee():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        if num-entries(this-object:zon02, "|") >= 3 
        then return entry(3, this-object:zon02, "|") = "00001".
        return false.
    end method.
    method public character getTriDetailSituationProp():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        if num-entries(this-object:zon02, "|") >= 4 
        then return entry(4, this-object:zon02, "|").
        return "".
    end method.
    method public character getRegroupementEncaissement():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        if num-entries(this-object:zon02, "|") >= 5 
        then return entry(5, this-object:zon02, "|").
        return "".
    end method.
    method public logical isEditerSituationLocataire():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        if num-entries(this-object:zon02, "|") >= 6 
        then return entry(6, this-object:zon02, "|") = "00001".
        return false.
    end method.
    method public character getCodeScenarioPresentation():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return this-object:zon03.
    end method.
    method public character getListeDocument():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return this-object:zon04.
    end method.
    method public character getDocument(piItem as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return if num-entries(this-object:zon04) >= piItem then entry(piItem, this-object:zon04) else "".
    end method.
    method public character getCodeEditionFacture():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return this-object:zon05.
    end method.
    method public character getEdSitCompteProprietaire():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return if this-object:zon06 > "" then this-object:zon06 else "L+N".
    end method.
    method public character getPeriodeTitreDocument():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return if this-object:zon07 > "" then this-object:zon07 else "Dates".
    end method.
    method public logical isRecapRubriqueVentilEncais():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return entry(1, this-object:zon08, "¤") = "00001".
    end method.
    method public logical isTotMandatVentilEncais():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        if num-entries(this-object:zon08, "¤") >= 2
        then return entry(2, this-object:zon08, "¤") <> "00002".
        return true.
    end method.
    method public logical isTotMandantVentilEncais():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        if num-entries(this-object:zon08, "¤") >= 3
        then return entry(3, this-object:zon08, "¤") <> "00002".
        return true.
    end method.
    method public logical isEdTvaEncais():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        if num-entries(this-object:zon08, "¤") >= 4
        then return entry(4, this-object:zon08, "¤") <> "00002".
        return true.
    end method.
    method public logical isEdTvaDepenseSurCrgSimplifie():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        if num-entries(this-object:zon08, "¤") >= 5
        then return entry(5, this-object:zon08, "¤") <> "00002".
        return true.
    end method.
    method public logical isTotSousTitreSurCrg():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        if num-entries(this-object:zon08, "¤") >= 6
        then return entry(6, this-object:zon08, "¤") <> "00002".
        return true.
    end method.
    method public logical isEdSoldePropPartiSurPgIndex():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        if num-entries(this-object:zon08, "¤") >= 7
        then return entry(7, this-object:zon08, "¤") <> "00002".
        return false.
    end method.
    method public logical isEdVentilParMandat():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        if num-entries(this-object:zon08, "¤") >= 8
        then return entry(8, this-object:zon08, "¤") <> "00002".
        return false.
    end method.

end class.
