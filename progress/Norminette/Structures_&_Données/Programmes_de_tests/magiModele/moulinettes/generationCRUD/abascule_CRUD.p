/*------------------------------------------------------------------------
File        : abascule_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table abascule
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/abascule.i}
{application/include/error.i}
define variable ghttabascule as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAbascule private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAbascule.
    run updateAbascule.
    run createAbascule.
end procedure.

procedure setAbascule:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAbascule.
    ghttAbascule = phttAbascule.
    run crudAbascule.
    delete object phttAbascule.
end procedure.

procedure readAbascule:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table abascule Informations relatives à la bascule nouveau decret comptable
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd as integer    no-undo.
    define input parameter table-handle phttAbascule.
    define variable vhttBuffer as handle no-undo.
    define buffer abascule for abascule.

    vhttBuffer = phttAbascule:default-buffer-handle.
    for first abascule no-lock
        where abascule.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer abascule:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAbascule no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAbascule:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table abascule Informations relatives à la bascule nouveau decret comptable
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAbascule.
    define variable vhttBuffer as handle  no-undo.
    define buffer abascule for abascule.

    vhttBuffer = phttAbascule:default-buffer-handle.
    for each abascule no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer abascule:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAbascule no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAbascule private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define buffer abascule for abascule.

    create query vhttquery.
    vhttBuffer = ghttAbascule:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAbascule:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first abascule exclusive-lock
                where rowid(abascule) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer abascule:handle, 'soc-cd: ', substitute('&1', vhSoc-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer abascule:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAbascule private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer abascule for abascule.

    create query vhttquery.
    vhttBuffer = ghttAbascule:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAbascule:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create abascule.
            if not outils:copyValidField(buffer abascule:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAbascule private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define buffer abascule for abascule.

    create query vhttquery.
    vhttBuffer = ghttAbascule:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAbascule:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first abascule exclusive-lock
                where rowid(Abascule) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer abascule:handle, 'soc-cd: ', substitute('&1', vhSoc-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete abascule no-error.
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

