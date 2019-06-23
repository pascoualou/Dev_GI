/*------------------------------------------------------------------------
File        : pontImmeubleCompta.p
Description :
Author(s)   : Kantena - 2016/12/23
Notes       : reprise de incliadb.i pour le cas '00001', 'imble'
derniere revue: 2018/04/11 - phm: KO.
               régler les TODO.
               enlever les messages 
               traductions
             - procedure majMandat private:
               - TODO: cette procédure pouvant être appelé à partir d'un for each, vhprocFormat devrait être ghprocFormat ...
------------------------------------------------------------------------*/
{preprocesseur/codePeriode.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2gestion.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/famille2tiers.i}
{preprocesseur/type2role.i}
{preprocesseur/referenceClient.i} 

using parametre.pclie.parametrageFournisseurLoyer.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

define temp-table ttParam no-undo
    field iCodeSoc   as integer
    field iCodeEtab  as integer
    field cNomEtab   as character
    field cAdr1Etab  as character
    field cAdr2Etab  as character
    field cCpEtab    as character
    field cVilleEtab as character
    field cCodePays  as character
    field iPeriode   as integer   initial 99
    field cDateDebut as character initial "999"
    field cDateFin   as character initial "999"
    field cSiret     as character initial "00000000000000"
    field cSiren     as character initial "000000000"
    field cApe       as character
    field iSoumis    as integer   initial 1
    field iInd       as integer   initial 1
    field iTyperec   as integer   initial 1
    field iTypedep   as integer
    field iRegime    as integer   initial 1
    field cNatMdt    as character
    field cFourn     as character
    field cModReg    as character
    field cLstMdt    as character
.
define temp-table ttParamCompte no-undo
    field iCodeSoc       as integer
    field cTypeContrat   as character 
    field iCodeEtab      as int64
    field cTypeRole      as character
    field iNumeroRole    as int64
    field cNomRole       as character
    field iNumerateur    as integer
    field iDenominateur  as integer
    field cModeReglement as character
.

function controleMandat returns integer private(piRetour as integer):
    /*------------------------------------------------------------------------------
    Purpose: Test les retours du programme majMdt.p
    Note   :
    ------------------------------------------------------------------------------*/
    case piRetour:
        when 1  or when 11  then return 104219.
        when 10 or when 12  then return 104223.
        when 30 or when 33  then return 104230.
        when 31 or when 34  then return 104231.
        when 2              then return 104220.
        when 3              then return 104221.
        when 4              then return 104222.
        when 21             then return 104224.
        when 22             then return 104225.
        when 23             then return 104226.
        when 24             then return 104227.
        when 25             then return 104228.
        when 26             then return 104229.
        when 32             then return 104232.
        when 40             then return 104233.
        when 51             then return 104234.
        when 52             then return 104235.
        when 53             then return 104236.
    end case.
    return 0.
end function.

function controleCompte returns integer private(piRetour as integer):
    /*------------------------------------------------------------------------------
    Purpose: Test les retours du programme majCpt.p
    Note   :
    ------------------------------------------------------------------------------*/
    case piRetour:
        when 1   then return 104238. /* Regroupement de compte incorrect */
        when 3   then return 999999. /*pas de parametre en entre */   //gga todo
        when 4   then return 104239. /* quote part co-indivisaire incorrecte */
        when 5   then return 104240. /* mode de reglement coindivisaire incorrect */
        when 6   then return 104241. /* param‚trage par d‚faut incorrect */
        when 999 then return 102540. /* Mandat %1 inexistant en comptabilit‚ (IETAB) */ //gga todo message avec %1
        otherwise return 104243.
    end case.
    return 0.
end function.

procedure MAJLienImmeuble:
    /*------------------------------------------------------------------------------
    purpose: Met à jour l'ensemble des mandats d'un immeuble
    Note   : service utilisé par imble_crud.p
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroImmeuble as integer  no-undo.

    define variable vlRechAdresse as logical   no-undo initial true.
    define variable vcModeGestion as character no-undo.
    define variable voFournisseurLoyer as class parametrageFournisseurLoyer no-undo.

    define buffer ctrat for ctrat.
    define buffer intnt for intnt.

    if integer(mtoken:cRefPrincipale) = {&REFCLIENT-MANPOWER} then return.

    /* Récupération mode de gestion des Fourn. Loyer */
    voFournisseurLoyer = new parametrageFournisseurLoyer().
    if voFournisseurLoyer:isDbParameter then vcModeGestion = voFournisseurLoyer:getCodeModele().
    delete object voFournisseurLoyer.
    /* Boucle de Maj de TOUS LES MANDATS rattachés à l'immeuble modifié */
    for each intnt no-lock
        where intnt.tpidt = {&TYPEBIEN-immeuble}
          and intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and intnt.noidt = piNumeroImmeuble
      , first ctrat no-lock
        where ctrat.tpcon  = intnt.tpcon
          and ctrat.nocon  = intnt.nocon
          and ctrat.fgprov = no:
        /* Ne pas gérer les fournisseurs loyers*/
        if (ctrat.ntcon <> {&NATURECONTRAT-mandatLocation}
        and ctrat.ntcon <> {&NATURECONTRAT-mandatLocationIndivision}
        and ctrat.ntcon <> {&NATURECONTRAT-mandatLocationDelegue})
        or ((ctrat.ntcon = {&NATURECONTRAT-mandatLocation}
          or ctrat.ntcon = {&NATURECONTRAT-mandatLocationIndivision}
          or ctrat.ntcon = {&NATURECONTRAT-mandatLocationDelegue}) and lookup(vcModeGestion, "00003,00004") > 0) /* FL Eurostudiomes ou BNP */
        then do:
            run majMandat({&TYPECONTRAT-mandat2Gerance}, intnt.nocon, piNumeroImmeuble, vlRechAdresse).
            vlRechAdresse = no.
        end.
    end.

end procedure.

procedure majMandatExterne:
    /*------------------------------------------------------------------------------
    purpose: appel externe de la procedure d'appel de l'interface de maj des mandats (gérance & copro) en compta
    Note   : service exterene
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat    as character no-undo.
    define input parameter piNumeroContrat  as int64     no-undo.
    define input parameter piNumeroImmeuble as int64     no-undo.
    define input parameter plRechAdresse    as logical   no-undo.
   
    run majMandat(pcTypeContrat, piNumeroContrat, piNumeroImmeuble, plRechAdresse).

end procedure.

procedure majCompteExterne:
    /*------------------------------------------------------------------------------
    purpose: appel externe de la procedure d'appel de l'interface de maj des mandats (gérance & copro) en compta
    Note   : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeMandat   as character no-undo.
    define input parameter piNumeroMandat as integer   no-undo.
    define input parameter piNumeroTiers  as int64     no-undo.
    define input parameter pcTypeRole     as character no-undo.
    define input parameter piNumeroRole   as int64     no-undo.
    define input parameter piNumerateur   as integer   no-undo.
    define input parameter piDenominateur as integer   no-undo.

    run majCompte(pcTypeMandat, piNumeroMandat, piNumeroTiers, pcTypeRole, piNumeroRole, piNumerateur, piDenominateur).

end procedure.


procedure majMandat private:
    /*------------------------------------------------------------------------------
    purpose: Procedure d'appel de l'interface de maj des mandats (gérance & copro) en compta
    Note   : Met à jour un mandat
    TODO: cette procédure pouvant être appelé à partir d'un for each, vhprocFormat devrait être ghprocFormat ...
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeMandat     as character no-undo.
    define input parameter piNumeroMandat   as integer   no-undo.
    define input parameter piNumeroImmeuble as integer   no-undo.
    define input parameter plRechAdresse    as logical   no-undo.

    define variable viRetour       as integer   no-undo.
    define variable vcNumeroMandat as character no-undo.
    define variable vcListeMandat  as character no-undo.
    define variable vhProc         as handle    no-undo.
    define variable vhprocFormat   as handle    no-undo.

    define buffer perio   for perio.
    define buffer vbPerio for perio.
    define buffer intnt   for intnt.
    define buffer vbRoles for roles.
    define buffer ctrat   for ctrat.
    define buffer tache   for tache.
    define buffer ctanx   for ctanx.
    define buffer synge   for synge.

    if integer(mtoken:cRefPrincipale) = {&REFCLIENT-MANPOWER} then return.

    create ttParam.
    if plRechAdresse then do:
        run adresse/formadr7_ext.p persistent set vhprocFormat.
        run getAdresseFormat7 in vhprocFormat(
            piNumeroImmeuble,
            output ttParam.cNomEtab,
            output ttParam.cAdr1Etab,
            output ttParam.cAdr2Etab,
            output ttParam.cCpEtab,
            output ttParam.cVilleEtab,
            output ttParam.cCodePays).
        delete object vhprocFormat.
    end.
    assign
        ttParam.iCodeSoc  = mtoken:getSociete(pcTypeMandat)
        ttParam.iCodeEtab = piNumeroMandat
    .
    if pcTypeMandat = {&TYPECONTRAT-mandat2Gerance}
    then do:
        /* les mandats provisoires ne vont pas en compta */
        if can-find(first ctrat no-lock
                    where ctrat.tpcon = pcTypeMandat
                      and ctrat.nocon = piNumeroMandat
                      and ctrat.fgprov)  then return.

        find last tache no-lock
            where tache.tpcon = {&TYPECONTRAT-mandat2Gerance}
              and tache.nocon = piNumeroMandat
              and tache.tptac = {&TYPETACHE-compteRenduGestion} no-error.
        if available tache
        then do:
            if can-do("20010,20011,20012", tache.pdges) then ttParam.iPeriode = 3.
            else if can-do("20013,20014,20015,20016,20017,20018", tache.pdges) then ttParam.iPeriode = 6.
            else if can-do("20019,20020,20021,20022,20023,20024,20025,20026,20027,20028,20029,20030", tache.pdges) then ttParam.iPeriode = 12.
            else if tache.pdges = "00000" then ttParam.iPeriode = 0. /* cas saisie "-" dans périodicité*/
            else ttParam.iPeriode = 1.
        end.
        else ttParam.iPeriode = 0.  
    end.
    else if pcTypeMandat = {&TYPECONTRAT-mandat2Syndic}
    then for first vbPerio no-lock           /* Recherche de l'exercice de PEC du Mandat      */
        where vbPerio.tpctt = {&TYPECONTRAT-mandat2Syndic}
          and vbPerio.Nomdt = piNumeroMandat
          and vbPerio.noper > 0
          and (vbPerio.cdtrt = "00001" or vbPerio.cdtrt = "00002")
        use-index ix_perio02             // tpctt, nomdt, noexo, noper        sinon, c'est ix_perio01
      , first perio no-lock
        where perio.tpctt = {&TYPECONTRAT-mandat2Syndic}
          and perio.nomdt = vbPerio.nomdt
          and perio.noexo = vbPerio.Noexo
          and perio.noper = 0:
        assign
            ttParam.cDateDebut = string(Perio.dtDeb)
            ttParam.cDateFin   = string(Perio.dtFin)
        .
        case Perio.CdPer:
            when {&CODEPERIODE-annuel}      then ttParam.iPeriode = {&CODEPERIODE-iAnnuel}.
            when {&CODEPERIODE-semestriel}  then ttParam.iPeriode = {&CODEPERIODE-iSemestriel}.
            when {&CODEPERIODE-trimestriel} then ttParam.iPeriode = {&CODEPERIODE-iTrimestriel}.
            when {&CODEPERIODE-mensuel}     then ttParam.iPeriode = {&CODEPERIODE-iMensuel}.
            when {&CODEPERIODE-indetermine} then ttParam.iPeriode = {&CODEPERIODE-iIndetermine}.
        end case.
    end.

    /* INFO MANDANT uniquement pour TVA              */
    if pcTypeMandat = {&TYPECONTRAT-mandat2Gerance}
    then for first intnt no-lock
        where intnt.tpcon = pcTypeMandat
          and intnt.nocon = piNumeroMandat
          and intnt.tpidt = {&TYPEROLE-mandant}:
        for last tache no-lock
            where tache.tpcon = intnt.tpcon
              and tache.nocon = intnt.nocon
              and tache.tptac = {&TYPETACHE-TVA}:
            if num-entries(tache.pdreg, "#") >= 3
            then assign
                ttParam.cSiret = entry(1, tache.pdreg, "#") + entry(2, tache.pdreg, "#")
                ttParam.cSiren = entry(1, tache.pdreg, "#")
                ttParam.cApe   = entry(3, tache.pdreg, "#")
            .
            else for first vbRoles no-lock
                where vbRoles.Tprol = intnt.tpidt
                  and vbRoles.norol = intnt.noidt
              , first ctanx no-lock
                where ctanx.tpcon = {&TYPECONTRAT-TVAIntracommunautaire}
                  and ctanx.tprol = {&TYPEROLE-tiers}
                  and ctanx.norol = vbRoles.notie:
                assign
                    ttParam.cSiren = string(ctanx.nosir, "999999999")
                    ttParam.cSiret = ttParam.cSiren + string(ctanx.cptbq, "99999")
                    ttParam.cApe   = ctanx.cdape
                .
            end.
            /* code soumis à TVA => "0" : oui*/
            assign
                ttParam.iSoumis = 0
                ttParam.iInd    = if tache.tpges = {&TYPE2GESTION-Totale} then 1 else 0
            .
            /* Type dépense et recette : débit ou encaissement*/
            if num-entries(Tache.lbdiv, "#") >= 4
            then assign
                ttParam.iTyperec = if entry(3, Tache.Lbdiv, "#") = "1" then 0 else 1
                ttParam.iTypedep = if entry(4, Tache.Lbdiv, "#") = "1" then 0 else 1
            .
            ttParam.iRegime  = if Tache.ntges = "18002" then 0 else 1.
        end.
    end.
    
    /* Cas spécial AFUL */
    /* Récupération du mode de règlement des charges pour le contrat AFUL */
    if pcTypeMandat = {&TYPECONTRAT-mandat2Syndic}
    then for first ctrat no-lock   /* recherche de la nature du contrat */
        where ctrat.tpcon = pcTypeMandat
          and ctrat.nocon = piNumeroMandat:
        ttParam.cNatMdt = ctrat.ntcon.
        /* recherche du mode de reglement fournisseur pour l'aful */
        if ctrat.ntcon = {&NATURECONTRAT-AFUL} or ctrat.ntcon = {&NATURECONTRAT-ASL}
        then for last tache no-lock
            where tache.tpcon = pcTypeMandat
              and tache.nocon = piNumeroMandat
              and tache.tptac = {&TYPETACHE-associationCleRepartition}:
            if tache.lbdiv > "" and num-entries(tache.lbdiv, "@") >= 2
            then assign
                ttParam.cFourn  = entry(1, tache.lbdiv, "@")
                ttParam.cModReg = if entry(2, tache.lbdiv, "@") = "00002" then "V" else "C"
            .
        end.
        /* recherche des mandat de l'AFUL */
        for each synge no-lock
           where synge.tpctp = pcTypeMandat
             and synge.noctp = piNumeroMandat
             and synge.tpct1 = {&TYPECONTRAT-titre2copro}:
            vcNumeroMandat = substring(string(synge.noct1, "9999999999"), 6, 5, 'character').
            if integer(vcNumeroMandat) >= 90000 then vcListeMandat = vcListeMandat + "@" + vcNumeroMandat.
        end.
        ttParam.cLstMdt = trim(vcListeMandat, '@').
    end.

    /* MAJ contrat Mandat Gestion pour Compta        */
    run immeubleEtLot/majmdt.p persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    run rprunLie         in vhProc(table ttParam, output viRetour).
    run destroy          in vhProc.
    if viRetour <> 0
    then do:
        viRetour = controleMandat(viRetour).
        if viRetour <> 0 then mError:create2Error(viRetour, 104237).
        return.
    end.
    run compta/pontCompta/majIndi.p persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    run majIndivisaire in vhProc(piNumeroMandat).
    run destroy in vhProc.
    
end procedure.

procedure majCompte private:
    /*------------------------------------------------------------------------------
    purpose: 
    Note   : reprise de adb/comm/incliadb.i pour le cas '00002'
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeMandat   as character no-undo.
    define input parameter piNumeroMandat as integer   no-undo.
    define input parameter piNumeroTiers  as int64     no-undo.
    define input parameter pcTypeRole     as character no-undo.
    define input parameter piNumeroRole   as int64     no-undo.
    define input parameter piNumerateur   as integer   no-undo.
    define input parameter piDenominateur as integer   no-undo.

    define variable voFournisseurLoyer as class     parametrageFournisseurLoyer.
    define variable vcModeGestion      as character no-undo.
    define variable vcTypeRole         as character no-undo.
    define variable vhProc             as handle    no-undo.
    define variable viRetour           as integer   no-undo.
    define buffer tiers for tiers.
    define buffer ctrat for ctrat.
    define buffer rlctt for rlctt.

    empty temp-table ttParamCompte. 
    /* Récupération mode de gestion des Fourn. Loyer */
    voFournisseurLoyer = new parametrageFournisseurLoyer().
    if voFournisseurLoyer:isDbParameter then vcModeGestion = voFournisseurLoyer:getCodeModele().
    delete object voFournisseurLoyer.
    create ttParamCompte.
    assign
        ttParamCompte.iCodeSoc      = mtoken:getSociete(pcTypeMandat)
        ttParamCompte.cTypeContrat  = pcTypeMandat
        ttParamCompte.iCodeEtab     = piNumeroMandat
        ttParamCompte.cTypeRole     = pcTypeRole 
        ttParamCompte.iNumeroRole   = piNumeroRole
        ttParamCompte.iNumerateur   = piNumerateur
        ttParamCompte.iDenominateur = piDenominateur        
    .
    /*On ne passe plus par FormTie4.p car on ne veut pas du Code Civilite‚ (Seuls le nom et le prenom du Tiers sont necessaires … la compta). */
    for first tiers no-lock
        where tiers.notie = piNumeroTiers:
        if tiers.cdfat = {&FAMILLETIERS-personneMorale} or tiers.cdfat = {&FAMILLETIERS-personneCivile}
        then ttParamCompte.cNomRole = substitute('&1&2', trim(tiers.lnom1), trim(tiers.lpre1)).  
        else ttParamCompte.cNomRole = substitute('&1 &2', trim(tiers.lnom1), trim(tiers.lpre1)). 
    end.

    /* Si c'est un role locataire, passer 5 chiffres. */
    if pcTypeRole = {&TYPEROLE-locataire} 
    then do:
        /** Modif SY le 06/09/2006 : pas de maj compta ADB pour Baux spécial vacant (propriétaire) **/
        find first ctrat no-lock
             where ctrat.tpcon = {&TYPECONTRAT-bail}
               and ctrat.nocon = piNumeroRole no-error.
        if available ctrat 
        then do:
            if ctrat.ntcon = {&NATURECONTRAT-specialVacant}
            then return.
            if integer(mtoken:cRefPrincipale) = {&REFCLIENT-MANPOWER} 
            then ttParamCompte.cNomRole = substitute('&1 (&2)', ttParamCompte.cNomRole, ctrat.noree).  /* SY #8575 MANPOWER ajouter le no registre dans le nom */              
        end.
        ttParamCompte.iNumeroRole = integer(substring(string(ttParamCompte.iNumeroRole, "9999999999"), 6, 5, 'character')).
        /** Modif SY le 02/09/2005 : pas de maj compta ADB pour Baux FL **/
        /* Recherche de la nature du mandat maitre */
        find first ctrat no-lock
             where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
               and ctrat.nocon = piNumeroMandat no-error.
        if not available ctrat 
        then do:
            mError:createError({&error}, 1000739, string(piNumeroMandat)).  //Mandat &1 introuvable
            return.
        end.
        /* Les Baux Fournisseurs de loyer ne vont en compta ADB que pour le modele no 3 (EUROSTUDIOMES) */
        if (ctrat.ntcon = {&NATURECONTRAT-mandatLocation}
         or ctrat.ntcon = {&NATURECONTRAT-mandatLocationIndivision}
         or ctrat.ntcon = {&NATURECONTRAT-mandatLocationDelegue})
        and (vcModeGestion <> "00003" and vcModeGestion <> "00004") then return.
        /* ajout SY le 02/06/2010 : les baux des mandats provisoires ne vont pas en compta */
        if ctrat.fgprov then return.
    end.

    /* Recherche de la Nature du Contrat. */
    if pcTypeRole = {&TYPEROLE-coIndivisaire} 
    then do:
        find first ctrat no-lock
             where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
               and ctrat.nocon = piNumeroMandat no-error.
        if not available ctrat 
        then do:
            mError:createError({&error}, 1000739, string(piNumeroMandat)).  //Mandat &1 introuvable
            return.
        end.
        case ctrat.ntcon:
            when {&NATURECONTRAT-mandatAvecIndivision}         then vcTypeRole = {&TYPEROLE-coIndivisaire}.
            when {&NATURECONTRAT-mandatSansIndivision}         then vcTypeRole = {&TYPEROLE-mandant}.
            when {&NATURECONTRAT-mandatGestionRevenusGarantis} then vcTypeRole = {&TYPEROLE-mandant}.
            when {&NATURECONTRAT-mandatSousLocation}           then vcTypeRole = {&TYPEROLE-mandant}.
            when {&NATURECONTRAT-mandatLocation}               then vcTypeRole = {&TYPEROLE-mandant}.
            when {&NATURECONTRAT-mandatLocationDelegue}        then vcTypeRole = {&TYPEROLE-mandant}.
            when {&NATURECONTRAT-mandatSousLocationDelegue}    then vcTypeRole = {&TYPEROLE-mandant}.
            when {&NATURECONTRAT-mandatLocationIndivision}     then vcTypeRole = {&TYPEROLE-mandant}.
            otherwise do:
                mError:createError({&error}, 1000738, ctrat.ntcon). //Nature de mandat &1 inconnue
                return.
            end.
        end case.
        /* Recherche Mode de Reglement du Role. */
        if vcTypeRole > "" then do:
            ttParamCompte.cModeReglement = "C".
            /* lecture de RLCTT pour le Mode de Reglement.*/
            for first rlctt no-lock
                where rlctt.tpct1 = ctrat.tpcon
                  and rlctt.noct1 = ctrat.nocon
                  and rlctt.tpidt = vcTypeRole
                  and rlctt.noidt = piNumeroRole
                  and rlctt.tpct2  = {&TYPECONTRAT-prive}:
               /* Recuperation du Mode de reglement dans lbdiv. */
               if rlctt.lbdiv = "00002" 
               then ttParamCompte.cModeReglement = "V".
            end.
        end.
    end.

    /* MAJ des roles loc/pro pour Compta */
    run compta/pontCompta/majCpt.p persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    run createCompte in vhProc(table ttParamCompte, output viRetour).
    run destroy in vhProc.
    if viRetour <> 0
    then do:
        viRetour = controleCompte(viRetour).
        if viRetour <> 0 then mError:create2Error(viRetour, 104237).
    end.

end procedure.
