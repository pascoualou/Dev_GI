/*------------------------------------------------------------------------
File        : ifpcomp_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifpcomp
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifpcomp.i}
{application/include/error.i}
define variable ghttifpcomp as handle no-undo.      // le handle de la temp table à mettre à jour


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

procedure crudIfpcomp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfpcomp.
    run updateIfpcomp.
    run createIfpcomp.
end procedure.

procedure setIfpcomp:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfpcomp.
    ghttIfpcomp = phttIfpcomp.
    run crudIfpcomp.
    delete object phttIfpcomp.
end procedure.

procedure readIfpcomp:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifpcomp Table des designations complementaires
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter pcArt-cle as character  no-undo.
    define input parameter piCdlng   as integer    no-undo.
    define input parameter piLig     as integer    no-undo.
    define input parameter table-handle phttIfpcomp.
    define variable vhttBuffer as handle no-undo.
    define buffer ifpcomp for ifpcomp.

    vhttBuffer = phttIfpcomp:default-buffer-handle.
    for first ifpcomp no-lock
        where ifpcomp.soc-cd = piSoc-cd
          and ifpcomp.art-cle = pcArt-cle
          and ifpcomp.cdlng = piCdlng
          and ifpcomp.lig = piLig:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifpcomp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfpcomp no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfpcomp:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifpcomp Table des designations complementaires
    Notes  : service externe. Critère piCdlng = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter pcArt-cle as character  no-undo.
    define input parameter piCdlng   as integer    no-undo.
    define input parameter table-handle phttIfpcomp.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifpcomp for ifpcomp.

    vhttBuffer = phttIfpcomp:default-buffer-handle.
    if piCdlng = ?
    then for each ifpcomp no-lock
        where ifpcomp.soc-cd = piSoc-cd
          and ifpcomp.art-cle = pcArt-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifpcomp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifpcomp no-lock
        where ifpcomp.soc-cd = piSoc-cd
          and ifpcomp.art-cle = pcArt-cle
          and ifpcomp.cdlng = piCdlng:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifpcomp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfpcomp no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfpcomp private:
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
    define buffer ifpcomp for ifpcomp.

    create query vhttquery.
    vhttBuffer = ghttIfpcomp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfpcomp:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhArt-cle, output vhCdlng, output vhLig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifpcomp exclusive-lock
                where rowid(ifpcomp) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifpcomp:handle, 'soc-cd/art-cle/cdlng/lig: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhArt-cle:buffer-value(), vhCdlng:buffer-value(), vhLig:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifpcomp:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfpcomp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifpcomp for ifpcomp.

    create query vhttquery.
    vhttBuffer = ghttIfpcomp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfpcomp:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifpcomp.
            if not outils:copyValidField(buffer ifpcomp:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfpcomp private:
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
    define buffer ifpcomp for ifpcomp.

    create query vhttquery.
    vhttBuffer = ghttIfpcomp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfpcomp:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhArt-cle, output vhCdlng, output vhLig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifpcomp exclusive-lock
                where rowid(Ifpcomp) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifpcomp:handle, 'soc-cd/art-cle/cdlng/lig: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhArt-cle:buffer-value(), vhCdlng:buffer-value(), vhLig:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifpcomp no-error.
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

