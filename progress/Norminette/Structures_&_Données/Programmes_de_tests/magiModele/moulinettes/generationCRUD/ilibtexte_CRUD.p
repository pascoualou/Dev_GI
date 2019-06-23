/*------------------------------------------------------------------------
File        : ilibtexte_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ilibtexte
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ilibtexte.i}
{application/include/error.i}
define variable ghttilibtexte as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phLibtexte-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/libtexte-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'libtexte-cd' then phLibtexte-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIlibtexte private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIlibtexte.
    run updateIlibtexte.
    run createIlibtexte.
end procedure.

procedure setIlibtexte:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIlibtexte.
    ghttIlibtexte = phttIlibtexte.
    run crudIlibtexte.
    delete object phttIlibtexte.
end procedure.

procedure readIlibtexte:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ilibtexte Fichier libelle texte
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piLibtexte-cd as integer    no-undo.
    define input parameter table-handle phttIlibtexte.
    define variable vhttBuffer as handle no-undo.
    define buffer ilibtexte for ilibtexte.

    vhttBuffer = phttIlibtexte:default-buffer-handle.
    for first ilibtexte no-lock
        where ilibtexte.soc-cd = piSoc-cd
          and ilibtexte.libtexte-cd = piLibtexte-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibtexte:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlibtexte no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIlibtexte:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ilibtexte Fichier libelle texte
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter table-handle phttIlibtexte.
    define variable vhttBuffer as handle  no-undo.
    define buffer ilibtexte for ilibtexte.

    vhttBuffer = phttIlibtexte:default-buffer-handle.
    if piSoc-cd = ?
    then for each ilibtexte no-lock
        where ilibtexte.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibtexte:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ilibtexte no-lock
        where ilibtexte.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilibtexte:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlibtexte no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIlibtexte private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhLibtexte-cd    as handle  no-undo.
    define buffer ilibtexte for ilibtexte.

    create query vhttquery.
    vhttBuffer = ghttIlibtexte:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIlibtexte:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhLibtexte-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ilibtexte exclusive-lock
                where rowid(ilibtexte) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ilibtexte:handle, 'soc-cd/libtexte-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhLibtexte-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ilibtexte:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIlibtexte private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ilibtexte for ilibtexte.

    create query vhttquery.
    vhttBuffer = ghttIlibtexte:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIlibtexte:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ilibtexte.
            if not outils:copyValidField(buffer ilibtexte:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIlibtexte private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhLibtexte-cd    as handle  no-undo.
    define buffer ilibtexte for ilibtexte.

    create query vhttquery.
    vhttBuffer = ghttIlibtexte:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIlibtexte:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhLibtexte-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ilibtexte exclusive-lock
                where rowid(Ilibtexte) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ilibtexte:handle, 'soc-cd/libtexte-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhLibtexte-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ilibtexte no-error.
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

