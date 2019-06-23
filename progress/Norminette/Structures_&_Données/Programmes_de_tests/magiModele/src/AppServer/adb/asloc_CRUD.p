/*------------------------------------------------------------------------
File        : asloc_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table asloc
Author(s)   : generation automatique le 01/30/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
Derniere revue: 2018/04/26 - phm: OK
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttasloc as handle no-undo.     // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phNoloc as handle, output phMsqtt as handle, output phNoass as handle, output phNobar as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noloc/msqtt/noass/nobar, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noloc' then phNoloc = phBuffer:buffer-field(vi).
            when 'msqtt' then phMsqtt = phBuffer:buffer-field(vi).
            when 'noass' then phNoass = phBuffer:buffer-field(vi).
            when 'nobar' then phNobar = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAsloc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAsloc.
    run updateAsloc.
    run createAsloc.
end procedure.

procedure setAsloc:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAsloc.
    ghttAsloc = phttAsloc.
    run crudAsloc.
    delete object phttAsloc.
end procedure.

procedure readAsloc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table asloc 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoloc as int64    no-undo.
    define input parameter piMsqtt as integer  no-undo.
    define input parameter piNoass as integer  no-undo.
    define input parameter piNobar as integer  no-undo.
    define input parameter table-handle phttAsloc.

    define variable vhttBuffer as handle no-undo.
    define buffer asloc for asloc.

    vhttBuffer = phttAsloc:default-buffer-handle.
    for first asloc no-lock
        where asloc.noloc = piNoloc
          and asloc.msqtt = piMsqtt
          and asloc.noass = piNoass
          and asloc.nobar = piNobar:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer asloc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAsloc no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAsloc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table asloc 
    Notes  : service externe. Critère piNoass = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNoloc as int64    no-undo.
    define input parameter piMsqtt as integer  no-undo.
    define input parameter piNoass as integer  no-undo.
    define input parameter table-handle phttAsloc.

    define variable vhttBuffer as handle  no-undo.
    define buffer asloc for asloc.

    vhttBuffer = phttAsloc:default-buffer-handle.
    if piNoass = ?
    then for each asloc no-lock
        where asloc.noloc = piNoloc
          and asloc.msqtt = piMsqtt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer asloc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each asloc no-lock
        where asloc.noloc = piNoloc
          and asloc.msqtt = piMsqtt
          and asloc.noass = piNoass:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer asloc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAsloc no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAsloc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNoloc    as handle  no-undo.
    define variable vhMsqtt    as handle  no-undo.
    define variable vhNoass    as handle  no-undo.
    define variable vhNobar    as handle  no-undo.
    define buffer asloc for asloc.

    create query vhttquery.
    vhttBuffer = ghttAsloc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAsloc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoloc, output vhMsqtt, output vhNoass, output vhNobar).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first asloc exclusive-lock
                where rowid(asloc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer asloc:handle, 'noloc/msqtt/noass/nobar: ', substitute('&1/&2/&3/&4', vhNoloc:buffer-value(), vhMsqtt:buffer-value(), vhNoass:buffer-value(), vhNobar:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer asloc:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAsloc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer asloc for asloc.

    create query vhttquery.
    vhttBuffer = ghttAsloc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAsloc:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create asloc.
            if not outils:copyValidField(buffer asloc:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAsloc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNoloc    as handle  no-undo.
    define variable vhMsqtt    as handle  no-undo.
    define variable vhNoass    as handle  no-undo.
    define variable vhNobar    as handle  no-undo.
    define buffer asloc for asloc.

    create query vhttquery.
    vhttBuffer = ghttAsloc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAsloc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoloc, output vhMsqtt, output vhNoass, output vhNobar).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first asloc exclusive-lock
                where rowid(Asloc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer asloc:handle, 'noloc/msqtt/noass/nobar: ', substitute('&1/&2/&3/&4', vhNoloc:buffer-value(), vhMsqtt:buffer-value(), vhNoass:buffer-value(), vhNobar:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete asloc no-error.
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

procedure deleteAslocBailMois:
    /*---------------------------------------------------------------------------
    Purpose : Suppression des asloc d'un bail dont la msqtt est supérieur à un mois.
    Notes   : service externe. Appelé par calasslo.p
    ---------------------------------------------------------------------------*/
    define input  parameter piNumeroBail        as integer no-undo.
    define input  parameter piMoisQuittancement as integer no-undo.

    define buffer asloc for asloc.

    for each asloc exclusive-lock
        where asloc.noloc = piNumeroBail
          and asloc.msqtt >= piMoisQuittancement:
        delete asloc.
    end.
end procedure.
