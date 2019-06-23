/*------------------------------------------------------------------------
File        : cprorata_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cprorata
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cprorata.i}
{application/include/error.i}
define variable ghttcprorata as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phAna1-cd as handle, output phDadeb as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/ana1-cd/dadeb, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'ana1-cd' then phAna1-cd = phBuffer:buffer-field(vi).
            when 'dadeb' then phDadeb = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCprorata private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCprorata.
    run updateCprorata.
    run createCprorata.
end procedure.

procedure setCprorata:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCprorata.
    ghttCprorata = phttCprorata.
    run crudCprorata.
    delete object phttCprorata.
end procedure.

procedure readCprorata:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cprorata 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter pcAna1-cd as character  no-undo.
    define input parameter pdaDadeb   as date       no-undo.
    define input parameter table-handle phttCprorata.
    define variable vhttBuffer as handle no-undo.
    define buffer cprorata for cprorata.

    vhttBuffer = phttCprorata:default-buffer-handle.
    for first cprorata no-lock
        where cprorata.soc-cd = piSoc-cd
          and cprorata.etab-cd = piEtab-cd
          and cprorata.ana1-cd = pcAna1-cd
          and cprorata.dadeb = pdaDadeb:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cprorata:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCprorata no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCprorata:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cprorata 
    Notes  : service externe. Critère pcAna1-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter pcAna1-cd as character  no-undo.
    define input parameter table-handle phttCprorata.
    define variable vhttBuffer as handle  no-undo.
    define buffer cprorata for cprorata.

    vhttBuffer = phttCprorata:default-buffer-handle.
    if pcAna1-cd = ?
    then for each cprorata no-lock
        where cprorata.soc-cd = piSoc-cd
          and cprorata.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cprorata:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cprorata no-lock
        where cprorata.soc-cd = piSoc-cd
          and cprorata.etab-cd = piEtab-cd
          and cprorata.ana1-cd = pcAna1-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cprorata:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCprorata no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCprorata private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhAna1-cd    as handle  no-undo.
    define variable vhDadeb    as handle  no-undo.
    define buffer cprorata for cprorata.

    create query vhttquery.
    vhttBuffer = ghttCprorata:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCprorata:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhAna1-cd, output vhDadeb).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cprorata exclusive-lock
                where rowid(cprorata) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cprorata:handle, 'soc-cd/etab-cd/ana1-cd/dadeb: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhAna1-cd:buffer-value(), vhDadeb:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cprorata:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCprorata private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cprorata for cprorata.

    create query vhttquery.
    vhttBuffer = ghttCprorata:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCprorata:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cprorata.
            if not outils:copyValidField(buffer cprorata:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCprorata private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhAna1-cd    as handle  no-undo.
    define variable vhDadeb    as handle  no-undo.
    define buffer cprorata for cprorata.

    create query vhttquery.
    vhttBuffer = ghttCprorata:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCprorata:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhAna1-cd, output vhDadeb).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cprorata exclusive-lock
                where rowid(Cprorata) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cprorata:handle, 'soc-cd/etab-cd/ana1-cd/dadeb: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhAna1-cd:buffer-value(), vhDadeb:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cprorata no-error.
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

