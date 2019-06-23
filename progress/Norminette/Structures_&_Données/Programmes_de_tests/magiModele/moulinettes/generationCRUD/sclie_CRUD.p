/*------------------------------------------------------------------------
File        : sclie_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table sclie
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/sclie.i}
{application/include/error.i}
define variable ghttsclie as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNosoc as handle, output phTpcon as handle, output phNocon as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nosoc/tpcon/nocon, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nosoc' then phNosoc = phBuffer:buffer-field(vi).
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudSclie private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteSclie.
    run updateSclie.
    run createSclie.
end procedure.

procedure setSclie:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSclie.
    ghttSclie = phttSclie.
    run crudSclie.
    delete object phttSclie.
end procedure.

procedure readSclie:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table sclie 0110/0169 : lien société porteurs de parts avec un mandat
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNosoc as integer    no-undo.
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as integer    no-undo.
    define input parameter table-handle phttSclie.
    define variable vhttBuffer as handle no-undo.
    define buffer sclie for sclie.

    vhttBuffer = phttSclie:default-buffer-handle.
    for first sclie no-lock
        where sclie.nosoc = piNosoc
          and sclie.tpcon = pcTpcon
          and sclie.nocon = piNocon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer sclie:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSclie no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getSclie:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table sclie 0110/0169 : lien société porteurs de parts avec un mandat
    Notes  : service externe. Critère pcTpcon = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNosoc as integer    no-undo.
    define input parameter pcTpcon as character  no-undo.
    define input parameter table-handle phttSclie.
    define variable vhttBuffer as handle  no-undo.
    define buffer sclie for sclie.

    vhttBuffer = phttSclie:default-buffer-handle.
    if pcTpcon = ?
    then for each sclie no-lock
        where sclie.nosoc = piNosoc:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer sclie:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each sclie no-lock
        where sclie.nosoc = piNosoc
          and sclie.tpcon = pcTpcon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer sclie:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSclie no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateSclie private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNosoc    as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define buffer sclie for sclie.

    create query vhttquery.
    vhttBuffer = ghttSclie:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttSclie:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNosoc, output vhTpcon, output vhNocon).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first sclie exclusive-lock
                where rowid(sclie) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer sclie:handle, 'nosoc/tpcon/nocon: ', substitute('&1/&2/&3', vhNosoc:buffer-value(), vhTpcon:buffer-value(), vhNocon:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer sclie:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createSclie private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer sclie for sclie.

    create query vhttquery.
    vhttBuffer = ghttSclie:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttSclie:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create sclie.
            if not outils:copyValidField(buffer sclie:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteSclie private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNosoc    as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define buffer sclie for sclie.

    create query vhttquery.
    vhttBuffer = ghttSclie:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttSclie:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNosoc, output vhTpcon, output vhNocon).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first sclie exclusive-lock
                where rowid(Sclie) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer sclie:handle, 'nosoc/tpcon/nocon: ', substitute('&1/&2/&3', vhNosoc:buffer-value(), vhTpcon:buffer-value(), vhNocon:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete sclie no-error.
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

