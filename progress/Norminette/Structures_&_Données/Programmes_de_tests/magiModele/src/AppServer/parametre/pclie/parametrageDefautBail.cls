/*------------------------------------------------------------------------
File        : parametrageDefautBail.cls
Description : Mise a jour des paramètres par defaut - BAIL
Author(s)   : kantena  -  2017/09/29
Notes       : pcldefbx.p
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametrageDefautBail inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/
    define variable separ as character format "X" extent 5 no-undo.

    constructor public parametrageDefautBail():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("DEFBX").
        {application/include/glbsepar2.i}
    end constructor.

    constructor public parametrageDefautBail(pcZon01 as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("DEFBX", pcZon01).
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

    method public decimal getNombreMoisAvance():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: TODO A renommer
        ------------------------------------------------------------------------------*/
        return int01.
    end method.
    
    method public logical isReleveAppelFondsActif():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return zon02 = "00001".  // oui
    end method.

    method public character getFacturationDepotGarantiePEC():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcFacturation as character no-undo.
        vcFacturation = (if num-entries(this-object:zon04, separ[1]) >= 7 then entry(7, this-object:zon04, separ[1])
                                                                          else "00001") no-error.
        error-status:error = false no-error.
        return vcFacturation.
    end method.

    method public character getNombreMoisLoyer():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcNombreMois as character no-undo.
        vcNombreMois = (if num-entries(this-object:zon10, separ[1]) >= 2 then entry(2, this-object:zon10, separ[1])
                                                                         else "1") no-error.
        error-status:error = false no-error.
        return vcNombreMois.
    end method.

    method public character getReactualisationAutomatique():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcReactualisationAutomatique as character no-undo.
        vcReactualisationAutomatique = (if num-entries(this-object:zon10, separ[1]) >= 3 then entry(3, this-object:zon10, separ[1])
                                                                                         else "00002") no-error.
        error-status:error = false no-error.
        return vcReactualisationAutomatique.
    end method.

    method public character getModeCalcul():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcModeCalcul as character no-undo.
        vcModeCalcul = (if num-entries(this-object:zon10, separ[1]) >= 4 then entry(4, this-object:zon10, separ[1])
                                                                         else "00001") no-error.
        error-status:error = false no-error.
        return vcModeCalcul.
    end method.

    method public character getReactualisationBaisse():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcReactualisationBaisse as character no-undo.
        vcReactualisationBaisse = (if num-entries(this-object:zon10, separ[1]) >= 5 then entry(5, this-object:zon10, separ[1])
                                                                                    else "00002") no-error.
        error-status:error = false no-error.
        return vcReactualisationBaisse.
    end method.

    method public logical isNatureBailActive():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return fgact = "YES".  // oui
    end method.

end class.
