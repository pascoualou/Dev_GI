/*------------------------------------------------------------------------
File        : pndfsai_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table pndfsai
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/pndfsai.i}
{application/include/error.i}
define variable ghttpndfsai as handle no-undo.      // le handle de la temp table à mettre à jour


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

procedure crudPndfsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deletePndfsai.
    run updatePndfsai.
    run createPndfsai.
end procedure.

procedure setPndfsai:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPndfsai.
    ghttPndfsai = phttPndfsai.
    run crudPndfsai.
    delete object phttPndfsai.
end procedure.

procedure readPndfsai:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table pndfsai Fichier entete notes de frais
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piNum-int as integer    no-undo.
    define input parameter table-handle phttPndfsai.
    define variable vhttBuffer as handle no-undo.
    define buffer pndfsai for pndfsai.

    vhttBuffer = phttPndfsai:default-buffer-handle.
    for first pndfsai no-lock
        where pndfsai.soc-cd = piSoc-cd
          and pndfsai.etab-cd = piEtab-cd
          and pndfsai.num-int = piNum-int:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pndfsai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPndfsai no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getPndfsai:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table pndfsai Fichier entete notes de frais
    Notes  : service externe. Critère piEtab-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter table-handle phttPndfsai.
    define variable vhttBuffer as handle  no-undo.
    define buffer pndfsai for pndfsai.

    vhttBuffer = phttPndfsai:default-buffer-handle.
    if piEtab-cd = ?
    then for each pndfsai no-lock
        where pndfsai.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pndfsai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each pndfsai no-lock
        where pndfsai.soc-cd = piSoc-cd
          and pndfsai.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pndfsai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPndfsai no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatePndfsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define buffer pndfsai for pndfsai.

    create query vhttquery.
    vhttBuffer = ghttPndfsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttPndfsai:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNum-int).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first pndfsai exclusive-lock
                where rowid(pndfsai) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer pndfsai:handle, 'soc-cd/etab-cd/num-int: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNum-int:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer pndfsai:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createPndfsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer pndfsai for pndfsai.

    create query vhttquery.
    vhttBuffer = ghttPndfsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttPndfsai:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create pndfsai.
            if not outils:copyValidField(buffer pndfsai:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deletePndfsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define buffer pndfsai for pndfsai.

    create query vhttquery.
    vhttBuffer = ghttPndfsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttPndfsai:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNum-int).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first pndfsai exclusive-lock
                where rowid(Pndfsai) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer pndfsai:handle, 'soc-cd/etab-cd/num-int: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNum-int:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete pndfsai no-error.
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

