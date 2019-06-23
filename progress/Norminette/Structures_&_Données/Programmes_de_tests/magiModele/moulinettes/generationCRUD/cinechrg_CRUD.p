/*------------------------------------------------------------------------
File        : cinechrg_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cinechrg
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cinechrg.i}
{application/include/error.i}
define variable ghttcinechrg as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phInvest-cle as handle, output phNum-int as handle, output phDadeb as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/invest-cle/num-int/dadeb, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'invest-cle' then phInvest-cle = phBuffer:buffer-field(vi).
            when 'num-int' then phNum-int = phBuffer:buffer-field(vi).
            when 'dadeb' then phDadeb = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCinechrg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCinechrg.
    run updateCinechrg.
    run createCinechrg.
end procedure.

procedure setCinechrg:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCinechrg.
    ghttCinechrg = phttCinechrg.
    run crudCinechrg.
    delete object phttCinechrg.
end procedure.

procedure readCinechrg:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cinechrg 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcInvest-cle as character  no-undo.
    define input parameter piNum-int    as integer    no-undo.
    define input parameter pdaDadeb      as date       no-undo.
    define input parameter table-handle phttCinechrg.
    define variable vhttBuffer as handle no-undo.
    define buffer cinechrg for cinechrg.

    vhttBuffer = phttCinechrg:default-buffer-handle.
    for first cinechrg no-lock
        where cinechrg.soc-cd = piSoc-cd
          and cinechrg.etab-cd = piEtab-cd
          and cinechrg.invest-cle = pcInvest-cle
          and cinechrg.num-int = piNum-int
          and cinechrg.dadeb = pdaDadeb:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cinechrg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCinechrg no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCinechrg:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cinechrg 
    Notes  : service externe. Critère piNum-int = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcInvest-cle as character  no-undo.
    define input parameter piNum-int    as integer    no-undo.
    define input parameter table-handle phttCinechrg.
    define variable vhttBuffer as handle  no-undo.
    define buffer cinechrg for cinechrg.

    vhttBuffer = phttCinechrg:default-buffer-handle.
    if piNum-int = ?
    then for each cinechrg no-lock
        where cinechrg.soc-cd = piSoc-cd
          and cinechrg.etab-cd = piEtab-cd
          and cinechrg.invest-cle = pcInvest-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cinechrg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cinechrg no-lock
        where cinechrg.soc-cd = piSoc-cd
          and cinechrg.etab-cd = piEtab-cd
          and cinechrg.invest-cle = pcInvest-cle
          and cinechrg.num-int = piNum-int:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cinechrg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCinechrg no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCinechrg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhInvest-cle    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define variable vhDadeb    as handle  no-undo.
    define buffer cinechrg for cinechrg.

    create query vhttquery.
    vhttBuffer = ghttCinechrg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCinechrg:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhInvest-cle, output vhNum-int, output vhDadeb).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cinechrg exclusive-lock
                where rowid(cinechrg) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cinechrg:handle, 'soc-cd/etab-cd/invest-cle/num-int/dadeb: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhInvest-cle:buffer-value(), vhNum-int:buffer-value(), vhDadeb:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cinechrg:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCinechrg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cinechrg for cinechrg.

    create query vhttquery.
    vhttBuffer = ghttCinechrg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCinechrg:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cinechrg.
            if not outils:copyValidField(buffer cinechrg:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCinechrg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhInvest-cle    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define variable vhDadeb    as handle  no-undo.
    define buffer cinechrg for cinechrg.

    create query vhttquery.
    vhttBuffer = ghttCinechrg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCinechrg:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhInvest-cle, output vhNum-int, output vhDadeb).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cinechrg exclusive-lock
                where rowid(Cinechrg) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cinechrg:handle, 'soc-cd/etab-cd/invest-cle/num-int/dadeb: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhInvest-cle:buffer-value(), vhNum-int:buffer-value(), vhDadeb:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cinechrg no-error.
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

