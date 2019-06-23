/*------------------------------------------------------------------------
File        : ifpcateg_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifpcateg
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifpcateg.i}
{application/include/error.i}
define variable ghttifpcateg as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phCateg-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/categ-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'categ-cle' then phCateg-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIfpcateg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfpcateg.
    run updateIfpcateg.
    run createIfpcateg.
end procedure.

procedure setIfpcateg:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfpcateg.
    ghttIfpcateg = phttIfpcateg.
    run crudIfpcateg.
    delete object phttIfpcateg.
end procedure.

procedure readIfpcateg:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifpcateg Table des categories d'articles(Honoraires,divers)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter pcCateg-cle as character  no-undo.
    define input parameter table-handle phttIfpcateg.
    define variable vhttBuffer as handle no-undo.
    define buffer ifpcateg for ifpcateg.

    vhttBuffer = phttIfpcateg:default-buffer-handle.
    for first ifpcateg no-lock
        where ifpcateg.soc-cd = piSoc-cd
          and ifpcateg.categ-cle = pcCateg-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifpcateg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfpcateg no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfpcateg:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifpcateg Table des categories d'articles(Honoraires,divers)
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter table-handle phttIfpcateg.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifpcateg for ifpcateg.

    vhttBuffer = phttIfpcateg:default-buffer-handle.
    if piSoc-cd = ?
    then for each ifpcateg no-lock
        where ifpcateg.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifpcateg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifpcateg no-lock
        where ifpcateg.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifpcateg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfpcateg no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfpcateg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhCateg-cle    as handle  no-undo.
    define buffer ifpcateg for ifpcateg.

    create query vhttquery.
    vhttBuffer = ghttIfpcateg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfpcateg:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhCateg-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifpcateg exclusive-lock
                where rowid(ifpcateg) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifpcateg:handle, 'soc-cd/categ-cle: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhCateg-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifpcateg:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfpcateg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifpcateg for ifpcateg.

    create query vhttquery.
    vhttBuffer = ghttIfpcateg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfpcateg:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifpcateg.
            if not outils:copyValidField(buffer ifpcateg:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfpcateg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhCateg-cle    as handle  no-undo.
    define buffer ifpcateg for ifpcateg.

    create query vhttquery.
    vhttBuffer = ghttIfpcateg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfpcateg:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhCateg-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifpcateg exclusive-lock
                where rowid(Ifpcateg) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifpcateg:handle, 'soc-cd/categ-cle: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhCateg-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifpcateg no-error.
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

