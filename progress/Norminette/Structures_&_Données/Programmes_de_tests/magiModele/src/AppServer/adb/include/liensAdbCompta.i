/*------------------------------------------------------------------------
File        : liensAdbCompta.i
Purpose     : Procédures de mise à jour de la Compta depuis la Gestion
Author(s)   : ofa  -  2018/05/29 
Notes       : vient de adb/comm/incliadb.i
ATTENTION!!! En cas de modification de la procédure RnMajEmpl, il faut la modifier également dans l'include COMM/MAJEMPL.I
derniere revue: 2018/08/03 - phm: OK

70  08/06/2015    SY    0515/0159 Ajout trace dans PrcRunLi Baux
71  20/07/2015    SY    Modification index table telephones pour V12.3
72  24/06/2016    SY    0616/0216 BNP - Pb tiers.tpmod à ?
73  06/11/2017    SY    #8575 MANPOWER V17.00 ouvrir la création des locataires en comptabilité pour l'objet dynamique de recherche mandat/locataire|
74  22/02/2018   JPM    #13031 champs INT64
---------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}
{preprocesseur/codePeriode.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/mode2Reglement.i}
{preprocesseur/referenceClient.i}
{preprocesseur/mode2gestionFournisseurLoyer.i}

{crud/include/arib.i}

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
function controleCompte returns character private(piRetour as integer, piNumeroMandat as int64):
    /*------------------------------------------------------------------------------
    Purpose: Test les retours du programme majCpt.p
    Note   :
    ------------------------------------------------------------------------------*/
    case piRetour:
        when 1   then return outilTraduction:getLibelle(104238). // Regroupement de compte incorrect
        when 3   then return outilTraduction:getLibelle(1000893). // pas de paramètre en entrée
        when 4   then return outilTraduction:getLibelle(104239). // quote part co-indivisaire incorrecte
        when 5   then return outilTraduction:getLibelle(104240). // mode de reglement coindivisaire incorrect
        when 6   then return outilTraduction:getLibelle(104241). // paramétrage par défaut incorrect
        when 999 then return outilFormatage:fSubstGestion(outilTraduction:getLibelle(102540), string(piNumeroMandat)).  // Mandat %1 inexistant en comptabilité (IETAB)      otherwise return outilTraduction:getLibelle(104243).
    end case.
end function.

procedure miseAJourGeranceVersCompta:
    /*------------------------------------------------------------------------------
    Purpose: Procedure exécutant le programme de lien ADB(Gérance) => Compta
    Notes  : Ancienne procédure PrcRunLi dans incliadb.i
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeLienEntree             as character no-undo.
    define input  parameter pcTypeMiseAJourEntree        as character no-undo.
    define input  parameter pcTypeIdentifiantEntree      as character no-undo.
    define input  parameter piNumeroContratEntree        as int64     no-undo.
    define input  parameter piNumeroMandatEntree         as int64     no-undo.
    define input  parameter pcTypeRoleEntree             as character no-undo.
    define input  parameter piNumeroRoleEntree           as int64     no-undo.
    define input  parameter piNumerateurTantiemeEntree   as integer   no-undo.
    define input  parameter piDenominateurTantiemeEntree as integer   no-undo.

    define variable vhProc                        as handle    no-undo.
    define variable vhProcPont                    as handle    no-undo.
    define variable viRetour                      as integer   no-undo.
    define variable viNumeroRole                  as int64     no-undo.
    define variable vcNomTiers                    as character no-undo.
    define variable vcModeReglement               as character no-undo.
    define variable pcTypeRoleEntreeContratMaitre as character no-undo.
    define variable vcCodeModeleFournisseurLoyer  as character no-undo.
    define variable vlRechercheAdresse            as logical   no-undo.
    define variable vcListeModeleFLComptaAdb      as character no-undo.
    define variable voFournisseurLoyer            as class parametre.pclie.parametrageFournisseurLoyer no-undo.
    define buffer vbCtrat for ctrat.
    define buffer intnt   for intnt.
    define buffer ctrat   for ctrat.
    define buffer rlctt   for rlctt.

    assign 
        viNumeroRole                 = piNumeroRoleEntree
        voFournisseurLoyer           = new parametre.pclie.parametrageFournisseurLoyer()
        vcCodeModeleFournisseurLoyer = voFournisseurLoyer:getCodeModele()
        vcListeModeleFLComptaAdb     = substitute('&1,&2', {&MODELE-ResidenceLocative-ComptaAdb}, {&MODELE-ResidenceLocativeEtDeleguee-ComptaAdb})
    .
    if integer(mToken:cRefPrincipale) = {&REFCLIENT-MANPOWER} and pcTypeLienEntree <> "00002" then return.    // SY #8575 MANPOWER créer les entêtes Baux en compta pour l'objet de recherche

    // Lien Mandats de Gérance => Compta.
    if pcTypeLienEntree = "00001" then do:
        run immeubleEtLot/pontImmeubleCompta.p persistent set vhProcPont.
        run getTokenInstance in vhProcPont(mToken:JSessionId).
         // Traitements différents si modif d'un immeuble (adresse ou nom) ou d'un mandat
        if pcTypeMiseAJourEntree = "ctrat" then do:
            for first intnt no-lock
                where intnt.tpidt = {&TYPEBIEN-immeuble}
                  and intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
                  and intnt.nocon = piNumeroContratEntree:
                run majMandatExterne in vhProcPont({&TYPECONTRAT-mandat2Gerance}, piNumeroContratEntree, intnt.noidt, yes).
            end.
            run compta/pontCompta/majIndi.p persistent set vhProc.
            run getTokenInstance in vhProc(mToken:JSessionId).
            run majIndivisaire in vhProc(piNumeroContratEntree).
            run destroy in vhProc.
        end.
        else run MAJLienImmeuble in vhProcPont (piNumeroContratEntree). // Boucle de Maj de TOUS LES MANDATS rattachés à l'immeuble modifié
        run destroy in vhProcPont.
    end.
    // Lien Baux => Compta
    else if pcTypeLienEntree = "00002" then do:
        // Dans ce cas on doit passer les informations sur le locataire ou sur le Propriétaire, et piNumeroContratEntree = No du Tiers concerné
        vcNomTiers = outilFormatage:getNomTiers(piNumeroContratEntree).
        if pcTypeRoleEntree = {&TYPEROLE-locataire} then do:
            // Pas de maj compta ADB pour Baux spécial vacant (propriétaire)
            for first vbCtrat no-lock
                where vbCtrat.tpcon = {&TYPECONTRAT-bail}
                  and vbCtrat.nocon = piNumeroRoleEntree:
                if vbCtrat.ntcon = {&NATURECONTRAT-specialVacant} or vbCtrat.fgprov then return.
            end.
            if integer(mToken:cRefPrincipale) = {&REFCLIENT-MANPOWER} then vcNomTiers = substitute("&1 (&2)", vcNomTiers, vbCtrat.noree). // SY #8575 MANPOWER ajouter le no registre dans le nom                
            viNumeroRole = viNumeroRole modulo 100000.    // int64(substring(string(viNumeroRole, "9999999999"), 6, 5)).
            //Pas de maj compta ADB pour Baux Fournisseurs Loyer
            for first ctrat no-lock
                where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
                  and ctrat.nocon = piNumeroMandatEntree:
                // Les Baux Fournisseurs de loyer ne vont en compta ADB que pour les modele no 3 et 4
                if (ctrat.ntcon = {&NATURECONTRAT-mandatLocation} 
                 or ctrat.ntcon = {&NATURECONTRAT-mandatLocationIndivision} 
                 or ctrat.ntcon = {&NATURECONTRAT-mandatLocationDelegue}) 
                and lookup(vcCodeModeleFournisseurLoyer, vcListeModeleFLComptaAdb) = 0 then return.
                // Les baux des mandats provisoires ne vont pas en compta
                if ctrat.fgprov = yes then return.
            end.
        end.
        else if pcTypeRoleEntree = {&TYPEROLE-coIndivisaire} then do:
            for first ctrat no-lock
                where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
                  and ctrat.nocon = piNumeroMandatEntree:
                case ctrat.ntcon:
                    when {&NATURECONTRAT-mandatAvecIndivision}          then pcTypeRoleEntreeContratMaitre = {&TYPEROLE-coIndivisaire}.
                    when {&NATURECONTRAT-mandatSansIndivision}          then pcTypeRoleEntreeContratMaitre = {&TYPEROLE-mandant}.
                    when {&NATURECONTRAT-mandatGestionRevenusGarantis}  then pcTypeRoleEntreeContratMaitre = {&TYPEROLE-mandant}.
                    when {&NATURECONTRAT-mandatSousLocation}            then pcTypeRoleEntreeContratMaitre = {&TYPEROLE-mandant}.
                    when {&NATURECONTRAT-mandatLocation}                then pcTypeRoleEntreeContratMaitre = {&TYPEROLE-mandant}.
                    when {&NATURECONTRAT-mandatLocationDelegue}         then pcTypeRoleEntreeContratMaitre = {&TYPEROLE-mandant}.
                    when {&NATURECONTRAT-mandatSousLocationDelegue}     then pcTypeRoleEntreeContratMaitre = {&TYPEROLE-mandant}.
                    when {&NATURECONTRAT-mandatLocationIndivision}      then pcTypeRoleEntreeContratMaitre = {&TYPEROLE-mandant}.
                end case.
            end.
            //Recherche Mode de Règlement du Rôle
            if pcTypeRoleEntreeContratMaitre <> "" then do:
                find first rlctt no-lock
                    where rlctt.tpct1 = {&TYPECONTRAT-mandat2Gerance}
                      and rlctt.noct1 = piNumeroMandatEntree
                      and rlctt.tpidt = pcTypeRoleEntreeContratMaitre
                      and rlctt.noidt = piNumeroRoleEntree
                      and rlctt.tpct2 = {&TYPECONTRAT-RIB} no-error.
                vcModeReglement = if available rlctt and rlctt.lbdiv = "00002" then "V" else "C".
            end.
        end.

        empty temp-table ttParamCompte.
        create ttParamCompte.
        assign
            ttParamCompte.iCodeSoc       = integer(mToken:cRefGerance)
            ttParamCompte.cTypeContrat   = {&TYPECONTRAT-mandat2Gerance} 
            ttParamCompte.iCodeEtab      = piNumeroMandatEntree
            ttParamCompte.cTypeRole      = pcTypeRoleEntree
            ttParamCompte.iNumeroRole    = viNumeroRole
            ttParamCompte.cNomRole       = vcNomTiers
            ttParamCompte.iNumerateur    = piNumerateurTantiemeEntree
            ttParamCompte.iDenominateur  = piDenominateurTantiemeEntree
            ttParamCompte.cModeReglement =  vcModeReglement
        .
        // MAJ des rôles loc/pro pour Compta
        run compta/pontCompta/majCpt.p persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        run createCompte in vhProc(table ttParamCompte, output viRetour).
        run destroy in vhProc.
        if viRetour <> 0 then mError:create2Error(controleCompte(viRetour, piNumeroMandatEntree), 104237).

    end.

end procedure.

procedure miseAJourCoproprieteVersCompta:
    /*------------------------------------------------------------------------------
    Purpose: Procedure exécutant le programme de lien ADB (Copro) => Compta 
    Notes  : Ancienne procédure PrcRunCo dans incliadb.i
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeLienEntree             as character no-undo.
    define input  parameter pcTypeMiseAJourEntree        as character no-undo.
    define input  parameter pcTypeIdentifiantEntree      as character no-undo.
    define input  parameter piNumeroContratEntree        as int64     no-undo.
    define input  parameter piNumeroMandatEntree         as int64     no-undo.
    define input  parameter pcTypeRoleEntree             as character no-undo.
    define input  parameter piNumeroRoleEntree           as int64     no-undo.
    define input  parameter piNumerateurTantiemeEntree   as integer   no-undo.
    define input  parameter piDenominateurTantiemeEntree as integer   no-undo.

    define variable vhProc       as handle   no-undo.
    define variable vhProcPont   as handle   no-undo.
    define variable viRetour     as integer  no-undo.
    define buffer intnt   for intnt.
    define buffer tiers   for tiers.
    define buffer ctCtt   for ctCtt.
    define buffer vbRoles for roles.

    if integer(mToken:cRefPrincipale) = {&REFCLIENT-MANPOWER} then return.

    // Maj mandat de copro => Compta.
    if pcTypeLienEntree = "00001" 
    then do:
        run ImmeubleEtLot/pontImmeubleCompta.p persistent set vhProcPont.
        run getTokenInstance in vhProcPont(mToken:JSessionId).
         // Traitements différents si modif d'un immeuble (adresse ou nom) ou d'un mandat
        if pcTypeMiseAJourEntree = "ctrat" 
        then for first intnt no-lock
                 where intnt.tpidt = {&TYPEBIEN-immeuble}
                   and intnt.tpcon = {&TYPECONTRAT-mandat2Syndic}
                   and intnt.nocon = piNumeroContratEntree:
            run majMandatExterne in vhProcPont({&TYPECONTRAT-mandat2Syndic}, piNumeroContratEntree, intnt.noidt, yes).
        end.
        else for first intnt no-lock
                 where intnt.tpidt = {&TYPEBIEN-immeuble}
                   and intnt.tpcon = {&TYPECONTRAT-mandat2Syndic}
                   and intnt.noidt = piNumeroContratEntree:
            run majMandatExterne in vhProcPont({&TYPECONTRAT-mandat2Syndic}, intnt.nocon, piNumeroContratEntree, yes).
        end.
        run destroy in vhProcPont.
    end.
    // Maj Copropriétaires => Compta.
    else if pcTypeLienEntree = "00002" 
    then do:
        run compta/pontCompta/majCpt.p persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        for each ctCtt no-lock
            where ctCtt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
              and ctCtt.noct1 = piNumeroMandatEntree
              and ctCtt.tpct2 = {&TYPECONTRAT-titre2copro}
          , each intnt no-lock
            where intnt.tpcon = ctctt.tpct2
              and intnt.nocon = ctctt.noct2
              and intnt.tpidt = {&TYPEROLE-Coproprietaire}
          , first vbRoles no-lock 
            where vbRoles.tprol = intnt.tpidt 
              and vbRoles.norol = intnt.noidt
          , first tiers no-lock
            where tiers.notie = vbRoles.notie:
            empty temp-table ttParamCompte.
            create ttParamCompte.
            assign
                ttParamCompte.iCodeSoc       = integer(mToken:cRefCopro)
                ttParamCompte.cTypeContrat   = {&TYPECONTRAT-mandat2Syndic} 
                ttParamCompte.iCodeEtab      = piNumeroMandatEntree
                ttParamCompte.cTypeRole      = pcTypeRoleEntree
                ttParamCompte.iNumeroRole    = intnt.noidt
                ttParamCompte.cNomRole       = outilFormatage:getNomTiers(tiers.notie)
                ttParamCompte.iNumerateur    = piNumerateurTantiemeEntree
                ttParamCompte.iDenominateur  = piDenominateurTantiemeEntree
             .
            run createCompte in vhProc(table ttParamCompte, output viRetour).
            if viRetour <> 0 then mError:create2Error(controleCompte(viRetour, piNumeroMandatEntree), 104237).
        end.
        run destroy in vhProc.
    end.
    // Lien Mandat => Compta
    else if pcTypeLienEntree = "00003" then do:
        run compta/pontCompta/majCpt.p persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        for first vbRoles no-lock
            where vbRoles.tprol = pcTypeIdentifiantEntree
              and vbRoles.norol = piNumeroRoleEntree
              and vbRoles.notie = piNumeroContratEntree
          , first tiers no-lock
            where tiers.notie = vbRoles.notie:
            empty temp-table ttParamCompte.
            create ttParamCompte.
            assign
                ttParamCompte.iCodeSoc       = integer(mToken:cRefCopro)
                ttParamCompte.cTypeContrat   = {&TYPECONTRAT-mandat2Syndic} 
                ttParamCompte.iCodeEtab      = piNumeroMandatEntree
                ttParamCompte.cTypeRole      = pcTypeIdentifiantEntree
                ttParamCompte.iNumeroRole    = vbRoles.norol
                ttParamCompte.cNomRole       = outilFormatage:getNomTiers(tiers.notie)
                ttParamCompte.iNumerateur    = piNumerateurTantiemeEntree
                ttParamCompte.iDenominateur  = piDenominateurTantiemeEntree
            .
            run createCompte in vhProc(table ttParamCompte, output viRetour).
            if viRetour <> 0 then mError:create2Error(controleCompte(viRetour, piNumeroMandatEntree), 104237).
        end.
        run destroy in vhProc.
    end.
end procedure.

procedure CreationDomiciliationCompta:
    /*------------------------------------------------------------------------------
    Purpose: Création domiciliation bancaire en compta (Table ARIB)
    Notes  : Ancienne procédure CreCpArib dans incliadb.i
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContratEntree        as character no-undo.
    define input parameter piNumeroContratEntree      as int64     no-undo.
    define input parameter pcTypeIdentifiantEntree    as character no-undo.
    define input parameter piNumeroIndentifiantEntree as int64     no-undo.
    define input parameter piNumeroMandatEntree       as int64     no-undo.
    define input parameter piNumeroCompteEntree       as int64     no-undo.

    define variable vhProc              as handle    no-undo.
    define variable viNumeroRole        as int64     no-undo.
    define variable viRetour            as integer   no-undo.
    define variable vcTitulaireIban     as character no-undo.
    define variable vcDomiciliationIban as character no-undo.
    define variable viNumeroInterneIban as integer   no-undo.
    define variable viNumeroSociete     as integer   no-undo.
    define variable viNumeroContrat     as int64     no-undo.
    define buffer intnt   for intnt.
    define buffer tiers   for tiers.
    define buffer ctCtt   for ctCtt.
    define buffer ctanx   for ctanx.
    define buffer vbRoles for roles.

    if integer(mToken:cRefPrincipale) = {&REFCLIENT-MANPOWER} then return.

    //Pas de création de compte bancaire Compta pour les salariés ou les contrats salariés
    if pcTypeContratEntree = {&TYPECONTRAT-Salarie} or pcTypeIdentifiantEntree = {&TYPEROLE-salarie}
    or pcTypeContratEntree = {&TYPECONTRAT-SalariePegase} or pcTypeIdentifiantEntree = {&TYPEROLE-salariePegase} then return.

    assign
        viNumeroSociete = if pcTypeContratEntree = {&TYPECONTRAT-mandat2Syndic} or pcTypeContratEntree = {&TYPECONTRAT-titre2copro} then integer(mToken:cRefCopro)
                          else if pcTypeContratEntree = {&TYPECONTRAT-mandat2Gerance} or pcTypeContratEntree =  {&TYPECONTRAT-bail} then integer(mToken:cRefGerance)
                          else integer(mToken:cRefPrincipale)
        viNumeroContrat = if pcTypeContratEntree = {&TYPECONTRAT-titre2copro} or pcTypeContratEntree = {&TYPECONTRAT-bail} then int64(truncate(piNumeroContratEntree / 100000,0))
                          else piNumeroContratEntree
        viNumeroRole    = if pcTypeIdentifiantEntree = {&TYPEROLE-locataire} then int64(piNumeroIndentifiantEntree modulo 100000)
                          else piNumeroIndentifiantEntree
    .
    for first ctanx no-lock
        where ctanx.Tpcon = {&TYPECONTRAT-RIB}
          and ctanx.Nocon = piNumeroCompteEntree:
        assign
            vcTitulaireIban     = ctanx.LbTit
            vcDomiciliationIban = ctanx.LbDom
            viNumeroInterneIban = ctanx.NoDoc
        .
    end.

    run crud/arib_CRUD.p persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    run readArib in vhProc(viNumeroSociete, viNumeroContrat, integer(pcTypeIdentifiantEntree), string(viNumeroRole, "99999"), viNumeroInterneIban).
    find first ttArib no-error.
    if available ttArib
    then assign 
       ttArib.Domicil[1] = vcTitulaireIban
       ttArib.Domicil[2] = vcDomiciliationIban
       ttArib.CRUD       = "U"
    .
    else do:
        create ttArib.
        assign 
            ttArib.Soc-Cd     = integer(viNumeroSociete)
            ttArib.Etab-Cd    = viNumeroContrat
            ttArib.Tprole     = integer(pcTypeIdentifiantEntree)
            ttArib.Cpt-Cd     = string(viNumeroRole, "99999")
            ttArib.Domicil[1] = vcTitulaireIban
            ttArib.Domicil[2] = vcDomiciliationIban
            ttArib.Nodoc      = viNumeroInterneIban
            ttArib.CRUD       = "C"
        .
    end.
    run setArib in vhProc(table ttArib).
    run destroy in vhProc.

end procedure.

procedure RecInfLie private:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  : 
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeIdent     as character no-undo.
    define output parameter piNumeroTiersMandant     as integer   no-undo.
    define output parameter piNumeroRoleMandant      as int64     no-undo.

    for first intnt no-lock
        where intnt.tpcon = pcTypeContrat
          and intnt.nocon = piNumeroContrat
          and intnt.tpidt = pcTypeIdent
    ,   first roles no-lock
        where roles.tprol = intnt.tpidt
          and roles.norol = intnt.noidt
    ,   first tiers no-lock
        where tiers.notie = roles.notie:
        assign
            piNumeroTiersMandant = tiers.notie
            piNumeroRoleMandant  = roles.norol
        .
    end.

end procedure.

function lanceMiseAJourEmployeCompta returns integer (pcTypeRoleEntree as character, piNumeroRoleEntree as int64):
    /*------------------------------------------------------------------------------
    Purpose: Procedure d'appel de l'interface de maj des employés en compta
    Notes  : Ancienne procédure RnMajEmpl dans incliadb.i
    Codes retour :
    0 = OK
    1 = collectif inexistant (CSSCPTCOL)
    2 = Regroupement inexistant (CCPTCOL)
    3 = Table de contrôle inexistante (ACTRC)

    10 = Salarié non trouvé ou incomplet
    11 = Adresse Salarié non trouvée
    ------------------------------------------------------------------------------*/

//ATTENTION!!! En cas de modification de cette procédure, il faut la modifier également dans l'include COMM/MAJEMPL.I

    {application/include/glbsepar.i}
    define variable voCollection                as class collection no-undo.
    define variable vcTypeMandatMaitre          as character    no-undo.
    define variable vhProc                      as handle       no-undo.
    define variable viNumeroErreur              as integer      no-undo.
    define variable viNumeroMandat              as int64        no-undo.
    define variable viNumeroOrdreSalarie        as integer      no-undo.
    define variable vcModeReglementSalarie      as character    no-undo.
    define variable vcCodeCiviliteSalarie       as character    no-undo.
    define variable vcTelephoneSalarie          as character    no-undo.
    define variable vcAdresseSalarie            as character    no-undo.
    define variable vcCodePostalSalarie         as character    no-undo.
    define variable vcVilleSalarie              as character    no-undo.
    define variable vcTitulaireIbanSalarie      as character    no-undo.
    define variable vcDomiciliationIbanSalarie  as character    no-undo.
    define variable vcIbanSalarie               as character    no-undo.
    define variable vcBicSalarie                as character    no-undo.
    define variable vcMailSalarie               as character    no-undo.
    define variable vcTypeModeEnvoiSalarie      as character    no-undo.
    define variable vcCodeReglement             as character    no-undo.
    define variable vcTypeContratSalarie        as character    no-undo.
    define buffer vbRoles       for roles.
    define buffer ctctt         for ctctt.
    define buffer tiers         for tiers.
    define buffer iLienAdresse  for iLienAdresse.
    define buffer iBaseAdresse  for iBaseAdresse.
    define buffer telephones    for telephones.

    if integer(mToken:cRefPrincipale) = {&REFCLIENT-MANPOWER} then return 0.

    if pcTypeRoleEntree = {&TYPEROLE-salarie}
    then assign 
        vcTypeContratSalarie = {&TYPECONTRAT-Salarie}
        viNumeroMandat = truncate(piNumeroRoleEntree / 10000,0)
        viNumeroOrdreSalarie = piNumeroRoleEntree modulo 100
    .
    else assign
        vcTypeContratSalarie = {&TYPECONTRAT-SalariePegase}
        viNumeroMandat = truncate(piNumeroRoleEntree / 100000,0)
        viNumeroOrdreSalarie = piNumeroRoleEntree modulo 100000
    .
    for first ctctt no-lock
        where ctctt.tpct2 = vcTypeContratSalarie
          and ctctt.noct2 = piNumeroRoleEntree
          and ctctt.noct1 = viNumeroMandat:
        vcTypeMandatMaitre = ctctt.tpct1.
    end. 
    find first vbRoles no-lock 
        where vbRoles.tprol = pcTypeRoleEntree
          and vbRoles.norol = piNumeroRoleEntree no-error.
    if not available vbRoles then return 10.

    find first tiers no-lock 
        where tiers.notie = vbRoles.notie no-error.
    if not available tiers then return 10.

    case tiers.cdcv1 :
        when "10001" then vcCodeCiviliteSalarie = "00010". // Monsieur
        when "10002" then vcCodeCiviliteSalarie = "00014". // Maitre
        when "10005" then vcCodeCiviliteSalarie = "00013". // Mademoiselle
        when "10006" then vcCodeCiviliteSalarie = "00011". // Madame
    end case.
    find first iLienAdresse no-lock
        where iLienAdresse.cTypeIdentifiant = pcTypeRoleEntree
          and iLienAdresse.iNumeroIdentifiant = piNumeroRoleEntree
          and iLienAdresse.cTypeAdresse = "00001" no-error.
    if not available iLienAdresse then return 11.

    find first iBaseAdresse no-lock
        where iBaseAdresse.iNumeroAdresse = iLienAdresse.iNumeroAdresse no-error.
    if not available iBaseAdresse then return 11.

    for each telephones no-lock
        where telephones.tpidt = pcTypeRoleEntree
          and telephones.noidt = piNumeroRoleEntree:
        if telephones.tptel = "00001" and vcTelephoneSalarie = "" then vcTelephoneSalarie = telephones.notel.
        if telephones.tptel = "00003" and vcMailSalarie = "" then vcMailSalarie = telephones.notel.
    end.
    assign
        vcVilleSalarie          = iBaseAdresse.cVille
        vcCodePostalSalarie     = iBaseAdresse.cCodePostal
        vcTypeModeEnvoiSalarie  = (if tiers.tpmod <> ? then tiers.tpmod else "")
        vcAdresseSalarie        = substitute("&1&2&3", outilFormatage:formatageAdresse(buffer iLienAdresse, buffer iBaseAdresse, 0), separ[4], trim(iBaseAdresse.cComplementDistribution))
    .
    vcModeReglementSalarie = "C".  //Chèque
    for first ctrat no-lock 
        where ctrat.tpcon = vcTypeContratSalarie
          and ctrat.nocon = piNumeroRoleEntree:
        if num-entries(ctrat.lbdiv, "@") >= 2 then do:
            assign 
                vcCodeReglement = entry(2 , ctrat.lbdiv, "@") 
                vcCodeReglement = entry(1 , vcCodeReglement, "#") 
            .
            if  vcCodeReglement = {&MODEREGLEMENT-virement} or vcCodeReglement = {&MODEREGLEMENT-virementListe} then vcModeReglementSalarie = "V".
        end.
    end.
    // Recherche compte bancaire du salarié
    for first rlctt no-lock 
        where rlctt.tpidt = pcTypeRoleEntree
          and rlctt.noidt = piNumeroRoleEntree
          and rlctt.tpct1 = vcTypeContratSalarie
          and rlctt.noct1 = piNumeroRoleEntree
          and rlctt.tpct2 = {&TYPECONTRAT-RIB}
      , first ctanx no-lock
        where ctanx.Tpcon = {&TYPECONTRAT-RIB}
          and ctanx.Nocon = rlctt.noct2:
        assign 
            vcTitulaireIbanSalarie     = ctanx.LbTit
            vcDomiciliationIbanSalarie = ctanx.LbDom
            vcIbanSalarie              = ctanx.iban
            vcBicSalarie               = ctanx.bicod
        .
    end.

    voCollection = new collection().
    voCollection:set('iNumeroSociete',      mToken:getSociete(vcTypeMandatMaitre)).
    voCollection:set('iNumeroMandat',       viNumeroMandat).
    voCollection:set('cNumeroCompte',       substitute("&1&2", string(viNumeroMandat,"9999"), string(viNumeroOrdreSalarie,"99999"))).
    voCollection:set('cCodeCollectif',      "04210").
    voCollection:set('cNumeroSousCompte',   string(viNumeroOrdreSalarie,"99999")).
    voCollection:set('cCleEmploye',         substitute("&1&2", string(viNumeroMandat,"9999"), string(viNumeroOrdreSalarie,"99999"))).
    voCollection:set('cNom',                tiers.lnom1).
    voCollection:set('cPrenom',             tiers.lpre1).
    voCollection:set('cCodeReglement',      vcModeReglementSalarie).
    voCollection:set('iRaisonSociale',      vcCodeCiviliteSalarie).
    voCollection:set('cTelephone',          vcTelephoneSalarie).
    voCollection:set('cAdresse',            vcAdresseSalarie).
    voCollection:set('cCodePostal',         vcCodePostalSalarie).
    voCollection:set('cVille',              vcVilleSalarie).
    voCollection:set('cTitulaireIban',      vcTitulaireIbanSalarie).
    voCollection:set('cDomiciliationIban',  vcDomiciliationIbanSalarie).
    voCollection:set('cIBAN',               vcIbanSalarie).
    voCollection:set('cBIC',                vcBicSalarie).
    voCollection:set('cEmail',              vcMailSalarie).
    voCollection:set('cTpMode',             vcTypeModeEnvoiSalarie).

    run compta/miseAJourEmploye.p (voCollection, output viNumeroErreur).
    delete object voCollection.

end function.

function lanceMiseAJourFournisseursLoyerCompta returns integer (pcTypeRoleEntree as character, piNumeroRoleEntree as int64):
    /*------------------------------------------------------------------------------
    Purpose: Procedure d'appel de l'interface de maj des Fournisseurs loyer en compta SOCIETE
    Notes  : Ancienne procédure RnMajFloy dans incliadb.i
    Codes retour :
    0 = OK

    10 = Rôle non trouvé ou incomplet
    20 = Erreur en maj compta (par miseAJourFournisseursLoyer.p)
    ------------------------------------------------------------------------------*/
    define variable vlErreur as logical no-undo.

    if integer(mToken:cRefPrincipale) = {&REFCLIENT-MANPOWER} then return 0.

    if not can-find(first roles no-lock
                    where roles.tprol = pcTypeRoleEntree
                      and roles.norol = piNumeroRoleEntree)
        or not can-find(first tiers no-lock 
                        where tiers.notie = roles.notie) then return 10.

    run compta/miseAJourFournisseursLoyer.p (integer(mToken:cRefGerance), piNumeroRoleEntree, output vlErreur).
    if vlErreur then do:
        mError:createError({&error}, substitute("Erreur en création/maj fournisseur de loyer &1. Veuillez consulter le fichier &2",string(piNumeroRoleEntree),"pmeflo.err")).
        return 20.
    end.

    return 0.
end function.
