/*------------------------------------------------------------------------
File        : idetail_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table idetail
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/idetail.i}
{application/include/error.i}
define variable ghttidetail as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCddet as handle, output phNodet as handle, output phIddet as handle, output phIxd01 as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cddet/nodet/iddet/ixd01, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cddet' then phCddet = phBuffer:buffer-field(vi).
            when 'nodet' then phNodet = phBuffer:buffer-field(vi).
            when 'iddet' then phIddet = phBuffer:buffer-field(vi).
            when 'ixd01' then phIxd01 = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIdetail private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIdetail.
    run updateIdetail.
    run createIdetail.
end procedure.

procedure setIdetail:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIdetail.
    ghttIdetail = phttIdetail.
    run crudIdetail.
    delete object phttIdetail.
end procedure.

procedure readIdetail:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table idetail Table de détail des infos d'une paire Code-Num
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCddet as character  no-undo.
    define input parameter piNodet as integer    no-undo.
    define input parameter piIddet as integer    no-undo.
    define input parameter pcIxd01 as character  no-undo.
    define input parameter table-handle phttIdetail.
    define variable vhttBuffer as handle no-undo.
    define buffer idetail for idetail.

    vhttBuffer = phttIdetail:default-buffer-handle.
    for first idetail no-lock
        where idetail.cddet = pcCddet
          and idetail.nodet = piNodet
          and idetail.iddet = piIddet
          and idetail.ixd01 = pcIxd01:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer idetail:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIdetail no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIdetail:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table idetail Table de détail des infos d'une paire Code-Num
    Notes  : service externe. Critère piIddet = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcCddet as character  no-undo.
    define input parameter piNodet as integer    no-undo.
    define input parameter piIddet as integer    no-undo.
    define input parameter table-handle phttIdetail.
    define variable vhttBuffer as handle  no-undo.
    define buffer idetail for idetail.

    vhttBuffer = phttIdetail:default-buffer-handle.
    if piIddet = ?
    then for each idetail no-lock
        where idetail.cddet = pcCddet
          and idetail.nodet = piNodet:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer idetail:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each idetail no-lock
        where idetail.cddet = pcCddet
          and idetail.nodet = piNodet
          and idetail.iddet = piIddet:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer idetail:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIdetail no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIdetail private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCddet    as handle  no-undo.
    define variable vhNodet    as handle  no-undo.
    define variable vhIddet    as handle  no-undo.
    define variable vhIxd01    as handle  no-undo.
    define buffer idetail for idetail.

    create query vhttquery.
    vhttBuffer = ghttIdetail:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIdetail:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCddet, output vhNodet, output vhIddet, output vhIxd01).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first idetail exclusive-lock
                where rowid(idetail) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer idetail:handle, 'cddet/nodet/iddet/ixd01: ', substitute('&1/&2/&3/&4', vhCddet:buffer-value(), vhNodet:buffer-value(), vhIddet:buffer-value(), vhIxd01:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer idetail:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIdetail private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer idetail for idetail.

    create query vhttquery.
    vhttBuffer = ghttIdetail:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIdetail:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create idetail.
            if not outils:copyValidField(buffer idetail:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIdetail private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCddet    as handle  no-undo.
    define variable vhNodet    as handle  no-undo.
    define variable vhIddet    as handle  no-undo.
    define variable vhIxd01    as handle  no-undo.
    define buffer idetail for idetail.

    create query vhttquery.
    vhttBuffer = ghttIdetail:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIdetail:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCddet, output vhNodet, output vhIddet, output vhIxd01).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first idetail exclusive-lock
                where rowid(Idetail) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer idetail:handle, 'cddet/nodet/iddet/ixd01: ', substitute('&1/&2/&3/&4', vhCddet:buffer-value(), vhNodet:buffer-value(), vhIddet:buffer-value(), vhIxd01:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete idetail no-error.
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

