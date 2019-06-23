/*------------------------------------------------------------------------
File        : parametrageDefautMandat.cls
Description :
Author(s)   : kantena  -  2017/09/29
Notes       : pcldefma.p
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametrageDefautMandat inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/
    define variable separ as character format "X" extent 5 no-undo.
    
    constructor public parametrageDefautMandat():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("DEFMA").
        {application/include/glbsepar2.i}
    end constructor.
    constructor public parametrageDefautMandat(pcZon01 as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("DEFMA", pcZon01).
        {application/include/glbsepar2.i}
    end constructor.

    method private character fillPrepare(pcZone as character, piNumEntries as integer, pcSeparateur as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        if pcZone = ? or pcZone = "" then return fill(pcSeparateur, piNumEntries).
        return pcZone + fill(pcSeparateur, piNumEntries - num-entries(pcZone, pcSeparateur)).
    end method.

    method public integer getGenerauxDuree():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable viDuree as integer no-undo.
        viDuree = integer(entry(3, this-object:zon01, separ[1])) no-error.
        error-status:error = false no-error.
        return viDuree.
    end method.
    method public void setGenerauxDuree(piDuree as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon01, 8, separ[1]).
        entry(3, this-object:zon01, separ[1]) = string(piDuree) no-error.
    end method.
    method public character getGenerauxUniteDuree():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcUnite as character no-undo.
        vcUnite = entry(3, entry(4, this-object:zon01, separ[1]), separ[2]) no-error.
        error-status:error = false no-error.
        return vcUnite.
    end method.
    method public void setGenerauxUniteDuree(pcUniteDuree as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon01, 8, separ[1]).
        entry(4, this-object:zon01, separ[1]) = string(pcUniteDuree) no-error.
    end method.
    method public integer getGenerauxDelaiResiliation():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable viDelai as integer no-undo.
        viDelai = integer(entry(5, this-object:zon01, separ[1])) no-error.
        error-status:error = false no-error.
        return viDelai.
    end method.
    method public void setGenerauxDelaiResiliation(piDelai as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon01, 8, separ[1]).
        entry(5, this-object:zon01, separ[1]) = string(piDelai) no-error.
    end method.
    method public character getGenerauxUniteDelaiResiliation():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcUnite as character no-undo.
        vcUnite = entry(3, entry(6, this-object:zon01, separ[1]), separ[2]) no-error.
        error-status:error = false no-error.
        return vcUnite.
    end method.
    method public void setGenerauxUniteDelaiResiliation(pcUnite as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon01, 8, separ[1]).
        entry(6, this-object:zon01, separ[1]) = pcUnite no-error.
    end method.
    method public character getGenerauxCodeRepartitionTerme():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcCode as character no-undo.
        vcCode = entry(3, entry(7, this-object:zon01, separ[1]), separ[2]) no-error.
        error-status:error = false no-error.
        return vcCode.
    end method.
    method public void setGenerauxCodeRepartitionTerme(pcCode as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon01, 8, separ[1]).
        entry(7, this-object:zon01, separ[1]) = pcCode no-error.
    end method.
    method public logical getGenerauxFicheFinPec():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcFiche as character no-undo.
        vcFiche = entry(3, entry(8, this-object:zon01, separ[1]), separ[2]) no-error.
        error-status:error = false no-error.
        return vcFiche = "00001".
    end method.
    method public void setGenerauxFicheFinPec(pcFiche as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon01, 8, separ[1]).
        entry(8, this-object:zon01, separ[1]) = pcFiche no-error.
    end method.
    method public logical getGenerauxModifAuto():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcModif as character no-undo.
        vcModif = entry(3, entry(9, this-object:zon01, separ[1]), separ[2]) no-error.
        error-status:error = false no-error.
        return vcModif = "00001".
    end method.
    method public void setGenerauxModifAuto(pcModif as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon01, 8, separ[1]).
        entry(9, this-object:zon01, separ[1]) = pcModif no-error.
    end method.

    method public character getDepotGarantieTypeTache():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: 
        ------------------------------------------------------------------------------*/
        define variable vcType as character no-undo.
        vcType = entry(1, entry(1, this-object:zon02, separ[3]), separ[1]) no-error.
        error-status:error = false no-error.
        return vcType.
    end method.
    method public void setDepotGarantieTypeTache(pcType as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon02, 3, separ[1]).
        entry(1, this-object:zon02, separ[1]) = pcType no-error.
    end method.
    method public logical getDepotGarantieParametrageActif():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcItem  as character no-undo.
        if this-object:isDbParameter = false then return false.

        vcItem = if num-entries(this-object:zon02, separ[3]) >= 2
                 then entry(2, this-object:zon02, separ[3]) 
                 else if num-entries(this-object:zon02, separ[1]) >= 2
                      then substitute("yes&1&2&1M", separ[2], entry(2, this-object:zon02, separ[1]))
                      else substitute("yes&1no&1M", separ[2]).
        return entry(1, vcItem, separ[2]) = "yes".
    end method.
    method public void setDepotGarantieParametrageActif(plActif as logical):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon02, 3, separ[1]).
        entry(2, this-object:zon02, separ[1]) = if plActif then "yes" else "no" no-error.
    end method.
    method public logical getDepotGarantieActivation():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcItem  as character no-undo.
        if this-object:isDbParameter = false then return false.

        vcItem = if num-entries(this-object:zon02, separ[3]) >= 2
                 then entry(2, this-object:zon02, separ[3]) 
                 else if num-entries(this-object:zon02, separ[1]) >= 2
                      then substitute("yes&1&2&1M", separ[2], entry(2, this-object:zon02, separ[1]))
                      else substitute("yes&1no&1M", separ[2]).
        return entry(2, vcItem, separ[2]) = "yes".
    end method.
    method public logical getDepotGarantieAutomatique():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcItem  as character no-undo.
        if this-object:isDbParameter = false then return false.

        vcItem = if num-entries(this-object:zon02, separ[3]) >= 2
                 then entry(2, this-object:zon02, separ[3]) 
                 else if num-entries(this-object:zon02, separ[1]) >= 2
                      then substitute("yes&1&2&1M", separ[2], entry(2, this-object:zon02, separ[1]))
                      else substitute("yes&1no&1M", separ[2]).
        return entry(3, vcItem, separ[2]) = "a".
    end method.
    method public character getTypeDepot():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vczon02  as character no-undo.

        if this-object:getDepotGarantieParametrageActif()
        then assign
            vczon02 = entry(3, entry(1, this-object:zon02, separ[3]), separ[1])
        no-error.
        if num-entries(vczon02, separ[2]) >= 3 then return entry(3, vczon02, separ[2]).
        return "".
    end method.
    method public character getDepotGarantieCode():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcCode as character no-undo.
        vcCode = entry(3, entry(3, entry(1, this-object:zon02, separ[3]), separ[1]), separ[2]) no-error.
        error-status:error = false no-error.
        return vcCode.
    end method.
    method public void setDepotGarantie3(pcParametre as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon02, 3, separ[1]).
        entry(3, this-object:zon02, separ[1]) = pcParametre no-error.
    end method.

    method public logical getIsHonoraireGestion():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: 
        ------------------------------------------------------------------------------*/
        define variable vlHonoraire as logical no-undo.
        vlHonoraire = num-entries(entry(1, this-object:zon03, separ[3]), separ[1]) >= 6 no-error.
        error-status:error = false no-error.
        return vlHonoraire.
    end method.
    method public character getHonoraireGestionTypeTache():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: 
        ------------------------------------------------------------------------------*/
        define variable vcType as character no-undo.
        vcType = entry(1, entry(1, this-object:zon03, separ[3]), separ[1]) no-error.
        error-status:error = false no-error.
        return vcType.
    end method.
    method public void setHonoraireGestionTypeTache(pcType as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon03, 6, separ[1]).
        entry(1, this-object:zon03, separ[1]) = pcType no-error.
    end method.
    method public logical getHonoraireGestionParametrageActif():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcItem  as character no-undo.
        vcItem = if num-entries(this-object:zon03, separ[3]) >= 2
                 then entry(2, this-object:zon03, separ[3]) 
                 else if num-entries(this-object:zon03, separ[1]) >= 2
                      then substitute("yes&1&2&1M", separ[2], entry(2, this-object:zon03, separ[1]))
                      else substitute("yes&1no&1M", separ[2]).
        return entry(1, vcItem, separ[2]) = "yes".
    end method.
    method public void setHonoraireGestionParametrageActif(plActif as logical):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon03, 6, separ[1]).
        entry(2, this-object:zon03, separ[1]) = if plActif then "yes" else "no" no-error.
    end method.
    method public logical getHonoraireGestionActivation():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcItem  as character no-undo.
        vcItem = if num-entries(this-object:zon03, separ[3]) >= 2
                 then entry(2, this-object:zon03, separ[3]) 
                 else if num-entries(this-object:zon03, separ[1]) >= 2
                      then substitute("yes&1&2&1M", separ[2], entry(2, this-object:zon03, separ[1]))
                      else substitute("yes&1no&1M", separ[2]).
        return entry(2, vcItem, separ[2]) = "yes".
    end method.
    method public logical getHonoraireGestionAutomatique():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcItem  as character no-undo.
        vcItem = if num-entries(this-object:zon03, separ[3]) >= 2
                 then entry(2, this-object:zon03, separ[3]) 
                 else if num-entries(this-object:zon03, separ[1]) >= 2
                      then substitute("yes&1&2&1M", separ[2], entry(2, this-object:zon03, separ[1]))
                      else substitute("yes&1no&1M", separ[2]).
        return entry(3, vcItem, separ[2]) = "a".
    end method.
    method public character getHonoraireGestionCodePeriode():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: 
        ------------------------------------------------------------------------------*/
        define variable vcCode as character no-undo.
        vcCode = entry(3, entry(3, entry(1, this-object:zon03, separ[3]), separ[1]), separ[2]) no-error.
        error-status:error = false no-error.
        return vcCode.
    end method.
    method public character getHonoraireGestionCodeHonoraire():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: 
        ------------------------------------------------------------------------------*/
        define variable vcCode as character no-undo.
        vcCode = entry(3, entry(5, entry(1, this-object:zon03, separ[3]),separ[1]) ,separ[2]) no-error.
        error-status:error = false no-error.
        return vcCode.
    end method.
    method public character getHonoraireGestionCodeFrais():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: 
        ------------------------------------------------------------------------------*/
        define variable vcCode as character no-undo.
        vcCode = entry(3, entry(6, entry(1, this-object:zon03, separ[3]), separ[1]), separ[2]) no-error.
        error-status:error = false no-error.
        return vcCode.
    end method.
    method public void setHonoraireGestion3(pcParametre as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon03, 6, separ[1]).
        entry(3, this-object:zon03, separ[1]) = pcParametre no-error.
    end method.
    method public void setHonoraireGestion4(pcParametre as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon03, 6, separ[1]).
        entry(4, this-object:zon03, separ[1]) = pcParametre no-error.
    end method.
    method public void setHonoraireGestion5(pcParametre as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon03, 6, separ[1]).
        entry(5, this-object:zon03, separ[1]) = pcParametre no-error.
    end method.
    method public void setHonoraireGestion6(pcParametre as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon03, 6, separ[1]).
        entry(6, this-object:zon03, separ[1]) = pcParametre no-error.
    end method.

    method public character getCRGTypeTache():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: 
        ------------------------------------------------------------------------------*/
        define variable vcType as character no-undo.
        vcType = entry(1, entry(1, this-object:zon04, separ[3]), separ[1]) no-error.
        error-status:error = false no-error.
        return vcType.
    end method.
    method public void setCRGTypeTache(pcType as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon04, 8, separ[1]).
        entry(1, this-object:zon04, separ[1]) = pcType no-error.
    end method.
    method public logical getCRGParametrageActif():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcItem  as character no-undo.
        vcItem = if num-entries(this-object:zon04, separ[3]) >= 2
                 then entry(2, this-object:zon04, separ[3]) 
                 else if num-entries(this-object:zon04, separ[1]) >= 2
                      then substitute("yes&1&2&1M", separ[2], entry(2, this-object:zon04, separ[1]))
                      else substitute("yes&1no&1M", separ[2]).
        return entry(1, vcItem, separ[2]) = "yes".
    end method.
    method public void setCRGParametrageActif(plActif as logical):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon04, 8, separ[1]).
        entry(2, this-object:zon04, separ[1]) = if plActif then "yes" else "no" no-error.
    end method.
    method public logical getCRGActivation():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcItem  as character no-undo.
        vcItem = if num-entries(this-object:zon04, separ[3]) >= 2
                 then entry(2, this-object:zon04, separ[3]) 
                 else if num-entries(this-object:zon04, separ[1]) >= 2
                      then substitute("yes&1&2&1M", separ[2], entry(2, this-object:zon04, separ[1]))
                      else substitute("yes&1no&1M", separ[2]).
        return entry(2, vcItem, separ[2]) = "yes".
    end method.
    method public logical getCRGAutomatique():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcItem  as character no-undo.
        vcItem = if num-entries(this-object:zon04, separ[3]) >= 2
                 then entry(2, this-object:zon04, separ[3]) 
                 else if num-entries(this-object:zon04, separ[1]) >= 2
                      then substitute("yes&1&2&1M", separ[2], entry(2, this-object:zon04, separ[1]))
                      else substitute("yes&1no&1M", separ[2]).
        return entry(3, vcItem, separ[2]) = "a".
    end method.
    method public character getCRGCodePresentation():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcCode as character no-undo.
        vcCode = entry(3, entry(3, entry(1, this-object:zon04, separ[3]), separ[1]), separ[2]) no-error.
        error-status:error = false no-error.
        return vcCode.
    end method.
    method public void setCRGCodePresentation(pcCode as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon04, 8, separ[1]).
        entry(3, this-object:zon04, separ[1]) = pcCode no-error.
    end method.
    method public character getCRGCodePeriodicite():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcCode as character no-undo.
        vcCode = entry(3, entry(4, entry(1, this-object:zon04, separ[3]), separ[1]), separ[2]) no-error.
        error-status:error = false no-error.
        return vcCode.
    end method.
    method public void setCRGCodePeriodicite(pcCode as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon04, 8, separ[1]).
        entry(4, this-object:zon04, separ[1]) = pcCode no-error.
    end method.
    method public character getCRGAvisEcheance():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcCode as character no-undo.
        vcCode = entry(3, entry(7, entry(1, this-object:zon04, separ[3]), separ[1]), separ[2]) no-error.
        error-status:error = false no-error.
        return vcCode.
    end method.
    method public logical getCRGPresentationHono():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcPres as character no-undo.
        vcPres = entry(3, entry(8, entry(1, this-object:zon04, separ[3]), separ[1]), separ[2]) no-error.
        error-status:error = false no-error.
        return vcPres = "00001".
    end method.
    method public void setCRG5(pcParametre as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon04, 8, separ[1]).
        entry(5, this-object:zon04, separ[1]) = pcParametre no-error.
    end method.
    method public void setCRG6(pcParametre as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon04, 8, separ[1]).
        entry(6, this-object:zon04, separ[1]) = pcParametre no-error.
    end method.
    method public void setCRG7(pcParametre as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon04, 8, separ[1]).
        entry(7, this-object:zon04, separ[1]) = pcParametre no-error.
    end method.
    method public void setCRG8(pcParametre as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon04, 8, separ[1]).
        entry(8, this-object:zon04, separ[1]) = pcParametre no-error.
    end method.

    method public character getIRFTypeTache():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: 
        ------------------------------------------------------------------------------*/
        define variable vcType as character no-undo.
        vcType = entry(1, entry(1, this-object:zon05, separ[3]), separ[1]) no-error.
        error-status:error = false no-error.
        return vcType.
    end method.
    method public void setIRFTypeTache(pcType as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon05, 10, separ[1]).
        entry(1, this-object:zon05, separ[1]) = pcType no-error.
    end method.
    method public logical getIRFParametrageActif():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcItem  as character no-undo.
        vcItem = if num-entries(this-object:zon05, separ[3]) >= 2
                 then entry(2, this-object:zon05, separ[3]) 
                 else if num-entries(this-object:zon05, separ[1]) >= 2
                      then substitute("yes&1&2&1M", separ[2], entry(2, this-object:zon05, separ[1]))
                      else substitute("yes&1no&1M", separ[2]).
        return entry(1, vcItem, separ[2]) = "yes".
    end method.
    method public void setIRFParametrageActif(plActif as logical):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon05, 10, separ[1]).
        entry(2, this-object:zon05, separ[1]) = if plActif then "yes" else "no" no-error.
    end method.
    method public logical getIRFActivation():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcItem  as character no-undo.
        vcItem = if num-entries(this-object:zon05, separ[3]) >= 2
                 then entry(2, this-object:zon05, separ[3]) 
                 else if num-entries(this-object:zon05, separ[1]) >= 2
                      then substitute("yes&1&2&1M", separ[2], entry(2, this-object:zon05, separ[1]))
                      else substitute("yes&1no&1M", separ[2]).
        return entry(2, vcItem, separ[2]) = "yes".
    end method.
    method public logical getIRFAutomatique():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcItem  as character no-undo.
        vcItem = if num-entries(this-object:zon05, separ[3]) >= 2
                 then entry(2, this-object:zon05, separ[3]) 
                 else if num-entries(this-object:zon05, separ[1]) >= 2
                      then substitute("yes&1&2&1M", separ[2], entry(2, this-object:zon05, separ[1]))
                      else substitute("yes&1no&1M", separ[2]).
        return entry(3, vcItem, separ[2]) = "a".
    end method.
    method public character getIRFCodeDeclaration():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcCode as character no-undo.
        vcCode = entry(3, entry(3, entry(1, this-object:zon05, separ[3]), separ[1]), separ[2]) no-error.
        error-status:error = false no-error.
        return vcCode.
    end method.
    method public void setIRFCodeDeclaration(pcCode as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon05, 10, separ[1]).
        entry(3, this-object:zon05, separ[1]) = pcCode no-error.
    end method.
    method public logical getIRFDeclaration2072():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcCode as character no-undo.
        vcCode = entry(3, entry(4, entry(1, this-object:zon05, separ[3]), separ[1]), separ[2]) no-error.
        error-status:error = false no-error.
        return vcCode = "00001".
    end method.
    method public void setIRF4(pcParametre as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon05, 10, separ[1]).
        entry(4, this-object:zon05, separ[1]) = pcParametre no-error.
    end method.
    method public logical getIRFMicroFoncier():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcCode as character no-undo.
        vcCode = entry(3, entry(5, entry(1, this-object:zon05, separ[3]), separ[1]), separ[2]) no-error.
        error-status:error = false no-error.
        return vcCode = "00001".
    end method.
    method public void setIRF5(pcParametre as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon05, 10, separ[1]).
        entry(5, this-object:zon05, separ[1]) = pcParametre no-error.
    end method.
    method public logical getIRFTVAProratee():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcCode as character no-undo.
        vcCode = entry(3, entry(6, entry(1, this-object:zon05, separ[3]), separ[1]), separ[2]) no-error.
        error-status:error = false no-error.
        return vcCode = "21001".
    end method.
    method public void setIRF6(pcParametre as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon05, 10, separ[1]).
        entry(6, this-object:zon05, separ[1]) = pcParametre no-error.
    end method.
    method public logical getIRFProrataMandant():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcCode as character no-undo.
        vcCode = entry(3, entry(7, entry(1, this-object:zon05, separ[3]), separ[1]), separ[2]) no-error.
        error-status:error = false no-error.
        return vcCode = "21001".
    end method.
    method public void setIRF7(pcParametre as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon05, 10, separ[1]).
        entry(7, this-object:zon05, separ[1]) = pcParametre no-error.
    end method.
    method public character getIRFCodeHonoraire():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcCode as character no-undo.
        vcCode = entry(3, entry(8, entry(1, this-object:zon05, separ[3]), separ[1]), separ[2]) no-error.
        error-status:error = false no-error.
        return vcCode.
    end method.
    method public void setIRF8(pcParametre as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon05, 10, separ[1]).
        entry(8, this-object:zon05, separ[1]) = pcParametre no-error.
    end method.
    method public decimal getIRFDeductionFrais():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vdeMontant as decimal no-undo.
        vdeMontant = decimal(entry(9, entry(1, this-object:zon05, separ[3]), separ[1])) no-error.
        error-status:error = false no-error.
        return vdeMontant.
    end method.
    method public void setIRF9(pcParametre as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon05, 10, separ[1]).
        entry(9, this-object:zon05, separ[1]) = pcParametre no-error.
    end method.
    method public decimal getIRFTauxDeductionMicro():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vdeMontant as decimal no-undo.
        vdeMontant = decimal(entry(10, entry(1, this-object:zon05, separ[3]), separ[1])) no-error.
        error-status:error = false no-error.
        return vdeMontant.
    end method.
    method public void setIRF10(pcParametre as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon05, 10, separ[1]).
        entry(10, this-object:zon05, separ[1]) = pcParametre no-error.
    end method.

    method public character getISFTypeTache():
        /*------------------------------------------------------------------------------
        Purpose : Code Frais de gestion
        Notes: 
        ------------------------------------------------------------------------------*/
        define variable vcType as character no-undo.
        vcType = entry(1, entry(1, this-object:zon06, separ[3]), separ[1]) no-error.
        error-status:error = false no-error.
        return vcType.
    end method.
    method public void setISFTypeTache(pcType as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon06, 5, separ[1]).
        entry(1, this-object:zon06, separ[1]) = pcType no-error.
    end method.
    method public logical getISFParametrageActif():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcItem  as character no-undo.
        vcItem = if num-entries(this-object:zon06, separ[3]) >= 2
                 then entry(2, this-object:zon06, separ[3]) 
                 else if num-entries(this-object:zon06, separ[1]) >= 2
                      then substitute("yes&1&2&1M", separ[2], entry(2, this-object:zon06, separ[1]))
                      else substitute("yes&1no&1M", separ[2]).
        return entry(1, vcItem, separ[2]) = "yes".
    end method.
    method public void setISFParametrageActif(plActif as logical):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon06, 5, separ[1]).
        entry(2, this-object:zon06, separ[1]) = if plActif then "yes" else "no" no-error.
    end method.
    method public logical getISFActivation():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcItem  as character no-undo.
        vcItem = if num-entries(this-object:zon06, separ[3]) >= 2
                 then entry(2, this-object:zon06, separ[3]) 
                 else if num-entries(this-object:zon06, separ[1]) >= 2
                      then substitute("yes&1&2&1M", separ[2], entry(2, this-object:zon06, separ[1]))
                      else substitute("yes&1no&1M", separ[2]).
        return entry(2, vcItem, separ[2]) = "yes".
    end method.
    method public logical getISFAutomatique():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcItem  as character no-undo.
        vcItem = if num-entries(this-object:zon06, separ[3]) >= 2
                 then entry(2, this-object:zon06, separ[3]) 
                 else if num-entries(this-object:zon06, separ[1]) >= 2
                      then substitute("yes&1&2&1M", separ[2], entry(2, this-object:zon06, separ[1]))
                      else substitute("yes&1no&1M", separ[2]).
        return entry(3, vcItem, separ[2]) = "a".
    end method.
    method public character getISFCodeDeclaration():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcCode as character no-undo.
        vcCode = entry(3, entry(3, entry(1, this-object:zon06, separ[3]), separ[1]), separ[2]) no-error.
        error-status:error = false no-error.
        return vcCode.
    end method.
    method public void setISF3(pcParametre as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon06, 5, separ[1]).
        entry(3, this-object:zon06, separ[1]) = pcParametre no-error.
    end method.
    method public character getISFcodePeriode():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcCode as character no-undo.
        vcCode = entry(3, entry(4, entry(1, this-object:zon06, separ[3]), separ[1]), separ[2]) no-error.
        error-status:error = false no-error.
        return vcCode.
    end method.
    method public void setISF4(pcParametre as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon06, 5, separ[1]).
        entry(4, this-object:zon06, separ[1]) = pcParametre no-error.
    end method.
    method public character getISFCodeHonoraire():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcCode as character no-undo.
        vcCode = entry(3, entry(5, entry(1, this-object:zon06, separ[3]), separ[1]), separ[2]) no-error.
        error-status:error = false no-error.
        return vcCode.
    end method.
    method public void setISF5(pcParametre as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon06, 5, separ[1]).
        entry(5, this-object:zon06, separ[1]) = pcParametre no-error.
    end method.

    method public character getDAS2TypeTache():
        /*------------------------------------------------------------------------------
        Purpose : Code Frais de gestion
        Notes: 
        ------------------------------------------------------------------------------*/
        define variable vcType as character no-undo.
        vcType = entry(1, entry(1, this-object:zon07, separ[3]), separ[1]) no-error.
        error-status:error = false no-error.
        return vcType.
    end method.
    method public void setDAS2TypeTache(pcType as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon07, 4, separ[1]).
        entry(1, this-object:zon07, separ[1]) = pcType no-error.
    end method.
    method public logical getDAS2ParametrageActif():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcItem  as character no-undo.
        vcItem = if num-entries(this-object:zon07, separ[3]) >= 2
                 then entry(2, this-object:zon07, separ[3]) 
                 else if num-entries(this-object:zon07, separ[1]) >= 2
                      then substitute("yes&1&2&1M", separ[2], entry(2, this-object:zon07, separ[1]))
                      else substitute("yes&1no&1M", separ[2]).
        return entry(1, vcItem, separ[2]) = "yes".
    end method.
    method public void setDAS2ParametrageActif(plActif as logical):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon07, 4, separ[1]).
        entry(2, this-object:zon07, separ[1]) = if plActif then "yes" else "no" no-error.
    end method.
    method public logical getDAS2Activation():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcItem  as character no-undo.
        vcItem = if num-entries(this-object:zon07, separ[3]) >= 2
                 then entry(2, this-object:zon07, separ[3]) 
                 else if num-entries(this-object:zon07, separ[1]) >= 2
                      then substitute("yes&1&2&1M", separ[2], entry(2, this-object:zon07, separ[1]))
                      else substitute("yes&1no&1M", separ[2]).
        return entry(2, vcItem, separ[2]) = "yes".
    end method.
    method public logical getDAS2Automatique():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcItem  as character no-undo.
        vcItem = if num-entries(this-object:zon07, separ[3]) >= 2
                 then entry(2, this-object:zon07, separ[3]) 
                 else if num-entries(this-object:zon07, separ[1]) >= 2
                      then substitute("yes&1&2&1M", separ[2], entry(2, this-object:zon07, separ[1]))
                      else substitute("yes&1no&1M", separ[2]).
        return entry(3, vcItem, separ[2]) = "a".
    end method.
    method public logical getDAS2Comptabilisation():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcCode as character no-undo.
        vcCode = entry(3, entry(3, entry(1, this-object:zon07, separ[3]), separ[1]), separ[2]) no-error.
        error-status:error = false no-error.
        return vcCode = "21001".
    end method.
    method public void setDAS23(pcParametre as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon07, 4, separ[1]).
        entry(3, this-object:zon07, separ[1]) = pcParametre no-error.
    end method.
    method public character getDAS2CodeHonoraire():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcCode as character no-undo.
        vcCode = entry(3, entry(4, entry(1, this-object:zon07, separ[3]), separ[1]), separ[2]) no-error.
        error-status:error = false no-error.
        return vcCode.
    end method.
    method public void setDAS24(pcParametre as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon07, 4, separ[1]).
        entry(4, this-object:zon07, separ[1]) = pcParametre no-error.
    end method.

    method public character getCRLTypeTache():
        /*------------------------------------------------------------------------------
        Purpose : Code Frais de gestion
        Notes: 
        ------------------------------------------------------------------------------*/
        define variable vcType as character no-undo.
        vcType = entry(1, entry(1, this-object:zon08, separ[3]), separ[1]) no-error.
        error-status:error = false no-error.
        return vcType.
    end method.
    method public void setCRLTypeTache(pcType as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon08, 7, separ[1]).
        entry(1, this-object:zon08, separ[1]) = pcType no-error.
    end method.
    method public logical getCRLParametrageActif():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcItem  as character no-undo.
        vcItem = if num-entries(this-object:zon08, separ[3]) >= 2
                 then entry(2, this-object:zon08, separ[3]) 
                 else if num-entries(this-object:zon08, separ[1]) >= 2
                      then substitute("yes&1&2&1M", separ[2], entry(2, this-object:zon08, separ[1]))
                      else substitute("yes&1no&1M", separ[2]).
        return entry(1, vcItem, separ[2]) = "yes".
    end method.
    method public void setCRLParametrageActif(plActif as logical):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon08, 7, separ[1]).
        entry(2, this-object:zon08, separ[1]) = if plActif then "yes" else "no" no-error.
    end method.
    method public logical getCRLActivation():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcItem  as character no-undo.
        vcItem = if num-entries(this-object:zon08, separ[3]) >= 2
                 then entry(2, this-object:zon08, separ[3]) 
                 else if num-entries(this-object:zon08, separ[1]) >= 2
                      then substitute("yes&1&2&1M", separ[2], entry(2, this-object:zon08, separ[1]))
                      else substitute("yes&1no&1M", separ[2]).
        return entry(2, vcItem, separ[2]) = "yes".
    end method.
    method public character getCRLCodeEncaissement():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcCode as character no-undo.
        vcCode = entry(3, entry(3, entry(1, this-object:zon08, separ[3]), separ[1]), separ[2]) no-error.
        error-status:error = false no-error.
        return vcCode.
    end method.
    method public void setCRL3(pcParametre as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon08, 7, separ[1]).
        entry(3, this-object:zon08, separ[1]) = pcParametre no-error.
    end method.
    method public character getCRLCodeDeclaration():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcCode as character no-undo.
        vcCode = entry(3, entry(4, entry(1, this-object:zon08, separ[3]), separ[1]), separ[2]) no-error.
        error-status:error = false no-error.
        return vcCode.
    end method.
    method public void setCRL4(pcParametre as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon08, 7, separ[1]).
        entry(4, this-object:zon08, separ[1]) = pcParametre no-error.
    end method.
    method public character getCRLCodePeriode():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcCode as character no-undo.
        vcCode = entry(3, entry(5, entry(1, this-object:zon08, separ[3]), separ[1]), separ[2]) no-error.
        error-status:error = false no-error.
        return vcCode.
    end method.
    method public void setCRL5(pcParametre as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon08, 7, separ[1]).
        entry(5, this-object:zon08, separ[1]) = pcParametre no-error.
    end method.
    method public logical getCRLComptabilisation():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcCode as character no-undo.
        vcCode = entry(3, entry(6, entry(1, this-object:zon08, separ[3]), separ[1]), separ[2]) no-error.
        error-status:error = false no-error.
        return vcCode = "21001".
    end method.
    method public void setCRL6(pcParametre as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon08, 7, separ[1]).
        entry(6, this-object:zon08, separ[1]) = pcParametre no-error.
    end method.
    method public character getCRLCodeHonoraire():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcCode as character no-undo.
        vcCode = entry(3, entry(7, entry(1, this-object:zon08, separ[3]), separ[1]), separ[2]) no-error.
        error-status:error = false no-error.
        return vcCode.
    end method.
    method public void setCRL7(pcParametre as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon08, 7, separ[1]).
        entry(7, this-object:zon08, separ[1]) = pcParametre no-error.
    end method.

    method public character getChargeLocativeTypeTache():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcType as character no-undo.
        vcType = entry(1, entry(1, this-object:zon09, separ[3]), separ[1]) no-error.
        error-status:error = false no-error.
        return vcType.
    end method.
    method public void setChargeLocativeTypeTache(pcType as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon09, 5, separ[1]).
        entry(1, this-object:zon09, separ[1]) = pcType no-error.
    end method.
    method public logical getChargeLocativeParametrageActif():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcItem  as character no-undo.
        vcItem = if num-entries(this-object:zon09, separ[3]) >= 2
                 then entry(2, this-object:zon09, separ[3]) 
                 else if num-entries(this-object:zon09, separ[1]) >= 2
                      then substitute("yes&1&2&1M", separ[2], entry(2, this-object:zon09, separ[1]))
                      else substitute("yes&1no&1M", separ[2]).
        return entry(1, vcItem, separ[2]) = "yes".
    end method.
    method public void setChargeLocativeParametrageActif(plActif as logical):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon09, 5, separ[1]).
        entry(2, this-object:zon09, separ[1]) = if plActif then "yes" else "no" no-error.
    end method.
    method public logical getChargeLocativeActivation():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcItem  as character no-undo.
        vcItem = if num-entries(this-object:zon09, separ[3]) >= 2
                 then entry(2, this-object:zon09, separ[3]) 
                 else if num-entries(this-object:zon09, separ[1]) >= 2
                      then substitute("yes&1&2&1M", separ[2], entry(2, this-object:zon09, separ[1]))
                      else substitute("yes&1yes&1M", separ[2]).
        return entry(2, vcItem, separ[2]) = "yes".
    end method.
    method public character getChargeLocativeCodePresentation():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcCode as character no-undo.
        vcCode = entry(3, entry(3, entry(1, this-object:zon09, separ[3]), separ[1]), separ[2]) no-error.
        error-status:error = false no-error.
        return vcCode.
    end method.
    method public void setChargeLocative3(pcParametre as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon09, 5, separ[1]).
        entry(3, this-object:zon09, separ[1]) = pcParametre no-error.
    end method.
    method public character getChargeLocativeCodeRepartition():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcCode as character no-undo.
        vcCode = entry(3, entry(4, entry(1, this-object:zon09, separ[3]), separ[1]), separ[2]) no-error.
        error-status:error = false no-error.
        return vcCode.
    end method.
    method public void setChargeLocative4(pcParametre as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon09, 5, separ[1]).
        entry(4, this-object:zon09, separ[1]) = pcParametre no-error.
    end method.
    method public logical getChargeLocativeIntegrationDirectCompta():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcCode as character no-undo.
        vcCode = entry(5, entry(1, this-object:zon09, separ[3]), separ[1]) no-error.
        error-status:error = false no-error.
        return vcCode = "yes".
    end method.
    method public void setChargeLocative5(pcParametre as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon09, 5, separ[1]).
        entry(5, this-object:zon09, separ[1]) = pcParametre no-error.
    end method.

    method public character getTVATypeTache():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcType as character no-undo.
        vcType = entry(1, entry(1, this-object:zon10, separ[3]), separ[1]) no-error.
        error-status:error = false no-error.
        return vcType.
    end method.
    method public void setTVATypeTache(pcType as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon10, 11, separ[1]).
        entry(1, this-object:zon10, separ[1]) = pcType no-error.
    end method.
    method public logical getTVAParametrageActif():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcItem  as character no-undo.
        vcItem = if num-entries(this-object:zon10, separ[3]) >= 2
                 then entry(2, this-object:zon10, separ[3]) 
                 else if num-entries(this-object:zon10, separ[1]) >= 2
                      then substitute("yes&1&2&1M", separ[2], entry(2, this-object:zon10, separ[1]))
                      else substitute("yes&1no&1M", separ[2]).
        return entry(1, vcItem, separ[2]) = "yes".
    end method.
    method public void setTVAParametrageActif(plActif as logical):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon10, 11, separ[1]).
        entry(2, this-object:zon10, separ[1]) = if plActif then "yes" else "no" no-error.
    end method.
    method public logical getTVAActivation():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcItem  as character no-undo.
        vcItem = if num-entries(this-object:zon10, separ[3]) >= 2
                 then entry(2, this-object:zon10, separ[3]) 
                 else if num-entries(this-object:zon10, separ[1]) >= 2
                      then substitute("yes&1&2&1M", separ[2], entry(2, this-object:zon10, separ[1]))
                      else substitute("yes&1yes&1M", separ[2]).
        return entry(2, vcItem, separ[2]) = "yes".
    end method.
    method public character getTVACodeRegime():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcCode as character no-undo.
        vcCode = entry(3, entry(3, entry(1, this-object:zon10, separ[3]), separ[1]), separ[2]) no-error.
        error-status:error = false no-error.
        return vcCode.
    end method.
    method public void setTVA3(pcParametre as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon10, 11, separ[1]).
        entry(3, this-object:zon10, separ[1]) = pcParametre no-error.
    end method.
    method public character getTVACodeDeclaration():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcCode as character no-undo.
        vcCode = entry(3, entry(4, entry(1, this-object:zon10, separ[3]), separ[1]), separ[2]) no-error.
        error-status:error = false no-error.
        return vcCode.
    end method.
    method public void setTVA4(pcParametre as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon10, 11, separ[1]).
        entry(4, this-object:zon10, separ[1]) = pcParametre no-error.
    end method.
    method public character getTVACodePeriode():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcCode as character no-undo.
        vcCode = entry(3, entry(5, entry(1, this-object:zon10, separ[3]), separ[1]), separ[2]) no-error.
        error-status:error = false no-error.
        return vcCode.
    end method.
    method public void setTVA5(pcParametre as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon10, 11, separ[1]).
        entry(5, this-object:zon10, separ[1]) = pcParametre no-error.
    end method.
    method public logical getTVAReglement():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcCode as character no-undo.
        vcCode = entry(3, entry(6, entry(1, this-object:zon10, separ[3]), separ[1]), separ[2]) no-error.
        error-status:error = false no-error.
        return vcCode = "21001".
    end method.
    method public void setTVA6(pcParametre as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon10, 11, separ[1]).
        entry(6, this-object:zon10, separ[1]) = pcParametre no-error.
    end method.
    method public character getTVACodeConserve():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcCode as character no-undo.
        vcCode = entry(1, entry(7, entry(1, this-object:zon10, separ[3]), separ[1]), separ[2]) no-error.
        error-status:error = false no-error.
        return vcCode.
    end method.
    method public void setTVA7(pcParametre as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon10, 11, separ[1]).
        entry(7, this-object:zon10, separ[1]) = pcParametre no-error.
    end method.
    method public integer getTVAProrataNumerateur():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcCode as character no-undo.
        vcCode = entry(1, entry(8, entry(1, this-object:zon10, separ[3]), separ[1]), separ[2]) no-error.
        error-status:error = false no-error.
        return integer(vcCode).
    end method.
    method public integer getTVAProrataDenominateur():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcCode as character no-undo.
        vcCode = entry(2, entry(8, entry(1, this-object:zon10, separ[3]), separ[1]), separ[2]) no-error.
        error-status:error = false no-error.
        return integer(vcCode).
    end method.
    method public void setTVA8(pcParametre as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon10, 11, separ[1]).
        entry(8, this-object:zon10, separ[1]) = pcParametre no-error.
    end method.
    method public character getTVACodeRecette():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcCode as character no-undo.
        vcCode = entry(9, entry(1, this-object:zon10, separ[3]), separ[1]) no-error.
        error-status:error = false no-error.
        return vcCode.
    end method.
    method public void setTVA9(pcParametre as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon10, 11, separ[1]).
        entry(9, this-object:zon10, separ[1]) = pcParametre no-error.
    end method.
    method public character getTVACodeDepense():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcCode as character no-undo.
        vcCode = entry(10, entry(1, this-object:zon10, separ[3]), separ[1]) no-error.
        error-status:error = false no-error.
        return vcCode.
    end method.
    method public void setTVA10(pcParametre as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon10, 11, separ[1]).
        entry(10, this-object:zon10, separ[1]) = pcParametre no-error.
    end method.
    method public character getTVACodeHonoraire():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcCode as character no-undo.
        vcCode = entry(3, entry(11, entry(1, this-object:zon10, separ[3]), separ[1]), separ[2]) no-error.
        error-status:error = false no-error.
        return vcCode.
    end method.
    method public void setTVA11(pcParametre as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:zon10, 11, separ[1]).
        entry(11, this-object:zon10, separ[1]) = pcParametre no-error.
    end method.

    method public character getDossierMandatTypeTache():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: 
        ------------------------------------------------------------------------------*/
        define variable vcType as character no-undo.
        vcType = entry(1, entry(1, this-object:lbdiv, separ[3]), separ[1]) no-error.
        error-status:error = false no-error.
        return vcType.
    end method.
    method public void setDossierMandatTypeTache(pcType as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:lbdiv, 4, separ[1]).
        entry(1, this-object:lbdiv, separ[1]) = pcType no-error.
    end method.
    method public logical getDossierMandatParametrageActif():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcItem  as character no-undo.
        vcItem = if num-entries(this-object:lbdiv, separ[3]) >= 2
                 then entry(2, this-object:lbdiv, separ[3]) 
                 else substitute("yes&1no&1M", separ[2]).
        return entry(1, vcItem, separ[2]) = "yes".
    end method.
    method public void setDossierMandatParametrageActif(plActif as logical):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:lbdiv, 4, separ[1]).
        entry(2, this-object:lbdiv, separ[1]) = if plActif then "yes" else "no" no-error.
    end method.
    method public logical getDossierMandatActivation():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcItem  as character no-undo.
        vcItem = if num-entries(this-object:lbdiv, separ[3]) >= 2
                 then entry(2, this-object:lbdiv, separ[3]) 
                 else substitute("yes&1no&1M", separ[2]).
        return entry(2, vcItem, separ[2]) = "yes".
    end method.
    method public logical getDossierMandatAutomatique():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcItem  as character no-undo.
        vcItem = if num-entries(this-object:lbdiv, separ[3]) >= 2
                 then entry(2, this-object:lbdiv, separ[3]) 
                 else substitute("yes&1no&1M", separ[2]).
        return entry(3, vcItem, separ[2]) = "a".
    end method.
    method public logical getDossierMandatChargeSyndic():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcCode as character no-undo.
        vcCode = entry(3, entry(3, entry(1, this-object:lbdiv, separ[3]), separ[1]), separ[2]) no-error.
        error-status:error = false no-error.
        return vcCode = "00001".
    end method.
    method public void setDossierMandat3(pcParametre as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:lbdiv, 11, separ[1]).
        entry(3, this-object:lbdiv, separ[1]) = pcParametre no-error.
    end method.
    method public void setDossierMandat4(pcParametre as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:lbdiv, 11, separ[1]).
        entry(4, this-object:lbdiv, separ[1]) = pcParametre no-error.
    end method.

    method public character getCommentaireTypeTache():
        /*------------------------------------------------------------------------------
        Purpose : Code Frais de gestion
        Notes: 
        ------------------------------------------------------------------------------*/
        define variable vcType as character no-undo.
        vcType = entry(1, entry(1, this-object:lbdiv2, separ[3]), separ[1]) no-error.
        error-status:error = false no-error.
        return vcType.
    end method.
    method public void setCommentaireTypeTache(pcType as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:lbdiv2, 2, separ[1]).
        entry(1, this-object:lbdiv2, separ[1]) = pcType no-error.
    end method.
    method public logical getCommentaireParametrageActif():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcItem  as character no-undo.
        vcItem = if num-entries(this-object:lbdiv2, separ[3]) >= 2
                 then entry(2, this-object:lbdiv2, separ[3]) 
                 else substitute("yes&1no&1M", separ[2]).
        return entry(1, vcItem, separ[2]) = "yes".
    end method.
    method public logical getCommentaireActivation():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcItem  as character no-undo.
        vcItem = if num-entries(this-object:lbdiv2, separ[3]) >= 2
                 then entry(2, this-object:lbdiv2, separ[3]) 
                 else substitute("yes&1no&1M", separ[2]).
        return entry(2, vcItem, separ[2]) = "yes".
    end method.
    method public logical getCommentaireAutomatique():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcItem  as character no-undo.
        vcItem = if num-entries(this-object:lbdiv2, separ[3]) >= 2
                 then entry(2, this-object:lbdiv2, separ[3]) 
                 else substitute("yes&1no&1M", separ[2]).
        return entry(3, vcItem, separ[2]) = "a".
    end method.
    method public void setCommentaire2(pcParametre as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:lbdiv2, 2, separ[1]).
        entry(2, this-object:lbdiv2, separ[1]) = pcParametre no-error.
    end method.

    method public character getCommercialTypeTache():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: 
        ------------------------------------------------------------------------------*/
        define variable vcType as character no-undo.
        vcType = entry(1, entry(1, this-object:lbdiv3, separ[3]), separ[1]) no-error.
        error-status:error = false no-error.
        return vcType.
    end method.
    method public void setCommercialTypeTache(pcType as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:lbdiv3, 2, separ[1]).
        entry(1, this-object:lbdiv3, separ[1]) = pcType no-error.
    end method.
    method public logical getCommercialParametrageActif():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcItem  as character no-undo.
        vcItem = if num-entries(this-object:lbdiv3, separ[3]) >= 2
                 then entry(2, this-object:lbdiv3, separ[3]) 
                 else substitute("yes&1no&1M", separ[2]).
        return entry(1, vcItem, separ[2]) = "yes".
    end method.
    method public logical getCommercialActivation():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcItem  as character no-undo.
        vcItem = if num-entries(this-object:lbdiv3, separ[3]) >= 2
                 then entry(2, this-object:lbdiv3, separ[3]) 
                 else substitute("yes&1no&1M", separ[2]).
        return entry(2, vcItem, separ[2]) = "yes".
    end method.
    method public logical getCommercialAutomatique():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcItem  as character no-undo.
        vcItem = if num-entries(this-object:lbdiv3, separ[3]) >= 2
                 then entry(2, this-object:lbdiv3, separ[3]) 
                 else substitute("yes&1no&1M", separ[2]).
        return entry(3, vcItem, separ[2]) = "a".
    end method.
    method public void setCommercial2(pcParametre as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        fillPrepare(this-object:lbdiv3, 2, separ[1]).
        entry(2, this-object:lbdiv3, separ[1]) = pcParametre no-error.
    end method.

end class.
