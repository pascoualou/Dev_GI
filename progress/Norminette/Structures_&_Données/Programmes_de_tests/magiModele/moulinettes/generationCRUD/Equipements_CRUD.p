/*------------------------------------------------------------------------
File        : Equipements_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table Equipements
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/Equipements.i}
{application/include/error.i}
define variable ghttEquipements as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCcodeequipement as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cCodeEquipement, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cCodeEquipement' then phCcodeequipement = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudEquipements private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteEquipements.
    run updateEquipements.
    run createEquipements.
end procedure.

procedure setEquipements:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttEquipements.
    ghttEquipements = phttEquipements.
    run crudEquipements.
    delete object phttEquipements.
end procedure.

procedure readEquipements:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table Equipements 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCcodeequipement as character  no-undo.
    define input parameter table-handle phttEquipements.
    define variable vhttBuffer as handle no-undo.
    define buffer Equipements for Equipements.

    vhttBuffer = phttEquipements:default-buffer-handle.
    for first Equipements no-lock
        where Equipements.cCodeEquipement = pcCcodeequipement:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer Equipements:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEquipements no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getEquipements:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table Equipements 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttEquipements.
    define variable vhttBuffer as handle  no-undo.
    define buffer Equipements for Equipements.

    vhttBuffer = phttEquipements:default-buffer-handle.
    for each Equipements no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer Equipements:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEquipements no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateEquipements private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCcodeequipement    as handle  no-undo.
    define buffer Equipements for Equipements.

    create query vhttquery.
    vhttBuffer = ghttEquipements:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttEquipements:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCcodeequipement).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first Equipements exclusive-lock
                where rowid(Equipements) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer Equipements:handle, 'cCodeEquipement: ', substitute('&1', vhCcodeequipement:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer Equipements:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createEquipements private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer Equipements for Equipements.

    create query vhttquery.
    vhttBuffer = ghttEquipements:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttEquipements:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create Equipements.
            if not outils:copyValidField(buffer Equipements:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteEquipements private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCcodeequipement    as handle  no-undo.
    define buffer Equipements for Equipements.

    create query vhttquery.
    vhttBuffer = ghttEquipements:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttEquipements:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCcodeequipement).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first Equipements exclusive-lock
                where rowid(Equipements) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer Equipements:handle, 'cCodeEquipement: ', substitute('&1', vhCcodeequipement:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete Equipements no-error.
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

