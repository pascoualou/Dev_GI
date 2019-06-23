/*------------------------------------------------------------------------
File        : ctctt_CRUD.p
Purpose     : maj de la tables des liens contrat - contrat
Author(s)   : GGA  -  2017/12/22
Notes       : 
derniere revue: 2018/04/27 - phm: OK
------------------------------------------------------------------------*/

{preprocesseur/type2contrat.i}

{oerealm/include/instanciateTokenOnModel.i}       // Doit être positionnée juste après using
define variable ghttctctt as handle no-undo.      // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phTpct1 as handle, output phNoct1 as handle, output phTpct2 as handle, output phNoct2 as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpct1/noct1/tpct2/noct2, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpct1' then phTpct1 = phBuffer:buffer-field(vi).
            when 'noct1' then phNoct1 = phBuffer:buffer-field(vi).
            when 'tpct2' then phTpct2 = phBuffer:buffer-field(vi).
            when 'noct2' then phNoct2 = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCtctt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCtctt.
    run updateCtctt.
    run createCtctt.
end procedure.

procedure setCtctt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCtctt.
    ghttCtctt = phttCtctt.
    run crudCtctt.
    delete object phttCtctt.
end procedure.

procedure readCtctt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ctctt 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpct1 as character no-undo.
    define input parameter piNoct1 as int64     no-undo.
    define input parameter pcTpct2 as character no-undo.
    define input parameter piNoct2 as int64     no-undo.
    define input parameter table-handle phttCtctt.
    define variable vhttBuffer as handle no-undo.
    define buffer ctctt for ctctt.

    vhttBuffer = phttCtctt:default-buffer-handle.
    for first ctctt no-lock
        where ctctt.tpct1 = pcTpct1
          and ctctt.noct1 = piNoct1
          and ctctt.tpct2 = pcTpct2
          and ctctt.noct2 = piNoct2:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ctctt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCtctt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCtctt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ctctt 
    Notes  : service externe. Critère pcTpct2 = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpct1 as character no-undo.
    define input parameter piNoct1 as int64     no-undo.
    define input parameter pcTpct2 as character no-undo.
    define input parameter table-handle phttCtctt.

    define variable vhttBuffer as handle  no-undo.
    define buffer ctctt for ctctt.

    vhttBuffer = phttCtctt:default-buffer-handle.
    if pcTpct2 = ?
    then for each ctctt no-lock
        where ctctt.tpct1 = pcTpct1
          and ctctt.noct1 = piNoct1:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ctctt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ctctt no-lock
        where ctctt.tpct1 = pcTpct1
          and ctctt.noct1 = piNoct1
          and ctctt.tpct2 = pcTpct2:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ctctt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCtctt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCtctt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpct1    as handle  no-undo.
    define variable vhNoct1    as handle  no-undo.
    define variable vhTpct2    as handle  no-undo.
    define variable vhNoct2    as handle  no-undo.
    define buffer ctctt for ctctt.

    create query vhttquery.
    vhttBuffer = ghttCtctt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCtctt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpct1, output vhNoct1, output vhTpct2, output vhNoct2).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ctctt exclusive-lock
                where rowid(ctctt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ctctt:handle, 'tpct1/noct1/tpct2/noct2: ', substitute('&1/&2/&3/&4', vhTpct1:buffer-value(), vhNoct1:buffer-value(), vhTpct2:buffer-value(), vhNoct2:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ctctt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCtctt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer ctctt for ctctt.

    create query vhttquery.
    vhttBuffer = ghttCtctt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCtctt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ctctt.
            if not outils:copyValidField(buffer ctctt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCtctt private:
    /*------------------------------------------------------------------------------
    Purpose:(appel depuis les differents pgms de maintenance tache)
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpct1    as handle  no-undo.
    define variable vhNoct1    as handle  no-undo.
    define variable vhTpct2    as handle  no-undo.
    define variable vhNoct2    as handle  no-undo.
    define buffer ctctt for ctctt.

    create query vhttquery.
    vhttBuffer = ghttCtctt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCtctt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpct1, output vhNoct1, output vhTpct2, output vhNoct2).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ctctt exclusive-lock
                where rowid(Ctctt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ctctt:handle, 'tpct1/noct1/tpct2/noct2: ', substitute('&1/&2/&3/&4', vhTpct1:buffer-value(), vhNoct1:buffer-value(), vhTpct2:buffer-value(), vhNoct2:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ctctt no-error.
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

procedure deleteCtcttSurCle:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContratPrincipal    as character no-undo.
    define input parameter piNumeroContratPrincipal  as int64     no-undo.
    define input parameter pcTypeContratSecondaire   as character no-undo.
    define input parameter piNumeroContratSecondaire as int64     no-undo.
    
    define buffer ctctt for ctctt.

blocTrans:
    do transaction:
        for each ctctt exclusive-lock  
           where ctctt.tpct1 = pcTypeContratPrincipal
             and ctctt.noct1 = piNumeroContratPrincipal
             and ctctt.tpct2 = pcTypeContratSecondaire
             and ctctt.noct2 = piNumeroContratSecondaire:
            delete ctctt no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.

procedure deleteCtcttSurContratPrincipal:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContratPrincipal   as character no-undo.
    define input parameter piNumeroContratPrincipal as int64     no-undo.
    
    define buffer ctctt for ctctt.

blocTrans:
    do transaction:
        for each ctctt exclusive-lock  
           where ctctt.tpct1 = pcTypeContratPrincipal
             and ctctt.noct1 = piNumeroContratPrincipal:
            delete ctctt no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.

procedure deleteCtcttSurContratSecondaire:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContratSecondaire   as character no-undo.
    define input parameter piNumeroContratSecondaire as int64     no-undo.
    
    define buffer ctctt for ctctt.

blocTrans:
    do transaction:
        for each ctctt exclusive-lock  
           where ctctt.tpct2 = pcTypeContratSecondaire
             and ctctt.noct2 = piNumeroContratSecondaire:
            delete ctctt no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.

procedure deleteContratCommerciaux:
    /*------------------------------------------------------------------------------
    Purpose: Suppression Mandat-UL utilisé pour les commerciaux.
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContratPrincipal   as character no-undo.
    define input parameter piNumeroContratPrincipal as int64     no-undo.
    
    define buffer ctctt for ctctt.
    define buffer ctrat for ctrat.
    define buffer intnt for intnt.

blocTrans:
    do transaction:
        for each ctctt exclusive-lock  
           where ctctt.tpct1 = pcTypeContratPrincipal
             and ctctt.noct1 = piNumeroContratPrincipal
             and ctctt.tpct2 = {&TYPECONTRAT-Mandat-UL}:
            for each ctrat exclusive-lock
               where ctrat.tpcon = ctctt.tpct2
                 and ctrat.nocon = ctctt.noct2:
                delete ctrat no-error.
                if error-status:error then do:
                    mError:createError({&error}, error-status:get-message(1)).
                    undo blocTrans, leave blocTrans.
                end.
            end.
            for each intnt exclusive-lock
               where intnt.tpidt = "00072"
                 and intnt.tpcon = ctctt.tpct2
                 and intnt.nocon = ctctt.noct2:
                delete intnt no-error.
                if error-status:error then do:
                    mError:createError({&error}, error-status:get-message(1)).
                    undo blocTrans, leave blocTrans.
                end.                
            end.
            delete ctctt no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
