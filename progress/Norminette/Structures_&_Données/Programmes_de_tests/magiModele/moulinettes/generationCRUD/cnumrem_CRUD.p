/*------------------------------------------------------------------------
File        : cnumrem_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cnumrem
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cnumrem.i}
{application/include/error.i}
define variable ghttcnumrem as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phType-remise as handle, output phDadeb as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/type-remise/dadeb, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'type-remise' then phType-remise = phBuffer:buffer-field(vi).
            when 'dadeb' then phDadeb = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCnumrem private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCnumrem.
    run updateCnumrem.
    run createCnumrem.
end procedure.

procedure setCnumrem:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCnumrem.
    ghttCnumrem = phttCnumrem.
    run crudCnumrem.
    delete object phttCnumrem.
end procedure.

procedure readCnumrem:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cnumrem Fichier de gestion des numeros de remise
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter plType-remise as logical    no-undo.
    define input parameter pdaDadeb       as date       no-undo.
    define input parameter table-handle phttCnumrem.
    define variable vhttBuffer as handle no-undo.
    define buffer cnumrem for cnumrem.

    vhttBuffer = phttCnumrem:default-buffer-handle.
    for first cnumrem no-lock
        where cnumrem.soc-cd = piSoc-cd
          and cnumrem.etab-cd = piEtab-cd
          and cnumrem.type-remise = plType-remise
          and cnumrem.dadeb = pdaDadeb:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cnumrem:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCnumrem no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCnumrem:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cnumrem Fichier de gestion des numeros de remise
    Notes  : service externe. Critère plType-remise = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter plType-remise as logical    no-undo.
    define input parameter table-handle phttCnumrem.
    define variable vhttBuffer as handle  no-undo.
    define buffer cnumrem for cnumrem.

    vhttBuffer = phttCnumrem:default-buffer-handle.
    if plType-remise = ?
    then for each cnumrem no-lock
        where cnumrem.soc-cd = piSoc-cd
          and cnumrem.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cnumrem:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cnumrem no-lock
        where cnumrem.soc-cd = piSoc-cd
          and cnumrem.etab-cd = piEtab-cd
          and cnumrem.type-remise = plType-remise:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cnumrem:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCnumrem no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCnumrem private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhType-remise    as handle  no-undo.
    define variable vhDadeb    as handle  no-undo.
    define buffer cnumrem for cnumrem.

    create query vhttquery.
    vhttBuffer = ghttCnumrem:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCnumrem:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhType-remise, output vhDadeb).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cnumrem exclusive-lock
                where rowid(cnumrem) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cnumrem:handle, 'soc-cd/etab-cd/type-remise/dadeb: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhType-remise:buffer-value(), vhDadeb:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cnumrem:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCnumrem private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cnumrem for cnumrem.

    create query vhttquery.
    vhttBuffer = ghttCnumrem:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCnumrem:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cnumrem.
            if not outils:copyValidField(buffer cnumrem:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCnumrem private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhType-remise    as handle  no-undo.
    define variable vhDadeb    as handle  no-undo.
    define buffer cnumrem for cnumrem.

    create query vhttquery.
    vhttBuffer = ghttCnumrem:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCnumrem:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhType-remise, output vhDadeb).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cnumrem exclusive-lock
                where rowid(Cnumrem) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cnumrem:handle, 'soc-cd/etab-cd/type-remise/dadeb: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhType-remise:buffer-value(), vhDadeb:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cnumrem no-error.
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

