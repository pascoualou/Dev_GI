/*------------------------------------------------------------------------
File        : aspno_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table aspno
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/aspno.i}
{application/include/error.i}
define variable ghttaspno as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phNoord as handle, output phNolot as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpcon/nocon/noord/nolot, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
            when 'noord' then phNoord = phBuffer:buffer-field(vi).
            when 'nolot' then phNolot = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAspno private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAspno.
    run updateAspno.
    run createAspno.
end procedure.

procedure setAspno:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAspno.
    ghttAspno = phttAspno.
    run crudAspno.
    delete object phttAspno.
end procedure.

procedure readAspno:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table aspno assurance propriétaire non occupant
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as int64      no-undo.
    define input parameter piNoord as integer    no-undo.
    define input parameter piNolot as integer    no-undo.
    define input parameter table-handle phttAspno.
    define variable vhttBuffer as handle no-undo.
    define buffer aspno for aspno.

    vhttBuffer = phttAspno:default-buffer-handle.
    for first aspno no-lock
        where aspno.tpcon = pcTpcon
          and aspno.nocon = piNocon
          and aspno.noord = piNoord
          and aspno.nolot = piNolot:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aspno:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAspno no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAspno:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table aspno assurance propriétaire non occupant
    Notes  : service externe. Critère piNoord = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as int64      no-undo.
    define input parameter piNoord as integer    no-undo.
    define input parameter table-handle phttAspno.
    define variable vhttBuffer as handle  no-undo.
    define buffer aspno for aspno.

    vhttBuffer = phttAspno:default-buffer-handle.
    if piNoord = ?
    then for each aspno no-lock
        where aspno.tpcon = pcTpcon
          and aspno.nocon = piNocon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aspno:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each aspno no-lock
        where aspno.tpcon = pcTpcon
          and aspno.nocon = piNocon
          and aspno.noord = piNoord:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aspno:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAspno no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAspno private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define buffer aspno for aspno.

    create query vhttquery.
    vhttBuffer = ghttAspno:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAspno:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNoord, output vhNolot).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first aspno exclusive-lock
                where rowid(aspno) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer aspno:handle, 'tpcon/nocon/noord/nolot: ', substitute('&1/&2/&3/&4', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhNoord:buffer-value(), vhNolot:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer aspno:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAspno private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer aspno for aspno.

    create query vhttquery.
    vhttBuffer = ghttAspno:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAspno:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create aspno.
            if not outils:copyValidField(buffer aspno:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAspno private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define buffer aspno for aspno.

    create query vhttquery.
    vhttBuffer = ghttAspno:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAspno:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNoord, output vhNolot).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first aspno exclusive-lock
                where rowid(Aspno) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer aspno:handle, 'tpcon/nocon/noord/nolot: ', substitute('&1/&2/&3/&4', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhNoord:buffer-value(), vhNolot:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete aspno no-error.
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

