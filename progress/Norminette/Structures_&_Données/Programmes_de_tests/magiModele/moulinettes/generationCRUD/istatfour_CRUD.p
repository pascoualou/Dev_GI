/*------------------------------------------------------------------------
File        : istatfour_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table istatfour
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/istatfour.i}
{application/include/error.i}
define variable ghttistatfour as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phFour-cle as handle, output phPrd-cd as handle, output phPrd-num as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/four-cle/prd-cd/prd-num, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'four-cle' then phFour-cle = phBuffer:buffer-field(vi).
            when 'prd-cd' then phPrd-cd = phBuffer:buffer-field(vi).
            when 'prd-num' then phPrd-num = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIstatfour private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIstatfour.
    run updateIstatfour.
    run createIstatfour.
end procedure.

procedure setIstatfour:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIstatfour.
    ghttIstatfour = phttIstatfour.
    run crudIstatfour.
    delete object phttIstatfour.
end procedure.

procedure readIstatfour:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table istatfour Statistiques concernant les fournisseurs.
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter pcFour-cle as character  no-undo.
    define input parameter piPrd-cd   as integer    no-undo.
    define input parameter piPrd-num  as integer    no-undo.
    define input parameter table-handle phttIstatfour.
    define variable vhttBuffer as handle no-undo.
    define buffer istatfour for istatfour.

    vhttBuffer = phttIstatfour:default-buffer-handle.
    for first istatfour no-lock
        where istatfour.soc-cd = piSoc-cd
          and istatfour.etab-cd = piEtab-cd
          and istatfour.four-cle = pcFour-cle
          and istatfour.prd-cd = piPrd-cd
          and istatfour.prd-num = piPrd-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer istatfour:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIstatfour no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIstatfour:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table istatfour Statistiques concernant les fournisseurs.
    Notes  : service externe. Critère piPrd-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter pcFour-cle as character  no-undo.
    define input parameter piPrd-cd   as integer    no-undo.
    define input parameter table-handle phttIstatfour.
    define variable vhttBuffer as handle  no-undo.
    define buffer istatfour for istatfour.

    vhttBuffer = phttIstatfour:default-buffer-handle.
    if piPrd-cd = ?
    then for each istatfour no-lock
        where istatfour.soc-cd = piSoc-cd
          and istatfour.etab-cd = piEtab-cd
          and istatfour.four-cle = pcFour-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer istatfour:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each istatfour no-lock
        where istatfour.soc-cd = piSoc-cd
          and istatfour.etab-cd = piEtab-cd
          and istatfour.four-cle = pcFour-cle
          and istatfour.prd-cd = piPrd-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer istatfour:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIstatfour no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIstatfour private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhFour-cle    as handle  no-undo.
    define variable vhPrd-cd    as handle  no-undo.
    define variable vhPrd-num    as handle  no-undo.
    define buffer istatfour for istatfour.

    create query vhttquery.
    vhttBuffer = ghttIstatfour:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIstatfour:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhFour-cle, output vhPrd-cd, output vhPrd-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first istatfour exclusive-lock
                where rowid(istatfour) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer istatfour:handle, 'soc-cd/etab-cd/four-cle/prd-cd/prd-num: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhFour-cle:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer istatfour:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIstatfour private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer istatfour for istatfour.

    create query vhttquery.
    vhttBuffer = ghttIstatfour:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIstatfour:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create istatfour.
            if not outils:copyValidField(buffer istatfour:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIstatfour private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhFour-cle    as handle  no-undo.
    define variable vhPrd-cd    as handle  no-undo.
    define variable vhPrd-num    as handle  no-undo.
    define buffer istatfour for istatfour.

    create query vhttquery.
    vhttBuffer = ghttIstatfour:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIstatfour:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhFour-cle, output vhPrd-cd, output vhPrd-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first istatfour exclusive-lock
                where rowid(Istatfour) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer istatfour:handle, 'soc-cd/etab-cd/four-cle/prd-cd/prd-num: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhFour-cle:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete istatfour no-error.
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

