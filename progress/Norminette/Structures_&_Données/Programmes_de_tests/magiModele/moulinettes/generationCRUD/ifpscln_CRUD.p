/*------------------------------------------------------------------------
File        : ifpscln_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifpscln
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifpscln.i}
{application/include/error.i}
define variable ghttifpscln as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phTypenat-cd as handle, output phScen-cle as handle, output phLig-num as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/typenat-cd/scen-cle/lig-num, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'typenat-cd' then phTypenat-cd = phBuffer:buffer-field(vi).
            when 'scen-cle' then phScen-cle = phBuffer:buffer-field(vi).
            when 'lig-num' then phLig-num = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIfpscln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfpscln.
    run updateIfpscln.
    run createIfpscln.
end procedure.

procedure setIfpscln:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfpscln.
    ghttIfpscln = phttIfpscln.
    run crudIfpscln.
    delete object phttIfpscln.
end procedure.

procedure readIfpscln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifpscln 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter piTypenat-cd as integer    no-undo.
    define input parameter pcScen-cle   as character  no-undo.
    define input parameter piLig-num    as integer    no-undo.
    define input parameter table-handle phttIfpscln.
    define variable vhttBuffer as handle no-undo.
    define buffer ifpscln for ifpscln.

    vhttBuffer = phttIfpscln:default-buffer-handle.
    for first ifpscln no-lock
        where ifpscln.soc-cd = piSoc-cd
          and ifpscln.etab-cd = piEtab-cd
          and ifpscln.typenat-cd = piTypenat-cd
          and ifpscln.scen-cle = pcScen-cle
          and ifpscln.lig-num = piLig-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifpscln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfpscln no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfpscln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifpscln 
    Notes  : service externe. Critère pcScen-cle = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter piTypenat-cd as integer    no-undo.
    define input parameter pcScen-cle   as character  no-undo.
    define input parameter table-handle phttIfpscln.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifpscln for ifpscln.

    vhttBuffer = phttIfpscln:default-buffer-handle.
    if pcScen-cle = ?
    then for each ifpscln no-lock
        where ifpscln.soc-cd = piSoc-cd
          and ifpscln.etab-cd = piEtab-cd
          and ifpscln.typenat-cd = piTypenat-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifpscln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifpscln no-lock
        where ifpscln.soc-cd = piSoc-cd
          and ifpscln.etab-cd = piEtab-cd
          and ifpscln.typenat-cd = piTypenat-cd
          and ifpscln.scen-cle = pcScen-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifpscln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfpscln no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfpscln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhTypenat-cd    as handle  no-undo.
    define variable vhScen-cle    as handle  no-undo.
    define variable vhLig-num    as handle  no-undo.
    define buffer ifpscln for ifpscln.

    create query vhttquery.
    vhttBuffer = ghttIfpscln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfpscln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhTypenat-cd, output vhScen-cle, output vhLig-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifpscln exclusive-lock
                where rowid(ifpscln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifpscln:handle, 'soc-cd/etab-cd/typenat-cd/scen-cle/lig-num: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhTypenat-cd:buffer-value(), vhScen-cle:buffer-value(), vhLig-num:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifpscln:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfpscln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifpscln for ifpscln.

    create query vhttquery.
    vhttBuffer = ghttIfpscln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfpscln:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifpscln.
            if not outils:copyValidField(buffer ifpscln:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfpscln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhTypenat-cd    as handle  no-undo.
    define variable vhScen-cle    as handle  no-undo.
    define variable vhLig-num    as handle  no-undo.
    define buffer ifpscln for ifpscln.

    create query vhttquery.
    vhttBuffer = ghttIfpscln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfpscln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhTypenat-cd, output vhScen-cle, output vhLig-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifpscln exclusive-lock
                where rowid(Ifpscln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifpscln:handle, 'soc-cd/etab-cd/typenat-cd/scen-cle/lig-num: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhTypenat-cd:buffer-value(), vhScen-cle:buffer-value(), vhLig-num:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifpscln no-error.
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

