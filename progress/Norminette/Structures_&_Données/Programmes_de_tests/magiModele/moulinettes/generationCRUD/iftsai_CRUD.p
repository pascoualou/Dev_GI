/*------------------------------------------------------------------------
File        : iftsai_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iftsai
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/iftsai.i}
{application/include/error.i}
define variable ghttiftsai as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phTprole as handle, output phSscptg-cd as handle, output phNum-int as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/tprole/sscptg-cd/num-int, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'tprole' then phTprole = phBuffer:buffer-field(vi).
            when 'sscptg-cd' then phSscptg-cd = phBuffer:buffer-field(vi).
            when 'num-int' then phNum-int = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIftsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIftsai.
    run updateIftsai.
    run createIftsai.
end procedure.

procedure setIftsai:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIftsai.
    ghttIftsai = phttIftsai.
    run crudIftsai.
    delete object phttIftsai.
end procedure.

procedure readIftsai:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iftsai 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter piTprole    as integer    no-undo.
    define input parameter pcSscptg-cd as character  no-undo.
    define input parameter piNum-int   as integer    no-undo.
    define input parameter table-handle phttIftsai.
    define variable vhttBuffer as handle no-undo.
    define buffer iftsai for iftsai.

    vhttBuffer = phttIftsai:default-buffer-handle.
    for first iftsai no-lock
        where iftsai.soc-cd = piSoc-cd
          and iftsai.etab-cd = piEtab-cd
          and iftsai.tprole = piTprole
          and iftsai.sscptg-cd = pcSscptg-cd
          and iftsai.num-int = piNum-int:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iftsai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIftsai no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIftsai:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iftsai 
    Notes  : service externe. Critère pcSscptg-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter piTprole    as integer    no-undo.
    define input parameter pcSscptg-cd as character  no-undo.
    define input parameter table-handle phttIftsai.
    define variable vhttBuffer as handle  no-undo.
    define buffer iftsai for iftsai.

    vhttBuffer = phttIftsai:default-buffer-handle.
    if pcSscptg-cd = ?
    then for each iftsai no-lock
        where iftsai.soc-cd = piSoc-cd
          and iftsai.etab-cd = piEtab-cd
          and iftsai.tprole = piTprole:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iftsai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each iftsai no-lock
        where iftsai.soc-cd = piSoc-cd
          and iftsai.etab-cd = piEtab-cd
          and iftsai.tprole = piTprole
          and iftsai.sscptg-cd = pcSscptg-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iftsai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIftsai no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIftsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhTprole    as handle  no-undo.
    define variable vhSscptg-cd    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define buffer iftsai for iftsai.

    create query vhttquery.
    vhttBuffer = ghttIftsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIftsai:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhTprole, output vhSscptg-cd, output vhNum-int).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iftsai exclusive-lock
                where rowid(iftsai) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iftsai:handle, 'soc-cd/etab-cd/tprole/sscptg-cd/num-int: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhTprole:buffer-value(), vhSscptg-cd:buffer-value(), vhNum-int:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iftsai:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIftsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iftsai for iftsai.

    create query vhttquery.
    vhttBuffer = ghttIftsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIftsai:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iftsai.
            if not outils:copyValidField(buffer iftsai:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIftsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhTprole    as handle  no-undo.
    define variable vhSscptg-cd    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define buffer iftsai for iftsai.

    create query vhttquery.
    vhttBuffer = ghttIftsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIftsai:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhTprole, output vhSscptg-cd, output vhNum-int).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iftsai exclusive-lock
                where rowid(Iftsai) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iftsai:handle, 'soc-cd/etab-cd/tprole/sscptg-cd/num-int: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhTprole:buffer-value(), vhSscptg-cd:buffer-value(), vhNum-int:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iftsai no-error.
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

