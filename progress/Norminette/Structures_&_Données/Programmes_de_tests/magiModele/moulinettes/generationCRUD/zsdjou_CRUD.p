/*------------------------------------------------------------------------
File        : zsdjou_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table zsdjou
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/zsdjou.i}
{application/include/error.i}
define variable ghttzsdjou as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phSscoll-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/sscoll-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'sscoll-cle' then phSscoll-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudZsdjou private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteZsdjou.
    run updateZsdjou.
    run createZsdjou.
end procedure.

procedure setZsdjou:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttZsdjou.
    ghttZsdjou = phttZsdjou.
    run crudZsdjou.
    delete object phttZsdjou.
end procedure.

procedure readZsdjou:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table zsdjou Solde des dossiers (Currie)
Correspondance Journaux
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcSscoll-cle as character  no-undo.
    define input parameter table-handle phttZsdjou.
    define variable vhttBuffer as handle no-undo.
    define buffer zsdjou for zsdjou.

    vhttBuffer = phttZsdjou:default-buffer-handle.
    for first zsdjou no-lock
        where zsdjou.soc-cd = piSoc-cd
          and zsdjou.etab-cd = piEtab-cd
          and zsdjou.sscoll-cle = pcSscoll-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer zsdjou:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttZsdjou no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getZsdjou:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table zsdjou Solde des dossiers (Currie)
Correspondance Journaux
    Notes  : service externe. Critère piEtab-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter table-handle phttZsdjou.
    define variable vhttBuffer as handle  no-undo.
    define buffer zsdjou for zsdjou.

    vhttBuffer = phttZsdjou:default-buffer-handle.
    if piEtab-cd = ?
    then for each zsdjou no-lock
        where zsdjou.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer zsdjou:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each zsdjou no-lock
        where zsdjou.soc-cd = piSoc-cd
          and zsdjou.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer zsdjou:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttZsdjou no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateZsdjou private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhSscoll-cle    as handle  no-undo.
    define buffer zsdjou for zsdjou.

    create query vhttquery.
    vhttBuffer = ghttZsdjou:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttZsdjou:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhSscoll-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first zsdjou exclusive-lock
                where rowid(zsdjou) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer zsdjou:handle, 'soc-cd/etab-cd/sscoll-cle: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhSscoll-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer zsdjou:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createZsdjou private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer zsdjou for zsdjou.

    create query vhttquery.
    vhttBuffer = ghttZsdjou:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttZsdjou:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create zsdjou.
            if not outils:copyValidField(buffer zsdjou:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteZsdjou private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhSscoll-cle    as handle  no-undo.
    define buffer zsdjou for zsdjou.

    create query vhttquery.
    vhttBuffer = ghttZsdjou:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttZsdjou:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhSscoll-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first zsdjou exclusive-lock
                where rowid(Zsdjou) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer zsdjou:handle, 'soc-cd/etab-cd/sscoll-cle: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhSscoll-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete zsdjou no-error.
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

