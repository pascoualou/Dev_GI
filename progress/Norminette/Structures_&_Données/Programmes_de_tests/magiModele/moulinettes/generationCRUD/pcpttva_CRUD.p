/*------------------------------------------------------------------------
File        : pcpttva_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table pcpttva
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/pcpttva.i}
{application/include/error.i}
define variable ghttpcpttva as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phColl-cle as handle, output phCpt-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/coll-cle/cpt-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'coll-cle' then phColl-cle = phBuffer:buffer-field(vi).
            when 'cpt-cd' then phCpt-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudPcpttva private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deletePcpttva.
    run updatePcpttva.
    run createPcpttva.
end procedure.

procedure setPcpttva:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPcpttva.
    ghttPcpttva = phttPcpttva.
    run crudPcpttva.
    delete object phttPcpttva.
end procedure.

procedure readPcpttva:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table pcpttva Fichier Comptes de TVA
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter pcColl-cle as character  no-undo.
    define input parameter pcCpt-cd   as character  no-undo.
    define input parameter table-handle phttPcpttva.
    define variable vhttBuffer as handle no-undo.
    define buffer pcpttva for pcpttva.

    vhttBuffer = phttPcpttva:default-buffer-handle.
    for first pcpttva no-lock
        where pcpttva.soc-cd = piSoc-cd
          and pcpttva.coll-cle = pcColl-cle
          and pcpttva.cpt-cd = pcCpt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pcpttva:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPcpttva no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getPcpttva:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table pcpttva Fichier Comptes de TVA
    Notes  : service externe. Critère pcColl-cle = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter pcColl-cle as character  no-undo.
    define input parameter table-handle phttPcpttva.
    define variable vhttBuffer as handle  no-undo.
    define buffer pcpttva for pcpttva.

    vhttBuffer = phttPcpttva:default-buffer-handle.
    if pcColl-cle = ?
    then for each pcpttva no-lock
        where pcpttva.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pcpttva:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each pcpttva no-lock
        where pcpttva.soc-cd = piSoc-cd
          and pcpttva.coll-cle = pcColl-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pcpttva:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPcpttva no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatePcpttva private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhColl-cle    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define buffer pcpttva for pcpttva.

    create query vhttquery.
    vhttBuffer = ghttPcpttva:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttPcpttva:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhColl-cle, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first pcpttva exclusive-lock
                where rowid(pcpttva) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer pcpttva:handle, 'soc-cd/coll-cle/cpt-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhColl-cle:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer pcpttva:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createPcpttva private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer pcpttva for pcpttva.

    create query vhttquery.
    vhttBuffer = ghttPcpttva:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttPcpttva:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create pcpttva.
            if not outils:copyValidField(buffer pcpttva:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deletePcpttva private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhColl-cle    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define buffer pcpttva for pcpttva.

    create query vhttquery.
    vhttBuffer = ghttPcpttva:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttPcpttva:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhColl-cle, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first pcpttva exclusive-lock
                where rowid(Pcpttva) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer pcpttva:handle, 'soc-cd/coll-cle/cpt-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhColl-cle:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete pcpttva no-error.
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

