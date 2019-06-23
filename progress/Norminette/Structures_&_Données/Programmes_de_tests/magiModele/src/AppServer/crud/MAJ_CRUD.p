/*------------------------------------------------------------------------
File        : MAJ_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table MAJ
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
derniere revue: 2018/09/13 - phm: OK
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttMAJ as handle no-undo.       // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phNmlog as handle, output phSoc-cd as handle, output phNmtab as handle, output phCdenr as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur NMLOG/soc-cd/NMTAB/CDENR, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nmlog'  then phNmlog  = phBuffer:buffer-field(vi).
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'nmtab'  then phNmtab  = phBuffer:buffer-field(vi).
            when 'cdenr'  then phCdenr  = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudMaj private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteMaj.
    run updateMaj.
    run createMaj.
end procedure.

procedure setMaj:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttMaj.
    ghttMaj = phttMaj.
    run crudMaj.
    delete object phttMaj.
end procedure.

procedure readMaj:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table MAJ 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcNmlog  as character no-undo.
    define input parameter piSoc-cd as integer   no-undo.
    define input parameter pcNmtab  as character no-undo.
    define input parameter pcCdenr  as character no-undo.
    define input parameter table-handle phttMaj.

    define variable vhttBuffer as handle no-undo.
    define buffer maj for maj.

    vhttBuffer = phttMaj:default-buffer-handle.
    for first maj no-lock
        where maj.nmlog = pcNmlog
          and maj.soc-cd = piSoc-cd
          and maj.nmtab = pcNmtab
          and maj.cdenr = pcCdenr:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer maj:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttMaj no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getMaj:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table MAJ 
    Notes  : service externe. Critère pcNmtab = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcNmlog  as character no-undo.
    define input parameter piSoc-cd as integer   no-undo.
    define input parameter pcNmtab  as character no-undo.
    define input parameter table-handle phttMaj.

    define variable vhttBuffer as handle  no-undo.
    define buffer maj for maj.

    vhttBuffer = phttMaj:default-buffer-handle.
    if pcNmtab = ?
    then for each maj no-lock
        where maj.nmlog = pcNmlog
          and maj.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer maj:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each maj no-lock
        where maj.nmlog = pcNmlog
          and maj.soc-cd = piSoc-cd
          and maj.nmtab = pcNmtab:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer maj:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttMaj no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateMaj private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNmlog    as handle  no-undo.
    define variable vhSoc-cd   as handle  no-undo.
    define variable vhNmtab    as handle  no-undo.
    define variable vhCdenr    as handle  no-undo.
    define buffer maj for maj.

    create query vhttquery.
    vhttBuffer = ghttMaj:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttMaj:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNmlog, output vhSoc-cd, output vhNmtab, output vhCdenr).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first maj exclusive-lock
                where rowid(maj) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer maj:handle, 'nmlog/soc-cd/nmtab/cdenr: ', substitute('&1/&2/&3/&4', vhNmlog:buffer-value(), vhSoc-cd:buffer-value(), vhNmtab:buffer-value(), vhCdenr:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer MAJ:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createMaj private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer maj for maj.

    create query vhttquery.
    vhttBuffer = ghttMaj:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttMaj:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create maj.
            if not outils:copyValidField(buffer maj:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteMaj private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNmlog    as handle  no-undo.
    define variable vhSoc-cd   as handle  no-undo.
    define variable vhNmtab    as handle  no-undo.
    define variable vhCdenr    as handle  no-undo.
    define buffer maj for maj.

    create query vhttquery.
    vhttBuffer = ghttMaj:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttMaj:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNmlog, output vhSoc-cd, output vhNmtab, output vhCdenr).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first maj exclusive-lock
                where rowid(Maj) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer maj:handle, 'nmlog/soc-cd/nmtab/cdenr: ', substitute('&1/&2/&3/&4', vhNmlog:buffer-value(), vhSoc-cd:buffer-value(), vhNmtab:buffer-value(), vhCdenr:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete maj no-error.
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
