/*------------------------------------------------------------------------
File        : ifdcateg_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifdcateg
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifdcateg.i}
{application/include/error.i}
define variable ghttifdcateg as handle no-undo.      // le handle de la temp table à mettre à jour


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

procedure crudIfdcateg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfdcateg.
    run updateIfdcateg.
    run createIfdcateg.
end procedure.

procedure setIfdcateg:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfdcateg.
    ghttIfdcateg = phttIfdcateg.
    run crudIfdcateg.
    delete object phttIfdcateg.
end procedure.

procedure readIfdcateg:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifdcateg Table des categories d'articles(Honoraires,divers)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter pcCateg-cle as character  no-undo.
    define input parameter table-handle phttIfdcateg.
    define variable vhttBuffer as handle no-undo.
    define buffer ifdcateg for ifdcateg.

    vhttBuffer = phttIfdcateg:default-buffer-handle.
    for first ifdcateg no-lock
        where ifdcateg.soc-cd = piSoc-cd
          and ifdcateg.categ-cle = pcCateg-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdcateg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdcateg no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfdcateg:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifdcateg Table des categories d'articles(Honoraires,divers)
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter table-handle phttIfdcateg.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifdcateg for ifdcateg.

    vhttBuffer = phttIfdcateg:default-buffer-handle.
    if piSoc-cd = ?
    then for each ifdcateg no-lock
        where ifdcateg.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdcateg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifdcateg no-lock
        where ifdcateg.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdcateg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdcateg no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfdcateg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhCateg-cle    as handle  no-undo.
    define buffer ifdcateg for ifdcateg.

    create query vhttquery.
    vhttBuffer = ghttIfdcateg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfdcateg:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhCateg-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdcateg exclusive-lock
                where rowid(ifdcateg) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdcateg:handle, 'soc-cd/categ-cle: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhCateg-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifdcateg:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfdcateg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifdcateg for ifdcateg.

    create query vhttquery.
    vhttBuffer = ghttIfdcateg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfdcateg:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifdcateg.
            if not outils:copyValidField(buffer ifdcateg:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfdcateg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhCateg-cle    as handle  no-undo.
    define buffer ifdcateg for ifdcateg.

    create query vhttquery.
    vhttBuffer = ghttIfdcateg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfdcateg:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhCateg-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdcateg exclusive-lock
                where rowid(Ifdcateg) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdcateg:handle, 'soc-cd/categ-cle: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhCateg-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifdcateg no-error.
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

