/*------------------------------------------------------------------------
File        : ifplart_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifplart
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifplart.i}
{application/include/error.i}
define variable ghttifplart as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phFam-cle as handle, output phSfam-cle as handle, output phArt-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/fam-cle/sfam-cle/art-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'fam-cle' then phFam-cle = phBuffer:buffer-field(vi).
            when 'sfam-cle' then phSfam-cle = phBuffer:buffer-field(vi).
            when 'art-cle' then phArt-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIfplart private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfplart.
    run updateIfplart.
    run createIfplart.
end procedure.

procedure setIfplart:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfplart.
    ghttIfplart = phttIfplart.
    run crudIfplart.
    delete object phttIfplart.
end procedure.

procedure readIfplart:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifplart Liens Familles/Sous-familles/Articles
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter pcFam-cle  as character  no-undo.
    define input parameter pcSfam-cle as character  no-undo.
    define input parameter pcArt-cle  as character  no-undo.
    define input parameter table-handle phttIfplart.
    define variable vhttBuffer as handle no-undo.
    define buffer ifplart for ifplart.

    vhttBuffer = phttIfplart:default-buffer-handle.
    for first ifplart no-lock
        where ifplart.soc-cd = piSoc-cd
          and ifplart.fam-cle = pcFam-cle
          and ifplart.sfam-cle = pcSfam-cle
          and ifplart.art-cle = pcArt-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifplart:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfplart no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfplart:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifplart Liens Familles/Sous-familles/Articles
    Notes  : service externe. Critère pcSfam-cle = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter pcFam-cle  as character  no-undo.
    define input parameter pcSfam-cle as character  no-undo.
    define input parameter table-handle phttIfplart.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifplart for ifplart.

    vhttBuffer = phttIfplart:default-buffer-handle.
    if pcSfam-cle = ?
    then for each ifplart no-lock
        where ifplart.soc-cd = piSoc-cd
          and ifplart.fam-cle = pcFam-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifplart:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifplart no-lock
        where ifplart.soc-cd = piSoc-cd
          and ifplart.fam-cle = pcFam-cle
          and ifplart.sfam-cle = pcSfam-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifplart:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfplart no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfplart private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhFam-cle    as handle  no-undo.
    define variable vhSfam-cle    as handle  no-undo.
    define variable vhArt-cle    as handle  no-undo.
    define buffer ifplart for ifplart.

    create query vhttquery.
    vhttBuffer = ghttIfplart:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfplart:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhFam-cle, output vhSfam-cle, output vhArt-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifplart exclusive-lock
                where rowid(ifplart) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifplart:handle, 'soc-cd/fam-cle/sfam-cle/art-cle: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhFam-cle:buffer-value(), vhSfam-cle:buffer-value(), vhArt-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifplart:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfplart private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifplart for ifplart.

    create query vhttquery.
    vhttBuffer = ghttIfplart:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfplart:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifplart.
            if not outils:copyValidField(buffer ifplart:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfplart private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhFam-cle    as handle  no-undo.
    define variable vhSfam-cle    as handle  no-undo.
    define variable vhArt-cle    as handle  no-undo.
    define buffer ifplart for ifplart.

    create query vhttquery.
    vhttBuffer = ghttIfplart:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfplart:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhFam-cle, output vhSfam-cle, output vhArt-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifplart exclusive-lock
                where rowid(Ifplart) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifplart:handle, 'soc-cd/fam-cle/sfam-cle/art-cle: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhFam-cle:buffer-value(), vhSfam-cle:buffer-value(), vhArt-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifplart no-error.
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

