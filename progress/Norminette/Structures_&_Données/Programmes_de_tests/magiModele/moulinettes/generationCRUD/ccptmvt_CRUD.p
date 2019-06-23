/*------------------------------------------------------------------------
File        : ccptmvt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ccptmvt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ccptmvt.i}
{application/include/error.i}
define variable ghttccptmvt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phSscoll-cle as handle, output phCpt-cd as handle, output phPrd-cd as handle, output phPrd-num as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/sscoll-cle/cpt-cd/prd-cd/prd-num, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'sscoll-cle' then phSscoll-cle = phBuffer:buffer-field(vi).
            when 'cpt-cd' then phCpt-cd = phBuffer:buffer-field(vi).
            when 'prd-cd' then phPrd-cd = phBuffer:buffer-field(vi).
            when 'prd-num' then phPrd-num = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCcptmvt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCcptmvt.
    run updateCcptmvt.
    run createCcptmvt.
end procedure.

procedure setCcptmvt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCcptmvt.
    ghttCcptmvt = phttCcptmvt.
    run crudCcptmvt.
    delete object phttCcptmvt.
end procedure.

procedure readCcptmvt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ccptmvt Fichier de mouvement de compte
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcSscoll-cle as character  no-undo.
    define input parameter pcCpt-cd     as character  no-undo.
    define input parameter piPrd-cd     as integer    no-undo.
    define input parameter piPrd-num    as integer    no-undo.
    define input parameter table-handle phttCcptmvt.
    define variable vhttBuffer as handle no-undo.
    define buffer ccptmvt for ccptmvt.

    vhttBuffer = phttCcptmvt:default-buffer-handle.
    for first ccptmvt no-lock
        where ccptmvt.soc-cd = piSoc-cd
          and ccptmvt.etab-cd = piEtab-cd
          and ccptmvt.sscoll-cle = pcSscoll-cle
          and ccptmvt.cpt-cd = pcCpt-cd
          and ccptmvt.prd-cd = piPrd-cd
          and ccptmvt.prd-num = piPrd-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ccptmvt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCcptmvt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCcptmvt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ccptmvt Fichier de mouvement de compte
    Notes  : service externe. Critère piPrd-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcSscoll-cle as character  no-undo.
    define input parameter pcCpt-cd     as character  no-undo.
    define input parameter piPrd-cd     as integer    no-undo.
    define input parameter table-handle phttCcptmvt.
    define variable vhttBuffer as handle  no-undo.
    define buffer ccptmvt for ccptmvt.

    vhttBuffer = phttCcptmvt:default-buffer-handle.
    if piPrd-cd = ?
    then for each ccptmvt no-lock
        where ccptmvt.soc-cd = piSoc-cd
          and ccptmvt.etab-cd = piEtab-cd
          and ccptmvt.sscoll-cle = pcSscoll-cle
          and ccptmvt.cpt-cd = pcCpt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ccptmvt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ccptmvt no-lock
        where ccptmvt.soc-cd = piSoc-cd
          and ccptmvt.etab-cd = piEtab-cd
          and ccptmvt.sscoll-cle = pcSscoll-cle
          and ccptmvt.cpt-cd = pcCpt-cd
          and ccptmvt.prd-cd = piPrd-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ccptmvt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCcptmvt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCcptmvt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhSscoll-cle    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define variable vhPrd-cd    as handle  no-undo.
    define variable vhPrd-num    as handle  no-undo.
    define buffer ccptmvt for ccptmvt.

    create query vhttquery.
    vhttBuffer = ghttCcptmvt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCcptmvt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhSscoll-cle, output vhCpt-cd, output vhPrd-cd, output vhPrd-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ccptmvt exclusive-lock
                where rowid(ccptmvt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ccptmvt:handle, 'soc-cd/etab-cd/sscoll-cle/cpt-cd/prd-cd/prd-num: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhSscoll-cle:buffer-value(), vhCpt-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ccptmvt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCcptmvt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ccptmvt for ccptmvt.

    create query vhttquery.
    vhttBuffer = ghttCcptmvt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCcptmvt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ccptmvt.
            if not outils:copyValidField(buffer ccptmvt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCcptmvt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhSscoll-cle    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define variable vhPrd-cd    as handle  no-undo.
    define variable vhPrd-num    as handle  no-undo.
    define buffer ccptmvt for ccptmvt.

    create query vhttquery.
    vhttBuffer = ghttCcptmvt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCcptmvt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhSscoll-cle, output vhCpt-cd, output vhPrd-cd, output vhPrd-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ccptmvt exclusive-lock
                where rowid(Ccptmvt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ccptmvt:handle, 'soc-cd/etab-cd/sscoll-cle/cpt-cd/prd-cd/prd-num: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhSscoll-cle:buffer-value(), vhCpt-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ccptmvt no-error.
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

