/*------------------------------------------------------------------------
File        : itrifou_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table itrifou
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/itrifou.i}
{application/include/error.i}
define variable ghttitrifou as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phCddomai as handle, output phCdsec as handle, output phEtab-cd as handle, output phOrd-num as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/cddomai/cdsec/etab-cd/ord-num, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'cddomai' then phCddomai = phBuffer:buffer-field(vi).
            when 'cdsec' then phCdsec = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'ord-num' then phOrd-num = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudItrifou private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteItrifou.
    run updateItrifou.
    run createItrifou.
end procedure.

procedure setItrifou:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttItrifou.
    ghttItrifou = phttItrifou.
    run crudItrifou.
    delete object phttItrifou.
end procedure.

procedure readItrifou:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table itrifou 0608/0001 : Fournisseurs prioritaires (ex specif 205)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter pcCddomai as character  no-undo.
    define input parameter pcCdsec   as character  no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piOrd-num as integer    no-undo.
    define input parameter table-handle phttItrifou.
    define variable vhttBuffer as handle no-undo.
    define buffer itrifou for itrifou.

    vhttBuffer = phttItrifou:default-buffer-handle.
    for first itrifou no-lock
        where itrifou.soc-cd = piSoc-cd
          and itrifou.cddomai = pcCddomai
          and itrifou.cdsec = pcCdsec
          and itrifou.etab-cd = piEtab-cd
          and itrifou.ord-num = piOrd-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer itrifou:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttItrifou no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getItrifou:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table itrifou 0608/0001 : Fournisseurs prioritaires (ex specif 205)
    Notes  : service externe. Critère piEtab-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter pcCddomai as character  no-undo.
    define input parameter pcCdsec   as character  no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter table-handle phttItrifou.
    define variable vhttBuffer as handle  no-undo.
    define buffer itrifou for itrifou.

    vhttBuffer = phttItrifou:default-buffer-handle.
    if piEtab-cd = ?
    then for each itrifou no-lock
        where itrifou.soc-cd = piSoc-cd
          and itrifou.cddomai = pcCddomai
          and itrifou.cdsec = pcCdsec:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer itrifou:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each itrifou no-lock
        where itrifou.soc-cd = piSoc-cd
          and itrifou.cddomai = pcCddomai
          and itrifou.cdsec = pcCdsec
          and itrifou.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer itrifou:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttItrifou no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateItrifou private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhCddomai    as handle  no-undo.
    define variable vhCdsec    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhOrd-num    as handle  no-undo.
    define buffer itrifou for itrifou.

    create query vhttquery.
    vhttBuffer = ghttItrifou:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttItrifou:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhCddomai, output vhCdsec, output vhEtab-cd, output vhOrd-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first itrifou exclusive-lock
                where rowid(itrifou) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer itrifou:handle, 'soc-cd/cddomai/cdsec/etab-cd/ord-num: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhCddomai:buffer-value(), vhCdsec:buffer-value(), vhEtab-cd:buffer-value(), vhOrd-num:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer itrifou:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createItrifou private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer itrifou for itrifou.

    create query vhttquery.
    vhttBuffer = ghttItrifou:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttItrifou:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create itrifou.
            if not outils:copyValidField(buffer itrifou:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteItrifou private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhCddomai    as handle  no-undo.
    define variable vhCdsec    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhOrd-num    as handle  no-undo.
    define buffer itrifou for itrifou.

    create query vhttquery.
    vhttBuffer = ghttItrifou:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttItrifou:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhCddomai, output vhCdsec, output vhEtab-cd, output vhOrd-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first itrifou exclusive-lock
                where rowid(Itrifou) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer itrifou:handle, 'soc-cd/cddomai/cdsec/etab-cd/ord-num: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhCddomai:buffer-value(), vhCdsec:buffer-value(), vhEtab-cd:buffer-value(), vhOrd-num:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete itrifou no-error.
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

