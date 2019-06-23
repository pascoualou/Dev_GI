/*------------------------------------------------------------------------
File        : Themes_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table Themes
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/Themes.i}
{application/include/error.i}
define variable ghttThemes as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCcodetheme as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cCodeTheme, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cCodeTheme' then phCcodetheme = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudThemes private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteThemes.
    run updateThemes.
    run createThemes.
end procedure.

procedure setThemes:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttThemes.
    ghttThemes = phttThemes.
    run crudThemes.
    delete object phttThemes.
end procedure.

procedure readThemes:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table Themes 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCcodetheme as character  no-undo.
    define input parameter table-handle phttThemes.
    define variable vhttBuffer as handle no-undo.
    define buffer Themes for Themes.

    vhttBuffer = phttThemes:default-buffer-handle.
    for first Themes no-lock
        where Themes.cCodeTheme = pcCcodetheme:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer Themes:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttThemes no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getThemes:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table Themes 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttThemes.
    define variable vhttBuffer as handle  no-undo.
    define buffer Themes for Themes.

    vhttBuffer = phttThemes:default-buffer-handle.
    for each Themes no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer Themes:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttThemes no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateThemes private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCcodetheme    as handle  no-undo.
    define buffer Themes for Themes.

    create query vhttquery.
    vhttBuffer = ghttThemes:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttThemes:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCcodetheme).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first Themes exclusive-lock
                where rowid(Themes) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer Themes:handle, 'cCodeTheme: ', substitute('&1', vhCcodetheme:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer Themes:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createThemes private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer Themes for Themes.

    create query vhttquery.
    vhttBuffer = ghttThemes:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttThemes:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create Themes.
            if not outils:copyValidField(buffer Themes:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteThemes private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCcodetheme    as handle  no-undo.
    define buffer Themes for Themes.

    create query vhttquery.
    vhttBuffer = ghttThemes:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttThemes:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCcodetheme).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first Themes exclusive-lock
                where rowid(Themes) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer Themes:handle, 'cCodeTheme: ', substitute('&1', vhCcodetheme:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete Themes no-error.
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

