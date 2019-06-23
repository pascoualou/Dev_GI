/*------------------------------------------------------------------------
File        : ifpsclnc_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifpsclnc
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifpsclnc.i}
{application/include/error.i}
define variable ghttifpsclnc as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phTypenat-cd as handle, output phScen-cle as handle, output phLig-num as handle, output phPos as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/typenat-cd/scen-cle/lig-num/pos, 
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
            when 'pos' then phPos = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIfpsclnc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfpsclnc.
    run updateIfpsclnc.
    run createIfpsclnc.
end procedure.

procedure setIfpsclnc:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfpsclnc.
    ghttIfpsclnc = phttIfpsclnc.
    run crudIfpsclnc.
    delete object phttIfpsclnc.
end procedure.

procedure readIfpsclnc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifpsclnc 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter piTypenat-cd as integer    no-undo.
    define input parameter pcScen-cle   as character  no-undo.
    define input parameter piLig-num    as integer    no-undo.
    define input parameter piPos        as integer    no-undo.
    define input parameter table-handle phttIfpsclnc.
    define variable vhttBuffer as handle no-undo.
    define buffer ifpsclnc for ifpsclnc.

    vhttBuffer = phttIfpsclnc:default-buffer-handle.
    for first ifpsclnc no-lock
        where ifpsclnc.soc-cd = piSoc-cd
          and ifpsclnc.etab-cd = piEtab-cd
          and ifpsclnc.typenat-cd = piTypenat-cd
          and ifpsclnc.scen-cle = pcScen-cle
          and ifpsclnc.lig-num = piLig-num
          and ifpsclnc.pos = piPos:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifpsclnc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfpsclnc no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfpsclnc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifpsclnc 
    Notes  : service externe. Critère piLig-num = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter piTypenat-cd as integer    no-undo.
    define input parameter pcScen-cle   as character  no-undo.
    define input parameter piLig-num    as integer    no-undo.
    define input parameter table-handle phttIfpsclnc.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifpsclnc for ifpsclnc.

    vhttBuffer = phttIfpsclnc:default-buffer-handle.
    if piLig-num = ?
    then for each ifpsclnc no-lock
        where ifpsclnc.soc-cd = piSoc-cd
          and ifpsclnc.etab-cd = piEtab-cd
          and ifpsclnc.typenat-cd = piTypenat-cd
          and ifpsclnc.scen-cle = pcScen-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifpsclnc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifpsclnc no-lock
        where ifpsclnc.soc-cd = piSoc-cd
          and ifpsclnc.etab-cd = piEtab-cd
          and ifpsclnc.typenat-cd = piTypenat-cd
          and ifpsclnc.scen-cle = pcScen-cle
          and ifpsclnc.lig-num = piLig-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifpsclnc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfpsclnc no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfpsclnc private:
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
    define variable vhPos    as handle  no-undo.
    define buffer ifpsclnc for ifpsclnc.

    create query vhttquery.
    vhttBuffer = ghttIfpsclnc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfpsclnc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhTypenat-cd, output vhScen-cle, output vhLig-num, output vhPos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifpsclnc exclusive-lock
                where rowid(ifpsclnc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifpsclnc:handle, 'soc-cd/etab-cd/typenat-cd/scen-cle/lig-num/pos: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhTypenat-cd:buffer-value(), vhScen-cle:buffer-value(), vhLig-num:buffer-value(), vhPos:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifpsclnc:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfpsclnc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifpsclnc for ifpsclnc.

    create query vhttquery.
    vhttBuffer = ghttIfpsclnc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfpsclnc:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifpsclnc.
            if not outils:copyValidField(buffer ifpsclnc:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfpsclnc private:
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
    define variable vhPos    as handle  no-undo.
    define buffer ifpsclnc for ifpsclnc.

    create query vhttquery.
    vhttBuffer = ghttIfpsclnc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfpsclnc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhTypenat-cd, output vhScen-cle, output vhLig-num, output vhPos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifpsclnc exclusive-lock
                where rowid(Ifpsclnc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifpsclnc:handle, 'soc-cd/etab-cd/typenat-cd/scen-cle/lig-num/pos: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhTypenat-cd:buffer-value(), vhScen-cle:buffer-value(), vhLig-num:buffer-value(), vhPos:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifpsclnc no-error.
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

