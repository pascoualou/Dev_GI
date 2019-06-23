/*------------------------------------------------------------------------
File        : cpaierec_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cpaierec
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cpaierec.i}
{application/include/error.i}
define variable ghttcpaierec as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phChrono as handle, output phLibpaie-cd as handle, output phBqjou-cd as handle, output phDaech as handle, output phColl-cle as handle, output phCpt-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/chrono/libpaie-cd/bqjou-cd/daech/coll-cle/cpt-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'chrono' then phChrono = phBuffer:buffer-field(vi).
            when 'libpaie-cd' then phLibpaie-cd = phBuffer:buffer-field(vi).
            when 'bqjou-cd' then phBqjou-cd = phBuffer:buffer-field(vi).
            when 'daech' then phDaech = phBuffer:buffer-field(vi).
            when 'coll-cle' then phColl-cle = phBuffer:buffer-field(vi).
            when 'cpt-cd' then phCpt-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCpaierec private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCpaierec.
    run updateCpaierec.
    run createCpaierec.
end procedure.

procedure setCpaierec:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCpaierec.
    ghttCpaierec = phttCpaierec.
    run crudCpaierec.
    delete object phttCpaierec.
end procedure.

procedure readCpaierec:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cpaierec Recapitulative de Paiement
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter piChrono     as integer    no-undo.
    define input parameter piLibpaie-cd as integer    no-undo.
    define input parameter pcBqjou-cd   as character  no-undo.
    define input parameter pdaDaech      as date       no-undo.
    define input parameter pcColl-cle   as character  no-undo.
    define input parameter pcCpt-cd     as character  no-undo.
    define input parameter table-handle phttCpaierec.
    define variable vhttBuffer as handle no-undo.
    define buffer cpaierec for cpaierec.

    vhttBuffer = phttCpaierec:default-buffer-handle.
    for first cpaierec no-lock
        where cpaierec.soc-cd = piSoc-cd
          and cpaierec.etab-cd = piEtab-cd
          and cpaierec.chrono = piChrono
          and cpaierec.libpaie-cd = piLibpaie-cd
          and cpaierec.bqjou-cd = pcBqjou-cd
          and cpaierec.daech = pdaDaech
          and cpaierec.coll-cle = pcColl-cle
          and cpaierec.cpt-cd = pcCpt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cpaierec:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCpaierec no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCpaierec:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cpaierec Recapitulative de Paiement
    Notes  : service externe. Critère pcColl-cle = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter piChrono     as integer    no-undo.
    define input parameter piLibpaie-cd as integer    no-undo.
    define input parameter pcBqjou-cd   as character  no-undo.
    define input parameter pdaDaech      as date       no-undo.
    define input parameter pcColl-cle   as character  no-undo.
    define input parameter table-handle phttCpaierec.
    define variable vhttBuffer as handle  no-undo.
    define buffer cpaierec for cpaierec.

    vhttBuffer = phttCpaierec:default-buffer-handle.
    if pcColl-cle = ?
    then for each cpaierec no-lock
        where cpaierec.soc-cd = piSoc-cd
          and cpaierec.etab-cd = piEtab-cd
          and cpaierec.chrono = piChrono
          and cpaierec.libpaie-cd = piLibpaie-cd
          and cpaierec.bqjou-cd = pcBqjou-cd
          and cpaierec.daech = pdaDaech:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cpaierec:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cpaierec no-lock
        where cpaierec.soc-cd = piSoc-cd
          and cpaierec.etab-cd = piEtab-cd
          and cpaierec.chrono = piChrono
          and cpaierec.libpaie-cd = piLibpaie-cd
          and cpaierec.bqjou-cd = pcBqjou-cd
          and cpaierec.daech = pdaDaech
          and cpaierec.coll-cle = pcColl-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cpaierec:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCpaierec no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCpaierec private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhChrono    as handle  no-undo.
    define variable vhLibpaie-cd    as handle  no-undo.
    define variable vhBqjou-cd    as handle  no-undo.
    define variable vhDaech    as handle  no-undo.
    define variable vhColl-cle    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define buffer cpaierec for cpaierec.

    create query vhttquery.
    vhttBuffer = ghttCpaierec:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCpaierec:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhChrono, output vhLibpaie-cd, output vhBqjou-cd, output vhDaech, output vhColl-cle, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cpaierec exclusive-lock
                where rowid(cpaierec) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cpaierec:handle, 'soc-cd/etab-cd/chrono/libpaie-cd/bqjou-cd/daech/coll-cle/cpt-cd: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhChrono:buffer-value(), vhLibpaie-cd:buffer-value(), vhBqjou-cd:buffer-value(), vhDaech:buffer-value(), vhColl-cle:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cpaierec:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCpaierec private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cpaierec for cpaierec.

    create query vhttquery.
    vhttBuffer = ghttCpaierec:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCpaierec:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cpaierec.
            if not outils:copyValidField(buffer cpaierec:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCpaierec private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhChrono    as handle  no-undo.
    define variable vhLibpaie-cd    as handle  no-undo.
    define variable vhBqjou-cd    as handle  no-undo.
    define variable vhDaech    as handle  no-undo.
    define variable vhColl-cle    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define buffer cpaierec for cpaierec.

    create query vhttquery.
    vhttBuffer = ghttCpaierec:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCpaierec:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhChrono, output vhLibpaie-cd, output vhBqjou-cd, output vhDaech, output vhColl-cle, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cpaierec exclusive-lock
                where rowid(Cpaierec) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cpaierec:handle, 'soc-cd/etab-cd/chrono/libpaie-cd/bqjou-cd/daech/coll-cle/cpt-cd: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhChrono:buffer-value(), vhLibpaie-cd:buffer-value(), vhBqjou-cd:buffer-value(), vhDaech:buffer-value(), vhColl-cle:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cpaierec no-error.
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

