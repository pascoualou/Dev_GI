/*------------------------------------------------------------------------
File        : regul_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table regul
Author(s)   : generation automatique le 04/27/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttregul as handle no-undo.     // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNomdt as handle, output phNoloc as handle, output phNoper as handle, output phNorub as handle, output phNolib as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nomdt/noloc/noper/norub/nolib, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nomdt' then phNomdt = phBuffer:buffer-field(vi).
            when 'noloc' then phNoloc = phBuffer:buffer-field(vi).
            when 'noper' then phNoper = phBuffer:buffer-field(vi).
            when 'norub' then phNorub = phBuffer:buffer-field(vi).
            when 'nolib' then phNolib = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudRegul private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteRegul.
    run updateRegul.
    run createRegul.
end procedure.

procedure setRegul:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttRegul.
    ghttRegul = phttRegul.
    run crudRegul.
    delete object phttRegul.
end procedure.

procedure readRegul:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table regul 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNomdt as integer    no-undo.
    define input parameter piNoloc as int64      no-undo.
    define input parameter piNoper as integer    no-undo.
    define input parameter piNorub as integer    no-undo.
    define input parameter piNolib as integer    no-undo.
    define input parameter table-handle phttRegul.
    define variable vhttBuffer as handle no-undo.
    define buffer regul for regul.

    vhttBuffer = phttRegul:default-buffer-handle.
    for first regul no-lock
        where regul.nomdt = piNomdt
          and regul.noloc = piNoloc
          and regul.noper = piNoper
          and regul.norub = piNorub
          and regul.nolib = piNolib:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer regul:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRegul no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getRegul:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table regul 
    Notes  : service externe. Critère piNorub = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNomdt as integer    no-undo.
    define input parameter piNoloc as int64      no-undo.
    define input parameter piNoper as integer    no-undo.
    define input parameter piNorub as integer    no-undo.
    define input parameter table-handle phttRegul.
    define variable vhttBuffer as handle  no-undo.
    define buffer regul for regul.

    vhttBuffer = phttRegul:default-buffer-handle.
    if piNorub = ?
    then for each regul no-lock
        where regul.nomdt = piNomdt
          and regul.noloc = piNoloc
          and regul.noper = piNoper:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer regul:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each regul no-lock
        where regul.nomdt = piNomdt
          and regul.noloc = piNoloc
          and regul.noper = piNoper
          and regul.norub = piNorub:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer regul:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRegul no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateRegul private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNoloc    as handle  no-undo.
    define variable vhNoper    as handle  no-undo.
    define variable vhNorub    as handle  no-undo.
    define variable vhNolib    as handle  no-undo.
    define buffer regul for regul.

    create query vhttquery.
    vhttBuffer = ghttRegul:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttRegul:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomdt, output vhNoloc, output vhNoper, output vhNorub, output vhNolib).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first regul exclusive-lock
                where rowid(regul) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer regul:handle, 'nomdt/noloc/noper/norub/nolib: ', substitute('&1/&2/&3/&4/&5', vhNomdt:buffer-value(), vhNoloc:buffer-value(), vhNoper:buffer-value(), vhNorub:buffer-value(), vhNolib:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer regul:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createRegul private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer regul for regul.

    create query vhttquery.
    vhttBuffer = ghttRegul:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttRegul:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create regul.
            if not outils:copyValidField(buffer regul:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteRegul private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhNoloc    as handle  no-undo.
    define variable vhNoper    as handle  no-undo.
    define variable vhNorub    as handle  no-undo.
    define variable vhNolib    as handle  no-undo.
    define buffer regul for regul.

    create query vhttquery.
    vhttBuffer = ghttRegul:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttRegul:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomdt, output vhNoloc, output vhNoper, output vhNorub, output vhNolib).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first regul exclusive-lock
                where rowid(Regul) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer regul:handle, 'nomdt/noloc/noper/norub/nolib: ', substitute('&1/&2/&3/&4/&5', vhNomdt:buffer-value(), vhNoloc:buffer-value(), vhNoper:buffer-value(), vhNorub:buffer-value(), vhNolib:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete regul no-error.
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

procedure deleteRegulSurLocataire:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroLocataire as int64 no-undo.
    
    define buffer regul for regul.

message "deleteRegulSurLocataire "  piNumeroLocataire.

blocTrans:
    do transaction:
        for each regul no-lock   
           where regul.noloc = piNumeroLocataire:
            find current regul exclusive-lock.    
            delete regul no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.

procedure deleteRegulSurMandat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as integer no-undo.
    
    define buffer regul for regul.

message "deleteRegulSurMandat "  piNumeroMandat.

blocTrans:
    do transaction:
        for each regul exclusive-lock  
           where regul.nomdt = piNumeroMandat:
            delete regul no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.

