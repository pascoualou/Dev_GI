/*------------------------------------------------------------------------
File        : ifptpfac_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifptpfac
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifptpfac.i}
{application/include/error.i}
define variable ghttifptpfac as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phTypefac-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/typefac-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'typefac-cle' then phTypefac-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIfptpfac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfptpfac.
    run updateIfptpfac.
    run createIfptpfac.
end procedure.

procedure setIfptpfac:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfptpfac.
    ghttIfptpfac = phttIfptpfac.
    run crudIfptpfac.
    delete object phttIfptpfac.
end procedure.

procedure readIfptpfac:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifptpfac Table des types de facturation
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter pcTypefac-cle as character  no-undo.
    define input parameter table-handle phttIfptpfac.
    define variable vhttBuffer as handle no-undo.
    define buffer ifptpfac for ifptpfac.

    vhttBuffer = phttIfptpfac:default-buffer-handle.
    for first ifptpfac no-lock
        where ifptpfac.soc-cd = piSoc-cd
          and ifptpfac.typefac-cle = pcTypefac-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifptpfac:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfptpfac no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfptpfac:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifptpfac Table des types de facturation
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter table-handle phttIfptpfac.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifptpfac for ifptpfac.

    vhttBuffer = phttIfptpfac:default-buffer-handle.
    if piSoc-cd = ?
    then for each ifptpfac no-lock
        where ifptpfac.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifptpfac:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifptpfac no-lock
        where ifptpfac.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifptpfac:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfptpfac no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfptpfac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhTypefac-cle    as handle  no-undo.
    define buffer ifptpfac for ifptpfac.

    create query vhttquery.
    vhttBuffer = ghttIfptpfac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfptpfac:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhTypefac-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifptpfac exclusive-lock
                where rowid(ifptpfac) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifptpfac:handle, 'soc-cd/typefac-cle: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhTypefac-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifptpfac:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfptpfac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifptpfac for ifptpfac.

    create query vhttquery.
    vhttBuffer = ghttIfptpfac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfptpfac:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifptpfac.
            if not outils:copyValidField(buffer ifptpfac:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfptpfac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhTypefac-cle    as handle  no-undo.
    define buffer ifptpfac for ifptpfac.

    create query vhttquery.
    vhttBuffer = ghttIfptpfac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfptpfac:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhTypefac-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifptpfac exclusive-lock
                where rowid(Ifptpfac) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifptpfac:handle, 'soc-cd/typefac-cle: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhTypefac-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifptpfac no-error.
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

