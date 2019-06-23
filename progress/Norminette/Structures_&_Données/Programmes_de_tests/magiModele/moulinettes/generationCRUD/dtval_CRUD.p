/*------------------------------------------------------------------------
File        : dtval_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table dtval
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/dtval.i}
{application/include/error.i}
define variable ghttdtval as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phColl-cle as handle, output phSscoll-cle as handle, output phCpt-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/coll-cle/sscoll-cle/cpt-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'coll-cle' then phColl-cle = phBuffer:buffer-field(vi).
            when 'sscoll-cle' then phSscoll-cle = phBuffer:buffer-field(vi).
            when 'cpt-cd' then phCpt-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudDtval private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteDtval.
    run updateDtval.
    run createDtval.
end procedure.

procedure setDtval:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttDtval.
    ghttDtval = phttDtval.
    run crudDtval.
    delete object phttDtval.
end procedure.

procedure readDtval:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table dtval Date de validité des comptes
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcColl-cle   as character  no-undo.
    define input parameter pcSscoll-cle as character  no-undo.
    define input parameter pcCpt-cd     as character  no-undo.
    define input parameter table-handle phttDtval.
    define variable vhttBuffer as handle no-undo.
    define buffer dtval for dtval.

    vhttBuffer = phttDtval:default-buffer-handle.
    for first dtval no-lock
        where dtval.soc-cd = piSoc-cd
          and dtval.etab-cd = piEtab-cd
          and dtval.coll-cle = pcColl-cle
          and dtval.sscoll-cle = pcSscoll-cle
          and dtval.cpt-cd = pcCpt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer dtval:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDtval no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getDtval:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table dtval Date de validité des comptes
    Notes  : service externe. Critère pcSscoll-cle = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcColl-cle   as character  no-undo.
    define input parameter pcSscoll-cle as character  no-undo.
    define input parameter table-handle phttDtval.
    define variable vhttBuffer as handle  no-undo.
    define buffer dtval for dtval.

    vhttBuffer = phttDtval:default-buffer-handle.
    if pcSscoll-cle = ?
    then for each dtval no-lock
        where dtval.soc-cd = piSoc-cd
          and dtval.etab-cd = piEtab-cd
          and dtval.coll-cle = pcColl-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer dtval:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each dtval no-lock
        where dtval.soc-cd = piSoc-cd
          and dtval.etab-cd = piEtab-cd
          and dtval.coll-cle = pcColl-cle
          and dtval.sscoll-cle = pcSscoll-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer dtval:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDtval no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateDtval private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhColl-cle    as handle  no-undo.
    define variable vhSscoll-cle    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define buffer dtval for dtval.

    create query vhttquery.
    vhttBuffer = ghttDtval:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttDtval:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhColl-cle, output vhSscoll-cle, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first dtval exclusive-lock
                where rowid(dtval) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer dtval:handle, 'soc-cd/etab-cd/coll-cle/sscoll-cle/cpt-cd: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhColl-cle:buffer-value(), vhSscoll-cle:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer dtval:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createDtval private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer dtval for dtval.

    create query vhttquery.
    vhttBuffer = ghttDtval:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttDtval:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create dtval.
            if not outils:copyValidField(buffer dtval:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteDtval private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhColl-cle    as handle  no-undo.
    define variable vhSscoll-cle    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define buffer dtval for dtval.

    create query vhttquery.
    vhttBuffer = ghttDtval:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttDtval:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhColl-cle, output vhSscoll-cle, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first dtval exclusive-lock
                where rowid(Dtval) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer dtval:handle, 'soc-cd/etab-cd/coll-cle/sscoll-cle/cpt-cd: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhColl-cle:buffer-value(), vhSscoll-cle:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete dtval no-error.
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

