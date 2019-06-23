/*------------------------------------------------------------------------
File        : suppressionContratAssurance.p
Purpose     : Suppression d'un contrat Assurance Immeuble  
Author(s)   : GGA - 17/12/06
Notes       : reprise adb/cont/delctass.p
01  14/04/2006  SY    0404/0305: Ajout parametres Entree/Sortie pour la PURGE
02  09/05/2006  SY    0404/0305: ajout suppr bloc-notes
09  27/11/2007  SY    1107/0217: Ajout suppression contrat bloc-note 01093 {&TYPECONTRAT-blocNote}
10  26/12/2013  SY    1213/0178: Amélioration gestion LOCK sur ltdiv
------------------------------------------------------------------------*/

{preprocesseur/type2contrat.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{adblib/include/ctrat.i}
{application/include/error.i}
{application/include/glbsepar.i}
{outils/include/lancementProgramme.i}

define variable ghProc as handle no-undo. 

procedure SupAssurance:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  : service externe 
    ------------------------------------------------------------------------------*/
    define input parameter table for ttError.
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter pcTypeTrt       as character no-undo.
    define input-output parameter poCollectionHandlePgm as class collection no-undo.

    define variable viSupCompagnie as integer no-undo. 
     
    define buffer ctrat   for ctrat.
    define buffer vbctrat for ctrat.
    define buffer vbintnt for intnt.

    /*--> Recherche du contrat... */    
    for first ctrat no-lock
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroContrat:
 
        /*--> On regarde si compagnie est rattachée à un autre contrat */              
        if not can-find(first intnt no-lock    
                        where intnt.tpidt = ctrat.tprol
                          and intnt.noidt = ctrat.norol
                          and intnt.tpcon <> ctrat.tpcon 
                          and intnt.nocon <> ctrat.nocon)
        and pcTypeTrt <> "PURGE" then do: 
            viSupCompagnie = outils:questionnaireGestion(108369, substitute('&2&1', separ[1], ctrat.lbnom), table ttError by-reference).    //La Compagnie %1 n'a plus de contrat d'assurance. Voulez-vous la supprimer ?
            if viSupCompagnie < 2 then return.
        end.
        else viSupCompagnie = 3. 
    
        /* suppression des commentaires */
        if ctrat.noblc > 0 
        then do:
            ghProc = lancementPgm ("note/notes_CRUD.p", poCollectionHandlePgm).
            run deleteNotesSurNoblc in ghProc(ctrat.noblc).
            if mError:erreur() then return.
        end.
 
        /* Suppression des liens INTNT */
        if can-find(first intnt no-lock
                    where intnt.tpcon = ctrat.tpcon
                      and intnt.nocon = ctrat.nocon)
        then do:
            ghProc = lancementPgm ("adblib/intnt_CRUD.p", poCollectionHandlePgm).
            run deleteIntntSurContrat in ghProc(ctrat.tpcon, ctrat.nocon).
            if mError:erreur() then return.
        end.
        
        /* Suppression des liens CTTAC */
        if can-find(first cttac no-lock 
                    where cttac.tpcon = ctrat.tpcon 
                      and cttac.nocon = ctrat.nocon)
        then do:                
            ghProc = lancementPgm ("adblib/cttac_CRUD.p", poCollectionHandlePgm).
            run deleteCttacSurContrat in ghProc(ctrat.tpcon, ctrat.nocon).
            if mError:erreur() then return.
        end.
       
        /* Suppression des TACHE */
        if can-find(first tache no-lock 
                    where tache.tpcon = ctrat.tpcon 
                      and tache.nocon = ctrat.nocon)
        then do:        
            ghProc = lancementPgm ("tache/tache.p", poCollectionHandlePgm).
            run deleteTacheSurContrat in ghProc(ctrat.tpcon, ctrat.nocon).
            if mError:erreur() then return.
        end.
        
        /* Suppression des Liens CTCTT */
        if can-find(first ctctt no-lock
                    where ctctt.tpct1 = ctrat.tpcon
                      and ctctt.noct1 = ctrat.nocon)
        then do:                   
            ghProc = lancementPgm ("adblib/ctctt_CRUD.p", poCollectionHandlePgm).
            run deleteCtcttSurContratPrincipal in ghProc(ctrat.tpcon, ctrat.nocon).
            if mError:erreur() then return.                
        end.
  
        if can-find(first ctctt no-lock
                    where ctctt.tpct2 = ctrat.tpcon
                      and ctctt.noct2 = ctrat.nocon)
        then do:    
            ghProc = lancementPgm ("adblib/ctctt_CRUD.p", poCollectionHandlePgm).                       
            run deleteCtcttSurContratSecondaire in ghProc(ctrat.tpcon, ctrat.nocon).
            if mError:erreur() then return.
        end.
        
        /* Suppression Attestation d'assurance */
        if can-find(first assat no-lock   
                    where assat.tpcon = ctrat.tpcon
                      and assat.nocon = ctrat.nocon)
        then do:   
            ghProc = lancementPgm ("adblib/assat_CRUD.p", poCollectionHandlePgm).
            run deleteAssatSurContrat in ghProc(ctrat.tpcon, ctrat.nocon).
            if mError:erreur() then return.
        end.
        
        /* Si compagnie non rattachée à un autre contrat et confirmation de suppression  */
        if viSupCompagnie = 3 then do:
            
            ghProc = lancementPgm ("role/roles_CRUD.p", poCollectionHandlePgm).
            run purgeRoles in ghProc(ctrat.tprol, ctrat.norol).
            if mError:erreur() then return.
            
            /* Contrat bloc-notes */
            if can-find(first intnt no-lock
                        where intnt.tpidt = ctrat.tprol
                          and intnt.noidt = ctrat.norol
                          and intnt.tpcon = {&TYPECONTRAT-blocNote})
            then do:
                ghProc = lancementPgm ("adblib/intnt_CRUD.p", poCollectionHandlePgm).
                run deleteContratBlocNote in ghProc(ctrat.tprol, ctrat.norol).
                if mError:erreur() then return.
            end.
  
            if can-find(first ladrs no-lock 
                        where ladrs.tpidt = ctrat.tprol
                          and ladrs.noidt = ctrat.norol)
            then do:                            
                ghProc = lancementPgm ("adresse/ladrs_CRUD.p", poCollectionHandlePgm).
                run deleteLadrsSurNoidt in ghProc(ctrat.tprol, ctrat.norol).
                if mError:erreur() then return.
            end.

            run supEvenementiel(ctrat.tprol, ctrat.norol, input-output poCollectionHandlePgm).
            if mError:erreur() then return.
        end.

        run SupEvenementiel(ctrat.tpcon, ctrat.nocon, input-output poCollectionHandlePgm).
        if mError:erreur() then return.

        /*--> Suppression du contrat */
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

end procedure.

procedure SupEvenementiel private:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  : 
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeIdentifiant   as character no-undo.   
    define input parameter piNumeroIdentifiant as int64     no-undo.
    define input-output parameter poCollectionHandlePgm as class collection no-undo.

    ghProc = lancementPgm ("evenementiel/supEvenementiel.p", poCollectionHandlePgm).
    run SupEvenementiel in ghProc(piNumeroIdentifiant, pcTypeIdentifiant, input-output poCollectionHandlePgm).

end procedure.
