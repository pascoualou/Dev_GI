/*------------------------------------------------------------------------
File        : indfo_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table indfo
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/indfo.i}
{application/include/error.i}
define variable ghttindfo as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCdind as handle, output phNoeud as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cdind/noeud, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cdind' then phCdind = phBuffer:buffer-field(vi).
            when 'noeud' then phNoeud = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIndfo private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIndfo.
    run updateIndfo.
    run createIndfo.
end procedure.

procedure setIndfo:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIndfo.
    ghttIndfo = phttIndfo.
    run crudIndfo.
    delete object phttIndfo.
end procedure.

procedure readIndfo:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table indfo 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCdind as character  no-undo.
    define input parameter piNoeud as integer    no-undo.
    define input parameter table-handle phttIndfo.
    define variable vhttBuffer as handle no-undo.
    define buffer indfo for indfo.

    vhttBuffer = phttIndfo:default-buffer-handle.
    for first indfo no-lock
        where indfo.cdind = pcCdind
          and indfo.noeud = piNoeud:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer indfo:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIndfo no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIndfo:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table indfo 
    Notes  : service externe. Critère pcCdind = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcCdind as character  no-undo.
    define input parameter table-handle phttIndfo.
    define variable vhttBuffer as handle  no-undo.
    define buffer indfo for indfo.

    vhttBuffer = phttIndfo:default-buffer-handle.
    if pcCdind = ?
    then for each indfo no-lock
        where indfo.cdind = pcCdind:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer indfo:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each indfo no-lock
        where indfo.cdind = pcCdind:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer indfo:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIndfo no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIndfo private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdind    as handle  no-undo.
    define variable vhNoeud    as handle  no-undo.
    define buffer indfo for indfo.

    create query vhttquery.
    vhttBuffer = ghttIndfo:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIndfo:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdind, output vhNoeud).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first indfo exclusive-lock
                where rowid(indfo) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer indfo:handle, 'cdind/noeud: ', substitute('&1/&2', vhCdind:buffer-value(), vhNoeud:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer indfo:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIndfo private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer indfo for indfo.

    create query vhttquery.
    vhttBuffer = ghttIndfo:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIndfo:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create indfo.
            if not outils:copyValidField(buffer indfo:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIndfo private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdind    as handle  no-undo.
    define variable vhNoeud    as handle  no-undo.
    define buffer indfo for indfo.

    create query vhttquery.
    vhttBuffer = ghttIndfo:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIndfo:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdind, output vhNoeud).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first indfo exclusive-lock
                where rowid(Indfo) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer indfo:handle, 'cdind/noeud: ', substitute('&1/&2', vhCdind:buffer-value(), vhNoeud:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete indfo no-error.
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

