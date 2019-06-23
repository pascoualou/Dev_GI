/*------------------------------------------------------------------------
File        : commaffair_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table commaffair
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/commaffair.i}
{application/include/error.i}
define variable ghttcommaffair as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phAffair-num as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/affair-num, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'affair-num' then phAffair-num = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCommaffair private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCommaffair.
    run updateCommaffair.
    run createCommaffair.
end procedure.

procedure setCommaffair:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCommaffair.
    ghttCommaffair = phttCommaffair.
    run crudCommaffair.
    delete object phttCommaffair.
end procedure.

procedure readCommaffair:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table commaffair Table contenant les commentaires du fichier affaire
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pdeAffair-num as decimal    no-undo.
    define input parameter table-handle phttCommaffair.
    define variable vhttBuffer as handle no-undo.
    define buffer commaffair for commaffair.

    vhttBuffer = phttCommaffair:default-buffer-handle.
    for first commaffair no-lock
        where commaffair.soc-cd = piSoc-cd
          and commaffair.etab-cd = piEtab-cd
          and commaffair.affair-num = pdeAffair-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer commaffair:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCommaffair no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCommaffair:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table commaffair Table contenant les commentaires du fichier affaire
    Notes  : service externe. Critère piEtab-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter table-handle phttCommaffair.
    define variable vhttBuffer as handle  no-undo.
    define buffer commaffair for commaffair.

    vhttBuffer = phttCommaffair:default-buffer-handle.
    if piEtab-cd = ?
    then for each commaffair no-lock
        where commaffair.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer commaffair:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each commaffair no-lock
        where commaffair.soc-cd = piSoc-cd
          and commaffair.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer commaffair:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCommaffair no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCommaffair private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhAffair-num    as handle  no-undo.
    define buffer commaffair for commaffair.

    create query vhttquery.
    vhttBuffer = ghttCommaffair:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCommaffair:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhAffair-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first commaffair exclusive-lock
                where rowid(commaffair) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer commaffair:handle, 'soc-cd/etab-cd/affair-num: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhAffair-num:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer commaffair:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCommaffair private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer commaffair for commaffair.

    create query vhttquery.
    vhttBuffer = ghttCommaffair:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCommaffair:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create commaffair.
            if not outils:copyValidField(buffer commaffair:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCommaffair private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhAffair-num    as handle  no-undo.
    define buffer commaffair for commaffair.

    create query vhttquery.
    vhttBuffer = ghttCommaffair:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCommaffair:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhAffair-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first commaffair exclusive-lock
                where rowid(Commaffair) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer commaffair:handle, 'soc-cd/etab-cd/affair-num: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhAffair-num:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete commaffair no-error.
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

