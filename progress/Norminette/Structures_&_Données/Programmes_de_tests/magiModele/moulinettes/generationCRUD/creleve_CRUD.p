/*------------------------------------------------------------------------
File        : creleve_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table creleve
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/creleve.i}
{application/include/error.i}
define variable ghttcreleve as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phValid as handle, output phRegl-cd as handle, output phCli-cle as handle, output phDev-cd as handle, output phAdr-cd as handle, output phDaech as handle, output phFac-num as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/valid/regl-cd/cli-cle/dev-cd/adr-cd/daech/fac-num, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'valid' then phValid = phBuffer:buffer-field(vi).
            when 'regl-cd' then phRegl-cd = phBuffer:buffer-field(vi).
            when 'cli-cle' then phCli-cle = phBuffer:buffer-field(vi).
            when 'dev-cd' then phDev-cd = phBuffer:buffer-field(vi).
            when 'adr-cd' then phAdr-cd = phBuffer:buffer-field(vi).
            when 'daech' then phDaech = phBuffer:buffer-field(vi).
            when 'fac-num' then phFac-num = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCreleve private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCreleve.
    run updateCreleve.
    run createCreleve.
end procedure.

procedure setCreleve:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCreleve.
    ghttCreleve = phttCreleve.
    run crudCreleve.
    delete object phttCreleve.
end procedure.

procedure readCreleve:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table creleve Fichier releve de factures
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter plValid   as logical    no-undo.
    define input parameter piRegl-cd as integer    no-undo.
    define input parameter pcCli-cle as character  no-undo.
    define input parameter pcDev-cd  as character  no-undo.
    define input parameter piAdr-cd  as integer    no-undo.
    define input parameter pdaDaech   as date       no-undo.
    define input parameter piFac-num as integer    no-undo.
    define input parameter table-handle phttCreleve.
    define variable vhttBuffer as handle no-undo.
    define buffer creleve for creleve.

    vhttBuffer = phttCreleve:default-buffer-handle.
    for first creleve no-lock
        where creleve.soc-cd = piSoc-cd
          and creleve.etab-cd = piEtab-cd
          and creleve.valid = plValid
          and creleve.regl-cd = piRegl-cd
          and creleve.cli-cle = pcCli-cle
          and creleve.dev-cd = pcDev-cd
          and creleve.adr-cd = piAdr-cd
          and creleve.daech = pdaDaech
          and creleve.fac-num = piFac-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer creleve:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCreleve no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCreleve:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table creleve Fichier releve de factures
    Notes  : service externe. Critère pdaDaech = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter plValid   as logical    no-undo.
    define input parameter piRegl-cd as integer    no-undo.
    define input parameter pcCli-cle as character  no-undo.
    define input parameter pcDev-cd  as character  no-undo.
    define input parameter piAdr-cd  as integer    no-undo.
    define input parameter pdaDaech   as date       no-undo.
    define input parameter table-handle phttCreleve.
    define variable vhttBuffer as handle  no-undo.
    define buffer creleve for creleve.

    vhttBuffer = phttCreleve:default-buffer-handle.
    if pdaDaech = ?
    then for each creleve no-lock
        where creleve.soc-cd = piSoc-cd
          and creleve.etab-cd = piEtab-cd
          and creleve.valid = plValid
          and creleve.regl-cd = piRegl-cd
          and creleve.cli-cle = pcCli-cle
          and creleve.dev-cd = pcDev-cd
          and creleve.adr-cd = piAdr-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer creleve:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each creleve no-lock
        where creleve.soc-cd = piSoc-cd
          and creleve.etab-cd = piEtab-cd
          and creleve.valid = plValid
          and creleve.regl-cd = piRegl-cd
          and creleve.cli-cle = pcCli-cle
          and creleve.dev-cd = pcDev-cd
          and creleve.adr-cd = piAdr-cd
          and creleve.daech = pdaDaech:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer creleve:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCreleve no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCreleve private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhValid    as handle  no-undo.
    define variable vhRegl-cd    as handle  no-undo.
    define variable vhCli-cle    as handle  no-undo.
    define variable vhDev-cd    as handle  no-undo.
    define variable vhAdr-cd    as handle  no-undo.
    define variable vhDaech    as handle  no-undo.
    define variable vhFac-num    as handle  no-undo.
    define buffer creleve for creleve.

    create query vhttquery.
    vhttBuffer = ghttCreleve:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCreleve:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhValid, output vhRegl-cd, output vhCli-cle, output vhDev-cd, output vhAdr-cd, output vhDaech, output vhFac-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first creleve exclusive-lock
                where rowid(creleve) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer creleve:handle, 'soc-cd/etab-cd/valid/regl-cd/cli-cle/dev-cd/adr-cd/daech/fac-num: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8/&9', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhValid:buffer-value(), vhRegl-cd:buffer-value(), vhCli-cle:buffer-value(), vhDev-cd:buffer-value(), vhAdr-cd:buffer-value(), vhDaech:buffer-value(), vhFac-num:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer creleve:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCreleve private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer creleve for creleve.

    create query vhttquery.
    vhttBuffer = ghttCreleve:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCreleve:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create creleve.
            if not outils:copyValidField(buffer creleve:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCreleve private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhValid    as handle  no-undo.
    define variable vhRegl-cd    as handle  no-undo.
    define variable vhCli-cle    as handle  no-undo.
    define variable vhDev-cd    as handle  no-undo.
    define variable vhAdr-cd    as handle  no-undo.
    define variable vhDaech    as handle  no-undo.
    define variable vhFac-num    as handle  no-undo.
    define buffer creleve for creleve.

    create query vhttquery.
    vhttBuffer = ghttCreleve:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCreleve:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhValid, output vhRegl-cd, output vhCli-cle, output vhDev-cd, output vhAdr-cd, output vhDaech, output vhFac-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first creleve exclusive-lock
                where rowid(Creleve) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer creleve:handle, 'soc-cd/etab-cd/valid/regl-cd/cli-cle/dev-cd/adr-cd/daech/fac-num: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8/&9', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhValid:buffer-value(), vhRegl-cd:buffer-value(), vhCli-cle:buffer-value(), vhDev-cd:buffer-value(), vhAdr-cd:buffer-value(), vhDaech:buffer-value(), vhFac-num:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete creleve no-error.
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

