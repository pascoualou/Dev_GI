/*------------------------------------------------------------------------
File        : Event_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table Event
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/Event.i}
{application/include/error.i}
define variable ghttEvent as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoeve as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur NoEve, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'NoEve' then phNoeve = phBuffer:buffer-field(vi).
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
    define buffer Event for Event.

    vhttBuffer = phttEvent:default-buffer-handle.
    for first Event no-lock
        where Event.NoEve = piNoeve:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer Event:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEvent no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getEvent:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table Event 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttEvent.
    define variable vhttBuffer as handle  no-undo.
    define buffer Event for Event.

    vhttBuffer = phttEvent:default-buffer-handle.
    for each Event no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer Event:handle, vhttBuffer).  // copy table physique vers temp-table
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
    define buffer Event for Event.

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

            find first Event exclusive-lock
                where rowid(Event) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer Event:handle, 'NoEve: ', substitute('&1', vhNoeve:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer Event:handle, vhttBuffer, "U", mtoken:cUser)
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
    define buffer Event for Event.

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

            create Event.
            if not outils:copyValidField(buffer Event:handle, vhttBuffer, "C", mtoken:cUser)
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
    define buffer Event for Event.

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

            find first Event exclusive-lock
                where rowid(Event) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer Event:handle, 'NoEve: ', substitute('&1', vhNoeve:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete Event no-error.
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

    define variable CpUseInc as integer no-undo.  

    define buffer event for event.

message "deleteEventParType "  pcTypetrt "// " piNumeroDocument "// " pcTypeRole "// " piNumeroRole.

blocTrans:
    do transaction:
        case pcTypetrt:
            when "DOCUM" 
            then do:
                for each event exclusive-lock  
                   where event.nodoc = piNumeroDocument:
                    run trtDeleteDepEvent (event.noeve, event.tpcon, event.nocon).
                    if mError:erreur()
                    then undo blocTrans, leave blocTrans.                    
                    delete event no-error.
                    if error-status:error then do:
                        mError:createError({&error}, error-status:get-message(1)).
                        undo blocTrans, leave blocTrans. 
                    end.               
                end.
            end.    
            when "SSDOS" 
            then do:
                for each event exclusive-lock  
                   where event.nossd = piNumeroDocument
                     and event.tprol = pcTypeRole
                     and event.norol = piNumeroRole:
                    run trtDeleteDepEvent (event.noeve, event.tpcon, event.nocon).
                    if mError:erreur()
                    then undo blocTrans, leave blocTrans.                    
                    delete event no-error.
                    if error-status:error then do:
                        mError:createError({&error}, error-status:get-message(1)).
                        undo blocTrans, leave blocTrans. 
                    end.                                   
                end.
            end.
            otherwise do: 
                CpUseInc = integer(pcTypeRole) no-error.
                if error-status:error or CpUseInc > 0 and CpUseInc < 1000 
                then do:
                    for each event exclusive-lock  
                       where event.tprol = pcTypeRole
                         and event.norol = piNumeroRole:
                        run trtDeleteDepEvent (event.noeve, event.tpcon, event.nocon).
                        if mError:erreur()
                        then undo blocTrans, leave blocTrans.                    
                        delete event no-error.
                        if error-status:error then do:
                            mError:createError({&error}, error-status:get-message(1)).
                            undo blocTrans, leave blocTrans. 
                        end.               
                    end.
                end.
                else do:
                    if CpUseInc > 1000 and CpUseInc < 2000 
                    then do:
                        for each event exclusive-lock
                           where event.tpcon = pcTypeRole
                             and event.nocon = piNumeroRole:
                            run trtDeleteDepEvent (event.noeve, event.tpcon, event.nocon).
                            if mError:erreur()
                            then undo blocTrans, leave blocTrans.                    
                            delete event no-error.
                            if error-status:error then do:
                                mError:createError({&error}, error-status:get-message(1)).
                                undo blocTrans, leave blocTrans. 
                            end.                                           
                        end.
                    end.
                    else do:
                        if CpUseInc = 2001 
                        then do:
                            for each event exclusive-lock
                               where event.noimm = piNumeroRole:
                                run trtDeleteDepEvent (event.noeve, event.tpcon, event.nocon).
                                if mError:erreur()
                                then undo blocTrans, leave blocTrans.                    
                                delete event no-error.
                                if error-status:error then do:
                                    mError:createError({&error}, error-status:get-message(1)).
                                    undo blocTrans, leave blocTrans. 
                                end.                                           
                            end.
                        end.
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
    def input parameter piNumeroEvenement as int64     no-undo.
    def input parameter pcTypeContrat     as character no-undo.
    def input parameter piNumeroContrat   as int64     no-undo.

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
        for each tbfic exclusive-lock
           where tbfic.tpidt = "01088"
             and tbfic.noidt = piNumeroEvenement:
            os-delete value(tbfic.lbdiv).
            delete tbfic no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans. 
            end.                           
        end.
        for each gadet no-lock                           //gga todo a revoir, pas un index et tres long en test
           where gadet.tpctt = "01088"
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
    define input parameter pcTypeRole       as character no-undo.
    define input parameter piNumeroRole     as int64     no-undo.

    define buffer event for event.
    define buffer evtev for evtev.

message "deleteEventEtLienSurRole "  pcTypeRole "// " piNumeroRole.

blocTrans:
    do transaction:
        for each event exclusive-lock 
           where event.tprol = pcTypeRole
             and event.norol = piNumeroRole:
            for each evtev exclusive-lock
               where evtev.noev1 = event.NoEve:
                delete evtev no-error.
                if error-status:error then do:
                    mError:createError({&error}, error-status:get-message(1)).
                   undo blocTrans, leave blocTrans.
                end.
            end.
            for each evtev exclusive-lock
               where evtev.noev2 = event.NoEve:
                delete evtev no-error.
                if error-status:error then do:
                    mError:createError({&error}, error-status:get-message(1)).
                   undo blocTrans, leave blocTrans.
                end.
            end.   
            delete event no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.    
    end.               
    error-status:error = false no-error.  // reset error-status

end procedure.
