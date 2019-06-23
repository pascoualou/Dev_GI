/*------------------------------------------------------------------------
File        : irelniv_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table irelniv
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/irelniv.i}
{application/include/error.i}
define variable ghttirelniv as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phRgt-cd as handle, output phRelan-niv as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/rgt-cd/relan-niv, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'rgt-cd' then phRgt-cd = phBuffer:buffer-field(vi).
            when 'relan-niv' then phRelan-niv = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIrelniv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIrelniv.
    run updateIrelniv.
    run createIrelniv.
end procedure.

procedure setIrelniv:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIrelniv.
    ghttIrelniv = phttIrelniv.
    run crudIrelniv.
    delete object phttIrelniv.
end procedure.

procedure readIrelniv:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table irelniv Niveaux de relance par groupe
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcRgt-cd    as character  no-undo.
    define input parameter piRelan-niv as integer    no-undo.
    define input parameter table-handle phttIrelniv.
    define variable vhttBuffer as handle no-undo.
    define buffer irelniv for irelniv.

    vhttBuffer = phttIrelniv:default-buffer-handle.
    for first irelniv no-lock
        where irelniv.soc-cd = piSoc-cd
          and irelniv.etab-cd = piEtab-cd
          and irelniv.rgt-cd = pcRgt-cd
          and irelniv.relan-niv = piRelan-niv:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer irelniv:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIrelniv no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIrelniv:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table irelniv Niveaux de relance par groupe
    Notes  : service externe. Critère pcRgt-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcRgt-cd    as character  no-undo.
    define input parameter table-handle phttIrelniv.
    define variable vhttBuffer as handle  no-undo.
    define buffer irelniv for irelniv.

    vhttBuffer = phttIrelniv:default-buffer-handle.
    if pcRgt-cd = ?
    then for each irelniv no-lock
        where irelniv.soc-cd = piSoc-cd
          and irelniv.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer irelniv:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each irelniv no-lock
        where irelniv.soc-cd = piSoc-cd
          and irelniv.etab-cd = piEtab-cd
          and irelniv.rgt-cd = pcRgt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer irelniv:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIrelniv no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIrelniv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhRgt-cd    as handle  no-undo.
    define variable vhRelan-niv    as handle  no-undo.
    define buffer irelniv for irelniv.

    create query vhttquery.
    vhttBuffer = ghttIrelniv:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIrelniv:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhRgt-cd, output vhRelan-niv).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first irelniv exclusive-lock
                where rowid(irelniv) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer irelniv:handle, 'soc-cd/etab-cd/rgt-cd/relan-niv: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhRgt-cd:buffer-value(), vhRelan-niv:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer irelniv:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIrelniv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer irelniv for irelniv.

    create query vhttquery.
    vhttBuffer = ghttIrelniv:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIrelniv:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create irelniv.
            if not outils:copyValidField(buffer irelniv:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIrelniv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhRgt-cd    as handle  no-undo.
    define variable vhRelan-niv    as handle  no-undo.
    define buffer irelniv for irelniv.

    create query vhttquery.
    vhttBuffer = ghttIrelniv:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIrelniv:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhRgt-cd, output vhRelan-niv).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first irelniv exclusive-lock
                where rowid(Irelniv) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer irelniv:handle, 'soc-cd/etab-cd/rgt-cd/relan-niv: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhRgt-cd:buffer-value(), vhRelan-niv:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete irelniv no-error.
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

