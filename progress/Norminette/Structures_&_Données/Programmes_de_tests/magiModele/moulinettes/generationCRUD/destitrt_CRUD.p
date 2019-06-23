/*------------------------------------------------------------------------
File        : destitrt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table destitrt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/destitrt.i}
{application/include/error.i}
define variable ghttdestitrt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTptrt as handle, output phNorol as handle, output phTpcon as handle, output phNocon as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tptrt/norol/tpcon/nocon, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tptrt' then phTptrt = phBuffer:buffer-field(vi).
            when 'norol' then phNorol = phBuffer:buffer-field(vi).
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudDestitrt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteDestitrt.
    run updateDestitrt.
    run createDestitrt.
end procedure.

procedure setDestitrt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttDestitrt.
    ghttDestitrt = phttDestitrt.
    run crudDestitrt.
    delete object phttDestitrt.
end procedure.

procedure readDestitrt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table destitrt 0108/0324 : envoi de copie CRG
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTptrt as character  no-undo.
    define input parameter piNorol as integer    no-undo.
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as int64      no-undo.
    define input parameter table-handle phttDestitrt.
    define variable vhttBuffer as handle no-undo.
    define buffer destitrt for destitrt.

    vhttBuffer = phttDestitrt:default-buffer-handle.
    for first destitrt no-lock
        where destitrt.tptrt = pcTptrt
          and destitrt.norol = piNorol
          and destitrt.tpcon = pcTpcon
          and destitrt.nocon = piNocon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer destitrt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDestitrt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getDestitrt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table destitrt 0108/0324 : envoi de copie CRG
    Notes  : service externe. Critère pcTpcon = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTptrt as character  no-undo.
    define input parameter piNorol as integer    no-undo.
    define input parameter pcTpcon as character  no-undo.
    define input parameter table-handle phttDestitrt.
    define variable vhttBuffer as handle  no-undo.
    define buffer destitrt for destitrt.

    vhttBuffer = phttDestitrt:default-buffer-handle.
    if pcTpcon = ?
    then for each destitrt no-lock
        where destitrt.tptrt = pcTptrt
          and destitrt.norol = piNorol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer destitrt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each destitrt no-lock
        where destitrt.tptrt = pcTptrt
          and destitrt.norol = piNorol
          and destitrt.tpcon = pcTpcon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer destitrt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDestitrt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateDestitrt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTptrt    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define buffer destitrt for destitrt.

    create query vhttquery.
    vhttBuffer = ghttDestitrt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttDestitrt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTptrt, output vhNorol, output vhTpcon, output vhNocon).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first destitrt exclusive-lock
                where rowid(destitrt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer destitrt:handle, 'tptrt/norol/tpcon/nocon: ', substitute('&1/&2/&3/&4', vhTptrt:buffer-value(), vhNorol:buffer-value(), vhTpcon:buffer-value(), vhNocon:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer destitrt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createDestitrt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer destitrt for destitrt.

    create query vhttquery.
    vhttBuffer = ghttDestitrt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttDestitrt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create destitrt.
            if not outils:copyValidField(buffer destitrt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteDestitrt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTptrt    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define buffer destitrt for destitrt.

    create query vhttquery.
    vhttBuffer = ghttDestitrt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttDestitrt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTptrt, output vhNorol, output vhTpcon, output vhNocon).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first destitrt exclusive-lock
                where rowid(Destitrt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer destitrt:handle, 'tptrt/norol/tpcon/nocon: ', substitute('&1/&2/&3/&4', vhTptrt:buffer-value(), vhNorol:buffer-value(), vhTpcon:buffer-value(), vhNocon:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete destitrt no-error.
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

