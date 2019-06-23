/*------------------------------------------------------------------------
File        : csscptcol_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table csscptcol
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/csscptcol.i}
{application/include/error.i}
define variable ghttcsscptcol as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phSscoll-cpt as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/sscoll-cpt, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'sscoll-cpt' then phSscoll-cpt = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCsscptcol private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCsscptcol.
    run updateCsscptcol.
    run createCsscptcol.
end procedure.

procedure setCsscptcol:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCsscptcol.
    ghttCsscptcol = phttCsscptcol.
    run crudCsscptcol.
    delete object phttCsscptcol.
end procedure.

procedure readCsscptcol:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table csscptcol Fichier collectif
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcSscoll-cpt as character  no-undo.
    define input parameter table-handle phttCsscptcol.
    define variable vhttBuffer as handle no-undo.
    define buffer csscptcol for csscptcol.

    vhttBuffer = phttCsscptcol:default-buffer-handle.
    for first csscptcol no-lock
        where csscptcol.soc-cd = piSoc-cd
          and csscptcol.etab-cd = piEtab-cd
          and csscptcol.sscoll-cpt = pcSscoll-cpt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer csscptcol:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCsscptcol no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCsscptcol:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table csscptcol Fichier collectif
    Notes  : service externe. Critère piEtab-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter table-handle phttCsscptcol.
    define variable vhttBuffer as handle  no-undo.
    define buffer csscptcol for csscptcol.

    vhttBuffer = phttCsscptcol:default-buffer-handle.
    if piEtab-cd = ?
    then for each csscptcol no-lock
        where csscptcol.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer csscptcol:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each csscptcol no-lock
        where csscptcol.soc-cd = piSoc-cd
          and csscptcol.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer csscptcol:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCsscptcol no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCsscptcol private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhSscoll-cpt    as handle  no-undo.
    define buffer csscptcol for csscptcol.

    create query vhttquery.
    vhttBuffer = ghttCsscptcol:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCsscptcol:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhSscoll-cpt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first csscptcol exclusive-lock
                where rowid(csscptcol) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer csscptcol:handle, 'soc-cd/etab-cd/sscoll-cpt: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhSscoll-cpt:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer csscptcol:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCsscptcol private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer csscptcol for csscptcol.

    create query vhttquery.
    vhttBuffer = ghttCsscptcol:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCsscptcol:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create csscptcol.
            if not outils:copyValidField(buffer csscptcol:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCsscptcol private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhSscoll-cpt    as handle  no-undo.
    define buffer csscptcol for csscptcol.

    create query vhttquery.
    vhttBuffer = ghttCsscptcol:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCsscptcol:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhSscoll-cpt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first csscptcol exclusive-lock
                where rowid(Csscptcol) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer csscptcol:handle, 'soc-cd/etab-cd/sscoll-cpt: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhSscoll-cpt:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete csscptcol no-error.
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

procedure deleteCsscptcolSurEtabCd:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSociete   as integer no-undo.
    define input parameter piCodeEtabl as integer no-undo.
    
    define buffer csscptcol for csscptcol.
    define buffer csscpt    for csscpt.

message "deleteCsscptcolSurEtabCd " piSociete "// " piCodeEtabl. 

blocTrans:
    do transaction:
        for each csscptcol exclusive-lock 
           where csscptcol.soc-cd  = piSociete
             and csscptcol.etab-cd = piCodeEtabl:
            for each csscpt exclusive-lock 
               where csscpt.soc-cd     = csscptcol.soc-cd
                 and csscpt.etab-cd    = csscptcol.etab-cd
                 and csscpt.sscoll-cle = csscptcol.sscoll-cle:
                delete csscpt no-error.
                if error-status:error then do:
                    mError:createError({&error}, error-status:get-message(1)).
                    undo blocTrans, leave blocTrans.
                end.
            end.
            delete csscptcol no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.


