/*-----------------------------------------------------------------------------
File        : majlocqt.p
Purpose     : Mise a jour des quittances A partir des tables temporaires ttQtt et ttRub, mise a jour de equit 
Author(s)   : SY - 10/01/1996      GGA - 2018/06/18
Notes       : reprise de adb/quit/MajLocQt.p
derniere revue: 2018/08/14 - phm: 

01  18/01/1996  SP    Ajout champ nbedt à ttQtt
02  19/01/1996  TM    Ajout de la recuperation des champs 'nbnum','nbden'.
03  22/01/1996  TM    Remplacement de 'tpbai' par 'ntbai'.
04  25/01/1996  PL    Correction de la mise a jour de ttRub.
05  14/03/1997  SY    TRANSFERTS : Ajout du champ FgTrf dans equit
06  01/09/1998  SY    Correction boucle raz tableaux : 14 -> 20
07  01/09/1998  SY    Ajout Maj Calendrier d'‚volution des loyers
08  07/06/1999  JC    Plus de mise a jour du calendrier
09  30/07/1999  AF    Sauvegarde de la quittance avant modification pour gestion correcte de equit.fgtrf
10  21/07/2000  PL    Gestion Double affichage Euro/Devise.
11  06/10/2000  JC    Modification de l'heure et de la date de modif si la quittance a ete modifiee (Nouvelle version de la fiche gerance)
12  22/03/2001  AD    0301/0576: si pas dans devise mandat pas de mise à jour ttQtt.cdmaj = 0.
13  18/04/2001  NO    Correction du type de mandat: remplacement de 01033 par 01030
14  23/09/2002  SY    Ajout maj zones nomdt,dtmsy,hemsy,cdmsy
15  06/04/2007  PL    0307/0413:pb changement rubrique charge qui mettait à jour la date de fin d'application de la rubrique sur la quittance précédente et du coup retopait cette dernière
16  16/09/2008  SY    0608/0065 Gestion mandats 5 chiffres
17  04/09/2009  SY    0909/0021 recalcul du nombre réel de rubriques pour maj equit.nbrub
18  22/01/2010  SY    1108/0443 Ajout suppression prrub si on a supprimé la rubrique
19  18/02/2011  SY    0110/0230 nouveau champ prrub.noqtt pour Version > 10.29
20  30/07/2012  PL    ajout except noint suite def ttQtt like equit dans tbtmpqtt.i
21  28/11/2017  SY    #9211 ajout NO-UNDO TEMP-TABLE Savequit
22  30/11/2017  SY    mémoriser mode de calcul de la TVA du bail dans equit.lbdiv3
23  13/02/2018  PL    #14273 : Message de debug intempestif car flag fgDebug resté à YES
-----------------------------------------------------------------------------*/
{preprocesseur/referenceClient.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}

{oerealm/include/instanciateTokenOnModel.i}         // Doit être positionnée juste après using

{application/include/glbsepar.i}
{bail/include/tbtmpqtt.i}
{bail/include/tbtmprub.i}
{crud/include/equit.i}
{crud/include/equit.i &nomtable=ttSaveEquit}
{crud/include/prrub.i}

{outils/include/lancementProgramme.i}               // fonctions lancementPgm, suppressionPgmPersistent

define variable goCollectionHandlePgm as class collection no-undo.
define variable ghProc  as handle  no-undo.
define variable glDebug as logical no-undo.

procedure lancementMajlocqt:
    /*------------------------------------------------------------------------
    Purpose :
    Notes   : service externe
    ------------------------------------------------------------------------*/
    define input-output parameter table for ttQtt.
    define input-output parameter table for ttRub.

    goCollectionHandlePgm = new collection().
    run trtMajlocqt.
    suppressionPgmPersistent(goCollectionHandlePgm).

end procedure.

procedure trtMajlocqt private:
    /*------------------------------------------------------------------------
    Purpose :
    Notes   : 
    ------------------------------------------------------------------------*/
    define variable viI                  as integer   no-undo.
    define variable viNumeroMandat       as int64     no-undo.
    define variable viNombreRubrique     as integer   no-undo.
    define variable vcModCalTVABail      as character no-undo.
    define variable viNumeroInterneEquit as int64     no-undo.
  
    define buffer tache for tache.  
    define buffer equit for equit.  
    define buffer prrub for prrub.
  
    /*--> Parcours des quittances de ttQtt qui ont ete modifiees */
    for each ttQtt 
        break by ttQtt.iNumeroLocataire:

        if first-of (ttQtt.iNumeroLocataire) then do:  /* SY 30/11/2017 */
            /* Tache TVA du bail */
            vcModCalTVABail = "".
            for last tache no-lock 
                where tache.tpcon = {&TYPECONTRAT-Bail}
                  and tache.nocon = ttQtt.iNumeroLocataire
                  and tache.tptac = {&TYPETACHE-TVABail}:
                vcModCalTVABail = tache.pdges.
            end.
            /*--> Le mode de calcul TVA du bail a-t-il changé ?  */
            for first equit no-lock 
                where equit.noloc = ttQtt.iNumeroLocataire
                  and equit.noqtt = ttQtt.iNoQuittance:
                if entry(1, equit.lbdiv3, separ[3]) <> vcModCalTVABail then ttQtt.CdMaj = 1.
            end.              
        end.
        if glDebug then mLogger:writeLog(0, substitute("ttQtt : noloc = &1 noqtt = &2 Flag modifié (ttQtt.CdMaj) = &3 vcModCalTVABail = &4",
                                             ttQtt.iNumeroLocataire, ttQtt.iNoQuittance, ttQtt.CdMaj, vcModCalTVABail)).
        if ttQtt.CdMaj = 0 then next.

        /*--> Recherche de la quittance dans equit */
        find first equit no-lock
             where equit.noloc = ttQtt.iNumeroLocataire
               and equit.noqtt = ttQtt.iNoQuittance no-error.
        /*--> Cas qui ne devrait jamais arriver */
        if not available equit then do: 
            mError:createError({&error}, 106945). //Au moins 1 enregistrement Equit à modifier non trouvé.
            return.
        end.
        assign
            viNumeroMandat       = truncate(ttQtt.iNumeroLocataire / 100000, 0)
            viNumeroInterneEquit = equit.noint
        .
        /*--> Sauvegarde de la quittance avant modification */
        empty temp-table ttSaveEquit.
        empty temp-table ttEquit.
        create ttSaveEquit.
        outils:copyValidField(buffer equit:handle, buffer ttSaveEquit:handle).
        create ttEquit.
        outils:copyValidField(buffer ttQtt:handle, buffer ttEquit:handle).
        if integer(mToken:cRefPrincipale) = {&REFCLIENT-MANPOWER} 
        then ttEquit.fgTrf = false.
        if ttEquit.lbdiv3 = "" then ttEquit.lbdiv3 = "" + separ[3].       /* SY 30/11/2017 : mémoriser mode de calcul de la TVA du bail */
        assign
            ttEquit.CRUD        = "U"
            ttEquit.dtTimestamp = datetime(equit.dtmsy, equit.hemsy)
            ttEquit.rRowid      = rowid(equit)
            ttEquit.nomdt       = viNumeroMandat
            ttEquit.MtQtt       = ttQtt.dMontantQuittance
            entry(1, ttEquit.lbdiv3, separ[3]) = vcModCalTVABail
            /*--> Mise a blanc des tableaux */
            ttEquit.TbFam     = 0
            ttEquit.TbSfa     = 0
            ttEquit.TbRub     = 0
            ttEquit.TbLib     = 0
            ttEquit.TbGen     = ""
            ttEquit.TbSig     = ""
            ttEquit.TbDet     = ""
            ttEquit.TbQte     = 0
            ttEquit.TbPro     = 0
            ttEquit.TbNum     = 0
            ttEquit.TbDen     = 0
            ttEquit.TbDt1     = ?
            ttEquit.TbDt2     = ?
            ttEquit.TbFil     = ""
            ttEquit.TbMtq     = 0
            ttEquit.TbPun     = 0
            ttEquit.TbTot     = 0
            ttEquit.TbMtq-dev = 0
            ttEquit.TbPun-dev = 0
            ttEquit.TbTot-dev = 0
            viI               = 1
            viNombreRubrique  = 0
        .
        /*--> Parcours des quittances de ttRub */
        for each ttRub  
            where ttRub.iNumeroLocataire = ttQtt.iNumeroLocataire
              and ttRub.iNoQuittance = ttQtt.iNoQuittance:
            assign
                viNombreRubrique   = viNombreRubrique + 1
                ttEquit.TbFam[viI] = ttRub.iFamille
                ttEquit.TbSfa[viI] = ttRub.iSousFamille
                ttEquit.TbRub[viI] = ttRub.iNorubrique
                ttEquit.TbLib[viI] = ttRub.iNoLibelleRubrique
                ttEquit.TbGen[viI] = ttRub.cCodeGenre
                ttEquit.TbSig[viI] = ttRub.cCodeSigne
                ttEquit.TbDet[viI] = ttRub.cdDet
                ttEquit.TbQte[viI] = ttRub.dQuantite
                ttEquit.TbPro[viI] = ttRub.iProrata
                ttEquit.TbNum[viI] = ttRub.iNumerateurProrata
                ttEquit.TbDen[viI] = ttRub.iDenominateurProrata
                ttEquit.TbDt1[viI] = ttRub.daDebutApplication
                ttEquit.TbDt2[viI] = ttRub.daFinApplication
                ttEquit.TbFil[viI] = ttRub.daDebutApplicationPrecedente
                ttEquit.TbMtq[viI] = ttRub.dMontantQuittance
                ttEquit.TbPun[viI] = ttRub.dPrixunitaire
                ttEquit.TbTot[viI] = ttRub.dMontantTotal
                viI                = viI + 1
            .
        end. /* Parcours de ttRub */
        
        if glDebug and equit.nbrub <> viNombreRubrique 
        then mLogger:writeLog (0, substitute("Locataire &1 mois &2 maj nbrub = &3 -> &4",
                                  equit.noloc, equit.msqtt, equit.nbrub, viNombreRubrique)).
        assign
            ttEquit.nbrub = viNombreRubrique
            /*--> Reinitialisation du code de mise a jour */
            ttQtt.CdMaj   = 0
            ghProc        = lancementPgm("crud/equit_CRUD.p", goCollectionHandlePgm)
        .
        run setEquit in ghProc(table ttEquit by-reference).
        if mError:erreur() then return.

        /*--> On compare la quittance modifiée et celle sauvegardée */
        find first equit no-lock
            where equit.noint = viNumeroInterneEquit no-error.
        find first ttSaveEquit
            where ttSaveEquit.noint = viNumeroInterneEquit no-error.
        if available ttSaveEquit and available equit
        and outils:bufferCompare(buffer ttSaveEquit:handle, buffer equit:handle, "nomdt,tbdt2,nbrub") > "" then do:
            empty temp-table ttEquit.
            create ttEquit.
            outils:copyValidField(buffer equit:handle, buffer ttEquit:handle).
            assign
                ttEquit.noloc       = equit.noloc 
                ttEquit.noqtt       = equit.noqtt
                ttEquit.CRUD        = "U"
                ttEquit.dtTimestamp = datetime(equit.dtmsy, equit.hemsy)
                ttEquit.rRowid      = rowid(equit)
                ttEquit.fgtrf       = false
                ghProc              = lancementPgm("crud/equit_CRUD.p", goCollectionHandlePgm)
            .
            run setEquit in ghProc(table ttEquit by-reference).
            if mError:erreur() then return.
        end.
        empty temp-table ttPrrub.
        for each prrub no-lock
            where prrub.noloc = equit.noloc
              and prrub.msqtt = equit.msqtt
              and (prrub.noqtt = 0 or prrub.noqtt = equit.noqtt)   /* SY 0110/0230 - version > 10.29  */
              and not can-find(first ttRub 
                               where ttRub.iNumeroLocataire = ttQtt.iNumeroLocataire
                                 and ttRub.iNoQuittance = ttQtt.iNoQuittance
                                 and ttRub.iNorubrique = prrub.cdrub 
                                 and ttRub.iNoLibelleRubrique = prrub.cdlib):
            create ttPrrub.
            assign 
                ttPrrub.cdrub       = prrub.cdrub
                ttPrrub.cdlib       = prrub.cdlib
                ttPrrub.noloc       = prrub.noloc
                ttPrrub.msqtt       = prrub.msqtt
                ttPrrub.noqtt       = prrub.noqtt
                ttPrrub.CRUD        = "D"
                ttPrrub.dtTimestamp = datetime(prrub.dtmsy, prrub.hemsy)
                ttPrrub.rRowid      = rowid(prrub)
            .
        end.
        ghProc = lancementPgm("crud/prrub_CRUD.p", goCollectionHandlePgm).
        run setPrrub in ghProc(table ttPrrub by-reference).
    end.
end procedure.
