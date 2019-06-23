/*------------------------------------------------------------------------
File        : cd2par_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cd2par
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cd2par.i}
{application/include/error.i}
define variable ghttcd2par as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCd2par private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCd2par.
    run updateCd2par.
    run createCd2par.
end procedure.

procedure setCd2par:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCd2par.
    ghttCd2par = phttCd2par.
    run crudCd2par.
    delete object phttCd2par.
end procedure.

procedure readCd2par:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cd2par parametres generaux DAS2
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter table-handle phttCd2par.
    define variable vhttBuffer as handle no-undo.
    define buffer cd2par for cd2par.

    vhttBuffer = phttCd2par:default-buffer-handle.
    for first cd2par no-lock
        where cd2par.soc-cd = piSoc-cd
          and cd2par.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cd2par:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCd2par no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCd2par:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cd2par parametres generaux DAS2
    Notes  : service externe. Critère piSoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter table-handle phttCd2par.
    define variable vhttBuffer as handle  no-undo.
    define buffer cd2par for cd2par.

    vhttBuffer = phttCd2par:default-buffer-handle.
    if piSoc-cd = ?
    then for each cd2par no-lock
        where cd2par.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cd2par:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cd2par no-lock
        where cd2par.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cd2par:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCd2par no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCd2par private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define buffer cd2par for cd2par.

    create query vhttquery.
    vhttBuffer = ghttCd2par:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCd2par:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cd2par exclusive-lock
                where rowid(cd2par) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cd2par:handle, 'soc-cd/etab-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cd2par:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCd2par private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cd2par for cd2par.

    create query vhttquery.
    vhttBuffer = ghttCd2par:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCd2par:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cd2par.
            if not outils:copyValidField(buffer cd2par:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCd2par private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define buffer cd2par for cd2par.

    create query vhttquery.
    vhttBuffer = ghttCd2par:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCd2par:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cd2par exclusive-lock
                where rowid(Cd2par) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cd2par:handle, 'soc-cd/etab-cd: ', substitute('&1/&2', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cd2par no-error.
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

