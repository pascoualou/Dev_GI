/*------------------------------------------------------------------------
File        : MandatSepa_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table MandatSepa
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}            // Doit être positionnée juste après using
/*{include/mandatSepa.i}*/
define variable ghttMandatSepa as handle no-undo.      // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phNomprelsepa as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noMPrelSEPA, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noMPrelSEPA' then phNomprelsepa = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudMandatsepa private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteMandatsepa.
    run updateMandatsepa.
    run createMandatsepa.
end procedure.

procedure setMandatsepa:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttMandatsepa.
    ghttMandatsepa = phttMandatsepa.
    run crudMandatsepa.
    delete object phttMandatsepa.
end procedure.

procedure readMandatsepa:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table MandatSepa Mandats de prélèvement SEPA
    Notes  : Fiche 0511/0023. Service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNomprelsepa as int64      no-undo.
    define input parameter table-handle phttMandatsepa.
    define variable vhttBuffer as handle no-undo.
    define buffer MandatSepa for MandatSepa.

    vhttBuffer = phttMandatsepa:default-buffer-handle.
    for first MandatSepa no-lock
        where MandatSepa.noMPrelSEPA = piNomprelsepa:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer MandatSepa:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttMandatsepa no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getMandatsepa:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table MandatSepa Mandats de prélèvement SEPA
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input  parameter pcTpcon    as character no-undo.
    define input  parameter piNocon    as int64     no-undo.
    define input  parameter pcTpmandat as character no-undo.
    define input  parameter pcNtcon    as character no-undo.
    define input parameter table-handle phttMandatsepa.
    define variable vhttBuffer as handle  no-undo.
    define buffer MandatSepa for MandatSepa.

    vhttBuffer = phttMandatsepa:default-buffer-handle.
    if pcNtcon > ""
    then for each mandatSepa no-lock
        where mandatSepa.tpcon    = pcTpcon
          and mandatSepa.nocon    = piNocon
          and mandatSepa.tpmandat = pcTpmandat
          and mandatSepa.ntcon    = pcNtcon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer mandatSepa:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each mandatSepa no-lock
        where mandatSepa.tpcon    = pcTpcon
          and mandatSepa.nocon    = piNocon
          and mandatSepa.tpmandat = pcTpmandat:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer MandatSepa:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttMandatsepa no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateMandatsepa private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery     as handle  no-undo.
    define variable vhttBuffer    as handle  no-undo.
    define variable vhNomprelsepa as handle  no-undo.
    define buffer MandatSepa for MandatSepa.

    create query vhttquery.
    vhttBuffer = ghttMandatsepa:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttMandatsepa:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomprelsepa).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first MandatSepa exclusive-lock
                where rowid(MandatSepa) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer MandatSepa:handle, 'noMPrelSEPA: ', substitute('&1', vhNomprelsepa:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer MandatSepa:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createMandatsepa private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer MandatSepa for MandatSepa.

    create query vhttquery.
    vhttBuffer = ghttMandatsepa:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttMandatsepa:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create MandatSepa.
            if not outils:copyValidField(buffer MandatSepa:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteMandatsepa private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery     as handle  no-undo.
    define variable vhttBuffer    as handle  no-undo.
    define variable vhNomprelsepa as handle  no-undo.
    define buffer MandatSepa for MandatSepa.

    create query vhttquery.
    vhttBuffer = ghttMandatsepa:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttMandatsepa:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomprelsepa).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first MandatSepa exclusive-lock
                where rowid(Mandatsepa) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer MandatSepa:handle, 'noMPrelSEPA: ', substitute('&1', vhNomprelsepa:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete MandatSepa no-error.
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

procedure deleteMandatSepaSurContrat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeMandatSepa as character no-undo.
    define input parameter pcTypeContrat    as character no-undo.
    define input parameter piNumeroContrat  as int64     no-undo.

    define buffer mandatSepa    for mandatSepa.
    define buffer suimandatSepa for suimandatSepa.

message "deleteMandatSepaSurContrat "  pcTypeMandatSepa "// " pcTypeContrat "// " piNumeroContrat.

blocTrans:
    do transaction:
        for each mandatSepa exclusive-lock
           where mandatSepa.tpmandat = pcTypeMandatSepa
             and mandatSepa.tpcon    = pcTypeContrat 
             and mandatSepa.nocon    = piNumeroContrat:
            for each suimandatSepa exclusive-lock
               where suimandatSepa.noMPrelSEPA = mandatSepa.noMPrelSEPA:
                delete suimandatSepa no-error.
                if error-status:error then do:
                    mError:createError({&error}, error-status:get-message(1)).
                    undo blocTrans, leave blocTrans.
                end.
            end.
            delete mandatSepa no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status
    return.
end procedure.

procedure deleteMandatSepa01:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeMandatSepa as character no-undo.
    define input parameter pcTypeContrat    as character no-undo.
    define input parameter piNumeroContrat  as int64     no-undo.
    define input parameter pcTypeRole       as character no-undo.
    define input parameter piNumeroRole     as int64     no-undo.
    
    define buffer mandatSepa    for mandatSepa.
    define buffer suimandatSepa for suimandatSepa.

message "deleteMandatSepa01 "  pcTypeMandatSepa "// " pcTypeContrat "// " piNumeroContrat "// " pcTypeRole "// " piNumeroRole.

blocTrans:
    do transaction:
        for each mandatsepa exclusive-lock
           where mandatsepa.tpmandat = pcTypeMandatSepa
             and mandatsepa.tpcon    = pcTypeContrat
             and mandatsepa.nocon    = piNumeroContrat
             and mandatsepa.tprol    = pcTypeRole
             and mandatsepa.norol    = piNumeroRole:
            for each suimandatSepa exclusive-lock 
               where suimandatSepa.noMPrelSEPA = mandatSepa.noMPrelSEPA:
                delete suimandatSepa no-error.
                if error-status:error then do:
                    mError:createError({&error}, error-status:get-message(1)).
                    undo blocTrans, leave blocTrans.
                end.
            end.   
            find current mandatSEPA exclusive-lock. 
            delete mandatSEPA no-error.     
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.                
        end.
    end.
    error-status:error = false no-error.  // reset error-status
    return.
end procedure.
