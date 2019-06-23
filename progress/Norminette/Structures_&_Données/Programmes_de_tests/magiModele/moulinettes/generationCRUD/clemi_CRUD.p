/*------------------------------------------------------------------------
File        : clemi_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table clemi
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/clemi.i}
{application/include/error.i}
define variable ghttclemi as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoimm as handle, output phNoord as handle, output phCdcle as handle, output phNorep as handle, output phTpcon as handle, output phNocon as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noimm/noord/cdcle/norep/tpcon/nocon, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noimm' then phNoimm = phBuffer:buffer-field(vi).
            when 'noord' then phNoord = phBuffer:buffer-field(vi).
            when 'cdcle' then phCdcle = phBuffer:buffer-field(vi).
            when 'norep' then phNorep = phBuffer:buffer-field(vi).
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudClemi private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteClemi.
    run updateClemi.
    run createClemi.
end procedure.

procedure setClemi:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttClemi.
    ghttClemi = phttClemi.
    run crudClemi.
    delete object phttClemi.
end procedure.

procedure readClemi:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table clemi 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoimm as integer    no-undo.
    define input parameter piNoord as integer    no-undo.
    define input parameter pcCdcle as character  no-undo.
    define input parameter piNorep as integer    no-undo.
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as integer    no-undo.
    define input parameter table-handle phttClemi.
    define variable vhttBuffer as handle no-undo.
    define buffer clemi for clemi.

    vhttBuffer = phttClemi:default-buffer-handle.
    for first clemi no-lock
        where clemi.noimm = piNoimm
          and clemi.noord = piNoord
          and clemi.cdcle = pcCdcle
          and clemi.norep = piNorep
          and clemi.tpcon = pcTpcon
          and clemi.nocon = piNocon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer clemi:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttClemi no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getClemi:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table clemi 
    Notes  : service externe. Critère pcTpcon = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoimm as integer    no-undo.
    define input parameter piNoord as integer    no-undo.
    define input parameter pcCdcle as character  no-undo.
    define input parameter piNorep as integer    no-undo.
    define input parameter pcTpcon as character  no-undo.
    define input parameter table-handle phttClemi.
    define variable vhttBuffer as handle  no-undo.
    define buffer clemi for clemi.

    vhttBuffer = phttClemi:default-buffer-handle.
    if pcTpcon = ?
    then for each clemi no-lock
        where clemi.noimm = piNoimm
          and clemi.noord = piNoord
          and clemi.cdcle = pcCdcle
          and clemi.norep = piNorep:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer clemi:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each clemi no-lock
        where clemi.noimm = piNoimm
          and clemi.noord = piNoord
          and clemi.cdcle = pcCdcle
          and clemi.norep = piNorep
          and clemi.tpcon = pcTpcon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer clemi:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttClemi no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateClemi private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define variable vhCdcle    as handle  no-undo.
    define variable vhNorep    as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define buffer clemi for clemi.

    create query vhttquery.
    vhttBuffer = ghttClemi:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttClemi:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoimm, output vhNoord, output vhCdcle, output vhNorep, output vhTpcon, output vhNocon).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first clemi exclusive-lock
                where rowid(clemi) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer clemi:handle, 'noimm/noord/cdcle/norep/tpcon/nocon: ', substitute('&1/&2/&3/&4/&5/&6', vhNoimm:buffer-value(), vhNoord:buffer-value(), vhCdcle:buffer-value(), vhNorep:buffer-value(), vhTpcon:buffer-value(), vhNocon:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer clemi:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createClemi private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer clemi for clemi.

    create query vhttquery.
    vhttBuffer = ghttClemi:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttClemi:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create clemi.
            if not outils:copyValidField(buffer clemi:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteClemi private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define variable vhCdcle    as handle  no-undo.
    define variable vhNorep    as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define buffer clemi for clemi.

    create query vhttquery.
    vhttBuffer = ghttClemi:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttClemi:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoimm, output vhNoord, output vhCdcle, output vhNorep, output vhTpcon, output vhNocon).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first clemi exclusive-lock
                where rowid(Clemi) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer clemi:handle, 'noimm/noord/cdcle/norep/tpcon/nocon: ', substitute('&1/&2/&3/&4/&5/&6', vhNoimm:buffer-value(), vhNoord:buffer-value(), vhCdcle:buffer-value(), vhNorep:buffer-value(), vhTpcon:buffer-value(), vhNocon:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete clemi no-error.
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

