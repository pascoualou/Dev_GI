/*------------------------------------------------------------------------
File        : deltitco.p
Purpose     : Suppression Titre de copropriété 
Author(s)   : SY 24/04/2006  -  GGA 2018/10/17
Notes       : reprise adb/lib/deltitco.p

 Dossier analyse  : doc_analyseetudes\Purge_ADB\a.Pre-etude\Purge_V05.doc
 Historique des modifications                                            
  No      Date     Auteur                   Objet                       
 0001  27/04/2006    SY    0404/0305 : Ajout cthis                      
 0002  26/07/2013   SY     0511/0023 prélèvement SEPA nouvelles tables  
                           mandatSEPA et suimandatSEPA                   
 0003  17/04/2015    SY    1214/0052 Compensation par lot                                                                                      
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}

{oerealm/include/instanciateTokenOnModel.i} // Doit être positionnée juste après using

{crud/include/ctrat.i}
{outils/include/lancementProgramme.i}       // fonctions lancementPgm, suppressionPgmPersistent

procedure delTitreCopro:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.    
    define input-output parameter poCollectionHandlePgm as class collection no-undo.

    define variable vhProc as handle no-undo.

    define buffer ctrat for ctrat.

    /* suppression des liens lots, indivisaires etc... */
    if can-find(first intnt no-lock
                where intnt.tpcon = pcTypeContrat
                  and intnt.nocon = piNumeroContrat) 
    then do:
        vhProc = lancementPgm ("crud/intnt_CRUD.p", poCollectionHandlePgm).
        run deleteIntntSurContrat in vhProc(pcTypeContrat, piNumeroContrat).
        if mError:erreur() then return.
    end.

    /* Suppression du lien avec le mandat maitre */
    if can-find(first ctctt no-lock
                where ctctt.tpct2 = pcTypeContrat
                  and ctctt.noct2 = piNumeroContrat) then do:
        vhProc = lancementPgm ("crud/ctctt_CRUD.p", poCollectionHandlePgm).
        run deleteCtcttSurContratSecondaire in vhProc(pcTypeContrat, piNumeroContrat).
        if mError:erreur() then return.
    end.

    /* Suppression taches */
    if can-find(first tache no-lock
                where tache.tpcon = pcTypeContrat
                  and tache.nocon = piNumeroContrat) then do:
        vhProc = lancementPgm ("crud/tache_CRUD.p", poCollectionHandlePgm).
        run deleteTacheSurContrat in vhProc(pcTypeContrat, piNumeroContrat).
        if mError:erreur() then return.
    end.

    /* Delete de tous les liens CTTAC */
    if can-find(first cttac no-lock
                where cttac.tpcon = pcTypeContrat
                  and cttac.nocon = piNumeroContrat) then do:
        vhProc = lancementPgm ("crud/cttac_CRUD.p", poCollectionHandlePgm).
        run deleteCttacSurContrat in vhProc(pcTypeContrat, piNumeroContrat).
        if mError:erreur() then return.
    end.

    /* liens banque */
    if can-find(first rlctt no-lock
                // whole-index corrige par la creation dans la version d'un index sur tpct1 noct1
                where rlctt.tpct1 = pcTypeContrat
                  and rlctt.noct1 = piNumeroContrat) then do:
        vhProc = lancementPgm("crud/rlctt_CRUD.p", poCollectionHandlePgm).
        run deleteRlcttSurContratMaitre in vhProc(pcTypeContrat, piNumeroContrat).
        if mError:erreur() then return.
    end.

    /* lien copro - gérance */
    if can-find(first synge no-lock
                where synge.tpct1 = pcTypeContrat
                  and synge.noct1 = piNumeroContrat) then do:
        vhProc = lancementPgm("crud/synge_CRUD.p", poCollectionHandlePgm).
        run deleteSyngeSurContrat1 in vhProc(pcTypeContrat, piNumeroContrat).
        if mError:erreur() then return.
    end.

    /* SY 1214/0052 */     
    if can-find(first compenslot no-lock
                where compenslot.tpct1 = pcTypeContrat
                  and compenslot.noct1 = piNumeroContrat) then do:
        vhProc = lancementPgm("crud/compenslot_CRUD.p", poCollectionHandlePgm).
        run deleteCompenslotSurContrat1 in vhProc(pcTypeContrat, piNumeroContrat).
        if mError:erreur() then return.
    end.
    
    if can-find(first cthis no-lock
                where cthis.tpcon = pcTypeContrat
                  and cthis.nocon = piNumeroContrat) then do:
        vhProc = lancementPgm("crud/cthis_CRUD.p", poCollectionHandlePgm).
        run deleteCthisSurContrat in vhProc(pcTypeContrat, piNumeroContrat).
        if mError:erreur() then return.
    end.
        
    /* Ajout SY le 26/07/2013 : SEPA */
    if can-find(first mandatSepa no-lock
                where mandatSepa.tpmandat = {&TYPECONTRAT-sepa}
                  and mandatSepa.tpcon    = pcTypeContrat
                  and mandatSepa.nocon    = piNumeroContrat) then do:
        vhProc = lancementPgm("crud/mandatSEPA_CRUD.p", poCollectionHandlePgm).
        run deleteMandatSepaSurContrat in vhProc({&TYPECONTRAT-sepa}, pcTypeContrat, piNumeroContrat).
        if mError:erreur() then return.
    end.
            
    /* Recherche du contrat dans CTRAT*/
    for first ctrat no-lock
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroContrat:
        /* Ajout SY le 17/10/2005 : suppression bloc-notes */
        if ctrat.noblc > 0 then do:
            vhProc = lancementPgm("crud/notes_CRUD.p", poCollectionHandlePgm).
            run deleteNotesSurNoblc in vhProc(ctrat.noblc).
            if mError:erreur() then return.
        end.
        /* 14/10/2003 : suppression du contrat */
        empty temp-table ttCtrat.
        create ttCtrat.
        assign
            ttCtrat.tpcon       = ctrat.tpcon
            ttCtrat.nocon       = ctrat.nocon
            ttCtrat.CRUD        = "D"
            ttCtrat.dtTimestamp = datetime(ctrat.dtmsy, ctrat.hemsy)
            ttCtrat.rRowid      = rowid(ctrat)
            vhProc              = lancementPgm("crud/ctrat_CRUD.p", poCollectionHandlePgm)
        .
        run setCtrat in vhProc(table ttCtrat by-reference).
        if mError:erreur() then return.
    end.
    
end procedure.
