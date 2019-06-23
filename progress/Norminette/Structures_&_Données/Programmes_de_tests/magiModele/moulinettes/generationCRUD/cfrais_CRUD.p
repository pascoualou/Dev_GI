/*------------------------------------------------------------------------
File        : cfrais_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cfrais
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cfrais.i}
{application/include/error.i}
define variable ghttcfrais as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phFrais-type as handle, output phFrais-cd as handle, output phJou-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/frais-type/frais-cd/jou-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'frais-type' then phFrais-type = phBuffer:buffer-field(vi).
            when 'frais-cd' then phFrais-cd = phBuffer:buffer-field(vi).
            when 'jou-cd' then phJou-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCfrais private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCfrais.
    run updateCfrais.
    run createCfrais.
end procedure.

procedure setCfrais:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCfrais.
    ghttCfrais = phttCfrais.
    run crudCfrais.
    delete object phttCfrais.
end procedure.

procedure readCfrais:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cfrais Fichier Frais de banques
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter plFrais-type as logical    no-undo.
    define input parameter pcFrais-cd   as character  no-undo.
    define input parameter pcJou-cd     as character  no-undo.
    define input parameter table-handle phttCfrais.
    define variable vhttBuffer as handle no-undo.
    define buffer cfrais for cfrais.

    vhttBuffer = phttCfrais:default-buffer-handle.
    for first cfrais no-lock
        where cfrais.soc-cd = piSoc-cd
          and cfrais.etab-cd = piEtab-cd
          and cfrais.frais-type = plFrais-type
          and cfrais.frais-cd = pcFrais-cd
          and cfrais.jou-cd = pcJou-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cfrais:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCfrais no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCfrais:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cfrais Fichier Frais de banques
    Notes  : service externe. Critère pcFrais-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter plFrais-type as logical    no-undo.
    define input parameter pcFrais-cd   as character  no-undo.
    define input parameter table-handle phttCfrais.
    define variable vhttBuffer as handle  no-undo.
    define buffer cfrais for cfrais.

    vhttBuffer = phttCfrais:default-buffer-handle.
    if pcFrais-cd = ?
    then for each cfrais no-lock
        where cfrais.soc-cd = piSoc-cd
          and cfrais.etab-cd = piEtab-cd
          and cfrais.frais-type = plFrais-type:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cfrais:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cfrais no-lock
        where cfrais.soc-cd = piSoc-cd
          and cfrais.etab-cd = piEtab-cd
          and cfrais.frais-type = plFrais-type
          and cfrais.frais-cd = pcFrais-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cfrais:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCfrais no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCfrais private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhFrais-type    as handle  no-undo.
    define variable vhFrais-cd    as handle  no-undo.
    define variable vhJou-cd    as handle  no-undo.
    define buffer cfrais for cfrais.

    create query vhttquery.
    vhttBuffer = ghttCfrais:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCfrais:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhFrais-type, output vhFrais-cd, output vhJou-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cfrais exclusive-lock
                where rowid(cfrais) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cfrais:handle, 'soc-cd/etab-cd/frais-type/frais-cd/jou-cd: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhFrais-type:buffer-value(), vhFrais-cd:buffer-value(), vhJou-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cfrais:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCfrais private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cfrais for cfrais.

    create query vhttquery.
    vhttBuffer = ghttCfrais:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCfrais:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cfrais.
            if not outils:copyValidField(buffer cfrais:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCfrais private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhFrais-type    as handle  no-undo.
    define variable vhFrais-cd    as handle  no-undo.
    define variable vhJou-cd    as handle  no-undo.
    define buffer cfrais for cfrais.

    create query vhttquery.
    vhttBuffer = ghttCfrais:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCfrais:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhFrais-type, output vhFrais-cd, output vhJou-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cfrais exclusive-lock
                where rowid(Cfrais) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cfrais:handle, 'soc-cd/etab-cd/frais-type/frais-cd/jou-cd: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhFrais-type:buffer-value(), vhFrais-cd:buffer-value(), vhJou-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cfrais no-error.
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

