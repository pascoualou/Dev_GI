/*------------------------------------------------------------------------
File        : pcumreg_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table pcumreg
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/pcumreg.i}
{application/include/error.i}
define variable ghttpcumreg as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phBqjou-cd as handle, output phJou-cd as handle, output phDaan as handle, output phDamois as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/bqjou-cd/jou-cd/daan/damois, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'bqjou-cd' then phBqjou-cd = phBuffer:buffer-field(vi).
            when 'jou-cd' then phJou-cd = phBuffer:buffer-field(vi).
            when 'daan' then phDaan = phBuffer:buffer-field(vi).
            when 'damois' then phDamois = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudPcumreg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deletePcumreg.
    run updatePcumreg.
    run createPcumreg.
end procedure.

procedure setPcumreg:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPcumreg.
    ghttPcumreg = phttPcumreg.
    run crudPcumreg.
    delete object phttPcumreg.
end procedure.

procedure readPcumreg:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table pcumreg cumul des cheques et des effets
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter pcBqjou-cd as character  no-undo.
    define input parameter pcJou-cd   as character  no-undo.
    define input parameter piDaan     as integer    no-undo.
    define input parameter piDamois   as integer    no-undo.
    define input parameter table-handle phttPcumreg.
    define variable vhttBuffer as handle no-undo.
    define buffer pcumreg for pcumreg.

    vhttBuffer = phttPcumreg:default-buffer-handle.
    for first pcumreg no-lock
        where pcumreg.soc-cd = piSoc-cd
          and pcumreg.etab-cd = piEtab-cd
          and pcumreg.bqjou-cd = pcBqjou-cd
          and pcumreg.jou-cd = pcJou-cd
          and pcumreg.daan = piDaan
          and pcumreg.damois = piDamois:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pcumreg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPcumreg no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getPcumreg:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table pcumreg cumul des cheques et des effets
    Notes  : service externe. Critère piDaan = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter pcBqjou-cd as character  no-undo.
    define input parameter pcJou-cd   as character  no-undo.
    define input parameter piDaan     as integer    no-undo.
    define input parameter table-handle phttPcumreg.
    define variable vhttBuffer as handle  no-undo.
    define buffer pcumreg for pcumreg.

    vhttBuffer = phttPcumreg:default-buffer-handle.
    if piDaan = ?
    then for each pcumreg no-lock
        where pcumreg.soc-cd = piSoc-cd
          and pcumreg.etab-cd = piEtab-cd
          and pcumreg.bqjou-cd = pcBqjou-cd
          and pcumreg.jou-cd = pcJou-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pcumreg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each pcumreg no-lock
        where pcumreg.soc-cd = piSoc-cd
          and pcumreg.etab-cd = piEtab-cd
          and pcumreg.bqjou-cd = pcBqjou-cd
          and pcumreg.jou-cd = pcJou-cd
          and pcumreg.daan = piDaan:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer pcumreg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPcumreg no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatePcumreg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhBqjou-cd    as handle  no-undo.
    define variable vhJou-cd    as handle  no-undo.
    define variable vhDaan    as handle  no-undo.
    define variable vhDamois    as handle  no-undo.
    define buffer pcumreg for pcumreg.

    create query vhttquery.
    vhttBuffer = ghttPcumreg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttPcumreg:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhBqjou-cd, output vhJou-cd, output vhDaan, output vhDamois).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first pcumreg exclusive-lock
                where rowid(pcumreg) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer pcumreg:handle, 'soc-cd/etab-cd/bqjou-cd/jou-cd/daan/damois: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhBqjou-cd:buffer-value(), vhJou-cd:buffer-value(), vhDaan:buffer-value(), vhDamois:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer pcumreg:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createPcumreg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer pcumreg for pcumreg.

    create query vhttquery.
    vhttBuffer = ghttPcumreg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttPcumreg:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create pcumreg.
            if not outils:copyValidField(buffer pcumreg:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deletePcumreg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhBqjou-cd    as handle  no-undo.
    define variable vhJou-cd    as handle  no-undo.
    define variable vhDaan    as handle  no-undo.
    define variable vhDamois    as handle  no-undo.
    define buffer pcumreg for pcumreg.

    create query vhttquery.
    vhttBuffer = ghttPcumreg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttPcumreg:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhBqjou-cd, output vhJou-cd, output vhDaan, output vhDamois).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first pcumreg exclusive-lock
                where rowid(Pcumreg) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer pcumreg:handle, 'soc-cd/etab-cd/bqjou-cd/jou-cd/daan/damois: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhBqjou-cd:buffer-value(), vhJou-cd:buffer-value(), vhDaan:buffer-value(), vhDamois:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete pcumreg no-error.
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

