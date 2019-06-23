/*------------------------------------------------------------------------
File        : cortrans_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cortrans
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cortrans.i}
{application/include/error.i}
define variable ghttcortrans as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phDev-cd as handle, output phFg-compta as handle, output phFour-cle as handle, output phDoss-num as handle, output phDadoss as handle, output phDacompta as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/dev-cd/fg-compta/four-cle/doss-num/dadoss/dacompta, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'dev-cd' then phDev-cd = phBuffer:buffer-field(vi).
            when 'fg-compta' then phFg-compta = phBuffer:buffer-field(vi).
            when 'four-cle' then phFour-cle = phBuffer:buffer-field(vi).
            when 'doss-num' then phDoss-num = phBuffer:buffer-field(vi).
            when 'dadoss' then phDadoss = phBuffer:buffer-field(vi).
            when 'dacompta' then phDacompta = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCortrans private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCortrans.
    run updateCortrans.
    run createCortrans.
end procedure.

procedure setCortrans:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCortrans.
    ghttCortrans = phttCortrans.
    run crudCortrans.
    delete object phttCortrans.
end procedure.

procedure readCortrans:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cortrans 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcDev-cd    as character  no-undo.
    define input parameter plFg-compta as logical    no-undo.
    define input parameter pcFour-cle  as character  no-undo.
    define input parameter piDoss-num  as integer    no-undo.
    define input parameter pdaDadoss    as date       no-undo.
    define input parameter pdaDacompta  as date       no-undo.
    define input parameter table-handle phttCortrans.
    define variable vhttBuffer as handle no-undo.
    define buffer cortrans for cortrans.

    vhttBuffer = phttCortrans:default-buffer-handle.
    for first cortrans no-lock
        where cortrans.soc-cd = piSoc-cd
          and cortrans.etab-cd = piEtab-cd
          and cortrans.dev-cd = pcDev-cd
          and cortrans.fg-compta = plFg-compta
          and cortrans.four-cle = pcFour-cle
          and cortrans.doss-num = piDoss-num
          and cortrans.dadoss = pdaDadoss
          and cortrans.dacompta = pdaDacompta:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cortrans:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCortrans no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCortrans:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cortrans 
    Notes  : service externe. Critère pdaDadoss = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcDev-cd    as character  no-undo.
    define input parameter plFg-compta as logical    no-undo.
    define input parameter pcFour-cle  as character  no-undo.
    define input parameter piDoss-num  as integer    no-undo.
    define input parameter pdaDadoss    as date       no-undo.
    define input parameter table-handle phttCortrans.
    define variable vhttBuffer as handle  no-undo.
    define buffer cortrans for cortrans.

    vhttBuffer = phttCortrans:default-buffer-handle.
    if pdaDadoss = ?
    then for each cortrans no-lock
        where cortrans.soc-cd = piSoc-cd
          and cortrans.etab-cd = piEtab-cd
          and cortrans.dev-cd = pcDev-cd
          and cortrans.fg-compta = plFg-compta
          and cortrans.four-cle = pcFour-cle
          and cortrans.doss-num = piDoss-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cortrans:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cortrans no-lock
        where cortrans.soc-cd = piSoc-cd
          and cortrans.etab-cd = piEtab-cd
          and cortrans.dev-cd = pcDev-cd
          and cortrans.fg-compta = plFg-compta
          and cortrans.four-cle = pcFour-cle
          and cortrans.doss-num = piDoss-num
          and cortrans.dadoss = pdaDadoss:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cortrans:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCortrans no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCortrans private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhDev-cd    as handle  no-undo.
    define variable vhFg-compta    as handle  no-undo.
    define variable vhFour-cle    as handle  no-undo.
    define variable vhDoss-num    as handle  no-undo.
    define variable vhDadoss    as handle  no-undo.
    define variable vhDacompta    as handle  no-undo.
    define buffer cortrans for cortrans.

    create query vhttquery.
    vhttBuffer = ghttCortrans:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCortrans:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhDev-cd, output vhFg-compta, output vhFour-cle, output vhDoss-num, output vhDadoss, output vhDacompta).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cortrans exclusive-lock
                where rowid(cortrans) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cortrans:handle, 'soc-cd/etab-cd/dev-cd/fg-compta/four-cle/doss-num/dadoss/dacompta: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhDev-cd:buffer-value(), vhFg-compta:buffer-value(), vhFour-cle:buffer-value(), vhDoss-num:buffer-value(), vhDadoss:buffer-value(), vhDacompta:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cortrans:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCortrans private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cortrans for cortrans.

    create query vhttquery.
    vhttBuffer = ghttCortrans:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCortrans:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cortrans.
            if not outils:copyValidField(buffer cortrans:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCortrans private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhDev-cd    as handle  no-undo.
    define variable vhFg-compta    as handle  no-undo.
    define variable vhFour-cle    as handle  no-undo.
    define variable vhDoss-num    as handle  no-undo.
    define variable vhDadoss    as handle  no-undo.
    define variable vhDacompta    as handle  no-undo.
    define buffer cortrans for cortrans.

    create query vhttquery.
    vhttBuffer = ghttCortrans:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCortrans:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhDev-cd, output vhFg-compta, output vhFour-cle, output vhDoss-num, output vhDadoss, output vhDacompta).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cortrans exclusive-lock
                where rowid(Cortrans) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cortrans:handle, 'soc-cd/etab-cd/dev-cd/fg-compta/four-cle/doss-num/dadoss/dacompta: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhDev-cd:buffer-value(), vhFg-compta:buffer-value(), vhFour-cle:buffer-value(), vhDoss-num:buffer-value(), vhDadoss:buffer-value(), vhDacompta:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cortrans no-error.
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

