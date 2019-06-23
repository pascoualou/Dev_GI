/*------------------------------------------------------------------------
File        : itrtln_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table itrtln
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/itrtln.i}
{application/include/error.i}
define variable ghttitrtln as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phTrt-cd as handle, output phEtat-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/trt-cd/etat-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'trt-cd' then phTrt-cd = phBuffer:buffer-field(vi).
            when 'etat-cd' then phEtat-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudItrtln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteItrtln.
    run updateItrtln.
    run createItrtln.
end procedure.

procedure setItrtln:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttItrtln.
    ghttItrtln = phttItrtln.
    run crudItrtln.
    delete object phttItrtln.
end procedure.

procedure readItrtln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table itrtln parametrage des etats par traitement
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piTrt-cd  as integer    no-undo.
    define input parameter piEtat-cd as integer    no-undo.
    define input parameter table-handle phttItrtln.
    define variable vhttBuffer as handle no-undo.
    define buffer itrtln for itrtln.

    vhttBuffer = phttItrtln:default-buffer-handle.
    for first itrtln no-lock
        where itrtln.soc-cd = piSoc-cd
          and itrtln.trt-cd = piTrt-cd
          and itrtln.etat-cd = piEtat-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer itrtln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttItrtln no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getItrtln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table itrtln parametrage des etats par traitement
    Notes  : service externe. Critère piTrt-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piTrt-cd  as integer    no-undo.
    define input parameter table-handle phttItrtln.
    define variable vhttBuffer as handle  no-undo.
    define buffer itrtln for itrtln.

    vhttBuffer = phttItrtln:default-buffer-handle.
    if piTrt-cd = ?
    then for each itrtln no-lock
        where itrtln.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer itrtln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each itrtln no-lock
        where itrtln.soc-cd = piSoc-cd
          and itrtln.trt-cd = piTrt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer itrtln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttItrtln no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateItrtln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhTrt-cd    as handle  no-undo.
    define variable vhEtat-cd    as handle  no-undo.
    define buffer itrtln for itrtln.

    create query vhttquery.
    vhttBuffer = ghttItrtln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttItrtln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhTrt-cd, output vhEtat-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first itrtln exclusive-lock
                where rowid(itrtln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer itrtln:handle, 'soc-cd/trt-cd/etat-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhTrt-cd:buffer-value(), vhEtat-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer itrtln:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createItrtln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer itrtln for itrtln.

    create query vhttquery.
    vhttBuffer = ghttItrtln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttItrtln:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create itrtln.
            if not outils:copyValidField(buffer itrtln:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteItrtln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhTrt-cd    as handle  no-undo.
    define variable vhEtat-cd    as handle  no-undo.
    define buffer itrtln for itrtln.

    create query vhttquery.
    vhttBuffer = ghttItrtln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttItrtln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhTrt-cd, output vhEtat-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first itrtln exclusive-lock
                where rowid(Itrtln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer itrtln:handle, 'soc-cd/trt-cd/etat-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhTrt-cd:buffer-value(), vhEtat-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete itrtln no-error.
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

