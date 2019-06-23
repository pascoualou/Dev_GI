/*------------------------------------------------------------------------
File        : cengsai_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cengsai
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cengsai.i}
{application/include/error.i}
define variable ghttcengsai as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phNiv-num as handle, output phAna-cd as handle, output phNum-int as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/niv-num/ana-cd/num-int, 
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
       end case.
    end.
end function.

procedure crudCengsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCengsai.
    run updateCengsai.
    run createCengsai.
end procedure.

procedure setCengsai:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCengsai.
    ghttCengsai = phttCengsai.
    run crudCengsai.
    delete object phttCengsai.
end procedure.

procedure readCengsai:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cengsai 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piNiv-num as integer    no-undo.
    define input parameter pcAna-cd  as character  no-undo.
    define input parameter piNum-int as integer    no-undo.
    define input parameter table-handle phttCengsai.
    define variable vhttBuffer as handle no-undo.
    define buffer cengsai for cengsai.

    vhttBuffer = phttCengsai:default-buffer-handle.
    for first cengsai no-lock
        where cengsai.soc-cd = piSoc-cd
          and cengsai.etab-cd = piEtab-cd
          and cengsai.niv-num = piNiv-num
          and cengsai.ana-cd = pcAna-cd
          and cengsai.num-int = piNum-int:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cengsai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCengsai no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCengsai:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cengsai 
    Notes  : service externe. Critère pcAna-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piNiv-num as integer    no-undo.
    define input parameter pcAna-cd  as character  no-undo.
    define input parameter table-handle phttCengsai.
    define variable vhttBuffer as handle  no-undo.
    define buffer cengsai for cengsai.

    vhttBuffer = phttCengsai:default-buffer-handle.
    if pcAna-cd = ?
    then for each cengsai no-lock
        where cengsai.soc-cd = piSoc-cd
          and cengsai.etab-cd = piEtab-cd
          and cengsai.niv-num = piNiv-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cengsai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cengsai no-lock
        where cengsai.soc-cd = piSoc-cd
          and cengsai.etab-cd = piEtab-cd
          and cengsai.niv-num = piNiv-num
          and cengsai.ana-cd = pcAna-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cengsai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCengsai no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCengsai private:
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
    define buffer cengsai for cengsai.

    create query vhttquery.
    vhttBuffer = ghttCengsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCengsai:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNiv-num, output vhAna-cd, output vhNum-int).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cengsai exclusive-lock
                where rowid(cengsai) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cengsai:handle, 'soc-cd/etab-cd/niv-num/ana-cd/num-int: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNiv-num:buffer-value(), vhAna-cd:buffer-value(), vhNum-int:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cengsai:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCengsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cengsai for cengsai.

    create query vhttquery.
    vhttBuffer = ghttCengsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCengsai:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cengsai.
            if not outils:copyValidField(buffer cengsai:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCengsai private:
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
    define buffer cengsai for cengsai.

    create query vhttquery.
    vhttBuffer = ghttCengsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCengsai:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNiv-num, output vhAna-cd, output vhNum-int).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cengsai exclusive-lock
                where rowid(Cengsai) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cengsai:handle, 'soc-cd/etab-cd/niv-num/ana-cd/num-int: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNiv-num:buffer-value(), vhAna-cd:buffer-value(), vhNum-int:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cengsai no-error.
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

