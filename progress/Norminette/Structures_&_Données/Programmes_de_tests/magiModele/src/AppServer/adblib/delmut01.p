/*------------------------------------------------------------------------
File        : delmut01.p
Purpose     : Suppression d'un contrat mutation de Gérance (01098)
Author(s)   : SY 01/06/2010   -  GGA 2018/02/08
Notes       : reprise adb/lib/delmut01.p
derniere revue: 2018/04/13 - phm: OK
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{adblib/include/ctrat.i}
{outils/include/lancementProgramme.i}
{application/include/error.i}

procedure DelCttMutGer:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  : service appelé par listeMutation.p, delmdtge.p
    ------------------------------------------------------------------------------*/  
    define input parameter table for ttError.      
    define input parameter piNumeroContratMutation as int64 no-undo.
    define input-output parameter poCollectionHandlePgm as class collection no-undo.
 
    define variable vhProc as handle no-undo.

    define buffer ctrat   for ctrat.
    define buffer vbctrat for ctrat.

    /* Recherche du contrat */
    for first ctrat no-lock  
        where ctrat.tpcon = {&TYPECONTRAT-mutationGerance}
          and ctrat.nocon = piNumeroContratMutation:
mLogger:writeLog(0, substitute("DelCttMutGer contrat mutation : &1", piNumeroContratMutation)).              
        /* SUPPRESSION DU CONTRAT DE MUTATION DANS MAJ */
        if can-find(first maj no-lock     
                    where maj.nmlog          = "SADB"
                      and maj.soc-cd         = integer(mToken:cRefPrincipale)
                      and maj.nmtab          = "CTRAT"
                      and integer(maj.cdenr) = ctrat.nodoc)
        then do:
            vhProc = lancementPgm("adblib/maj_CRUD.p", poCollectionHandlePgm).
            run deleteMajSurDocument in vhProc("SADB", integer(mToken:cRefPrincipale), "CTRAT", ctrat.nodoc).
            if mError:erreur() then return.
        end.

        /* Suppression des liens INTNT */
        if can-find(first intnt no-lock
                    where intnt.tpcon = ctrat.tpcon
                      and intnt.nocon = ctrat.nocon)
        then do:                      
            vhProc = lancementPgm ("adblib/intnt_CRUD.p", poCollectionHandlePgm).
            run deleteIntntSurContrat in vhProc(ctrat.tpcon, ctrat.nocon).
            if mError:erreur() then return.
        end.

        /* Suppression des Liens CTCTT */
        if can-find(first ctctt no-lock
                    where ctctt.tpct1 = ctrat.tpcon
                      and ctctt.noct1 = ctrat.nocon)
        then do:
            vhProc = lancementPgm ("adblib/ctctt_CRUD.p", poCollectionHandlePgm).
            run deleteCtcttSurContratPrincipal in vhProc(ctrat.tpcon, ctrat.nocon).
            if mError:erreur() then return.
        end.

        if can-find(first ctctt no-lock
                    where ctctt.tpct2 = ctrat.tpcon
                      and ctctt.noct2 = ctrat.nocon)
        then do:
            vhProc = lancementPgm ("adblib/ctctt_CRUD.p", poCollectionHandlePgm).            
            run deleteCtcttSurContratSecondaire in vhProc(ctrat.tpcon, ctrat.nocon).
            if mError:erreur() then return.
        end.

        /* Suppression traces suivi associées */
        if can-find(first detail no-lock
                    where detail.cddet = "MUTAG" + string(ctrat.nocon, "999999999"))
        then do:
            vhProc = lancementPgm ("adblib/detail_CRUD.p", poCollectionHandlePgm).
            run deleteDetailSurCode in vhProc("MUTAG" + string(ctrat.nocon, "999999999")).
            if mError:erreur() then return.
        end.

        /* A faire APRES supression ctctt */
        find first vbctrat no-lock
             where vbctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
               and vbctrat.nocon = ctrat.nomdt-ach no-error.
mLogger:writeLog(0, substitute("delmut01.p DelCttMutGer contrat acheteur : &1 provisoire : &2", vbctrat.nocon, vbctrat.fgprov)).               
        if available vbctrat and vbctrat.fgprov 
        then do:
            vhProc = lancementPgm ("mandat/delmdtge.p", poCollectionHandlePgm).
            run lanceDelmdtge in vhProc(table ttError, ctrat.nomdt-ach, yes, "", input-output poCollectionHandlePgm).
            if mError:erreur() then return.
        end.
        
        /* Suppression du contrat */  
        empty temp-table ttCtrat.
        create ttCtrat.
        assign
            ttCtrat.tpcon       = ctrat.tpcon 
            ttCtrat.nocon       = ctrat.nocon
            ttCtrat.CRUD        = "D"
            ttCtrat.dtTimestamp = datetime(ctrat.dtmsy, ctrat.hemsy)
            ttCtrat.rRowid      = rowid(ctrat)
            vhProc              = lancementPgm ("adblib/ctrat_CRUD.p", poCollectionHandlePgm)
        .
        run setCtrat in vhProc(table ttCtrat by-reference).
        if mError:erreur() then return.
    end.

end procedure.
