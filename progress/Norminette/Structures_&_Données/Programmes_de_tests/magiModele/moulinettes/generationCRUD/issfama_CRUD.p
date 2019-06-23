/*------------------------------------------------------------------------
File        : issfama_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table issfama
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/issfama.i}
{application/include/error.i}
define variable ghttissfama as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phFam-cd as handle, output phSfam-cd as handle, output phSsfam-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/fam-cd/sfam-cd/ssfam-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'fam-cd' then phFam-cd = phBuffer:buffer-field(vi).
            when 'sfam-cd' then phSfam-cd = phBuffer:buffer-field(vi).
            when 'ssfam-cd' then phSsfam-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIssfama private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIssfama.
    run updateIssfama.
    run createIssfama.
end procedure.

procedure setIssfama:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIssfama.
    ghttIssfama = phttIssfama.
    run crudIssfama.
    delete object phttIssfama.
end procedure.

procedure readIssfama:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table issfama fichier des sous-sous-familles d'affaires
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piFam-cd   as integer    no-undo.
    define input parameter piSfam-cd  as integer    no-undo.
    define input parameter piSsfam-cd as integer    no-undo.
    define input parameter table-handle phttIssfama.
    define variable vhttBuffer as handle no-undo.
    define buffer issfama for issfama.

    vhttBuffer = phttIssfama:default-buffer-handle.
    for first issfama no-lock
        where issfama.soc-cd = piSoc-cd
          and issfama.fam-cd = piFam-cd
          and issfama.sfam-cd = piSfam-cd
          and issfama.ssfam-cd = piSsfam-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer issfama:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIssfama no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIssfama:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table issfama fichier des sous-sous-familles d'affaires
    Notes  : service externe. Critère piSfam-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piFam-cd   as integer    no-undo.
    define input parameter piSfam-cd  as integer    no-undo.
    define input parameter table-handle phttIssfama.
    define variable vhttBuffer as handle  no-undo.
    define buffer issfama for issfama.

    vhttBuffer = phttIssfama:default-buffer-handle.
    if piSfam-cd = ?
    then for each issfama no-lock
        where issfama.soc-cd = piSoc-cd
          and issfama.fam-cd = piFam-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer issfama:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each issfama no-lock
        where issfama.soc-cd = piSoc-cd
          and issfama.fam-cd = piFam-cd
          and issfama.sfam-cd = piSfam-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer issfama:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIssfama no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIssfama private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhFam-cd    as handle  no-undo.
    define variable vhSfam-cd    as handle  no-undo.
    define variable vhSsfam-cd    as handle  no-undo.
    define buffer issfama for issfama.

    create query vhttquery.
    vhttBuffer = ghttIssfama:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIssfama:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhFam-cd, output vhSfam-cd, output vhSsfam-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first issfama exclusive-lock
                where rowid(issfama) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer issfama:handle, 'soc-cd/fam-cd/sfam-cd/ssfam-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhFam-cd:buffer-value(), vhSfam-cd:buffer-value(), vhSsfam-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer issfama:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIssfama private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer issfama for issfama.

    create query vhttquery.
    vhttBuffer = ghttIssfama:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIssfama:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create issfama.
            if not outils:copyValidField(buffer issfama:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIssfama private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhFam-cd    as handle  no-undo.
    define variable vhSfam-cd    as handle  no-undo.
    define variable vhSsfam-cd    as handle  no-undo.
    define buffer issfama for issfama.

    create query vhttquery.
    vhttBuffer = ghttIssfama:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIssfama:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhFam-cd, output vhSfam-cd, output vhSsfam-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first issfama exclusive-lock
                where rowid(Issfama) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer issfama:handle, 'soc-cd/fam-cd/sfam-cd/ssfam-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhFam-cd:buffer-value(), vhSfam-cd:buffer-value(), vhSsfam-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete issfama no-error.
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

