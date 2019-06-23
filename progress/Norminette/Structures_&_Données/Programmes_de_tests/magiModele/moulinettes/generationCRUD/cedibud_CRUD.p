/*------------------------------------------------------------------------
File        : cedibud_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cedibud
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cedibud.i}
{application/include/error.i}
define variable ghttcedibud as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phGi-ttyid as handle, output phAna1-cd as handle, output phAna2-cd as handle, output phAna3-cd as handle, output phAna4-cd as handle, output phRub-cd as handle, output phSscoll-cle as handle, output phCpt-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur gi-ttyid/ana1-cd/ana2-cd/ana3-cd/ana4-cd/rub-cd/sscoll-cle/cpt-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'gi-ttyid' then phGi-ttyid = phBuffer:buffer-field(vi).
            when 'ana1-cd' then phAna1-cd = phBuffer:buffer-field(vi).
            when 'ana2-cd' then phAna2-cd = phBuffer:buffer-field(vi).
            when 'ana3-cd' then phAna3-cd = phBuffer:buffer-field(vi).
            when 'ana4-cd' then phAna4-cd = phBuffer:buffer-field(vi).
            when 'rub-cd' then phRub-cd = phBuffer:buffer-field(vi).
            when 'sscoll-cle' then phSscoll-cle = phBuffer:buffer-field(vi).
            when 'cpt-cd' then phCpt-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCedibud private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCedibud.
    run updateCedibud.
    run createCedibud.
end procedure.

procedure setCedibud:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCedibud.
    ghttCedibud = phttCedibud.
    run crudCedibud.
    delete object phttCedibud.
end procedure.

procedure readCedibud:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cedibud Fichier edition des budgets
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcGi-ttyid   as character  no-undo.
    define input parameter pcAna1-cd    as character  no-undo.
    define input parameter pcAna2-cd    as character  no-undo.
    define input parameter pcAna3-cd    as character  no-undo.
    define input parameter pcAna4-cd    as character  no-undo.
    define input parameter piRub-cd     as integer    no-undo.
    define input parameter pcSscoll-cle as character  no-undo.
    define input parameter pcCpt-cd     as character  no-undo.
    define input parameter table-handle phttCedibud.
    define variable vhttBuffer as handle no-undo.
    define buffer cedibud for cedibud.

    vhttBuffer = phttCedibud:default-buffer-handle.
    for first cedibud no-lock
        where cedibud.gi-ttyid = pcGi-ttyid
          and cedibud.ana1-cd = pcAna1-cd
          and cedibud.ana2-cd = pcAna2-cd
          and cedibud.ana3-cd = pcAna3-cd
          and cedibud.ana4-cd = pcAna4-cd
          and cedibud.rub-cd = piRub-cd
          and cedibud.sscoll-cle = pcSscoll-cle
          and cedibud.cpt-cd = pcCpt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cedibud:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCedibud no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCedibud:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cedibud Fichier edition des budgets
    Notes  : service externe. Critère pcSscoll-cle = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcGi-ttyid   as character  no-undo.
    define input parameter pcAna1-cd    as character  no-undo.
    define input parameter pcAna2-cd    as character  no-undo.
    define input parameter pcAna3-cd    as character  no-undo.
    define input parameter pcAna4-cd    as character  no-undo.
    define input parameter piRub-cd     as integer    no-undo.
    define input parameter pcSscoll-cle as character  no-undo.
    define input parameter table-handle phttCedibud.
    define variable vhttBuffer as handle  no-undo.
    define buffer cedibud for cedibud.

    vhttBuffer = phttCedibud:default-buffer-handle.
    if pcSscoll-cle = ?
    then for each cedibud no-lock
        where cedibud.gi-ttyid = pcGi-ttyid
          and cedibud.ana1-cd = pcAna1-cd
          and cedibud.ana2-cd = pcAna2-cd
          and cedibud.ana3-cd = pcAna3-cd
          and cedibud.ana4-cd = pcAna4-cd
          and cedibud.rub-cd = piRub-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cedibud:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cedibud no-lock
        where cedibud.gi-ttyid = pcGi-ttyid
          and cedibud.ana1-cd = pcAna1-cd
          and cedibud.ana2-cd = pcAna2-cd
          and cedibud.ana3-cd = pcAna3-cd
          and cedibud.ana4-cd = pcAna4-cd
          and cedibud.rub-cd = piRub-cd
          and cedibud.sscoll-cle = pcSscoll-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cedibud:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCedibud no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCedibud private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhGi-ttyid    as handle  no-undo.
    define variable vhAna1-cd    as handle  no-undo.
    define variable vhAna2-cd    as handle  no-undo.
    define variable vhAna3-cd    as handle  no-undo.
    define variable vhAna4-cd    as handle  no-undo.
    define variable vhRub-cd    as handle  no-undo.
    define variable vhSscoll-cle    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define buffer cedibud for cedibud.

    create query vhttquery.
    vhttBuffer = ghttCedibud:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCedibud:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhGi-ttyid, output vhAna1-cd, output vhAna2-cd, output vhAna3-cd, output vhAna4-cd, output vhRub-cd, output vhSscoll-cle, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cedibud exclusive-lock
                where rowid(cedibud) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cedibud:handle, 'gi-ttyid/ana1-cd/ana2-cd/ana3-cd/ana4-cd/rub-cd/sscoll-cle/cpt-cd: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8', vhGi-ttyid:buffer-value(), vhAna1-cd:buffer-value(), vhAna2-cd:buffer-value(), vhAna3-cd:buffer-value(), vhAna4-cd:buffer-value(), vhRub-cd:buffer-value(), vhSscoll-cle:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cedibud:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCedibud private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cedibud for cedibud.

    create query vhttquery.
    vhttBuffer = ghttCedibud:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCedibud:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cedibud.
            if not outils:copyValidField(buffer cedibud:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCedibud private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhGi-ttyid    as handle  no-undo.
    define variable vhAna1-cd    as handle  no-undo.
    define variable vhAna2-cd    as handle  no-undo.
    define variable vhAna3-cd    as handle  no-undo.
    define variable vhAna4-cd    as handle  no-undo.
    define variable vhRub-cd    as handle  no-undo.
    define variable vhSscoll-cle    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define buffer cedibud for cedibud.

    create query vhttquery.
    vhttBuffer = ghttCedibud:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCedibud:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhGi-ttyid, output vhAna1-cd, output vhAna2-cd, output vhAna3-cd, output vhAna4-cd, output vhRub-cd, output vhSscoll-cle, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cedibud exclusive-lock
                where rowid(Cedibud) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cedibud:handle, 'gi-ttyid/ana1-cd/ana2-cd/ana3-cd/ana4-cd/rub-cd/sscoll-cle/cpt-cd: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8', vhGi-ttyid:buffer-value(), vhAna1-cd:buffer-value(), vhAna2-cd:buffer-value(), vhAna3-cd:buffer-value(), vhAna4-cd:buffer-value(), vhRub-cd:buffer-value(), vhSscoll-cle:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cedibud no-error.
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

