/*------------------------------------------------------------------------
File        : iprof_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iprof
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/iprof.i}
{application/include/error.i}
define variable ghttiprof as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phProf-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/prof-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'prof-cle' then phProf-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIprof private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIprof.
    run updateIprof.
    run createIprof.
end procedure.

procedure setIprof:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIprof.
    ghttIprof = phttIprof.
    run crudIprof.
    delete object phttIprof.
end procedure.

procedure readIprof:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iprof Profession
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter pcProf-cle as character  no-undo.
    define input parameter table-handle phttIprof.
    define variable vhttBuffer as handle no-undo.
    define buffer iprof for iprof.

    vhttBuffer = phttIprof:default-buffer-handle.
    for first iprof no-lock
        where iprof.soc-cd = piSoc-cd
          and iprof.prof-cle = pcProf-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iprof:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIprof no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIprof:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iprof Profession
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter table-handle phttIprof.
    define variable vhttBuffer as handle  no-undo.
    define buffer iprof for iprof.

    vhttBuffer = phttIprof:default-buffer-handle.
    if piSoc-cd = ?
    then for each iprof no-lock
        where iprof.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iprof:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each iprof no-lock
        where iprof.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iprof:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIprof no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIprof private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhProf-cle    as handle  no-undo.
    define buffer iprof for iprof.

    create query vhttquery.
    vhttBuffer = ghttIprof:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIprof:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhProf-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iprof exclusive-lock
                where rowid(iprof) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iprof:handle, 'soc-cd/prof-cle: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhProf-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iprof:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIprof private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iprof for iprof.

    create query vhttquery.
    vhttBuffer = ghttIprof:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIprof:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iprof.
            if not outils:copyValidField(buffer iprof:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIprof private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhProf-cle    as handle  no-undo.
    define buffer iprof for iprof.

    create query vhttquery.
    vhttBuffer = ghttIprof:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIprof:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhProf-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iprof exclusive-lock
                where rowid(Iprof) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iprof:handle, 'soc-cd/prof-cle: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhProf-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iprof no-error.
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

