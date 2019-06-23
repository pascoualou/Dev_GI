/*------------------------------------------------------------------------
File        : specif_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table specif
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/specif.i}
{application/include/error.i}
define variable ghttspecif as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phOrd-num as handle, output phCode as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/ord-num/code, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'ord-num' then phOrd-num = phBuffer:buffer-field(vi).
            when 'code' then phCode = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudSpecif private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteSpecif.
    run updateSpecif.
    run createSpecif.
end procedure.

procedure setSpecif:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSpecif.
    ghttSpecif = phttSpecif.
    run crudSpecif.
    delete object phttSpecif.
end procedure.

procedure readSpecif:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table specif definition de zones ou traitements specifiques
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piOrd-num as integer    no-undo.
    define input parameter pcCode    as character  no-undo.
    define input parameter table-handle phttSpecif.
    define variable vhttBuffer as handle no-undo.
    define buffer specif for specif.

    vhttBuffer = phttSpecif:default-buffer-handle.
    for first specif no-lock
        where specif.soc-cd = piSoc-cd
          and specif.etab-cd = piEtab-cd
          and specif.ord-num = piOrd-num
          and specif.code = pcCode:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer specif:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSpecif no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getSpecif:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table specif definition de zones ou traitements specifiques
    Notes  : service externe. Critère piOrd-num = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piOrd-num as integer    no-undo.
    define input parameter table-handle phttSpecif.
    define variable vhttBuffer as handle  no-undo.
    define buffer specif for specif.

    vhttBuffer = phttSpecif:default-buffer-handle.
    if piOrd-num = ?
    then for each specif no-lock
        where specif.soc-cd = piSoc-cd
          and specif.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer specif:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each specif no-lock
        where specif.soc-cd = piSoc-cd
          and specif.etab-cd = piEtab-cd
          and specif.ord-num = piOrd-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer specif:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSpecif no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateSpecif private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhOrd-num    as handle  no-undo.
    define variable vhCode    as handle  no-undo.
    define buffer specif for specif.

    create query vhttquery.
    vhttBuffer = ghttSpecif:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttSpecif:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhOrd-num, output vhCode).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first specif exclusive-lock
                where rowid(specif) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer specif:handle, 'soc-cd/etab-cd/ord-num/code: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhOrd-num:buffer-value(), vhCode:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer specif:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createSpecif private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer specif for specif.

    create query vhttquery.
    vhttBuffer = ghttSpecif:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttSpecif:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create specif.
            if not outils:copyValidField(buffer specif:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteSpecif private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhOrd-num    as handle  no-undo.
    define variable vhCode    as handle  no-undo.
    define buffer specif for specif.

    create query vhttquery.
    vhttBuffer = ghttSpecif:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttSpecif:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhOrd-num, output vhCode).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first specif exclusive-lock
                where rowid(Specif) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer specif:handle, 'soc-cd/etab-cd/ord-num/code: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhOrd-num:buffer-value(), vhCode:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete specif no-error.
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

