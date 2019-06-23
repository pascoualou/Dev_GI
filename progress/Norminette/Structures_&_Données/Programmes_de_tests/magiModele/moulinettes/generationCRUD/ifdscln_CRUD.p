/*------------------------------------------------------------------------
File        : ifdscln_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifdscln
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifdscln.i}
{application/include/error.i}
define variable ghttifdscln as handle no-undo.      // le handle de la temp table à mettre à jour


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

procedure crudIfdscln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfdscln.
    run updateIfdscln.
    run createIfdscln.
end procedure.

procedure setIfdscln:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfdscln.
    ghttIfdscln = phttIfdscln.
    run crudIfdscln.
    delete object phttIfdscln.
end procedure.

procedure readIfdscln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifdscln Table des lignes de scenarios de factures diverses
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter piSoc-dest   as integer    no-undo.
    define input parameter piEtab-dest  as integer    no-undo.
    define input parameter piTypenat-cd as integer    no-undo.
    define input parameter pcScen-cle   as character  no-undo.
    define input parameter piLig-num    as integer    no-undo.
    define input parameter table-handle phttIfdscln.
    define variable vhttBuffer as handle no-undo.
    define buffer ifdscln for ifdscln.

    vhttBuffer = phttIfdscln:default-buffer-handle.
    for first ifdscln no-lock
        where ifdscln.soc-cd = piSoc-cd
          and ifdscln.etab-cd = piEtab-cd
          and ifdscln.soc-dest = piSoc-dest
          and ifdscln.etab-dest = piEtab-dest
          and ifdscln.typenat-cd = piTypenat-cd
          and ifdscln.scen-cle = pcScen-cle
          and ifdscln.lig-num = piLig-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdscln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdscln no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfdscln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifdscln Table des lignes de scenarios de factures diverses
    Notes  : service externe. Critère pcScen-cle = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter piSoc-dest   as integer    no-undo.
    define input parameter piEtab-dest  as integer    no-undo.
    define input parameter piTypenat-cd as integer    no-undo.
    define input parameter pcScen-cle   as character  no-undo.
    define input parameter table-handle phttIfdscln.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifdscln for ifdscln.

    vhttBuffer = phttIfdscln:default-buffer-handle.
    if pcScen-cle = ?
    then for each ifdscln no-lock
        where ifdscln.soc-cd = piSoc-cd
          and ifdscln.etab-cd = piEtab-cd
          and ifdscln.soc-dest = piSoc-dest
          and ifdscln.etab-dest = piEtab-dest
          and ifdscln.typenat-cd = piTypenat-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdscln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifdscln no-lock
        where ifdscln.soc-cd = piSoc-cd
          and ifdscln.etab-cd = piEtab-cd
          and ifdscln.soc-dest = piSoc-dest
          and ifdscln.etab-dest = piEtab-dest
          and ifdscln.typenat-cd = piTypenat-cd
          and ifdscln.scen-cle = pcScen-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdscln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdscln no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfdscln private:
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
    define buffer ifdscln for ifdscln.

    create query vhttquery.
    vhttBuffer = ghttIfdscln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfdscln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhSoc-dest, output vhEtab-dest, output vhTypenat-cd, output vhScen-cle, output vhLig-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdscln exclusive-lock
                where rowid(ifdscln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdscln:handle, 'soc-cd/etab-cd/soc-dest/etab-dest/typenat-cd/scen-cle/lig-num: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhSoc-dest:buffer-value(), vhEtab-dest:buffer-value(), vhTypenat-cd:buffer-value(), vhScen-cle:buffer-value(), vhLig-num:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifdscln:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfdscln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifdscln for ifdscln.

    create query vhttquery.
    vhttBuffer = ghttIfdscln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfdscln:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifdscln.
            if not outils:copyValidField(buffer ifdscln:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfdscln private:
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
    define buffer ifdscln for ifdscln.

    create query vhttquery.
    vhttBuffer = ghttIfdscln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfdscln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhSoc-dest, output vhEtab-dest, output vhTypenat-cd, output vhScen-cle, output vhLig-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdscln exclusive-lock
                where rowid(Ifdscln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdscln:handle, 'soc-cd/etab-cd/soc-dest/etab-dest/typenat-cd/scen-cle/lig-num: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhSoc-dest:buffer-value(), vhEtab-dest:buffer-value(), vhTypenat-cd:buffer-value(), vhScen-cle:buffer-value(), vhLig-num:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifdscln no-error.
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

