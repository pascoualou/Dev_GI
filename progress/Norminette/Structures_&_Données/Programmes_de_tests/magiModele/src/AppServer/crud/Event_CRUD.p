/*------------------------------------------------------------------------
File        : Event_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table Event
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
derniere revue: 2018/06/05 - phm: OK
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttEvent as handle no-undo.     // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phNoeve as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noeve, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noeve' then phNoeve = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudEvent private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteEvent.
    run updateEvent.
    run createEvent.
end procedure.

procedure setEvent:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttEvent.
    ghttEvent = phttEvent.
    run crudEvent.
    delete object phttEvent.
end procedure.

procedure readEvent:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table Event 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoeve as int64      no-undo.
    define input parameter table-handle phttEvent.
    define variable vhttBuffer as handle no-undo.
    define buffer vbEvent for event.

    vhttBuffer = phttEvent:default-buffer-handle.
    for first vbEvent no-lock
        where vbEvent.NoEve = piNoeve:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer vbEvent:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEvent no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getEvent:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table event 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttEvent.
    define variable vhttBuffer as handle  no-undo.
    define buffer vbEvent for event.

    vhttBuffer = phttEvent:default-buffer-handle.
    for each vbEvent no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer vbEvent:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEvent no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateEvent private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoeve    as handle  no-undo.
    define buffer vbEvent for event.

    create query vhttquery.
    vhttBuffer = ghttEvent:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttEvent:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoeve).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first vbEvent exclusive-lock
                where rowid(vbEvent) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer vbEvent:handle, 'NoEve: ', substitute('&1', vhNoeve:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer vbEvent:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createEvent private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer vbEvent for event.

    create query vhttquery.
    vhttBuffer = ghttEvent:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttEvent:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create vbEvent.
            if not outils:copyValidField(buffer vbEvent:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteEvent private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoeve    as handle  no-undo.
    define buffer vbEvent for event.

    create query vhttquery.
    vhttBuffer = ghttEvent:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttEvent:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoeve).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first vbEvent exclusive-lock
                where rowid(vbEvent) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer vbEvent:handle, 'NoEve: ', substitute('&1', vhNoeve:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete vbEvent no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteEventParType:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
             et des enregistrements des tables dependantes (desev, tbfic, gadet, evtev) 
             a partir de adb/cpta/gerevent.p pour le code case TpActSel when "SUPPR" 
             appel du type ({RunPgExp.i &Path = RpRunCpt &Prog = "'gerevent.p'" &Parameter = "'SUPPR','',0,'',0,'DOCUM',docum.nodoc,'',0,'',0"}
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypetrt        as character no-undo.
    define input parameter piNumeroDocument as integer   no-undo.
    define input parameter pcTypeRole       as character no-undo.
    define input parameter piNumeroRole     as integer   no-undo.

    define variable viTypeRole as integer no-undo.  
    define buffer vbEvent for event.

message "deleteEventParType "  pcTypetrt "// " piNumeroDocument "// " pcTypeRole "// " piNumeroRole.

blocTrans:
    do transaction:
        case pcTypetrt:
            when "DOCUM" then for each vbEvent exclusive-lock
                where vbEvent.nodoc = piNumeroDocument:
                run trtDeleteDepEvent(vbEvent.noeve, vbEvent.tpcon, vbEvent.nocon).
                if mError:erreur() then undo blocTrans, leave blocTrans.

                delete vbEvent no-error.
                if error-status:error then do:
                    mError:createError({&error}, error-status:get-message(1)).
                    undo blocTrans, leave blocTrans. 
                end.
            end.

            when "SSDOS" then for each vbEvent exclusive-lock  
                where vbEvent.nossd = piNumeroDocument
                  and vbEvent.tprol = pcTypeRole
                  and vbEvent.norol = piNumeroRole:
                run trtDeleteDepEvent(vbEvent.noeve, vbEvent.tpcon, vbEvent.nocon).
                if mError:erreur() then undo blocTrans, leave blocTrans.

                delete vbEvent no-error.
                if error-status:error then do:
                    mError:createError({&error}, error-status:get-message(1)).
                    undo blocTrans, leave blocTrans.
                end.
            end.

            otherwise do: 
                viTypeRole = integer(pcTypeRole) no-error.
                if error-status:error or (viTypeRole > 0 and viTypeRole < 1000) 
                then for each vbEvent exclusive-lock  
                   where vbEvent.tprol = pcTypeRole
                     and vbEvent.norol = piNumeroRole:
                    run trtDeleteDepEvent(vbEvent.noeve, vbEvent.tpcon, vbEvent.nocon).
                    if mError:erreur() then undo blocTrans, leave blocTrans.

                    delete vbEvent no-error.
                    if error-status:error then do:
                        mError:createError({&error}, error-status:get-message(1)).
                        undo blocTrans, leave blocTrans. 
                    end.
                end.
                else if viTypeRole > 1000 and viTypeRole < 2000 
                then for each vbEvent exclusive-lock
                    where vbEvent.tpcon = pcTypeRole
                      and vbEvent.nocon = piNumeroRole:
                    run trtDeleteDepEvent(vbEvent.noeve, vbEvent.tpcon, vbEvent.nocon).
                    if mError:erreur() then undo blocTrans, leave blocTrans.

                    delete vbEvent no-error.
                    if error-status:error then do:
                        mError:createError({&error}, error-status:get-message(1)).
                        undo blocTrans, leave blocTrans. 
                    end.
                end.
                else if viTypeRole = 2001
                then for each vbEvent exclusive-lock
                    where vbEvent.noimm = piNumeroRole:
                    run trtDeleteDepEvent(vbEvent.noeve, vbEvent.tpcon, vbEvent.nocon).
                    if mError:erreur() then undo blocTrans, leave blocTrans.

                    delete vbEvent no-error.
                    if error-status:error then do:
                        mError:createError({&error}, error-status:get-message(1)).
                        undo blocTrans, leave blocTrans. 
                    end.
                end.
            end.
        end case.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.

procedure trtDeleteDepEvent private:
    /*------------------------------------------------------------------------------
    Purpose: suppression des enregistrements des tables dependantes (desev, tbfic, gadet, evtev) de event 
    Notes  : 
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroEvenement as int64     no-undo.
    define input parameter pcTypeContrat     as character no-undo.
    define input parameter piNumeroContrat   as int64     no-undo.

    define buffer desev for desev.
    define buffer tbfic for tbfic.
    define buffer gadet for gadet.
    define buffer evtev for evtev.  

message "trtDeleteDepEvent "  piNumeroEvenement "// " piNumeroContrat "// " pcTypeContrat.

blocTrans:
    do transaction:
        for each desev exclusive-lock  
            where desev.noeve = piNumeroEvenement:
            delete desev no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
        // todo  A repenser en mode GED ???
        for each tbfic exclusive-lock
            where tbfic.tpidt = {&TYPECONTRAT-evenement}
              and tbfic.noidt = piNumeroEvenement:
            os-delete value(tbfic.lbdiv).
            delete tbfic no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans. 
            end.
        end.
        for each gadet no-lock                           //gga todo a revoir, whole-index et tres long en test
            where gadet.tpctt = {&TYPECONTRAT-evenement}
              and gadet.noctt = piNumeroEvenement
              and gadet.tpct1 = pcTypeContrat
              and gadet.noct1 = piNumeroContrat:
            find current gadet exclusive-lock.
            delete gadet no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans. 
            end.
        end.
        for each evtev exclusive-lock
            where evtev.noev1 = piNumeroEvenement:
            delete evtev no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
// todo attention, wholeindex; Pas perturbant sur ma base (1 enregistrement), mais est-ce toujours le cas ?
        for each evtev exclusive-lock
            where evtev.noev2 = piNumeroEvenement:
            delete evtev no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.   
    end.
    error-status:error = false no-error.  // reset error-status
    
end procedure.

procedure deleteEventEtLienSurRole:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
             et des enregistrements des tables dependantes (desev, tbfic, gadet, evtev) 
    Notes  : service externe 
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeRole   as character no-undo.
    define input parameter piNumeroRole as int64     no-undo.

    define buffer vbEvent for event.
    define buffer evtev   for evtev.

message "deleteEventEtLienSurRole "  pcTypeRole "// " piNumeroRole.

blocTrans:
    do transaction:
        for each vbEvent exclusive-lock 
            where vbEvent.tprol = pcTypeRole
              and vbEvent.norol = piNumeroRole:
            for each evtev exclusive-lock
                where evtev.noev1 = vbEvent.noeve:
                delete evtev no-error.
                if error-status:error then do:
                    mError:createError({&error}, error-status:get-message(1)).
                    undo blocTrans, leave blocTrans.
                end.
            end.
// todo attention, wholeindex; Pas perturbant sur ma base (1 enregistrement), mais est-ce toujours le cas ?
            for each evtev exclusive-lock
                where evtev.noev2 = vbEvent.noeve:
                delete evtev no-error.
                if error-status:error then do:
                    mError:createError({&error}, error-status:get-message(1)).
                   undo blocTrans, leave blocTrans.
                end.
            end.
            delete vbEvent no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
