/*------------------------------------------------------------------------
File        : roleAnnexeContrat.p
Purpose     : role annexe d'un contrat
Author(s)   : GGA  -  2017/08/31
Notes       : reprise du pgm adb/cont/gesanx00.p
derniere revue: 2018/12/11 - GGa/SPo: OK
------------------------------------------------------------------------*/
{preprocesseur/referenceClient.i}
using parametre.pclie.parametragePrelevementAutomatique.
using parametre.syspg.syspg.
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2gerance.i}
{preprocesseur/mode2reglement.i}
{preprocesseur/mode2envoiQuitt.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/glbsepar.i}
{application/include/combo.i}
{contrat/include/roleContrat.i &nomtable=ttRoleAnnexe}
{crud/include/intnt.i}
{crud/include/coloc.i}
{crud/include/cttac.i}
{tache/include/tache.i}

{comm/include/fctdatin.i}

procedure getRoleAnnexe:
    /*------------------------------------------------------------------------------
    Purpose: affichage role annexe d'un contrat
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter pcTypeRole      as character no-undo.
    define output parameter table for ttRoleAnnexe.

    define buffer ctrat for ctrat.
    define buffer intnt for intnt.

    empty temp-table ttRoleAnnexe.
    find first ctrat no-lock
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroContrat no-error.
    if not available ctrat then do:
        mError:createError({&error}, 100057).
        return.
    end.
    run chargeCombo (ctrat.tpcon, ctrat.ntcon, ctrat.nocon, ctrat.tpgerance, "").     //on conserve l'utilisation de la combo car plus facile de retrouver les roles annexes
    for each ttCombo
        where ttCombo.cNomCombo = "CMBROLEANNEXE"
          and ttCombo.cCode = (if pcTypeRole > "" then pcTypeRole else ttCombo.cCode)
      , each intnt no-lock
        where intnt.tpcon = ctrat.tpcon
          and intnt.nocon = ctrat.nocon
          and intnt.tpidt = ttCombo.cCode:
        create ttRoleAnnexe.
        assign
            ttRoleAnnexe.cTypeContrat   = intnt.tpcon
            ttRoleAnnexe.iNumeroContrat = intnt.nocon
            ttRoleAnnexe.cTypeRole      = intnt.tpidt
            ttRoleAnnexe.cLibTypeRole   = outilTraduction:getLibelleProgZone2("R_CR2", ctrat.ntcon, intnt.tpidt)
            ttRoleAnnexe.iNumeroRole    = intnt.noidt
            ttRoleAnnexe.cNom           = outilFormatage:getNomTiers(intnt.tpidt, intnt.noidt)
            ttRoleAnnexe.cAdresse       = outilFormatage:formatageAdresse(intnt.tpidt, intnt.noidt)
            ttRoleAnnexe.dtTimestamp    = datetime(intnt.dtmsy, intnt.hemsy)
            ttRoleAnnexe.CRUD           = "R"
            ttRoleAnnexe.rRowid         = rowid(intnt)
        .
    end.
end procedure.

procedure setRoleAnnexe:
    /*------------------------------------------------------------------------------
    Purpose: maj role annexe d'un contrat
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table for ttRoleAnnexe.

    define variable vhIntnt         as handle  no-undo.
    define variable vhAlimaj        as handle  no-undo.
    define variable vhMandatSepa    as handle  no-undo.
    define variable vhColoc         as handle  no-undo.
    define variable vlCreationColoc as logical no-undo.
    define variable vdaDebut        as date    no-undo.

    define buffer ctrat   for ctrat.
    define buffer intnt   for intnt.
    define buffer coloc   for coloc.
    define buffer vbRoles for roles.

    empty temp-table ttIntnt.
    empty temp-table ttColoc.
    find first ttRoleAnnexe where lookup(ttRoleAnnexe.crud, "C,D") > 0 no-error.
    if not available ttRoleAnnexe then return.

    find first ctrat no-lock
        where ctrat.tpcon = ttRoleAnnexe.cTypeContrat
          and ctrat.nocon = ttRoleAnnexe.iNumeroContrat no-error.
    if not available ctrat then do:
        mError:createError({&error}, 100057).
        return.
    end.
    vdaDebut = (if ctrat.dtini <> ? then ctrat.dtini else today).             // si création alors ctrat est vide => il faut une date de début valide quand même
    run chargeCombo(ctrat.tpcon, ctrat.ntcon, ctrat.nocon, ctrat.tpgerance, "").  //on conserve l'utilsation de la combo car plus facile de controler les roles annexes
blocMiseAJour:
    do:
        for each ttRoleAnnexe
            where ttRoleAnnexe.crud = 'C':
            if not can-find(first ttCombo
                            where ttCombo.cNomCombo = "CMBROLEANNEXE"
                              and ttCombo.cCode     = ttRoleAnnexe.cTypeRole) then do:
                mError:createError({&error}, 1000592, ttRoleAnnexe.cTypeRole).         //type de rôle &1 interdit
                leave blocMiseAJour.
            end.
            if not can-find(first vbroles no-lock
                            where vbroles.tprol = ttRoleAnnexe.cTypeRole
                              and vbRoles.norol = ttRoleAnnexe.iNumeroRole) then do:
                mError:createError({&error}, 1000599, substitute('&2&1&3', separ[1], ttRoleAnnexe.cTypeRole, ttRoleAnnexe.iNumeroRole)).      //rôle &1 &2 inexistant
                leave blocMiseAJour.
            end.

            for first intnt no-lock
                    where Intnt.tpidt = ttRoleAnnexe.cTypeRole
                      and Intnt.noidt = ttRoleAnnexe.iNumeroRole
                      and Intnt.tpcon = ttRoleAnnexe.cTypeContrat
                      and Intnt.nocon = ttRoleAnnexe.iNumeroContrat
                      and Intnt.nbnum = (if ttRoleAnnexe.cTypeRole = {&TYPEROLE-colocataire}
                                          then date2Integer(vdaDebut)
                                          else 0)
                      and intnt.idsui = 0
                      and intnt.idpre = 0:
                if not can-find(first ttRoleAnnexe where ttRoleAnnexe.rRowid = rowid(intnt) and ttRoleAnnexe.crud = "D")
                then do :
                    mError:createError({&error}, 1000937, substitute('&2&1&3',
                                                                     separ[1],
                                                                     outilTraduction:getLibelleProgZone2("R_CR2", ctrat.ntcon, intnt.tpidt),
                                                                     substitute("&1-&2-&3-&4",
                                                                                intnt.tpcon,
                                                                                intnt.nocon,
                                                                                intnt.noidt,
                                                                                intnt.nbnum))).      // "&1 déjà existant sur ce contrat (&2)"
                    leave blocMiseAJour.
                end.
            end.
            if ttRoleAnnexe.cTypeRole = {&TYPEROLE-colocataire} then vlCreationColoc = true.
            create ttIntnt.
            assign
                ttIntnt.tpidt = ttRoleAnnexe.cTypeRole
                ttIntnt.noidt = ttRoleAnnexe.iNumeroRole
                ttIntnt.tpcon = ttRoleAnnexe.cTypeContrat
                ttIntnt.nocon = ttRoleAnnexe.iNumeroContrat
                ttIntnt.nbnum = if ttRoleAnnexe.cTypeRole = {&TYPEROLE-colocataire}
                                then date2Integer(vdaDebut)
                                else 0
                ttIntnt.nbden = 0
                ttIntnt.idpre = 0
                ttIntnt.idsui = 0
                ttIntnt.cdreg = ""
                ttIntnt.lbdiv = ""
                ttIntnt.CRUD  = 'C'
            .
        end.
        for each ttRoleAnnexe
            where ttRoleAnnexe.crud = 'D':
            find first intnt no-lock
                where rowid(intnt) = ttRoleAnnexe.rRowid no-error.
            if not available intnt then do:
                mError:createError({&error}, 1000208, string(ttRoleAnnexe.iNumeroRole)).
                leave blocMiseAJour.
            end.
            if can-find(first coloc no-lock                           //Vérification que le colocataire n'est pas dans une répartition historisée
                        where coloc.tpidt = ttRoleAnnexe.cTypeRole
                          and coloc.noidt = ttRoleAnnexe.iNumeroRole
                          and coloc.tpcon = ttRoleAnnexe.cTypeContrat
                          and coloc.nocon = ttRoleAnnexe.iNumeroContrat
                          and coloc.noqtt > 0) then do:
                mError:createError({&error}, 1000591).              //Suppression impossible car le colocataire est présent dans une répartition historisée
                leave blocMiseAJour.
            end.
            create ttIntnt.
            assign
                ttIntnt.tpidt       = intnt.tpidt
                ttIntnt.noidt       = intnt.noidt
                ttIntnt.tpcon       = intnt.tpcon
                ttIntnt.nocon       = intnt.nocon
                ttIntnt.nbnum       = intnt.nbnum
                ttIntnt.idpre       = intnt.idpre
                ttIntnt.idsui       = intnt.idsui
                ttIntnt.dtTimestamp = datetime(intnt.dtmsy, intnt.hemsy)
                ttIntnt.rRowid      = rowid(intnt)
                ttIntnt.CRUD        = 'D'
            .
            /* Suppression de l'entete du colocataire */
            for first coloc no-lock
                where coloc.tpidt = ttRoleAnnexe.cTypeRole
                  and coloc.noidt = ttRoleAnnexe.iNumeroRole
                  and coloc.tpcon = ttRoleAnnexe.cTypeContrat
                  and coloc.nocon = ttRoleAnnexe.iNumeroContrat
                  and coloc.noqtt = 0:
                create ttColoc.
                assign
                    ttColoc.tpcon       = coloc.tpcon
                    ttColoc.nocon       = coloc.nocon
                    ttColoc.msqtt       = coloc.msqtt
                    ttColoc.noord       = coloc.noord
                    ttColoc.tpidt       = coloc.tpidt
                    ttColoc.noidt       = coloc.noidt
                    ttColoc.dtTimestamp = datetime(coloc.dtmsy, coloc.hemsy)
                    ttColoc.rRowid      = rowid(coloc)
                    ttColoc.CRUD        = 'D'
                .
            end.

            /* Ajout SY le 26/07/2013 : SEPA */
            if not valid-handle(vhMandatSepa) then do:
                run "crud/mandatSEPA_CRUD.p" persistent set vhMandatSepa.
                run getTokenInstance in vhMandatSepa (mToken:JSessionId).
            end.
            run deleteMandatSepaRoleContrat in vhMandatSepa({&TYPECONTRAT-sepa}, ttRoleAnnexe.cTypeContrat, ttRoleAnnexe.iNumeroContrat, ttRoleAnnexe.cTypeRole, ttRoleAnnexe.iNumeroRole).
            if mError:erreur() then leave blocMiseAJour.
            /* todo : sujet à aborder en point technique : normalement plus de mise à jour "SITE CENTRAL"
            if not valid-handle(vhAlimaj) then do:
                run "application/transfert/GI_alimaj.p" persistent set vhAlimaj.
                run getTokenInstance in vhAlimaj (mToken:JSessionId).
            end.
            run majTrace in vhAlimaj (integer(mToken:cRefGerance), 'sadb', 'ctrat', string(ctrat.nodoc, '>>>>>>>>9')).
            if mError:erreur() then leave blocMiseAJour.*/
        end.
        if can-find(first ttIntnt) then do:
            run crud/intnt_CRUD.p persistent set vhIntnt.
            run getTokenInstance in vhIntnt(mToken:JSessionId).
            run setIntnt in vhIntnt(table ttIntnt by-reference).
            if mError:erreur() then leave blocMiseAJour.
        end.
        if can-find(first ttColoc) then do:
            run crud/coloc_CRUD.p persistent set vhColoc.
            run getTokenInstance in vhColoc (mToken:JSessionId).
            run setColoc in vhColoc(table ttColoc by-reference).
            if mError:erreur() then leave blocMiseAJour.
        end.
        run gereColocation(buffer ctrat, vlCreationColoc).
    end.
    if valid-handle(vhMandatSepa) then run destroy in vhMandatSepa.
    if valid-handle(vhAlimaj)     then run destroy in vhAlimaj.
    if valid-handle(vhIntnt)      then run destroy in vhIntnt.
    if valid-handle(vhColoc)      then run destroy in vhColoc.

    error-status:error = false no-error.  // reset error-status
    return.

end procedure.

procedure initComboRoleAnnexe:
    /*------------------------------------------------------------------------------
    Purpose: Liste des roles annexes d'un contrat
    Notes  : service externe (beMandatGerance.cls, beAssuranceImmeuble.cls etc...)
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter pcNatureContrat as character no-undo.
    define output parameter table for ttCombo.

    define variable vcFiltreRole as character no-undo.

    define buffer ctrat for ctrat.

    if lookup(pcTypeContrat, substitute("&1,&2",{&TYPECONTRAT-bail},{&TYPECONTRAT-prebail})) > 0
    then vcFiltreRole = {&TYPEROLE-garant}. // Pour bail et pré bail, on retire de la combo le type de role Garant, il sera géré via la tâche garant
    find first ctrat no-lock
         where ctrat.tpcon = pcTypeContrat
           and ctrat.nocon = piNumeroContrat no-error.
    if available ctrat
    then run chargeCombo(ctrat.tpcon,   ctrat.ntcon,     ctrat.nocon,     ctrat.tpgerance, vcFiltreRole).
    else run chargeCombo(pcTypeContrat, pcNatureContrat, piNumeroContrat, "", vcFiltreRole).
    error-status:error = false no-error.  // reset error-status
    return.

end procedure.

procedure chargeCombo private:
    /*------------------------------------------------------------------------------
    Purpose: Liste des roles annexes autorisés pour ce contrat
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter pcNatureContrat as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeGerance   as character no-undo.
    define input parameter pcTypeRoleExclu as character no-undo.

    define variable vlGerantExterne as logical no-undo.
    define variable voSyspg         as class syspg no-undo.

    define buffer intnt  for intnt.
    define buffer sys_pg for sys_pg.

    empty temp-table ttCombo.
    voSyspg = new syspg().
    if pcTypeContrat = {&TYPECONTRAT-mandat2Gerance}
    and lookup(mtoken:cRefGerance, "{&REFCLIENT-ALLIANZ},{&REFCLIENT-ALLIANZRECETTE},{&REFCLIENT-GIDEV},{&REFCLIENT-GICLI}") > 0
    then if pcTypeGerance = {&TYPE2GERANCE-externePartielle} or pcTypeGerance = {&TYPE2GERANCE-externeTotale}
        then vlGerantExterne = yes.
        else for first intnt no-lock
            where intnt.tpcon = pcTypeContrat
              and intnt.nocon = piNumeroContrat
              and intnt.tpidt = {&TYPEROLE-gerantExterne}:
            vlGerantExterne = yes.
        end.
boucle:
    for each sys_pg no-lock
        where sys_pg.tppar = "R_CR2"
          and sys_pg.zone1 = pcNatureContrat:
        if (sys_pg.zone2 = {&TYPEROLE-gerantExterne} and not vlGerantExterne ) 
        or sys_pg.zone2 = pcTypeRoleExclu
        then next boucle.
        voSyspg:creationttCombo("CMBROLEANNEXE", sys_pg.zone2, outilTraduction:getLibelle(sys_pg.nome1), output table ttCombo by-reference).
    end.
    delete object voSyspg.

end procedure.

procedure gereColocation private :
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : à partir de la procedure GereColocation de gesanx00_srv.p
    ------------------------------------------------------------------------------*/
    define parameter buffer ctrat for ctrat.
    define input parameter pvlCreationColoc as logical no-undo.

    define variable vhprocTache as handle no-undo.
    define variable vhprocCttac as handle no-undo.

    define buffer tache for tache.
    define buffer intnt for intnt.

    empty temp-table ttTache.
    empty temp-table ttCttac.

    run crud/tache_CRUD.p persistent set vhprocTache.
    run getTokenInstance in vhprocTache(mToken:JSessionId).
    run crud/cttac_CRUD.p persistent set vhprocCttac.
    run getTokenInstance in vhprocCttac(mToken:JSessionId).

    if available ctrat and (ctrat.tpcon = {&TYPECONTRAT-bail} or ctrat.tpcon = {&TYPECONTRAT-preBail}) then
blocMiseAJour : do :
        if not can-find(first tache no-lock
                        where tache.tpcon = ctrat.tpcon
                          and tache.nocon = ctrat.nocon
                          and tache.tptac = {&TYPETACHE-Colocation})
        and can-find(first intnt no-lock
                     where intnt.tpcon = ctrat.tpcon
                       and intnt.nocon = ctrat.nocon
                       and intnt.tpidt = {&TYPEROLE-colocataire})
        then do:
            create ttTache.
            assign
                ttTache.tpcon = ctrat.tpcon
                ttTache.nocon = ctrat.nocon
                ttTache.tptac = {&TYPETACHE-Colocation}
                ttTache.tpGes = {&non} // par défaut : gestion multiple des colocataires r 'Non'
                ttTache.CRUD  = "C"
            .
        end.
        if not can-find(first cttac
                        where cttac.tpcon = ctrat.tpcon
                          and cttac.nocon = ctrat.nocon
                          and cttac.tptac = {&TYPETACHE-Colocation})
        then do:
            create ttcttac.
            assign
                ttcttac.tpcon = ctrat.tpcon
                ttcttac.nocon = ctrat.nocon
                ttcttac.tptac = {&TYPETACHE-Colocation}
                ttcttac.CRUD  = "C"
            .
        end.
        run setTache in vhprocTache(table ttTache by-reference).
        if mError:erreur() then leave blocMiseAJour.
        run setCttac in vhprocCttac(table ttCttac by-reference).
        if mError:erreur() then leave blocMiseAJour.
        run initColocataires(buffer ctrat).
        if mError:erreur() then leave blocMiseAJour.
        if pvlCreationColoc then mError:createError({&information}, 111163). // Pensez à modifier la tache 'Colocation' pour prendre en compte les modifications faites
    end. // blocMiseAJour
    run destroy in vhprocTache.
    run destroy in vhprocCttac.
end procedure.

procedure initColocataires private :
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : à partir de la procedure InitColocataires de adb/cont/gesanx00_srv.p
    ------------------------------------------------------------------------------*/
    define parameter buffer ctrat for ctrat.
    
    define variable viBase                 as integer   no-undo.
    define variable viNumeroGarant         as int64     no-undo.
    define variable vcModeReglement        as character no-undo.
    define variable vdDateSortie           as date      no-undo.
    define variable viDefautJourPrel       as integer   no-undo.
    define variable viJourPrelevement      as integer   no-undo.
    define variable vcTypeRole             as character no-undo.
    define variable vhProcColoc            as handle    no-undo.
    define variable voParametrePrelevement as class     parametragePrelevementAutomatique no-undo.

    define buffer pclie for pclie.
    define buffer tache for tache.
    define buffer intnt for intnt.
    define buffer coloc for coloc.

    empty temp-table ttColoc.

    run crud/coloc_CRUD.p persistent set vhProcColoc.
    run getTokenInstance in vhProcColoc(mToken:JSessionId).

    assign
        voParametrePrelevement = new parametragePrelevementAutomatique()
    .
    assign  // assign séparé volontairement - sinon plantage
        viDefautJourPrel = voParametrePrelevement:getNombreJoursPrelevement() when voParametrePrelevement:isPrelevementAutomatique() // Récupération des infos sur le prélèvement automatique */
    .
    // Si pas de colocataire, on passe
    viBase = 1. /* Il faut compter au moins le locataire */
    for each intnt no-lock
       where intnt.tpcon = ctrat.tpcon
         and intnt.nocon = ctrat.nocon
         and intnt.tpidt = {&TYPEROLE-colocataire}:
        viBase = viBase + 1.
    end.
    // Récupération du 1er garant par defaut
    viNumeroGarant = 0.
    for first  intnt  no-lock
        where   intnt.tpcon = ctrat.tpcon
        and     intnt.nocon = ctrat.nocon
        and     intnt.tpidt = {&TYPEROLE-garant}:
        viNumeroGarant = intnt.noidt.
    end.
    // PL : 24/07/14 (0714/0240)
    assign
        vcTypeRole   = (if ctrat.tpcon = {&TYPECONTRAT-preBail} then {&TYPEROLE-candidatLocataire} else {&TYPEROLE-locataire})
        vdDateSortie = ctrat.dtree
        vcModeReglement = {&MODEREGLEMENT-cheque}
    .
    // Récupération de la tache quittancement
    for last tache no-lock
        where tache.tpcon = ctrat.tpcon
          and tache.nocon = ctrat.nocon
          and tache.tptac = {&TYPETACHE-quittancement}:
        assign
            vcModeReglement   = tache.cdreg
            viJourPrelevement = tache.duree
            viJourPrelevement = viDefautJourPrel when lookup(tache.cdreg, substitute("&1,&2",{&MODEREGLEMENT-prelevement},{&MODEREGLEMENT-prelevementMensuel})) > 0 and viJourPrelevement = 0 // SY 1013/0126
            vdDateSortie      = tache.dtfin when tache.dtfin <> ?
            vdDateSortie      = min(ctrat.dtree, tache.dtfin) when ctrat.dtree <> ? and tache.dtfin <> ?
        .
    end.
    // creation de l'entete locataire dans coloc
    find first coloc no-lock
         where coloc.tpcon = ctrat.tpcon
           and coloc.nocon = ctrat.nocon
           and coloc.tpidt = vcTypeRole
           and coloc.noidt = ctrat.nocon
           and coloc.msqtt = 0
           no-error.
    if not available coloc then do:
        create ttColoc.
        assign
            ttColoc.tpcon        = ctrat.tpcon
            ttColoc.nocon        = ctrat.nocon
            ttColoc.msqtt        = 0
            ttColoc.tpidt        = vcTypeRole
            ttColoc.noidt        = ctrat.nocon
            ttcoloc.noqtt        = 0
            ttcoloc.dtent        = (if ctrat.dtdeb  = ? then {&dateNulle} else ctrat.dtdeb)
            ttcoloc.dtsor        = (if vdDateSortie = ? then {&dateNulle} else vdDateSortie)
            ttcoloc.tprol-Garant = (if viNumeroGarant <> 0 then {&TYPEROLE-garant} else "")
            ttcoloc.norol-Garant = viNumeroGarant
            ttcoloc.fgQtt-Garant = false
            ttcoloc.qpColoc      = viBase
            ttcoloc.qpTotal      = viBase
            ttcoloc.mdEnv        = {&MODEENVOIQUIT-aucun}
            ttcoloc.mdreg        = vcModeReglement
            ttcoloc.jrpre        = viJourPrelevement
            ttColoc.CRUD         = 'C'
        .
    end.
    // creation des entetes colocataire dans coloc
    for each intnt no-lock
       where intnt.tpcon = ctrat.tpcon
         and intnt.nocon = ctrat.nocon
         and intnt.tpidt = {&TYPEROLE-colocataire}:
        find first coloc no-lock
             where coloc.tpcon = ctrat.tpcon
               and coloc.nocon = ctrat.nocon
               and coloc.tpidt = intnt.tpidt
               and coloc.noidt = intnt.noidt
               and coloc.msqtt = 0
               no-error.
        if not available coloc then do:
            create ttColoc.
            assign
                ttColoc.tpcon        = intnt.tpcon
                ttColoc.nocon        = intnt.nocon
                ttColoc.msqtt        = 0
                ttColoc.tpidt        = intnt.tpidt
                ttColoc.noidt        = intnt.noidt
                ttcoloc.noqtt        = 0
                ttcoloc.dtent        = (if intnt.nbnum > 0 then integer2Date(intnt.nbnum) else {&dateNulle})
                ttcoloc.dtsor        = (if intnt.nbden > 0 then integer2Date(intnt.nbden) else {&dateNulle})
                ttcoloc.tprol-Garant = ""
                ttcoloc.norol-Garant = 0
                ttcoloc.fgQtt-Garant = false
                ttcoloc.qpColoc      = 0
                ttcoloc.qpTotal      = viBase
                ttcoloc.mdEnv        = {&MODEENVOIQUIT-aucun}
                ttcoloc.mdreg        = {&MODEREGLEMENT-aucun}
                ttcoloc.jrpre        = 0
                ttcoloc.CRUD         = 'C'
            .
        end.
    end.
    run setColoc in vhProcColoc(table ttColoc by-reference).
    run destroy in vhProcColoc.
    delete object voParametrePrelevement.
end procedure.
