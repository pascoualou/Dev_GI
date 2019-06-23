/*------------------------------------------------------------------------
File        : cpaiecom_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cpaiecom
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cpaiecom.i}
{application/include/error.i}
define variable ghttcpaiecom as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phChrono as handle, output phColl-cle as handle, output phCpt-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/chrono/coll-cle/cpt-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'chrono' then phChrono = phBuffer:buffer-field(vi).
            when 'coll-cle' then phColl-cle = phBuffer:buffer-field(vi).
            when 'cpt-cd' then phCpt-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCpaiecom private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCpaiecom.
    run updateCpaiecom.
    run createCpaiecom.
end procedure.

procedure setCpaiecom:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCpaiecom.
    ghttCpaiecom = phttCpaiecom.
    run crudCpaiecom.
    delete object phttCpaiecom.
end procedure.

procedure readCpaiecom:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cpaiecom 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter piChrono   as integer    no-undo.
    define input parameter pcColl-cle as character  no-undo.
    define input parameter pcCpt-cd   as character  no-undo.
    define input parameter table-handle phttCpaiecom.
    define variable vhttBuffer as handle no-undo.
    define buffer cpaiecom for cpaiecom.

    vhttBuffer = phttCpaiecom:default-buffer-handle.
    for first cpaiecom no-lock
        where cpaiecom.soc-cd = piSoc-cd
          and cpaiecom.etab-cd = piEtab-cd
          and cpaiecom.chrono = piChrono
          and cpaiecom.coll-cle = pcColl-cle
          and cpaiecom.cpt-cd = pcCpt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cpaiecom:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCpaiecom no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCpaiecom:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cpaiecom 
    Notes  : service externe. Critère pcColl-cle = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter piChrono   as integer    no-undo.
    define input parameter pcColl-cle as character  no-undo.
    define input parameter table-handle phttCpaiecom.
    define variable vhttBuffer as handle  no-undo.
    define buffer cpaiecom for cpaiecom.

    vhttBuffer = phttCpaiecom:default-buffer-handle.
    if pcColl-cle = ?
    then for each cpaiecom no-lock
        where cpaiecom.soc-cd = piSoc-cd
          and cpaiecom.etab-cd = piEtab-cd
          and cpaiecom.chrono = piChrono:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cpaiecom:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cpaiecom no-lock
        where cpaiecom.soc-cd = piSoc-cd
          and cpaiecom.etab-cd = piEtab-cd
          and cpaiecom.chrono = piChrono
          and cpaiecom.coll-cle = pcColl-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cpaiecom:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCpaiecom no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCpaiecom private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhChrono    as handle  no-undo.
    define variable vhColl-cle    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define buffer cpaiecom for cpaiecom.

    create query vhttquery.
    vhttBuffer = ghttCpaiecom:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCpaiecom:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhChrono, output vhColl-cle, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cpaiecom exclusive-lock
                where rowid(cpaiecom) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cpaiecom:handle, 'soc-cd/etab-cd/chrono/coll-cle/cpt-cd: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhChrono:buffer-value(), vhColl-cle:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cpaiecom:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCpaiecom private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cpaiecom for cpaiecom.

    create query vhttquery.
    vhttBuffer = ghttCpaiecom:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCpaiecom:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cpaiecom.
            if not outils:copyValidField(buffer cpaiecom:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCpaiecom private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhChrono    as handle  no-undo.
    define variable vhColl-cle    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define buffer cpaiecom for cpaiecom.

    create query vhttquery.
    vhttBuffer = ghttCpaiecom:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCpaiecom:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhChrono, output vhColl-cle, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cpaiecom exclusive-lock
                where rowid(Cpaiecom) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cpaiecom:handle, 'soc-cd/etab-cd/chrono/coll-cle/cpt-cd: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhChrono:buffer-value(), vhColl-cle:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cpaiecom no-error.
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

