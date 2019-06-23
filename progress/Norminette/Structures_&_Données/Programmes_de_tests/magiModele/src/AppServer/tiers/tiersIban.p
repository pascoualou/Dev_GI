/*------------------------------------------------------------------------
File        : tiersIban.p
Purpose     :
Author(s)   : OFA - 2018/05/15
Notes       :
------------------------------------------------------------------------*/

using parametre.pclie.parametrageDefautMandat.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{tiers/include/tiersIban.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}
{preprocesseur/mode2reglement.i}
{preprocesseur/nature2contrat.i}
{application/include/glbsepar.i}
{crud/include/intnt.i}
{tache/include/tache.i}
{crud/include/rlctt.i}

function IsControleDesIbanActive returns logical ():
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define buffer parpaie for parpaie.

    find first parpaie no-lock
        where parpaie.soc-cd   = INT(mToken:cRefPrincipale)
          and parpaie.etab-cd  = 8500 no-error.
    if not available parpaie then
        find first parpaie no-lock
            where parpaie.soc-cd   = INT(mToken:cRefPrincipale) no-error. 

    return available parpaie and parpaie.rib-periode ne 0.

end function.

function isIbanUtiliseParUnContrat return character (piNumeroTiers as integer, piNumeroContratIban as integer):
/*------------------------------------------------------------------------------
 Purpose     : Contrôle de l'utilisation d'un RIB d'un tiers en virement ou en prélèvement pour un de ses roles
 Notes       : ancien programme lib/ctrbqu00.p
 Paramètre de sortie :
       vcChaineSortie
               (1) Liste des mandants utilisateurs
               (2) Liste des indivisaires utilisateurs
               (3) Liste des coproprietaires utilisateurs
               (4) Liste des locataires utilisateurs
               (6) Liste des Mandats utilisant cette banque en Virement CRG
 
------------------------------------------------------------------------------*/

    define variable vlIbanUtilise               as logical   no-undo.
    define variable vcChaineSortie              as character no-undo.
    define variable viNombreIbanDuTiers         as integer   no-undo.
    define variable vcModeReglement             as character no-undo.
    define variable vcListeModeReglement        as character no-undo.
    define variable vcListeMandants             as character no-undo.
    define variable vcListeIndivisaires         as character no-undo.
    define variable vcListeCoproprietaires      as character no-undo.
    define variable vcListeLocataires           as character no-undo.
    define variable vcListeMandats              as character no-undo.
    define variable vlModeReglementAutomatique  as logical   no-undo.
    define variable voDefautMandat              as class parametrageDefautMandat no-undo.
    
    define buffer ctanx for ctanx.
    define buffer vbRoles for roles.
    define buffer rlctt for rlctt.
    define buffer ctrat for ctrat.
    define buffer intnt for intnt.
    define buffer tache for tache.
    
    assign
        vlIbanUtilise       = no
        voDefautMandat      = new parametrageDefautMandat()
        vlModeReglementAutomatique = voDefautMandat:getIsModificationAutoModeReglementProprietaire()
        .

    for each ctanx no-lock
        where ctanx.tprol = {&TYPEROLE-tiers}
        and   ctanx.NoRol = piNumeroTiers
        and   ctanx.TpCon = {&TYPECONTRAT-RIB}:
        viNombreIbanDuTiers = viNombreIbanDuTiers + 1.
    end.

    for each vbRoles no-lock
        where vbRoles.notie = piNumeroTiers :
        // Recherche liens role-contrat-banque (rlctt)  (locataire, mandant, indiv., salari‚)
        for each rlctt no-lock
            where rlctt.tpidt = vbRoles.tprol
            and   rlctt.noidt = vbRoles.norol
            and   rlctt.tpct2 = {&TYPECONTRAT-RIB}
            and   rlctt.noct2 = piNumeroContratIban
            and   rlctt.tpct1 <> ""
            ,first ctrat no-lock
            where ctrat.tpcon = rlctt.tpct1
            and   ctrat.nocon = rlctt.noct1
            and   ctrat.norol = vbRoles.norol
            and   ctrat.dtree = ?
            by tpct1 by noct1:
            // Recherche du mode de règlement associé
            case rlctt.tpct1 :
                when {&TYPECONTRAT-titre2copro} then
                do:
                    if num-entries(ctrat.lbdiv,"@") >= 2 then
                    do:
                        vcListeModeReglement = entry(2,ctrat.lbdiv,"@").
                        if lookup({&MODEREGLEMENT-virement}, vcListeModeReglement, "#") > 0
                            or lookup({&MODEREGLEMENT-prelevement}, vcListeModeReglement, "#") > 0
                            or lookup({&MODEREGLEMENT-prelevementMensuelBudget}, vcListeModeReglement, "#") > 0 then
                            assign
                                vlIbanUtilise          = yes
                                vcListeCoproprietaires = substitute("&1, &2", vcListeCoproprietaires, outilFormatage:fSubstGestion(outilTraduction:getLibelle(105874), substitute("&1&2&3", string(vbRoles.norol), separ[1], string(ctrat.nocon)))) //Copropriétaire (ou indivisaire) %1 du Titre de copropriété %2
                                .
                    end.
                end.
                when {&TYPECONTRAT-mandat2Gerance} then
                do:
                    // mandat avec indivision
                    if ctrat.ntcon = {&NATURECONTRAT-mandatAvecIndivision} or ctrat.ntcon = {&NATURECONTRAT-mandatLocationIndivision} then
                        for first intnt no-lock
                            where intnt.tpcon = ctrat.tpcon
                            and   intnt.nocon = ctrat.nocon
                            and   Intnt.Tpidt = vbRoles.tprol
                            and   Intnt.noidt = vbRoles.norol
                            and   num-entries(intnt.lbdiv,"@") <> 0:
                            vcModeReglement = entry(1,intnt.lbdiv,"@").
                            if vcModeReglement = {&MODEREGLEMENT-virement} or vcModeReglement = {&MODEREGLEMENT-prelevement} or vcModeReglement = {&MODEREGLEMENT-prelevementMensuelBudget} then
                            do:
                                if vlModeReglementAutomatique = no or (vlModeReglementAutomatique = yes and vcModeReglement <> {&MODEREGLEMENT-virement}) then
                                    assign
                                        vlIbanUtilise   = yes
                                        vcListeMandants = substitute("&1, &2", vcListeMandants, outilFormatage:fSubstGestion(outilTraduction:getLibelle(105871), substitute("&1&2&3", string(vbRoles.norol), separ[1], string(ctrat.nocon)))) //Indivisaire %1 du mandat %2
                                        .
                                // maj liste des mandats utilisant le mode de reglement Virement pour le CRG
                                if vcModeReglement = {&MODEREGLEMENT-virement} and lookup(string(ctrat.nocon), vcListeMandats) = 0 then 
                                    vcListeMandats = substitute("&1, &2", vcListeMandats, string(ctrat.nocon)).
                            end.
                        end.
                    else
                        for first tache no-lock
                            where tache.tpcon = ctrat.tpcon
                            and   tache.nocon = ctrat.nocon
                            and   tache.tptac = {&TYPETACHE-compteRenduGestion}:
                            if Tache.ntreg = {&MODEREGLEMENT-virement} or Tache.ntreg = {&MODEREGLEMENT-prelevement} or Tache.ntreg = {&MODEREGLEMENT-prelevementMensuelBudget} then
                            do:
                                if vlModeReglementAutomatique = no or (vlModeReglementAutomatique = yes and Tache.ntreg <> {&MODEREGLEMENT-virement}) then
                                    assign
                                        vlIbanUtilise = yes
                                        vcListeMandants = substitute("&1, &2", vcListeMandants, outilFormatage:fSubstGestion(outilTraduction:getLibelle(105870), substitute("&1&2&3", string(vbRoles.norol), separ[1], string(ctrat.nocon))))
                                        .
                                // maj liste des mandats utilisant le mode de reglement Virement pour le CRG
                                if Tache.ntreg = {&MODEREGLEMENT-virement} and lookup(string(ctrat.nocon), vcListeMandats) = 0 then 
                                    vcListeMandats = substitute("&1, &2", vcListeMandats, string(ctrat.nocon)).
                            end.
                        end.
                end.
                when {&TYPECONTRAT-bail} then
                    for last tache no-lock
                        where tache.tpcon = ctrat.tpcon
                        and   tache.nocon = ctrat.nocon
                        and   tache.tptac = {&TYPETACHE-quittancement}:
                        if Tache.cdreg = {&MODEREGLEMENT-virement} or Tache.cdreg = {&MODEREGLEMENT-prelevement} or Tache.cdreg = {&MODEREGLEMENT-prelevementMensuelBudget} then
                            assign
                                vlIbanUtilise     = yes
                                vcListeLocataires = substitute("&1, &2", vcListeLocataires, outilFormatage:fSubstGestion(outilTraduction:getLibelle(105872), string(vbRoles.norol)))
                                .
                    end.
            end case.
        end.

        /* Si le tiers n'a qu'une banque, recherche liens role-Titres de copro & les modes de reglt Copropriétaires/Indiv
           car le lien rlctt n'existe pas toujours (Pb Prmsyreg.p corrigé le 13/04/2001)*/
        if (vbRoles.tprol = {&TYPEROLE-coproprietaire} or vbRoles.tprol = {&TYPEROLE-coIndivisaire}) and viNombreIbanDuTiers = 1 then
            for each intnt no-lock
                where intnt.tpidt = vbRoles.tprol
                and   intnt.noidt = vbRoles.norol
                and   intnt.tpcon = {&TYPECONTRAT-titre2copro}
                ,first ctrat no-lock
                where ctrat.tpcon = intnt.tpcon
                and   ctrat.nocon = intnt.nocon:

                if not vcListeCoproprietaires matches substitute("*&1*",string(ctrat.nocon)) and num-entries(ctrat.lbdiv,"@") >= 2 then
                do:
                    vcListeModeReglement = entry(2,ctrat.lbdiv,"@").
                    if lookup({&MODEREGLEMENT-virement}, vcListeModeReglement, "#" ) > 0
                        or lookup({&MODEREGLEMENT-prelevement}, vcListeModeReglement, "#" ) > 0
                        or lookup({&MODEREGLEMENT-prelevementMensuelBudget}, vcListeModeReglement, "#" ) > 0 then
                        assign
                            vlIbanUtilise          = yes
                            vcListeCoproprietaires = substitute("&1, &2", vcListeCoproprietaires, outilFormatage:fSubstGestion(outilTraduction:getLibelle(105874), substitute("&1&2&3", string(vbRoles.norol), separ[1], string(ctrat.nocon))))
                            .
                end.
            end.
    end.

    if vlIbanUtilise then do:
        vcChaineSortie = substitute("&1|&2|&3|&4|&5|&6",trim(vcListeMandants,",")
                                                       ,trim(vcListeIndivisaires,",")
                                                       ,trim(vcListeCoproprietaires,",")
                                                       ,trim(vcListeLocataires,",")
                                                       ,trim(vcListeMandats,",")).
        //Suppression de ce compte bancaire impossible, il est utilisé en virement %sou prélèvement par : %1
        mError:createError({&error}, outilFormatage:fSubstGestion(outilTraduction:getLibelle(105869),trim(replace(vcChaineSortie,"|",","),","))).
    end.

    return vcChaineSortie.

end function.



/* **********************  Internal Procedures  *********************** */


procedure getTiersBanques :
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : Externe
    ------------------------------------------------------------------------------*/
    define input  parameter poCollection as collection no-undo.
    define output parameter table for ttBanquesTiers.

    define variable vhProcCtAnx                         as handle no-undo.
    define variable viNumeroTiers                       as integer no-undo.
    define variable vcTypeRoleTiers                     as character no-undo.
    define variable viNumeroRoleTiers                   as int64 no-undo.
    define variable vcTypeContratTiers                  as character no-undo.
    define variable viNumeroContratTiers                as int64 no-undo.
    define variable viNumeroContratIbanDuContratEnCours as int64 no-undo.

    define buffer vbttBanquesTiers  for ttBanquesTiers.

    assign
        viNumeroTiers           = poCollection:getInteger("iNumeroTiers")
        vcTypeRoleTiers         = poCollection:getCharacter("cTypeRole")
        viNumeroRoleTiers       = poCollection:getInt64("iNumeroRole")
        vcTypeContratTiers      = poCollection:getCharacter("cTypeContrat")
        viNumeroContratTiers    = poCollection:getInt64("iNumeroContrat")
    .

    run crud/ctanx_CRUD.p persistent set vhProcCtAnx.
    run getTokenInstance in vhProcCtAnx(mToken:JSessionId).
    run getCtanx in vhProcCtAnx({&TYPECONTRAT-RIB}, {&TYPEROLE-tiers}, viNumeroTiers, table ttBanquesTiers by-reference).
    run getCtanx in vhProcCtAnx({&TYPECONTRAT-RIBAttenteValidation}, {&TYPEROLE-tiers}, viNumeroTiers, table ttBanquesTiers by-reference).

    for each ttBanquesTiers:
        if ttBanquesTiers.cTypeContratIban = {&TYPECONTRAT-RIB} then
            find first vbttBanquesTiers 
                where vbttBanquesTiers.cTypeContratIban = {&TYPECONTRAT-RIBAttenteValidation}
                and   vbttBanquesTiers.iNumeroContratIban = ttBanquesTiers.iNumeroContratIban
                no-error.
        assign
            ttBanquesTiers.cTypeRoleTiers        = vcTypeRoleTiers
            ttBanquesTiers.iNumeroRoleTiers      = viNumeroRoleTiers
            ttBanquesTiers.cTypeContratTiers     = vcTypeContratTiers
            ttBanquesTiers.iNumeroContratTiers   = viNumeroContratTiers
            ttBanquesTiers.lIbanValide           = (ttBanquesTiers.cTypeContratIban = {&TYPECONTRAT-RIB})
            ttBanquesTiers.lIbanDuContratEnCours = can-find(first rlctt no-lock
                                                                where rlctt.tpidt = vcTypeRoleTiers 
                                                                  and rlctt.noidt = viNumeroRoleTiers
                                                                  and rlctt.tpct1 = vcTypeContratTiers 
                                                                  and rlctt.noct1 = viNumeroContratTiers
                                                                  and rlctt.tpct2 = {&TYPECONTRAT-RIB}
                                                                  and rlctt.noct2 = ttBanquesTiers.iNumeroContratIban)
            ttBanquesTiers.cLibelleStatut        = outilTraduction:getLibelle(if available vbttBanquesTiers and vbttBanquesTiers.cStatutValidationIban = "M" then 1000715      //IBAN valide - Un nouvel IBAN est en attente de validation
                                                                              else if available vbttBanquesTiers and vbttBanquesTiers.cStatutValidationIban = "G" then 1000716 //IBANvalide - En attente de blocage
                                                                              else if lookup(ttBanquesTiers.cStatutValidationIban,"C,M")> 0 then 1000714                       //IBAN en attente de validation
                                                                              else if ttBanquesTiers.cStatutValidationIban = "G" then 1000716                                  //IBAN valide - En attente de blocage
                                                                              else if ttBanquesTiers.cStatutValidationIban = "D" then 1000717                                  //IBAN bloqué - En attente de déblocage
                                                                              else if ttBanquesTiers.cStatutValidationIban = "Z" then 1000718                                  //IBAN non valide - Bloqué
                                                                              else 1000713)                                                                                    //IBAN valide
            ttBanquesTiers.lAccesBlocage         = ttBanquesTiers.cTypeContratIban = {&TYPECONTRAT-RIB} and not available vbttBanquesTiers
            ttBanquesTiers.lAccesDeblocage       = ttBanquesTiers.cTypeContratIban = {&TYPECONTRAT-RIBAttenteValidation} and ttBanquesTiers.cStatutValidationIban = "Z"
        .
    end.

    run destroy in vhProcCtAnx.

    return.
end procedure.

procedure initControleDesIban:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : externe
    ------------------------------------------------------------------------------*/
    define output parameter table for ttControleDesIban.
    
    create ttControleDesIban.
    assign
        ttControleDesIban.lControleDesIban = IsControleDesIbanActive()
        .

end procedure.

procedure updateTiersBanque:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : externe
    ------------------------------------------------------------------------------*/
    define input parameter table for ttBanquesTiers.

    define variable vhProcCtAnx             as handle       no-undo.
    define variable vhRlCtt                 as handle       no-undo.
    define variable vhCtrlBancaire          as handle       no-undo.
    define variable vlIbanUtilise           as logical      no-undo.
    define variable vcChaineSortie          as character    no-undo.
    define variable vhProcCtrl              as handle       no-undo.
    define variable vcListeChampsModifies   as character    no-undo.
    
    define buffer vbttBanquesTiers for ttBanquesTiers.
    define buffer ctanx for ctanx.

    run outils/controleBancaire.p persistent set vhCtrlBancaire.
    run getTokenInstance in vhCtrlBancaire(mToken:JSessionId).
    for each ttBanquesTiers where lookup(ttBanquesTiers.CRUD,"C,U") > 0,
        first ctanx no-lock
            where rowid(ctanx) = ttBanquesTiers.rRowid:
        vcListeChampsModifies = outils:bufferCompare(buffer ttBanquesTiers:handle, buffer ctanx:handle, "").
        if (lookup("cIban",vcListeChampsModifies) > 0
            or lookup("cCodeBIC",vcListeChampsModifies) > 0) 
            and dynamic-function('controleIbanBic' in vhCtrlBancaire, ttBanquesTiers.cCodeBIC, ttBanquesTiers.cIban ) then leave. 
        
        if IsControleDesIbanActive() then do:
            if lookup("cIban",vcListeChampsModifies) > 0
            or lookup("cCodeBIC",vcListeChampsModifies) > 0
            then 
                assign
                    ttBanquesTiers.cTypeContratIban         = {&TYPECONTRAT-RIBAttenteValidation}
                    ttBanquesTiers.cStatutValidationIban    = if ttBanquesTiers.CRUD = "U" then "M" else "C"
                    //Il faut créer un nouvel enregistrement ctanx (duplication du ctanx 01038 en 01138) et ne pas modifier celui existant
                    ttBanquesTiers.rRowid                   = ? 
                    ttBanquesTiers.CRUD                     = "C"
                    ttBanquesTiers.iNumeroInterneContrat    = ?
                    ttBanquesTiers.iNumeroContratIban       = ?
                    .
        end.
        else
            assign
                ttBanquesTiers.cTypeContratIban         = {&TYPECONTRAT-RIB}
                ttBanquesTiers.cStatutValidationIban    = ""
                ttBanquesTiers.iNumeroInterneContrat    = ? when ttBanquesTiers.CRUD = "C"
                ttBanquesTiers.iNumeroContratIban       = ? when ttBanquesTiers.CRUD = "C"
                .

        if ttBanquesTiers.iNumeroContratTiers <> 0 then do: 
            if ttBanquesTiers.lIbanDuContratEnCours then
                run PrepareCreateRlCtt.
            else
                run PrepareDeleteRlCtt.
        end.
    end.
    run destroy in vhCtrlBancaire.

    for each ttBanquesTiers where ttBanquesTiers.CRUD = "D",
        first ctanx no-lock
            where rowid(ctanx) = ttBanquesTiers.rRowid:
        if isIbanUtiliseParUnContrat(ctanx.norol, ctanx.nocon) > "" then return.
        run MiseAJourModesReglements (ttBanquesTiers.rRowid).
        run PrepareDeleteRlCtt.
    end.

    run crud/ctanx_CRUD.p persistent set vhProcCtAnx.
    run getTokenInstance in vhProcCtAnx(mToken:JSessionId).

    if can-find(first ttRlctt)
    then do:
        run crud/rlctt_CRUD.p persistent set vhRlCtt.
        run getTokenInstance in vhRlCtt(mToken:JSessionId).
        run setRlctt in vhRlCtt(table ttRlctt by-reference).
        run destroy in vhRlCtt.
    end.

    run setCtanx in vhProcCtAnx(table ttBanquesTiers by-reference).
    run destroy in vhProcCtAnx.

    return.
end procedure.

procedure MiseAJourModesReglements:
    /*------------------------------------------------------------------------------
    Purpose: Mise à jour des modes de règlements (Virement -> Chèque) en cas de suppression de l'IBAN du contrat
    Notes  : 
    ------------------------------------------------------------------------------*/
    define input parameter prRowidCtanx as rowid no-undo.

    define variable vhIntnt                     as handle    no-undo.
    define variable vhTache                     as handle    no-undo.
    define variable vhRlCtt                     as handle    no-undo.

    define buffer vbRoles for roles.
    define buffer rlctt for rlctt.
    define buffer ctrat for ctrat.
    define buffer intnt for intnt.
    define buffer tache for tache.
    define buffer ctanx for ctanx.

    for first ctanx no-lock
        where rowid(ctanx) = prRowidCtanx,
        each vbRoles no-lock
        where vbRoles.notie = ctanx.norol,
        each rlctt exclusive-lock
        where   rlctt.tpidt = vbRoles.tprol
        and     rlctt.noidt = vbRoles.norol
        and     rlctt.tpct2 = {&TYPECONTRAT-RIB}
        and     rlctt.noct2 = ctanx.nocon:
        /* Modification des modes de règlement tache CRG */
        if rlctt.tpct1 = {&TYPECONTRAT-mandat2Gerance} then
            for first ctrat no-lock
                where ctrat.tpcon = rlctt.tpct1
                and   ctrat.nocon = rlctt.noct1:
                if ctrat.ntcon = {&NATURECONTRAT-mandatAvecIndivision} or ctrat.ntcon = {&NATURECONTRAT-mandatLocationIndivision} then
                    for first intnt no-lock
                        where intnt.tpcon = ctrat.tpcon
                        and   intnt.nocon = ctrat.nocon
                        and   intnt.Tpidt = vbRoles.tprol
                        and   intnt.noidt = vbRoles.norol
                        and   num-entries(intnt.lbdiv,"@") <> 0
                        and   entry(1,intnt.lbdiv,"@") = {&MODEREGLEMENT-virement}:
                        create ttIntnt.
                        assign
                            ttIntnt.tpcon               = intnt.tpcon
                            ttIntnt.nocon               = intnt.nocon
                            ttIntnt.tpidt               = intnt.tpidt
                            ttIntnt.noidt               = intnt.noidt
                            entry(1,ttIntnt.lbdiv,"@")  = {&MODEREGLEMENT-cheque}  /* chèque */
                            ttIntnt.CRUD                = "U"
                            ttIntnt.dtTimestamp         = datetime(intnt.dtmsy, intnt.hemsy)
                            ttIntnt.rRowid              = rowid(intnt)
                        .   
                    end.
                else
                    for first tache no-lock
                        where tache.tpcon = ctrat.tpcon
                        and   tache.nocon = ctrat.nocon
                        and   tache.tptac = {&TYPETACHE-compteRenduGestion}
                        and   tache.ntreg = {&MODEREGLEMENT-virement}:
                        create ttTache.
                        assign
                            ttTache.tpcon       = tache.tpcon
                            ttTache.nocon       = tache.nocon
                            ttTache.tptac       = {&TYPETACHE-TVABail}
                            ttTache.notac       = tache.notac
                            ttTache.notac       = tache.noita
                            ttTache.mdreg       = {&MODEREGLEMENT-cheque}
                            ttTache.CRUD        = "U"
                            ttTache.dtTimestamp = datetime(tache.dtmsy, tache.hemsy)
                            ttTache.rRowid      = rowid(tache)
                        .
                    end.
            end.
    end.

    if can-find(first ttIntnt)
    then do:
        run crud/intnt_CRUD.p persistent set vhIntnt.
        run getTokenInstance in vhIntnt(mToken:JSessionId).
        run setIntnt in vhIntnt(table ttIntnt by-reference).
        run destroy in vhIntnt.
    end.           

    if can-find(first ttTache)
    then do:
        run crud/tache_CRUD.p persistent set vhTache.
        run getTokenInstance in vhTache(mToken:JSessionId).
        run setIntnt in vhTache(table ttTache by-reference).
        run destroy in vhTache.
    end.           

    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure PrepareDeleteRlCtt:
    /*------------------------------------------------------------------------------
    Purpose: suppression des liens IBAN / contrat
    Notes  : 
    ------------------------------------------------------------------------------*/

    define buffer vbRoles for roles.
    define buffer rlctt for rlctt.
    define buffer ctanx for ctanx.

    for first ctanx no-lock
        where rowid(ctanx) = ttBanquesTiers.rRowid,
        each vbRoles no-lock
        where vbRoles.notie = ctanx.norol,
        each rlctt no-lock
        where   rlctt.tpidt = vbRoles.tprol
        and     rlctt.noidt = vbRoles.norol
        and     rlctt.tpct2 = {&TYPECONTRAT-RIB}
        and     rlctt.noct2 = ctanx.nocon:
        if ttBanquesTiers.iNumeroContratTiers = 0 or (rlctt.tpct1 = ttBanquesTiers.cTypeContratTiers and rlctt.noct1 = ttBanquesTiers.iNumeroContratTiers) then do:
            create ttRlctt.
            assign
                ttRlctt.tpidt       = rlctt.tpidt
                ttRlctt.noidt       = rlctt.noidt
                ttRlctt.tpct1       = rlctt.tpct1
                ttRlctt.noct1       = rlctt.noct1
                ttRlctt.tpct2       = rlctt.tpct2
                ttRlctt.noct2       = rlctt.noct2
                ttRlctt.CRUD        = "D"
                ttRlctt.dtTimestamp = datetime(rlctt.dtmsy, rlctt.hemsy)
                ttRlctt.rRowid      = rowid(rlctt)
                .
        end.
    end.

    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure PrepareCreateRlCtt:
    /*------------------------------------------------------------------------------
    Purpose: Création des liens IBAN / contrat
    Notes  : 
    ------------------------------------------------------------------------------*/

    define buffer rlctt for rlctt.
    define buffer ctanx for ctanx.

    for first ctanx no-lock
        where rowid(ctanx) = ttBanquesTiers.rRowid:
        if not can-find(first rlctt no-lock
                            where rlctt.tpidt = ttBanquesTiers.cTypeRoleTiers
                            and   rlctt.noidt = ttBanquesTiers.iNumeroRoleTiers
                            and   rlctt.tpct2 = {&TYPECONTRAT-RIB}
                            and   rlctt.noct2 = ctanx.nocon
                            and   rlctt.tpct1 = ttBanquesTiers.cTypeContratTiers
                            and   rlctt.noct1 = ttBanquesTiers.iNumeroContratTiers) then do:
            create ttRlctt.
            assign
                ttRlctt.tpidt = ttBanquesTiers.cTypeRoleTiers
                ttRlctt.noidt = ttBanquesTiers.iNumeroRoleTiers
                ttRlctt.tpct2 = {&TYPECONTRAT-RIB}
                ttRlctt.noct2 = ctanx.nocon
                ttRlctt.tpct1 = ttBanquesTiers.cTypeContratTiers
                ttRlctt.noct1 = ttBanquesTiers.iNumeroContratTiers
                ttRlctt.CRUD  = "C"
                .
        end.
    end.

    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

