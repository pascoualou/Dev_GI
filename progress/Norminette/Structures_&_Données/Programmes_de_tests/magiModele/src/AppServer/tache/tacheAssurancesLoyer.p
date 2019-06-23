/*-----------------------------------------------------------------------------
File        : tacheAssurancesLoyers.p
Purpose     : tache assurances loyers (04342)
Author(s)   : OFA - 2017/12/12
Notes       : a partir de adb/tach/prmmtass.p
Derniere revue: 2018/05/24 - ofa: OK
-----------------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}

using parametre.syspg.parametrageTache.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{tache/include/tacheAssurancesLoyer.i}
{application/include/combo.i}
{application/include/error.i}

function messageErreur returns character private(pcTypeAssurance as character, pcNumeroAssurance as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    return substitute(outilTraduction:getLibelle(1000391),     // Le barême d'assurance &1 n°&2 n'existe pas
                      if pcTypeAssurance > ""
                      then outilTraduction:getLibelleProg("O_CLC", pcTypeAssurance)
                      else outilTraduction:getLibelle(106209), // Garantie Spéciale
                      pcNumeroAssurance).
end function.

function libelleAssurance returns character private(pcCodeAssurance as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define buffer ccptcol for ccptcol.
    define buffer ifour   for ifour.

    /* Recherche de la fiche fournisseur */
    for first ccptcol no-lock
        where ccptcol.soc-cd = integer(mToken:cRefGerance)
          and ccptcol.tprole = 12
      , first ifour no-lock
        where ifour.soc-cd   = ccptcol.soc-cd
          and ifour.coll-cle = ccptcol.coll-cle
          and ifour.cpt-cd   = pcCodeAssurance:
        return replace(trim(ifour.nom), ",", ";").
    end.
    return "".
end function.

function controleExistence returns logical private(pcTypeAssurance as character, pcNumeroAssurance as character):
    /*------------------------------------------------------------------------------
    Purpose: Vérifie si l'enregistrement dans garan existe ou s'il ne faut pas contrôler car valeur zéro (non saisie) 
    Notes:
    ------------------------------------------------------------------------------*/
    if integer(pcNumeroAssurance) <> 0
    and not can-find(first garan no-lock
                     where garan.tpctt = pcTypeAssurance
                       and garan.nobar = 0
                       and garan.noctt = integer(pcNumeroAssurance))
    then do:
        mError:createError({&error}, messageErreur(pcTypeAssurance,pcNumeroAssurance)).
        return false.
    end.
    return true.
end function.

procedure initTacheAssurancesLoyer:
    /*------------------------------------------------------------------------------
     Purpose: Initialisation de la tâche Assurances loyer à partir des paramètres client
     Notes: Service externe
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroMandat   as integer   no-undo.
    define input  parameter pcTypeTraitement as character no-undo.
    define output parameter table for ttTacheAssurancesLoyer.

    define buffer ctrat for ctrat.

    for first ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and ctrat.nocon = piNumeroMandat:
        create ttTacheAssurancesLoyer.
        assign
            ttTacheAssurancesLoyer.CRUD                             = if pcTypeTraitement = "INITIALISATION" then 'R' else 'C'
            ttTacheAssurancesLoyer.cTypeContrat                     = {&TYPECONTRAT-mandat2Gerance}
            ttTacheAssurancesLoyer.iNumeroContrat                   = piNumeroMandat
            ttTacheAssurancesLoyer.cTypeTache                       = {&TYPETACHE-AssurancesLoyer}
            ttTacheAssurancesLoyer.cNumGarantieLoyerBauxCom         = "00"
            ttTacheAssurancesLoyer.cNumGarantieLoyerBauxHab         = "00"
            ttTacheAssurancesLoyer.cNumProtectionJuridiqueBauxCom   = "00"
            ttTacheAssurancesLoyer.cNumProtectionJuridiqueBauxHab   = "00"
            ttTacheAssurancesLoyer.cNumGarantieRisqueLocatifBauxCom = "00"
            ttTacheAssurancesLoyer.cNumGarantieRisqueLocatifBauxHab = "00"
            ttTacheAssurancesLoyer.cNumCarenceLocativeBauxCom       = "00"
            ttTacheAssurancesLoyer.cNumCarenceLocativeBauxHab       = "00"
            ttTacheAssurancesLoyer.cNumGarantieSpeciale             = "00"
        .
    end.
end procedure.

procedure miseAJourTableTache private:
    /*------------------------------------------------------------------------------
     Purpose: Mise à jour de la table tache à partir du dataset
     Notes:
    ------------------------------------------------------------------------------*/
    define variable vhproc as handle  no-undo.
    define variable vrttTacheAssurancesLoyer as rowid no-undo.
    define buffer cttac for cttac.

    vrttTacheAssurancesLoyer = rowid(ttTacheAssurancesLoyer).
    run tache/tache.p persistent set vhproc.
    run getTokenInstance in vhproc(mToken:JSessionId).
    run setTache in vhproc(table ttTacheAssurancesLoyer by-reference).
    run destroy in vhproc.
    if mError:erreur() then return.

    // Mise à jour table cttac: utilisation de la table ttTacheAssurancesLoyer pour éviter de devoir créer un ttCttac sachant que les champs à mettre à jour sont identiques
    for first ttTacheAssurancesLoyer
        where rowid(ttTacheAssurancesLoyer) = vrttTacheAssurancesLoyer
      , first cttac no-lock
        where cttac.tpcon = ttTacheAssurancesLoyer.cTypeContrat
          and cttac.nocon = ttTacheAssurancesLoyer.iNumeroContrat
          and cttac.tptac = ttTacheAssurancesLoyer.cTypeTache:
        assign
            ttTacheAssurancesLoyer.dtTimestamp = datetime(cttac.dtmsy, cttac.hemsy)
            ttTacheAssurancesLoyer.rRowid      = rowid(cttac)
        .
    end.
    run adblib/cttac_CRUD.p persistent set vhproc.
    run getTokenInstance in vhproc(mToken:JSessionId).
    run setCttac in vhproc(table ttTacheAssurancesLoyer by-reference).
    run destroy in vhproc.
end procedure.

procedure setTacheAssurancesLoyer:
    /*------------------------------------------------------------------------------
    Purpose: Update de la tâche CRG
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter table for ttTacheAssurancesLoyer.
    define input parameter table for ttError.

    for first ttTacheAssurancesLoyer
        where lookup(ttTacheAssurancesLoyer.CRUD, "C,U,D") > 0:
        run controlesAvantValidation.
        if mError:erreur() then return.

        run miseAJourTableTache.
    end.

end procedure.

procedure getTacheAssurancesLoyer:
    /*------------------------------------------------------------------------------
    Purpose: Lecture de la tâche Assurances loyer
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroMandat   as int64     no-undo.
    define output parameter table for ttTacheAssurancesLoyer.

    define buffer tache     for tache.

    empty temp-table ttTacheAssurancesLoyer.

    for first tache no-lock
        where tache.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and tache.nocon = piNumeroMandat
          and tache.tptac = {&TYPETACHE-AssurancesLoyer}
          and tache.notac = 1:
        create ttTacheAssurancesLoyer.
        outils:copyValidField(buffer tache:handle, buffer ttTacheAssurancesLoyer:handle).
    end.

end procedure.

procedure initComboTacheAssurancesLoyer:
    /*------------------------------------------------------------------------------
    Purpose: Chargement des combos de l'écran depuis la vue
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define output parameter table for ttcombo.

    run chargeCombo.

end procedure.

procedure chargeCombo private:
    /*------------------------------------------------------------------------------
    Purpose: Chargement de toutes les combos de l'écran
    Notes  : 
    ------------------------------------------------------------------------------*/
    define variable viNumero as integer no-undo.
    define buffer ifdtpfac for ifdtpfac.
    define buffer ifdparam for ifdparam.
    define buffer garan    for garan.

    create ttCombo.
    assign
        viNumero          = viNumero + 1
        ttCombo.iSeqId    = viNumero
        ttCombo.cCode     = "00"
        ttCombo.cLibelle  = "00 - " + outilTraduction:getLibelle(700140) /* 00 - Sans */
        ttCombo.cNomCombo = "GARANTIELOYER"
    .
    for each garan no-lock
        where garan.tpctt = {&TYPECONTRAT-GarantieLoyer}
          and garan.nobar = 0:
        create ttCombo.
        assign
            viNumero          = viNumero + 1
            ttCombo.iSeqId    = viNumero
            ttCombo.cCode     = string(garan.noctt, "99")
            ttCombo.cLibelle  = substitute("&1 - &2", ttCombo.cCode, libelleAssurance(if garan.noctt <> 1 or garan.lbdiv > "" then garan.lbdiv else "00000"))
            ttCombo.cNomCombo = "GARANTIELOYER"
        .
    end.

    create ttCombo.
    assign
        viNumero          = viNumero + 1
        ttCombo.iSeqId    = viNumero
        ttCombo.cCode     = "00"
        ttCombo.cLibelle  = "00 - " + outilTraduction:getLibelle(700140) /* 00 - Sans */
        ttCombo.cNomCombo = "PROTECTIONJURIDIQUE"
    .
    for each garan no-lock
        where garan.tpctt = {&TYPECONTRAT-ProtectionJuridique}
          and garan.nobar = 0:
        create ttCombo.
        assign
            viNumero          = viNumero + 1
            ttCombo.iSeqId    = viNumero
            ttCombo.cCode     = string(garan.noctt, "99")
            ttCombo.cLibelle  = substitute("&1 - &2", ttCombo.cCode, libelleAssurance(if garan.noctt <> 1 or garan.lbdiv > "" then garan.lbdiv else "00000"))
            ttCombo.cNomCombo = "PROTECTIONJURIDIQUE"
        .
    end.

    create ttCombo.
    assign
        viNumero          = viNumero + 1
        ttCombo.iSeqId    = viNumero
        ttCombo.cCode     = "00"
        ttCombo.cLibelle  = "00 - " + outilTraduction:getLibelle(700140) /* 00 - Sans */
        ttCombo.cNomCombo = "GARANTIERISQUELOCATIF"
    .
    for each garan no-lock
        where garan.tpctt = {&TYPECONTRAT-GarantieRisqueLocatif}
          and garan.nobar = 0:
        create ttCombo.
        assign
            viNumero          = viNumero + 1
            ttCombo.iSeqId    = viNumero
            ttCombo.cCode     = string(garan.noctt, "99")
            ttCombo.cLibelle  = substitute("&1 - &2", ttCombo.cCode, libelleAssurance(if garan.noctt <> 1 or garan.lbdiv > "" then garan.lbdiv else "00000"))
            ttCombo.cNomCombo = "GARANTIERISQUELOCATIF"
        .
    end.

    create ttCombo.
    assign
        viNumero          = viNumero + 1
        ttCombo.iSeqId    = viNumero
        ttCombo.cCode     = "00"
        ttCombo.cLibelle  = "00 - " + outilTraduction:getLibelle(700140) /* 00 - Sans */
        ttCombo.cNomCombo = "VACANCELOCATIVE"
    .
    for each garan no-lock
        where garan.tpctt = {&TYPECONTRAT-VacanceLocative}
          and garan.nobar = 0:
        create ttCombo.
        assign
            viNumero          = viNumero + 1
            ttCombo.iSeqId    = viNumero
            ttCombo.cCode     = string(garan.noctt,"99")
            ttCombo.cLibelle  = substitute("&1 - &2", string(garan.noctt, "99"), libelleAssurance(garan.cdass))
            ttCombo.cNomCombo = "VACANCELOCATIVE"
        .
    end.

    create ttCombo.
    assign
        viNumero          = viNumero + 1
        ttCombo.iSeqId    = viNumero
        ttCombo.cCode     = "00"
        ttCombo.cLibelle  = "00 - " + outilTraduction:getLibelle(700140) /* 00 - Sans */
        ttCombo.cNomCombo = "GARANTIESPECIALE"
    .
    for first ifdparam no-lock
        where ifdparam.soc-dest = integer(mToken:cRefGerance)
      , each garan no-lock
        where garan.tpctt >= {&TYPECONTRAT-GarantiePierre}
          and garan.tpctt <= {&TYPECONTRAT-DerniereGarantieSpeciale} //Les garanties spéciales sont codées de 01020 pour la garantie Pierre à 01029 
          and garan.nobar = 0
      , first ifdtpfac no-lock
        where ifdtpfac.soc-cd = ifdparam.soc-cd
          and ifdtpfac.typefac-cle = substring(garan.tpctt, 4, 2, "character"):
        create ttCombo.
        assign
            viNumero          = viNumero + 1
            ttCombo.iSeqId    = viNumero
            ttCombo.cCode     = garan.tpctt
            ttCombo.cLibelle  = substitute("&1 - &2", ifdtpfac.typefac-cle, ifdtpfac.lib)
            ttCombo.cNomCombo = "GARANTIESPECIALE"
        .
    end.

end procedure.

procedure controlesAvantValidation private:
    /*------------------------------------------------------------------------------
    Purpose: Contrôle des informations saisies par l'utilisateur avant de faire l'update 
    Notes  : 
    ------------------------------------------------------------------------------*/
    define variable voTache as class parametrageTache no-undo.
    define buffer ifdtpfac for ifdtpfac.
    define buffer garan    for garan.
    define buffer ifdparam for ifdparam.

    if ttTacheAssurancesLoyer.CRUD = "D" then do:
        voTache = new parametrageTache().
        if voTache:tacheObligatoire(ttTacheAssurancesLoyer.iNumeroContrat, ttTacheAssurancesLoyer.cTypeContrat, {&TYPETACHE-AssurancesLoyer}) = yes 
        then mError:createError({&error}, 100372). //Suppression interdite !
        delete object voTache.
    end.
    else do:
        // On vérifie que tous les barêmes d'assurances saisis existent
        controleExistence({&TYPECONTRAT-GarantieLoyer}, ttTacheAssurancesLoyer.cNumGarantieLoyerBauxCom). 
        controleExistence({&TYPECONTRAT-GarantieLoyer}, ttTacheAssurancesLoyer.cNumGarantieLoyerBauxHab). 
        controleExistence({&TYPECONTRAT-ProtectionJuridique}, ttTacheAssurancesLoyer.cNumProtectionJuridiqueBauxCom). 
        controleExistence({&TYPECONTRAT-ProtectionJuridique}, ttTacheAssurancesLoyer.cNumProtectionJuridiqueBauxHab). 
        controleExistence({&TYPECONTRAT-GarantieRisqueLocatif}, ttTacheAssurancesLoyer.cNumGarantieRisqueLocatifBauxCom). 
        controleExistence({&TYPECONTRAT-GarantieRisqueLocatif}, ttTacheAssurancesLoyer.cNumGarantieRisqueLocatifBauxHab). 
        controleExistence({&TYPECONTRAT-VacanceLocative}, ttTacheAssurancesLoyer.cNumCarenceLocativeBauxCom). 
        controleExistence({&TYPECONTRAT-VacanceLocative}, ttTacheAssurancesLoyer.cNumCarenceLocativeBauxHab). 
        if integer(ttTacheAssurancesLoyer.cNumGarantieSpeciale) <> 0
        then for first ifdparam no-lock
            where ifdparam.soc-dest = integer(mToken:cRefGerance):
            if not can-find(first garan no-lock
                where garan.tpctt = ttTacheAssurancesLoyer.cNumGarantieSpeciale
                  and garan.nobar = 0)
            or not can-find(first ifdtpfac no-lock
                where ifdtpfac.soc-cd      = ifdparam.soc-cd
                  and ifdtpfac.typefac-cle = substring(ttTacheAssurancesLoyer.cNumGarantieSpeciale, 4, 2, "character"))
            then mError:createError({&error}, messageErreur("", ttTacheAssurancesLoyer.cNumGarantieSpeciale)). 
        end.
    end.
end procedure.
