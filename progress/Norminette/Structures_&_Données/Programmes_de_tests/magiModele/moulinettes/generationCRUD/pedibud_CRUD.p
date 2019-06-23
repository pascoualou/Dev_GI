/*------------------------------------------------------------------------
File        : pedibud_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table pedibud
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/pedibud.i}
{application/include/error.i}
define variable ghttpedibud as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phGi-ttyid as handle, output phType as handle, output phAna1-cd as handle, output phAna2-cd as handle, output phAna3-cd as handle, output phAna4-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur gi-ttyid/type/ana1-cd/ana2-cd/ana3-cd/ana4-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'gi-ttyid' then phGi-ttyid = phBuffer:buffer-field(vi).
            when 'type' then phType = phBuffer:buffer-field(vi).
            when 'ana1-cd' then phAna1-cd = phBuffer:buffer-field(vi).
            when 'ana2-cd' then phAna2-cd = phBuffer:buffer-field(vi).
            when 'ana3-cd' then phAna3-cd = phBuffer:buffer-field(vi).
            when 'ana4-cd' then phAna4-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudPedibud private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deletePedibud.
    run updatePedibud.
    run createPedibud.
end procedure.

procedure setPedibud:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPedibud.
    ghttPedibud = phttPedibud.
    run crudPedibud.
    delete object phttPedibud.
end procedure.

procedure readPedibud:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table pedibud Edition des budgets (fichier de travail)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcGi-ttyid as character  no-undo.
    define input parameter plType     as logical    no-undo.
    define input parameter pcAna1-cd  as character  no-undo.
    define input parameter pcAna2-cd  as character  no-undo.
    define input parameter pcAna3-cd  as character  no-undo.
    define input parameter pcAna4-cd  as character  no-undo.
    define input parameter table-handle phttPedibud.
    define variable vhttBuffer as handle no-undo.
    define buffer pedibud for pedibud.

    vhttBuffer = phttPedibud:default-buffer-handle.
    for first pedibud no-lock
        where pedibud.gi-ttyid = pcGi-ttyid
          and pedibud.type = plType
          and pedibud.ana1-cd = pcAna1-cd
          and pedibud.ana2-cd = pcAna2-cd
          and pedibud.ana3-cd = pcAna3-cd
          and pedibud.ana4-cd = pcAna4-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pedibud:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPedibud no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getPedibud:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table pedibud Edition des budgets (fichier de travail)
    Notes  : service externe. Critère pcAna3-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcGi-ttyid as character  no-undo.
    define input parameter plType     as logical    no-undo.
    define input parameter pcAna1-cd  as character  no-undo.
    define input parameter pcAna2-cd  as character  no-undo.
    define input parameter pcAna3-cd  as character  no-undo.
    define input parameter table-handle phttPedibud.
    define variable vhttBuffer as handle  no-undo.
    define buffer pedibud for pedibud.

    vhttBuffer = phttPedibud:default-buffer-handle.
    if pcAna3-cd = ?
    then for each pedibud no-lock
        where pedibud.gi-ttyid = pcGi-ttyid
          and pedibud.type = plType
          and pedibud.ana1-cd = pcAna1-cd
          and pedibud.ana2-cd = pcAna2-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pedibud:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each pedibud no-lock
        where pedibud.gi-ttyid = pcGi-ttyid
          and pedibud.type = plType
          and pedibud.ana1-cd = pcAna1-cd
          and pedibud.ana2-cd = pcAna2-cd
          and pedibud.ana3-cd = pcAna3-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pedibud:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPedibud no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatePedibud private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhGi-ttyid    as handle  no-undo.
    define variable vhType    as handle  no-undo.
    define variable vhAna1-cd    as handle  no-undo.
    define variable vhAna2-cd    as handle  no-undo.
    define variable vhAna3-cd    as handle  no-undo.
    define variable vhAna4-cd    as handle  no-undo.
    define buffer pedibud for pedibud.

    create query vhttquery.
    vhttBuffer = ghttPedibud:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttPedibud:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhGi-ttyid, output vhType, output vhAna1-cd, output vhAna2-cd, output vhAna3-cd, output vhAna4-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first pedibud exclusive-lock
                where rowid(pedibud) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer pedibud:handle, 'gi-ttyid/type/ana1-cd/ana2-cd/ana3-cd/ana4-cd: ', substitute('&1/&2/&3/&4/&5/&6', vhGi-ttyid:buffer-value(), vhType:buffer-value(), vhAna1-cd:buffer-value(), vhAna2-cd:buffer-value(), vhAna3-cd:buffer-value(), vhAna4-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer pedibud:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createPedibud private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer pedibud for pedibud.

    create query vhttquery.
    vhttBuffer = ghttPedibud:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttPedibud:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create pedibud.
            if not outils:copyValidField(buffer pedibud:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deletePedibud private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhGi-ttyid    as handle  no-undo.
    define variable vhType    as handle  no-undo.
    define variable vhAna1-cd    as handle  no-undo.
    define variable vhAna2-cd    as handle  no-undo.
    define variable vhAna3-cd    as handle  no-undo.
    define variable vhAna4-cd    as handle  no-undo.
    define buffer pedibud for pedibud.

    create query vhttquery.
    vhttBuffer = ghttPedibud:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttPedibud:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhGi-ttyid, output vhType, output vhAna1-cd, output vhAna2-cd, output vhAna3-cd, output vhAna4-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first pedibud exclusive-lock
                where rowid(Pedibud) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer pedibud:handle, 'gi-ttyid/type/ana1-cd/ana2-cd/ana3-cd/ana4-cd: ', substitute('&1/&2/&3/&4/&5/&6', vhGi-ttyid:buffer-value(), vhType:buffer-value(), vhAna1-cd:buffer-value(), vhAna2-cd:buffer-value(), vhAna3-cd:buffer-value(), vhAna4-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete pedibud no-error.
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

