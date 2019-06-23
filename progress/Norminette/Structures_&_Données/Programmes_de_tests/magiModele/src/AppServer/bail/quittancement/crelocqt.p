/*-----------------------------------------------------------------------------
File        : crelocqt.p
Purpose     : Creation des quittances d'un locataire a partir des tables temporaires ttQtt et ttRub
Author(s)   : SP - 30/04/1996, GGA - 2018/06/11
Notes       : reprise de adb/quit/crelocqt.p
derniere revue: 2018/08/14 - phm: KO
        traductions
        traiter les todo
-----------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{bail/include/tbtmpqtt.i}
{bail/include/tbtmprub.i}
{application/include/glbsepar.i}

{outils/include/lancementProgramme.i}

define variable goCollectionHandlePgm as class collection no-undo.
define variable ghEquitCrud as handle no-undo.

procedure lancementCrelocqt:
    /*-------------------------------------------------------------------
    Purpose:
    Notes:  service externe
    ----------------------------------------------------------------------*/
    define input parameter piNumeroLocataire as int64 no-undo.
    define input-output parameter table for ttQtt.
    define input-output parameter table for ttRub.

    goCollectionHandlePgm = new collection().   
    ghEquitCrud = lancementPgm("crud/equit_CRUD.p", goCollectionHandlePgm).
    run creationQuittancelocataire (piNumeroLocataire).
    suppressionPgmPersistent(goCollectionHandlePgm).

end procedure.

procedure creationQuittancelocataire private:
    /*------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------*/
    define input parameter piNumeroLocataire as int64 no-undo.

    define variable viNumeroMandat    as int64     no-undo.
    define variable viCpRubQtt        as integer   no-undo.
    define variable vcCdModCalTVABail as character no-undo.

    define buffer tache for tache.  
    define buffer rubqt for rubqt.  

    viNumeroMandat = truncate(piNumeroLocataire / 100000, 0).
    for last tache no-lock 
        where tache.tpcon = {&TYPECONTRAT-bail}
          and tache.nocon = piNumeroLocataire
          and tache.tptac = {&TYPETACHE-TVABail}:
        vcCdModCalTVABail = tache.pdges.
    end.
    /* Suppression des quit. du locataire dans Equit */
    run deleteEquitSurLocataire in ghEquitCrud(piNumeroLocataire).
    if mError:erreur() then return.

    /* Parcours des quit. du locataire dans ttQtt */
    for each ttQtt
        where ttQtt.iNumeroLocataire = piNumeroLocataire:
        assign
            ttQtt.CRUD               = "C"
            ttQtt.iNumeroLocataire   = piNumeroLocataire
            ttQtt.CdCor              = "00001"                        /* texte sur Avis d'echeance */
            ttQtt.FgTrf              = false                          /* quittance non transferee */
            ttQtt.iNumeroMandat      = viNumeroMandat 
            ttQtt.cModeCalculTVABail = vcCdModCalTVABail              /* SY 30/11/2017 */
            viCpRubQtt               = 0
        .
        /* Parcours des quittances de ttRub */
        for each ttRub
            where ttRub.iNumeroLocataire = ttQtt.iNumeroLocataire
              and ttRub.iNoQuittance = ttQtt.iNoQuittance
        by ttRub.iNorubrique by ttRub.iNoLibelleRubrique:
            find first rubqt no-lock   
                where rubqt.cdrub = ttRub.iNorubrique
                  and rubqt.cdlib = ttRub.iNoLibelleRubrique no-error.
            assign
                viCpRubQtt              = viCpRubQtt + 1
                ttQtt.TbFam[viCpRubQtt] = (if available rubqt then rubqt.cdfam else ttRub.iFamille)  /* modif SY le 08/02/2013 */
                ttQtt.TbSfa[viCpRubQtt] = (if available rubqt then rubqt.cdsfa else ttRub.iSousFamille)  /* modif SY le 08/02/2013 */
                ttQtt.TbRub[viCpRubQtt] = ttRub.iNorubrique
                ttQtt.TbLib[viCpRubQtt] = ttRub.iNoLibelleRubrique
                ttQtt.TbGen[viCpRubQtt] = ttRub.cCodeGenre
                ttQtt.TbSig[viCpRubQtt] = ttRub.cCodeSigne
                ttQtt.TbDet[viCpRubQtt] = ttRub.CdDet
                ttQtt.TbQte[viCpRubQtt] = ttRub.dQuantite
                ttQtt.TbPro[viCpRubQtt] = ttRub.iProrata
                ttQtt.TbNum[viCpRubQtt] = ttRub.iNumerateurProrata
                ttQtt.TbDen[viCpRubQtt] = ttRub.iDenominateurProrata
                ttQtt.TbDt1[viCpRubQtt] = ttRub.daDebutApplication
                ttQtt.TbDt2[viCpRubQtt] = ttRub.daFinApplication
                ttQtt.TbFil[viCpRubQtt] = ttRub.daDebutApplicationPrecedente
                ttQtt.TbPun[viCpRubQtt] = ttRub.dPrixunitaire
                ttQtt.TbTot[viCpRubQtt] = ttRub.dMontantTotal
                ttQtt.TbMtq[viCpRubQtt] = ttRub.dMontantQuittance
            no-error.
            if error-status:error then do:
                mError:createError({&error}, "erreur sur mise a jour quittancement").     //gga todo a voir si il faut ce no-error et quel message dans ce cas   
                return.
            end.
        end.
    end.
    run setEquit in ghEquitCrud(table ttQtt by-reference).

end procedure.
