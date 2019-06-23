/*-----------------------------------------------------------------------------
File        : regulqtt.p
Purpose     : Module de calcul des rubriques de rappel/avoir pour régulariser un locataire qui aurait du sortir mais qui est finalement prolongé
Author(s)   : SY - 18/05/2007     GGA - 2018/06/13
Notes       : reprise de adb/src/quit/regulqtt.p
derniere revue: 2018/07/29 - phm:

01  18/10/2007  NP    1007/0022 Remplacement NoRefUse par NoRefGer
02  22/09/2008  NP    0608/0065 Gestion Mandats à 5 chiffres
03  18/02/2011  SY    0110/0230 nouveau champ prrub.noqtt pour Version > 10.29
04  12/01/2015  SY    Modif FIND FIRST equit pour ignorer avis ech périmés (Pb plantage PEC, equit non historisé)|
05  27/12/2017  SY    RETOUR ARRIERE SUR DECOUPAGE CARTURIS
-----------------------------------------------------------------------------*/
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/error.i}
{application/include/glbsepar.i}
{bail/include/tbtmpqtt.i}
{bail/include/tbtmprub.i}
{tache/include/tache.i}
{crud/include/prrub.i}
{bail/include/tbtmprub.i &nomtable=ttRubriqueRegularisation}
define temp-table ttTmpRub no-undo
    field norub as integer
    field nolib as integer
    field lbrub as character
    field vlmtq as decimal
index Ix_TmRub01 is unique primary norub nolib.

define variable goCollectionHandlePgm as class collection no-undo.
define variable goCollectionContrat   as class collection no-undo.
define variable ghProc          as handle    no-undo.
define variable gcTypeContrat   as character no-undo.
define variable giNumeroContrat as int64     no-undo.

{outils/include/lancementProgramme.i}            // fonctions lancementPgm, suppressionPgmPersistent

procedure lancementRegulqtt:
    /*------------------------------------------------------------------------
    Purpose :
    Notes   : service externe
    ------------------------------------------------------------------------*/
    define input parameter poCollectionContrat as class collection no-undo.
    define input parameter table for ttError.
    define input-output parameter table for ttRubriqueRegularisation.

    assign
        gcTypeContrat         = poCollectionContrat:getCharacter("cTypeContrat")
        giNumeroContrat       = poCollectionContrat:getInt64("iNumeroContrat")
        goCollectionContrat   = poCollectionContrat
        goCollectionHandlePgm = new collection()
    .
    run trtRegulqtt.
    suppressionPgmPersistent(goCollectionHandlePgm).

end procedure.

procedure trtRegulqtt private:
    /*------------------------------------------------------------------------
    Purpose :
    Notes   :
    ------------------------------------------------------------------------*/
    define variable viNumeroQuittance       as integer   no-undo.
    define variable viMoisTrtGI             as integer   no-undo.
    define variable vcListeRubriqueErreur   as character no-undo.
    define variable vcLstRubQt              as character no-undo.
    define variable vdaAncienneDateSortie   as date      no-undo.
    define variable vdaFinRegul             as date      no-undo.
    define variable vcInfoTache             as character no-undo.
    define variable viMoisEchu              as integer   no-undo.

    define buffer aquit for aquit.
    define buffer equit for equit.
    define buffer rubqt for rubqt.
    define buffer prrub for prrub.
    define buffer tache for tache.

    /* Controles préliminaires */
    /* Facture de sortie */
    if can-find(first iftsai no-lock
                where iftsai.soc-cd      = integer(mToken:crefGerance)
                  and iftsai.etab-cd     = integer(substring(string(giNumeroContrat,"9999999999"), 1, 5, "character"))
                  and iftsai.tprole      = 19
                  and iftsai.sscptg-cd   = substring(string(giNumeroContrat, "9999999999"), 6, 5, "character")
                  and iftsai.typefac-cle = "Sortie") then do:
        mError:createError({&information}, 1000845).   //Suppression date de sortie. Vous avez supprimé la date de sortie du locataire mais il ne peut y avoir de régularisation automatique car vous avez fait la facture de sortie
        return.
    end.

    /* Recherche de la dernière quittance du locataire pour trouver l'ancienne date de sortie */
    {&_proparse_ prolint-nowarn(use-index)}
    for last aquit no-lock
        where aquit.noLoc = giNumeroContrat
          and aquit.fgfac = false
        use-index ix_aquit03:            // noloc, msqtt
        vdaAncienneDateSortie = aquit.dtfin.
    end.
    /* Recherche quittance en cours */
    viMoisEchu = goCollectionContrat:getInteger("iMoisEchu").
    find first equit no-lock
        where equit.noloc = giNumeroContrat
          and equit.msqtt >= viMoisEchu no-error.     /* AJout SY le 12/01/2015 pour ne pas prendre les Avis d'échéance périmés (Pb plantage PEC, equit non historisé) */
    if not available equit then do:
        /* ERREUR : le locataire %1 n'a pas de quittance... */
        mError:createErrorGestion({&error}, 100837, substitute("&2&1", separ[1], giNumeroContrat)).
        return.
    end.
    assign
        viNumeroQuittance = equit.noqtt
        viMoisTrtGI       = equit.msqtt
        vdaFinRegul       = equit.dtdpr - 1  /* date de fin de regul */
        ghProc            = lancementPgm("adb/cpta/chgloypr.p", goCollectionHandlePgm)
    .
    /* Calcul des Rappels/Avoir */
    empty temp-table ttTmpRub.
    run lancementChgloypr in ghProc(goCollectionContrat, ?, "RAZDTSOR", table ttError, output table ttTmpRub).
  
    if mError:erreur() then return.
    if not can-find (first ttTmpRub) then return.

    empty temp-table ttQtt.
    empty temp-table ttRub.

    /* Chargement d'une quittance dans ttQtt et ttRub */
    ghProc = lancementPgm("bail/quittancement/quittanceEncours.p", goCollectionHandlePgm).
    run getQuittance in ghProc(goCollectionContrat, viNumeroQuittance, input-output table ttQtt by-reference, input-output table ttRub by-reference).
    if mError:erreur() then return.

    /* Positionnement sur la quittance */
    find first ttQtt
        where ttQtt.iNumeroLocataire = giNumeroContrat
          and ttQtt.iNoQuittance = viNumeroQuittance no-error.
    if not available ttQtt then do:
        /* Erreur au chargement de la quittance %1 du locataire %2 */
        mError:createErrorGestion({&error}, 104131, substitute("&2&1&3", separ[1], viNumeroQuittance, giNumeroContrat)).
        return.
    end.
    /* Recherche si rub rappel/avoir existent déjà */
    vcListeRubriqueErreur = "".
    for each ttTmpRub
      , first ttRub
        where ttRub.iNumeroLocataire = giNumeroContrat
          and ttRub.iNoQuittance = viNumeroQuittance
          and ttRub.iNorubrique = ttTmpRub.norub
          and ttRub.iNoLibelleRubrique = ttTmpRub.nolib:
        vcListeRubriqueErreur = substitute("&1,&2.&3", vcListeRubriqueErreur, string(ttTmpRub.norub, "999"), string(ttTmpRub.nolib, "99")).
    end.
    vcListeRubriqueErreur = trim(vcListeRubriqueErreur, ",").
    if vcListeRubriqueErreur > "" then do:
        mError:createError({&information}, 1000846, vcListeRubriqueErreur).   //Suppression date de sortie. Vous avez supprimé la date de sortie du locataire mais il ne peut y avoir de régularisation automatique car des rubriques de rappel/avoir existent déjà (&1)
        return.
    end.
    /* Création des rubriques de régul */
    /*Init dates d'application       */
    empty temp-table ttRubriqueRegularisation.    //gga utiliser cette table pour echange entre regulqtt et chgloypr + affichage en retour ihm mais pour le moment manque le montant
    for each ttTmpRub
      , first rubqt no-lock
        where rubqt.cdrub = ttTmpRub.norub
          and rubqt.cdlib = ttTmpRub.nolib:
        ghProc = lancementPgm("bail/quittancement/majrubtm.p", goCollectionHandlePgm).
        run lancementMajrubtm in ghProc(
            goCollectionContrat,
            viNumeroQuittance,
            ttTmpRub.norub,
            '01',                 // creation
            rubqt.cdfam,
            rubqt.cdsfa,
            ttTmpRub.nolib,
            ttTmpRub.lbrub,
            rubqt.CdGen,
            rubqt.CdSig,
            '00000',              // cddet direct/détaillé (?)
            0,
            0,
            ttTmpRub.vlmtq,
            0,                    // cdpro : non proraté
            ttQtt.iNumerateurProrata,
            ttQtt.iDenominateurProrata,
            ttTmpRub.vlmtq,
            ttQtt.daDebutPeriode,
            ttQtt.daFinPeriode,
            '',
            0,                    // nolig
            ttTmpRub.nolib,
            input-output table ttQtt by-reference,
            input-output table ttRub by-reference
        ).
        if mError:erreur() then return.

        for first ttRub
            where ttRub.iNumeroLocataire = giNumeroContrat
              and ttRub.iNoQuittance = viNumeroQuittance
              and ttRub.iNorubrique = ttTmpRub.norub
              and ttRub.iNoLibelleRubrique = ttTmpRub.nolib:
            create ttRubriqueRegularisation.
            buffer-copy ttRub to ttRubriqueRegularisation. 
        end.
        
        /* SY le 21/05/2007 : cas particulier rub MEH 111 et 114 calculées => régul forcée sur la rubrique 107.01 */
        if ttTmpRub.norub = 107 then do:
            empty temp-table ttPrrub.
            create ttPrrub.
            find first prrub no-lock
                where prrub.cdrub = ttTmpRub.norub
                  and prrub.cdlib = ttTmpRub.nolib
                  and prrub.noloc = giNumeroContrat
                  and prrub.msqtt = ttQtt.iMoisTraitementQuitt
                  and (prrub.noqtt = 0 or prrub.noqtt = ttQtt.iNoQuittance) no-error.    /* SY 0110/0230 - version > 10.29  */
            assign
                ttPrrub.cdrub = ttTmpRub.norub
                ttPrrub.cdlib = ttTmpRub.nolib
                ttPrrub.noloc = giNumeroContrat
                ttPrrub.msqtt = ttQtt.iMoisTraitementQuitt
                ttPrrub.noqtt = ttQtt.iNoQuittance
            .
            if available prrub
            then assign
                ttPrrub.CRUD        = "U"
                ttPrrub.rRowid      = rowid(prrub)
                ttPrrub.dtTimestamp = datetime(prrub.dtmsy, prrub.hemsy)
            .
            else ttPrrub.CRUD = "C".
            assign
                ttPrrub.lbrub = ttTmpRub.lbrub
                ttPrrub.nome1 = rubqt.nome1
                ttPrrub.cdfam = rubqt.cdfam
                ttPrrub.cdsfa = rubqt.cdsfa
                ttPrrub.cdaff = "00001"
                ttPrrub.cdlng = 0
                ttPrrub.cdgen = rubqt.cdgen
                ttPrrub.cdsig = rubqt.cdsig
                ttPrrub.cdirf = rubqt.prg05
                ttPrrub.lbcab = ""
                ghProc        = lancementPgm("crud/prrub_CRUD.p", goCollectionHandlePgm)
            .
            run setPrrub in ghProc(table ttPrrub by-reference).
            if mError:erreur() then return.
        end.
    end.

    /* Mise à jour de Equit */
    ghProc = lancementPgm("bail/quittancement/majlocqt.p", goCollectionHandlePgm).
    run lancementMajlocqt in ghProc (input-output table ttQtt by-reference, input-output table ttRub by-reference).
    if mError:erreur() then return.

    /* mise à jour Tache.lbdiv2 */
    vcLstRubQt = "".
    for each ttTmpRub:
        vcLstRubQt = substitute("&1&2&3&4&3&5&36&7", vcLstRubQt, ttTmpRub.norub, separ[3], ttTmpRub.nolib, ttTmpRub.lbrub, string(ttTmpRub.vlmtq * 100 , "->>>>>>>>>999"), separ[1]).
    end.
    vcInfoTache = substitute("&1&2&3&2&4&2&5&2&6", string(vdaAncienneDateSortie, "99/99/9999"), separ[2], vdaFinRegul, viNumeroQuittance, viMoisTrtGI, vcLstRubQt).

    for last tache no-lock
       where tache.tptac = {&TYPETACHE-quittancement}
         and tache.tpcon = gcTypeContrat
         and tache.nocon = giNumeroContrat:
        create ttTache.
        assign
            ttTache.tpcon       = tache.tpcon
            ttTache.nocon       = tache.nocon
            ttTache.tptac       = tache.tptac
            ttTache.notac       = tache.notac
            ttTache.CRUD        = "U"
            ttTache.rRowid      = rowid(tache)
            ttTache.dtTimestamp = datetime(tache.dtmsy, tache.hemsy)
            ttTache.lbdiv2      = vcInfoTache
            ghProc              = lancementPgm("crud/tache_CRUD.p", goCollectionHandlePgm)
        .
        run setTache in ghProc(table ttTache by-reference).
        if mError:erreur()
        then do:
            mError:createError({&error}, 103807).
            return.
        end.
    end.

end procedure.
