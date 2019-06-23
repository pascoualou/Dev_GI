/*-----------------------------------------------------------------------------
File      : suprol01.p
Purpose   : Suppression d'un role après contrôle
Author(s) : SY 12/01/2004   -  GGA 2018/02/28
Notes     : reprise adb/lib/suprol01.p

gga todo ATTENTION pour l'instant seulement teste pour role acheteur (depuis suppression mandat mutation)

01  15/03/2004  SY    1203/0038: Ajout gestion transfert suppr au DPS (GEJS/COES/GEFS)
02  23/11/2004  SY    1104/0150: Ajout gestion des nouveaux roles associes a l'usufruit
03  10/10/2005  AF    0205/0300: Roles 00071 - Gerant
04  12/04/2006  SY    0404/0305: Ajout suppr role 00016 indivisaire de gérance + adaptation pour les PURGES
05  13/04/2006  SY    0404/0305: Ajout nom et SIRET en retour
06  14/04/2006  SY    0404/0305: Suppression evenementiel avec le programme event/supident.p
07  14/04/2006  SY    0404/0305: ajout table ctrlb
08  27/04/2006  SY    0404/0305: ajout suppression evenementiel fournisseur "FOU" suite à PURGE fournisseurs
09  27/11/2007  SY    1107/0217: Ajout suppression contrat bloc-note 01093
10  29/05/2009  SY    0509/0263: ajout nlle table telephones
11  03/09/2009  SY    0809/0018: procedure CreTrsup mise en include (CreTrsup.i)
12  21/10/2010  PL    1010/0181: Suppression indivisaire.
13  10/04/2012  PL    0312/0009: Ajout Dir. d'agence (00060)
14  19/10/2012  SY    1012/0063: Des services ont été supprimés suite à la Fusion GERER-DAUCHEZ + refonte des Groupes.
                                Mais il reste toutes les alertes-evenement associées !
15  19/10/2012  SY    1012/0063: ajout tables manquantes (event, gaint, trait...)
16  25/02/2013  SY    0113/0091: ajout nlle tables evtev
17   27/02/13   OF    0303/0099: Ajout devis et réponses devis
18  26/12/2013  SY    1213/0178: Amélioration gestion LOCK sur ltdiv
19  02/07/2014  SY    0114/0244: Paie Pegase
-----------------------------------------------------------------------------*/
{preprocesseur/famille2role.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2intervention.i}
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{outils/include/lancementProgramme.i}
{adblib/include/ctrat.i}
{adblib/include/intnt.i}
{tache/include/tache.i}


define variable gcTypeRole   as character no-undo.
define variable giNumeroRole as int64     no-undo.
define variable gcTypeTrt    as character no-undo.
define variable ghProc       as handle    no-undo.
define variable goCollectionHandlePgm  as class collection no-undo.

procedure suppressionRole:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter  pcTypeRole       as character no-undo.
    define input parameter  piNumeroRole     as int64     no-undo.
    define input parameter  pcTypeTrt        as character no-undo.
    define input-output parameter poCollectionHandlePgm as class collection no-undo.

    define variable vcListeRoleProprietaire as character no-undo.
    define variable viNumeroTiers           as integer   no-undo.
    define variable viCpUseInc              as integer   no-undo.
    define variable vcRetourCtrl            as character no-undo.

    define buffer vbroles for roles.
    define buffer sys_pg  for sys_pg.

    assign
        goCollectionHandlePgm   = poCollectionHandlePgm
        gcTypeRole              = pcTypeRole
        giNumeroRole            = piNumeroRole
        gcTypeTrt               = pcTypeTrt
        vcListeRoleProprietaire = substitute("&1,&2", {&TYPEROLE-mandataire}, {&TYPEROLE-gerant})  // Liste des roles de la famille "propriétaires" + gérant + mandataire
    .
    for each sys_pg no-lock
      where sys_pg.tppar = "R_RFR"
        and sys_pg.zone2 = {&FAMILLEROLE-proprietaire}:
        vcListeRoleProprietaire = vcListeRoleProprietaire + "," + sys_pg.zone1.
    end.
    for first vbroles no-lock
        where vbroles.tprol = gcTypeRole
          and vbroles.norol = giNumeroRole:
        viNumeroTiers = vbroles.notie.
    end.
    if gcTypeRole = "FOU" then run supFou.
    if mError:erreur() then return.
    if lookup(gcTypeRole, vcListeRoleProprietaire) > 0 then do:
        case gcTypeRole:
            when {&TYPEROLE-coproprietaire} then run supRolCop(viNumeroTiers).
            when {&TYPEROLE-mandant}        then run supRolMan.
            when {&TYPEROLE-coIndivisaire}  then run supRolInd.
            otherwise                            run supRolDiv.
        end case.
        if mError:erreur() then return.
    end.
    else case gcTypeRole:
        when {&TYPEROLE-locataire} then do:
            mError:createError({&error}, 1000662). //Suppression locataire non gérée par suprol01.p (utiliser delbail.p)
            return.
        end.
        when {&TYPEROLE-salarie} then do:
            mError:createError({&error}, 1000663). //Suppression salarié non gérée par suprol01.p (utiliser delsal00.p)
            return.
        end.
        when {&TYPEROLE-salariePegase} then do:
            mError:createError({&error}, 1000664). //Suppression salarié Pégase non gérée par suprol01.p (utiliser delsalpz.p)
            return.
        end.
        otherwise run supRolDiv.
    end case.
    if mError:erreur() then return.
    
    //Suppression du tiers si pas utilisé ailleurs
    if viNumeroTiers <> 0
    then do:
        ghProc = lancementPgm("tiers/ctsuptie.p", goCollectionHandlePgm).         
        run controleTiers in ghProc(viNumeroTiers, no, output vcRetourCtrl).
        if vcRetourCtrl = "00"
        then do:
            ghProc = lancementPgm("tiers/suptie01.p", goCollectionHandlePgm).         
            run suppressionTiers in ghProc(viNumeroTiers, input-output goCollectionHandlePgm).
            if mError:erreur() then return.
        end.
    end.

end procedure.

procedure SupFou private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    //Suppression des tarifs travaux
    if can-find(first tarif no-lock   
                where tarif.nofou = giNumeroRole)
    then do:
        ghProc = lancementPgm("adblib/tarif_CRUD.p", goCollectionHandlePgm).
        run deleteTarifSurNofou in ghProc(giNumeroRole).
        if mError:erreur() then return.
    end.
    
    //Suppression des devis
    if can-find(first devis no-lock   
                where  devis.nofou = giNumeroRole)
    then do:    
        ghProc = lancementPgm("adblib/devis_CRUD.p", goCollectionHandlePgm).
        run deleteDevisSurNofou in ghProc(giNumeroRole).
        if mError:erreur() then return.
    end.
    
    run supEvenementiel(gcTypeRole, giNumeroRole).

end procedure.

procedure SupRolMan private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de Suppression d'un mandant
    Notes  :
    ------------------------------------------------------------------------------*/
    /* lien adresse + telephones */
    run supAdrTel (gcTypeRole, giNumeroRole).
    if mError:erreur() then return.
    
    /* lien RIB */
    if can-find(first rlctt no-lock
                where rlctt.tpidt = gcTypeRole
                  and rlctt.noidt = giNumeroRole)
    then do:    
        ghProc = lancementPgm("adblib/rlctt_CRUD.p", goCollectionHandlePgm).
        run deleteRlcttSurIdentifiant in ghProc(gcTypeRole, giNumeroRole).
        if mError:erreur() then return.
    end.
    
    /* sigle mandant  */
    if can-find(first sigle no-lock
                where sigle.tprol = gcTypeRole
                  and sigle.norol = giNumeroRole)
    then do:
        ghProc = lancementPgm("adblib/sigle_CRUD.p", goCollectionHandlePgm).
        run deleteSigleSurNorol in ghProc(gcTypeRole, giNumeroRole).
        if mError:erreur() then return.
    end.
    
    /* lien contrat - mandant - bénéficiaire  */
    if can-find(first ctrlb no-lock
                where ctrlb.tpid1 = gcTypeRole
                  and ctrlb.noid1 = giNumeroRole)
    then do:   
        ghProc = lancementPgm( "adblib/ctrlb_CRUD.p", goCollectionHandlePgm).
        run deleteCtrlbSurIdentifiant in ghProc(gcTypeRole, giNumeroRole).
        if mError:erreur() then return.
    end.
    
    /* liens intnt */
    if can-find(first intnt no-lock
                where intnt.tpidt = gcTypeRole
                  and intnt.noidt = giNumeroRole)
    then do:  
        ghProc = lancementPgm("adblib/intnt_CRUD.p", goCollectionHandlePgm).
        run deleteRoleMandant in ghProc (gcTypeRole, giNumeroRole).
        if mError:erreur() then return.
    end.

    empty temp-table ttTache.
    /* Diagnostic technique privatif (04201) */
    for each tache no-lock
        where tache.tpcon = {&TYPECONTRAT-construction}
          and tache.tptac = {&TYPETACHE-diagnosticTechnique}
          and tache.pdreg = "TRUE"
          and tache.tphon = gcTypeRole
          and tache.duree = giNumeroRole:
        create ttTache.
        assign
            ttTache.tpcon   = tache.tpcon
            ttTache.nocon   = tache.nocon
            ttTache.tptac   = tache.tptac
            ttTache.notac   = tache.notac
            ttTache.CRUD        = "D"
            ttTache.dtTimestamp = datetime(tache.dtmsy, tache.hemsy)
            ttTache.rRowid      = rowid(tache)
        .
    end.
    /* Etude technique privatif (04265) */
    for each tache no-lock
        where tache.tpcon = {&TYPECONTRAT-construction}
          and tache.tptac = {&TYPETACHE-04235}
          and tache.pdreg = "TRUE"
          and tache.tphon = gcTypeRole
          and tache.duree = giNumeroRole:
        create ttTache.
        assign
            ttTache.tpcon   = tache.tpcon
            ttTache.nocon   = tache.nocon
            ttTache.tptac   = tache.tptac
            ttTache.notac   = tache.notac
            ttTache.CRUD        = "D"
            ttTache.dtTimestamp = datetime(tache.dtmsy, tache.hemsy)
            ttTache.rRowid      = rowid(tache)
        .
    end.
    if can-find (first ttTache)
    then do:
        ghProc = lancementPgm("tache/tache.p", goCollectionHandlePgm).
        run setTache in ghProc(table ttTache by-reference).
        if mError:erreur() then return.
    end.
    
    /* roles */
    ghProc = lancementPgm ("role/roles_CRUD.p", goCollectionHandlePgm).
    run purgeRoles in ghProc(gcTypeRole, giNumeroRole). 
    if mError:erreur() then return.
        
    /* Evenementiel */
    run supEvenementiel(gcTypeRole, giNumeroRole).
    if mError:erreur() then return.
    
    /* Comptabilité sauf si on vient de la compta */
    if gcTypeTrt <> "PURGE" then run supCptaRol.

end procedure.

procedure SupRolCop private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de Suppression d'un coproprietaire
             + ses roles associés Acheteur (00042) et Vendeur (00041)
             + ses titres de copropriété (vides)
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable viNumeroTiers  as integer  no-undo.
    define variable viNumeroMandat as integer  no-undo.

    define buffer vbRoles for roles.
    define buffer rlctt   for rlctt.
    define buffer tache   for tache.
    define buffer intnt   for intnt.
    define buffer ctrat   for ctrat.

    ghProc = lancementPgm ("role/roles_CRUD.p", goCollectionHandlePgm).
    run purgeRoles in ghProc(gcTypeRole, giNumeroRole). 
    if mError:erreur() then return.
    
    /* lien adresse + telephones */
    run supAdrTel(gcTypeRole, giNumeroRole).
    if mError:erreur() then return.
    
    /* lien RIB */
    if can-find(first rlctt no-lock
                where rlctt.tpidt = gcTypeRole
                  and rlctt.noidt = giNumeroRole)
    then do:    
        ghProc = lancementPgm("adblib/rlctt_CRUD.p", goCollectionHandlePgm).
        run deleteRlcttSurIdentifiant in ghProc(gcTypeRole, giNumeroRole).
        if mError:erreur() then return.
    end.
    
    empty temp-table ttTache.
    /* Diagnostic technique privatif (04201) */
    for each tache no-lock
        where tache.tpcon = {&TYPECONTRAT-construction}
          and tache.tptac = {&TYPETACHE-diagnosticTechnique}
          and tache.pdreg = "TRUE"
          and tache.tphon = gcTypeRole
          and tache.duree = giNumeroRole:
        create ttTache.
        assign
            ttTache.tpcon   = tache.tpcon
            ttTache.nocon   = tache.nocon
            ttTache.tptac   = tache.tptac
            ttTache.notac   = tache.notac
            ttTache.CRUD        = "D"
            ttTache.dtTimestamp = datetime(tache.dtmsy, tache.hemsy)
            ttTache.rRowid      = rowid(tache)
        .
    end.
    /* Etude technique privatif (04265) */
    for each tache no-lock
        where tache.tpcon = {&TYPECONTRAT-construction}
          and tache.tptac = {&TYPETACHE-04235}
          and tache.pdreg = "TRUE"
          and tache.tphon = gcTypeRole
          and tache.duree = giNumeroRole:
        create ttTache.
        assign
            ttTache.tpcon   = tache.tpcon
            ttTache.nocon   = tache.nocon
            ttTache.tptac   = tache.tptac
            ttTache.notac   = tache.notac
            ttTache.CRUD        = "D"
            ttTache.dtTimestamp = datetime(tache.dtmsy, tache.hemsy)
            ttTache.rRowid      = rowid(tache)
        .
    end.
    /* Immeuble/Domotique: BIP (04258) */
    for each tache no-lock
        where tache.tpcon = {&TYPECONTRAT-construction}
          and tache.tptac = {&TYPETACHE-cleMagnetiqueDetails}
          and integer(tache.pdges) = viNumeroTiers
          and tache.dcreg = gcTypeRole:
        create ttTache.
        assign
            ttTache.tpcon   = tache.tpcon
            ttTache.nocon   = tache.nocon
            ttTache.tptac   = tache.tptac
            ttTache.notac   = tache.notac
            ttTache.CRUD        = "D"
            ttTache.dtTimestamp = datetime(tache.dtmsy, tache.hemsy)
            ttTache.rRowid      = rowid(tache)
        .
    end.
    if can-find (first ttTache)
    then do:
        ghProc = lancementPgm("tache/tache.p", goCollectionHandlePgm).
        run setTache in ghProc(table ttTache by-reference).
        if mError:erreur() then return.
    end.
    /* liens intnt */
    empty temp-table ttIntnt.        
    for each intnt no-lock
        where intnt.tpidt = gcTypeRole
          and intnt.noidt = giNumeroRole:
        if intnt.tpcon = {&TYPECONTRAT-titre2copro} then do:
            viNumeroMandat = truncate(intnt.nocon / 100000, 0). //  integer(substring(string(NoTitCop, "9999999999"), 1 , 5, 'character')).
/*gga todo a faire mais pour le moment je ne sais pas tester 
            LbTmpPdt = "01003"
                + "|" + string(viNumeroMandat)
                + "|" + intnt.tpcon
                + "|" + string(intnt.nocon).
            {RunPgExp.i &Path       = RpRunLibADB
                        &Prog       = "'Deltitco.p'"
                        &Parameter  = "INPUT LbTmpPdt
                                        , OUTPUT CdRetUse
                                        , OUTPUT LbDivSor"}
gga*/
        end.
        create ttIntnt.
        assign
            ttIntnt.tpcon  = intnt.tpcon
            ttIntnt.nocon  = intnt.nocon
            ttIntnt.tpidt  = intnt.tpidt
            ttIntnt.noidt  = intnt.noidt
            ttIntnt.nbnum  = intnt.nbnum
            ttIntnt.idpre  = intnt.idpre
            ttIntnt.idsui  = intnt.idsui
            ttIntnt.CRUD   = "D"
            ttIntnt.dtTimestamp = datetime(intnt.dtmsy, intnt.hemsy)
            ttIntnt.rRowid = rowid(intnt)
        . 
    end.
    if can-find (first ttIntnt)
    then do:
        ghProc = lancementPgm("adblib/intnt_CRUD.p", goCollectionHandlePgm).
        run setIntnt in ghProc(table ttIntnt by-reference).
        if mError:erreur() then return.
    end.
    
    /* Contrat bloc-notes */
    run supBlocNote (gcTypeRole, giNumeroRole).
    if mError:erreur() then return.
    
    ghProc = lancementPgm ("role/roles_CRUD.p", goCollectionHandlePgm).
    run purgeRoles in ghProc(gcTypeRole, giNumeroRole). 
    if mError:erreur() then return.
    
    /* Evenementiel */
    run supEvenementiel(gcTypeRole, giNumeroRole).
    if mError:erreur() then return.
    
    /* Comptabilité. sauf si on vient de la compta */
    if gcTypeTrt <> "PURGE" then run supCptaRol.
    if mError:erreur() then return.
    
    /* Acheteur/Vendeur */
    /* lien adresse + telephones */
    run supAdrTel({&TYPEROLE-acheteur}, giNumeroRole).
    if mError:erreur() then return.
    
    /* Contrat bloc-notes */
    run supBlocNote ({&TYPEROLE-acheteur}, giNumeroRole).
    if mError:erreur() then return.
    
    /* roles  */
    ghProc = lancementPgm ("role/roles_CRUD.p", goCollectionHandlePgm).
    run purgeRoles in ghProc({&TYPEROLE-acheteur}, giNumeroRole). 
    if mError:erreur() then return.
    
    /* evenementiel */
    run supEvenementiel({&TYPEROLE-acheteur}, giNumeroRole).
    if mError:erreur() then return.
    
    /* lien adresse + telephones */
    run supAdrTel ({&TYPEROLE-vendeur}, giNumeroRole).
    if mError:erreur() then return.
    
    /* Contrat bloc-notes */
    run supBlocNote ({&TYPEROLE-vendeur}, giNumeroRole).
    if mError:erreur() then return.
    
    /* roles  */
    ghProc = lancementPgm ("role/roles_CRUD.p", goCollectionHandlePgm).
    run purgeRoles in ghProc({&TYPEROLE-vendeur}, giNumeroRole). 
    if mError:erreur() then return.
    
    /* evenementiel */
    run supEvenementiel({&TYPEROLE-vendeur}, giNumeroRole).

end procedure.

procedure SupRolInd private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de Suppression d'un Indivisaire de Gérance
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer intnt   for intnt.
    define buffer rlctt   for rlctt.
    define buffer ctrat   for ctrat.
    define buffer vbRoles for roles.
    define buffer ltdiv   for ltdiv.
    define buffer ltrol   for ltrol.

    /* lien adresse + telephones */
    run supAdrTel(gcTypeRole, giNumeroRole).
    if mError:erreur() then return.
    
    /* liens intnt */
    empty temp-table ttIntnt.    
    for each intnt no-lock
       where intnt.tpidt = gcTypeRole
         and intnt.noidt = giNumeroRole:
        create ttIntnt.
        assign
            ttIntnt.tpcon  = intnt.tpcon
            ttIntnt.nocon  = intnt.nocon
            ttIntnt.tpidt  = intnt.tpidt
            ttIntnt.noidt  = intnt.noidt
            ttIntnt.nbnum  = intnt.nbnum
            ttIntnt.idpre  = intnt.idpre
            ttIntnt.idsui  = intnt.idsui
            ttIntnt.CRUD   = "D"
            ttIntnt.dtTimestamp = datetime(intnt.dtmsy, intnt.hemsy)
            ttIntnt.rRowid = rowid(intnt)
        . 
    end.
    if can-find (first ttIntnt)
    then do:
        ghProc = lancementPgm("adblib/intnt_CRUD.p", goCollectionHandlePgm).
        run setIntnt in ghProc(table ttIntnt by-reference).
        if mError:erreur() then return.
    end.
    
    /* liens rlctt */
    if can-find(first rlctt no-lock
                where rlctt.tpidt = gcTypeRole
                  and rlctt.noidt = giNumeroRole)
    then do:
        ghProc = lancementPgm("adblib/rlctt_CRUD.p", goCollectionHandlePgm).
        run deleteRlcttSurIdentifiant in ghProc(gcTypeRole, giNumeroRole).
        if mError:erreur() then return.
    end.
        
    /* Contrat bloc-notes */
    run supBlocNote (gcTypeRole, giNumeroRole).
    if mError:erreur() then return.
    
    /* roles  */
    ghProc = lancementPgm ("role/roles_CRUD.p", goCollectionHandlePgm).
    run purgeRoles in ghProc(gcTypeRole, giNumeroRole). 
    if mError:erreur() then return.
        
    /* Evenementiel */
    run supEvenementiel(gcTypeRole, giNumeroRole).

end procedure.

procedure SupRolDiv private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de Suppression d'un role divers sans spécificité
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer intnt   for intnt.
    define buffer ctrat   for ctrat.
    define buffer vbRoles for roles.
    define buffer ltrol   for ltrol.
    define buffer ltdiv   for ltdiv.
    
    /* lien adresse + telephones */
    run supAdrTel(gcTypeRole, giNumeroRole).
    if mError:erreur() then return.
    
    /* Contrat bloc-notes */
    run supBlocNote (gcTypeRole, giNumeroRole).   
    if mError:erreur() then return. 
    
    /* roles  */
    ghProc = lancementPgm ("role/roles_CRUD.p", goCollectionHandlePgm).
    run purgeRoles in ghProc(gcTypeRole, giNumeroRole). 
    if mError:erreur() then return.
    
    empty temp-table ttIntnt.
    if gcTypeRole = {&TYPEROLE-directeurAgence}
    then do:
        for each intnt no-lock    /* lien avec le Contrat Gestionnaire restant éventuellement ???? d'où ??? */
           where intnt.tpidt = gcTypeRole
             and intnt.noidt = giNumeroRole
             and intnt.tpcon = {&TYPECONTRAT-serviceGestion}:
            create ttIntnt.
            assign
                ttIntnt.tpcon  = intnt.tpcon
                ttIntnt.nocon  = intnt.nocon
                ttIntnt.tpidt  = intnt.tpidt
                ttIntnt.noidt  = intnt.noidt
                ttIntnt.nbnum  = intnt.nbnum
                ttIntnt.idpre  = intnt.idpre
                ttIntnt.idsui  = intnt.idsui
                ttIntnt.CRUD   = "D"
                ttIntnt.dtTimestamp = datetime(intnt.dtmsy, intnt.hemsy)
                ttIntnt.rRowid = rowid(intnt)
            . 
        end.     
        if can-find (first ttIntnt)
        then do:
            ghProc = lancementPgm("adblib/intnt_CRUD.p", goCollectionHandlePgm).
            run setIntnt in ghProc(table ttIntnt by-reference).
            if mError:erreur() then return.
        end.
    end.
    /* Evenementiel */
    run supEvenementiel(gcTypeRole, giNumeroRole).
    
end procedure.

procedure supEvenementiel private:
    /*-------------------------------------------------------------------------
    Purpose:
    Notes  :
    --------------------------------------------------------------------------*/
    define input parameter pcTypeRole   as character no-undo.
    define input parameter piNumeroRole as int64     no-undo.

    define buffer vbEvent for event.
    define buffer evtev   for evtev.
    
    ghProc = lancementPgm ("evenementiel/supEvenementiel.p", goCollectionHandlePgm).
    run SupEvenementiel in ghProc(pcTypeRole, piNumeroRole, input-output goCollectionHandlePgm).
    if mError:erreur() then return.
  
    /* Ajout SY le 19/10/2012 : evenements */ 
    if can-find(first event no-lock 
                where event.tprol = pcTypeRole
                  and event.norol = piNumeroRole)
    then do:
        ghProc = lancementPgm ("evenementiel/Event_Crud.p", goCollectionHandlePgm).
        run deleteEventEtLienSurRole in ghProc(pcTypeRole, piNumeroRole).
    end.

end procedure.

procedure SupCptaRol private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de suppression de la comptabilite d'un role
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable viCodeRoleDPS  as integer   no-undo.
    define variable vcNumeroCompte as character no-undo.
    
    define buffer ccptcol for ccptcol.
    define buffer csscpt  for csscpt.

    case gcTypeRole:
        when {&TYPEROLE-mandant} or when {&TYPEROLE-coIndivisaire} then viCodeRoleDPS = 16.
        when {&TYPEROLE-coproprietaire}                            then viCodeRoleDPS = 8.
    end case.
    vcNumeroCompte = string(giNumeroRole, "99999").
    /*--> On suppprime le compte individuel en comptabilite */
    for first ccptcol no-lock
        where ccptcol.soc-cd = integer(mToken:cRefPrincipale)
          and ccptcol.tprole = viCodeRoleDPS:
        /*--> S'il existe deja le compte avec soc-cd negatif on supprime */
        for each csscpt exclusive-lock
           where csscpt.soc-cd   = - ccptcol.soc-cd
             and csscpt.coll-cle = ccptcol.coll-cle
             and csscpt.cpt-cd   = vcNumeroCompte:
            delete csscpt.
        end.
        /*--> Passage du compte en soc-cd negatif */
        for each csscpt exclusive-lock
           where csscpt.soc-cd   = ccptcol.soc-cd
             and csscpt.coll-cle = ccptcol.coll-cle
             and csscpt.cpt-cd   = vcNumeroCompte:
            csscpt.soc-cd = - csscpt.soc-cd.
        end.
    end.

end procedure.

procedure supAdrTel private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeRole   as character no-undo.
    define input parameter piNumeroRole as integer   no-undo.

    /* lien adresse */
    if can-find(first ladrs no-lock 
                where ladrs.tpidt = pcTypeRole
                  and ladrs.noidt = piNumeroRole)
    then do:                                   
        ghProc = lancementPgm("adresse/ladrs_CRUD.p", goCollectionHandlePgm).
        run deleteLadrsSurNoidt in ghProc(pcTypeRole, piNumeroRole).
        if mError:erreur() then return.
    end.
    
    /* telephones */
    if can-find(first telephones no-lock 
                where telephones.tpidt = pcTypeRole
                  and telephones.noidt = piNumeroRole)
    then do:                                       
        ghProc = lancementPgm("tiers/telephones_CRUD.p", goCollectionHandlePgm).
        run deleteTelephonesSurNoidt in ghProc(pcTypeRole, piNumeroRole).
    end.    
        
end procedure.

procedure supBlocNote private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeRole   as character no-undo.
    define input parameter piNumeroRole as integer   no-undo.

    define buffer intnt for intnt.
    define buffer ctrat for ctrat.

    empty temp-table ttIntnt.
    empty temp-table ttCtrat.

    /* Contrat bloc-notes */
    for each intnt no-lock
       where intnt.tpidt = gcTypeRole
         and intnt.noidt = giNumeroRole
         and intnt.tpcon = {&TYPECONTRAT-blocNote}:
        for each ctrat no-lock
           where ctrat.tpcon = intnt.tpcon
             and ctrat.nocon = intnt.nocon:
            create ttCtrat.
            assign
                ttCtrat.tpcon  = ctrat.tpcon
                ttCtrat.nocon  = ctrat.nocon
                ttCtrat.CRUD        = "D"
                ttCtrat.dtTimestamp = datetime(ctrat.dtmsy, ctrat.hemsy)
                ttCtrat.rRowid      = rowid(ctrat)
            .
        end.
        create ttIntnt.
        assign
            ttIntnt.tpcon  = intnt.tpcon
            ttIntnt.nocon  = intnt.nocon
            ttIntnt.tpidt  = intnt.tpidt
            ttIntnt.noidt  = intnt.noidt
            ttIntnt.nbnum  = intnt.nbnum
            ttIntnt.idpre  = intnt.idpre
            ttIntnt.idsui  = intnt.idsui
            ttIntnt.CRUD   = "D"
            ttIntnt.dtTimestamp = datetime(intnt.dtmsy, intnt.hemsy)
            ttIntnt.rRowid = rowid(intnt)
        .           
    end.
    if can-find (first ttIntnt)
    then do:
        ghProc = lancementPgm("adblib/intnt_CRUD.p", goCollectionHandlePgm).
        run setIntnt in ghProc(table ttIntnt by-reference).
        if mError:erreur() then return.
    end.
    if can-find (first ttCtrat)
    then do:
        ghProc = lancementPgm("adblib/ctrat_CRUD.p", goCollectionHandlePgm).
        run setCtrat in ghProc(table ttCtrat by-reference).
    end.
        
end procedure.
