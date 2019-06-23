/*------------------------------------------------------------------------
File        : ifdscsai_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifdscsai
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifdscsai.i}
{application/include/error.i}
define variable ghttifdscsai as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phSoc-dest as handle, output phEtab-dest as handle, output phTypenat-cd as handle, output phScen-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/soc-dest/etab-dest/typenat-cd/scen-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'soc-dest' then phSoc-dest = phBuffer:buffer-field(vi).
            when 'etab-dest' then phEtab-dest = phBuffer:buffer-field(vi).
            when 'typenat-cd' then phTypenat-cd = phBuffer:buffer-field(vi).
            when 'scen-cle' then phScen-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIfdscsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfdscsai.
    run updateIfdscsai.
    run createIfdscsai.
end procedure.

procedure setIfdscsai:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfdscsai.
    ghttIfdscsai = phttIfdscsai.
    run crudIfdscsai.
    delete object phttIfdscsai.
end procedure.

procedure readIfdscsai:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifdscsai Entete des scenarios de factures diverses
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter piSoc-dest   as integer    no-undo.
    define input parameter piEtab-dest  as integer    no-undo.
    define input parameter piTypenat-cd as integer    no-undo.
    define input parameter pcScen-cle   as character  no-undo.
    define input parameter table-handle phttIfdscsai.
    define variable vhttBuffer as handle no-undo.
    define buffer ifdscsai for ifdscsai.

    vhttBuffer = phttIfdscsai:default-buffer-handle.
    for first ifdscsai no-lock
        where ifdscsai.soc-cd = piSoc-cd
          and ifdscsai.etab-cd = piEtab-cd
          and ifdscsai.soc-dest = piSoc-dest
          and ifdscsai.etab-dest = piEtab-dest
          and ifdscsai.typenat-cd = piTypenat-cd
          and ifdscsai.scen-cle = pcScen-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdscsai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdscsai no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfdscsai:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifdscsai Entete des scenarios de factures diverses
    Notes  : service externe. Critère piTypenat-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter piSoc-dest   as integer    no-undo.
    define input parameter piEtab-dest  as integer    no-undo.
    define input parameter piTypenat-cd as integer    no-undo.
    define input parameter table-handle phttIfdscsai.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifdscsai for ifdscsai.

    vhttBuffer = phttIfdscsai:default-buffer-handle.
    if piTypenat-cd = ?
    then for each ifdscsai no-lock
        where ifdscsai.soc-cd = piSoc-cd
          and ifdscsai.etab-cd = piEtab-cd
          and ifdscsai.soc-dest = piSoc-dest
          and ifdscsai.etab-dest = piEtab-dest:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdscsai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifdscsai no-lock
        where ifdscsai.soc-cd = piSoc-cd
          and ifdscsai.etab-cd = piEtab-cd
          and ifdscsai.soc-dest = piSoc-dest
          and ifdscsai.etab-dest = piEtab-dest
          and ifdscsai.typenat-cd = piTypenat-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdscsai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdscsai no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfdscsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhSoc-dest    as handle  no-undo.
    define variable vhEtab-dest    as handle  no-undo.
    define variable vhTypenat-cd    as handle  no-undo.
    define variable vhScen-cle    as handle  no-undo.
    define buffer ifdscsai for ifdscsai.

    create query vhttquery.
    vhttBuffer = ghttIfdscsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfdscsai:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhSoc-dest, output vhEtab-dest, output vhTypenat-cd, output vhScen-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdscsai exclusive-lock
                where rowid(ifdscsai) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdscsai:handle, 'soc-cd/etab-cd/soc-dest/etab-dest/typenat-cd/scen-cle: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhSoc-dest:buffer-value(), vhEtab-dest:buffer-value(), vhTypenat-cd:buffer-value(), vhScen-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifdscsai:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfdscsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifdscsai for ifdscsai.

    create query vhttquery.
    vhttBuffer = ghttIfdscsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfdscsai:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifdscsai.
            if not outils:copyValidField(buffer ifdscsai:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfdscsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhSoc-dest    as handle  no-undo.
    define variable vhEtab-dest    as handle  no-undo.
    define variable vhTypenat-cd    as handle  no-undo.
    define variable vhScen-cle    as handle  no-undo.
    define buffer ifdscsai for ifdscsai.

    create query vhttquery.
    vhttBuffer = ghttIfdscsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfdscsai:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhSoc-dest, output vhEtab-dest, output vhTypenat-cd, output vhScen-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdscsai exclusive-lock
                where rowid(Ifdscsai) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdscsai:handle, 'soc-cd/etab-cd/soc-dest/etab-dest/typenat-cd/scen-cle: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhSoc-dest:buffer-value(), vhEtab-dest:buffer-value(), vhTypenat-cd:buffer-value(), vhScen-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifdscsai no-error.
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

