/*------------------------------------------------------------------------
File        : createFiche.p
Description :
Author(s)   : NPO  -  2017/02/20
Notes       :
------------------------------------------------------------------------*/
{preprocesseur/nature2contrat.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2role.i}
{preprocesseur/type2tiers.i}
{preprocesseur/type2libelle.i}
{preprocesseur/codefinancier2commercialisation.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{mandat/include/uniteLocation.i}
{bail/include/Bail.i}

function igetNextSequence returns integer (pcNomTable as character, pcChampSequence as character):
    /*------------------------------------------------------------------------------
    Purpose: calcul prochain numero de sequence
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhBuffer   as handle  no-undo.
    define variable viSequence as integer no-undo initial 1.

    create buffer vhBuffer for table pcNomTable.
    vhBuffer:find-last("", no-lock) no-error.
    viSequence = if vhBuffer:available then vhBuffer:buffer-field(pcChampSequence):buffer-value + 1 else 1.
    delete object vhBuffer no-error.
    return viSequence.

end function.

procedure createFiche:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beCommercialisation.cls
    ------------------------------------------------------------------------------*/
    define input  parameter piTypFiche     as integer no-undo.
    define input-output parameter table for ttUniteLocation.

    define variable viNextNumeroFiche     as integer no-undo.
    define variable viNextNumeroHisto     as integer no-undo.
    define variable viNumeroRangPrecedent as integer no-undo.
    define variable viDernierNumeroRang   as integer no-undo.
    define variable viNombrePieces        as integer no-undo.
    define variable vdSurfaceUtileTotale  as decimal no-undo.
    define variable viContratMin          as integer no-undo.
    define variable viContratMax          as integer no-undo.
    define variable vlNouvFiche           as logical no-undo.
    define buffer gl_libelle     for gl_libelle.
    define buffer gl_fiche       for gl_fiche.
    define buffer gl_fiche_tiers for gl_fiche_tiers.
    define buffer gl_sequence    for gl_sequence.
    define buffer unite          for unite.
    define buffer local          for local.
    define buffer ctrat          for ctrat.   /* dernier contrat bail non annulé sur l'UL */
    define buffer vbLastCtrat    for ctrat.   /* dernier contrat bail sur l'UL */
    define buffer vbRoles        for roles.
    define buffer intnt          for intnt.
    define buffer ctctt          for ctctt.
    define buffer cpuni          for cpuni.
    define buffer gl_finance     for gl_finance.

    /* Recherche du nombre de pièces et de la surface habitable */
    /* c.f. getSurfaceUniteLocation */
blocUnite:
    for each ttUniteLocation
        where ttUniteLocation.CRUD = 'C':
        if not can-find(first ctrat no-lock
                        where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
                          and ctrat.nocon = ttUniteLocation.iNumeroContrat)
        then do:
            mError:createError({&error}, 106469, string(ttUniteLocation.iNumeroContrat)).
            leave blocUnite.
        end.
        /*--> Recherche infos concernant l'UL **/
        find first unite no-lock
            where unite.nomdt = ttUniteLocation.iNumeroContrat
              and unite.noapp = ttUniteLocation.iNumeroAppartement
              and unite.noact = 0 no-error.
        if not available unite
        then do:
            //UL [&1] inexistante pour le mandat  [&2].
            mError:createError({&error}, 1000221, substitute('&1&2', string(ttUniteLocation.iNumeroAppartement), string(ttUniteLocation.iNumeroContrat))).
        	leave blocUnite.
        end.
        assign
            viContratMin = unite.nomdt * 100000 + unite.noapp * 100
            viContratMax = viContratMin + 100
        .
        /* Recherche du dernier bail GI non annulé */
        {&_proparse_ prolint-nowarn(use-index)}
        for last ctrat no-lock
            where ctrat.tpcon = {&TYPECONTRAT-bail}
              and ctrat.nocon > viContratMin
              and ctrat.nocon < viContratMax
              and ctrat.ntcon <> {&NATURECONTRAT-specialVacant}
              and not ctrat.fgannul
            use-index ix_ctrat02: // index tpcon + nocon
            viNumeroRangPrecedent = ctrat.nocon modulo 100.
        end.

        /* Recherche du dernier rang du bail (annulé ou non) */
        viDernierNumeroRang = 0.
        {&_proparse_ prolint-nowarn(use-index)}
        for last vbLastCtrat no-lock
            where vbLastCtrat.tpcon = {&TYPECONTRAT-bail}
              and vbLastCtrat.nocon > viContratMin
              and vbLastCtrat.nocon < viContratMax
              and vbLastCtrat.ntcon <> {&NATURECONTRAT-specialVacant}
            use-index ix_ctrat02: // index tpcon + nocon
            viDernierNumeroRang = vbLastCtrat.nocon modulo 100.
        end.
        /* recherche si la fiche est déjà créée pour le même prochain rang */
        find first gl_fiche no-lock
            where gl_fiche.tpcon = {&TYPECONTRAT-mandat2Gerance}
              and gl_fiche.nocon = ttUniteLocation.iNumeroContrat
              and gl_fiche.noapp = ttUniteLocation.iNumeroAppartement no-error.
        if available gl_fiche and gl_fiche.noconloc = viContratMin + viDernierNumeroRang + 1 then leave blocUnite.

        if available gl_fiche then ttUniteLocation.iNumeroFicheCom = gl_fiche.nofiche.
        /* Recherche du nombre de pièces et de la surface habitable */
        /* c.f. getSurfaceUniteLocation */
        for each cpuni no-lock
        	where cpuni.nomdt = unite.nomdt
              and cpuni.noapp = unite.noapp
              and cpuni.nocmp = unite.nocmp
          , first Local no-lock
            where local.noimm = cpuni.noimm
              and local.nolot = cpuni.nolot:
            assign
                viNombrePieces       = viNombrePieces + local.nbprf
                vdSurfaceUtileTotale = vdSurfaceUtileTotale + if Local.fgdiv then cpuni.sflot else outilFormatage:ConvSurface(local.sfree, local.usree)
            .
        end.
        find first gl_fiche exclusive-lock
            where gl_fiche.tpcon = {&TYPECONTRAT-mandat2Gerance}
              and gl_fiche.nocon = ttUniteLocation.iNumeroContrat
              and gl_fiche.noapp = ttUniteLocation.iNumeroAppartement no-error.
        if available gl_fiche then do:
            assign
                vlNouvFiche              = no
                viNextNumeroFiche        = gl_fiche.nofiche
                ttUniteLocation.iNumeroFicheCom = viNextNumeroFiche
            /*--> RAZ de la fiche **/
                gl_fiche.tpcon           = {&TYPECONTRAT-mandat2Gerance}
                gl_fiche.nocon           = ttUniteLocation.iNumeroContrat
                gl_fiche.noapp           = ttUniteLocation.iNumeroAppartement
                gl_fiche.cdcmp           = unite.cdcmp
                gl_fiche.nbpiece         = viNombrePieces
                gl_fiche.surfhab         = vdSurfaceUtileTotale
                /*gl_fiche.nbphoto         = routine prête voir NL */
                gl_fiche.tpconloc        = {&TYPECONTRAT-bail}
                gl_fiche.noconloc        = viContratMin + viDernierNumeroRang + 1
                gl_fiche.typfiche        = piTypFiche /* 1 = Location  */
                gl_fiche.nomodecreation  = ttUniteLocation.iNoModeCreation
                gl_fiche.nozonealur      = 0
                gl_fiche.titre_comm      = ""
                gl_fiche.texte_comm      = ""
                gl_fiche.texte_gestion   = ""
                gl_fiche.loy_preco       = 0
                gl_fiche.texte_loy_preco = ""
                gl_fiche.fgvac_locative  = false
                gl_fiche.fgloy_impaye    = false
                gl_fiche.dtmsy           = today
                gl_fiche.hemsy           = mtime
                gl_fiche.cdmsy           = mToken:cUser
            .
boucle:
            for each gl_libelle no-lock
                where gl_libelle.tpidt = {&TYPLIBELLE-workflow}
                   by gl_libelle.noordre:
                gl_fiche.noworkflow = gl_libelle.noidt.
                leave boucle.
            end.
            /*--> création du prochain historique **/
            run createHisto (gl_fiche.nofiche, output viNextNumeroHisto).
            /* Locataire rattaché à la fiche */
            /* ok NL  ---> NON car que dans le rang de la table sequence */
            for each gl_fiche_tiers exclusive-lock
                where gl_fiche_tiers.nofiche      = gl_fiche.nofiche
                  //and gl_fiche_tiers.tprole  = {&TYPEROLE-locataire}      NPO nécessaire ???
                  and gl_fiche_tiers.tprolefiche  = {&TYPEROLE-locataire}
                  and gl_fiche_tiers.nohisto      = 0:
                assign
                    gl_fiche_tiers.nohisto = viNextNumeroHisto
                    gl_fiche_tiers.dtmsy   = today
                    gl_fiche_tiers.hemsy   = mtime
                    gl_fiche_tiers.cdmsy   = mToken:cUser
                .
            end.
            /* RAZ des tiers associés à la fiche */  /* ok NL */
            for each gl_fiche_tiers exclusive-lock
                where gl_fiche_tiers.nofiche = gl_fiche.nofiche
                  and gl_fiche_tiers.nohisto = 0:
                delete gl_fiche_tiers.
            end.
            /* au cas ou on historise qd même
            for each gl_fiche_tiers exclusive-lock
                where gl_fiche_tiers.nofiche = gl_fiche.nofiche
                  and gl_fiche_tiers.nohisto = 0:
                assign
                    gl_fiche_tiers.nohisto = iNextNumeroHisto
                    gl_fiche_tiers.dtmsy   = today
                    gl_fiche_tiers.hemsy   = mtime
                    gl_fiche_tiers.cdmsy   = mToken:cUser
                    .
            end. */
            /* Vue Situation financière */ /* ok NL */
            for each gl_finance exclusive-lock
                where gl_finance.nofiche = gl_fiche.nofiche
                  and gl_finance.nohisto = 0:
                assign
                    gl_finance.nohisto = viNextNumeroHisto
                    gl_finance.dtmsy   = today
                    gl_finance.hemsy   = mtime
                    gl_finance.cdmsy   = mToken:cUser
                .
            end.
            /* Séquence */
            for each gl_sequence exclusive-lock
                where gl_sequence.nofiche = gl_fiche.nofiche
                  and gl_sequence.nohisto = 0:
                assign
                    gl_sequence.nohisto = viNextNumeroHisto
                    gl_sequence.dtmsy   = today
                    gl_sequence.hemsy   = mtime
                    gl_sequence.cdmsy   = mToken:cUser
                .
            end.
        end.
        else do:   /* La fiche n'existe pas */
            /*--> Recherche du prochain numéro de fiche **/
            assign
                vlNouvFiche                     = yes
                viNextNumeroFiche               = igetNextSequence('gl_fiche', 'nofiche')
                ttUniteLocation.iNumeroFicheCom = viNextNumeroFiche
            .
            /* Création de la fiche */
            create gl_fiche.
            assign
                gl_fiche.nofiche  = viNextNumeroFiche
                gl_fiche.tpcon    = {&TYPECONTRAT-mandat2Gerance}
                gl_fiche.nocon    = ttUniteLocation.iNumeroContrat
                gl_fiche.noapp    = ttUniteLocation.iNumeroAppartement
                gl_fiche.cdcmp    = unite.cdcmp
                gl_fiche.nbpiece  = viNombrePieces
                gl_fiche.surfhab  = vdSurfaceUtileTotale
                /*gl_fiche.nbphoto  = routine prête voir NL */
                gl_fiche.tpconloc = {&TYPECONTRAT-bail}
                gl_fiche.noconloc = viContratMin + viDernierNumeroRang + 1
                gl_fiche.typfiche = piTypFiche      /* 1 = Location  */
                gl_fiche.nomodecreation = ttUniteLocation.iNoModeCreation
                gl_fiche.dtcsy      = today
                gl_fiche.hecsy      = mtime
                gl_fiche.cdcsy      = mToken:cUser
                gl_fiche.dtmsy      = today
                gl_fiche.hemsy      = mtime
                gl_fiche.cdmsy      = mToken:cUser
            .
boucle:
            for each gl_libelle no-lock
                where gl_libelle.tpidt = {&TYPLIBELLE-workflow}
                   by gl_libelle.noordre:
                gl_fiche.noworkflow = gl_libelle.noidt.
                leave boucle.
            end.
        end.
        mError:createInfoRowid(rowid(gl_fiche)).
        /*--> Création NEXT HISTO + NEXT SEQUENCE si bail déjà existant dans GI **/
        if viNumeroRangPrecedent > 0
        and not can-find(first gl_sequence no-lock
            where gl_sequence.nofiche = viNextNumeroFiche
              and gl_sequence.norang  = viNumeroRangPrecedent)
        then do:
            /*--> création du prochain historique **/
            run createHisto(viNextNumeroFiche, output viNextNumeroHisto).
            run createMajSequence(viNextNumeroFiche, ttUniteLocation.iNumeroContrat, ttUniteLocation.iNumeroAppartement, viNumeroRangPrecedent, viNextNumeroHisto).
        end.

        if vlNouvFiche and viNextNumeroHisto > 0 then run createAncLoyer(buffer gl_fiche, viNextNumeroHisto).
        /*--> Création NEXT SEQUENCE pour prochain rang (ENCOURS) **/
        run createMajSequence (viNextNumeroFiche, ttUniteLocation.iNumeroContrat, ttUniteLocation.iNumeroAppartement, viDernierNumeroRang + 1, 0).
        /*--> Je (re)charge les tiers PROPRIO SERVICE GESTION ET GESTIONNAIRE rattachés à la fiche */
        /* Mandant coté GI */
        for first intnt no-lock
            where intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
              and intnt.nocon = ttUniteLocation.iNumeroContrat
              and intnt.tpidt = {&TYPEROLE-mandant} :
            run createTiersFiche(viNextNumeroFiche, intnt.tpidt, intnt.tpidt, intnt.noidt).
        end.

        /* Service de Gestion GI "00048"  et Gestionnaire "00047" */
        for each ctctt no-lock
            where ctctt.tpct1 = {&TYPECONTRAT-serviceGestion}
              and ctctt.tpct2 = {&TYPECONTRAT-mandat2Gerance}
              and ctctt.noct2 = ttUniteLocation.iNumeroContrat
          , first ctrat no-lock
            where ctrat.tpcon = ctctt.tpct1
              and ctrat.nocon = ctctt.noct1:
            run createTiersFiche(viNextNumeroFiche, {&TYPEROLE-agenceGestion}, {&TYPEROLE-agenceGestion}, ctctt.noct1).
            if can-find(first roles no-lock
                where roles.tprol = ctrat.tprol
                  and roles.norol = ctrat.norol)
            then run createTiersFiche(viNextNumeroFiche, {&TYPEROLE-gestionnaire}, {&TYPEROLE-gestionnaire}, ctrat.norol).
        end.

        // SPo 10/04/2017 : Tiers apporteur (par défaut le cabinet)
        for first vbRoles no-lock
            where vbRoles.tprol = {&TYPEROLE-mandataire}
              and vbRoles.norol = 1:
            /** NPO plus de création de role Tiers Apporteur
            define variable vhProcRole            as handle  no-undo.    //   <-- à remonter
            define variable viNumeroRoleApporteur as int64   no-undo.    //   <-- à remonter
            define buffer vb2roles         for roles.                    //   <-- à remonter
            run role/roles_CRUD.p persistent set vhProcRole.
            run getTokenInstance in vhProcRole(mToken:JSessionId).
                find first vb2roles no-lock
                where vb2roles.tprol = {&TYPEROLE-tiersApporteur}
                and   vb2roles.notie = vbRoles.notie
                no-error.
            if not available vb2roles then do:
message "duplication role cabinet  -> role tiersApporteur " view-as alert-box.
                run dupliRoles in vhProcRole (vbRoles.tprol, vbRoles.norol, {&TYPEROLE-tiersApporteur}, no , output viNumeroRoleApporteur).
                run destroy in vhProcRole.
message "Apres duplication role cabinet " viNumeroRoleApporteur view-as alert-box.
            end.
            find first vb2roles no-lock
                where vb2roles.tprol = {&TYPEROLE-tiersApporteur}
                and   vb2roles.notie = vbRoles.notie
                no-error.
            if available vb2roles then do:****/
                //run createTiersFiche(viNextNumeroFiche, vb2roles.tprol, vb2roles.norol).
                run createTiersFiche(viNextNumeroFiche, {&TYPEROLE-tiersApporteur}, vbRoles.tprol, vbRoles.norol).
            /*end.*/
        end.
    end. /* for each ttUniteLocation */

end procedure.

procedure createTiersFiche private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroFiche   as integer   no-undo.
    define input  parameter pcTypeRoleFiche as character no-undo.
    define input  parameter pcTypeRole      as character no-undo.
    define input  parameter piNumeroRole    as integer   no-undo.

    define buffer vbRoles        for roles.
    define buffer gl_fiche_tiers for gl_fiche_tiers.

    for first vbRoles no-lock
        where vbRoles.tprol = pcTypeRole
          and vbRoles.norol = piNumeroRole:
        if not can-find(first gl_fiche_tiers no-lock
           where gl_fiche_tiers.nofiche     = piNumeroFiche
             and gl_fiche_tiers.nohisto     = 0
             and gl_fiche_tiers.tprolefiche = pcTypeRoleFiche
             and gl_fiche_tiers.norol       = piNumeroRole
             and gl_fiche_tiers.tprol       = pcTypeRole)
        then do:
            create gl_fiche_tiers.
            assign
                gl_fiche_tiers.nofiche     = piNumeroFiche
                gl_fiche_tiers.tprolefiche = pcTypeRoleFiche
                gl_fiche_tiers.norol       = piNumeroRole
                gl_fiche_tiers.tprol       = pcTypeRole
                gl_fiche_tiers.tptiers     = {&TYPETIERS-tiersRoleGI}
                gl_fiche_tiers.soccd       = ""
                gl_fiche_tiers.dtcsy       = today
                gl_fiche_tiers.hecsy       = mtime
                gl_fiche_tiers.cdcsy       = mToken:cUser
                gl_fiche_tiers.dtmsy       = gl_fiche_tiers.dtcsy
                gl_fiche_tiers.hemsy       = gl_fiche_tiers.hecsy
                gl_fiche_tiers.cdmsy       = gl_fiche_tiers.cdcsy
            .
        end.
    end.

end procedure.

procedure createMajSequence private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroFiche  as integer no-undo.
    define input  parameter piNumeroMandat as integer no-undo.
    define input  parameter piNumeroUL     as integer no-undo.
    define input  parameter piNumeroRang   as integer no-undo.
    define input  parameter piNumeroHisto  as integer no-undo.

    define variable viNextNumeroSequence as integer no-undo.

    define buffer gl_sequence for gl_sequence.
    define buffer tache       for tache.

     /* Recherche info bail */
    find last tache no-lock
        where tache.tpcon = {&TYPECONTRAT-bail}
          and tache.nocon = piNumeroMandat * 100000 + piNumeroUL * 100 + piNumeroRang
          and tache.tptac = {&TYPETACHE-quittancement} no-error.
    find first gl_sequence exclusive-lock
        where gl_sequence.nofiche = piNumeroFiche
          and gl_sequence.norang  = piNumeroRang no-error.
    if not available gl_sequence
    then do:
        /* Recherche de la prochaine séquence pour le rang */
        viNextNumeroSequence = igetNextSequence('gl_sequence', 'nosequence').
        create gl_sequence.
        assign
            gl_sequence.nosequence = viNextNumeroSequence
            gl_sequence.nofiche    = piNumeroFiche
            gl_sequence.norang     = piNumeroRang
            gl_sequence.nohisto    = piNumeroHisto
            gl_sequence.dtcsy      = today
            gl_sequence.hecsy      = mtime
            gl_sequence.cdcsy      = mToken:cUser
        .
    end.
    assign
        gl_sequence.dtentree = (if available tache then tache.dtdeb else ?)
        gl_sequence.dtsortie = (if available tache then tache.dtfin else ?)
        gl_sequence.dtmsy    = today
        gl_sequence.hemsy    = mtime
        gl_sequence.cdmsy    = mToken:cUser
    .
end procedure.

procedure createHisto private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroFiche     as integer no-undo.
    define output parameter piNextNumeroHisto as integer no-undo.

    define variable viNextNumeroHisto     as integer no-undo.
    define buffer gl_histo for gl_histo.

    /*--> Recherche du prochain historique **/
    viNextNumeroHisto = igetNextSequence('gl_histo', 'nohisto').
    create gl_histo.
    assign
        gl_histo.nohisto  = viNextNumeroHisto
        gl_histo.nofiche  = piNumeroFiche
        gl_histo.dtcsy    = today
        gl_histo.hecsy    = mtime
        gl_histo.cdcsy    = mToken:cUser
        gl_histo.dtmsy    = today
        gl_histo.hemsy    = mtime
        gl_histo.cdmsy    = mToken:cUser
        piNextNumeroHisto = viNextNumeroHisto
    .
end procedure.

procedure createAncLoyer private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer gl_fiche for gl_fiche.
    define input parameter piNumeroHisto as integer no-undo.

    define variable vhProc as handle no-undo.

    define buffer gl_finance for gl_finance.
    define buffer gl_loyer for gl_loyer.
    define buffer gl_detailfinance for gl_detailfinance.
    define buffer tache for tache.

    create gl_finance.
    assign
        gl_finance.nofinance = igetNextSequence('gl_finance', 'nofinance')
        gl_finance.tpfinance = {&TYPEFINANCE-LOYER}
        gl_finance.nofiche   = gl_fiche.nofiche
        gl_finance.nohisto   = piNumeroHisto
        gl_finance.dtcsy     = today
        gl_finance.hecsy     = mtime
        gl_finance.cdcsy     = mToken:cUser
        gl_finance.dtmsy     = gl_finance.dtcsy
        gl_finance.hemsy     = gl_finance.hecsy
        gl_finance.cdmsy     = mToken:cUser
    .
    create gl_loyer.
    assign
        gl_loyer.noloyer   = igetNextSequence('gl_loyer', 'noloyer')
        gl_loyer.nofinance = gl_finance.nofinance
        gl_loyer.tployer   = 0
        gl_loyer.dtcsy     = today
        gl_loyer.hecsy     = mtime
        gl_loyer.cdcsy     = mToken:cUser
        gl_loyer.dtmsy     = gl_loyer.dtcsy
        gl_loyer.hemsy     = gl_loyer.hecsy
        gl_loyer.cdmsy     = mToken:cUser
    .
    create gl_detailfinance.
    assign
        gl_detailfinance.nodetailfinance = igetNextSequence('gl_detailfinance', 'nodetailfinance')
        gl_detailfinance.nofinance       = gl_finance.nofinance
        gl_detailfinance.nochpfinance    = 10001
        gl_detailfinance.dtcsy           = today
        gl_detailfinance.hecsy           = mtime
        gl_detailfinance.cdcsy           = mToken:cUser
        gl_detailfinance.dtmsy           = gl_detailfinance.dtcsy
        gl_detailfinance.hemsy           = gl_detailfinance.hecsy
        gl_detailfinance.cdmsy           = mToken:cUser
    .
    run bail/bail.p persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    run readBail in vhProc(gl_fiche.TpConLoc, gl_fiche.NoConLoc - 1, output table ttBail by-reference).
    for first ttbail:
        assign
            gl_loyer.loyerhc_ht        = ttbail.dMontantLoyer / ttbail.iNombreMoisQuitt
            gl_loyer.charge_ht         = ttbail.dMontantCharge
            gl_loyer.totalht           = gl_loyer.loyerhc_ht + gl_loyer.charge_ht
            gl_loyer.loyercc_annuel    = ttbail.dMontantLoyerAnnuel
            gl_detailfinance.montantht = gl_loyer.loyerhc_ht
        .
    end.
    for last tache no-lock
        where tache.tpcon = {&TYPECONTRAT-bail}
          and tache.nocon = gl_fiche.NoConLoc - 1
          and tache.tptac = {&TYPETACHE-revision}:
        assign
            gl_loyer.indice_rev   = decimal(entry(2,entry(2,tache.lbdiv,"&"),"#"))
            gl_loyer.lbindice_rev = substitute('&1T&2', tache.ntreg, tache.cdreg)
            gl_loyer.dtindice_rev = tache.dtdeb
        .
    end.
    run destroy in vhProc.

end procedure.
