/*------------------------------------------------------------------------
File        : ccptana2_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ccptana2
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ccptana2.i}
{application/include/error.i}
define variable ghttccptana2 as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phAna2-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/ana2-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'ana2-cd' then phAna2-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCcptana2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCcptana2.
    run updateCcptana2.
    run createCcptana2.
end procedure.

procedure setCcptana2:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCcptana2.
    ghttCcptana2 = phttCcptana2.
    run crudCcptana2.
    delete object phttCcptana2.
end procedure.

procedure readCcptana2:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ccptana2 Deuxiem fichier compte analytique
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter pcAna2-cd as character  no-undo.
    define input parameter table-handle phttCcptana2.
    define variable vhttBuffer as handle no-undo.
    define buffer ccptana2 for ccptana2.

    vhttBuffer = phttCcptana2:default-buffer-handle.
    for first ccptana2 no-lock
        where ccptana2.soc-cd = piSoc-cd
          and ccptana2.etab-cd = piEtab-cd
          and ccptana2.ana2-cd = pcAna2-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ccptana2:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCcptana2 no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCcptana2:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ccptana2 Deuxiem fichier compte analytique
    Notes  : service externe. Critère piEtab-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter table-handle phttCcptana2.
    define variable vhttBuffer as handle  no-undo.
    define buffer ccptana2 for ccptana2.

    vhttBuffer = phttCcptana2:default-buffer-handle.
    if piEtab-cd = ?
    then for each ccptana2 no-lock
        where ccptana2.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ccptana2:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ccptana2 no-lock
        where ccptana2.soc-cd = piSoc-cd
          and ccptana2.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ccptana2:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCcptana2 no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCcptana2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhAna2-cd    as handle  no-undo.
    define buffer ccptana2 for ccptana2.

    create query vhttquery.
    vhttBuffer = ghttCcptana2:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCcptana2:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhAna2-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ccptana2 exclusive-lock
                where rowid(ccptana2) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ccptana2:handle, 'soc-cd/etab-cd/ana2-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhAna2-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ccptana2:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCcptana2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ccptana2 for ccptana2.

    create query vhttquery.
    vhttBuffer = ghttCcptana2:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCcptana2:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ccptana2.
            if not outils:copyValidField(buffer ccptana2:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCcptana2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhAna2-cd    as handle  no-undo.
    define buffer ccptana2 for ccptana2.

    create query vhttquery.
    vhttBuffer = ghttCcptana2:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCcptana2:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhAna2-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ccptana2 exclusive-lock
                where rowid(Ccptana2) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ccptana2:handle, 'soc-cd/etab-cd/ana2-cd: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhAna2-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ccptana2 no-error.
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

