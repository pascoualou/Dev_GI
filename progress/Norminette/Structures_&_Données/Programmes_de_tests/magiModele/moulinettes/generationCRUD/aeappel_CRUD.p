/*------------------------------------------------------------------------
File        : aeappel_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table aeappel
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/aeappel.i}
{application/include/error.i}
define variable ghttaeappel as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phNatjou-gi as handle, output phAppel-num as handle, output phDaeffet as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/natjou-gi/appel-num/daeffet, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'natjou-gi' then phNatjou-gi = phBuffer:buffer-field(vi).
            when 'appel-num' then phAppel-num = phBuffer:buffer-field(vi).
            when 'daeffet' then phDaeffet = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAeappel private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAeappel.
    run updateAeappel.
    run createAeappel.
end procedure.

procedure setAeappel:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAeappel.
    ghttAeappel = phttAeappel.
    run crudAeappel.
    delete object phttAeappel.
end procedure.

procedure readAeappel:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table aeappel table des appels de fond
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcNatjou-gi as character  no-undo.
    define input parameter pcAppel-num as character  no-undo.
    define input parameter pdaDaeffet   as date       no-undo.
    define input parameter table-handle phttAeappel.
    define variable vhttBuffer as handle no-undo.
    define buffer aeappel for aeappel.

    vhttBuffer = phttAeappel:default-buffer-handle.
    for first aeappel no-lock
        where aeappel.soc-cd = piSoc-cd
          and aeappel.etab-cd = piEtab-cd
          and aeappel.natjou-gi = pcNatjou-gi
          and aeappel.appel-num = pcAppel-num
          and aeappel.daeffet = pdaDaeffet:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aeappel:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAeappel no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAeappel:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table aeappel table des appels de fond
    Notes  : service externe. Critère pcAppel-num = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcNatjou-gi as character  no-undo.
    define input parameter pcAppel-num as character  no-undo.
    define input parameter table-handle phttAeappel.
    define variable vhttBuffer as handle  no-undo.
    define buffer aeappel for aeappel.

    vhttBuffer = phttAeappel:default-buffer-handle.
    if pcAppel-num = ?
    then for each aeappel no-lock
        where aeappel.soc-cd = piSoc-cd
          and aeappel.etab-cd = piEtab-cd
          and aeappel.natjou-gi = pcNatjou-gi:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aeappel:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each aeappel no-lock
        where aeappel.soc-cd = piSoc-cd
          and aeappel.etab-cd = piEtab-cd
          and aeappel.natjou-gi = pcNatjou-gi
          and aeappel.appel-num = pcAppel-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aeappel:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAeappel no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAeappel private:
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
    define variable vhDaeffet    as handle  no-undo.
    define buffer aeappel for aeappel.

    create query vhttquery.
    vhttBuffer = ghttAeappel:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAeappel:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNatjou-gi, output vhAppel-num, output vhDaeffet).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first aeappel exclusive-lock
                where rowid(aeappel) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer aeappel:handle, 'soc-cd/etab-cd/natjou-gi/appel-num/daeffet: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNatjou-gi:buffer-value(), vhAppel-num:buffer-value(), vhDaeffet:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer aeappel:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAeappel private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer aeappel for aeappel.

    create query vhttquery.
    vhttBuffer = ghttAeappel:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAeappel:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create aeappel.
            if not outils:copyValidField(buffer aeappel:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAeappel private:
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
    define variable vhDaeffet    as handle  no-undo.
    define buffer aeappel for aeappel.

    create query vhttquery.
    vhttBuffer = ghttAeappel:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAeappel:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNatjou-gi, output vhAppel-num, output vhDaeffet).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first aeappel exclusive-lock
                where rowid(Aeappel) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer aeappel:handle, 'soc-cd/etab-cd/natjou-gi/appel-num/daeffet: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNatjou-gi:buffer-value(), vhAppel-num:buffer-value(), vhDaeffet:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete aeappel no-error.
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

