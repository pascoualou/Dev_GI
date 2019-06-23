/*---------------------------------------------------------------------------
File        : delbai.p
Purpose     : Controle et Suppression d'un bail 
Author(s)   : AF 28/11/2002  -  GGA 2018/05/23
Notes       : reprise adb/cont/delbai.p

 0001 20/12/2002 AF Mise à jour sequence direct ds le prg de la   
                    table tache                                   
 0002 14/10/2003 SY Fiche 0503/0102- correction suppr ltctt       
 0003 29/12/2003 PL 1103/0031 Gestion trace de pec.               
                    Affichage du type et numero de mandat dans    
                    tous les messages.                            
                    Ajout d'un mode de travail "muet" pour lancer 
                    la purge des pec plantées en batch.           
 0004 12/01/2004 SY - Correction suppression "lides"              
                    - Correction suppression compte en compta     
 0005 14/01/2004 SY 0104/0140: ajout suppression RIB du Bail      
                    (table rlctt)                                 
 0006 29/03/2004 SY ajout suppression calendrier (calev) et       
                    echelle mobile (echlo) chiffre aff (chaff)    
 0007 16/08/2004 SY 0804/0111 : On ne peut pas supprimer un bail  
                    qui est dans un quitt en attente d'int‚gration
 0008 11/10/2004 SY 1004/0092: correction suppression RIB du Bail 
                    (table rlctt)                                 
 0009 03/01/2005 SY 0105/0007: Ajout controle pas de quittance    
                    historis‚e pour le locataire                  
 0010 22/03/2005 SY 0305/0319: CREDIT LYONNAIS                    
                    Ajout controle si Bailleur existe Si oui il   
                    doit être supprimé avant de supprimer le loc. 
 0011 01/07/2005 SY 0605/0394 : correction test sur ajquit        
                    (il manquait le critere mandat (etab-cd)      
 0012 09/12/2005 SY 0305/0491 :ajout suppr alertes (gadet)        
 0013 15/12/2005 PL ajout suppression des purges correspondantes  
 0014 12/04/2006 SY 0404/0305 adaptation pour les PURGES (compta) 
 0015 13/04/2006 SY 0404/0305 ajout tables Credit lyonnais        
 0016 28/04/2006 SY 0404/0305 ajout suppr tache cle magnétique/bip
 0017 09/05/2006 SY 0404/0305 ajout suppr bloc-notes              
 0018 05/09/2006 SY 0605/0248 ajout suppr détail charges locatives
 0019 26/10/2006 SY 1006/0283 : CREDIT LYONNAIS                   
                    suite fiche 0305/0319: le controle bailleur   
                    est bloquant si le rang du locataire est 01   
                    mais pas pour les rangs supérieurs            
 0020 10/07/2007 SY Ajout suppr matricule CAF (tbent)             
 0021 15/10/2007 NP 1007/0022 Remplacement NoRefUse par NoRefGer  
 0022 16/09/2008 SY 0608/0065 Gestion mandats 5 chiffres            
 0023 03/09/2009 SY 0809/0018 : création trace de suppression pour  
                    transfert GEQS au site central                  
 0024 01/12/2009 SY 1108/0397 Quittancement rubriques calculées     
 0025 10/03/2010 SY 0210/0196 Maj occupant des lots apres supp. Bail
 0026 01/04/2010 SY 0310/0271 Ajout suppression telephones          
                    + Contrat bloc-notes locataire                  
 0027 16/04/2010 PL INSITU : suppression des enregistrements de la  
                    table 'detail'                                  
 0028 21/07/2010 SY 0706/0018 Mutation gérance                      
                    ajout suppression tbent (correspondance bail)   
 0029 05/11/2010 SY 0908/0110 Ajout suppression revtrt, revhis      
 0030 25/11/2010 SY 1009/0101 Ajout suppression REFAC- (tbdet)        
 0031 28/02/2012 PL 0212/0184 Ajout messages log.                    
 0032 18/03/2013 SY 0313/0049 Adaptation pour GRL (table garlodt)     
 0033 24/04/2013 PL 1209/0039 Gestion colocation                    
 0034 26/07/2013 SY 0511/0023 prélèvement SEPA nouvelles tables     
                    mandatSEPA et suimandatSEPA                     
 0035 26/07/2013 SY 0511/0023 prélèvement SEPA nouvelles tables     
                    mandatSEPA et suimandatSEPA                      
 0036 29/01/2015 SY 0115/0228 Ajout suppression du role Bailleur (00059)   
                    associé (LCL)                                   
 0037 04/03/2015 NP 0414/0245 Ajout gestion mensualisation du quitt  
 0038 27/05/2016 NP 0116/0077 ADELE : suppr des enregistrmts DETAIL                  
---------------------------------------------------------------------------*/


{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2tache.i}

using parametre.pclie.parametrageFournisseurLoyer.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/error.i}
{outils/include/lancementProgramme.i}
{tache/include/tache.i}
{application/include/glbsepar.i}
{adblib/include/ctrat.i}
{adblib/include/detail.i}
{adblib/include/tbent.i}
{adblib/include/unite.i}
{adblib/include/local.i}
{adblib/include/eqprov.i}
{adblib/include/prrub.i}


define variable glMuet                 as logical   no-undo.
define variable gcTypeTrt              as character no-undo.
define variable giRefGerance           as integer   no-undo. 
define variable ghProc                 as handle    no-undo.
define variable gcTypeContrat          as character no-undo. 
define variable giNumeroContrat        as int64     no-undo.
define variable glGestFournisseurLoyer as logical   no-undo.
define variable gcCodeModele           as character no-undo.
define variable giNumeroMandat         as integer   no-undo.
define variable giNumeroUl             as integer   no-undo.
define variable giRanUse               as integer   no-undo.
define variable gcCptLoc               as character no-undo.

function affichageMessage return logical private (pcMessage as character):
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  : 
    ------------------------------------------------------------------------------*/    
    define variable vcInfoMandat as character no-undo. 

    if not glMuet and not gcTypeTrt begins "PURGE"
    then do:
        vcInfoMandat = outilFormatage:fSubst(outilTraduction:getLibelle(000265), string(giNumeroContrat)).
        mError:createError({&information}, substitute("&1&2", vcInfoMandat, pcMessage)).
    end.
    
end function.


procedure lanceDelBail:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  : service externe 
    ------------------------------------------------------------------------------*/    
    define input parameter table for ttError.    
    define input parameter pcTypeContrat   as character no-undo. 
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter plMuet          as logical   no-undo.
    define input parameter pcTypeTrt       as character no-undo.
    define input-output parameter poCollectionHandlePgm as class collection no-undo.
 
    define variable vlAnocontrole as logical no-undo. 

    define variable voFournisseurLoyer as class parametrageFournisseurLoyer no-undo.

mLogger:writeLog(0, substitute("delbail.p lanceDelBail type contrat : &1 numero contrat : &2 muet &3 type trt &4", pcTypeContrat, piNumeroContrat, plMuet, pcTypeTrt)).
    assign
        giNumeroMandat  = integer(substring(string(piNumeroContrat, "9999999999"), 1, 5, 'character'))
        giNumeroUl      = integer(substring(string(piNumeroContrat, "9999999999"), 6, 3, 'character'))
        giRanUse        = integer(substring(string(piNumeroContrat, "9999999999"), 9, 2, 'character'))
        gcCptLoc        = substring(string(piNumeroContrat, "9999999999"), 6, 5, 'character')   
        glMuet          = plMuet
        gcTypeTrt       = pcTypeTrt
        giRefGerance    = integer(mToken:cRefGerance)
        gcTypeContrat   = pcTypeContrat
        giNumeroContrat = piNumeroContrat
    .  
    voFournisseurLoyer = new parametrageFournisseurLoyer().
    assign
        glGestFournisseurLoyer = voFournisseurLoyer:isGesFournisseurLoyer()
        gcCodeModele = voFournisseurLoyer:getCodeModele()
    .
    delete object voFournisseurLoyer no-error.
    if gcTypeTrt <> "PURGE" and gcTypeTrt <> "PURGE-MANPOWER" 
    then run CtrlDel (output vlAnocontrole).    
    if vlAnocontrole then return.
    
    run DelBail (input-output poCollectionHandlePgm).
                    
end procedure.

procedure CtrlDel private:
    /*------------------------------------------------------------------------------
    Purpose: Controle de la suppression d'un Mandat 
    Notes  : 
    ------------------------------------------------------------------------------*/
    define output parameter plAnocontrole as logical no-undo init no. 

    define buffer ccptcol   for ccptcol.
    define buffer csscptcol for csscptcol. 
    define buffer intnt     for intnt.

    /*--> Recherche du Bail... */
    if not can-find(first ctrat no-lock
                    where ctrat.TpCon = gcTypeContrat
                      and ctrat.NoCon = giNumeroContrat)
    then do:
        affichageMessage (outilTraduction:getLibelle(105686)). //bail inexistant 
        plAnocontrole = yes.
        return.
    end.
    /*--> 16/08/2004 : Recherche si quittance en attente d'integration  */
    if can-find(first ajquit no-lock
                where Ajquit.soc-cd  = giRefGerance
                  and ajquit.etab-cd = giNumeroMandat
                  and Ajquit.cptg-cd = "4112" 
                  and Ajquit.sscpt-cd = substring( string(giNumeroContrat, "9999999999"), 6, 5, 'character'))
    then do:
        affichageMessage (outilTraduction:getLibelle(109006)). //Ce locataire a ete traite dans le dernier transfert de quittancement qui est en attente d'integration
        plAnocontrole = yes.
        return.
    end.
    /*--> Recherche d'elements comptabilisés sur le locataire */
    find first ccptcol no-lock
         where ccptcol.soc-cd = giRefGerance
           and ccptcol.tprole = 19 no-error.
    if not available ccptcol 
    then do:
        affichageMessage (outilTraduction:getLibelle(107474)). //Manque role comptable locataire
        plAnocontrole = yes.
        return.
    end.
    for each csscptcol no-lock
       where csscptcol.soc-cd   = ccptcol.soc-cd
         and csscptcol.etab-cd  = giNumeroMandat
         and csscptcol.coll-cle = ccptcol.coll-cle
    use-index sscptcol-i:
        if can-find(first cecrln no-lock
                    where cecrln.soc-cd     = csscptcol.soc-cd
                      and cecrln.etab-cd    = csscptcol.etab-cd
                      and cecrln.sscoll-cle = csscptcol.sscoll-cle
                      and cecrln.cpt-cd     = gcCptLoc)
        then do:
            affichageMessage (outilTraduction:getLibelle(107475)). //Il existe des écriture en comptabilité (cecrln) 
            plAnocontrole = yes.
            return.
        end.
        if can-find(first cextln no-lock
                    where cextln.soc-cd     = csscptcol.soc-cd
                      and cextln.etab-cd    = csscptcol.etab-cd
                      and cextln.sscoll-cle = csscptcol.sscoll-cle
                      and cextln.cpt-cd     = gcCptLoc)
        then do:
            affichageMessage (outilTraduction:getLibelle(107476)). //Il existe des écriture en comptabilité (cextln)
            plAnocontrole = yes.
            return.
        end.
        if can-find(first cexmln no-lock
                    where cexmln.soc-cd     = csscptcol.soc-cd
                      and cexmln.etab-cd    = giNumeroMandat
                      and cexmln.sscoll-cle = csscptcol.sscoll-cle
                      and cexmln.cpt-cd     = gcCptLoc)
        then do:
            affichageMessage (outilTraduction:getLibelle(107477)). //Il existe des écritures en comptabilité (cexmln)
            plAnocontrole = yes.
            return.
        end.    
    end.
    /*--> Recherche si facture d'entree locataire deja transferee. */
    if can-find(first Aquit no-lock
                where Aquit.noloc = giNumeroContrat
                  and Aquit.fgfac 
                  and Aquit.fgtrf) 
    then do:
        affichageMessage (outilTraduction:getLibelle(107478)). //Une facture d'entrée a déjà été transférée pour ce locataire
        plAnocontrole = yes.
        return.
    end.
    /*--> Recherche si facture d'entree locataire deja comptabilisee. */    
    if can-find(first isoc no-lock
                where isoc.soc-cd = giRefGerance)
    then do:
        affichageMessage (outilTraduction:getLibelle(107479)). //Isoc non disponible
        plAnocontrole = yes.
        return.
    end.
    if can-find(first iftsai no-lock
                where iftsai.soc-cd      = giRefGerance
                  and iftsai.etab-cd     = giNumeroMandat
                  and iftsai.sscptg-cd   = gcCptLoc
                  and iftsai.typefac-cle = "Entrée"
                  and iftsai.fg-edifac)
    then do:
        affichageMessage (outilTraduction:getLibelle(107480)). //Une facture d'entrée a déjà été comptabilisée pour ce locataire
        plAnocontrole = yes.
        return.
    end.
    /*--> Recherche si Historique de quitt GI  */
    if can-find(first Aquit no-lock
                where Aquit.noloc = giNumeroContrat
                  and Aquit.noqtt > 0
                  and Aquit.fgfac = no)
    then do:
        affichageMessage (outilTraduction:getLibelle(109425)).
        plAnocontrole = yes.
        return.
    end.
    /*--> Si Gestion des fournisseurs de loyer Crédit lyonnais : controler si bailleur rattaché */
    if glGestFournisseurLoyer and gcCodeModele = "00002" and giRanUse = 01 
    then do:
        for first intnt no-lock 
            where intnt.tpcon = gcTypeContrat 
              and intnt.nocon = giNumeroContrat
              and intnt.tpidt = {&TYPEROLE-bailleur}:
            if can-find(first ctrat no-lock
                        where ctrat.tpcon = gcTypeContrat 
                          and ctrat.nocon = intnt.noidt)
            then do:
                affichageMessage (outilFormatage:fSubstGestion(outilTraduction:getLibelle(109535), substitute('&1 - &2', ctrat.nocon, ctrat.lbnom))). //Vous ne pouvez pas supprimer le Bail avant d'avoir supprimé le Bailleur %1 associé.
                plAnocontrole = yes.
                return.
            end.    
        end.
    end.
    
end procedure.

procedure DelBail private:
    /*------------------------------------------------------------------------------
    Purpose: Suppression du Mandat 
    Notes  : 
    ------------------------------------------------------------------------------*/    
    define input-output parameter poCollectionHandlePgm as class collection no-undo.
 
    define variable vdaEntreeOccupant        as date      no-undo.
    define variable vcNomOccupant            as character no-undo.
    define variable viNumeroTiers            as integer   no-undo.
    define variable viNumeroDernierLocataire as integer   no-undo.

    define buffer ctrat   for ctrat.
    define buffer tache   for tache.
    define buffer vbroles for roles.
    define buffer detail  for detail.
    define buffer unite   for unite.
    define buffer cpuni   for cpuni.
    define buffer local   for local.

    if glMuet = no and not gcTypeTrt begins "PURGE"
    and outils:questionnaire(107481, table ttError by-reference) <= 2 
    then return.

    /*--> Suppression de tous les liens avec ce Bail. */
    if can-find(first intnt no-lock
                where intnt.tpcon = gcTypeContrat
                  and intnt.nocon = giNumeroContrat)
    then do:    
        ghProc = lancementPgm ("adblib/intnt_CRUD.p", poCollectionHandlePgm).
        run deleteIntntSurContrat in ghProc(gcTypeContrat, giNumeroContrat).
        if mError:erreur() then return.
    end.
        
    /*--> Suppression du role Locataire. */
    for each vbroles no-lock
       where vbroles.TpRol = {&TYPEROLE-locataire} 
         and vbroles.NoRol = giNumeroContrat:
             
        viNumeroTiers = vbroles.notie.
        
        if can-find(first intnt no-lock
                    where intnt.tpidt = vbroles.tprol
                      and intnt.noidt = vbroles.norol
                      and intnt.tpcon = {&TYPECONTRAT-blocNote})
        then do:        
            ghProc = lancementPgm ("adblib/intnt_CRUD.p", poCollectionHandlePgm).
            run deleteContratBlocNote in ghProc(vbroles.tprol, vbroles.norol).
            if mError:erreur() then return.
        end.        
                
        /* Ajout Sy le 18/03/2013 */
        if can-find(first garlodt no-lock   
                    where garlodt.tprol = vbroles.TpRol
                      and garlodt.norol = decimal(vbroles.norol))
        then do:    
            ghProc = lancementPgm ("adblib/garlodt_CRUD.p", poCollectionHandlePgm).
            run deleteGarlodtSurLocataire in ghProc(vbroles.TpRol, decimal(vbroles.norol)).
            if mError:erreur() then return.
        end.  
     
    end.

    /*--> Suppression du role Locataire. */
    ghProc = lancementPgm ("role/roles_CRUD.p", poCollectionHandlePgm).
    run purgeRoles in ghProc({&TYPEROLE-locataire}, giNumeroContrat). 
    if mError:erreur() then return.

    /*--> Suppression de toutes les Adresses du Locataire. */
    if can-find(first ladrs no-lock 
                where ladrs.tpidt = {&TYPEROLE-locataire}
                  and ladrs.noidt = giNumeroContrat)
    then do:                                
        ghProc = lancementPgm ("adresse/ladrs_CRUD.p", poCollectionHandlePgm).
        run deleteLadrsSurNoidt in ghProc({&TYPEROLE-locataire}, giNumeroContrat).
        if mError:erreur() then return.
    end.

    /* Ajout SY le 01/04/2010 */
    if can-find(first telephones no-lock 
                where telephones.tpidt = {&TYPEROLE-locataire}
                  and telephones.noidt = giNumeroContrat)
    then do:                                    
        ghProc = lancementPgm ("tiers/telephones_CRUD.p", poCollectionHandlePgm).
        run deleteTelephonesSurNoidt in ghProc({&TYPEROLE-locataire}, giNumeroContrat).
        if mError:erreur() then return.
    end.
    
    /*--> Suppression de tous les liens tache du bail */
    if can-find(first cttac no-lock 
                where cttac.tpcon = gcTypeContrat 
                  and cttac.nocon = giNumeroContrat)
    then do:    
        ghProc = lancementPgm("adblib/cttac_CRUD.p", poCollectionHandlePgm).
        run deleteCttacSurContrat in ghProc(gcTypeContrat, giNumeroContrat).
        if mError:erreur() then return.
    end.
    
    /*--> Suppression de toutes les Taches du Bail. */
    if can-find(first tache no-lock 
                where tache.tpcon = gcTypeContrat 
                  and tache.nocon = giNumeroContrat)
    then do:
        ghProc = lancementPgm ("tache/tache.p", poCollectionHandlePgm).
        run deleteTacheSurContrat in ghProc(gcTypeContrat, giNumeroContrat).
        if mError:erreur() then return.
    end.

    /* Ajout SY le 01/12/2009 : Tache quittancement rubriques calculées */
    if can-find(first detail no-lock 
                where detail.cddet = gcTypeContrat
                  and detail.nodet = giNumeroContrat
                  and detail.iddet = integer("04360"))
    then do:               
        ghProc = lancementPgm ("adblib/detail_CRUD.p", poCollectionHandlePgm).
        run deleteDetailSurCodeNumeroIndicateur in ghProc(gcTypeContrat, giNumeroContrat, integer("04360")).
        if mError:erreur() then return.
    end.
 
    empty temp-table ttdetail.    
    /* Ajout PL le 16/04/2010 : ID INSITU */
    run prepaDelDetail ("IS_00019|", "IS_TRT_00069|").
    run prepaDelDetail ("IS_01033|", "IS_TRT_01032|").    
    for each detail no-lock
        where detail.cddet = "IS_00013"
          and detail.tbchr[2] = string(giNumeroContrat,"9999999999"):
        create ttDetail.
        assign
            ttDetail.cddet       = detail.cddet
            ttDetail.nodet       = detail.nodet
            ttDetail.iddet       = detail.iddet
            ttDetail.ixd01       = detail.ixd01
            ttDetail.CRUD        = "D"
            ttDetail.dtTimestamp = datetime(detail.dtmsy, detail.hemsy) 
            ttDetail.rRowid      = rowid(detail) 
        .      
    end.
    /* NP 0116/0077 : ADELE */
    run prepaDelDetail ("AD_00019|", "IS_TRT_00069|").    
    run prepaDelDetail ("AD_01033|", "IS_TRT_01032|").    
    for each detail no-lock
        where detail.cddet = "AD_00013"
          and detail.tbchr[2] = string(giNumeroContrat,"9999999999"):
        create ttDetail.
        assign
            ttDetail.cddet       = detail.cddet
            ttDetail.nodet       = detail.nodet
            ttDetail.iddet       = detail.iddet
            ttDetail.ixd01       = detail.ixd01
            ttDetail.CRUD        = "D"
            ttDetail.dtTimestamp = datetime(detail.dtmsy, detail.hemsy) 
            ttDetail.rRowid      = rowid(detail) 
        .      
    end.
    ghProc = lancementPgm ("adblib/detail_CRUD.p", poCollectionHandlePgm).
    run setDetail in ghProc(table ttDetail by-reference).
    if mError:erreur() then return.
        
    /* Immeuble/Domotique : BIP (04258) */
    empty temp-table ttTache.
    for each tache no-lock
       where tache.tpcon = {&TYPECONTRAT-construction}
         and tache.tptac = {&TYPETACHE-cleMagnetiqueDetails}
         and integer(tache.pdges) = viNumeroTiers
         and tache.dcreg = {&TYPEROLE-locataire}:
        create ttTache.
        assign
            ttTache.tpcon       = tache.tpcon
            ttTache.nocon       = tache.nocon
            ttTache.tptac       = tache.tptac
            ttTache.notac       = tache.notac
            ttTache.CRUD        = "D"
            ttTache.dtTimestamp = datetime(tache.dtmsy, tache.hemsy) 
            ttTache.rRowid      = rowid(tache) 
        .
    end.
    if can-find(first ttTache) then do:
        ghProc = lancementPgm("tache/tache.p", poCollectionHandlePgm).
        run setTache in ghProc(table ttTache by-reference).
        if mError:erreur() then return.
    end.
     
    /*--> Suppression du Lien Contrat/Contrat */
    if can-find(first ctctt no-lock
                where ctctt.tpct1 = gcTypeContrat
                  and ctctt.noct1 = giNumeroContrat)
    then do:    
        ghProc = lancementPgm ("adblib/ctctt_CRUD.p", poCollectionHandlePgm).
        run deleteCtcttSurContratPrincipal in ghProc(gcTypeContrat, giNumeroContrat).
        if mError:erreur() then return.
    end.

    if can-find(first ctctt no-lock
                where ctctt.tpct2 = gcTypeContrat
                  and ctctt.noct2 = giNumeroContrat)
    then do:        
        ghProc = lancementPgm ("adblib/ctctt_CRUD.p", poCollectionHandlePgm).
        run deleteCtcttSurContratSecondaire in ghProc(gcTypeContrat, giNumeroContrat).
        if mError:erreur() then return.
    end.

    /* 14/01/04 : suppression banque du contrat */
    if can-find(first rlctt no-lock
                where rlctt.tpct1 = gcTypeContrat
                  and rlctt.noct1 = giNumeroContrat)
    then do:                     
        ghProc = lancementPgm ("adblib/rlctt_CRUD.p", poCollectionHandlePgm).
        run deleteRlcttSurContratMaitre in ghProc(gcTypeContrat, giNumeroContrat).
        if mError:erreur() then return.
    end.

    /* 24/04/2013 : suppression des historiques de répartition de la colocation */
    if can-find(first coloc no-lock   
                where coloc.tpcon = gcTypeContrat
                  and coloc.nocon = giNumeroContrat)
    then do:    
        ghProc = lancementPgm ("adblib/coloc_CRUD.p", poCollectionHandlePgm).
        run deleteColocSurContrat in ghProc(gcTypeContrat, giNumeroContrat).
        if mError:erreur() then return.
    end.

    /* Ajout SY le 26/07/2013 : SEPA */
    if can-find(first mandatSepa no-lock
                where mandatSepa.tpmandat = {&TYPECONTRAT-sepa}
                  and mandatSepa.tpcon    = gcTypeContrat 
                  and mandatSepa.nocon    = giNumeroContrat)
    then do:    
        ghProc = lancementPgm ("adblib/mandatSEPA_CRUD.p", poCollectionHandlePgm).
        run deleteMandatSepaSurContrat in ghProc({&TYPECONTRAT-sepa}, gcTypeContrat, giNumeroContrat).
        if mError:erreur() then return.
    end.
    
    if gcTypeContrat = {&TYPECONTRAT-bail} 
    then do:
        /*--> Mettre l'unite vacante que si nous sommes sur le dernier bail */
        find last ctrat no-lock 
            where ctrat.tpcon = gcTypeContrat
              and ctrat.nocon >= giNumeroContrat
              and ctrat.nocon <= integer(string(giNumeroMandat,"99999") + string(giNumeroUl,"999") + "99") no-error.
        if available ctrat and ctrat.nocon = giNumeroContrat 
        then do:
            viNumeroDernierLocataire = 0.
            /* Recherche de l'existence du locataire precedent. */
            for last ctrat no-lock
               where ctrat.tpcon = gcTypeContrat
                 and ctrat.nocon > integer(string(giNumeroMandat,"99999") + string(giNumeroUl,"999") + "00")
                 and ctrat.nocon < giNumeroContrat:
                assign viNumeroDernierLocataire = ctrat.nocon
                       vcNomOccupant            = ctrat.lbnom
                . 
                for last tache no-lock
                   where tache.tpcon = gcTypeContrat
                     and tache.nocon = ctrat.nocon
                     and tache.tptac = "04029":
                    vdaEntreeOccupant = tache.dtdeb.    
                end.
            end.
            /*--> Recherche de l'Unite de Location active pour ce mandat. */
            for first unite no-lock  
                where unite.NoMdt = giNumeroMandat
                  and unite.NoAct = 0
                  and unite.NoApp = giNumeroUl:
                create ttUnite.
                assign
                    ttUnite.nomdt       = unite.nomdt
                    ttUnite.noapp       = unite.noapp
                    ttUnite.noact       = unite.noact
                    ttUnite.CRUD        = "U"
                    ttUnite.rRowid      = rowid(unite)
                    ttUnite.dtTimestamp = datetime(unite.dtmsy, unite.hemsy)
                    ttUnite.cdocc       = "00002"   /* Vacant. */
                    ttUnite.tprol       = (if viNumeroDernierLocataire <> 0 then {&TYPEROLE-locataire} else "")
                    ttUnite.norol       = viNumeroDernierLocataire
                .
                ghProc = lancementPgm ("adblib/unite_CRUD.p", poCollectionHandlePgm).
                run setUnite in ghProc(table ttUnite by-reference).
                if mError:erreur() then return.
            end.
        end.
        /* Ajout SY le 10/03/2010 : Mise à jour de l'occupant des lots de l'UL */
        empty temp-table ttLocal. 
        for each unite no-lock
           where unite.NoMdt = giNumeroMandat
             and unite.NoAct = 0
             and unite.NoApp = giNumeroUl
        , each cpuni no-lock
         where cpuni.nomdt = unite.nomdt
           and cpuni.noapp = unite.noapp
           and cpuni.nocmp = unite.nocmp
        , first local no-lock
          where local.noimm = cpuni.noimm
            and local.nolot = cpuni.nolot:
            if local.nmocc <> vcNomOccupant 
            then do:
                create ttLocal.
                assign
                    ttLocal.noloc       = local.noloc
                    ttLocal.CRUD        = "U"
                    ttLocal.dtTimestamp = datetime(local.dtmsy, local.hemsy)
                    ttLocal.rRowid      = rowid(local)
                    ttLocal.NmOcc       = vcNomOccupant
                    ttLocal.DtEnt       = vdaEntreeOccupant
                    ttLocal.lbdiv3      = "00000"
                    ttLocal.cdmsy       = mtoken:cUser + "@" + "delbail.p"
                .
            end.                
        end.                
        if can-find(first ttLocal)
        then do:
            ghProc = lancementPgm ("adblib/local_CRUD.p", poCollectionHandlePgm).
            run setLocal in ghProc(table ttLocal by-reference).
            if mError:erreur() then return.
        end.
         
        /*--> Delete des quittances */  
        if can-find(first equit no-lock
                    where equit.noloc = giNumeroContrat)
        then do:
            ghProc = lancementPgm("bail/quittancement/equit_CRUD.p", poCollectionHandlePgm).
            run deleteEquitSurLocataire in ghProc(giNumeroContrat).
            if mError:erreur() then return.
        end.
    
        /*--> Delete des factures d'entree locataire : GESTION */
        if can-find(first aquit no-lock
                    where aquit.noloc = giNumeroContrat)
        then do:        
            ghProc = lancementPgm ("adblib/aquit_CRUD.p", poCollectionHandlePgm).
            run deleteAquitSurLocataire in ghProc(giNumeroContrat).
            if mError:erreur() then return.
        end.
        
        /*--> Delete des quittances de provision : mensualisation du quitt : GESTION */
        empty temp-table ttEqprov.
        for each eqprov no-lock
           where eqprov.noloc = giNumeroContrat:
            create ttEqprov.
            assign
                ttEqprov.noint       = eqprov.noint
                ttEqprov.CRUD        = "D"
                ttEqprov.dtTimestamp = datetime(eqprov.dtmsy, eqprov.hemsy) 
                ttEqprov.rRowid      = rowid(eqprov) 
            .                  
        end.
        if can-find(first ttEqprov)
        then do:
            ghProc = lancementPgm ("adblib/eqprov_CRUD.p", poCollectionHandlePgm).
            run setEqprov in ghProc(table ttEqprov by-reference).
            if mError:erreur() then return.
        end.
            
        /*--> Suppression des rubriques spécifique locataire */
        empty temp-table ttPrrub.
        for each prrub no-lock
           where prrub.noloc = giNumeroContrat:
            create ttEqprov.
            assign
                ttPrrub.cdrub       = prrub.cdrub
                ttPrrub.cdlib       = prrub.cdlib
                ttPrrub.noloc       = prrub.noloc
                ttPrrub.msqtt       = prrub.msqtt
                ttPrrub.noqtt       = prrub.noqtt
                ttPrrub.CRUD        = "D"
                ttPrrub.dtTimestamp = datetime(prrub.dtmsy, prrub.hemsy) 
                ttPrrub.rRowid      = rowid(prrub) 
            .                  
        end.
        if can-find(first ttPrrub)
        then do:
            ghProc = lancementPgm("adblib/prrub_CRUD.p", poCollectionHandlePgm).
            run setPrrub in ghProc (table ttPrrub by-reference).
            if mError:erreur() then return.
        end.
        
        empty temp-table ttTbent.
        /* matricule CAF */
        for each tbent no-lock
           where tbent.cdent = "00001":
            if integer(entry(1, tbent.iden2, separ[1])) = giNumeroContrat 
            then do:
                create ttTbent.
                assign
                    ttTbent.cdent       = tbent.cdent
                    ttTbent.iden1       = tbent.iden1
                    ttTbent.iden2       = tbent.iden2
                    ttTbent.CRUD        = "D"
                    ttTbent.dtTimestamp = datetime(tbent.dtmsy, tbent.hemsy) 
                    ttTbent.rRowid      = rowid(tbent) 
                .                  
            end.
        end.
        /* mutations de gérance : correspondance ancien bail / nouveau bail (tbent) */
        for each tbent no-lock
           where tbent.cdent >= "MUTAG" + string(giNumeroMandat, "99999") + "0000" 
             and tbent.cdent <= "MUTAG" + string(giNumeroMandat, "99999") + "9999" 
             and integer(tbent.iden1) = giNumeroContrat:
            create ttTbent.
            assign
                ttTbent.cdent       = tbent.cdent
                ttTbent.iden1       = tbent.iden1
                ttTbent.iden2       = tbent.iden2
                ttTbent.CRUD        = "D"
                ttTbent.dtTimestamp = datetime(tbent.dtmsy, tbent.hemsy) 
                ttTbent.rRowid      = rowid(tbent) 
            .                  
        end.
        for each tbent no-lock
           where tbent.cdent begins "MUTAG"
             and tbent.mten1 = giNumeroContrat:
            create ttTbent.
            assign
                ttTbent.cdent       = tbent.cdent
                ttTbent.iden1       = tbent.iden1
                ttTbent.iden2       = tbent.iden2
                ttTbent.CRUD        = "D"
                ttTbent.dtTimestamp = datetime(tbent.dtmsy, tbent.hemsy) 
                ttTbent.rRowid      = rowid(tbent) 
            .                  
        end.  
        if can-find(first ttTbent)
        then do:
            ghProc = lancementPgm ("adblib/tbent_CRUD.p", poCollectionHandlePgm).
            run setTbent in ghProc(table ttTbent by-reference).
            if mError:erreur() then return.
        end.

        /*--> Si Gestion des fournisseurs de loyer Crédit lyonnais et si bail FL , supprimer role bailleur et lien avec locataire mobile  */
        if glGestFournisseurLoyer and gcCodeModele = "00002"
        then do:
            /*--> Rechercher type du mandat maitre */
            for first ctrat no-lock
                where ctrat.tpcon = "01030"
                  and ctrat.nocon = giNumeroMandat
                  and lookup(ctrat.ntcon , "03075,03093,03085" ) > 0:
 
                if can-find(first intnt no-lock
                            where intnt.tpidt = {&TYPEROLE-bailleur}
                              and intnt.noidt = giNumeroContrat)
                then do:               
                    ghProc = lancementPgm ("adblib/intnt_CRUD.p", poCollectionHandlePgm).
                    run deleteIntntSurIdentifiant in ghProc({&TYPEROLE-bailleur}, giNumeroContrat).
                    if mError:erreur() then return.
                end.
                
                /*--> Suppression de toutes les Adresses du bailleur. */  
                if can-find(first ladrs no-lock 
                            where ladrs.tpidt = {&TYPEROLE-bailleur}
                              and ladrs.noidt = giNumeroContrat)
                then do:                            
                    ghProc = lancementPgm ("adresse/ladrs_CRUD.p", poCollectionHandlePgm).
                    run deleteLadrsSurNoidt in ghProc({&TYPEROLE-bailleur}, giNumeroContrat).
                    if mError:erreur() then return.
                end.

                if can-find(first telephones no-lock 
                            where telephones.tpidt = {&TYPEROLE-bailleur}
                              and telephones.noidt = giNumeroContrat)
                then do:                                            
                    ghProc = lancementPgm ("tiers/telephones_CRUD.p", poCollectionHandlePgm).
                    run deleteTelephonesSurNoidt in ghProc({&TYPEROLE-bailleur}, giNumeroContrat).
                    if mError:erreur() then return.                
                end.
                
                ghProc = lancementPgm ("role/roles_CRUD.p", poCollectionHandlePgm).
                run purgeRoles in ghProc({&TYPEROLE-bailleur}, giNumeroContrat). 
                if mError:erreur() then return.

            end.
        end.
    end.

    /* echelle mobile */
    if can-find(first echlo no-lock   
                where echlo.tpcon = gcTypeContrat
                  and echlo.nocon = giNumeroContrat)
    then do:
        ghProc = lancementPgm ("adblib/echlo_CRUD.p", poCollectionHandlePgm).
        run deleteEchloSurContrat in ghProc(gcTypeContrat, giNumeroContrat).
        if mError:erreur() then return.
    end.

    /* calendrier */
    if can-find(first calev no-lock   
                where calev.tpcon = gcTypeContrat
                  and calev.nocon = giNumeroContrat)
    then do:
        ghProc = lancementPgm ("adblib/calev_CRUD.p", poCollectionHandlePgm).
        run deleteCalevSurContrat in ghProc(gcTypeContrat, giNumeroContrat).
        if mError:erreur() then return.
    end.
    
    /* chiffre d'affaire */
    if can-find(first chaff no-lock   
                where chaff.tpcon = gcTypeContrat
                  and chaff.nocon = giNumeroContrat)
    then do:
        ghProc = lancementPgm ("adblib/chaff_CRUD.p", poCollectionHandlePgm).
        run deleteChaffSurContrat in ghProc(gcTypeContrat, giNumeroContrat).
        if mError:erreur() then return.
    end.
        
    /* Ajout SY le 05/11/2010 : Traitement des révisions */
    if can-find(first revtrt no-lock   
                where revtrt.tpcon = gcTypeContrat
                  and revtrt.nocon = giNumeroContrat)
    then do:
        ghProc = lancementPgm ("adblib/revtrt_CRUD.p", poCollectionHandlePgm).
        run deleteRevtrtSurContrat in ghProc(gcTypeContrat, giNumeroContrat).
        if mError:erreur() then return.
    end.
    if can-find(first revhis no-lock   
                where revhis.tpcon = gcTypeContrat
                  and revhis.nocon = giNumeroContrat)
    then do:
        ghProc = lancementPgm ("adblib/revhis_CRUD.p", poCollectionHandlePgm).
        run deleteRevhisSurContrat in ghProc(gcTypeContrat, giNumeroContrat).
        if mError:erreur() then return.
    end.
   
    /* Ajout SY le 25/11/2010 - suppression % refacturation dépenses mandat */
    if can-find(first tbdet no-lock
                where tbdet.cdent          = "REFAC-" + gcTypeContrat
                  and integer(tbdet.iden1) = giNumeroContrat)
    then do:
        ghProc = lancementPgm ("adblib/tbdet_CRUD.p", poCollectionHandlePgm).
        run deleteTbdetSurIdentifiant1 in ghProc("REFAC-" + gcTypeContrat, giNumeroContrat).
        if mError:erreur() then return.
    end.   
   
    /* Ajout sy le 09/12/2005 : alertes */
    if can-find(first gadet no-lock
                where gadet.tpctt = gcTypeContrat
                  and gadet.noctt = decimal(giNumeroContrat))
    then do:
        ghProc = lancementPgm ("adblib/gadet_CRUD.p", poCollectionHandlePgm).
        run deleteGadetSurContrat in ghProc(gcTypeContrat, decimal(giNumeroContrat)).
        if mError:erreur() then return.
    end.
    
    /* Ajout SY le 13/04/2006 : provisions quittancées */
    if can-find(first eprov no-lock
                where eprov.noloc = giNumeroContrat)
    then do:
        ghProc = lancementPgm ("adblib/eprov_CRUD.p", poCollectionHandlePgm).
        run deleteEprovSurLocataire in ghProc(giNumeroContrat).
        if mError:erreur() then return.
    end.

    if can-find(first rprub no-lock   
                where rprub.tpcon = gcTypeContrat
                  and rprub.nocon = giNumeroContrat)
    then do:
        ghProc = lancementPgm ("adblib/rprub_CRUD.p", poCollectionHandlePgm).
        run deleteRprubSurContrat in ghProc(gcTypeContrat, giNumeroContrat).
        if mError:erreur() then return.
    end.
         
    /* regularisation des provisions */
    if can-find(first regul no-lock
                where regul.noloc = giNumeroContrat)
    then do:
        ghProc = lancementPgm ("adblib/regul_CRUD.p", poCollectionHandlePgm).
        run deleteRegulSurLocataire in ghProc(giNumeroContrat).
        if mError:erreur() then return.
    end.
    
    /* Ajout sy le 05/09/2006 : détail charges locatives */
    if can-find(first chglo no-lock
                where chglo.tpctt = gcTypeContrat
                  and chglo.noctt = decimal(giNumeroContrat))
    then do:
        ghProc = lancementPgm ("adblib/chglo_CRUD.p", poCollectionHandlePgm).
        run deleteChgloSurBail in ghProc(gcTypeContrat, decimal(giNumeroContrat)).
        if mError:erreur() then return.
    end.
    
    /* Ajout SY le 13/04/2006 : accords de reglement  */
    if can-find(first acreg no-lock   
                where acreg.tpcon = gcTypeContrat
                  and acreg.nocon = giNumeroContrat)
    then do:
        ghProc = lancementPgm ("adblib/acreg_CRUD.p", poCollectionHandlePgm).
        run deleteAcregSurContrat in ghProc(gcTypeContrat, giNumeroContrat).
        if mError:erreur() then return.
    end.
    
    /* Ajout SY le 13/04/2006 : attestations d'assurances  */
    if can-find(first assat no-lock   
                where assat.tpcon = gcTypeContrat
                  and assat.nocon = giNumeroContrat)
    then do:
        ghProc = lancementPgm ("adblib/assat_CRUD.p", poCollectionHandlePgm).
        run deleteAssatSurContrat in ghProc(gcTypeContrat, giNumeroContrat).
        if mError:erreur() then return.
    end.    
    
    /* Ajout SY le 13/04/2006 : tables Credit lyonnais  */  
    if can-find(first aloyd no-lock
                where aloyd.tpcon = gcTypeContrat
                  and aloyd.nocon = decimal(giNumeroContrat))
    then do:
        ghProc = lancementPgm ("adblib/aloyd_CRUD.p", poCollectionHandlePgm).
        run deleteAloydSurBail in ghProc(gcTypeContrat, decimal(giNumeroContrat)).
        if mError:erreur() then return.
    end.
 
    if can-find(first amor1 no-lock
                where amor1.tpcon = gcTypeContrat
                  and amor1.nocon = giNumeroContrat)
    then do:
        ghProc = lancementPgm ("adblib/amor1_CRUD.p", poCollectionHandlePgm).
        run deleteAmor1SurContrat in ghProc(gcTypeContrat, giNumeroContrat).
        if mError:erreur() then return.
    end.
    if can-find(first amor2 no-lock
                where amor2.tpcon = gcTypeContrat
                  and amor2.nocon = giNumeroContrat)
    then do:
        ghProc = lancementPgm ("adblib/amor2_CRUD.p", poCollectionHandlePgm).
        run deleteAmor2SurContrat in ghProc(gcTypeContrat, giNumeroContrat).
        if mError:erreur() then return.
    end.
    
    if can-find(first amorh no-lock
                where amorh.tpcon = gcTypeContrat
                  and amorh.nocon = giNumeroContrat)
    then do:
        ghProc = lancementPgm ("adblib/amorh_CRUD.p", poCollectionHandlePgm).
        run deleteAmorhSurContrat in ghProc(gcTypeContrat, giNumeroContrat).
        if mError:erreur() then return.
    end.
    
    /* table MANPOWER */
    if can-find(first rpges no-lock
                where rpges.nocon = giNumeroContrat)
    then do:
        ghProc = lancementPgm ("adblib/rpges_CRUD.p", poCollectionHandlePgm).
        run deleteRpgesSurContrat in ghProc(giNumeroContrat).
        if mError:erreur() then return.
    end.
                
    if gcTypeTrt <> "PURGE" 
    then do:
        /*--> Delete des factures d'entree locataire : COMPTA */
        for each iftsai exclusive-lock 
           where iftsai.soc-cd = isoc.soc-cd
             and iftsai.etab-cd = giNumeroMandat
             and iftsai.sscptg-cd = gcCptLoc
             and iftsai.typefac-cle = "Entrée"
             and not fg-edifac:
            for each iftln of iftsai exclusive-lock:
                delete iftln.  
            end.
            delete iftsai.
        end.  
        /*--> On suppprime le compte individuel en comptabilite */
        for first ccptcol no-lock 
            where ccptcol.soc-cd = giRefGerance
              and ccptcol.tprole = 19:
            for each csscptcol no-lock
               where csscptcol.soc-cd   = ccptcol.soc-cd
                 and csscptcol.etab-cd  = giNumeroMandat
                 and csscptcol.coll-cle = ccptcol.coll-cle
            use-index sscptcol-i:
                /*--> S'il existe deja le compte avec soc-cd negatif */
                for each csscpt exclusive-lock 
                   where csscpt.soc-cd = - ccptcol.soc-cd
                     and csscpt.etab-cd = giNumeroMandat
                     and csscpt.sscoll-cle = csscptcol.sscoll-cle
                     and csscpt.cpt-cd = gcCptLoc:
                    delete csscpt.
                end.
                /*--> Passage du compte en soc-cd negatif */
                for each csscpt of csscptcol exclusive-lock  
                   where csscpt.cpt-cd = gcCptLoc:
                    csscpt.soc-cd = - csscpt.soc-cd.
                end.
            end.
        end.
    end.
    
    /* renou, rev , entrée ...*/    
    for each afair exclusive-lock
       where afair.nomdt > 0
         and afair.tpdem = {&TYPEROLE-locataire}
         and afair.nodem = giNumeroContrat:
        delete afair no-error.      /* Pb incompréhensible à cette table : le DELETE est impossible !!! */
    end.

    /*--> Evenementiel */
    ghProc = lancementPgm ("evenementiel/supEvenementiel.p", poCollectionHandlePgm).
    run SupEvenementiel in ghProc(gcTypeContrat, giNumeroContrat, input-output poCollectionHandlePgm).
    if mError:erreur() then return.
    
    run SupEvenementiel in ghProc({&TYPEROLE-locataire}, giNumeroContrat, input-output poCollectionHandlePgm).
    if mError:erreur() then return.

    if can-find(first cthis no-lock
                where cthis.tpcon = gcTypeContrat
                  and cthis.nocon = giNumeroContrat)
    then do:
        ghProc = lancementPgm ("adblib/cthis_CRUD.p", poCollectionHandlePgm).
        run deleteCthisSurContrat in ghProc(gcTypeContrat, giNumeroContrat).
        if mError:erreur() then return.
    end. 
                  
    /*--> Suppression du Bail */
    for first ctrat no-lock
        where ctrat.TpCon = gcTypeContrat
          and ctrat.NoCon = giNumeroContrat:
        if ctrat.noblc > 0 
        then do:
            ghProc = lancementPgm ("note/notes_CRUD.p", poCollectionHandlePgm).
            run deleteNotesSurNoblc in ghProc(ctrat.noblc).
            if mError:erreur() then return.
        end.
        empty temp-table ttCtrat.
        create ttCtrat.
        assign
            ttCtrat.tpcon       = ctrat.tpcon 
            ttCtrat.nocon       = ctrat.nocon
            ttCtrat.CRUD        = "D"
            ttCtrat.dtTimestamp = datetime(ctrat.dtmsy, ctrat.hemsy)
            ttCtrat.rRowid      = rowid(ctrat)
            ghProc              = lancementPgm ("adblib/ctrat_CRUD.p", poCollectionHandlePgm)
        .
        run setCtrat in ghProc(table ttCtrat by-reference).
        if mError:erreur() then return.
    end.

    /*--> Mise à jour des sequences */
    find last tache no-lock
    use-index ix_tache01 no-error.
    if available tache 
    then current-value (sq_notac01) = tache.noita.
    else current-value (sq_notac01) = 1.
       
end procedure.

procedure prepaDelDetail private:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  : service externe 
    ------------------------------------------------------------------------------*/    
    define input parameter pcIxd01 as character no-undo.
    define input parameter pcIxd02 as character no-undo.

    define variable vcIdis as character no-undo.

    define buffer detail   for detail. 
    define buffer vbdetail for detail.

     for first detail no-lock
        where detail.ixd01 = pcIxd01 + string(giNumeroContrat, "9999999999"):
        vcIdis = entry(2, detail.ixd02, "|").
        for first vbdetail no-lock
            where vbdetail.ixd02 = pcIxd02 + vcIdis:
            create ttDetail.
            assign
                ttDetail.cddet       = vbdetail.cddet
                ttDetail.nodet       = vbdetail.nodet
                ttDetail.iddet       = vbdetail.iddet
                ttDetail.ixd01       = vbdetail.ixd01
                ttDetail.CRUD        = "D"
                ttDetail.dtTimestamp = datetime(vbdetail.dtmsy, vbdetail.hemsy) 
                ttDetail.rRowid      = rowid(vbdetail) 
            .                  
        end.
        create ttDetail.
        assign
            ttDetail.cddet       = detail.cddet
            ttDetail.nodet       = detail.nodet
            ttDetail.iddet       = detail.iddet
            ttDetail.ixd01       = detail.ixd01
            ttDetail.CRUD        = "D"
            ttDetail.dtTimestamp = datetime(detail.dtmsy, detail.hemsy) 
            ttDetail.rRowid      = rowid(detail) 
        .      
    end.

end procedure.
