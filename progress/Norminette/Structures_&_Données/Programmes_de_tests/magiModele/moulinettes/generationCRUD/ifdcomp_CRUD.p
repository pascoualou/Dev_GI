/*------------------------------------------------------------------------
File        : ifdcomp_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifdcomp
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifdcomp.i}
{application/include/error.i}
define variable ghttifdcomp as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phArt-cle as handle, output phCdlng as handle, output phLig as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/art-cle/cdlng/lig, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'art-cle' then phArt-cle = phBuffer:buffer-field(vi).
            when 'cdlng' then phCdlng = phBuffer:buffer-field(vi).
            when 'lig' then phLig = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIfdcomp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfdcomp.
    run updateIfdcomp.
    run createIfdcomp.
end procedure.

procedure setIfdcomp:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfdcomp.
    ghttIfdcomp = phttIfdcomp.
    run crudIfdcomp.
    delete object phttIfdcomp.
end procedure.

procedure readIfdcomp:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifdcomp Table des designations complementaires
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter pcArt-cle as character  no-undo.
    define input parameter piCdlng   as integer    no-undo.
    define input parameter piLig     as integer    no-undo.
    define input parameter table-handle phttIfdcomp.
    define variable vhttBuffer as handle no-undo.
    define buffer ifdcomp for ifdcomp.

    vhttBuffer = phttIfdcomp:default-buffer-handle.
    for first ifdcomp no-lock
        where ifdcomp.soc-cd = piSoc-cd
          and ifdcomp.art-cle = pcArt-cle
          and ifdcomp.cdlng = piCdlng
          and ifdcomp.lig = piLig:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdcomp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdcomp no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfdcomp:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifdcomp Table des designations complementaires
    Notes  : service externe. Critère piCdlng = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter pcArt-cle as character  no-undo.
    define input parameter piCdlng   as integer    no-undo.
    define input parameter table-handle phttIfdcomp.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifdcomp for ifdcomp.

    vhttBuffer = phttIfdcomp:default-buffer-handle.
    if piCdlng = ?
    then for each ifdcomp no-lock
        where ifdcomp.soc-cd = piSoc-cd
          and ifdcomp.art-cle = pcArt-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdcomp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifdcomp no-lock
        where ifdcomp.soc-cd = piSoc-cd
          and ifdcomp.art-cle = pcArt-cle
          and ifdcomp.cdlng = piCdlng:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdcomp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdcomp no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfdcomp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhArt-cle    as handle  no-undo.
    define variable vhCdlng    as handle  no-undo.
    define variable vhLig    as handle  no-undo.
    define buffer ifdcomp for ifdcomp.

    create query vhttquery.
    vhttBuffer = ghttIfdcomp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfdcomp:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhArt-cle, output vhCdlng, output vhLig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdcomp exclusive-lock
                where rowid(ifdcomp) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdcomp:handle, 'soc-cd/art-cle/cdlng/lig: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhArt-cle:buffer-value(), vhCdlng:buffer-value(), vhLig:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifdcomp:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfdcomp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifdcomp for ifdcomp.

    create query vhttquery.
    vhttBuffer = ghttIfdcomp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfdcomp:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifdcomp.
            if not outils:copyValidField(buffer ifdcomp:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfdcomp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhArt-cle    as handle  no-undo.
    define variable vhCdlng    as handle  no-undo.
    define variable vhLig    as handle  no-undo.
    define buffer ifdcomp for ifdcomp.

    create query vhttquery.
    vhttBuffer = ghttIfdcomp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfdcomp:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhArt-cle, output vhCdlng, output vhLig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdcomp exclusive-lock
                where rowid(Ifdcomp) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdcomp:handle, 'soc-cd/art-cle/cdlng/lig: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhArt-cle:buffer-value(), vhCdlng:buffer-value(), vhLig:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifdcomp no-error.
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

