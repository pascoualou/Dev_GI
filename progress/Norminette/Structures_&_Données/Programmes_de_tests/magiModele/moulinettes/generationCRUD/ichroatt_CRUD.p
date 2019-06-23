/*------------------------------------------------------------------------
File        : ichroatt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ichroatt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ichroatt.i}
{application/include/error.i}
define variable ghttichroatt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phType-cd as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phBque as handle, output phGuichet as handle, output phCpt as handle, output phChrono-num as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur type-cd/soc-cd/etab-cd/bque/guichet/cpt/chrono-num, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'type-cd' then phType-cd = phBuffer:buffer-field(vi).
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'bque' then phBque = phBuffer:buffer-field(vi).
            when 'guichet' then phGuichet = phBuffer:buffer-field(vi).
            when 'cpt' then phCpt = phBuffer:buffer-field(vi).
            when 'chrono-num' then phChrono-num = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIchroatt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIchroatt.
    run updateIchroatt.
    run createIchroatt.
end procedure.

procedure setIchroatt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIchroatt.
    ghttIchroatt = phttIchroatt.
    run crudIchroatt.
    delete object phttIchroatt.
end procedure.

procedure readIchroatt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ichroatt 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcType-cd    as character  no-undo.
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcBque       as character  no-undo.
    define input parameter pcGuichet    as character  no-undo.
    define input parameter pcCpt        as character  no-undo.
    define input parameter piChrono-num as integer    no-undo.
    define input parameter table-handle phttIchroatt.
    define variable vhttBuffer as handle no-undo.
    define buffer ichroatt for ichroatt.

    vhttBuffer = phttIchroatt:default-buffer-handle.
    for first ichroatt no-lock
        where ichroatt.type-cd = pcType-cd
          and ichroatt.soc-cd = piSoc-cd
          and ichroatt.etab-cd = piEtab-cd
          and ichroatt.bque = pcBque
          and ichroatt.guichet = pcGuichet
          and ichroatt.cpt = pcCpt
          and ichroatt.chrono-num = piChrono-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ichroatt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIchroatt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIchroatt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ichroatt 
    Notes  : service externe. Critère pcCpt = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcType-cd    as character  no-undo.
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcBque       as character  no-undo.
    define input parameter pcGuichet    as character  no-undo.
    define input parameter pcCpt        as character  no-undo.
    define input parameter table-handle phttIchroatt.
    define variable vhttBuffer as handle  no-undo.
    define buffer ichroatt for ichroatt.

    vhttBuffer = phttIchroatt:default-buffer-handle.
    if pcCpt = ?
    then for each ichroatt no-lock
        where ichroatt.type-cd = pcType-cd
          and ichroatt.soc-cd = piSoc-cd
          and ichroatt.etab-cd = piEtab-cd
          and ichroatt.bque = pcBque
          and ichroatt.guichet = pcGuichet:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ichroatt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ichroatt no-lock
        where ichroatt.type-cd = pcType-cd
          and ichroatt.soc-cd = piSoc-cd
          and ichroatt.etab-cd = piEtab-cd
          and ichroatt.bque = pcBque
          and ichroatt.guichet = pcGuichet
          and ichroatt.cpt = pcCpt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ichroatt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIchroatt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIchroatt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhType-cd    as handle  no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhBque    as handle  no-undo.
    define variable vhGuichet    as handle  no-undo.
    define variable vhCpt    as handle  no-undo.
    define variable vhChrono-num    as handle  no-undo.
    define buffer ichroatt for ichroatt.

    create query vhttquery.
    vhttBuffer = ghttIchroatt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIchroatt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhType-cd, output vhSoc-cd, output vhEtab-cd, output vhBque, output vhGuichet, output vhCpt, output vhChrono-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ichroatt exclusive-lock
                where rowid(ichroatt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ichroatt:handle, 'type-cd/soc-cd/etab-cd/bque/guichet/cpt/chrono-num: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhType-cd:buffer-value(), vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhBque:buffer-value(), vhGuichet:buffer-value(), vhCpt:buffer-value(), vhChrono-num:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ichroatt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIchroatt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ichroatt for ichroatt.

    create query vhttquery.
    vhttBuffer = ghttIchroatt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIchroatt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ichroatt.
            if not outils:copyValidField(buffer ichroatt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIchroatt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhType-cd    as handle  no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhBque    as handle  no-undo.
    define variable vhGuichet    as handle  no-undo.
    define variable vhCpt    as handle  no-undo.
    define variable vhChrono-num    as handle  no-undo.
    define buffer ichroatt for ichroatt.

    create query vhttquery.
    vhttBuffer = ghttIchroatt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIchroatt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhType-cd, output vhSoc-cd, output vhEtab-cd, output vhBque, output vhGuichet, output vhCpt, output vhChrono-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ichroatt exclusive-lock
                where rowid(Ichroatt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ichroatt:handle, 'type-cd/soc-cd/etab-cd/bque/guichet/cpt/chrono-num: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhType-cd:buffer-value(), vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhBque:buffer-value(), vhGuichet:buffer-value(), vhCpt:buffer-value(), vhChrono-num:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ichroatt no-error.
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

