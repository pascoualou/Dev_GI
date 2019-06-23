/*------------------------------------------------------------------------
File        : cecrana_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cecrana
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cecrana.i}
{application/include/error.i}
define variable ghttcecrana as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phJou-cd as handle, output phPrd-cd as handle, output phPrd-num as handle, output phPiece-int as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'jou-cd' then phJou-cd = phBuffer:buffer-field(vi).
            when 'prd-cd' then phPrd-cd = phBuffer:buffer-field(vi).
            when 'prd-num' then phPrd-num = phBuffer:buffer-field(vi).
            when 'piece-int' then phPiece-int = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCecrana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCecrana.
    run updateCecrana.
    run createCecrana.
end procedure.

procedure setCecrana:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCecrana.
    ghttCecrana = phttCecrana.
    run crudCecrana.
    delete object phttCecrana.
end procedure.

procedure readCecrana:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cecrana fichier des entetes de lignes analytiques utilise en  saisie    analytique manuelle
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcJou-cd    as character  no-undo.
    define input parameter piPrd-cd    as integer    no-undo.
    define input parameter piPrd-num   as integer    no-undo.
    define input parameter piPiece-int as integer    no-undo.
    define input parameter table-handle phttCecrana.
    define variable vhttBuffer as handle no-undo.
    define buffer cecrana for cecrana.

    vhttBuffer = phttCecrana:default-buffer-handle.
    for first cecrana no-lock
        where cecrana.soc-cd = piSoc-cd
          and cecrana.etab-cd = piEtab-cd
          and cecrana.jou-cd = pcJou-cd
          and cecrana.prd-cd = piPrd-cd
          and cecrana.prd-num = piPrd-num
          and cecrana.piece-int = piPiece-int:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cecrana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCecrana no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCecrana:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cecrana fichier des entetes de lignes analytiques utilise en  saisie    analytique manuelle
    Notes  : service externe. Critère piPrd-num = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcJou-cd    as character  no-undo.
    define input parameter piPrd-cd    as integer    no-undo.
    define input parameter piPrd-num   as integer    no-undo.
    define input parameter table-handle phttCecrana.
    define variable vhttBuffer as handle  no-undo.
    define buffer cecrana for cecrana.

    vhttBuffer = phttCecrana:default-buffer-handle.
    if piPrd-num = ?
    then for each cecrana no-lock
        where cecrana.soc-cd = piSoc-cd
          and cecrana.etab-cd = piEtab-cd
          and cecrana.jou-cd = pcJou-cd
          and cecrana.prd-cd = piPrd-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cecrana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cecrana no-lock
        where cecrana.soc-cd = piSoc-cd
          and cecrana.etab-cd = piEtab-cd
          and cecrana.jou-cd = pcJou-cd
          and cecrana.prd-cd = piPrd-cd
          and cecrana.prd-num = piPrd-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cecrana:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCecrana no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCecrana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhJou-cd    as handle  no-undo.
    define variable vhPrd-cd    as handle  no-undo.
    define variable vhPrd-num    as handle  no-undo.
    define variable vhPiece-int    as handle  no-undo.
    define buffer cecrana for cecrana.

    create query vhttquery.
    vhttBuffer = ghttCecrana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCecrana:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhPrd-cd, output vhPrd-num, output vhPiece-int).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cecrana exclusive-lock
                where rowid(cecrana) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cecrana:handle, 'soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhPiece-int:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cecrana:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCecrana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cecrana for cecrana.

    create query vhttquery.
    vhttBuffer = ghttCecrana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCecrana:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cecrana.
            if not outils:copyValidField(buffer cecrana:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCecrana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhJou-cd    as handle  no-undo.
    define variable vhPrd-cd    as handle  no-undo.
    define variable vhPrd-num    as handle  no-undo.
    define variable vhPiece-int    as handle  no-undo.
    define buffer cecrana for cecrana.

    create query vhttquery.
    vhttBuffer = ghttCecrana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCecrana:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhPrd-cd, output vhPrd-num, output vhPiece-int).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cecrana exclusive-lock
                where rowid(Cecrana) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cecrana:handle, 'soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhPiece-int:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cecrana no-error.
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

