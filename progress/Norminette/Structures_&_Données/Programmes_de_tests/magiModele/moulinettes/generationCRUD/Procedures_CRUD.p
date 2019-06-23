/*------------------------------------------------------------------------
File        : Procedures_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table Procedures
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/Procedures.i}
{application/include/error.i}
define variable ghttProcedures as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phCtypeprocedure as handle, output phDdatedebut as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpcon/nocon/cTypeProcedure/dDateDebut, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
            when 'cTypeProcedure' then phCtypeprocedure = phBuffer:buffer-field(vi).
            when 'dDateDebut' then phDdatedebut = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudProcedures private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteProcedures.
    run updateProcedures.
    run createProcedures.
end procedure.

procedure setProcedures:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttProcedures.
    ghttProcedures = phttProcedures.
    run crudProcedures.
    delete object phttProcedures.
end procedure.

procedure readProcedures:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table Procedures Procédures / arrêtés sur une copropriété
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon          as character  no-undo.
    define input parameter piNocon          as int64      no-undo.
    define input parameter pcCtypeprocedure as character  no-undo.
    define input parameter pdaDdatedebut     as date       no-undo.
    define input parameter table-handle phttProcedures.
    define variable vhttBuffer as handle no-undo.
    define buffer Procedures for Procedures.

    vhttBuffer = phttProcedures:default-buffer-handle.
    for first Procedures no-lock
        where Procedures.tpcon = pcTpcon
          and Procedures.nocon = piNocon
          and Procedures.cTypeProcedure = pcCtypeprocedure
          and Procedures.dDateDebut = pdaDdatedebut:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer Procedures:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttProcedures no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getProcedures:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table Procedures Procédures / arrêtés sur une copropriété
    Notes  : service externe. Critère pcCtypeprocedure = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon          as character  no-undo.
    define input parameter piNocon          as int64      no-undo.
    define input parameter pcCtypeprocedure as character  no-undo.
    define input parameter table-handle phttProcedures.
    define variable vhttBuffer as handle  no-undo.
    define buffer Procedures for Procedures.

    vhttBuffer = phttProcedures:default-buffer-handle.
    if pcCtypeprocedure = ?
    then for each Procedures no-lock
        where Procedures.tpcon = pcTpcon
          and Procedures.nocon = piNocon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer Procedures:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each Procedures no-lock
        where Procedures.tpcon = pcTpcon
          and Procedures.nocon = piNocon
          and Procedures.cTypeProcedure = pcCtypeprocedure:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer Procedures:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttProcedures no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateProcedures private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhCtypeprocedure    as handle  no-undo.
    define variable vhDdatedebut    as handle  no-undo.
    define buffer Procedures for Procedures.

    create query vhttquery.
    vhttBuffer = ghttProcedures:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttProcedures:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhCtypeprocedure, output vhDdatedebut).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first Procedures exclusive-lock
                where rowid(Procedures) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer Procedures:handle, 'tpcon/nocon/cTypeProcedure/dDateDebut: ', substitute('&1/&2/&3/&4', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhCtypeprocedure:buffer-value(), vhDdatedebut:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer Procedures:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createProcedures private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer Procedures for Procedures.

    create query vhttquery.
    vhttBuffer = ghttProcedures:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttProcedures:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create Procedures.
            if not outils:copyValidField(buffer Procedures:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteProcedures private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhCtypeprocedure    as handle  no-undo.
    define variable vhDdatedebut    as handle  no-undo.
    define buffer Procedures for Procedures.

    create query vhttquery.
    vhttBuffer = ghttProcedures:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttProcedures:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhCtypeprocedure, output vhDdatedebut).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first Procedures exclusive-lock
                where rowid(Procedures) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer Procedures:handle, 'tpcon/nocon/cTypeProcedure/dDateDebut: ', substitute('&1/&2/&3/&4', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhCtypeprocedure:buffer-value(), vhDdatedebut:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete Procedures no-error.
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

