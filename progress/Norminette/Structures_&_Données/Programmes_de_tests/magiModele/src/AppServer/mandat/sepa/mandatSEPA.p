/*------------------------------------------------------------------------
File        : mandatSEPA.p
Purpose     : Mandat de prélèvement SEPA pour un role d'un contrat (locataire, copropriétaire...)
Author(s)   : SPo - 2018/06/13
Notes       : a partir de adb/src/tach/prmSepa.p
derniere revue: 2018/07/22 - phm: 
------------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/origineRUM.i}
{preprocesseur/sequenceRUM.i}
{preprocesseur/erreurMandatSEPA.i}
{preprocesseur/caractereRUM.i}

using parametre.syspr.syspr.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/glbsepar.i}
{tache/include/mandatPrelevementSepa.i}
{application/include/combo.i}
{application/include/error.i}
{crud/include/iaction.i}

procedure getMandatSEPA:
    /*------------------------------------------------------------------------------
    Purpose: Lecture du dernier ou liste mandat de prélèvement SEPA d'un role pour un contrat
             si type/no de role absent : on prend le role principal du contrat
             si pcTypeTrt = "LISTE" ou "LISTE-SUIVI": liste des mandats SEPA du role pour ce contrat
             sinon le dernier
             si pcTypeTrt = "SUIVI" ou "LISTE-SUIVI" ajout du détail de l'utilisation du mandat SEPA
    Notes  : service externe (beBail.cls)
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeTrt       as character no-undo.
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeRole      as character no-undo.
    define input parameter piNumeroRole    as int64     no-undo.
    define output parameter table for ttMandatPrelSepa.
    define output parameter table for ttSuiviMandatPrelSepa.

    define variable viEtabComm                 as integer   no-undo initial 8500.
    define variable viNumeroMandat             as integer   no-undo.
    define variable vcListeTypeContratAutorise as character no-undo.
    define variable viNoContratBanque          as integer   no-undo.
    define variable vcIBAN                     as character no-undo.
    define variable vhProcIBAN                 as handle    no-undo.
    define variable vhProcSEPA                 as handle    no-undo.
    define variable vcCodeErreur               as character no-undo.
    define variable vcLibelleErreur            as character no-undo.
    define variable vlModuleCtrlRIB            as logical   no-undo.
    define variable vlDernier                  as logical   no-undo initial true.

    define buffer ctrat      for ctrat.
    define buffer parpaie    for parpaie.
    define buffer mandatSepa for mandatSepa.

    empty temp-table ttMandatPrelSepa.
    empty temp-table ttSuiviMandatPrelSepa.
    if not can-find(first ctrat no-lock
                    where ctrat.tpcon = pcTypeContrat
                      and ctrat.nocon = piNumeroContrat) then do:
        mError:createError({&error}, 100057).
        return.
    end.
    if pcTypeRole = "" or pcTypeRole = ?
    or piNumeroRole = 0 or piNumeroRole = ?
    then for first ctrat no-lock
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroContrat:
        assign
            pcTypeRole   = ctrat.tprol
            piNumeroRole = ctrat.norol
        .
    end.
    if not can-find(first roles no-lock
                    where roles.tprol = pcTypeRole
                      and roles.norol = piNumeroRole) then do:
        mError:createError({&error}, 1000599, substitute("&2&1&3", separ[1], pcTypeRole, piNumeroRole)). //rôle &1 &2 inexistant
        return.
    end.
    vcListeTypeContratAutorise = substitute("&1,&2,&3", {&TYPECONTRAT-bail}, {&TYPECONTRAT-preBail}, {&TYPECONTRAT-titre2copro}).
    if lookup(pcTypeContrat, vcListeTypeContratAutorise) = 0 then do:
        mError:createErrorGestion({&error}, 1000779, pcTypeContrat).    // Recherche RUM role/contrat : type de contrat &1 non géré
        return.
    end.
    // Module optionnel du process de controle/validation des RIB (0416/0226 BNP)
    find first parpaie no-lock
        where parpaie.soc-cd   = integer(mtoken:cRefPrincipale)
          and parpaie.etab-cd  = viEtabComm  no-error.
    if not available parpaie
    then find first parpaie no-lock
        where parpaie.soc-cd = integer(mtoken:cRefPrincipale) no-error.
    assign
        vlModuleCtrlRIB = (available parpaie and parpaie.rib-periode <> 0)
        viNumeroMandat  = truncate(piNumeroContrat / 100000, 0)
    .
    if pcTypeTrt begins "LISTE"
    then for each mandatSepa no-lock
        where mandatSepa.tpmandat = {&TYPECONTRAT-sepa}
          and mandatSepa.ntcon    = {&NATURECONTRAT-recurrent}
          and mandatSepa.nomdt    = viNumeroMandat
          and mandatSepa.tpcon    = pcTypeContrat
          and mandatSepa.nocon    = piNumeroContrat
          and mandatSepa.tprol    = pcTypeRole
          and mandatSepa.norol    = piNumeroRole
        by mandatSepa.noord descending:   // Ordre pour l'interface utilisateur : le dernier mandat SEPA en 1er
        create ttMandatPrelSepa.
        outils:copyValidField(buffer mandatSepa:handle, buffer ttMandatPrelSepa:handle).  // copy table physique vers temp-table
        assign
            ttMandatPrelSepa.daCreation           = mandatsepa.dtcsy
            ttMandatPrelSepa.cUtilisateurCreation = mandatsepa.cdcsy
            ttMandatPrelSepa.ldernierRUM          = vlDernier
            vlDernier                             = false
        .
    end.
    else for last mandatSepa no-lock
        where mandatSepa.Tpmandat = {&TYPECONTRAT-sepa}
          and mandatSepa.ntcon    = {&NATURECONTRAT-recurrent}
          and mandatSepa.nomdt    = viNumeroMandat
          and mandatSepa.tpcon    = pcTypeContrat
          and mandatSepa.nocon    = piNumeroContrat
          and mandatSepa.tprol    = pcTypeRole
          and mandatSepa.norol    = piNumeroRole
        use-index ix_mandatSepa07:
        create ttMandatPrelSepa.
        outils:copyValidField(buffer mandatSepa:handle, buffer ttMandatPrelSepa:handle).  // copy table physique vers temp-table
        assign
            ttMandatPrelSepa.daCreation           = mandatsepa.dtcsy
            ttMandatPrelSepa.cUtilisateurCreation = mandatsepa.cdcsy
            ttMandatPrelSepa.ldernierRUM          = true
        .
    end.
    run outils/IBANRoleContrat.p persistent set vhprocIBAN.
    run getTokenInstance in vhprocIBAN(mToken:JSessionId).
    run outils/controleBancaire.p persistent set vhProcSEPA.
    run getTokenInstance in vhProcSEPA(mToken:JSessionId).
    for each ttMandatPrelSepa
      , first roles no-lock
        where roles.tprol = ttMandatPrelSepa.cTypeRole
          and roles.norol = ttMandatPrelSepa.iNumeroRole:
        assign
            ttMandatPrelSepa.cLibelleOrigineRUM    = outilTraduction:getLibelleParam ("SAORI", ttMandatPrelSepa.ccodeOrigineRUM)
            ttMandatPrelSepa.cLibelleSequenceRUM   = outilTraduction:getLibelleParam ("SASEQ", ttMandatPrelSepa.ccodeSequenceRUM)
            ttMandatPrelSepa.lRUMUtilise           = can-find(first suimandatSEPA no-lock
                                                              where suimandatSEPA.noMPrelSEPA = ttMandatPrelSepa.iNoMandatSepa
                                                                and suimandat.TypeLig = "PREL")
            ttMandatPrelSepa.lRIBAttenteValidation = vlModuleCtrlRIB
                                                 and can-find(first ctanx no-lock
                                                              where ctanx.tpcon = {&TYPECONTRAT-RIBAttenteValidation}
                                                                and ctanx.TpRol = {&TYPEROLE-tiers}
                                                                and Ctanx.Norol = roles.notie)
        .
        // Contrôles de validité  IBAN role + contrat
        run IBAN-RoleContrat in vhProcIBAN(ttMandatPrelSepa.cTypeContrat
                                         , ttMandatPrelSepa.iNumeroContrat
                                         , ttMandatPrelSepa.cTypeRole
                                         , ttMandatPrelSepa.iNumeroRole
                                         , output viNoContratBanque
                                         , output vcIBAN).
        run IsMandatSepaValide(ttMandatPrelSepa.iNoMandatSepa
                              ,viNoContratBanque
                              ,today
                              ,vhProcSEPA
                              ,output vcCodeErreur
                              ,output vcLibelleErreur).
        assign
            ttMandatPrelSepa.lRUMValide              = ( integer(vcCodeErreur) = 0 )
            ttMandatPrelSepa.cCodeErreurNonValide    = vcCodeErreur
            ttMandatPrelSepa.cLibelleErreurNonValide = vcLibelleErreur
        .
    end.
    run destroy in vhprocIBAN.
    run destroy in vhprocSEPA.
    if pcTypeTrt matches "*SUIVI*"
    then for each ttMandatPrelSepa:
        run createttSuiviMandatPrelSepa(buffer ttMandatPrelSepa).
    end.
end procedure.

procedure createttSuiviMandatPrelSepa private:
    /*------------------------------------------------------------------------------
    Purpose: création tache garant table physique -> table tempo
    Notes  : service externe (beBail.cls)
    ------------------------------------------------------------------------------*/
    define parameter buffer pbttMandatPrelSepa for ttMandatPrelSepa.
    define buffer suimandatsepa for suimandatsepa.
    for each suimandatsepa no-lock
        where suimandatsepa.nomprelsepa = pbttMandatPrelSepa.iNoMandatSepa:
        create ttSuiviMandatPrelSepa.
        outils:copyValidField(buffer suimandatsepa:handle, buffer ttSuiviMandatPrelSepa:handle).  // copy table physique vers temp-table
        assign
            ttSuiviMandatPrelSepa.cTypeContrat        = pbttMandatPrelSepa.cTypeContrat
            ttSuiviMandatPrelSepa.iNumeroContrat      = pbttMandatPrelSepa.iNumeroContrat
            ttSuiviMandatPrelSepa.cTypeRole           = pbttMandatPrelSepa.cTypeRole
            ttSuiviMandatPrelSepa.iNumeroRole         = pbttMandatPrelSepa.iNumeroRole
            ttSuiviMandatPrelSepa.cLibelleSequenceRUM = outilTraduction:getLibelleParam ("SASEQ", ttSuiviMandatPrelSepa.ccodeSequenceRUM)
            ttSuiviMandatPrelSepa.daAction            = suimandatsepa.dtcsy
            ttSuiviMandatPrelSepa.cUtilisateurAction  = suimandatsepa.cdcsy
        .
    end.
end procedure.

procedure setMandatSEPA:
    /*------------------------------------------------------------------------------
    Purpose: Mise à jour mandat de prélèvement SEPA
    Notes  : service externe (beBail.cls)
    ------------------------------------------------------------------------------*/
    define input parameter table for ttMandatPrelSepa.
    define input parameter table for ttError.

    find first ttMandatPrelSepa
        where lookup(ttMandatPrelSepa.CRUD, "C,U,D") > 0 no-error.
    if not available ttMandatPrelSepa then return.

    run ctrlSaisie.
    if mError:erreur() then return.

    run prepareLigneSuivi.
    run majMandatSEPA.
end procedure.

procedure ctrlSaisie private:
    /*------------------------------------------------------------------------------
    Purpose: Contrôle des données avant mise à jour
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vlCaractereRUMOK    as logical   no-undo.
    define variable vlHabModRIB         as logical   no-undo.
    define variable vcCaractereInterdit as character no-undo.
    define variable vhProcIBAN          as handle    no-undo.
    define variable vhProcSEPA          as handle    no-undo.
    define variable viNoContratBanque   as integer   no-undo.
    define variable vcIBAN              as character no-undo.
    define variable vcCodeErreur        as character no-undo.
    define variable vcLibelleErreur     as character no-undo.
    define variable viNumeroReponse     as integer   no-undo.

    define buffer mandatsepa         for mandatsepa.
    define buffer parpaie            for parpaie.
    define buffer vbttMandatPrelSepa for ttMandatPrelSepa.
    define buffer ctanx              for ctanx.
    define buffer roles              for roles.
    define buffer tutil              for tutil.

    run outils/IBANRoleContrat.p persistent set vhprocIBAN.
    run getTokenInstance in vhprocIBAN(mToken:JSessionId).
    run outils/controleBancaire.p persistent set vhProcSEPA.
    run getTokenInstance in vhProcSEPA(mToken:JSessionId).

bouclectrl:
   for each ttMandatPrelSepa
       where lookup(ttMandatPrelSepa.CRUD, "C,U,D") > 0:
       if not can-find(first ctrat no-lock
                       where ctrat.tpcon = ttMandatPrelSepa.cTypeContrat
                         and ctrat.nocon = ttMandatPrelSepa.iNumeroContrat)
        then mError:createErrorGestion({&error}, 109346, substitute('&2&1&3', separ[1],outilTraduction:getLibelleProg("O_COT", ttMandatPrelSepa.cTypeContrat), string(ttMandatPrelSepa.iNumeroContrat))).
        else if not can-find(first roles no-lock
                             where roles.tprol = ttMandatPrelSepa.cTypeRole
                               and roles.norol = ttMandatPrelSepa.iNumeroRole)
        then mError:createError({&error}, 1000768, substitute('&2&1&3', separ[1], outilTraduction:getLibelleProg("O_ROL", ttMandatPrelSepa.cTypeRole), string(ttMandatPrelSepa.iNumeroRole))).
        else if lookup(ttMandatPrelSepa.CRUD, "U,D") > 0
        and not can-find(first mandatsepa no-lock
                         where mandatsepa.nomprelsepa = ttMandatPrelSepa.iNoMandatSepa)
        then mError:createError({&error}, 1000789, string(ttMandatPrelSepa.iNoMandatSepa)).
        if mError:erreur() then leave boucleCtrl.

        // habilitations utilisateur pour Modification RIB/IBAN
        for first tutil no-lock
            where tutil.ident_u = mtoken:cUser:
            vlHabModRIB = lookup(tutil.ribgestimmod, "TRUE,YES") > 0.
        end.
        run IBAN-RoleContrat in vhProcIBAN(
            ttMandatPrelSepa.cTypeContrat,
            ttMandatPrelSepa.iNumeroContrat,
            ttMandatPrelSepa.cTypeRole,
            ttMandatPrelSepa.iNumeroRole,
            output viNoContratBanque,
            output vcIBAN
        ).
        if ttMandatPrelSepa.CRUD = "D" then do:
            if ttMandatPrelSepa.lRUMUtilise then do:
                mError:createError({&error}, 1000822).  // mandat SEPA déjà utilisé pour une prélèvement
                leave bouclectrl.
            end.
            else if ttMandatPrelSepa.daDerniereUtilisationRUM <> ? then do:
                mError:createError({&error}, 1000796).  // La date de dernière utilisation de ce mandat de prélèvement SEPA a été renseignée, vous ne pouvez pas le supprimer.
                leave bouclectrl.
            end.
        end.
        else do: // Controles avant création/maj
            ttMandatPrelSepa.iNoMandatbis = ttMandatPrelSepa.iNoMandatSepa.
            // Contrôles de validité  IBAN role + contrat
            run isMandatSepaValide(
                ttMandatPrelSepa.iNoMandatSepa,
                viNoContratBanque,
                today,
                vhProcSEPA,
                output vcCodeErreur,
                output vcLibelleErreur
            ).
            assign
                ttMandatPrelSepa.lRUMValide              = (integer(vcCodeErreur) = 0)
                ttMandatPrelSepa.cCodeErreurNonValide    = vcCodeErreur
                ttMandatPrelSepa.cLibelleErreurNonValide = vcLibelleErreur
            .
            if viNoContratBanque > 0
            and (ttMandatPrelSepa.cIBAN = ? or ttMandatPrelSepa.cIBAN = "")
            then for first ctanx no-lock
                where ctanx.tpcon = {&TYPECONTRAT-RIB}
                  and ctanx.nocon = viNoContratBanque:
                assign
                    ttMandatPrelSepa.cIBAN          = ctanx.iban
                    ttMandatPrelSepa.cBIC           = ctanx.bicod
                    ttMandatPrelSepa.cDomiciliation = ctanx.lbdom
                .
            end.
            if ttMandatPrelSepa.cCodeErreurNonValide = {&ERRMANDATSEPA-IBANHorsZoneSEPA} then do:
                mError:createError({&error}, ttMandatPrelSepa.cLibelleErreurNonValide).
                leave bouclectrl.
            end.
            // Modification date de signature pour utilisateur ayant l'habilitation
            if ((ttMandatPrelSepa.CRUD = "C" and ttMandatPrelSepa.daSignatureRUM <> ?)
             or (ttMandatPrelSepa.CRUD = "U" and can-find(first mandatsepa no-lock
                                                          where mandatsepa.nomprelsepa = ttMandatPrelSepa.iNoMandatSepa
                                                            and mandatSEPA.dtSig <> ttMandatPrelSepa.daSignatureRUM))) then do:
                if not vlHabModRIB then do:
                    mError:createError({&error}, 1000792).
                    leave bouclectrl.
                end.
                else if ttMandatPrelSepa.daSignatureRUM <> ?
                    and ttMandatPrelSepa.cCodeErreurNonValide = {&ERRMANDATSEPA-AbsenceIBAN} then do:
                    mError:createError({&error}, 1000791).  // IBAN absent, validation mandat SEPA impossible
                    leave bouclectrl.
                end.
            end.
            if ttMandatPrelSepa.ccodeOrigineRUM > {&ORIGINERUM-automatiqueGI} then do:  // Contrôles spécifiques saisies non automatique GI
                if ttMandatPrelSepa.cRUM = "" or ttMandatPrelSepa.cRUM = ? then do:
                    mError:createError({&error}, 1000782, "").
                    leave bouclectrl.
                end.
                else do:
                    run CtrlRUM(ttMandatPrelSepa.cRUM, output vlCaractereRUMOK, output vcCaractereInterdit).
                    if not vlCaractereRUMOK then do:
                        mError:createError({&error}, 1000783, substitute('&2&1&3', separ[1], vcCaractereInterdit, "")).
                        leave bouclectrl.
                    end.
                end.
                // Contrôle UNICITE RUM
                for first mandatSEPA no-lock
                    where mandatSEPA.codeRUM = ttMandatPrelSepa.cRUM
                      and mandatSEPA.noMPrelSEPA <> ttMandatPrelSepa.iNoMandatSepa
                      and mandatSEPA.dtresil = ?:
                    // La RUM &1 est déjà utilisée pour le &2 n°&3, intervenant : &4 n° &5 (&6).
                    mError:createError({&error}, 1000784, substitute('&2&1&3&1&4&1&5&1&6&1&7', separ[1], ttMandatPrelSepa.cRUM, outilTraduction:getLibelleProg("O_COT", ttMandatPrelSepa.cTypeContrat), string(ttMandatPrelSepa.iNumeroContrat), outilTraduction:getLibelleProg("O_ROL", ttMandatPrelSepa.cTypeRole), string(ttMandatPrelSepa.iNumeroRole), outilFormatage:getNomTiers(ttMandatPrelSepa.cTypeRole, ttMandatPrelSepa.iNumeroRole))).
                    leave bouclectrl.
                end.
            end.
            // Si RECURRENT : date signature et date dernière utilisation obligatoires (cas reprise manuelle)
            if ttMandatPrelSepa.ccodeSequenceRUM = {&SEQUENCERUM-RECURRENT} then do:
                if ttMandatPrelSepa.daSignatureRUM = ? then do:
                    mError:createError({&error}, 1000785, "").
                    leave bouclectrl.
                end.
                else if ttMandatPrelSepa.daDerniereUtilisationRUM = ? then do:
                    mError:createError({&error}, 1000786, "").
                    leave bouclectrl.
                end.
            end.
            if ttMandatPrelSepa.daResiliationRUM <> ?
            and ttMandatPrelSepa.daDerniereUtilisationRUM <> ?
            and ttMandatPrelSepa.daResiliationRUM < ttMandatPrelSepa.daDerniereUtilisationRUM then do:
                mError:createError({&error}, 1000780).
                leave bouclectrl.
            end.
            if ttMandatPrelSepa.CRUD = "U" then do:
                if not ttMandatPrelSepa.ldernierRUM then do:
                    mError:createError({&error}, 1000795).
                    leave bouclectrl.
                end.
                if ttMandatPrelSepa.ccodeSequenceRUM = {&SEQUENCERUM-FINAL}
                and not vlHabModRIB
                then do:
                    mError:createError({&error}, 1000781, "").
                    leave bouclectrl.
                end.
                if ttMandatPrelSepa.ccodeSequenceRUM = {&SEQUENCERUM-FINAL}
                and not can-find(first mandatsepa where mandatsepa.nomprelsepa = ttMandatPrelSepa.iNoMandatSepa and mandatsepa.cdstatut = {&SEQUENCERUM-RECURRENT})
                then do:
                    // Pour envoyer la séquence <FINAL> dans le prochain prélèvement il faut d'abord que ce mandat SEPA ait été utilisé donc que la séquence en cours soit à <RECURRENT>
                    mError:createError({&error}, 1000787, "").
                    leave bouclectrl.
                end.
            end.
            else do:
                // pas 2 create pour le même contrat/role dans le même dataset
                if can-find(first vbttMandatPrelSepa
                            where vbttMandatPrelSepa.cTypeContrat   = ttMandatPrelSepa.cTypeContrat
                              and vbttMandatPrelSepa.iNumeroContrat = ttMandatPrelSepa.iNumeroContrat
                              and vbttMandatPrelSepa.cTypeRole      = ttMandatPrelSepa.cTypeRole
                              and vbttMandatPrelSepa.iNumeroRole    = ttMandatPrelSepa.iNumeroRole
                              and rowid(vbttMandatPrelSepa)        <> rowid(ttMandatPrelSepa))
                then do:
                    mError:createError({&error}, 1000797).
                    leave bouclectrl.
                end.
                // pas de create nouveau mandat SEPA si précédent non résilié
                for last mandatSepa no-lock
                    where mandatSepa.Tpmandat = {&TYPECONTRAT-sepa}
                      and mandatSepa.ntcon    = {&NATURECONTRAT-recurrent}
                      and mandatSepa.nomdt    = ttMandatPrelSepa.iMandatMaitre
                      and mandatSepa.tpcon    = ttMandatPrelSepa.cTypeContrat
                      and mandatSepa.nocon    = ttMandatPrelSepa.iNumeroContrat
                      and mandatSepa.tprol    = ttMandatPrelSepa.cTypeRole
                      and mandatSepa.norol    = ttMandatPrelSepa.iNumeroRole
                    use-index ix_mandatSepa07:
                    if mandatSepa.dtResil = ? then do:
                        mError:createError({&error}, 1000794, "").
                        leave bouclectrl.
                    end.
                end.
                if viNoContratBanque = 0 then do:
                    // Aucun IBAN pour le tiers. Confirmez-vous la création du mandat de prélèvement SEPA ?
                    viNumeroReponse = outils:questionnaire(1000790, table ttError by-reference).
                    if viNumeroReponse <= 2 then do:         // question oui/non pour continuer le traitement
                        if viNumeroReponse = 2
                        then mError:createError({&error}, 1000689). // message sans interet mais erreur nécessaire pour interrompre maj
                        leave bouclectrl.
                    end.
                end.
            end.
            // mise à jour nom du role
            assign
                ttMandatPrelSepa.cNomRole        = outilFormatage:getNomTiers(ttMandatPrelSepa.cTypeRole, ttMandatPrelSepa.iNumeroRole)
                ttMandatPrelSepa.cNomCompletRole = entry(1, outilFormatage:getNomTiersFormtiea ("TYPE", ttMandatPrelSepa.cTypeRole, ttMandatPrelSepa.iNumeroRole, 64), "|")
            .
        end.
    end.
    run destroy in vhprocIBAN.
    run destroy in vhprocSEPA.
end procedure.

procedure prepareLigneSuivi private:
    /*------------------------------------------------------------------------------
    Purpose: Préparation des lignes de suivi en table temporaire
             Ligne "SIGN" pour la signature du mandat de prélèvement
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer mandatsepa for mandatsepa.

    empty temp-table ttSuiviMandatPrelSepa.
    for each ttMandatPrelSepa
        where ttMandatPrelSepa.CRUD = "D":
        // si suppression mandat prélèvement SEPA alors suppression des lignes de suivi
        run createttSuiviMandatPrelSepa(buffer ttMandatPrelSepa).
        for each ttSuiviMandatPrelSepa
            where ttSuiviMandatPrelSepa.iNoMandatSepa = ttMandatPrelSepa.iNoMandatSepa:
            ttSuiviMandatPrelSepa.CRUD = "D".
        end.
    end.
    for each ttMandatPrelSepa
        where lookup(ttMandatPrelSepa.CRUD, "C,U") > 0:
        ttMandatPrelSepa.cSvgCRUD = ttMandatPrelSepa.CRUD.
        if ttMandatPrelSepa.daSignatureRUM <> ? then do:
            if ttMandatPrelSepa.daValideRUM = ? then ttMandatPrelSepa.daValideRUM = today. // Validation RUM si date signature passe de ? à une date valide
            if ttMandatPrelSepa.CRUD = "C"
            or not can-find(first suimandatSEPA no-lock
                            where suimandatSEPA.noMPrelSEPA = ttMandatPrelSepa.iNoMandatSepa
                              and suimandat.TypeLig         = "SIGN")
            then do:
                create ttSuiviMandatPrelSepa.
                buffer-copy ttMandatPrelSepa except dtTimestamp to ttSuiviMandatPrelSepa
                    assign
                        ttSuiviMandatPrelSepa.iNumeroLigne        = 0
                        ttSuiviMandatPrelSepa.cTypeLigne          = "SIGN"
                        ttSuiviMandatPrelSepa.cLibelle            = outilTraduction:getLibelle(1000799)     // Mandat de prélèvement SEPA signé (donc Validé)
                        ttSuiviMandatPrelSepa.cLibelleSequenceRUM = outilTraduction:getLibelleParam ("SASEQ", ttSuiviMandatPrelSepa.ccodeSequenceRUM)
                        ttSuiviMandatPrelSepa.daAction            = today
                        ttSuiviMandatPrelSepa.cUtilisateurAction  = mtoken:cUser
                        ttSuiviMandatPrelSepa.CRUD                = "C"
                        ttSuiviMandatPrelSepa.dtTimestamp         = ?
                        ttSuiviMandatPrelSepa.rRowid              = ?
                .
            end.
        end.
        // trace dans table iaction à générer
        if ttMandatPrelSepa.CRUD = "C" then ttMandatPrelSepa.lCreerAction = true.
        if ttMandatPrelSepa.CRUD = "U"
        then for first mandatsepa no-lock
            where mandatsepa.nomprelsepa = ttMandatPrelSepa.iNoMandatSepa:
            if ttMandatPrelSepa.cRUM <> mandatSEPA.codeRUM
            or ttMandatPrelSepa.daSignatureRUM <> mandatSEPA.dtSig
            or ttMandatPrelSepa.daResiliationRUM <> mandatSEPA.dtResil
            then assign
                ttMandatPrelSepa.lCreerAction         = true
                ttMandatPrelSepa.cInfoSuiviAvantModif = substitute(outilTraduction:getLibelle(1000802), mandatsepa.codeRUM, if mandatSEPA.dtSig <> ? then outilTraduction:getLibelle(100065) + " " + string(mandatSEPA.dtSig,"99/99/9999") else outilTraduction:getLibelle(1000803), if mandatSEPA.dtResil <> ? then outilTraduction:getLibelle(105589) + " " + string(mandatSEPA.dtResil,"99/99/9999") else outilTraduction:getLibelle(1000804))
            .
        end.
    end.
end procedure.

procedure ctrlRUM private:
    /*------------------------------------------------------------------------------
    Purpose: Contrôle des caractères saisis dans la RUM
    Notes  : liste des caractères autorisés "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ/ -?:().,+" 
             c.f. caractereRUM.i
    ------------------------------------------------------------------------------*/
    define input parameter  pcRUM     as character no-undo.
    define output parameter plRUM-OK  as logical   no-undo.
    define output parameter pcCharErr as character no-undo.

    define variable vcCaractere        as character no-undo.
    define variable viCompteur         as integer   no-undo.

    do viCompteur = 1 to length(pcRUM, "character"):
        vcCaractere = substring(pcRUM, viCompteur, 1, 'character').
        if index({&CODERUM-ListeCarAutorise}, vcCaractere) = 0 then do:
            pcCharErr = vcCaractere.
            return.
        end.
    end.
    plRUM-OK = true.
end procedure.

procedure majMandatSEPA private:
    /*------------------------------------------------------------------------------
    Purpose: Mise à jour mandat de prélèvement SEPA
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhsuimandatsepa     as handle    no-undo.
    define variable vhmandatSepa        as handle    no-undo.
    define variable vhIaction           as handle    no-undo.
    define variable vcAction            as character no-undo.
    define variable vcApresModification as character no-undo.

    run crud/mandatSEPA_CRUD.p persistent set vhmandatSepa.
    run getTokenInstance in vhmandatSepa(mToken:JSessionId).
    run setMandatsepa in vhmandatSepa(table ttMandatPrelSepa by-reference).
    run destroy in vhmandatSepa.
    if mError:erreur() then return.

    // Création du mandat SEPA : mise à jour no interne mandat sepa et code RUM dans ligne de suivi
    for each ttMandatPrelSepa
        where ttMandatPrelSepa.cSvgCRUD = "C"
      , each ttSuiviMandatPrelSepa
        where ttSuiviMandatPrelSepa.cTypeContrat = ttMandatPrelSepa.cTypeContrat
          and ttSuiviMandatPrelSepa.iNumeroContrat = ttMandatPrelSepa.iNumeroContrat
          and ttSuiviMandatPrelSepa.cTypeRole = ttMandatPrelSepa.cTypeRole
          and ttSuiviMandatPrelSepa.iNumeroRole = ttMandatPrelSepa.iNumeroRole
          and ttSuiviMandatPrelSepa.CRUD = "C":
        assign
            ttSuiviMandatPrelSepa.iNoMandatSepa = ttMandatPrelSepa.iNoMandatSepa
            ttSuiviMandatPrelSepa.cRUM          = ttMandatPrelSepa.cRUM
        .
    end.
    if can-find(first ttSuiviMandatPrelSepa) then do:
        run crud/suiMandatSEPA_CRUD.p persistent set vhsuimandatsepa.
        run getTokenInstance in vhsuimandatsepa(mToken:JSessionId).
        run setSuimandatsepa in vhsuimandatsepa (table ttSuiviMandatPrelSepa by-reference).
        run destroy in vhsuimandatsepa.
        if mError:erreur() then return.
    end.
    // Création des traces dans iaction
    empty temp-table ttIaction.
    for each ttMandatPrelSepa
        where ttMandatPrelSepa.lCreerAction:
        assign
            vcAction            = ""
            vcApresModification = ""
        .
        // Création du mandat prélèvement SEPA pour le contrat &1 &2, intervenant : &3 N° &4 - &5, RUM : &6.
        if ttMandatPrelSepa.cSvgCRUD = "C"
        then vcAction = substitute(outilTraduction:getLibelle(1000800),
                                   outilTraduction:getLibelleProg("O_CLC", ttMandatPrelSepa.cTypeContrat),
                                   ttMandatPrelSepa.iNumeroContrat,
                                   outilTraduction:getLibelleProg("O_ROL", ttMandatPrelSepa.cTypeRole),
                                   ttMandatPrelSepa.iNumeroRole,
                                   outilFormatage:getNomTiers(ttMandatPrelSepa.cTypeRole, ttMandatPrelSepa.iNumeroRole),
                                   ttMandatPrelSepa.cRUM).
        else if ttMandatPrelSepa.cSvgCRUD = "U"
        then assign
            // Modification du mandat prélèvement SEPA pour le contrat &1 &2, intervenant : &3 N° &4 - &5, RUM : &6.
            vcAction            = substitute(outilTraduction:getLibelle(1000801),
                                             outilTraduction:getLibelleProg("O_CLC", ttMandatPrelSepa.cTypeContrat),
                                             ttMandatPrelSepa.iNumeroContrat,
                                             outilTraduction:getLibelleProg("O_ROL", ttMandatPrelSepa.cTypeRole),
                                             ttMandatPrelSepa.iNumeroRole,
                                             outilFormatage:getNomTiers(ttMandatPrelSepa.cTypeRole,
                                             ttMandatPrelSepa.iNumeroRole),
                                             ttMandatPrelSepa.cRUM)
            vcApresModification = substitute(outilTraduction:getLibelle(1000802),
                                             ttMandatPrelSepa.cRUM,
                                             if ttMandatPrelSepa.daSignatureRUM <> ? then outilTraduction:getLibelle(100065) + " " + string(ttMandatPrelSepa.daSignatureRUM,"99/99/9999") else outilTraduction:getLibelle(1000803),
                                             if ttMandatPrelSepa.daResiliationRUM <> ? then outilTraduction:getLibelle(105589) + " " + string(ttMandatPrelSepa.daResiliationRUM,"99/99/9999") else outilTraduction:getLibelle(1000804))
        .
        create ttIaction.
        assign 
            ttIaction.action   = vcAction 
            ttIaction.computer = ""
            ttIaction.nocon    = ttMandatPrelSepa.iNumeroContrat
            ttIaction.noidt    = ttMandatPrelSepa.iNumeroRole
            ttIaction.nomprg   = "mandatSEPA.p"
            ttIaction.notac    = 0
            ttIaction.tpcon    = ttMandatPrelSepa.cTypeContrat
            ttIaction.tpidt    = ttMandatPrelSepa.cTypeRole
            ttIaction.tptac    = ""
            ttIaction.username = mtoken:cUser
            ttIaction.zone1    = ttMandatPrelSepa.cInfoSuiviAvantModif
            ttIaction.zone2    = vcApresModification
            ttIaction.zone3    = ""
            ttIaction.zone4    = ""
            ttIaction.CRUD     = "C"
        .
    end.
    if can-find(first ttIaction) then do:
        run crud/iaction_CRUD.p persistent set vhIaction.
        run getTokenInstance in vhIaction(mToken:JSessionId).
        run setIaction in vhIaction (table ttIaction by-reference).
        run destroy in vhIaction.
        if mError:erreur() then return.
    end.
    
end procedure.

procedure initComboMandatSEPA:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define output parameter table for ttCombo.

    define variable voSyspr as class syspr no-undo.

    empty temp-table ttCombo.
    voSyspr = new syspr().
    voSyspr:getComboParametre("SAORI", "ORIGINERUM", output table ttCombo by-reference).
    // supprimer les items non saisissables pour IHM
    for each ttCombo
        where ttCombo.cNomCombo = "ORIGINERUM"
          and ttCombo.cCode >= {&ORIGINERUM-migration}:
        delete ttCombo.
    end.
    voSyspr:getComboParametre("SASEQ", "SEQUENCERUM", output table ttCombo by-reference).
    delete object voSyspr.

end procedure.

procedure isMandatSepaValide:
    /*------------------------------------------------------------------------------
    Purpose: Controle de la validité d'un mandat SEPA pour une date d'échéance donnée
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter  piNoMandatSepa    as int64     no-undo.
    define input parameter  piNoContratBanque as integer   no-undo.
    define input parameter  pdaEcheancePrel   as date      no-undo.
    define input parameter  phprocSEPA        as handle    no-undo.
    define output parameter pcCodeErreurSepa  as character no-undo.        /* c.f. param SAERR dans sys_pr */
    define output parameter pcLibelleErreur   as character no-undo.

    define variable vdaExpiration as date   no-undo.
    define variable vhprocSEPA    as handle no-undo.

    define buffer mandatsepa for mandatsepa.
    define buffer ctanx      for ctanx.

    vhprocSEPA = phprocSEPA.
    if not valid-handle(vhprocSEPA)
    then run outils/controleBancaire.p persistent set vhProcSEPA.

    find first mandatsepa no-lock
        where mandatsepa.noMPrelSEPA = piNoMandatSepa no-error.
    if not available mandatsepa then do:
        assign
            pcCodeErreurSepa = {&ERRMANDATSEPA-AbsenceMandatSepa}
            pcLibelleErreur = substitute(outilTraduction:getLibelle(1000789), string(ttMandatPrelSepa.iNoMandatSepa))
        .
        return.
    end.
    if mandatsepa.dtsig <> ? then vdaExpiration = add-interval( (if mandatsepa.dtUtilisation <> ? then mandatsepa.dtUtilisation else mandatsepa.dtsig), {&DELAIEXPIRATION-36mois}, "months").
    if mandatsepa.dtsig = ?
    then assign pcCodeErreurSepa = {&ERRMANDATSEPA-AbsenceSignature}.
    else if mandatsepa.dtresil <> ? and mandatsepa.dtresil <= pdaEcheancePrel
    then assign
        pcCodeErreurSepa = {&ERRMANDATSEPA-Resilie}
        pcLibelleErreur  = substitute(outilTraduction:getLibelle(1000819), string(mandatsepa.dtresil, "99/99/9999"))
    .
    else if vdaExpiration <> ? and vdaExpiration <= pdaEcheancePrel     // Mandat SEPA expiré le &1(non utilisé depuis plus de &2 mois)
    then assign
        pcCodeErreurSepa = {&ERRMANDATSEPA-Expire36Mois}
        pcLibelleErreur = substitute(outilTraduction:getLibelle(1000820), string(vdaExpiration, "99/99/9999"), string({&DELAIEXPIRATION-36mois}))
    .
    else if piNoContratBanque = 0
    then assign pcCodeErreurSepa = {&ERRMANDATSEPA-AbsenceIBAN}.
    if pcCodeErreurSepa > "" then do:
        if pcLibelleErreur = "" then pcLibelleErreur = outilTraduction:getLibelleParam ("SAERR", pcCodeErreurSepa).
        return.
    end.
    // Recherche si changement d'IBAN entre celui du mandat SEPA et celui en cours pour le role + contrat (non bloquant)
    for first ctanx no-lock
        where ctanx.tpcon = {&TYPECONTRAT-RIB}
          and ctanx.nocon = piNoContratBanque:
        // Vérification Zone SEPA
        if not dynamic-function('isZoneSEPA' in vhprocSEPA, ctanx.iban, ctanx.bicod) then do:
            //  L' IBAN+BIC &1 est hors zone SEPA. Prélèvement SEPA interdit.
            assign
                pcCodeErreurSepa = {&ERRMANDATSEPA-IBANHorsZoneSEPA}
                pcLibelleErreur = substitute(outilTraduction:getLibelle(1000793), ctanx.iban + "/" + ctanx.bicod)
            .
            return.
        end.
        if mandatsepa.iban <> ctanx.iban then do:
            assign
                pcCodeErreurSepa = {&ERRMANDATSEPA-ChangementIBAN}
                pcLibelleErreur = substitute(outilTraduction:getLibelle(1000821), mandatsepa.iban, ctanx.iban)
            .
            return.
        end.
    end.
    if not valid-handle(phprocSEPA) then run destroy in vhprocSEPA.
end procedure.
