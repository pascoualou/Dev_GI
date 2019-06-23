/*------------------------------------------------------------------------
File        : scfic_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table scfic
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/scfic.i}
{application/include/error.i}
define variable ghttscfic as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNosoc as handle, output phDthist as handle, output phNosui03 as handle, output phNmfic as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nosoc/dthist/nosui03/NmFic, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nosoc' then phNosoc = phBuffer:buffer-field(vi).
            when 'dthist' then phDthist = phBuffer:buffer-field(vi).
            when 'nosui03' then phNosui03 = phBuffer:buffer-field(vi).
            when 'NmFic' then phNmfic = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudScfic private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteScfic.
    run updateScfic.
    run createScfic.
end procedure.

procedure setScfic:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttScfic.
    ghttScfic = phttScfic.
    run crudScfic.
    delete object phttScfic.
end procedure.

procedure readScfic:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table scfic 0110/0169 : Fichiers joints liés à une société , à une opération et à une date
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNosoc   as integer    no-undo.
    define input parameter pdaDthist  as date       no-undo.
    define input parameter piNosui03 as integer    no-undo.
    define input parameter pcNmfic   as character  no-undo.
    define input parameter table-handle phttScfic.
    define variable vhttBuffer as handle no-undo.
    define buffer scfic for scfic.

    vhttBuffer = phttScfic:default-buffer-handle.
    for first scfic no-lock
        where scfic.nosoc = piNosoc
          and scfic.dthist = pdaDthist
          and scfic.nosui03 = piNosui03
          and scfic.NmFic = pcNmfic:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer scfic:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttScfic no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getScfic:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table scfic 0110/0169 : Fichiers joints liés à une société , à une opération et à une date
    Notes  : service externe. Critère piNosui03 = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNosoc   as integer    no-undo.
    define input parameter pdaDthist  as date       no-undo.
    define input parameter piNosui03 as integer    no-undo.
    define input parameter table-handle phttScfic.
    define variable vhttBuffer as handle  no-undo.
    define buffer scfic for scfic.

    vhttBuffer = phttScfic:default-buffer-handle.
    if piNosui03 = ?
    then for each scfic no-lock
        where scfic.nosoc = piNosoc
          and scfic.dthist = pdaDthist:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer scfic:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each scfic no-lock
        where scfic.nosoc = piNosoc
          and scfic.dthist = pdaDthist
          and scfic.nosui03 = piNosui03:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer scfic:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttScfic no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateScfic private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNosoc    as handle  no-undo.
    define variable vhDthist    as handle  no-undo.
    define variable vhNosui03    as handle  no-undo.
    define variable vhNmfic    as handle  no-undo.
    define buffer scfic for scfic.

    create query vhttquery.
    vhttBuffer = ghttScfic:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttScfic:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNosoc, output vhDthist, output vhNosui03, output vhNmfic).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first scfic exclusive-lock
                where rowid(scfic) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer scfic:handle, 'nosoc/dthist/nosui03/NmFic: ', substitute('&1/&2/&3/&4', vhNosoc:buffer-value(), vhDthist:buffer-value(), vhNosui03:buffer-value(), vhNmfic:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer scfic:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createScfic private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer scfic for scfic.

    create query vhttquery.
    vhttBuffer = ghttScfic:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttScfic:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create scfic.
            if not outils:copyValidField(buffer scfic:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteScfic private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNosoc    as handle  no-undo.
    define variable vhDthist    as handle  no-undo.
    define variable vhNosui03    as handle  no-undo.
    define variable vhNmfic    as handle  no-undo.
    define buffer scfic for scfic.

    create query vhttquery.
    vhttBuffer = ghttScfic:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttScfic:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNosoc, output vhDthist, output vhNosui03, output vhNmfic).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first scfic exclusive-lock
                where rowid(Scfic) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer scfic:handle, 'nosoc/dthist/nosui03/NmFic: ', substitute('&1/&2/&3/&4', vhNosoc:buffer-value(), vhDthist:buffer-value(), vhNosui03:buffer-value(), vhNmfic:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete scfic no-error.
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

