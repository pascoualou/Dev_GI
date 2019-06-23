/*------------------------------------------------------------------------
File        : issfam_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table issfam
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/issfam.i}
{application/include/error.i}
define variable ghttissfam as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phLibtier-cd as handle, output phFam-cd as handle, output phSsfam-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/libtier-cd/fam-cd/ssfam-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'libtier-cd' then phLibtier-cd = phBuffer:buffer-field(vi).
            when 'fam-cd' then phFam-cd = phBuffer:buffer-field(vi).
            when 'ssfam-cd' then phSsfam-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIssfam private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIssfam.
    run updateIssfam.
    run createIssfam.
end procedure.

procedure setIssfam:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIssfam.
    ghttIssfam = phttIssfam.
    run crudIssfam.
    delete object phttIssfam.
end procedure.

procedure readIssfam:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table issfam Fichier des libelles de sous-famille.
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piLibtier-cd as integer    no-undo.
    define input parameter piFam-cd     as integer    no-undo.
    define input parameter piSsfam-cd   as integer    no-undo.
    define input parameter table-handle phttIssfam.
    define variable vhttBuffer as handle no-undo.
    define buffer issfam for issfam.

    vhttBuffer = phttIssfam:default-buffer-handle.
    for first issfam no-lock
        where issfam.soc-cd = piSoc-cd
          and issfam.libtier-cd = piLibtier-cd
          and issfam.fam-cd = piFam-cd
          and issfam.ssfam-cd = piSsfam-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer issfam:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIssfam no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIssfam:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table issfam Fichier des libelles de sous-famille.
    Notes  : service externe. Critère piFam-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piLibtier-cd as integer    no-undo.
    define input parameter piFam-cd     as integer    no-undo.
    define input parameter table-handle phttIssfam.
    define variable vhttBuffer as handle  no-undo.
    define buffer issfam for issfam.

    vhttBuffer = phttIssfam:default-buffer-handle.
    if piFam-cd = ?
    then for each issfam no-lock
        where issfam.soc-cd = piSoc-cd
          and issfam.libtier-cd = piLibtier-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer issfam:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each issfam no-lock
        where issfam.soc-cd = piSoc-cd
          and issfam.libtier-cd = piLibtier-cd
          and issfam.fam-cd = piFam-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer issfam:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIssfam no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIssfam private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhLibtier-cd    as handle  no-undo.
    define variable vhFam-cd    as handle  no-undo.
    define variable vhSsfam-cd    as handle  no-undo.
    define buffer issfam for issfam.

    create query vhttquery.
    vhttBuffer = ghttIssfam:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIssfam:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhLibtier-cd, output vhFam-cd, output vhSsfam-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first issfam exclusive-lock
                where rowid(issfam) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer issfam:handle, 'soc-cd/libtier-cd/fam-cd/ssfam-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhLibtier-cd:buffer-value(), vhFam-cd:buffer-value(), vhSsfam-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer issfam:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIssfam private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer issfam for issfam.

    create query vhttquery.
    vhttBuffer = ghttIssfam:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIssfam:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create issfam.
            if not outils:copyValidField(buffer issfam:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIssfam private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhLibtier-cd    as handle  no-undo.
    define variable vhFam-cd    as handle  no-undo.
    define variable vhSsfam-cd    as handle  no-undo.
    define buffer issfam for issfam.

    create query vhttquery.
    vhttBuffer = ghttIssfam:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIssfam:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhLibtier-cd, output vhFam-cd, output vhSsfam-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first issfam exclusive-lock
                where rowid(Issfam) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer issfam:handle, 'soc-cd/libtier-cd/fam-cd/ssfam-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhLibtier-cd:buffer-value(), vhFam-cd:buffer-value(), vhSsfam-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete issfam no-error.
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

