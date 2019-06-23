/*------------------------------------------------------------------------
File        : iribfour_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iribfour
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/iribfour.i}
{application/include/error.i}
define variable ghttiribfour as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phFour-cle as handle, output phOrdre-num as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/four-cle/ordre-num, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'four-cle' then phFour-cle = phBuffer:buffer-field(vi).
            when 'ordre-num' then phOrdre-num = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIribfour private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIribfour.
    run updateIribfour.
    run createIribfour.
end procedure.

procedure setIribfour:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIribfour.
    ghttIribfour = phttIribfour.
    run crudIribfour.
    delete object phttIribfour.
end procedure.

procedure readIribfour:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iribfour Liste des rib pour les fournisseurs.
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter pcFour-cle  as character  no-undo.
    define input parameter piOrdre-num as integer    no-undo.
    define input parameter table-handle phttIribfour.
    define variable vhttBuffer as handle no-undo.
    define buffer iribfour for iribfour.

    vhttBuffer = phttIribfour:default-buffer-handle.
    for first iribfour no-lock
        where iribfour.soc-cd = piSoc-cd
          and iribfour.four-cle = pcFour-cle
          and iribfour.ordre-num = piOrdre-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iribfour:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIribfour no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIribfour:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iribfour Liste des rib pour les fournisseurs.
    Notes  : service externe. Critère pcFour-cle = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter pcFour-cle  as character  no-undo.
    define input parameter table-handle phttIribfour.
    define variable vhttBuffer as handle  no-undo.
    define buffer iribfour for iribfour.

    vhttBuffer = phttIribfour:default-buffer-handle.
    if pcFour-cle = ?
    then for each iribfour no-lock
        where iribfour.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iribfour:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each iribfour no-lock
        where iribfour.soc-cd = piSoc-cd
          and iribfour.four-cle = pcFour-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iribfour:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIribfour no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIribfour private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhFour-cle    as handle  no-undo.
    define variable vhOrdre-num    as handle  no-undo.
    define buffer iribfour for iribfour.

    create query vhttquery.
    vhttBuffer = ghttIribfour:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIribfour:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhFour-cle, output vhOrdre-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iribfour exclusive-lock
                where rowid(iribfour) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iribfour:handle, 'soc-cd/four-cle/ordre-num: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhFour-cle:buffer-value(), vhOrdre-num:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iribfour:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIribfour private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iribfour for iribfour.

    create query vhttquery.
    vhttBuffer = ghttIribfour:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIribfour:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iribfour.
            if not outils:copyValidField(buffer iribfour:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIribfour private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhFour-cle    as handle  no-undo.
    define variable vhOrdre-num    as handle  no-undo.
    define buffer iribfour for iribfour.

    create query vhttquery.
    vhttBuffer = ghttIribfour:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIribfour:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhFour-cle, output vhOrdre-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iribfour exclusive-lock
                where rowid(Iribfour) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iribfour:handle, 'soc-cd/four-cle/ordre-num: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhFour-cle:buffer-value(), vhOrdre-num:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iribfour no-error.
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

