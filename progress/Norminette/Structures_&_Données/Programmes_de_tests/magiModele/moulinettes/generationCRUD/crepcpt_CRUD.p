/*------------------------------------------------------------------------
File        : crepcpt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table crepcpt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/crepcpt.i}
{application/include/error.i}
define variable ghttcrepcpt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phRepart-cle as handle, output phLig as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/repart-cle/lig, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'repart-cle' then phRepart-cle = phBuffer:buffer-field(vi).
            when 'lig' then phLig = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCrepcpt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCrepcpt.
    run updateCrepcpt.
    run createCrepcpt.
end procedure.

procedure setCrepcpt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCrepcpt.
    ghttCrepcpt = phttCrepcpt.
    run crudCrepcpt.
    delete object phttCrepcpt.
end procedure.

procedure readCrepcpt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table crepcpt Fichier comptes a repartir
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcRepart-cle as character  no-undo.
    define input parameter piLig        as integer    no-undo.
    define input parameter table-handle phttCrepcpt.
    define variable vhttBuffer as handle no-undo.
    define buffer crepcpt for crepcpt.

    vhttBuffer = phttCrepcpt:default-buffer-handle.
    for first crepcpt no-lock
        where crepcpt.soc-cd = piSoc-cd
          and crepcpt.etab-cd = piEtab-cd
          and crepcpt.repart-cle = pcRepart-cle
          and crepcpt.lig = piLig:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer crepcpt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCrepcpt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCrepcpt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table crepcpt Fichier comptes a repartir
    Notes  : service externe. Critère pcRepart-cle = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcRepart-cle as character  no-undo.
    define input parameter table-handle phttCrepcpt.
    define variable vhttBuffer as handle  no-undo.
    define buffer crepcpt for crepcpt.

    vhttBuffer = phttCrepcpt:default-buffer-handle.
    if pcRepart-cle = ?
    then for each crepcpt no-lock
        where crepcpt.soc-cd = piSoc-cd
          and crepcpt.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer crepcpt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each crepcpt no-lock
        where crepcpt.soc-cd = piSoc-cd
          and crepcpt.etab-cd = piEtab-cd
          and crepcpt.repart-cle = pcRepart-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer crepcpt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCrepcpt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCrepcpt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhRepart-cle    as handle  no-undo.
    define variable vhLig    as handle  no-undo.
    define buffer crepcpt for crepcpt.

    create query vhttquery.
    vhttBuffer = ghttCrepcpt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCrepcpt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhRepart-cle, output vhLig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first crepcpt exclusive-lock
                where rowid(crepcpt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer crepcpt:handle, 'soc-cd/etab-cd/repart-cle/lig: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhRepart-cle:buffer-value(), vhLig:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer crepcpt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCrepcpt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer crepcpt for crepcpt.

    create query vhttquery.
    vhttBuffer = ghttCrepcpt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCrepcpt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create crepcpt.
            if not outils:copyValidField(buffer crepcpt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCrepcpt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhRepart-cle    as handle  no-undo.
    define variable vhLig    as handle  no-undo.
    define buffer crepcpt for crepcpt.

    create query vhttquery.
    vhttBuffer = ghttCrepcpt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCrepcpt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhRepart-cle, output vhLig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first crepcpt exclusive-lock
                where rowid(Crepcpt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer crepcpt:handle, 'soc-cd/etab-cd/repart-cle/lig: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhRepart-cle:buffer-value(), vhLig:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete crepcpt no-error.
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

