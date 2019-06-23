/*------------------------------------------------------------------------
File        : ifdtiers_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifdtiers
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifdtiers.i}
{application/include/error.i}
define variable ghttifdtiers as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phSoc-dest as handle, output phTypefac-cle as handle, output phCptg-cd as handle, output phSscpt-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/soc-dest/typefac-cle/cptg-cd/sscpt-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'soc-dest' then phSoc-dest = phBuffer:buffer-field(vi).
            when 'typefac-cle' then phTypefac-cle = phBuffer:buffer-field(vi).
            when 'cptg-cd' then phCptg-cd = phBuffer:buffer-field(vi).
            when 'sscpt-cd' then phSscpt-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIfdtiers private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfdtiers.
    run updateIfdtiers.
    run createIfdtiers.
end procedure.

procedure setIfdtiers:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfdtiers.
    ghttIfdtiers = phttIfdtiers.
    run crudIfdtiers.
    delete object phttIfdtiers.
end procedure.

procedure readIfdtiers:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifdtiers Table des correspondances comptes Cabinet / comptes ADB
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter piSoc-dest    as integer    no-undo.
    define input parameter pcTypefac-cle as character  no-undo.
    define input parameter pcCptg-cd     as character  no-undo.
    define input parameter pcSscpt-cd    as character  no-undo.
    define input parameter table-handle phttIfdtiers.
    define variable vhttBuffer as handle no-undo.
    define buffer ifdtiers for ifdtiers.

    vhttBuffer = phttIfdtiers:default-buffer-handle.
    for first ifdtiers no-lock
        where ifdtiers.soc-cd = piSoc-cd
          and ifdtiers.etab-cd = piEtab-cd
          and ifdtiers.soc-dest = piSoc-dest
          and ifdtiers.typefac-cle = pcTypefac-cle
          and ifdtiers.cptg-cd = pcCptg-cd
          and ifdtiers.sscpt-cd = pcSscpt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdtiers:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdtiers no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfdtiers:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifdtiers Table des correspondances comptes Cabinet / comptes ADB
    Notes  : service externe. Critère pcCptg-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter piSoc-dest    as integer    no-undo.
    define input parameter pcTypefac-cle as character  no-undo.
    define input parameter pcCptg-cd     as character  no-undo.
    define input parameter table-handle phttIfdtiers.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifdtiers for ifdtiers.

    vhttBuffer = phttIfdtiers:default-buffer-handle.
    if pcCptg-cd = ?
    then for each ifdtiers no-lock
        where ifdtiers.soc-cd = piSoc-cd
          and ifdtiers.etab-cd = piEtab-cd
          and ifdtiers.soc-dest = piSoc-dest
          and ifdtiers.typefac-cle = pcTypefac-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdtiers:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifdtiers no-lock
        where ifdtiers.soc-cd = piSoc-cd
          and ifdtiers.etab-cd = piEtab-cd
          and ifdtiers.soc-dest = piSoc-dest
          and ifdtiers.typefac-cle = pcTypefac-cle
          and ifdtiers.cptg-cd = pcCptg-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdtiers:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdtiers no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfdtiers private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhSoc-dest    as handle  no-undo.
    define variable vhTypefac-cle    as handle  no-undo.
    define variable vhCptg-cd    as handle  no-undo.
    define variable vhSscpt-cd    as handle  no-undo.
    define buffer ifdtiers for ifdtiers.

    create query vhttquery.
    vhttBuffer = ghttIfdtiers:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfdtiers:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhSoc-dest, output vhTypefac-cle, output vhCptg-cd, output vhSscpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdtiers exclusive-lock
                where rowid(ifdtiers) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdtiers:handle, 'soc-cd/etab-cd/soc-dest/typefac-cle/cptg-cd/sscpt-cd: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhSoc-dest:buffer-value(), vhTypefac-cle:buffer-value(), vhCptg-cd:buffer-value(), vhSscpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifdtiers:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfdtiers private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifdtiers for ifdtiers.

    create query vhttquery.
    vhttBuffer = ghttIfdtiers:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfdtiers:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifdtiers.
            if not outils:copyValidField(buffer ifdtiers:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfdtiers private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhSoc-dest    as handle  no-undo.
    define variable vhTypefac-cle    as handle  no-undo.
    define variable vhCptg-cd    as handle  no-undo.
    define variable vhSscpt-cd    as handle  no-undo.
    define buffer ifdtiers for ifdtiers.

    create query vhttquery.
    vhttBuffer = ghttIfdtiers:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfdtiers:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhSoc-dest, output vhTypefac-cle, output vhCptg-cd, output vhSscpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdtiers exclusive-lock
                where rowid(Ifdtiers) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdtiers:handle, 'soc-cd/etab-cd/soc-dest/typefac-cle/cptg-cd/sscpt-cd: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhSoc-dest:buffer-value(), vhTypefac-cle:buffer-value(), vhCptg-cd:buffer-value(), vhSscpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifdtiers no-error.
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

