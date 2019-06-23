/*------------------------------------------------------------------------
File        : irel_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table irel
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/irel.i}
{application/include/error.i}
define variable ghttirel as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phRel-cd as handle, output phRel-num as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/rel-cd/rel-num, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'rel-cd' then phRel-cd = phBuffer:buffer-field(vi).
            when 'rel-num' then phRel-num = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIrel private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIrel.
    run updateIrel.
    run createIrel.
end procedure.

procedure setIrel:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIrel.
    ghttIrel = phttIrel.
    run crudIrel.
    delete object phttIrel.
end procedure.

procedure readIrel:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table irel Liste des differents textes de lettre de relance.
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piRel-cd  as integer    no-undo.
    define input parameter piRel-num as integer    no-undo.
    define input parameter table-handle phttIrel.
    define variable vhttBuffer as handle no-undo.
    define buffer irel for irel.

    vhttBuffer = phttIrel:default-buffer-handle.
    for first irel no-lock
        where irel.soc-cd = piSoc-cd
          and irel.etab-cd = piEtab-cd
          and irel.rel-cd = piRel-cd
          and irel.rel-num = piRel-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer irel:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIrel no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIrel:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table irel Liste des differents textes de lettre de relance.
    Notes  : service externe. Critère piRel-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piRel-cd  as integer    no-undo.
    define input parameter table-handle phttIrel.
    define variable vhttBuffer as handle  no-undo.
    define buffer irel for irel.

    vhttBuffer = phttIrel:default-buffer-handle.
    if piRel-cd = ?
    then for each irel no-lock
        where irel.soc-cd = piSoc-cd
          and irel.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer irel:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each irel no-lock
        where irel.soc-cd = piSoc-cd
          and irel.etab-cd = piEtab-cd
          and irel.rel-cd = piRel-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer irel:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIrel no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIrel private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhRel-cd    as handle  no-undo.
    define variable vhRel-num    as handle  no-undo.
    define buffer irel for irel.

    create query vhttquery.
    vhttBuffer = ghttIrel:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIrel:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhRel-cd, output vhRel-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first irel exclusive-lock
                where rowid(irel) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer irel:handle, 'soc-cd/etab-cd/rel-cd/rel-num: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhRel-cd:buffer-value(), vhRel-num:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer irel:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIrel private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer irel for irel.

    create query vhttquery.
    vhttBuffer = ghttIrel:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIrel:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create irel.
            if not outils:copyValidField(buffer irel:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIrel private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhRel-cd    as handle  no-undo.
    define variable vhRel-num    as handle  no-undo.
    define buffer irel for irel.

    create query vhttquery.
    vhttBuffer = ghttIrel:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIrel:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhRel-cd, output vhRel-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first irel exclusive-lock
                where rowid(Irel) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer irel:handle, 'soc-cd/etab-cd/rel-cd/rel-num: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhRel-cd:buffer-value(), vhRel-num:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete irel no-error.
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

