/*------------------------------------------------------------------------
File        : acdbar_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table acdbar
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/acdbar.i}
{application/include/error.i}
define variable ghttacdbar as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpcb-cd as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phSscpt-cd as handle, output phIndex-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpcb-cd/soc-cd/etab-cd/sscpt-cd/index-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpcb-cd' then phTpcb-cd = phBuffer:buffer-field(vi).
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'sscpt-cd' then phSscpt-cd = phBuffer:buffer-field(vi).
            when 'index-cd' then phIndex-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAcdbar private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAcdbar.
    run updateAcdbar.
    run createAcdbar.
end procedure.

procedure setAcdbar:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAcdbar.
    ghttAcdbar = phttAcdbar.
    run crudAcdbar.
    delete object phttAcdbar.
end procedure.

procedure readAcdbar:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table acdbar 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piTpcb-cd  as integer    no-undo.
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter pcSscpt-cd as character  no-undo.
    define input parameter piIndex-cd as integer    no-undo.
    define input parameter table-handle phttAcdbar.
    define variable vhttBuffer as handle no-undo.
    define buffer acdbar for acdbar.

    vhttBuffer = phttAcdbar:default-buffer-handle.
    for first acdbar no-lock
        where acdbar.tpcb-cd = piTpcb-cd
          and acdbar.soc-cd = piSoc-cd
          and acdbar.etab-cd = piEtab-cd
          and acdbar.sscpt-cd = pcSscpt-cd
          and acdbar.index-cd = piIndex-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer acdbar:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAcdbar no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAcdbar:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table acdbar 
    Notes  : service externe. Critère pcSscpt-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piTpcb-cd  as integer    no-undo.
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter pcSscpt-cd as character  no-undo.
    define input parameter table-handle phttAcdbar.
    define variable vhttBuffer as handle  no-undo.
    define buffer acdbar for acdbar.

    vhttBuffer = phttAcdbar:default-buffer-handle.
    if pcSscpt-cd = ?
    then for each acdbar no-lock
        where acdbar.tpcb-cd = piTpcb-cd
          and acdbar.soc-cd = piSoc-cd
          and acdbar.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer acdbar:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each acdbar no-lock
        where acdbar.tpcb-cd = piTpcb-cd
          and acdbar.soc-cd = piSoc-cd
          and acdbar.etab-cd = piEtab-cd
          and acdbar.sscpt-cd = pcSscpt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer acdbar:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAcdbar no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAcdbar private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcb-cd    as handle  no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhSscpt-cd    as handle  no-undo.
    define variable vhIndex-cd    as handle  no-undo.
    define buffer acdbar for acdbar.

    create query vhttquery.
    vhttBuffer = ghttAcdbar:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAcdbar:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcb-cd, output vhSoc-cd, output vhEtab-cd, output vhSscpt-cd, output vhIndex-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first acdbar exclusive-lock
                where rowid(acdbar) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer acdbar:handle, 'tpcb-cd/soc-cd/etab-cd/sscpt-cd/index-cd: ', substitute('&1/&2/&3/&4/&5', vhTpcb-cd:buffer-value(), vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhSscpt-cd:buffer-value(), vhIndex-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer acdbar:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAcdbar private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer acdbar for acdbar.

    create query vhttquery.
    vhttBuffer = ghttAcdbar:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAcdbar:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create acdbar.
            if not outils:copyValidField(buffer acdbar:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAcdbar private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcb-cd    as handle  no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhSscpt-cd    as handle  no-undo.
    define variable vhIndex-cd    as handle  no-undo.
    define buffer acdbar for acdbar.

    create query vhttquery.
    vhttBuffer = ghttAcdbar:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAcdbar:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcb-cd, output vhSoc-cd, output vhEtab-cd, output vhSscpt-cd, output vhIndex-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first acdbar exclusive-lock
                where rowid(Acdbar) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer acdbar:handle, 'tpcb-cd/soc-cd/etab-cd/sscpt-cd/index-cd: ', substitute('&1/&2/&3/&4/&5', vhTpcb-cd:buffer-value(), vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhSscpt-cd:buffer-value(), vhIndex-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete acdbar no-error.
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

