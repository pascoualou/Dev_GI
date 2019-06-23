/*------------------------------------------------------------------------
File        : irep_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table irep
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/irep.i}
{application/include/error.i}
define variable ghttirep as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phRep-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/rep-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'rep-cle' then phRep-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIrep private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIrep.
    run updateIrep.
    run createIrep.
end procedure.

procedure setIrep:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIrep.
    ghttIrep = phttIrep.
    run crudIrep.
    delete object phttIrep.
end procedure.

procedure readIrep:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table irep Fichier Representant
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter pcRep-cle as character  no-undo.
    define input parameter table-handle phttIrep.
    define variable vhttBuffer as handle no-undo.
    define buffer irep for irep.

    vhttBuffer = phttIrep:default-buffer-handle.
    for first irep no-lock
        where irep.soc-cd = piSoc-cd
          and irep.rep-cle = pcRep-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer irep:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIrep no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIrep:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table irep Fichier Representant
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter table-handle phttIrep.
    define variable vhttBuffer as handle  no-undo.
    define buffer irep for irep.

    vhttBuffer = phttIrep:default-buffer-handle.
    if piSoc-cd = ?
    then for each irep no-lock
        where irep.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer irep:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each irep no-lock
        where irep.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer irep:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIrep no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIrep private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhRep-cle    as handle  no-undo.
    define buffer irep for irep.

    create query vhttquery.
    vhttBuffer = ghttIrep:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIrep:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhRep-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first irep exclusive-lock
                where rowid(irep) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer irep:handle, 'soc-cd/rep-cle: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhRep-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer irep:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIrep private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer irep for irep.

    create query vhttquery.
    vhttBuffer = ghttIrep:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIrep:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create irep.
            if not outils:copyValidField(buffer irep:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIrep private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhRep-cle    as handle  no-undo.
    define buffer irep for irep.

    create query vhttquery.
    vhttBuffer = ghttIrep:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIrep:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhRep-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first irep exclusive-lock
                where rowid(Irep) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer irep:handle, 'soc-cd/rep-cle: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhRep-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete irep no-error.
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

