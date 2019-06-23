/*------------------------------------------------------------------------
File        : ifdsclnc_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifdsclnc
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifdsclnc.i}
{application/include/error.i}
define variable ghttifdsclnc as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phSoc-dest as handle, output phEtab-dest as handle, output phTypenat-cd as handle, output phScen-cle as handle, output phLig-num as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/soc-dest/etab-dest/typenat-cd/scen-cle/lig-num, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'soc-dest' then phSoc-dest = phBuffer:buffer-field(vi).
            when 'etab-dest' then phEtab-dest = phBuffer:buffer-field(vi).
            when 'typenat-cd' then phTypenat-cd = phBuffer:buffer-field(vi).
            when 'scen-cle' then phScen-cle = phBuffer:buffer-field(vi).
            when 'lig-num' then phLig-num = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIfdsclnc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfdsclnc.
    run updateIfdsclnc.
    run createIfdsclnc.
end procedure.

procedure setIfdsclnc:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfdsclnc.
    ghttIfdsclnc = phttIfdsclnc.
    run crudIfdsclnc.
    delete object phttIfdsclnc.
end procedure.

procedure readIfdsclnc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifdsclnc Designations complementaires des scenarios de factures diverses
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter piSoc-dest   as integer    no-undo.
    define input parameter piEtab-dest  as integer    no-undo.
    define input parameter piTypenat-cd as integer    no-undo.
    define input parameter pcScen-cle   as character  no-undo.
    define input parameter piLig-num    as integer    no-undo.
    define input parameter table-handle phttIfdsclnc.
    define variable vhttBuffer as handle no-undo.
    define buffer ifdsclnc for ifdsclnc.

    vhttBuffer = phttIfdsclnc:default-buffer-handle.
    for first ifdsclnc no-lock
        where ifdsclnc.soc-cd = piSoc-cd
          and ifdsclnc.etab-cd = piEtab-cd
          and ifdsclnc.soc-dest = piSoc-dest
          and ifdsclnc.etab-dest = piEtab-dest
          and ifdsclnc.typenat-cd = piTypenat-cd
          and ifdsclnc.scen-cle = pcScen-cle
          and ifdsclnc.lig-num = piLig-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdsclnc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdsclnc no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfdsclnc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifdsclnc Designations complementaires des scenarios de factures diverses
    Notes  : service externe. Critère pcScen-cle = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter piSoc-dest   as integer    no-undo.
    define input parameter piEtab-dest  as integer    no-undo.
    define input parameter piTypenat-cd as integer    no-undo.
    define input parameter pcScen-cle   as character  no-undo.
    define input parameter table-handle phttIfdsclnc.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifdsclnc for ifdsclnc.

    vhttBuffer = phttIfdsclnc:default-buffer-handle.
    if pcScen-cle = ?
    then for each ifdsclnc no-lock
        where ifdsclnc.soc-cd = piSoc-cd
          and ifdsclnc.etab-cd = piEtab-cd
          and ifdsclnc.soc-dest = piSoc-dest
          and ifdsclnc.etab-dest = piEtab-dest
          and ifdsclnc.typenat-cd = piTypenat-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdsclnc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifdsclnc no-lock
        where ifdsclnc.soc-cd = piSoc-cd
          and ifdsclnc.etab-cd = piEtab-cd
          and ifdsclnc.soc-dest = piSoc-dest
          and ifdsclnc.etab-dest = piEtab-dest
          and ifdsclnc.typenat-cd = piTypenat-cd
          and ifdsclnc.scen-cle = pcScen-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdsclnc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdsclnc no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfdsclnc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhSoc-dest    as handle  no-undo.
    define variable vhEtab-dest    as handle  no-undo.
    define variable vhTypenat-cd    as handle  no-undo.
    define variable vhScen-cle    as handle  no-undo.
    define variable vhLig-num    as handle  no-undo.
    define buffer ifdsclnc for ifdsclnc.

    create query vhttquery.
    vhttBuffer = ghttIfdsclnc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfdsclnc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhSoc-dest, output vhEtab-dest, output vhTypenat-cd, output vhScen-cle, output vhLig-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdsclnc exclusive-lock
                where rowid(ifdsclnc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdsclnc:handle, 'soc-cd/etab-cd/soc-dest/etab-dest/typenat-cd/scen-cle/lig-num: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhSoc-dest:buffer-value(), vhEtab-dest:buffer-value(), vhTypenat-cd:buffer-value(), vhScen-cle:buffer-value(), vhLig-num:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifdsclnc:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfdsclnc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifdsclnc for ifdsclnc.

    create query vhttquery.
    vhttBuffer = ghttIfdsclnc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfdsclnc:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifdsclnc.
            if not outils:copyValidField(buffer ifdsclnc:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfdsclnc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhSoc-dest    as handle  no-undo.
    define variable vhEtab-dest    as handle  no-undo.
    define variable vhTypenat-cd    as handle  no-undo.
    define variable vhScen-cle    as handle  no-undo.
    define variable vhLig-num    as handle  no-undo.
    define buffer ifdsclnc for ifdsclnc.

    create query vhttquery.
    vhttBuffer = ghttIfdsclnc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfdsclnc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhSoc-dest, output vhEtab-dest, output vhTypenat-cd, output vhScen-cle, output vhLig-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdsclnc exclusive-lock
                where rowid(Ifdsclnc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdsclnc:handle, 'soc-cd/etab-cd/soc-dest/etab-dest/typenat-cd/scen-cle/lig-num: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhSoc-dest:buffer-value(), vhEtab-dest:buffer-value(), vhTypenat-cd:buffer-value(), vhScen-cle:buffer-value(), vhLig-num:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifdsclnc no-error.
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

