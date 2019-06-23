/*------------------------------------------------------------------------
File        : ilibel_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ilibel
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ilibel.i}
{application/include/error.i}
define variable ghttilibel as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phActivite-cd as handle, output phLiblang-cd as handle, output phLibel-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/activite-cd/liblang-cd/libel-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'activite-cd' then phActivite-cd = phBuffer:buffer-field(vi).
            when 'liblang-cd' then phLiblang-cd = phBuffer:buffer-field(vi).
            when 'libel-cd' then phLibel-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIlibel private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIlibel.
    run updateIlibel.
    run createIlibel.
end procedure.

procedure setIlibel:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIlibel.
    ghttIlibel = phttIlibel.
    run crudIlibel.
    delete object phttIlibel.
end procedure.

procedure readIlibel:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ilibel Table de libelles
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter piActivite-cd as integer    no-undo.
    define input parameter piLiblang-cd  as integer    no-undo.
    define input parameter piLibel-cd    as integer    no-undo.
    define input parameter table-handle phttIlibel.
    define variable vhttBuffer as handle no-undo.
    define buffer ilibel for ilibel.

    vhttBuffer = phttIlibel:default-buffer-handle.
    for first ilibel no-lock
        where ilibel.soc-cd = piSoc-cd
          and ilibel.etab-cd = piEtab-cd
          and ilibel.activite-cd = piActivite-cd
          and ilibel.liblang-cd = piLiblang-cd
          and ilibel.libel-cd = piLibel-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibel:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlibel no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIlibel:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ilibel Table de libelles
    Notes  : service externe. Critère piLiblang-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter piActivite-cd as integer    no-undo.
    define input parameter piLiblang-cd  as integer    no-undo.
    define input parameter table-handle phttIlibel.
    define variable vhttBuffer as handle  no-undo.
    define buffer ilibel for ilibel.

    vhttBuffer = phttIlibel:default-buffer-handle.
    if piLiblang-cd = ?
    then for each ilibel no-lock
        where ilibel.soc-cd = piSoc-cd
          and ilibel.etab-cd = piEtab-cd
          and ilibel.activite-cd = piActivite-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibel:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ilibel no-lock
        where ilibel.soc-cd = piSoc-cd
          and ilibel.etab-cd = piEtab-cd
          and ilibel.activite-cd = piActivite-cd
          and ilibel.liblang-cd = piLiblang-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibel:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlibel no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIlibel private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhActivite-cd    as handle  no-undo.
    define variable vhLiblang-cd    as handle  no-undo.
    define variable vhLibel-cd    as handle  no-undo.
    define buffer ilibel for ilibel.

    create query vhttquery.
    vhttBuffer = ghttIlibel:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIlibel:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhActivite-cd, output vhLiblang-cd, output vhLibel-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ilibel exclusive-lock
                where rowid(ilibel) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ilibel:handle, 'soc-cd/etab-cd/activite-cd/liblang-cd/libel-cd: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhActivite-cd:buffer-value(), vhLiblang-cd:buffer-value(), vhLibel-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ilibel:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIlibel private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ilibel for ilibel.

    create query vhttquery.
    vhttBuffer = ghttIlibel:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIlibel:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ilibel.
            if not outils:copyValidField(buffer ilibel:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIlibel private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhActivite-cd    as handle  no-undo.
    define variable vhLiblang-cd    as handle  no-undo.
    define variable vhLibel-cd    as handle  no-undo.
    define buffer ilibel for ilibel.

    create query vhttquery.
    vhttBuffer = ghttIlibel:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIlibel:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhActivite-cd, output vhLiblang-cd, output vhLibel-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ilibel exclusive-lock
                where rowid(Ilibel) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ilibel:handle, 'soc-cd/etab-cd/activite-cd/liblang-cd/libel-cd: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhActivite-cd:buffer-value(), vhLiblang-cd:buffer-value(), vhLibel-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ilibel no-error.
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

