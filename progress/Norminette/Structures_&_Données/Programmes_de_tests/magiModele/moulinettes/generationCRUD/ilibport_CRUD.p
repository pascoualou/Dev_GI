/*------------------------------------------------------------------------
File        : ilibport_CRUD.p
Purpose     : Librairie contenant les procedures li�es � la mise � jour de la table ilibport
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table � condition
              que les champs de l'index unique soient tous pr�sents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit �tre positionn�e juste apr�s using
//{include/ilibport.i}
{application/include/error.i}
define variable ghttilibport as handle no-undo.      // le handle de la temp table � mettre � jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phPort-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: r�cup�re les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/port-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'port-cd' then phPort-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIlibport private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIlibport.
    run updateIlibport.
    run createIlibport.
end procedure.

procedure setIlibport:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIlibport.
    ghttIlibport = phttIlibport.
    run crudIlibport.
    delete object phttIlibport.
end procedure.

procedure readIlibport:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ilibport Portage Libelle
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piPort-cd as integer    no-undo.
    define input parameter table-handle phttIlibport.
    define variable vhttBuffer as handle no-undo.
    define buffer ilibport for ilibport.

    vhttBuffer = phttIlibport:default-buffer-handle.
    for first ilibport no-lock
        where ilibport.soc-cd = piSoc-cd
          and ilibport.port-cd = piPort-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibport:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlibport no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIlibport:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ilibport Portage Libelle
    Notes  : service externe. Crit�re piSoc-cd = ? si pas � prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter table-handle phttIlibport.
    define variable vhttBuffer as handle  no-undo.
    define buffer ilibport for ilibport.

    vhttBuffer = phttIlibport:default-buffer-handle.
    if piSoc-cd = ?
    then for each ilibport no-lock
        where ilibport.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibport:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ilibport no-lock
        where ilibport.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibport:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlibport no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIlibport private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhPort-cd    as handle  no-undo.
    define buffer ilibport for ilibport.

    create query vhttquery.
    vhttBuffer = ghttIlibport:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIlibport:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhPort-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ilibport exclusive-lock
                where rowid(ilibport) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ilibport:handle, 'soc-cd/port-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhPort-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ilibport:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIlibport private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ilibport for ilibport.

    create query vhttquery.
    vhttBuffer = ghttIlibport:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIlibport:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ilibport.
            if not outils:copyValidField(buffer ilibport:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIlibport private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhPort-cd    as handle  no-undo.
    define buffer ilibport for ilibport.

    create query vhttquery.
    vhttBuffer = ghttIlibport:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIlibport:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhPort-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ilibport exclusive-lock
                where rowid(Ilibport) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ilibport:handle, 'soc-cd/port-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhPort-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ilibport no-error.
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

