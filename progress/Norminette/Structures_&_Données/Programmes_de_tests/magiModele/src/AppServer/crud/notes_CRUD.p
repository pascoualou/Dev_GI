/*------------------------------------------------------------------------
File        : notes_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table notes
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttnotes as handle no-undo.      // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phNoblc as handle, output phNorub as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noblc/norub, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noblc' then phNoblc = phBuffer:buffer-field(vi).
            when 'norub' then phNorub = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure getNextNotes:
    /*------------------------------------------------------------------------------
    Purpose: Récupère le numéro de bloc et de rubrique pour la création d'une note
    Notes  : ATTENTION : si le numero de bloc est nul, on veut creer un nouveau bloc note et non pas une nouvelle rubrique
             service externe et interne
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroBlocIN   as integer no-undo.
    define output parameter piNumeroBlocOUT  as integer no-undo.
    define output parameter piNumeroRubrique as integer no-undo.

    define buffer notes for notes.

    if piNumeroBlocIN = 0 or piNumeroBlocIN = ?
    then do:
        /* par defaut la premiere rubrique est n°1 */
        piNumeroRubrique = 1.
        {&_proparse_ prolint-nowarn(wholeindex)}
        find last notes no-lock no-error.
        piNumeroBlocOUT = if available notes then notes.noblc + 1 else 1.
    end.
    else do:
        piNumeroBlocOUT = piNumeroBlocIN.
        /* recherche rubrique suivante du bloc note en cours */
        {&_proparse_ prolint-nowarn(wholeindex)}
        find last notes no-lock
            where notes.noblc = piNumeroBlocIN no-error.
        if available notes 
        then piNumeroRubrique = notes.norub + 1.
        else piNumeroRubrique = 1.                     //pas encore de note (creation mais avec numero de bloc note renseigne avant maj) 
    end.

end procedure.

procedure crudNotes private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteNotes.
    run updateNotes.
    run createNotes.
end procedure.

procedure setNotes:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input-output parameter table-handle phttNotes.
    ghttNotes = phttNotes.
    run crudNotes.
    delete object phttNotes.
end procedure.

procedure readNotes:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table notes 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoblc as int64     no-undo.
    define input parameter piNorub as integer   no-undo.
    define input-output parameter table-handle phttNotes.

    define variable vhttBuffer as handle no-undo.
    define buffer notes for notes.

    vhttBuffer = phttNotes:default-buffer-handle.
    for first notes no-lock
        where notes.noblc = piNoblc
          and notes.norub = piNorub:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer notes:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttNotes no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getNotes:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table notes 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter piNoblc as int64    no-undo.
    define input-output parameter table-handle phttNotes.

    define variable vhttBuffer as handle  no-undo.
    define buffer notes for notes.

    vhttBuffer = phttNotes:default-buffer-handle.
    for each notes no-lock
        where notes.noblc = piNoblc:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer notes:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttNotes no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateNotes private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoblc    as handle  no-undo.
    define variable vhNorub    as handle  no-undo.
    define buffer notes for notes.

    create query vhttquery.
    vhttBuffer = ghttNotes:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttNotes:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoblc, output vhNorub).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first notes exclusive-lock
                where rowid(notes) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer notes:handle, 'noblc/norub: ', substitute('&1/&2', vhNoblc:buffer-value(), vhNorub:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer notes:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createNotes private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable viNumeroBloc     as integer no-undo.
    define variable viNumeroRubrique as integer no-undo.
    define variable vhttquery        as handle  no-undo.
    define variable vhttBuffer       as handle  no-undo.
    define variable vhNoblc          as handle  no-undo.
    define variable vhNorub          as handle  no-undo.
    define buffer notes for notes.

    create query vhttquery.
    vhttBuffer = ghttNotes:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttNotes:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoblc, output vhNorub).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            run getNextNotes(vhNoblc:buffer-value(), output viNumeroBloc, output viNumeroRubrique).
            assign
                vhNoblc:buffer-value() = viNumeroBloc
                vhNorub:buffer-value() = viNumeroRubrique
            .
            create notes.
            if not outils:copyValidField(buffer notes:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteNotes private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoblc    as handle  no-undo.
    define variable vhNorub    as handle  no-undo.
    define buffer notes for notes.

    create query vhttquery.
    vhttBuffer = ghttNotes:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttNotes:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoblc, output vhNorub).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first notes exclusive-lock
                where rowid(Notes) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer notes:handle, 'noblc/norub: ', substitute('&1/&2', vhNoblc:buffer-value(), vhNorub:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete notes no-error.
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

procedure deleteNotesSurNoblc:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroBloc as int64 no-undo.

    define buffer notes for notes.

blocTrans:
    do transaction:
        for each notes exclusive-lock 
           where notes.noblc = piNumeroBloc:
            delete notes no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
