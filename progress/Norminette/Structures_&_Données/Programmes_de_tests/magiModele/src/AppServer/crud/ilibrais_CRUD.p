/*------------------------------------------------------------------------
File        : ilibrais_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ilibrais
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ilibrais.i}
{application/include/error.i}
define variable ghttilibrais as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phLibrais-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/librais-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'librais-cd' then phLibrais-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIlibrais private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIlibrais.
    run updateIlibrais.
    run createIlibrais.
end procedure.

procedure setIlibrais:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIlibrais.
    ghttIlibrais = phttIlibrais.
    run crudIlibrais.
    delete object phttIlibrais.
end procedure.

procedure readIlibrais:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ilibrais Liste des libelles des differentes raisons sociales des tiers.
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piLibrais-cd as integer    no-undo.
    define input parameter table-handle phttIlibrais.
    define variable vhttBuffer as handle no-undo.
    define buffer ilibrais for ilibrais.

    vhttBuffer = phttIlibrais:default-buffer-handle.
    for first ilibrais no-lock
        where ilibrais.soc-cd = piSoc-cd
          and ilibrais.librais-cd = piLibrais-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibrais:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlibrais no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIlibrais:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ilibrais Liste des libelles des differentes raisons sociales des tiers.
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter table-handle phttIlibrais.
    define variable vhttBuffer as handle  no-undo.
    define buffer ilibrais for ilibrais.

    vhttBuffer = phttIlibrais:default-buffer-handle.
    if piSoc-cd = ?
    then for each ilibrais no-lock
        where ilibrais.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibrais:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ilibrais no-lock
        where ilibrais.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibrais:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlibrais no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIlibrais private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhLibrais-cd    as handle  no-undo.
    define buffer ilibrais for ilibrais.

    create query vhttquery.
    vhttBuffer = ghttIlibrais:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIlibrais:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhLibrais-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ilibrais exclusive-lock
                where rowid(ilibrais) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ilibrais:handle, 'soc-cd/librais-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhLibrais-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ilibrais:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIlibrais private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ilibrais for ilibrais.

    create query vhttquery.
    vhttBuffer = ghttIlibrais:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIlibrais:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ilibrais.
            if not outils:copyValidField(buffer ilibrais:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIlibrais private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhLibrais-cd    as handle  no-undo.
    define buffer ilibrais for ilibrais.

    create query vhttquery.
    vhttBuffer = ghttIlibrais:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIlibrais:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhLibrais-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ilibrais exclusive-lock
                where rowid(Ilibrais) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ilibrais:handle, 'soc-cd/librais-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhLibrais-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ilibrais no-error.
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

