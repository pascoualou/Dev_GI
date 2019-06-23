/*------------------------------------------------------------------------
File        : cd2sai_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cd2sai
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cd2sai.i}
{application/include/error.i}
define variable ghttcd2sai as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phNum-int as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/num-int, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'num-int' then phNum-int = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCd2sai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCd2sai.
    run updateCd2sai.
    run createCd2sai.
end procedure.

procedure setCd2sai:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCd2sai.
    ghttCd2sai = phttCd2sai.
    run crudCd2sai.
    delete object phttCd2sai.
end procedure.

procedure readCd2sai:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cd2sai Informations fournisseurs DAS2
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piNum-int as integer    no-undo.
    define input parameter table-handle phttCd2sai.
    define variable vhttBuffer as handle no-undo.
    define buffer cd2sai for cd2sai.

    vhttBuffer = phttCd2sai:default-buffer-handle.
    for first cd2sai no-lock
        where cd2sai.soc-cd = piSoc-cd
          and cd2sai.etab-cd = piEtab-cd
          and cd2sai.num-int = piNum-int:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cd2sai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCd2sai no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCd2sai:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cd2sai Informations fournisseurs DAS2
    Notes  : service externe. Critère piEtab-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter table-handle phttCd2sai.
    define variable vhttBuffer as handle  no-undo.
    define buffer cd2sai for cd2sai.

    vhttBuffer = phttCd2sai:default-buffer-handle.
    if piEtab-cd = ?
    then for each cd2sai no-lock
        where cd2sai.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cd2sai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cd2sai no-lock
        where cd2sai.soc-cd = piSoc-cd
          and cd2sai.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cd2sai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCd2sai no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCd2sai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define buffer cd2sai for cd2sai.

    create query vhttquery.
    vhttBuffer = ghttCd2sai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCd2sai:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNum-int).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cd2sai exclusive-lock
                where rowid(cd2sai) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cd2sai:handle, 'soc-cd/etab-cd/num-int: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNum-int:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cd2sai:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCd2sai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cd2sai for cd2sai.

    create query vhttquery.
    vhttBuffer = ghttCd2sai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCd2sai:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cd2sai.
            if not outils:copyValidField(buffer cd2sai:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCd2sai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define buffer cd2sai for cd2sai.

    create query vhttquery.
    vhttBuffer = ghttCd2sai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCd2sai:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNum-int).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cd2sai exclusive-lock
                where rowid(Cd2sai) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cd2sai:handle, 'soc-cd/etab-cd/num-int: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNum-int:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cd2sai no-error.
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

