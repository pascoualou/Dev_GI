/*------------------------------------------------------------------------
File        : apartva_CRUD.p
Purpose     : Librairie contenant les procedures li�es � la mise � jour de la table apartva
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table � condition
              que les champs de l'index unique soient tous pr�sents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit �tre positionn�e juste apr�s using
//{include/apartva.i}
{application/include/error.i}
define variable ghttapartva as handle no-undo.      // le handle de la temp table � mettre � jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: r�cup�re les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudApartva private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteApartva.
    run updateApartva.
    run createApartva.
end procedure.

procedure setApartva:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttApartva.
    ghttApartva = phttApartva.
    run crudApartva.
    delete object phttApartva.
end procedure.

procedure readApartva:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table apartva 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd as integer    no-undo.
    define input parameter table-handle phttApartva.
    define variable vhttBuffer as handle no-undo.
    define buffer apartva for apartva.

    vhttBuffer = phttApartva:default-buffer-handle.
    for first apartva no-lock
        where apartva.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer apartva:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttApartva no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getApartva:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table apartva 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttApartva.
    define variable vhttBuffer as handle  no-undo.
    define buffer apartva for apartva.

    vhttBuffer = phttApartva:default-buffer-handle.
    for each apartva no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer apartva:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttApartva no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateApartva private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define buffer apartva for apartva.

    create query vhttquery.
    vhttBuffer = ghttApartva:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttApartva:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first apartva exclusive-lock
                where rowid(apartva) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer apartva:handle, 'soc-cd: ', substitute('&1', vhSoc-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer apartva:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createApartva private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer apartva for apartva.

    create query vhttquery.
    vhttBuffer = ghttApartva:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttApartva:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create apartva.
            if not outils:copyValidField(buffer apartva:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteApartva private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define buffer apartva for apartva.

    create query vhttquery.
    vhttBuffer = ghttApartva:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttApartva:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first apartva exclusive-lock
                where rowid(Apartva) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer apartva:handle, 'soc-cd: ', substitute('&1', vhSoc-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete apartva no-error.
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

