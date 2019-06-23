/*------------------------------------------------------------------------
File        : ifdtpfac_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifdtpfac
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifdtpfac.i}
{application/include/error.i}
define variable ghttifdtpfac as handle no-undo.      // le handle de la temp table à mettre à jour


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

procedure crudIfdtpfac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfdtpfac.
    run updateIfdtpfac.
    run createIfdtpfac.
end procedure.

procedure setIfdtpfac:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfdtpfac.
    ghttIfdtpfac = phttIfdtpfac.
    run crudIfdtpfac.
    delete object phttIfdtpfac.
end procedure.

procedure readIfdtpfac:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifdtpfac Table des types de facturation
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter pcTypefac-cle as character  no-undo.
    define input parameter table-handle phttIfdtpfac.
    define variable vhttBuffer as handle no-undo.
    define buffer ifdtpfac for ifdtpfac.

    vhttBuffer = phttIfdtpfac:default-buffer-handle.
    for first ifdtpfac no-lock
        where ifdtpfac.soc-cd = piSoc-cd
          and ifdtpfac.typefac-cle = pcTypefac-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdtpfac:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdtpfac no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfdtpfac:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifdtpfac Table des types de facturation
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter table-handle phttIfdtpfac.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifdtpfac for ifdtpfac.

    vhttBuffer = phttIfdtpfac:default-buffer-handle.
    if piSoc-cd = ?
    then for each ifdtpfac no-lock
        where ifdtpfac.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdtpfac:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifdtpfac no-lock
        where ifdtpfac.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdtpfac:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdtpfac no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfdtpfac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhTypefac-cle    as handle  no-undo.
    define buffer ifdtpfac for ifdtpfac.

    create query vhttquery.
    vhttBuffer = ghttIfdtpfac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfdtpfac:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhTypefac-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdtpfac exclusive-lock
                where rowid(ifdtpfac) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdtpfac:handle, 'soc-cd/typefac-cle: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhTypefac-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifdtpfac:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfdtpfac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifdtpfac for ifdtpfac.

    create query vhttquery.
    vhttBuffer = ghttIfdtpfac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfdtpfac:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifdtpfac.
            if not outils:copyValidField(buffer ifdtpfac:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfdtpfac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhTypefac-cle    as handle  no-undo.
    define buffer ifdtpfac for ifdtpfac.

    create query vhttquery.
    vhttBuffer = ghttIfdtpfac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfdtpfac:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhTypefac-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdtpfac exclusive-lock
                where rowid(Ifdtpfac) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdtpfac:handle, 'soc-cd/typefac-cle: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhTypefac-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifdtpfac no-error.
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

