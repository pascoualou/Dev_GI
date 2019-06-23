/*------------------------------------------------------------------------
File        : indiceRevision_CRUD.p
Purpose     :
Author(s)   : DM - 2017/10/10
Notes       : reprise de adb/src/lib/l_indrv_ext.p  
------------------------------------------------------------------------*/
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

procedure getLibelleIndice:
    /*------------------------------------------------------------------------------
    Purpose: Libellé indice de révision   Procedure RecLibInd et RecLibInc
    Notes  : service appelé par baremeHonoraire.p  .... reprise de adb/src/lib/l_indrv_ext.p
    ------------------------------------------------------------------------------*/
    define input parameter  piCdIrv   as integer   no-undo.
    define input parameter  piAnPer   as integer   no-undo.
    define input parameter  piNoPer   as integer   no-undo.
    define input parameter  pcTypeLib as character no-undo.    // npo pour gérer libellé court et explicite
    define output parameter pcLibelle as character no-undo.

    define variable vcLibelleMes    as character    no-undo.
    define buffer lsirv for lsirv.
    
    for first lsirv no-lock where lsirv.cdirv = piCdIrv:
        case lsirv.cdper:
            when 1 then  // Indice mensuel
                pcLibelle = substitute("&1 &2", outilTraduction:getLibelleParam("CDMOI", string(piNoPer,"99999"), "c"), string(piAnPer)). // Recherche du libelle du mois

                when 3 then do: // Indice trimestriel
                  if mToken:iCodeLangueReference = 0     // Gestion du 1er et des nièmes (pour la France)
                  then vcLibelleMes = outilTraduction:getLibelle(if piNoPer = 1 then 44 else 24).
                  if pcTypeLib = "c" then
                      pcLibelle = substitute("&1&2 &3 &4", piNoPer, vcLibelleMes, outilTraduction:getLibelle(102088), piAnPer).
                  else
                      pcLibelle = substitute("&1&2 &3 &4", piNoPer, vcLibelleMes, outilTraduction:getLibelle(100997), piAnPer).
                end.

                when 6 then do: // Indice semestriel
                  if mToken:iCodeLangueReference = 0     // Gestion du 1er et des nièmes (pour la France)
                  then vcLibelleMes = outilTraduction:getLibelle(if piNoPer = 1 then 44 else 24).
                  if pcTypeLib = "c" then
                      pcLibelle = substitute("&1&2 &3 &4", piNoPer, vcLibelleMes, string(outilTraduction:getLibelle(107514), "X(3)"), piAnPer).
                  else
                      pcLibelle = substitute("&1&2 &3 &4", piNoPer, vcLibelleMes, outilTraduction:getLibelle(107514), piAnPer).
                end.
                when 12 then pcLibelle = string(piAnPer).
        end case.
    end.        
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure readIndiceRevision2:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : reprise de LecIndR2
    ------------------------------------------------------------------------------*/
    define input  parameter piTypeIndiceCou         as integer no-undo.
    define input  parameter piAnneeCou              as integer no-undo.
    define input  parameter piNumeroPeriodeCou      as integer no-undo.
    define input  parameter piNombrePeriodeRevision as integer no-undo.
    define output parameter poCollection            as class collection no-undo.

    define variable viIndice as integer no-undo.

    define buffer indrv for indrv.
    define buffer lsirv for lsirv.

    find first IndRv no-lock
         where IndRv.CdIrv = piTypeIndiceCou
           and IndRv.AnPer = piAnneeCou + piNombrePeriodeRevision
           and IndRv.NoPer = piNumeroPeriodeCou no-error.
    if not available (IndRv) then
    do:
        poCollection:set("lTrouve", false).
        return.
    end.

    /* Recuperation des infos */
    poCollection = new collection().
    poCollection:set("lTrouve",         true).
    poCollection:set("iTypeIndice",     IndRv.CdIrv).
    poCollection:set("iAnneeCou",       IndRv.AnPer).
    poCollection:set("iNumerPeriode",   IndRv.NoPer).
    poCollection:set("dValeurRevision", IndRv.VlIrv).
    poCollection:set("dParutionJO",     IndRv.DtPjo).
    poCollection:set("daMAJ",           IndRv.DtMsy).

    /* Recherche du type d'indice */
    find first lsirv no-lock
         where lsirv.cdirv = piTypeIndiceCou no-error.
    if available lsirv and LsIrv.FgVal = 1
    then poCollection:set("dTauxRevision", indrv.txirv). /* Indice avec taux uniquement */
    else do:
        /* Modif Sy le 14/03/2005 : calcul du taux sur sur la période écoulée (1 ans, 3ans ...) */
        viIndice = indrv.VlIrv.
        find first IndRv no-lock
             where IndRv.CdIrv = piTypeIndiceCou
               and IndRv.AnPer = piAnneeCou 
               and IndRv.NoPer = piNombrePeriodeRevision no-error.
        if available Indrv 
        then poCollection:set("dTauxRevision", ((viIndice * 100) / indrv.vlirv) - 100).
    end.

end procedure.

procedure readIndiceRevision3:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : reprise de LecIndR3
    ------------------------------------------------------------------------------*/
    define input  parameter piTypeIndiceCou         as integer no-undo.
    define input  parameter piAnneeCou              as integer no-undo.
    define input  parameter piNumeroPeriodeCou      as integer no-undo.
    define input  parameter piNombrePeriodeRevision as integer no-undo.
    define output parameter poCollection            as class collection no-undo.

    define variable viIndice as integer no-undo.

    define buffer indrv for indrv.
    define buffer lsirv for lsirv.

    find first IndRv no-lock
         where IndRv.CdIrv = piTypeIndiceCou
           and IndRv.AnPer = piAnneeCou
           and IndRv.NoPer = piNumeroPeriodeCou no-error.
    if not available (IndRv) then do:
        poCollection:set("lTrouve", false).
        return.
    end.

    /* Recuperation des infos */
    poCollection = new collection().
    poCollection:set("lTrouve",         true).
    poCollection:set("iTypeIndice",     IndRv.CdIrv).
    poCollection:set("iAnneeCou",       IndRv.AnPer).
    poCollection:set("iNumerPeriode",   IndRv.NoPer).
    poCollection:set("dValeurRevision", IndRv.VlIrv).
    poCollection:set("dParutionJO",     IndRv.DtPjo).
    poCollection:set("daMAJ",           IndRv.DtMsy).
    
    /* Recherche du type d'indice */
    find first lsirv no-lock
         where lsirv.cdirv = piTypeIndiceCou no-error.
    if available lsirv and LsIrv.FgVal = 1 
    then poCollection:set("dTauxRevision", indrv.txirv). /* Indice avec taux uniquement  */
    else do:
        /** Modif Sy le 14/03/2005 : calcul du taux sur la période écoulée ( 1 ans , 3ans ...) **/
        viIndice = indrv.VlIrv.
        find first IndRv no-lock
             where IndRv.CdIrv = piTypeIndiceCou
               and IndRv.AnPer = piAnneeCou - piNombrePeriodeRevision
               and IndRv.NoPer = piNumeroPeriodeCou no-error.
        if available Indrv 
        then poCollection:set("dValeurRevision", ((viIndice * 100) / indrv.vlirv) - 100).
    end.

end procedure.