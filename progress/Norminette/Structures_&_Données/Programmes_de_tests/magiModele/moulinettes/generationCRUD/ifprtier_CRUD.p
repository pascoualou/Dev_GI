/*------------------------------------------------------------------------
File        : ifprtier_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifprtier
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifprtier.i}
{application/include/error.i}
define variable ghttifprtier as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phSscoll-cle as handle, output phCpt-cd as handle, output phSoc-dest as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/sscoll-cle/cpt-cd/soc-dest, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'sscoll-cle' then phSscoll-cle = phBuffer:buffer-field(vi).
            when 'cpt-cd' then phCpt-cd = phBuffer:buffer-field(vi).
            when 'soc-dest' then phSoc-dest = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIfprtier private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfprtier.
    run updateIfprtier.
    run createIfprtier.
end procedure.

procedure setIfprtier:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfprtier.
    ghttIfprtier = phttIfprtier.
    run crudIfprtier.
    delete object phttIfprtier.
end procedure.

procedure readIfprtier:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifprtier 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter pcSscoll-cle as character  no-undo.
    define input parameter pcCpt-cd     as character  no-undo.
    define input parameter piSoc-dest   as integer    no-undo.
    define input parameter table-handle phttIfprtier.
    define variable vhttBuffer as handle no-undo.
    define buffer ifprtier for ifprtier.

    vhttBuffer = phttIfprtier:default-buffer-handle.
    for first ifprtier no-lock
        where ifprtier.soc-cd = piSoc-cd
          and ifprtier.sscoll-cle = pcSscoll-cle
          and ifprtier.cpt-cd = pcCpt-cd
          and ifprtier.soc-dest = piSoc-dest:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifprtier:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfprtier no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfprtier:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifprtier 
    Notes  : service externe. Critère pcCpt-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter pcSscoll-cle as character  no-undo.
    define input parameter pcCpt-cd     as character  no-undo.
    define input parameter table-handle phttIfprtier.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifprtier for ifprtier.

    vhttBuffer = phttIfprtier:default-buffer-handle.
    if pcCpt-cd = ?
    then for each ifprtier no-lock
        where ifprtier.soc-cd = piSoc-cd
          and ifprtier.sscoll-cle = pcSscoll-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifprtier:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifprtier no-lock
        where ifprtier.soc-cd = piSoc-cd
          and ifprtier.sscoll-cle = pcSscoll-cle
          and ifprtier.cpt-cd = pcCpt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifprtier:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfprtier no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfprtier private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhSscoll-cle    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define variable vhSoc-dest    as handle  no-undo.
    define buffer ifprtier for ifprtier.

    create query vhttquery.
    vhttBuffer = ghttIfprtier:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfprtier:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhSscoll-cle, output vhCpt-cd, output vhSoc-dest).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifprtier exclusive-lock
                where rowid(ifprtier) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifprtier:handle, 'soc-cd/sscoll-cle/cpt-cd/soc-dest: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhSscoll-cle:buffer-value(), vhCpt-cd:buffer-value(), vhSoc-dest:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifprtier:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfprtier private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifprtier for ifprtier.

    create query vhttquery.
    vhttBuffer = ghttIfprtier:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfprtier:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifprtier.
            if not outils:copyValidField(buffer ifprtier:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfprtier private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhSscoll-cle    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define variable vhSoc-dest    as handle  no-undo.
    define buffer ifprtier for ifprtier.

    create query vhttquery.
    vhttBuffer = ghttIfprtier:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfprtier:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhSscoll-cle, output vhCpt-cd, output vhSoc-dest).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifprtier exclusive-lock
                where rowid(Ifprtier) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifprtier:handle, 'soc-cd/sscoll-cle/cpt-cd/soc-dest: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhSscoll-cle:buffer-value(), vhCpt-cd:buffer-value(), vhSoc-dest:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifprtier no-error.
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

