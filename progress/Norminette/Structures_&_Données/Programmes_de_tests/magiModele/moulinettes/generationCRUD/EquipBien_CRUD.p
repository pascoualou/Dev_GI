/*------------------------------------------------------------------------
File        : EquipBien_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table EquipBien
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/EquipBien.i}
{application/include/error.i}
define variable ghttEquipBien as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCtypebien as handle, output phInumerobien as handle, output phCcodeequipement as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cTypeBien/iNumeroBien/cCodeEquipement, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cTypeBien' then phCtypebien = phBuffer:buffer-field(vi).
            when 'iNumeroBien' then phInumerobien = phBuffer:buffer-field(vi).
            when 'cCodeEquipement' then phCcodeequipement = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudEquipbien private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteEquipbien.
    run updateEquipbien.
    run createEquipbien.
end procedure.

procedure setEquipbien:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttEquipbien.
    ghttEquipbien = phttEquipbien.
    run crudEquipbien.
    delete object phttEquipbien.
end procedure.

procedure readEquipbien:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table EquipBien Equipement de l'immeuble ou du lot
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCtypebien       as character  no-undo.
    define input parameter piInumerobien     as integer    no-undo.
    define input parameter pcCcodeequipement as character  no-undo.
    define input parameter table-handle phttEquipbien.
    define variable vhttBuffer as handle no-undo.
    define buffer EquipBien for EquipBien.

    vhttBuffer = phttEquipbien:default-buffer-handle.
    for first EquipBien no-lock
        where EquipBien.cTypeBien = pcCtypebien
          and EquipBien.iNumeroBien = piInumerobien
          and EquipBien.cCodeEquipement = pcCcodeequipement:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer EquipBien:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEquipbien no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getEquipbien:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table EquipBien Equipement de l'immeuble ou du lot
    Notes  : service externe. Critère piInumerobien = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcCtypebien       as character  no-undo.
    define input parameter piInumerobien     as integer    no-undo.
    define input parameter table-handle phttEquipbien.
    define variable vhttBuffer as handle  no-undo.
    define buffer EquipBien for EquipBien.

    vhttBuffer = phttEquipbien:default-buffer-handle.
    if piInumerobien = ?
    then for each EquipBien no-lock
        where EquipBien.cTypeBien = pcCtypebien:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer EquipBien:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each EquipBien no-lock
        where EquipBien.cTypeBien = pcCtypebien
          and EquipBien.iNumeroBien = piInumerobien:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer EquipBien:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEquipbien no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateEquipbien private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCtypebien    as handle  no-undo.
    define variable vhInumerobien    as handle  no-undo.
    define variable vhCcodeequipement    as handle  no-undo.
    define buffer EquipBien for EquipBien.

    create query vhttquery.
    vhttBuffer = ghttEquipbien:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttEquipbien:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCtypebien, output vhInumerobien, output vhCcodeequipement).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first EquipBien exclusive-lock
                where rowid(EquipBien) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer EquipBien:handle, 'cTypeBien/iNumeroBien/cCodeEquipement: ', substitute('&1/&2/&3', vhCtypebien:buffer-value(), vhInumerobien:buffer-value(), vhCcodeequipement:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer EquipBien:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createEquipbien private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer EquipBien for EquipBien.

    create query vhttquery.
    vhttBuffer = ghttEquipbien:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttEquipbien:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create EquipBien.
            if not outils:copyValidField(buffer EquipBien:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteEquipbien private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCtypebien    as handle  no-undo.
    define variable vhInumerobien    as handle  no-undo.
    define variable vhCcodeequipement    as handle  no-undo.
    define buffer EquipBien for EquipBien.

    create query vhttquery.
    vhttBuffer = ghttEquipbien:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttEquipbien:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCtypebien, output vhInumerobien, output vhCcodeequipement).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first EquipBien exclusive-lock
                where rowid(Equipbien) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer EquipBien:handle, 'cTypeBien/iNumeroBien/cCodeEquipement: ', substitute('&1/&2/&3', vhCtypebien:buffer-value(), vhInumerobien:buffer-value(), vhCcodeequipement:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete EquipBien no-error.
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

