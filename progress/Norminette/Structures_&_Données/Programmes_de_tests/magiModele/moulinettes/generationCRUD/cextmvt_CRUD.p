/*------------------------------------------------------------------------
File        : cextmvt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cextmvt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cextmvt.i}
{application/include/error.i}
define variable ghttcextmvt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phSscoll-cle as handle, output phCpt-cd as handle, output phPrd-cd as handle, output phPrd-num as handle, output phTypenat-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/sscoll-cle/cpt-cd/prd-cd/prd-num/typenat-cd, 
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
            when 'typenat-cd' then phTypenat-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCextmvt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCextmvt.
    run updateCextmvt.
    run createCextmvt.
end procedure.

procedure setCextmvt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCextmvt.
    ghttCextmvt = phttCextmvt.
    run crudCextmvt.
    delete object phttCextmvt.
end procedure.

procedure readCextmvt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cextmvt Fichier de mouvement de compte
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcSscoll-cle as character  no-undo.
    define input parameter pcCpt-cd     as character  no-undo.
    define input parameter piPrd-cd     as integer    no-undo.
    define input parameter piPrd-num    as integer    no-undo.
    define input parameter piTypenat-cd as integer    no-undo.
    define input parameter table-handle phttCextmvt.
    define variable vhttBuffer as handle no-undo.
    define buffer cextmvt for cextmvt.

    vhttBuffer = phttCextmvt:default-buffer-handle.
    for first cextmvt no-lock
        where cextmvt.soc-cd = piSoc-cd
          and cextmvt.etab-cd = piEtab-cd
          and cextmvt.sscoll-cle = pcSscoll-cle
          and cextmvt.cpt-cd = pcCpt-cd
          and cextmvt.prd-cd = piPrd-cd
          and cextmvt.prd-num = piPrd-num
          and cextmvt.typenat-cd = piTypenat-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cextmvt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCextmvt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCextmvt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cextmvt Fichier de mouvement de compte
    Notes  : service externe. Critère piPrd-num = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcSscoll-cle as character  no-undo.
    define input parameter pcCpt-cd     as character  no-undo.
    define input parameter piPrd-cd     as integer    no-undo.
    define input parameter piPrd-num    as integer    no-undo.
    define input parameter table-handle phttCextmvt.
    define variable vhttBuffer as handle  no-undo.
    define buffer cextmvt for cextmvt.

    vhttBuffer = phttCextmvt:default-buffer-handle.
    if piPrd-num = ?
    then for each cextmvt no-lock
        where cextmvt.soc-cd = piSoc-cd
          and cextmvt.etab-cd = piEtab-cd
          and cextmvt.sscoll-cle = pcSscoll-cle
          and cextmvt.cpt-cd = pcCpt-cd
          and cextmvt.prd-cd = piPrd-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cextmvt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cextmvt no-lock
        where cextmvt.soc-cd = piSoc-cd
          and cextmvt.etab-cd = piEtab-cd
          and cextmvt.sscoll-cle = pcSscoll-cle
          and cextmvt.cpt-cd = pcCpt-cd
          and cextmvt.prd-cd = piPrd-cd
          and cextmvt.prd-num = piPrd-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cextmvt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCextmvt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCextmvt private:
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
    define variable vhTypenat-cd    as handle  no-undo.
    define buffer cextmvt for cextmvt.

    create query vhttquery.
    vhttBuffer = ghttCextmvt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCextmvt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhSscoll-cle, output vhCpt-cd, output vhPrd-cd, output vhPrd-num, output vhTypenat-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cextmvt exclusive-lock
                where rowid(cextmvt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cextmvt:handle, 'soc-cd/etab-cd/sscoll-cle/cpt-cd/prd-cd/prd-num/typenat-cd: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhSscoll-cle:buffer-value(), vhCpt-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhTypenat-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cextmvt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCextmvt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cextmvt for cextmvt.

    create query vhttquery.
    vhttBuffer = ghttCextmvt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCextmvt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cextmvt.
            if not outils:copyValidField(buffer cextmvt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCextmvt private:
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
    define variable vhTypenat-cd    as handle  no-undo.
    define buffer cextmvt for cextmvt.

    create query vhttquery.
    vhttBuffer = ghttCextmvt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCextmvt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhSscoll-cle, output vhCpt-cd, output vhPrd-cd, output vhPrd-num, output vhTypenat-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cextmvt exclusive-lock
                where rowid(Cextmvt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cextmvt:handle, 'soc-cd/etab-cd/sscoll-cle/cpt-cd/prd-cd/prd-num/typenat-cd: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhSscoll-cle:buffer-value(), vhCpt-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhTypenat-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cextmvt no-error.
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

