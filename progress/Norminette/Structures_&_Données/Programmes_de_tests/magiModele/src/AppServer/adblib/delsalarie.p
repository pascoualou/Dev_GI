/*---------------------------------------------------------------------------
File        : delsalarie.p
Purpose     : Suppression d'un contrat salarié ou contrat salarie Pegase  
Author(s)   : SY 24/04/2006 (delsal00.p) 02/07/2014 (delsalpz.p)  -  GGA 2018/02/12
Notes       : reprise adb/lib/delsal00.p et adb/lib/delsalpz.p

01  27/04/2006  SY    0404/0305 Ajout suppr evenementiel
02  09/05/2006  SY    0404/0305 ajout suppr bloc-notes
03  27/11/2006  SY    0405/0447 ajout suppr salpre (inutilisée pour le moment)
04  16/08/2007  SY    0207/0135 ajout suppr salimp
05  27/11/2007  SY    1107/0217 Ajout suppression contrat bloc-note 01093
06  05/12/2007  SY    0207/0128 Ajout suppr cumdas
07  16/09/2008  NP    0608/0065 Gestion Mandats à 5 chiffres
08  27/01/2009  SY    ajout tables salanb et telephones + suppression doublon delete epaie
09  15/07/2009  SY    ajout tables DIF: salhis,difcum,difheu,difuti
10  15/07/2009  SY    0709/0106 : ajout suppr trace PECEC
11  23/10/2012  SY    plus de EXCLUSIVE-LOCK sur ltxxx, trop de conflit Utilisateur sur les tables requête
12  23/10/2012  SY    1012/0150 Gestion suppressions multiples du même salarié en compta
---------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{adblib/include/ctrat.i}
{adblib/include/pclie.i}
{adblib/include/cumsa.i}
{tache/include/tache.i}
{outils/include/lancementProgramme.i}

define variable ghProc as handle no-undo.

procedure DelCttSal:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  : service externe 
    ------------------------------------------------------------------------------*/   
    define input parameter pcTypeRoleSalarie as character no-undo.
    define input parameter piNumeroContrat   as int64     no-undo.
    define input parameter pcTypeContrat     as character no-undo.
    define input parameter piNumeroMandat    as integer   no-undo.
    define input parameter pcTypeMandat      as character no-undo.
    define input parameter pcTypeTrt         as character no-undo.
    define input parameter plSupCpt          as logical   no-undo.
    define input-output parameter poCollectionHandlePgm as class collection no-undo.

    define variable vcCptCdSal as character no-undo.
    define variable vcTempo    as character no-undo. 
    define variable viCodeSoc  as integer   no-undo. 

    define buffer ctrat      for ctrat.
    define buffer csscpt     for csscpt.
    define buffer iempl      for iempl.
    define buffer tache      for tache.
    define buffer pclie      for pclie.

mLogger:writeLog(0, substitute("delsalarie.p DelCttSal pcTypeRoleSalarie : &1 piNumeroContrat : &2 pcTypeContrat &3 piNumeroMandat &4 pcTypeMandat &5 pcTypeTrt &9 plSupCpt &7", 
                               pcTypeRoleSalarie, piNumeroContrat, pcTypeContrat, piNumeroMandat, pcTypeMandat, pcTypeTrt, plSupCpt)).    
    viCodeSoc = integer(mToken:cRefPrincipale).
    
    /*--> Recherche du contrat... */
    for first ctrat no-lock  
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroContrat:
        if ctrat.noblc > 0 
        then do:
            ghProc = lancementPgm ("note/notes_CRUD.p", poCollectionHandlePgm).
            run deleteNotesSurNoblc in ghProc(ctrat.noblc).
            if mError:erreur() then return.
        end.
        if pcTypeRoleSalarie = {&TYPEROLE-salarie}
        then vcCptCdSal = string(ctrat.nocon modulo 100, "99999").     //string(integer(substring(string(ctrat.nocon, "9999999"), 6, 2)), "99999").
        else vcCptCdSal = string(ctrat.nocon modulo 100000, "99999").  //string(integer(substring(string(ctrat.nocon, "9999999999"), 6, 5)), "99999). 
        if pcTypeTrt <> "PURGE" and plSupCpt then do:
            /* suppression physique anciennes traces */
            for each csscpt exclusive-lock
                where csscpt.soc-cd     = - viCodeSoc
                  and csscpt.etab-cd    = piNumeroMandat
                  and csscpt.cpt-cd     = vcCptCdSal
                  and csscpt.sscoll-cle = "EI":
                for first iempl exclusive-lock
                    where iempl.soc-cd   = - viCodeSoc
                      and iempl.coll-cle = "ei"
                      and iempl.empl-cle = string(piNumeroMandat, "9999") + csscpt.cpt-cd:
                    delete iempl.
                end.
                delete csscpt.
            end.
            /* "Suppression" du salarie en compta (masquage) */
            for each csscpt exclusive-lock
                where csscpt.soc-cd     = viCodeSoc
                  and csscpt.etab-cd    = piNumeroMandat
                  and csscpt.cpt-cd     = vcCptCdSal
                  and csscpt.sscoll-cle = "EI":
                for first iempl exclusive-lock 
                    where iempl.soc-cd   = viCodeSoc
                      and iempl.coll-cle = "ei"
                      and iempl.empl-cle = string(piNumeroMandat, "9999") + csscpt.cpt-cd:
                    iempl.soc-cd = - iempl.soc-cd no-error.
                end.
                csscpt.soc-cd = - csscpt.soc-cd no-error.
            end.
        end.
        
        /* suppression imputation comptable */
        if can-find(first salimp no-lock 
                    where salimp.tprol = pcTypeRoleSalarie
                      and salimp.norol = piNumeroContrat)
        then do:                          
            ghProc = lancementPgm ("adblib/salimp_CRUD.p", poCollectionHandlePgm).
            run deleteSalimpSurRole in ghProc(pcTypeRoleSalarie, piNumeroContrat).
            if mError:erreur() then return.    
        end.
        
        /* Suppression de l'emploi du salarié */
        if can-find(first salar no-lock 
                    where salar.tprol = pcTypeRoleSalarie
                      and salar.norol = piNumeroContrat)
        then do:                                  
            ghProc = lancementPgm ("adblib/salar_CRUD.p", poCollectionHandlePgm).
            run deleteSalarSurRole in ghProc(pcTypeRoleSalarie, piNumeroContrat).
            if mError:erreur() then return.    
        end.
          
        /* Suppression de la banque du salarié */
        if can-find(first rlctt no-lock
                    where rlctt.tpidt = pcTypeRoleSalarie
                      and rlctt.noidt = piNumeroContrat
                      and rlctt.tpct1 = pcTypeContrat
                      and rlctt.noct1 = piNumeroContrat
                      and rlctt.tpct2 = {&TYPECONTRAT-prive})
        then do:  
            ghProc = lancementPgm ("adblib/rlctt_CRUD.p", poCollectionHandlePgm).
            run deleteRlcttSurTypeContratSecondaire in ghProc(pcTypeRoleSalarie, piNumeroContrat, pcTypeContrat, piNumeroContrat, {&TYPECONTRAT-prive}).
            if mError:erreur() then return.
        end.
        
        /* Contrat bloc-notes */
        if can-find(first intnt no-lock
                    where intnt.tpidt = pcTypeRoleSalarie
                      and intnt.noidt = piNumeroContrat
                      and intnt.tpcon = {&TYPECONTRAT-blocNote})
        then do:                
            ghProc = lancementPgm ("adblib/intnt_CRUD.p", poCollectionHandlePgm).
            run deleteContratBlocNote in ghProc(pcTypeRoleSalarie, piNumeroContrat).
            if mError:erreur() then return.
        end.
        
        /* Suppression du role salarié & lien adresse */
        ghProc = lancementPgm ("role/roles_CRUD.p", poCollectionHandlePgm).
        run purgeRoles in ghProc(pcTypeRoleSalarie, piNumeroContrat). 
        if mError:erreur() then return.
 
        if can-find(first ladrs no-lock 
                    where ladrs.tpidt = pcTypeRoleSalarie
                      and ladrs.noidt = piNumeroContrat)
        then do:                                               
            ghProc = lancementPgm ("adresse/ladrs_CRUD.p", poCollectionHandlePgm).
            run deleteLadrsSurNoidt in ghProc(pcTypeRoleSalarie, piNumeroContrat).
            if mError:erreur() then return.
        end.    
 
        if can-find(first telephones no-lock 
                    where telephones.tpidt = pcTypeRoleSalarie
                      and telephones.noidt = piNumeroContrat)
        then do:                                                 
            ghProc = lancementPgm ("tiers/telephones_CRUD.p", poCollectionHandlePgm).
            run deleteTelephonesSurNoidt in ghProc(pcTypeRoleSalarie, piNumeroContrat).
            if mError:erreur() then return.
        end.

        /* Suppression liens contrat salarié - taches */
        if can-find(first cttac no-lock 
                    where cttac.tpcon = pcTypeContrat
                      and cttac.nocon = piNumeroContrat)
        then do:                           
            ghProc = lancementPgm ("adblib/cttac_CRUD.p", poCollectionHandlePgm).
            run deleteCttacSurContrat in ghProc(pcTypeContrat, piNumeroContrat).
            if mError:erreur() then return.
        end.
               
        /* Suppression taches */
        if can-find(first tache no-lock 
                    where tache.tpcon = pcTypeContrat
                      and tache.nocon = piNumeroContrat)
        then do:                  
            ghProc = lancementPgm ( "tache/tache.p", poCollectionHandlePgm).
            run deleteTacheSurContrat in ghProc(pcTypeContrat, piNumeroContrat).
            if mError:erreur() then return.
        end.
        
        /* Suppression lien role - contrat salarié */
        if can-find(first intnt no-lock
                    where intnt.tpcon = pcTypeContrat
                      and intnt.nocon = piNumeroContrat)
        then do:              
            ghProc = lancementPgm ("adblib/intnt_CRUD.p", poCollectionHandlePgm).
            run deleteIntntSurContrat in ghProc(pcTypeContrat, piNumeroContrat).
            if mError:erreur() then return.
        end.
     
        /* Suppression lien mandat - contrat salarié */
        ghProc = lancementPgm ("adblib/ctctt_CRUD.p", poCollectionHandlePgm).
        run deleteCtcttSurCle in ghProc(pcTypeMandat, piNumeroMandat, pcTypeContrat, piNumeroContrat).
        if mError:erreur() then return.    
        
        /* historiques de paie */
        empty temp-table ttCumsa. 
        for each cumsa no-lock
            where cumsa.tpmdt = pcTypeMandat
              and cumsa.nomdt = piNumeroMandat
              and cumsa.norol = piNumeroContrat:
            create ttCumsa.
            assign
                ttCumsa.antrt       = cumsa.antrt
                ttCumsa.tpmdt       = cumsa.tpmdt
                ttCumsa.nomdt       = cumsa.nomdt
                ttCumsa.tprol       = cumsa.tprol
                ttCumsa.norol       = cumsa.norol
                ttCumsa.nomod       = cumsa.nomod
                ttCumsa.CRUD        = "D"
                ttCumsa.dtTimestamp = datetime(cumsa.dtmsy, cumsa.hemsy) 
                ttCumsa.rRowid      = rowid(cumsa) 
             .
        end.
        if can-find(first ttCumsa) then do:
            ghProc = lancementPgm ("adblib/cumsa_CRUD.p", poCollectionHandlePgm).
            run setCumsa in ghProc(table ttCumsa by-reference).
            if mError:erreur() then return.
        end.

        if can-find(first cumdas no-lock 
                    where cumdas.tprol = pcTypeRoleSalarie
                      and cumdas.norol = decimal(piNumeroContrat))
        then do:                  
            ghProc = lancementPgm ("adblib/cumdas_CRUD.p", poCollectionHandlePgm).
            run deleteCumdasSurRole in ghProc(pcTypeRoleSalarie, decimal(piNumeroContrat)).
            if mError:erreur() then return.    
        end.
 
        /* conges payes */
        if can-find(first conge no-lock 
                    where conge.tprol = pcTypeRoleSalarie
                      and conge.norol = piNumeroContrat)
        then do:                          
            ghProc = lancementPgm ("adblib/conge_CRUD.p", poCollectionHandlePgm).
            run deleteCongeSurRole in ghProc(pcTypeRoleSalarie, piNumeroContrat).
            if mError:erreur() then return.    
        end.
        
        /* bulletins en cours */
        if can-find(first epaie no-lock 
                    where epaie.tprol = pcTypeRoleSalarie
                      and epaie.norol = piNumeroContrat)
        then do:                                  
            ghProc = lancementPgm ("adblib/epaie_CRUD.p", poCollectionHandlePgm).
            run deleteEpaieSurRole in ghProc(pcTypeRoleSalarie, piNumeroContrat).
            if mError:erreur() then return.    
        end.
        
        /* historique des bulletins */
        if can-find(first epaie no-lock 
                    where epaie.tprol = pcTypeRoleSalarie
                      and epaie.norol = piNumeroContrat)
        then do:                                          
            ghProc = lancementPgm ("adblib/apaie_CRUD.p", poCollectionHandlePgm).
            run deleteApaieSurRole in ghProc(pcTypeRoleSalarie, piNumeroContrat).
            if mError:erreur() then return.    
        end.
  
        /* attestation de salaire pour la SS */  
        if can-find(first atsal no-lock 
                    where atsal.nomdt = piNumeroMandat
                      and atsal.norol = piNumeroContrat)
        then do:                                                  
            ghProc = lancementPgm ("adblib/atsal_CRUD.p", poCollectionHandlePgm).
            run deleteAtsalSurMandatRole in ghProc(piNumeroMandat, piNumeroContrat).
            if mError:erreur() then return.    
        end.
        
        /* attestation ASSEDIC */
        if can-find(first atass no-lock 
                    where atass.nomdt = piNumeroMandat
                      and atass.norol = piNumeroContrat)
        then do:                                                          
            ghProc = lancementPgm ("adblib/atass_CRUD.p", poCollectionHandlePgm).
            run deleteAtassSurMandatRole in ghProc(piNumeroMandat, piNumeroContrat).
            if mError:erreur() then return.    
        end.
   
        /* absences maladie */
        if can-find(first malad no-lock 
                    where malad.norol = piNumeroContrat)
        then do:                                                                  
            ghProc = lancementPgm ("adblib/malad_CRUD.p", poCollectionHandlePgm).
            run deleteMaladSurRole in ghProc(piNumeroContrat).
            if mError:erreur() then return.    
        end.

        /* périodes de présence */
        if can-find(first salpre no-lock 
                    where salpre.tprol = pcTypeRoleSalarie
                      and salpre.norol = piNumeroContrat)
        then do:
            ghProc = lancementPgm ("adblib/salpre_CRUD.p", poCollectionHandlePgm).
            run deleteSalpreSurRole in ghProc(pcTypeRoleSalarie, piNumeroContrat).
            if mError:erreur() then return.    
        end.    
        
        /* suppression annulation bulletin */
        if can-find(first salanb no-lock 
                    where salanb.tprol = pcTypeRoleSalarie
                      and salanb.norol = piNumeroContrat)
        then do:        
            ghProc = lancementPgm ("adblib/salanb_CRUD.p", poCollectionHandlePgm).
            run deleteSalanbSurRole in ghProc(pcTypeRoleSalarie, piNumeroContrat).
            if mError:erreur() then return.
        end.
        
        /* suppression histo pour DIF */
        if can-find(first salhis no-lock 
                    where salhis.tprol = pcTypeRoleSalarie
                      and salhis.norol = piNumeroContrat)
        then do:                
            ghProc = lancementPgm ("adblib/salhis_CRUD.p", poCollectionHandlePgm).
            run deleteSalhisSurRole in ghProc(pcTypeRoleSalarie, piNumeroContrat).
            if mError:erreur() then return.  
        end.         

        if can-find(first difcum no-lock 
                    where difcum.tprol = pcTypeRoleSalarie
                      and difcum.norol = piNumeroContrat)
        then do:                
            ghProc = lancementPgm ("adblib/difcum_CRUD.p", poCollectionHandlePgm).
            run deleteDifcumSurRole in ghProc(pcTypeRoleSalarie, piNumeroContrat).
            if mError:erreur() then return.            
        end.

        if can-find(first difheu no-lock 
                    where difheu.tprol = pcTypeRoleSalarie
                      and difheu.norol = piNumeroContrat)
        then do:                        
            ghProc = lancementPgm ("adblib/difheu_CRUD.p", poCollectionHandlePgm).
            run deleteDifheuSurRole in ghProc(pcTypeRoleSalarie, piNumeroContrat).
            if mError:erreur() then return.                    
        end.
 
        if can-find(first difuti no-lock 
                    where difuti.tprol = pcTypeRoleSalarie
                      and difuti.norol = piNumeroContrat)
        then do:                        
            ghProc = lancementPgm ("adblib/difuti_CRUD.p", poCollectionHandlePgm).
            run deleteDifutiSurRole in ghProc(pcTypeRoleSalarie, piNumeroContrat).
            if mError:erreur() then return.                    
        end.
           
        /* Raz role dans tache Domotique de l'immeuble */
        empty temp-table ttTache.
        vcTempo = pcTypeRoleSalarie + "," + string(piNumeroContrat).
        for each tache no-lock
           where tache.tpcon = {&TYPECONTRAT-construction}
             and tache.tptac = {&TYPETACHE-loge}
             and tache.pdreg = "TRUE"
             and tache.cdreg = vcTempo:
            create ttTache.
            assign
                ttTache.tpcon       = tache.tpcon
                ttTache.nocon       = tache.nocon
                ttTache.tptac       = tache.tptac
                ttTache.notac       = tache.notac
                ttTache.CRUD        = "U"
                ttTache.dtTimestamp = datetime(tache.dtmsy, tache.hemsy) 
                ttTache.rRowid      = rowid(tache) 
                ttTache.cdreg       = ""
             .
        end.
        if can-find(first ttTache) then do:
            ghProc = lancementPgm ("tache/tache.p", poCollectionHandlePgm).
            run setTache in ghProc(table ttTache by-reference).
            if mError:erreur() then return.
        end.
        
        /* suppression mémoire dernier utilisé */
        empty temp-table ttPclie.
        for each pclie no-lock
           where pclie.tppar          = "MEMID"
             and pclie.zon02          = pcTypeRoleSalarie
             and integer(pclie.zon03) = piNumeroContrat:
            create ttPclie.
            assign
                ttPclie.tppar       = pclie.tppar
                ttPclie.zon01       = pclie.zon01
                ttPclie.CRUD        = "D"
                ttPclie.dtTimestamp = datetime(pclie.dtmsy, pclie.hemsy) 
                ttPclie.rRowid      = rowid(pclie) 
             .
        end.
        for each pclie no-lock
           where pclie.tppar          = "MEMID"
             and pclie.zon02          = pcTypeContrat
             and integer(pclie.zon03) = piNumeroContrat:
            create ttPclie.
            assign
                ttPclie.tppar       = pclie.tppar
                ttPclie.zon01       = pclie.zon01
                ttPclie.CRUD        = "D"
                ttPclie.dtTimestamp = datetime(pclie.dtmsy, pclie.hemsy) 
                ttPclie.rRowid      = rowid(pclie) 
             .
        end.
        /* Ajout SY le 15/07/2009 */
        for each pclie no-lock
           where pclie.tppar = "PECEC"
             and pclie.zon01 = pcTypeContrat
             and pclie.int01 = piNumeroContrat:
            create ttPclie.
            assign
                ttPclie.tppar       = pclie.tppar
                ttPclie.zon01       = pclie.zon01
                ttPclie.CRUD        = "D"
                ttPclie.dtTimestamp = datetime(pclie.dtmsy, pclie.hemsy) 
                ttPclie.rRowid      = rowid(pclie) 
             .
        end.
        if can-find(first ttPclie) then do:
            ghProc = lancementPgm ("adblib/pclie_CRUD.p", poCollectionHandlePgm).
            run setPclie in ghProc(table ttPclie by-reference).
            if mError:erreur() then return.
        end.
        
        /*--> Evenementiel */
        ghProc = lancementPgm ("evenementiel/supEvenementiel.p", poCollectionHandlePgm).
        run SupEvenementiel in ghProc(pcTypeContrat, piNumeroContrat, input-output poCollectionHandlePgm).
        if mError:erreur() then return.
        
        run SupEvenementiel in ghProc(pcTypeRoleSalarie, piNumeroContrat, input-output poCollectionHandlePgm).
        if mError:erreur() then return.
        
        /* Suppression contrat salarié */
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
    
end procedure.
