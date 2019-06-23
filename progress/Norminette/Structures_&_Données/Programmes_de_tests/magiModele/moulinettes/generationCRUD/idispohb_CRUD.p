/*------------------------------------------------------------------------
File        : idispohb_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table idispohb
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/idispohb.i}
{application/include/error.i}
define variable ghttidispohb as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phPrd-cd as handle, output phPrd-num as handle, output phAffair-num as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/prd-cd/prd-num/affair-num, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'prd-cd' then phPrd-cd = phBuffer:buffer-field(vi).
            when 'prd-num' then phPrd-num = phBuffer:buffer-field(vi).
            when 'affair-num' then phAffair-num = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIdispohb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIdispohb.
    run updateIdispohb.
    run createIdispohb.
end procedure.

procedure setIdispohb:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIdispohb.
    ghttIdispohb = phttIdispohb.
    run crudIdispohb.
    delete object phttIdispohb.
end procedure.

procedure readIdispohb:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table idispohb Disponible Hors bugdet
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter piPrd-cd     as integer    no-undo.
    define input parameter piPrd-num    as integer    no-undo.
    define input parameter pdeAffair-num as decimal    no-undo.
    define input parameter table-handle phttIdispohb.
    define variable vhttBuffer as handle no-undo.
    define buffer idispohb for idispohb.

    vhttBuffer = phttIdispohb:default-buffer-handle.
    for first idispohb no-lock
        where idispohb.soc-cd = piSoc-cd
          and idispohb.etab-cd = piEtab-cd
          and idispohb.prd-cd = piPrd-cd
          and idispohb.prd-num = piPrd-num
          and idispohb.affair-num = pdeAffair-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer idispohb:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIdispohb no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIdispohb:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table idispohb Disponible Hors bugdet
    Notes  : service externe. Critère piPrd-num = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter piPrd-cd     as integer    no-undo.
    define input parameter piPrd-num    as integer    no-undo.
    define input parameter table-handle phttIdispohb.
    define variable vhttBuffer as handle  no-undo.
    define buffer idispohb for idispohb.

    vhttBuffer = phttIdispohb:default-buffer-handle.
    if piPrd-num = ?
    then for each idispohb no-lock
        where idispohb.soc-cd = piSoc-cd
          and idispohb.etab-cd = piEtab-cd
          and idispohb.prd-cd = piPrd-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer idispohb:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each idispohb no-lock
        where idispohb.soc-cd = piSoc-cd
          and idispohb.etab-cd = piEtab-cd
          and idispohb.prd-cd = piPrd-cd
          and idispohb.prd-num = piPrd-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer idispohb:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIdispohb no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIdispohb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhPrd-cd    as handle  no-undo.
    define variable vhPrd-num    as handle  no-undo.
    define variable vhAffair-num    as handle  no-undo.
    define buffer idispohb for idispohb.

    create query vhttquery.
    vhttBuffer = ghttIdispohb:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIdispohb:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhPrd-cd, output vhPrd-num, output vhAffair-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first idispohb exclusive-lock
                where rowid(idispohb) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer idispohb:handle, 'soc-cd/etab-cd/prd-cd/prd-num/affair-num: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhAffair-num:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer idispohb:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIdispohb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer idispohb for idispohb.

    create query vhttquery.
    vhttBuffer = ghttIdispohb:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIdispohb:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create idispohb.
            if not outils:copyValidField(buffer idispohb:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIdispohb private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhPrd-cd    as handle  no-undo.
    define variable vhPrd-num    as handle  no-undo.
    define variable vhAffair-num    as handle  no-undo.
    define buffer idispohb for idispohb.

    create query vhttquery.
    vhttBuffer = ghttIdispohb:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIdispohb:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhPrd-cd, output vhPrd-num, output vhAffair-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first idispohb exclusive-lock
                where rowid(Idispohb) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer idispohb:handle, 'soc-cd/etab-cd/prd-cd/prd-num/affair-num: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhAffair-num:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete idispohb no-error.
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

