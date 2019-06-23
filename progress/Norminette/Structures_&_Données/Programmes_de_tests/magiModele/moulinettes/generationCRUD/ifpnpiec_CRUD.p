/*------------------------------------------------------------------------
File        : ifpnpiec_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifpnpiec
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifpnpiec.i}
{application/include/error.i}
define variable ghttifpnpiec as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phPrd-cd as handle, output phPrd-num as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/prd-cd/prd-num, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'prd-cd' then phPrd-cd = phBuffer:buffer-field(vi).
            when 'prd-num' then phPrd-num = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIfpnpiec private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfpnpiec.
    run updateIfpnpiec.
    run createIfpnpiec.
end procedure.

procedure setIfpnpiec:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfpnpiec.
    ghttIfpnpiec = phttIfpnpiec.
    run crudIfpnpiec.
    delete object phttIfpnpiec.
end procedure.

procedure readIfpnpiec:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifpnpiec Table de numerotation des pieces
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piPrd-cd  as integer    no-undo.
    define input parameter piPrd-num as integer    no-undo.
    define input parameter table-handle phttIfpnpiec.
    define variable vhttBuffer as handle no-undo.
    define buffer ifpnpiec for ifpnpiec.

    vhttBuffer = phttIfpnpiec:default-buffer-handle.
    for first ifpnpiec no-lock
        where ifpnpiec.soc-cd = piSoc-cd
          and ifpnpiec.etab-cd = piEtab-cd
          and ifpnpiec.prd-cd = piPrd-cd
          and ifpnpiec.prd-num = piPrd-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifpnpiec:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfpnpiec no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfpnpiec:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifpnpiec Table de numerotation des pieces
    Notes  : service externe. Critère piPrd-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piPrd-cd  as integer    no-undo.
    define input parameter table-handle phttIfpnpiec.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifpnpiec for ifpnpiec.

    vhttBuffer = phttIfpnpiec:default-buffer-handle.
    if piPrd-cd = ?
    then for each ifpnpiec no-lock
        where ifpnpiec.soc-cd = piSoc-cd
          and ifpnpiec.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifpnpiec:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifpnpiec no-lock
        where ifpnpiec.soc-cd = piSoc-cd
          and ifpnpiec.etab-cd = piEtab-cd
          and ifpnpiec.prd-cd = piPrd-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifpnpiec:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfpnpiec no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfpnpiec private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhPrd-cd    as handle  no-undo.
    define variable vhPrd-num    as handle  no-undo.
    define buffer ifpnpiec for ifpnpiec.

    create query vhttquery.
    vhttBuffer = ghttIfpnpiec:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfpnpiec:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhPrd-cd, output vhPrd-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifpnpiec exclusive-lock
                where rowid(ifpnpiec) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifpnpiec:handle, 'soc-cd/etab-cd/prd-cd/prd-num: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifpnpiec:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfpnpiec private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifpnpiec for ifpnpiec.

    create query vhttquery.
    vhttBuffer = ghttIfpnpiec:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfpnpiec:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifpnpiec.
            if not outils:copyValidField(buffer ifpnpiec:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfpnpiec private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhPrd-cd    as handle  no-undo.
    define variable vhPrd-num    as handle  no-undo.
    define buffer ifpnpiec for ifpnpiec.

    create query vhttquery.
    vhttBuffer = ghttIfpnpiec:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfpnpiec:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhPrd-cd, output vhPrd-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifpnpiec exclusive-lock
                where rowid(Ifpnpiec) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifpnpiec:handle, 'soc-cd/etab-cd/prd-cd/prd-num: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifpnpiec no-error.
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

