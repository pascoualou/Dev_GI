/*------------------------------------------------------------------------
File        : abap_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table abap
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/abap.i}
{application/include/error.i}
define variable ghttabap as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phFg-valid as handle, output phTypefac-cle as handle, output phEtab-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/fg-valid/typefac-cle/etab-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'fg-valid' then phFg-valid = phBuffer:buffer-field(vi).
            when 'typefac-cle' then phTypefac-cle = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAbap private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAbap.
    run updateAbap.
    run createAbap.
end procedure.

procedure setAbap:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAbap.
    ghttAbap = phttAbap.
    run crudAbap.
    delete object phttAbap.
end procedure.

procedure readAbap:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table abap Paiements fournisseurs venant du DPS
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter plFg-valid    as logical    no-undo.
    define input parameter pcTypefac-cle as character  no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter table-handle phttAbap.
    define variable vhttBuffer as handle no-undo.
    define buffer abap for abap.

    vhttBuffer = phttAbap:default-buffer-handle.
    for first abap no-lock
        where abap.soc-cd = piSoc-cd
          and abap.fg-valid = plFg-valid
          and abap.typefac-cle = pcTypefac-cle
          and abap.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer abap:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAbap no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAbap:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table abap Paiements fournisseurs venant du DPS
    Notes  : service externe. Critère pcTypefac-cle = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter plFg-valid    as logical    no-undo.
    define input parameter pcTypefac-cle as character  no-undo.
    define input parameter table-handle phttAbap.
    define variable vhttBuffer as handle  no-undo.
    define buffer abap for abap.

    vhttBuffer = phttAbap:default-buffer-handle.
    if pcTypefac-cle = ?
    then for each abap no-lock
        where abap.soc-cd = piSoc-cd
          and abap.fg-valid = plFg-valid:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer abap:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each abap no-lock
        where abap.soc-cd = piSoc-cd
          and abap.fg-valid = plFg-valid
          and abap.typefac-cle = pcTypefac-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer abap:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAbap no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAbap private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhFg-valid    as handle  no-undo.
    define variable vhTypefac-cle    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define buffer abap for abap.

    create query vhttquery.
    vhttBuffer = ghttAbap:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAbap:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhFg-valid, output vhTypefac-cle, output vhEtab-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first abap exclusive-lock
                where rowid(abap) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer abap:handle, 'soc-cd/fg-valid/typefac-cle/etab-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhFg-valid:buffer-value(), vhTypefac-cle:buffer-value(), vhEtab-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer abap:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAbap private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer abap for abap.

    create query vhttquery.
    vhttBuffer = ghttAbap:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAbap:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create abap.
            if not outils:copyValidField(buffer abap:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAbap private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhFg-valid    as handle  no-undo.
    define variable vhTypefac-cle    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define buffer abap for abap.

    create query vhttquery.
    vhttBuffer = ghttAbap:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAbap:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhFg-valid, output vhTypefac-cle, output vhEtab-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first abap exclusive-lock
                where rowid(Abap) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer abap:handle, 'soc-cd/fg-valid/typefac-cle/etab-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhFg-valid:buffer-value(), vhTypefac-cle:buffer-value(), vhEtab-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete abap no-error.
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

