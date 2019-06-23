/*------------------------------------------------------------------------
File        : cbapln_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cbapln
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cbapln.i}
{application/include/error.i}
define variable ghttcbapln as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phNum-int as handle, output phLig as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/num-int/lig, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'num-int' then phNum-int = phBuffer:buffer-field(vi).
            when 'lig' then phLig = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCbapln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCbapln.
    run updateCbapln.
    run createCbapln.
end procedure.

procedure setCbapln:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCbapln.
    ghttCbapln = phttCbapln.
    run crudCbapln.
    delete object phttCbapln.
end procedure.

procedure readCbapln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cbapln Lignes des saisie de paiement rapide
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piNum-int as integer    no-undo.
    define input parameter piLig     as integer    no-undo.
    define input parameter table-handle phttCbapln.
    define variable vhttBuffer as handle no-undo.
    define buffer cbapln for cbapln.

    vhttBuffer = phttCbapln:default-buffer-handle.
    for first cbapln no-lock
        where cbapln.soc-cd = piSoc-cd
          and cbapln.num-int = piNum-int
          and cbapln.lig = piLig:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cbapln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCbapln no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCbapln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cbapln Lignes des saisie de paiement rapide
    Notes  : service externe. Critère piNum-int = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piNum-int as integer    no-undo.
    define input parameter table-handle phttCbapln.
    define variable vhttBuffer as handle  no-undo.
    define buffer cbapln for cbapln.

    vhttBuffer = phttCbapln:default-buffer-handle.
    if piNum-int = ?
    then for each cbapln no-lock
        where cbapln.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cbapln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cbapln no-lock
        where cbapln.soc-cd = piSoc-cd
          and cbapln.num-int = piNum-int:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cbapln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCbapln no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCbapln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define variable vhLig    as handle  no-undo.
    define buffer cbapln for cbapln.

    create query vhttquery.
    vhttBuffer = ghttCbapln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCbapln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhNum-int, output vhLig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cbapln exclusive-lock
                where rowid(cbapln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cbapln:handle, 'soc-cd/num-int/lig: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhNum-int:buffer-value(), vhLig:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cbapln:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCbapln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cbapln for cbapln.

    create query vhttquery.
    vhttBuffer = ghttCbapln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCbapln:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cbapln.
            if not outils:copyValidField(buffer cbapln:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCbapln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define variable vhLig    as handle  no-undo.
    define buffer cbapln for cbapln.

    create query vhttquery.
    vhttBuffer = ghttCbapln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCbapln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhNum-int, output vhLig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cbapln exclusive-lock
                where rowid(Cbapln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cbapln:handle, 'soc-cd/num-int/lig: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhNum-int:buffer-value(), vhLig:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cbapln no-error.
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

