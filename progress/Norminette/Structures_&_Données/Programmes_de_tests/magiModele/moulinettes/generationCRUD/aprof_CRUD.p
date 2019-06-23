/*------------------------------------------------------------------------
File        : aprof_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table aprof
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/aprof.i}
{application/include/error.i}
define variable ghttaprof as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phProfil-cd as handle, output phMandatdeb as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur profil-cd/mandatdeb, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'profil-cd' then phProfil-cd = phBuffer:buffer-field(vi).
            when 'mandatdeb' then phMandatdeb = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAprof private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAprof.
    run updateAprof.
    run createAprof.
end procedure.

procedure setAprof:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAprof.
    ghttAprof = phttAprof.
    run crudAprof.
    delete object phttAprof.
end procedure.

procedure readAprof:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table aprof 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piProfil-cd as integer    no-undo.
    define input parameter piMandatdeb as integer    no-undo.
    define input parameter table-handle phttAprof.
    define variable vhttBuffer as handle no-undo.
    define buffer aprof for aprof.

    vhttBuffer = phttAprof:default-buffer-handle.
    for first aprof no-lock
        where aprof.profil-cd = piProfil-cd
          and aprof.mandatdeb = piMandatdeb:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aprof:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAprof no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAprof:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table aprof 
    Notes  : service externe. Critère piProfil-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piProfil-cd as integer    no-undo.
    define input parameter table-handle phttAprof.
    define variable vhttBuffer as handle  no-undo.
    define buffer aprof for aprof.

    vhttBuffer = phttAprof:default-buffer-handle.
    if piProfil-cd = ?
    then for each aprof no-lock
        where aprof.profil-cd = piProfil-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aprof:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each aprof no-lock
        where aprof.profil-cd = piProfil-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aprof:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAprof no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAprof private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhProfil-cd    as handle  no-undo.
    define variable vhMandatdeb    as handle  no-undo.
    define buffer aprof for aprof.

    create query vhttquery.
    vhttBuffer = ghttAprof:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAprof:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhProfil-cd, output vhMandatdeb).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first aprof exclusive-lock
                where rowid(aprof) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer aprof:handle, 'profil-cd/mandatdeb: ', substitute('&1/&2', vhProfil-cd:buffer-value(), vhMandatdeb:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer aprof:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAprof private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer aprof for aprof.

    create query vhttquery.
    vhttBuffer = ghttAprof:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAprof:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create aprof.
            if not outils:copyValidField(buffer aprof:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAprof private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhProfil-cd    as handle  no-undo.
    define variable vhMandatdeb    as handle  no-undo.
    define buffer aprof for aprof.

    create query vhttquery.
    vhttBuffer = ghttAprof:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAprof:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhProfil-cd, output vhMandatdeb).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first aprof exclusive-lock
                where rowid(Aprof) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer aprof:handle, 'profil-cd/mandatdeb: ', substitute('&1/&2', vhProfil-cd:buffer-value(), vhMandatdeb:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete aprof no-error.
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

