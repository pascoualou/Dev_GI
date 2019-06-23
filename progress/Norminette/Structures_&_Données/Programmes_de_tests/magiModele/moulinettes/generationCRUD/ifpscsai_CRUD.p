/*------------------------------------------------------------------------
File        : ifpscsai_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifpscsai
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifpscsai.i}
{application/include/error.i}
define variable ghttifpscsai as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phTypenat-cd as handle, output phScen-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/typenat-cd/scen-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'typenat-cd' then phTypenat-cd = phBuffer:buffer-field(vi).
            when 'scen-cle' then phScen-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIfpscsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfpscsai.
    run updateIfpscsai.
    run createIfpscsai.
end procedure.

procedure setIfpscsai:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfpscsai.
    ghttIfpscsai = phttIfpscsai.
    run crudIfpscsai.
    delete object phttIfpscsai.
end procedure.

procedure readIfpscsai:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifpscsai 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter piTypenat-cd as integer    no-undo.
    define input parameter pcScen-cle   as character  no-undo.
    define input parameter table-handle phttIfpscsai.
    define variable vhttBuffer as handle no-undo.
    define buffer ifpscsai for ifpscsai.

    vhttBuffer = phttIfpscsai:default-buffer-handle.
    for first ifpscsai no-lock
        where ifpscsai.soc-cd = piSoc-cd
          and ifpscsai.etab-cd = piEtab-cd
          and ifpscsai.typenat-cd = piTypenat-cd
          and ifpscsai.scen-cle = pcScen-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifpscsai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfpscsai no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfpscsai:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifpscsai 
    Notes  : service externe. Critère piTypenat-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter piTypenat-cd as integer    no-undo.
    define input parameter table-handle phttIfpscsai.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifpscsai for ifpscsai.

    vhttBuffer = phttIfpscsai:default-buffer-handle.
    if piTypenat-cd = ?
    then for each ifpscsai no-lock
        where ifpscsai.soc-cd = piSoc-cd
          and ifpscsai.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifpscsai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifpscsai no-lock
        where ifpscsai.soc-cd = piSoc-cd
          and ifpscsai.etab-cd = piEtab-cd
          and ifpscsai.typenat-cd = piTypenat-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifpscsai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfpscsai no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfpscsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhTypenat-cd    as handle  no-undo.
    define variable vhScen-cle    as handle  no-undo.
    define buffer ifpscsai for ifpscsai.

    create query vhttquery.
    vhttBuffer = ghttIfpscsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfpscsai:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhTypenat-cd, output vhScen-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifpscsai exclusive-lock
                where rowid(ifpscsai) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifpscsai:handle, 'soc-cd/etab-cd/typenat-cd/scen-cle: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhTypenat-cd:buffer-value(), vhScen-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifpscsai:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfpscsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifpscsai for ifpscsai.

    create query vhttquery.
    vhttBuffer = ghttIfpscsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfpscsai:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifpscsai.
            if not outils:copyValidField(buffer ifpscsai:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfpscsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhTypenat-cd    as handle  no-undo.
    define variable vhScen-cle    as handle  no-undo.
    define buffer ifpscsai for ifpscsai.

    create query vhttquery.
    vhttBuffer = ghttIfpscsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfpscsai:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhTypenat-cd, output vhScen-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifpscsai exclusive-lock
                where rowid(Ifpscsai) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifpscsai:handle, 'soc-cd/etab-cd/typenat-cd/scen-cle: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhTypenat-cd:buffer-value(), vhScen-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifpscsai no-error.
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

