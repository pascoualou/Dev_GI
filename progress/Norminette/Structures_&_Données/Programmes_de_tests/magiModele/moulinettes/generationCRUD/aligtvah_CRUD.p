/*------------------------------------------------------------------------
File        : aligtvah_CRUD.p
Purpose     : Librairie contenant les procedures li�es � la mise � jour de la table aligtvah
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table � condition
              que les champs de l'index unique soient tous pr�sents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit �tre positionn�e juste apr�s using
//{include/aligtvah.i}
{application/include/error.i}
define variable ghttaligtvah as handle no-undo.      // le handle de la temp table � mettre � jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phDahist as handle, output phChrono as handle):
    /*------------------------------------------------------------------------------
    Purpose: r�cup�re les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/dahist/chrono, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'dahist' then phDahist = phBuffer:buffer-field(vi).
            when 'chrono' then phChrono = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAligtvah private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAligtvah.
    run updateAligtvah.
    run createAligtvah.
end procedure.

procedure setAligtvah:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAligtvah.
    ghttAligtvah = phttAligtvah.
    run crudAligtvah.
    delete object phttAligtvah.
end procedure.

procedure readAligtvah:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table aligtvah 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter pdaDahist  as date       no-undo.
    define input parameter piChrono  as integer    no-undo.
    define input parameter table-handle phttAligtvah.
    define variable vhttBuffer as handle no-undo.
    define buffer aligtvah for aligtvah.

    vhttBuffer = phttAligtvah:default-buffer-handle.
    for first aligtvah no-lock
        where aligtvah.soc-cd = piSoc-cd
          and aligtvah.etab-cd = piEtab-cd
          and aligtvah.dahist = pdaDahist
          and aligtvah.chrono = piChrono:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aligtvah:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAligtvah no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAligtvah:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table aligtvah 
    Notes  : service externe. Crit�re pdaDahist = ? si pas � prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter pdaDahist  as date       no-undo.
    define input parameter table-handle phttAligtvah.
    define variable vhttBuffer as handle  no-undo.
    define buffer aligtvah for aligtvah.

    vhttBuffer = phttAligtvah:default-buffer-handle.
    if pdaDahist = ?
    then for each aligtvah no-lock
        where aligtvah.soc-cd = piSoc-cd
          and aligtvah.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aligtvah:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each aligtvah no-lock
        where aligtvah.soc-cd = piSoc-cd
          and aligtvah.etab-cd = piEtab-cd
          and aligtvah.dahist = pdaDahist:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aligtvah:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAligtvah no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAligtvah private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhDahist    as handle  no-undo.
    define variable vhChrono    as handle  no-undo.
    define buffer aligtvah for aligtvah.

    create query vhttquery.
    vhttBuffer = ghttAligtvah:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAligtvah:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhDahist, output vhChrono).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first aligtvah exclusive-lock
                where rowid(aligtvah) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer aligtvah:handle, 'soc-cd/etab-cd/dahist/chrono: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhDahist:buffer-value(), vhChrono:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer aligtvah:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAligtvah private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer aligtvah for aligtvah.

    create query vhttquery.
    vhttBuffer = ghttAligtvah:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAligtvah:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create aligtvah.
            if not outils:copyValidField(buffer aligtvah:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAligtvah private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhDahist    as handle  no-undo.
    define variable vhChrono    as handle  no-undo.
    define buffer aligtvah for aligtvah.

    create query vhttquery.
    vhttBuffer = ghttAligtvah:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAligtvah:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhDahist, output vhChrono).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first aligtvah exclusive-lock
                where rowid(Aligtvah) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer aligtvah:handle, 'soc-cd/etab-cd/dahist/chrono: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhDahist:buffer-value(), vhChrono:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete aligtvah no-error.
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

