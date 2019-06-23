/*------------------------------------------------------------------------
File        : arectva_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table arectva
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/arectva.i}
{application/include/error.i}
define variable ghttarectva as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phSiren as handle, output phDate_decla as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/siren/date_decla, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'siren' then phSiren = phBuffer:buffer-field(vi).
            when 'date_decla' then phDate_decla = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudArectva private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteArectva.
    run updateArectva.
    run createArectva.
end procedure.

procedure setArectva:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttArectva.
    ghttArectva = phttArectva.
    run crudArectva.
    delete object phttArectva.
end procedure.

procedure readArectva:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table arectva TVA a payer
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter pcSiren      as character  no-undo.
    define input parameter pdaDate_decla as date       no-undo.
    define input parameter table-handle phttArectva.
    define variable vhttBuffer as handle no-undo.
    define buffer arectva for arectva.

    vhttBuffer = phttArectva:default-buffer-handle.
    for first arectva no-lock
        where arectva.soc-cd = piSoc-cd
          and arectva.siren = pcSiren
          and arectva.date_decla = pdaDate_decla:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer arectva:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttArectva no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getArectva:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table arectva TVA a payer
    Notes  : service externe. Critère pcSiren = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter pcSiren      as character  no-undo.
    define input parameter table-handle phttArectva.
    define variable vhttBuffer as handle  no-undo.
    define buffer arectva for arectva.

    vhttBuffer = phttArectva:default-buffer-handle.
    if pcSiren = ?
    then for each arectva no-lock
        where arectva.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer arectva:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each arectva no-lock
        where arectva.soc-cd = piSoc-cd
          and arectva.siren = pcSiren:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer arectva:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttArectva no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateArectva private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhSiren    as handle  no-undo.
    define variable vhDate_decla    as handle  no-undo.
    define buffer arectva for arectva.

    create query vhttquery.
    vhttBuffer = ghttArectva:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttArectva:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhSiren, output vhDate_decla).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first arectva exclusive-lock
                where rowid(arectva) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer arectva:handle, 'soc-cd/siren/date_decla: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhSiren:buffer-value(), vhDate_decla:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer arectva:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createArectva private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer arectva for arectva.

    create query vhttquery.
    vhttBuffer = ghttArectva:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttArectva:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create arectva.
            if not outils:copyValidField(buffer arectva:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteArectva private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhSiren    as handle  no-undo.
    define variable vhDate_decla    as handle  no-undo.
    define buffer arectva for arectva.

    create query vhttquery.
    vhttBuffer = ghttArectva:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttArectva:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhSiren, output vhDate_decla).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first arectva exclusive-lock
                where rowid(Arectva) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer arectva:handle, 'soc-cd/siren/date_decla: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhSiren:buffer-value(), vhDate_decla:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete arectva no-error.
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

