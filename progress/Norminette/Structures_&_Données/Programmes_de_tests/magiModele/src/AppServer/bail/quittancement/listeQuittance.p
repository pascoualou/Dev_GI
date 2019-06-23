/*------------------------------------------------------------------------
File        : listeQuittance.p
Purpose     : chargement des avis d'échéance ou quittances historisées
Author(s)   : GGA 2018/06/04 - Spo 2018/08/01
Notes       :
derniere revue: 2018/08/14 - phm: KO
        programme non terminé (chargePreQuittancement)
----------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/referenceClient.i}

using parametre.pclie.parametrageRubriqueQuittHonoCabinet.
using parametre.pclie.parametrageProlongationExpiration.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{bail/include/tbtmpqtt.i}
{bail/include/tbtmprub.i}
{bail/include/listeQuittance.i}

define variable goCollectionHandlePgm as class collection no-undo.
define variable goCollection          as class collection no-undo.
define variable ghProc   as handle no-undo.

{outils/include/lancementProgramme.i}               // fonctions lancementPgm, suppressionPgmPersistent
{bail/quittancement/procedureCommuneQuittance.i}    // procédures chgMoisQuittance, chgInfoMandat, isRubMod
{bail/include/filtreLo.i}                           // Filtrage locataire à prendre, procedure filtreLoc

procedure getListeQuittanceEncours:
    /*------------------------------------------------------------------------------
      Purpose:
      Notes:   service externe
    ------------------------------------------------------------------------------*/
    define input parameter poCollection as class collection no-undo.
    define output parameter table for ttQtt.
    define output parameter table for ttRub.

    define variable viNumeroContrat as int64     no-undo.
    define variable vcTypeContrat   as character no-undo.
    define variable viNumeroMandat  as int64     no-undo.

    empty temp-table ttQtt.
    empty temp-table ttRub.
    assign
        vcTypeContrat         = poCollection:getCharacter("cTypeContrat")
        viNumeroContrat       = poCollection:getInt64("iNumeroContrat")
        viNumeroMandat        = truncate(viNumeroContrat / 100000, 0)
        goCollection          = poCollection
        goCollectionHandlePgm = new collection()
    .
    run chgMoisQuittance (viNumeroMandat, input-output goCollection).
    if vcTypeContrat = {&TYPECONTRAT-bail}
    then run chargeQuittanceEncours.
    else if vcTypeContrat = {&TYPECONTRAT-preBail}
    then run chargePreQuittancement.
    else do:
         mError:createError({&error}, 1000688, vcTypeContrat).     // Type de contrat &1 incorrect.
         return.
    end.
    suppressionPgmPersistent(goCollectionHandlePgm).

end procedure.

procedure chargeQuittanceEncours private:
    /*------------------------------------------------------------------------------
      Purpose: chargement des avis d'échéance (equit) entêtes + rubriques
      Notes:
    ------------------------------------------------------------------------------*/
    define variable voParametrageRubriqueQuittHonoCabinet as class   parametrageRubriqueQuittHonoCabinet no-undo.
    define variable vlTaciteReconduction         as logical no-undo.
    define variable vdaFinBail                   as date    no-undo.
    define variable vdaSortieLocataire           as date    no-undo.
    define variable vdaResiliationBail           as date    no-undo.
    define variable vdaFinQuittancementLocataire as date    no-undo.
    define variable vlPrendre                    as logical no-undo.
    define buffer vbTtQtt for ttQtt.

    ghProc = lancementPgm("bail/quittancement/quittanceEncours.p", goCollectionHandlePgm).
    run getListeQuittance in ghProc(goCollection,
                                    input-output table ttQtt by-reference,
                                    input-output table ttRub by-reference).
    // supprimer les avis d'échéance postérieurs à la sortie du locataire ou expiration du bail commercial (selon paramètres client)
boucleFiltrage:
    for each ttQtt:
        // Filtre (= Qtt locataire à prendre ?)
        run filtreLoc(ttQtt.daDebutPeriode, ttQtt.iNumeroLocataire, output vlTaciteReconduction, output vdaFinBail, output vdaSortieLocataire, output vdaResiliationBail, output vlPrendre, output vdaFinQuittancementLocataire).
        if not vlPrendre then do:
            for each vbTtQtt where vbttQtt.daDebutPeriode >= ttQtt.daDebutPeriode:
                for each ttRub where ttRub.iNoQuittance = vbttQtt.iNoQuittance:
                    delete ttRub.
                end.
                delete vbTtQtt.
            end.
            leave boucleFiltrage.
        end.
    end.
    // renseigner les actions autorisées sur chaque rubrique
    voParametrageRubriqueQuittHonoCabinet = new parametrageRubriqueQuittHonoCabinet().
    for each ttQtt
      , each ttRub where ttRub.iNoQuittance = ttQtt.iNoQuittance:
        run isRubMod(voParametrageRubriqueQuittHonoCabinet,
                     ttRub.iNorubrique,
                     ttRub.iNoLibelleRubrique,
                     ttRub.cCodeGenre,
                     ttQtt.iNombreRubrique,
                     ttQtt.cdori,
                     output ttRub.lModificationAutorisee,
                     output ttRub.lSuppressionAutorisee,
                     output ttRub.lLienRubrique).
    end.
    delete object voParametrageRubriqueQuittHonoCabinet.
end procedure.

procedure chargePreQuittancement private:
    /*------------------------------------------------------------------------------
      Purpose: chargement de la pré-quittance (pquit) entêtes + rubriques
      Notes:
    ------------------------------------------------------------------------------*/
    define variable voParametrageRubriqueQuittHonoCabinet as class   parametrageRubriqueQuittHonoCabinet no-undo.
    ghProc = lancementPgm("bail/quittancement/quittanceEncours.p", goCollectionHandlePgm).
    run getListeQuittance in ghProc(goCollection,
                                    input-output table ttQtt by-reference,
                                    input-output table ttRub by-reference).
    // renseigner les actions autorisées sur chaque rubrique
    voParametrageRubriqueQuittHonoCabinet = new parametrageRubriqueQuittHonoCabinet().
    for each ttQtt
      , each ttRub where ttRub.iNoQuittance = ttQtt.iNoQuittance:
        run isRubMod(voParametrageRubriqueQuittHonoCabinet,
                     ttRub.iNorubrique,
                     ttRub.iNoLibelleRubrique,
                     ttRub.cCodeGenre,
                     ttQtt.iNombreRubrique,
                     ttQtt.cdori,
                     output ttRub.lModificationAutorisee,
                     output ttRub.lSuppressionAutorisee,
                     output ttRub.lLienRubrique).
    end.
    delete object voParametrageRubriqueQuittHonoCabinet.
end procedure.

procedure getListeQuittanceHisto:
    /*------------------------------------------------------------------------------
      Purpose:
      Notes:   service externe
    ------------------------------------------------------------------------------*/
    define input parameter poCollection as class collection no-undo.
    define output parameter table for ttQtt.
    define output parameter table for ttRub.

    define variable viNumeroRole as int64 no-undo.

    empty temp-table ttQtt.
    empty temp-table ttRub.
    assign
        viNumeroRole          = poCollection:getInt64("iNumeroRole")
        goCollection          = poCollection
        goCollectionHandlePgm = new collection()
    .
    run chargeQuittanceHisto(viNumeroRole).
    suppressionPgmPersistent(goCollectionHandlePgm).

end procedure.

procedure chargeQuittanceHisto private:
    /*------------------------------------------------------------------------------
      Purpose: Chargement des quittances historisées (entête + rubriques)
      Notes:
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroRole as int64 no-undo.

    ghProc = lancementPgm("bail/quittancement/quittanceHistorique.p", goCollectionHandlePgm).
    run getListeQuittance in ghProc(piNumeroRole,
                                    output table ttQtt by-reference,
                                    output table ttRub by-reference).
end procedure.

procedure getListeSimpleQuittance:
    /*------------------------------------------------------------------------------
      Purpose: Liste des quittances historisées (entête simplifié uniquement)
               ou avis d'échéance (en cours) ou les 2
      Notes:   service externe
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeTrt    as character no-undo.
    define input  parameter poCollection as class collection no-undo.
    define output parameter table for ttListeQuittance.

    define variable vlTaciteReconduction         as logical no-undo.
    define variable vdaFinBail                   as date    no-undo.
    define variable vdaSortieLocataire           as date    no-undo.
    define variable vdaResiliationBail           as date    no-undo.
    define variable vdaFinQuittancementLocataire as date    no-undo.
    define variable vlPrendre                    as logical no-undo.
    define variable viNumeroRole                 as int64   no-undo.
    define buffer aquit for aquit.
    define buffer equit for equit.
    
    empty temp-table ttListeQuittance.
    assign
        viNumeroRole          = poCollection:getInt64("iNumeroRole")
        goCollection          = poCollection
        goCollectionHandlePgm = new collection()
    .
    if pcTypeTrt = "HISTO" or pcTypeTrt = ""
    then for each aquit no-lock
        where aquit.noLoc = viNumeroRole
        by aquit.msqtt by aquit.noqtt:
        create ttListeQuittance.
        outils:copyValidField(buffer aquit:handle, buffer ttListeQuittance:handle).
        assign
            ttListeQuittance.cTypeRole = {&TYPEROLE-locataire}
            ttListeQuittance.cNomTable = "aquit"
        .
    end.
    if pcTypeTrt = "ENCOURS" or pcTypeTrt = ""
    then
boucleEquit:
    for each equit no-lock
        where equit.noLoc = viNumeroRole
        by equit.msqtt by equit.noqtt:
        // Filtre (= Qtt locataire à prendre ?)
        run filtreLoc(equit.dtdpr, equit.noloc, output vlTaciteReconduction, output vdaFinBail, output vdaSortieLocataire, output vdaResiliationBail, output vlPrendre, output vdaFinQuittancementLocataire).
        if not vlPrendre then leave boucleEquit.

        create ttListeQuittance.
        outils:copyValidField(buffer equit:handle, buffer ttListeQuittance:handle).
        assign
            ttListeQuittance.cTypeRole = {&TYPEROLE-locataire}
            ttListeQuittance.cNomTable = "equit"
        .
    end.
end procedure.
