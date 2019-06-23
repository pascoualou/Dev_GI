/*------------------------------------------------------------------------
File        : ichrono_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ichrono
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ichrono.i}
{application/include/error.i}
define variable ghttichrono as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phBque as handle, output phGuichet as handle, output phCpt as handle, output phRib as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/bque/guichet/cpt/rib, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'bque' then phBque = phBuffer:buffer-field(vi).
            when 'guichet' then phGuichet = phBuffer:buffer-field(vi).
            when 'cpt' then phCpt = phBuffer:buffer-field(vi).
            when 'rib' then phRib = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIchrono private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIchrono.
    run updateIchrono.
    run createIchrono.
end procedure.

procedure setIchrono:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIchrono.
    ghttIchrono = phttIchrono.
    run crudIchrono.
    delete object phttIchrono.
end procedure.

procedure readIchrono:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ichrono 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter pcBque    as character  no-undo.
    define input parameter pcGuichet as character  no-undo.
    define input parameter pcCpt     as character  no-undo.
    define input parameter pcRib     as character  no-undo.
    define input parameter table-handle phttIchrono.
    define variable vhttBuffer as handle no-undo.
    define buffer ichrono for ichrono.

    vhttBuffer = phttIchrono:default-buffer-handle.
    for first ichrono no-lock
        where ichrono.soc-cd = piSoc-cd
          and ichrono.etab-cd = piEtab-cd
          and ichrono.bque = pcBque
          and ichrono.guichet = pcGuichet
          and ichrono.cpt = pcCpt
          and ichrono.rib = pcRib:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ichrono:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIchrono no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIchrono:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ichrono 
    Notes  : service externe. Critère pcCpt = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter pcBque    as character  no-undo.
    define input parameter pcGuichet as character  no-undo.
    define input parameter pcCpt     as character  no-undo.
    define input parameter table-handle phttIchrono.
    define variable vhttBuffer as handle  no-undo.
    define buffer ichrono for ichrono.

    vhttBuffer = phttIchrono:default-buffer-handle.
    if pcCpt = ?
    then for each ichrono no-lock
        where ichrono.soc-cd = piSoc-cd
          and ichrono.etab-cd = piEtab-cd
          and ichrono.bque = pcBque
          and ichrono.guichet = pcGuichet:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ichrono:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ichrono no-lock
        where ichrono.soc-cd = piSoc-cd
          and ichrono.etab-cd = piEtab-cd
          and ichrono.bque = pcBque
          and ichrono.guichet = pcGuichet
          and ichrono.cpt = pcCpt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ichrono:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIchrono no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIchrono private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhBque    as handle  no-undo.
    define variable vhGuichet    as handle  no-undo.
    define variable vhCpt    as handle  no-undo.
    define variable vhRib    as handle  no-undo.
    define buffer ichrono for ichrono.

    create query vhttquery.
    vhttBuffer = ghttIchrono:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIchrono:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhBque, output vhGuichet, output vhCpt, output vhRib).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ichrono exclusive-lock
                where rowid(ichrono) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ichrono:handle, 'soc-cd/etab-cd/bque/guichet/cpt/rib: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhBque:buffer-value(), vhGuichet:buffer-value(), vhCpt:buffer-value(), vhRib:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ichrono:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIchrono private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ichrono for ichrono.

    create query vhttquery.
    vhttBuffer = ghttIchrono:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIchrono:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ichrono.
            if not outils:copyValidField(buffer ichrono:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIchrono private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhBque    as handle  no-undo.
    define variable vhGuichet    as handle  no-undo.
    define variable vhCpt    as handle  no-undo.
    define variable vhRib    as handle  no-undo.
    define buffer ichrono for ichrono.

    create query vhttquery.
    vhttBuffer = ghttIchrono:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIchrono:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhBque, output vhGuichet, output vhCpt, output vhRib).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ichrono exclusive-lock
                where rowid(Ichrono) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ichrono:handle, 'soc-cd/etab-cd/bque/guichet/cpt/rib: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhBque:buffer-value(), vhGuichet:buffer-value(), vhCpt:buffer-value(), vhRib:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ichrono no-error.
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

