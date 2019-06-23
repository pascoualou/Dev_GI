/*------------------------------------------------------------------------
File        : iparfrais_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iparfrais
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/iparfrais.i}
{application/include/error.i}
define variable ghttiparfrais as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phNotfrais-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/notfrais-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'notfrais-cd' then phNotfrais-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIparfrais private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIparfrais.
    run updateIparfrais.
    run createIparfrais.
end procedure.

procedure setIparfrais:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIparfrais.
    ghttIparfrais = phttIparfrais.
    run crudIparfrais.
    delete object phttIparfrais.
end procedure.

procedure readIparfrais:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iparfrais Fichier parametre notes de frais.
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter piNotfrais-cd as integer    no-undo.
    define input parameter table-handle phttIparfrais.
    define variable vhttBuffer as handle no-undo.
    define buffer iparfrais for iparfrais.

    vhttBuffer = phttIparfrais:default-buffer-handle.
    for first iparfrais no-lock
        where iparfrais.soc-cd = piSoc-cd
          and iparfrais.etab-cd = piEtab-cd
          and iparfrais.notfrais-cd = piNotfrais-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iparfrais:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIparfrais no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIparfrais:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iparfrais Fichier parametre notes de frais.
    Notes  : service externe. Critère piEtab-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter table-handle phttIparfrais.
    define variable vhttBuffer as handle  no-undo.
    define buffer iparfrais for iparfrais.

    vhttBuffer = phttIparfrais:default-buffer-handle.
    if piEtab-cd = ?
    then for each iparfrais no-lock
        where iparfrais.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iparfrais:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each iparfrais no-lock
        where iparfrais.soc-cd = piSoc-cd
          and iparfrais.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iparfrais:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIparfrais no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIparfrais private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNotfrais-cd    as handle  no-undo.
    define buffer iparfrais for iparfrais.

    create query vhttquery.
    vhttBuffer = ghttIparfrais:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIparfrais:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNotfrais-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iparfrais exclusive-lock
                where rowid(iparfrais) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iparfrais:handle, 'soc-cd/etab-cd/notfrais-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNotfrais-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iparfrais:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIparfrais private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iparfrais for iparfrais.

    create query vhttquery.
    vhttBuffer = ghttIparfrais:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIparfrais:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iparfrais.
            if not outils:copyValidField(buffer iparfrais:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIparfrais private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNotfrais-cd    as handle  no-undo.
    define buffer iparfrais for iparfrais.

    create query vhttquery.
    vhttBuffer = ghttIparfrais:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIparfrais:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNotfrais-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iparfrais exclusive-lock
                where rowid(Iparfrais) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iparfrais:handle, 'soc-cd/etab-cd/notfrais-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNotfrais-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iparfrais no-error.
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

