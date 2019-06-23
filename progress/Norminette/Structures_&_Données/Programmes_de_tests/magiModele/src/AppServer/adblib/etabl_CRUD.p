/*------------------------------------------------------------------------
File        : etabl_CRUD.p
Purpose     : Librairie contenant toutes les procedures liees a la mise a jour de la table etabl
Author(s)   : SY 20/02/1998 - GGA 2017/11/13
Notes       : repris depuis adb/lib/l_etabl.p (et seulement les procedures utilisees)
------------------------------------------------------------------------*/
{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
{adblib/include/etabl.i}
{application/include/error.i}
define variable ghttEtabl as handle no-undo.      // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phTptac as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpcon/nocon/tptac, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
            when 'tptac' then phTptac = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudEtabl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteEtabl.
    run updateEtabl.
    run createEtabl.
end procedure.

procedure setEtabl:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttEtabl.
    ghttEtabl = phttEtabl.
    run crudEtabl.
    delete object phttEtabl.
end procedure.

procedure readEtabl:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table Etabl Etablissement (Paie)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as integer    no-undo.
    define input parameter pcTptac as character  no-undo.
    define input parameter table-handle phttEtabl.
    define variable vhttBuffer as handle no-undo.
    define buffer Etabl for Etabl.

    vhttBuffer = phttEtabl:default-buffer-handle.
    for first Etabl no-lock
        where Etabl.tpcon = pcTpcon
          and Etabl.nocon = piNocon
          and Etabl.tptac = pcTptac:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer Etabl:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEtabl no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getEtabl:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table Etabl Etablissement (Paie)
    Notes  : service externe. Critère piNocon = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as integer    no-undo.
    define input parameter table-handle phttEtabl.
    define variable vhttBuffer as handle  no-undo.
    define buffer Etabl for Etabl.

    vhttBuffer = phttEtabl:default-buffer-handle.
    if piNocon = ?
    then for each Etabl no-lock
        where Etabl.tpcon = pcTpcon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer Etabl:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each Etabl no-lock
        where Etabl.tpcon = pcTpcon
          and Etabl.nocon = piNocon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer Etabl:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEtabl no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateEtabl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhTptac    as handle  no-undo.
    define buffer Etabl for Etabl.

    create query vhttquery.
    vhttBuffer = ghttEtabl:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttEtabl:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhTptac).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first Etabl exclusive-lock
                where rowid(Etabl) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer Etabl:handle, 'tpcon/nocon/tptac: ', substitute('&1/&2/&3', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhTptac:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer Etabl:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createEtabl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer Etabl for Etabl.

    create query vhttquery.
    vhttBuffer = ghttEtabl:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttEtabl:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create Etabl.
            if not outils:copyValidField(buffer Etabl:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteEtabl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhTptac    as handle  no-undo.
    define buffer Etabl for Etabl.

    create query vhttquery.
    vhttBuffer = ghttEtabl:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttEtabl:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhTptac).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first Etabl exclusive-lock
                where rowid(Etabl) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer Etabl:handle, 'tpcon/nocon/tptac: ', substitute('&1/&2/&3', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhTptac:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete Etabl no-error.
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

procedure deleteEtablSurContrat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as integer   no-undo.
    
    define buffer etabl for etabl.

message "deleteEtablSurContrat "  pcTypeContrat "// " piNumeroContrat.

blocTrans:
    do transaction:
        for each etabl exclusive-lock   
           where etabl.tpcon = pcTypeContrat
             and etabl.nocon = piNumeroContrat:
            delete etabl no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.

