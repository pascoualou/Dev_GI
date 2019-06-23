/*------------------------------------------------------------------------
File        : ifpjou_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifpjou
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifpjou.i}
{application/include/error.i}
define variable ghttifpjou as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phTypefac-cle as handle, output phLibass-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/typefac-cle/libass-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'typefac-cle' then phTypefac-cle = phBuffer:buffer-field(vi).
            when 'libass-cd' then phLibass-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIfpjou private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfpjou.
    run updateIfpjou.
    run createIfpjou.
end procedure.

procedure setIfpjou:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfpjou.
    ghttIfpjou = phttIfpjou.
    run crudIfpjou.
    delete object phttIfpjou.
end procedure.

procedure readIfpjou:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifpjou tables des journaux facturation
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter pcTypefac-cle as character  no-undo.
    define input parameter piLibass-cd   as integer    no-undo.
    define input parameter table-handle phttIfpjou.
    define variable vhttBuffer as handle no-undo.
    define buffer ifpjou for ifpjou.

    vhttBuffer = phttIfpjou:default-buffer-handle.
    for first ifpjou no-lock
        where ifpjou.soc-cd = piSoc-cd
          and ifpjou.etab-cd = piEtab-cd
          and ifpjou.typefac-cle = pcTypefac-cle
          and ifpjou.libass-cd = piLibass-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifpjou:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfpjou no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfpjou:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifpjou tables des journaux facturation
    Notes  : service externe. Critère pcTypefac-cle = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter pcTypefac-cle as character  no-undo.
    define input parameter table-handle phttIfpjou.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifpjou for ifpjou.

    vhttBuffer = phttIfpjou:default-buffer-handle.
    if pcTypefac-cle = ?
    then for each ifpjou no-lock
        where ifpjou.soc-cd = piSoc-cd
          and ifpjou.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifpjou:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifpjou no-lock
        where ifpjou.soc-cd = piSoc-cd
          and ifpjou.etab-cd = piEtab-cd
          and ifpjou.typefac-cle = pcTypefac-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifpjou:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfpjou no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfpjou private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhTypefac-cle    as handle  no-undo.
    define variable vhLibass-cd    as handle  no-undo.
    define buffer ifpjou for ifpjou.

    create query vhttquery.
    vhttBuffer = ghttIfpjou:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfpjou:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhTypefac-cle, output vhLibass-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifpjou exclusive-lock
                where rowid(ifpjou) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifpjou:handle, 'soc-cd/etab-cd/typefac-cle/libass-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhTypefac-cle:buffer-value(), vhLibass-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifpjou:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfpjou private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifpjou for ifpjou.

    create query vhttquery.
    vhttBuffer = ghttIfpjou:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfpjou:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifpjou.
            if not outils:copyValidField(buffer ifpjou:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfpjou private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhTypefac-cle    as handle  no-undo.
    define variable vhLibass-cd    as handle  no-undo.
    define buffer ifpjou for ifpjou.

    create query vhttquery.
    vhttBuffer = ghttIfpjou:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfpjou:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhTypefac-cle, output vhLibass-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifpjou exclusive-lock
                where rowid(Ifpjou) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifpjou:handle, 'soc-cd/etab-cd/typefac-cle/libass-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhTypefac-cle:buffer-value(), vhLibass-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifpjou no-error.
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

