/*------------------------------------------------------------------------
File        : ijouprd_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ijouprd
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
derniere revue: 2018/09/04 - phm: OK
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}         // Doit être positionnée juste après using
define variable ghttijouprd as handle no-undo.      // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phJou-cd as handle, output phPrd-cd as handle, output phPrd-num as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/jou-cd/prd-cd/prd-num, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd'  then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'jou-cd'  then phJou-cd = phBuffer:buffer-field(vi).
            when 'prd-cd'  then phPrd-cd = phBuffer:buffer-field(vi).
            when 'prd-num' then phPrd-num = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIjouprd private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIjouprd.
    run updateIjouprd.
    run createIjouprd.
end procedure.

procedure setIjouprd:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIjouprd.
    ghttIjouprd = phttIjouprd.
    run crudIjouprd.
    delete object phttIjouprd.
end procedure.

procedure readIjouprd:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ijouprd Periode de journal
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter pcJou-cd  as character  no-undo.
    define input parameter piPrd-cd  as integer    no-undo.
    define input parameter piPrd-num as integer    no-undo.
    define input parameter table-handle phttIjouprd.

    define variable vhttBuffer as handle no-undo.
    define buffer ijouprd for ijouprd.

    vhttBuffer = phttIjouprd:default-buffer-handle.
    for first ijouprd no-lock
        where ijouprd.soc-cd = piSoc-cd
          and ijouprd.etab-cd = piEtab-cd
          and ijouprd.jou-cd = pcJou-cd
          and ijouprd.prd-cd = piPrd-cd
          and ijouprd.prd-num = piPrd-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ijouprd:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIjouprd no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIjouprd:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ijouprd Periode de journal
    Notes  : service externe. Critère piPrd-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter pcJou-cd  as character  no-undo.
    define input parameter piPrd-cd  as integer    no-undo.
    define input parameter table-handle phttIjouprd.

    define variable vhttBuffer as handle  no-undo.
    define buffer ijouprd for ijouprd.

    vhttBuffer = phttIjouprd:default-buffer-handle.
    if piPrd-cd = ?
    then for each ijouprd no-lock
        where ijouprd.soc-cd = piSoc-cd
          and ijouprd.etab-cd = piEtab-cd
          and ijouprd.jou-cd = pcJou-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ijouprd:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ijouprd no-lock
        where ijouprd.soc-cd = piSoc-cd
          and ijouprd.etab-cd = piEtab-cd
          and ijouprd.jou-cd = pcJou-cd
          and ijouprd.prd-cd = piPrd-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ijouprd:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIjouprd no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIjouprd private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhSoc-cd   as handle  no-undo.
    define variable vhEtab-cd  as handle  no-undo.
    define variable vhJou-cd   as handle  no-undo.
    define variable vhPrd-cd   as handle  no-undo.
    define variable vhPrd-num  as handle  no-undo.
    define buffer ijouprd for ijouprd.

    create query vhttquery.
    vhttBuffer = ghttIjouprd:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIjouprd:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhPrd-cd, output vhPrd-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ijouprd exclusive-lock
                where rowid(ijouprd) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ijouprd:handle, 'soc-cd/etab-cd/jou-cd/prd-cd/prd-num: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ijouprd:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIjouprd private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ijouprd for ijouprd.

    create query vhttquery.
    vhttBuffer = ghttIjouprd:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIjouprd:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ijouprd.
            if not outils:copyValidField(buffer ijouprd:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIjouprd private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhSoc-cd   as handle  no-undo.
    define variable vhEtab-cd  as handle  no-undo.
    define variable vhJou-cd   as handle  no-undo.
    define variable vhPrd-cd   as handle  no-undo.
    define variable vhPrd-num  as handle  no-undo.
    define buffer ijouprd for ijouprd.

    create query vhttquery.
    vhttBuffer = ghttIjouprd:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIjouprd:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhPrd-cd, output vhPrd-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ijouprd exclusive-lock
                where rowid(Ijouprd) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ijouprd:handle, 'soc-cd/etab-cd/jou-cd/prd-cd/prd-num: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ijouprd no-error.
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

procedure deleteIjouprdSurEtabCd:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSociete   as integer no-undo.
    define input parameter piCodeEtabl as integer no-undo.

    define buffer ijouprd for ijouprd.

blocTrans:
    do transaction:
        for each ijouprd exclusive-lock
           where ijouprd.soc-cd  = piSociete
             and ijouprd.etab-cd = piCodeEtabl:
            delete ijouprd no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status
    return.                               // reset return-value
end procedure.
