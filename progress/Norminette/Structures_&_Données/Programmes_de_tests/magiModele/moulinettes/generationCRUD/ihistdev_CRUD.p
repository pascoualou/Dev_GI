/*------------------------------------------------------------------------
File        : ihistdev_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ihistdev
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ihistdev.i}
{application/include/error.i}
define variable ghttihistdev as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phDev-cd as handle, output phCours-da as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/dev-cd/cours-da, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'dev-cd' then phDev-cd = phBuffer:buffer-field(vi).
            when 'cours-da' then phCours-da = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIhistdev private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIhistdev.
    run updateIhistdev.
    run createIhistdev.
end procedure.

procedure setIhistdev:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIhistdev.
    ghttIhistdev = phttIhistdev.
    run crudIhistdev.
    delete object phttIhistdev.
end procedure.

procedure readIhistdev:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ihistdev Historique du cours des devises.
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter pcDev-cd   as character  no-undo.
    define input parameter pdaCours-da as date       no-undo.
    define input parameter table-handle phttIhistdev.
    define variable vhttBuffer as handle no-undo.
    define buffer ihistdev for ihistdev.

    vhttBuffer = phttIhistdev:default-buffer-handle.
    for first ihistdev no-lock
        where ihistdev.soc-cd = piSoc-cd
          and ihistdev.dev-cd = pcDev-cd
          and ihistdev.cours-da = pdaCours-da:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ihistdev:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIhistdev no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIhistdev:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ihistdev Historique du cours des devises.
    Notes  : service externe. Critère pcDev-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter pcDev-cd   as character  no-undo.
    define input parameter table-handle phttIhistdev.
    define variable vhttBuffer as handle  no-undo.
    define buffer ihistdev for ihistdev.

    vhttBuffer = phttIhistdev:default-buffer-handle.
    if pcDev-cd = ?
    then for each ihistdev no-lock
        where ihistdev.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ihistdev:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ihistdev no-lock
        where ihistdev.soc-cd = piSoc-cd
          and ihistdev.dev-cd = pcDev-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ihistdev:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIhistdev no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIhistdev private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhDev-cd    as handle  no-undo.
    define variable vhCours-da    as handle  no-undo.
    define buffer ihistdev for ihistdev.

    create query vhttquery.
    vhttBuffer = ghttIhistdev:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIhistdev:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhDev-cd, output vhCours-da).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ihistdev exclusive-lock
                where rowid(ihistdev) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ihistdev:handle, 'soc-cd/dev-cd/cours-da: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhDev-cd:buffer-value(), vhCours-da:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ihistdev:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIhistdev private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ihistdev for ihistdev.

    create query vhttquery.
    vhttBuffer = ghttIhistdev:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIhistdev:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ihistdev.
            if not outils:copyValidField(buffer ihistdev:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIhistdev private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhDev-cd    as handle  no-undo.
    define variable vhCours-da    as handle  no-undo.
    define buffer ihistdev for ihistdev.

    create query vhttquery.
    vhttBuffer = ghttIhistdev:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIhistdev:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhDev-cd, output vhCours-da).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ihistdev exclusive-lock
                where rowid(Ihistdev) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ihistdev:handle, 'soc-cd/dev-cd/cours-da: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhDev-cd:buffer-value(), vhCours-da:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ihistdev no-error.
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

