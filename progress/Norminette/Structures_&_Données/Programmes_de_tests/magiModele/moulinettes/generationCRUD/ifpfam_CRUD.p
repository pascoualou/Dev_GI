/*------------------------------------------------------------------------
File        : ifpfam_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifpfam
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifpfam.i}
{application/include/error.i}
define variable ghttifpfam as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phFam-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/fam-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'fam-cle' then phFam-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIfpfam private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfpfam.
    run updateIfpfam.
    run createIfpfam.
end procedure.

procedure setIfpfam:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfpfam.
    ghttIfpfam = phttIfpfam.
    run crudIfpfam.
    delete object phttIfpfam.
end procedure.

procedure readIfpfam:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifpfam Table des familles d'articles
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter pcFam-cle as character  no-undo.
    define input parameter table-handle phttIfpfam.
    define variable vhttBuffer as handle no-undo.
    define buffer ifpfam for ifpfam.

    vhttBuffer = phttIfpfam:default-buffer-handle.
    for first ifpfam no-lock
        where ifpfam.soc-cd = piSoc-cd
          and ifpfam.fam-cle = pcFam-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifpfam:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfpfam no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfpfam:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifpfam Table des familles d'articles
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter table-handle phttIfpfam.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifpfam for ifpfam.

    vhttBuffer = phttIfpfam:default-buffer-handle.
    if piSoc-cd = ?
    then for each ifpfam no-lock
        where ifpfam.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifpfam:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifpfam no-lock
        where ifpfam.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifpfam:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfpfam no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfpfam private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhFam-cle    as handle  no-undo.
    define buffer ifpfam for ifpfam.

    create query vhttquery.
    vhttBuffer = ghttIfpfam:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfpfam:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhFam-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifpfam exclusive-lock
                where rowid(ifpfam) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifpfam:handle, 'soc-cd/fam-cle: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhFam-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifpfam:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfpfam private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifpfam for ifpfam.

    create query vhttquery.
    vhttBuffer = ghttIfpfam:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfpfam:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifpfam.
            if not outils:copyValidField(buffer ifpfam:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfpfam private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhFam-cle    as handle  no-undo.
    define buffer ifpfam for ifpfam.

    create query vhttquery.
    vhttBuffer = ghttIfpfam:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfpfam:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhFam-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifpfam exclusive-lock
                where rowid(Ifpfam) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifpfam:handle, 'soc-cd/fam-cle: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhFam-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifpfam no-error.
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

