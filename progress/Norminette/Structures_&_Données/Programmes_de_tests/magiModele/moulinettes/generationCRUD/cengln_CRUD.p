/*------------------------------------------------------------------------
File        : cengln_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cengln
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cengln.i}
{application/include/error.i}
define variable ghttcengln as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phNiv-num as handle, output phAna-cd as handle, output phNum-int as handle, output phLig as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/niv-num/ana-cd/num-int/lig, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'niv-num' then phNiv-num = phBuffer:buffer-field(vi).
            when 'ana-cd' then phAna-cd = phBuffer:buffer-field(vi).
            when 'num-int' then phNum-int = phBuffer:buffer-field(vi).
            when 'lig' then phLig = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCengln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCengln.
    run updateCengln.
    run createCengln.
end procedure.

procedure setCengln:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCengln.
    ghttCengln = phttCengln.
    run crudCengln.
    delete object phttCengln.
end procedure.

procedure readCengln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cengln 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piNiv-num as integer    no-undo.
    define input parameter pcAna-cd  as character  no-undo.
    define input parameter piNum-int as integer    no-undo.
    define input parameter piLig     as integer    no-undo.
    define input parameter table-handle phttCengln.
    define variable vhttBuffer as handle no-undo.
    define buffer cengln for cengln.

    vhttBuffer = phttCengln:default-buffer-handle.
    for first cengln no-lock
        where cengln.soc-cd = piSoc-cd
          and cengln.etab-cd = piEtab-cd
          and cengln.niv-num = piNiv-num
          and cengln.ana-cd = pcAna-cd
          and cengln.num-int = piNum-int
          and cengln.lig = piLig:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cengln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCengln no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCengln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cengln 
    Notes  : service externe. Critère piNum-int = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piNiv-num as integer    no-undo.
    define input parameter pcAna-cd  as character  no-undo.
    define input parameter piNum-int as integer    no-undo.
    define input parameter table-handle phttCengln.
    define variable vhttBuffer as handle  no-undo.
    define buffer cengln for cengln.

    vhttBuffer = phttCengln:default-buffer-handle.
    if piNum-int = ?
    then for each cengln no-lock
        where cengln.soc-cd = piSoc-cd
          and cengln.etab-cd = piEtab-cd
          and cengln.niv-num = piNiv-num
          and cengln.ana-cd = pcAna-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cengln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cengln no-lock
        where cengln.soc-cd = piSoc-cd
          and cengln.etab-cd = piEtab-cd
          and cengln.niv-num = piNiv-num
          and cengln.ana-cd = pcAna-cd
          and cengln.num-int = piNum-int:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cengln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCengln no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCengln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNiv-num    as handle  no-undo.
    define variable vhAna-cd    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define variable vhLig    as handle  no-undo.
    define buffer cengln for cengln.

    create query vhttquery.
    vhttBuffer = ghttCengln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCengln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNiv-num, output vhAna-cd, output vhNum-int, output vhLig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cengln exclusive-lock
                where rowid(cengln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cengln:handle, 'soc-cd/etab-cd/niv-num/ana-cd/num-int/lig: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNiv-num:buffer-value(), vhAna-cd:buffer-value(), vhNum-int:buffer-value(), vhLig:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cengln:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCengln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cengln for cengln.

    create query vhttquery.
    vhttBuffer = ghttCengln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCengln:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cengln.
            if not outils:copyValidField(buffer cengln:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCengln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNiv-num    as handle  no-undo.
    define variable vhAna-cd    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define variable vhLig    as handle  no-undo.
    define buffer cengln for cengln.

    create query vhttquery.
    vhttBuffer = ghttCengln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCengln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNiv-num, output vhAna-cd, output vhNum-int, output vhLig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cengln exclusive-lock
                where rowid(Cengln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cengln:handle, 'soc-cd/etab-cd/niv-num/ana-cd/num-int/lig: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNiv-num:buffer-value(), vhAna-cd:buffer-value(), vhNum-int:buffer-value(), vhLig:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cengln no-error.
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

