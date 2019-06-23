/*------------------------------------------------------------------------
File        : ifam_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifam
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifam.i}
{application/include/error.i}
define variable ghttifam as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phLibtier-cd as handle, output phFam-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/libtier-cd/fam-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'libtier-cd' then phLibtier-cd = phBuffer:buffer-field(vi).
            when 'fam-cd' then phFam-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIfam private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfam.
    run updateIfam.
    run createIfam.
end procedure.

procedure setIfam:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfam.
    ghttIfam = phttIfam.
    run crudIfam.
    delete object phttIfam.
end procedure.

procedure readIfam:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifam Fichier famille
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piLibtier-cd as integer    no-undo.
    define input parameter piFam-cd     as integer    no-undo.
    define input parameter table-handle phttIfam.
    define variable vhttBuffer as handle no-undo.
    define buffer ifam for ifam.

    vhttBuffer = phttIfam:default-buffer-handle.
    for first ifam no-lock
        where ifam.soc-cd = piSoc-cd
          and ifam.libtier-cd = piLibtier-cd
          and ifam.fam-cd = piFam-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifam:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfam no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfam:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifam Fichier famille
    Notes  : service externe. Critère piLibtier-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piLibtier-cd as integer    no-undo.
    define input parameter table-handle phttIfam.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifam for ifam.

    vhttBuffer = phttIfam:default-buffer-handle.
    if piLibtier-cd = ?
    then for each ifam no-lock
        where ifam.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifam:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifam no-lock
        where ifam.soc-cd = piSoc-cd
          and ifam.libtier-cd = piLibtier-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifam:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfam no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfam private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhLibtier-cd    as handle  no-undo.
    define variable vhFam-cd    as handle  no-undo.
    define buffer ifam for ifam.

    create query vhttquery.
    vhttBuffer = ghttIfam:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfam:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhLibtier-cd, output vhFam-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifam exclusive-lock
                where rowid(ifam) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifam:handle, 'soc-cd/libtier-cd/fam-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhLibtier-cd:buffer-value(), vhFam-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifam:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfam private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifam for ifam.

    create query vhttquery.
    vhttBuffer = ghttIfam:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfam:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifam.
            if not outils:copyValidField(buffer ifam:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfam private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhLibtier-cd    as handle  no-undo.
    define variable vhFam-cd    as handle  no-undo.
    define buffer ifam for ifam.

    create query vhttquery.
    vhttBuffer = ghttIfam:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfam:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhLibtier-cd, output vhFam-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifam exclusive-lock
                where rowid(Ifam) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifam:handle, 'soc-cd/libtier-cd/fam-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhLibtier-cd:buffer-value(), vhFam-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifam no-error.
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

