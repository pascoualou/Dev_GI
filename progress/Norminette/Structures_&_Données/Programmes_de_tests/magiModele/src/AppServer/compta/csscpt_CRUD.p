/*------------------------------------------------------------------------
File        : csscpt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table csscpt
Author(s)   : generation automatique le 04/27/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttcsscpt as handle no-undo.     // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phSscoll-cle as handle, output phCpt-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/sscoll-cle/cpt-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'sscoll-cle' then phSscoll-cle = phBuffer:buffer-field(vi).
            when 'cpt-cd' then phCpt-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCsscpt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCsscpt.
    run updateCsscpt.
    run createCsscpt.
end procedure.

procedure setCsscpt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCsscpt.
    ghttCsscpt = phttCsscpt.
    run crudCsscpt.
    delete object phttCsscpt.
end procedure.

procedure readCsscpt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table csscpt Fichier collectif rattache aux cptes indiv
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcSscoll-cle as character  no-undo.
    define input parameter pcCpt-cd     as character  no-undo.
    define input parameter table-handle phttCsscpt.
    define variable vhttBuffer as handle no-undo.
    define buffer csscpt for csscpt.

    vhttBuffer = phttCsscpt:default-buffer-handle.
    for first csscpt no-lock
        where csscpt.soc-cd = piSoc-cd
          and csscpt.etab-cd = piEtab-cd
          and csscpt.sscoll-cle = pcSscoll-cle
          and csscpt.cpt-cd = pcCpt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer csscpt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCsscpt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCsscpt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table csscpt Fichier collectif rattache aux cptes indiv
    Notes  : service externe. Critère pcSscoll-cle = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcSscoll-cle as character  no-undo.
    define input parameter table-handle phttCsscpt.
    define variable vhttBuffer as handle  no-undo.
    define buffer csscpt for csscpt.

    vhttBuffer = phttCsscpt:default-buffer-handle.
    if pcSscoll-cle = ?
    then for each csscpt no-lock
        where csscpt.soc-cd = piSoc-cd
          and csscpt.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer csscpt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each csscpt no-lock
        where csscpt.soc-cd = piSoc-cd
          and csscpt.etab-cd = piEtab-cd
          and csscpt.sscoll-cle = pcSscoll-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer csscpt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCsscpt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCsscpt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhSscoll-cle    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define buffer csscpt for csscpt.

    create query vhttquery.
    vhttBuffer = ghttCsscpt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCsscpt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhSscoll-cle, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first csscpt exclusive-lock
                where rowid(csscpt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer csscpt:handle, 'soc-cd/etab-cd/sscoll-cle/cpt-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhSscoll-cle:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer csscpt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCsscpt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer csscpt for csscpt.

    create query vhttquery.
    vhttBuffer = ghttCsscpt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCsscpt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create csscpt.
            if not outils:copyValidField(buffer csscpt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCsscpt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhSscoll-cle    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define buffer csscpt for csscpt.

    create query vhttquery.
    vhttBuffer = ghttCsscpt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCsscpt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhSscoll-cle, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first csscpt exclusive-lock
                where rowid(Csscpt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer csscpt:handle, 'soc-cd/etab-cd/sscoll-cle/cpt-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhSscoll-cle:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete csscpt no-error.
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
