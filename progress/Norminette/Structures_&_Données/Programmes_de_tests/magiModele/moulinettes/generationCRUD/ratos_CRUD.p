/*------------------------------------------------------------------------
File        : ratos_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ratos
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ratos.i}
{application/include/error.i}
define variable ghttratos as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phNofou as handle, output phNorat as handle, output phNoord as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpcon/nocon/NoFou/norat/NoOrd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
            when 'NoFou' then phNofou = phBuffer:buffer-field(vi).
            when 'norat' then phNorat = phBuffer:buffer-field(vi).
            when 'NoOrd' then phNoord = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudRatos private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteRatos.
    run updateRatos.
    run createRatos.
end procedure.

procedure setRatos:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttRatos.
    ghttRatos = phttRatos.
    run crudRatos.
    delete object phttRatos.
end procedure.

procedure readRatos:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ratos Chaine Travaux : Table de rattachement des Ordres de Service
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as integer    no-undo.
    define input parameter piNofou as integer    no-undo.
    define input parameter piNorat as integer    no-undo.
    define input parameter piNoord as integer    no-undo.
    define input parameter table-handle phttRatos.
    define variable vhttBuffer as handle no-undo.
    define buffer ratos for ratos.

    vhttBuffer = phttRatos:default-buffer-handle.
    for first ratos no-lock
        where ratos.tpcon = pcTpcon
          and ratos.nocon = piNocon
          and ratos.NoFou = piNofou
          and ratos.norat = piNorat
          and ratos.NoOrd = piNoord:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ratos:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRatos no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getRatos:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ratos Chaine Travaux : Table de rattachement des Ordres de Service
    Notes  : service externe. Critère piNorat = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as integer    no-undo.
    define input parameter piNofou as integer    no-undo.
    define input parameter piNorat as integer    no-undo.
    define input parameter table-handle phttRatos.
    define variable vhttBuffer as handle  no-undo.
    define buffer ratos for ratos.

    vhttBuffer = phttRatos:default-buffer-handle.
    if piNorat = ?
    then for each ratos no-lock
        where ratos.tpcon = pcTpcon
          and ratos.nocon = piNocon
          and ratos.NoFou = piNofou:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ratos:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ratos no-lock
        where ratos.tpcon = pcTpcon
          and ratos.nocon = piNocon
          and ratos.NoFou = piNofou
          and ratos.norat = piNorat:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ratos:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRatos no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateRatos private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNofou    as handle  no-undo.
    define variable vhNorat    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define buffer ratos for ratos.

    create query vhttquery.
    vhttBuffer = ghttRatos:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttRatos:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNofou, output vhNorat, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ratos exclusive-lock
                where rowid(ratos) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ratos:handle, 'tpcon/nocon/NoFou/norat/NoOrd: ', substitute('&1/&2/&3/&4/&5', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhNofou:buffer-value(), vhNorat:buffer-value(), vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ratos:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createRatos private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ratos for ratos.

    create query vhttquery.
    vhttBuffer = ghttRatos:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttRatos:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ratos.
            if not outils:copyValidField(buffer ratos:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteRatos private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNofou    as handle  no-undo.
    define variable vhNorat    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define buffer ratos for ratos.

    create query vhttquery.
    vhttBuffer = ghttRatos:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttRatos:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNofou, output vhNorat, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ratos exclusive-lock
                where rowid(Ratos) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ratos:handle, 'tpcon/nocon/NoFou/norat/NoOrd: ', substitute('&1/&2/&3/&4/&5', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhNofou:buffer-value(), vhNorat:buffer-value(), vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ratos no-error.
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

