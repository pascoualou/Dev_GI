/*------------------------------------------------------------------------
File        : ifdnpiec_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifdnpiec
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifdnpiec.i}
{application/include/error.i}
define variable ghttifdnpiec as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phJou-cd as handle, output phDadeb as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/jou-cd/dadeb, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'jou-cd' then phJou-cd = phBuffer:buffer-field(vi).
            when 'dadeb' then phDadeb = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIfdnpiec private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfdnpiec.
    run updateIfdnpiec.
    run createIfdnpiec.
end procedure.

procedure setIfdnpiec:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfdnpiec.
    ghttIfdnpiec = phttIfdnpiec.
    run crudIfdnpiec.
    delete object phttIfdnpiec.
end procedure.

procedure readIfdnpiec:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifdnpiec Table de numerotation des pieces
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter pcJou-cd  as character  no-undo.
    define input parameter pdaDadeb   as date       no-undo.
    define input parameter table-handle phttIfdnpiec.
    define variable vhttBuffer as handle no-undo.
    define buffer ifdnpiec for ifdnpiec.

    vhttBuffer = phttIfdnpiec:default-buffer-handle.
    for first ifdnpiec no-lock
        where ifdnpiec.soc-cd = piSoc-cd
          and ifdnpiec.etab-cd = piEtab-cd
          and ifdnpiec.jou-cd = pcJou-cd
          and ifdnpiec.dadeb = pdaDadeb:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdnpiec:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdnpiec no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfdnpiec:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifdnpiec Table de numerotation des pieces
    Notes  : service externe. Critère pcJou-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter pcJou-cd  as character  no-undo.
    define input parameter table-handle phttIfdnpiec.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifdnpiec for ifdnpiec.

    vhttBuffer = phttIfdnpiec:default-buffer-handle.
    if pcJou-cd = ?
    then for each ifdnpiec no-lock
        where ifdnpiec.soc-cd = piSoc-cd
          and ifdnpiec.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdnpiec:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifdnpiec no-lock
        where ifdnpiec.soc-cd = piSoc-cd
          and ifdnpiec.etab-cd = piEtab-cd
          and ifdnpiec.jou-cd = pcJou-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdnpiec:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdnpiec no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfdnpiec private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhJou-cd    as handle  no-undo.
    define variable vhDadeb    as handle  no-undo.
    define buffer ifdnpiec for ifdnpiec.

    create query vhttquery.
    vhttBuffer = ghttIfdnpiec:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfdnpiec:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhDadeb).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdnpiec exclusive-lock
                where rowid(ifdnpiec) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdnpiec:handle, 'soc-cd/etab-cd/jou-cd/dadeb: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhDadeb:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifdnpiec:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfdnpiec private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifdnpiec for ifdnpiec.

    create query vhttquery.
    vhttBuffer = ghttIfdnpiec:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfdnpiec:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifdnpiec.
            if not outils:copyValidField(buffer ifdnpiec:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfdnpiec private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhJou-cd    as handle  no-undo.
    define variable vhDadeb    as handle  no-undo.
    define buffer ifdnpiec for ifdnpiec.

    create query vhttquery.
    vhttBuffer = ghttIfdnpiec:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfdnpiec:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhDadeb).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdnpiec exclusive-lock
                where rowid(Ifdnpiec) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdnpiec:handle, 'soc-cd/etab-cd/jou-cd/dadeb: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhDadeb:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifdnpiec no-error.
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

