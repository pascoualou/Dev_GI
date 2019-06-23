/*------------------------------------------------------------------------
File        : ifdfam_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifdfam
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifdfam.i}
{application/include/error.i}
define variable ghttifdfam as handle no-undo.      // le handle de la temp table à mettre à jour


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

procedure crudIfdfam private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfdfam.
    run updateIfdfam.
    run createIfdfam.
end procedure.

procedure setIfdfam:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfdfam.
    ghttIfdfam = phttIfdfam.
    run crudIfdfam.
    delete object phttIfdfam.
end procedure.

procedure readIfdfam:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifdfam Table des familles d'articles
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter pcFam-cle as character  no-undo.
    define input parameter table-handle phttIfdfam.
    define variable vhttBuffer as handle no-undo.
    define buffer ifdfam for ifdfam.

    vhttBuffer = phttIfdfam:default-buffer-handle.
    for first ifdfam no-lock
        where ifdfam.soc-cd = piSoc-cd
          and ifdfam.fam-cle = pcFam-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdfam:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdfam no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfdfam:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifdfam Table des familles d'articles
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter table-handle phttIfdfam.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifdfam for ifdfam.

    vhttBuffer = phttIfdfam:default-buffer-handle.
    if piSoc-cd = ?
    then for each ifdfam no-lock
        where ifdfam.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdfam:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifdfam no-lock
        where ifdfam.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdfam:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdfam no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfdfam private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhFam-cle    as handle  no-undo.
    define buffer ifdfam for ifdfam.

    create query vhttquery.
    vhttBuffer = ghttIfdfam:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfdfam:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhFam-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdfam exclusive-lock
                where rowid(ifdfam) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdfam:handle, 'soc-cd/fam-cle: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhFam-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifdfam:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfdfam private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifdfam for ifdfam.

    create query vhttquery.
    vhttBuffer = ghttIfdfam:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfdfam:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifdfam.
            if not outils:copyValidField(buffer ifdfam:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfdfam private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhFam-cle    as handle  no-undo.
    define buffer ifdfam for ifdfam.

    create query vhttquery.
    vhttBuffer = ghttIfdfam:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfdfam:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhFam-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdfam exclusive-lock
                where rowid(Ifdfam) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdfam:handle, 'soc-cd/fam-cle: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhFam-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifdfam no-error.
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

