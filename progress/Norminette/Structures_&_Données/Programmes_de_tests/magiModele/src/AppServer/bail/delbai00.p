/*---------------------------------------------------------------------------
File        : delbai00.p
Purpose     : Suppression d'un contrat lie type Pre-Bail  
Author(s)   : SY 01/10/2002  -  GGA 2018/02/15
Notes       : reprise adb/lib/delbai00.p
derniere revue: 2018/04/13 - phm: KO
                après lancementPgm, il serait bien de faire suppressionPgmPersistent avant return.
correction 2018/04/24 GGA: 
             pas de changement, le suppressionPgmPersistent est fait dans le pgm de plus haut niveau
             ce pgm est appele dans une boucle et meme sans cela on peut executer plusieurs fois les memes pgms                 
---------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2tache.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{adblib/include/ctrat.i}
{tache/include/tache.i}
{outils/include/lancementProgramme.i}

define variable ghProc as handle no-undo.

procedure SupPreBail:
    /*------------------------------------------------------------------------------
    Purpose: procedure de suppression du contrat Pré-Bail 
    Notes  : service externe
    ------------------------------------------------------------------------------*/    
    define input parameter pcTypeContrat             as character no-undo. 
    define input parameter piNumeroContrat           as int64     no-undo.
    define input parameter piNumeroMandat            as int64     no-undo.
    define input parameter plSuppressionEvenementiel as logical   no-undo.
    define input-output parameter poCollectionHandlePgm as class collection no-undo.

    define variable vcTypeRole as character no-undo.

    define buffer intnt   for intnt.
    define buffer vbintnt for intnt.
    define buffer vbroles for roles.

mLogger:writeLog(0, substitute("delbail00.p SupPreBail type contrat : &1 numero contrat : &2 numero mandat &3", pcTypeContrat, piNumeroContrat, piNumeroMandat)).
    vcTypeRole = if pcTypeContrat = {&TYPECONTRAT-preBail} then {&TYPEROLE-candidatLocataire} else {&TYPEROLE-locataire}.

    /* Quittances */
    if can-find(first pquit no-lock
                where pquit.noloc = piNumeroContrat)
    then do:
        ghProc = lancementPgm("bail/quittancement/pquit_CRUD.p", poCollectionHandlePgm).
        run deletePquitSurNoloc in ghProc(piNumeroContrat).
        if mError:erreur() then return.
    end.

    /* taches du contrat */
    if can-find(first tache no-lock 
                where tache.tpcon = pcTypeContrat
                  and tache.nocon = piNumeroContrat)
    then do:                
        ghProc = lancementPgm ("tache/tache.p", poCollectionHandlePgm).
        run deleteTacheSurContrat in ghProc(pcTypeContrat, piNumeroContrat).
        if mError:erreur() then return.
    end.

    /* liens cttac       */
    if can-find(first cttac no-lock 
                where cttac.tpcon = pcTypeContrat
                  and cttac.nocon = piNumeroContrat)
    then do:                    
        ghProc = lancementPgm("adblib/cttac_CRUD.p", poCollectionHandlePgm).
        run deleteCttacSurContrat in ghProc(pcTypeContrat, piNumeroContrat).
        if mError:erreur() then return.
    end.
    
    /* Ajout SY le 01/12/2009 : tache quittancement rubriques calculées */ 
    if can-find(first detail no-lock 
                where detail.cddet = pcTypeContrat
                  and detail.nodet = piNumeroContrat
                  and detail.iddet = integer("04360"))
    then do:               
        ghProc = lancementPgm ("adblib/detail_CRUD.p", poCollectionHandlePgm).
        run deleteDetailSurCodeNumeroIndicateur in ghProc(pcTypeContrat, piNumeroContrat, integer("04360")).
        if mError:erreur() then return.
    end.

    /* liens banque (rlctt)      */
    if can-find(first rlctt no-lock
                where rlctt.tpct2 = pcTypeContrat
                  and rlctt.noct2 = piNumeroContrat)
    then do:                 
        ghProc = lancementPgm ("adblib/rlctt_CRUD.p", poCollectionHandlePgm).
        run deleteRlcttSurContrat in ghProc(pcTypeContrat, piNumeroContrat).
        if mError:erreur() then return.
    end.

    /* Roles associés  & adresses */
boucleRoleAdresse:    
    for each intnt no-lock
        where intnt.tpcon = pcTypeContrat
          and intnt.nocon = piNumeroContrat
          and intnt.tpidt < {&TYPEBIEN-immeuble}
      , first vbroles no-lock
        where vbroles.tprol = intnt.tpidt
          and vbroles.norol = intnt.noidt:
        
        /* mandant etc... : vérifier si roles pas utilisé ailleurs */
        if intnt.tpidt <> vcTypeRole
        and can-find(first vbintnt no-lock
                     where vbintnt.tpidt = vbroles.tprol
                       and vbintnt.noidt = vbroles.norol
                       and (vbintnt.tpcon <> pcTypeContrat or vbintnt.nocon <> piNumeroContrat)) then next boucleRoleAdresse.

        if can-find(first ladrs no-lock 
                    where ladrs.tpidt = vbroles.tprol
                      and ladrs.noidt = vbroles.norol)
        then do:                                
            ghProc = lancementPgm ("adresse/ladrs_CRUD.p", poCollectionHandlePgm).
            run deleteLadrsSurNoidt in ghProc(vbroles.tprol, vbroles.norol).
            if mError:erreur() then return.
        end.
 
        if can-find(first telephones no-lock 
                    where telephones.tpidt = vbroles.tprol
                      and telephones.noidt = vbroles.norol)
        then do:                                    
            ghProc = lancementPgm ("tiers/telephones_CRUD.p", poCollectionHandlePgm).
            run deleteTelephonesSurNoidt in ghProc(vbroles.tprol, vbroles.norol).
            if mError:erreur() then return.
        end.

        ghProc = lancementPgm ("role/roles_CRUD.p", poCollectionHandlePgm).
        run purgeRoles in ghProc(vbroles.tprol, vbroles.norol). 
        if mError:erreur() then return.
             
    end.

    /* Lien contrat maitre - contrat li‚ */
    if can-find(first ctctt no-lock
                where ctctt.tpct2 = pcTypeContrat
                  and ctctt.noct2 = piNumeroContrat)
    then do:
        ghProc = lancementPgm ("adblib/ctctt_CRUD.p", poCollectionHandlePgm).
        run deleteCtcttSurContratSecondaire in ghProc(pcTypeContrat, piNumeroContrat).
        if mError:erreur() then return.
    end.

    /* liens intnt */
    if can-find(first intnt no-lock
                where intnt.tpcon = pcTypeContrat
                  and intnt.nocon = piNumeroContrat)
    then do:        
        ghProc = lancementPgm ("adblib/intnt_CRUD.p", poCollectionHandlePgm).
        run deleteIntntSurContrat in ghProc(pcTypeContrat, piNumeroContrat).
        if mError:erreur() then return.
    end.
    
    /* echelle mobile */
    if can-find(first echlo no-lock   
                where echlo.tpcon = pcTypeContrat
                  and echlo.nocon = piNumeroContrat)
    then do:    
        ghProc = lancementPgm ("adblib/echlo_CRUD.p", poCollectionHandlePgm).
        run deleteEchloSurContrat in ghProc(pcTypeContrat, piNumeroContrat).
        if mError:erreur() then return.
    end.
    
    /* calendrier */
    if can-find(first calev no-lock   
                where calev.tpcon = pcTypeContrat
                  and calev.nocon = piNumeroContrat)
    then do:
        ghProc = lancementPgm ("adblib/calev_CRUD.p", poCollectionHandlePgm).
        run deleteCalevSurContrat in ghProc(pcTypeContrat, piNumeroContrat).
        if mError:erreur() then return.
    end.
    
    /* chiffre d'affaire */
    if can-find(first chaff no-lock   
                where chaff.tpcon = pcTypeContrat
                  and chaff.nocon = piNumeroContrat)
    then do:
        ghProc = lancementPgm ("adblib/chaff_CRUD.p", poCollectionHandlePgm).
        run deleteChaffSurContrat in ghProc(pcTypeContrat, piNumeroContrat).
        if mError:erreur() then return.
    end.
    
    /* Ajout SY le 05/11/2010 : Traitement des révisions */
    if can-find(first revtrt no-lock   
                where revtrt.tpcon = pcTypeContrat
                  and revtrt.nocon = piNumeroContrat)
    then do:
        ghProc = lancementPgm ("adblib/revtrt_CRUD.p", poCollectionHandlePgm).
        run deleteRevtrtSurContrat in ghProc(pcTypeContrat, piNumeroContrat).
        if mError:erreur() then return.
    end.
    
    if can-find(first revhis no-lock   
                where revhis.tpcon = pcTypeContrat
                  and revhis.nocon = piNumeroContrat)
    then do:
        ghProc = lancementPgm ("adblib/revhis_CRUD.p", poCollectionHandlePgm).
        run deleteRevhisSurContrat in ghProc(pcTypeContrat, piNumeroContrat).
        if mError:erreur() then return.
    end.

    /* alertes */
    if can-find(first gadet no-lock
                where gadet.tpctt = pcTypeContrat
                  and gadet.noctt = decimal(piNumeroContrat))
    then do:
        ghProc = lancementPgm ("adblib/gadet_CRUD.p", poCollectionHandlePgm).
        run deleteGadetSurContrat in ghProc(pcTypeContrat, decimal(piNumeroContrat)).
        if mError:erreur() then return.
    end.
        
    /* 24/04/2013 : suppression des historiques de répartition de la colocation */
    if can-find(first coloc no-lock   
                where coloc.tpcon = pcTypeContrat
                  and coloc.nocon = piNumeroContrat)
    then do:        
        ghProc = lancementPgm ("adblib/coloc_CRUD.p", poCollectionHandlePgm).
        run deleteColocSurContrat in ghProc(pcTypeContrat, piNumeroContrat).
        if mError:erreur() then return.
    end.

    /* Ajout SY le 26/07/2013 : SEPA */
    if can-find(first mandatSepa no-lock
                where mandatSepa.tpmandat = {&TYPECONTRAT-sepa}
                  and mandatSepa.tpcon    = pcTypeContrat 
                  and mandatSepa.nocon    = piNumeroContrat)
    then do:
        ghProc = lancementPgm ("adblib/mandatSEPA_CRUD.p", poCollectionHandlePgm).
        run deleteMandatSepaSurContrat in ghProc({&TYPECONTRAT-sepa}, pcTypeContrat, piNumeroContrat).
        if mError:erreur() then return.
    end.

    /*--> NP 1215/0218 Add gestion module Location ALLZ **/
    run Maj_FicheLocation (piNumeroContrat, piNumeroMandat, input-output poCollectionHandlePgm).
    if mError:erreur() then return.

    /*--> Evenementiel */
    /* NP 0312/0134 supp de l'événementiel que si supp volontaire du prébail et non validation du prébail en bail !!! */
    if plSuppressionEvenementiel 
    then do:
        ghProc = lancementPgm ("evenementiel/supEvenementiel.p", poCollectionHandlePgm).
        run SupEvenementiel in ghProc(pcTypeContrat, piNumeroContrat, input-output poCollectionHandlePgm).
        if mError:erreur() then return.

        run SupEvenementiel in ghProc(vcTypeRole, piNumeroContrat, input-output poCollectionHandlePgm).
        if mError:erreur() then return.
        
    end.

    if can-find(first cthis no-lock
                where cthis.tpcon = pcTypeContrat
                  and cthis.nocon = piNumeroContrat)
    then do:
        ghProc = lancementPgm ("adblib/cthis_CRUD.p", poCollectionHandlePgm).
        run deleteCthisSurContrat in ghProc(pcTypeContrat, piNumeroContrat).
        if mError:erreur() then return.
    end.

    /* Ajout SY le 25/11/2010 - suppression % refacturation dépenses mandat */
    if can-find(first tbdet no-lock
                where tbdet.cdent          = "REFAC-" + pcTypeContrat
                  and integer(tbdet.iden1) = piNumeroContrat)
    then do:    
        ghProc = lancementPgm ("adblib/tbdet_CRUD.p", poCollectionHandlePgm).
        run deleteTbdetSurIdentifiant1 in ghProc("REFAC-" + pcTypeContrat, piNumeroContrat).
        if mError:erreur() then return.
    end.

    /* contrat */
    for first ctrat no-lock
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroContrat:
        empty temp-table ttCtrat.
        create ttCtrat.
        assign
            ttCtrat.tpcon       = ctrat.tpcon 
            ttCtrat.nocon       = ctrat.nocon
            ttCtrat.CRUD        = "D"
            ttCtrat.dtTimestamp = datetime(ctrat.dtmsy, ctrat.hemsy)
            ttCtrat.rRowid      = rowid(ctrat)
        .
        ghProc = lancementPgm ("adblib/ctrat_CRUD.p", poCollectionHandlePgm).
        run setCtrat in ghProc(table ttCtrat by-reference).
        if mError:erreur() then return.
    end.
    /* INSITU */
    /* ATTENTION : NE PAS GERER LA SUPPRESSION INSITU DU PREBAIL !!!!
       ELLE EST FAITE A PART DANS GPBAIL00.P CAR ON APPELLE DELBAIL.P
       A LA FIN DE LA VALIDATION DU PREBAIL POUR SUPPRIMER LE PREBAIL. 
       IL NE FAUT PAS SUPPRIMER LES TRACES DANS DETAIL SAUF SI ON 
       SUPPRIME VOLONTAIREMENT LE PREBAIL !!! */

end procedure.

procedure Maj_FicheLocation private:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  :
    ------------------------------------------------------------------------------*/    
    define input parameter piNumeroContrat as int64 no-undo.
    define input parameter piNumeroMandat  as int64 no-undo.
    define input-output parameter poCollectionHandlePgm as class collection no-undo.

    define buffer location for location.
    define buffer intnt    for intnt. 
    define buffer vbctrat  for ctrat.
    define buffer ctrat    for ctrat.
    define buffer tache    for tache.

    empty temp-table ttTache.
    for last location no-lock 
        where location.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and location.nocon = piNumeroMandat
          and location.noapp = integer(substring(string(piNumeroContrat, "9999999999"), 6, 3, "character")): 
        for each intnt no-lock
            where intnt.tpcon = {&TYPECONTRAT-MandatLocation}
              and intnt.tpidt = "06000"
              and intnt.noidt = location.nofiche
          , first vbctrat no-lock
            where vbctrat.tpcon = intnt.tpcon
              and vbctrat.nocon = intnt.nocon:
            for first ctrat no-lock 
                where ctrat.tpcon = {&TYPECONTRAT-MandatLocation}
                  and ctrat.nocon = vbctrat.nocon:
                for last tache no-lock  
                    where tache.tpcon = ctrat.tpcon
                      and tache.nocon = ctrat.nocon
                      and tache.tptac = {&TYPEtache-04347}:
                    create ttTache.
                    assign
                        ttTache.tpcon       = tache.tpcon
                        ttTache.nocon       = tache.nocon
                        ttTache.tptac       = tache.tptac
                        ttTache.notac       = tache.notac
                        ttTache.CRUD        = "U"
                        ttTache.dtTimestamp = datetime(tache.dtmsy, tache.hemsy) 
                        ttTache.rRowid      = rowid(tache) 
                    .
                    ttTache.duree = if tache.duree > 1 then tache.duree - 1 else 0.
                    if ttTache.duree = 0 then ttTache.tpfin = '00000'.
                end.
            end.
        end.  
    end.
    if can-find(first ttTache) then do:
        ghProc = lancementPgm ("tache/tache.p", poCollectionHandlePgm).
        run setTache in ghProc(table ttTache by-reference).
        if mError:erreur() then return.
    end.

end procedure.
