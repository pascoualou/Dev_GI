/*------------------------------------------------------------------------
File        : afps_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table afps
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/afps.i}
{application/include/error.i}
define variable ghttafps as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phNatjou-gi as handle, output phAppel-num as handle, output phLig as handle, output phPos as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/natjou-gi/appel-num/lig/pos, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'natjou-gi' then phNatjou-gi = phBuffer:buffer-field(vi).
            when 'appel-num' then phAppel-num = phBuffer:buffer-field(vi).
            when 'lig' then phLig = phBuffer:buffer-field(vi).
            when 'pos' then phPos = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAfps private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAfps.
    run updateAfps.
    run createAfps.
end procedure.

procedure setAfps:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAfps.
    ghttAfps = phttAfps.
    run crudAfps.
    delete object phttAfps.
end procedure.

procedure readAfps:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table afps lignes de detail prestations
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcNatjou-gi as character  no-undo.
    define input parameter pcAppel-num as character  no-undo.
    define input parameter piLig       as integer    no-undo.
    define input parameter piPos       as integer    no-undo.
    define input parameter table-handle phttAfps.
    define variable vhttBuffer as handle no-undo.
    define buffer afps for afps.

    vhttBuffer = phttAfps:default-buffer-handle.
    for first afps no-lock
        where afps.soc-cd = piSoc-cd
          and afps.etab-cd = piEtab-cd
          and afps.natjou-gi = pcNatjou-gi
          and afps.appel-num = pcAppel-num
          and afps.lig = piLig
          and afps.pos = piPos:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer afps:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAfps no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAfps:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table afps lignes de detail prestations
    Notes  : service externe. Critère piLig = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcNatjou-gi as character  no-undo.
    define input parameter pcAppel-num as character  no-undo.
    define input parameter piLig       as integer    no-undo.
    define input parameter table-handle phttAfps.
    define variable vhttBuffer as handle  no-undo.
    define buffer afps for afps.

    vhttBuffer = phttAfps:default-buffer-handle.
    if piLig = ?
    then for each afps no-lock
        where afps.soc-cd = piSoc-cd
          and afps.etab-cd = piEtab-cd
          and afps.natjou-gi = pcNatjou-gi
          and afps.appel-num = pcAppel-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer afps:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each afps no-lock
        where afps.soc-cd = piSoc-cd
          and afps.etab-cd = piEtab-cd
          and afps.natjou-gi = pcNatjou-gi
          and afps.appel-num = pcAppel-num
          and afps.lig = piLig:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer afps:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAfps no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAfps private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNatjou-gi    as handle  no-undo.
    define variable vhAppel-num    as handle  no-undo.
    define variable vhLig    as handle  no-undo.
    define variable vhPos    as handle  no-undo.
    define buffer afps for afps.

    create query vhttquery.
    vhttBuffer = ghttAfps:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAfps:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNatjou-gi, output vhAppel-num, output vhLig, output vhPos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first afps exclusive-lock
                where rowid(afps) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer afps:handle, 'soc-cd/etab-cd/natjou-gi/appel-num/lig/pos: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNatjou-gi:buffer-value(), vhAppel-num:buffer-value(), vhLig:buffer-value(), vhPos:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer afps:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAfps private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer afps for afps.

    create query vhttquery.
    vhttBuffer = ghttAfps:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAfps:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create afps.
            if not outils:copyValidField(buffer afps:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAfps private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNatjou-gi    as handle  no-undo.
    define variable vhAppel-num    as handle  no-undo.
    define variable vhLig    as handle  no-undo.
    define variable vhPos    as handle  no-undo.
    define buffer afps for afps.

    create query vhttquery.
    vhttBuffer = ghttAfps:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAfps:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNatjou-gi, output vhAppel-num, output vhLig, output vhPos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first afps exclusive-lock
                where rowid(Afps) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer afps:handle, 'soc-cd/etab-cd/natjou-gi/appel-num/lig/pos: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNatjou-gi:buffer-value(), vhAppel-num:buffer-value(), vhLig:buffer-value(), vhPos:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete afps no-error.
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

