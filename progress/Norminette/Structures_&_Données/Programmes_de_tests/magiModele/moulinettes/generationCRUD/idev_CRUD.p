/*------------------------------------------------------------------------
File        : idev_CRUD.p
Purpose     : Librairie contenant les procedures li�es � la mise � jour de la table idev
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table � condition
              que les champs de l'index unique soient tous pr�sents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit �tre positionn�e juste apr�s using
//{include/idev.i}
{application/include/error.i}
define variable ghttidev as handle no-undo.      // le handle de la temp table � mettre � jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phDev-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: r�cup�re les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/dev-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'dev-cd' then phDev-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIdev private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIdev.
    run updateIdev.
    run createIdev.
end procedure.

procedure setIdev:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIdev.
    ghttIdev = phttIdev.
    run crudIdev.
    delete object phttIdev.
end procedure.

procedure readIdev:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table idev Liste des cours des devises
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd as integer    no-undo.
    define input parameter pcDev-cd as character  no-undo.
    define input parameter table-handle phttIdev.
    define variable vhttBuffer as handle no-undo.
    define buffer idev for idev.

    vhttBuffer = phttIdev:default-buffer-handle.
    for first idev no-lock
        where idev.soc-cd = piSoc-cd
          and idev.dev-cd = pcDev-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer idev:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIdev no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIdev:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table idev Liste des cours des devises
    Notes  : service externe. Crit�re piSoc-cd = ? si pas � prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd as integer    no-undo.
    define input parameter table-handle phttIdev.
    define variable vhttBuffer as handle  no-undo.
    define buffer idev for idev.

    vhttBuffer = phttIdev:default-buffer-handle.
    if piSoc-cd = ?
    then for each idev no-lock
        where idev.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer idev:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each idev no-lock
        where idev.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer idev:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIdev no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIdev private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhDev-cd    as handle  no-undo.
    define buffer idev for idev.

    create query vhttquery.
    vhttBuffer = ghttIdev:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIdev:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhDev-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first idev exclusive-lock
                where rowid(idev) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer idev:handle, 'soc-cd/dev-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhDev-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer idev:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIdev private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer idev for idev.

    create query vhttquery.
    vhttBuffer = ghttIdev:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIdev:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create idev.
            if not outils:copyValidField(buffer idev:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIdev private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhDev-cd    as handle  no-undo.
    define buffer idev for idev.

    create query vhttquery.
    vhttBuffer = ghttIdev:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIdev:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhDev-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first idev exclusive-lock
                where rowid(Idev) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer idev:handle, 'soc-cd/dev-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhDev-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete idev no-error.
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

