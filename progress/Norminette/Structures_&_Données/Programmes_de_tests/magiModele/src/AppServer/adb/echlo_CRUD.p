/*------------------------------------------------------------------------
File        : echlo_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table echlo
Author(s)   : generation automatique le 2018/01/31
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
derniere revue: 2018/04/25 - phm: OK
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttechlo as handle no-undo.      // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phNoper as handle, output phNoact as handle, output phNocal as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpcon/nocon/noper/noact/nocal, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.

    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
            when 'noper' then phNoper = phBuffer:buffer-field(vi).
            when 'noact' then phNoact = phBuffer:buffer-field(vi).
            when 'nocal' then phNocal = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudEchlo private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteEchlo.
    run updateEchlo.
    run createEchlo.
end procedure.

procedure setEchlo:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttEchlo.

    ghttEchlo = phttEchlo.
    run crudEchlo.
    delete object phttEchlo.
end procedure.

procedure readEchlo:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table echlo Echelle des loyers
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character no-undo.
    define input parameter piNocon as int64     no-undo.
    define input parameter piNoper as integer   no-undo.
    define input parameter piNoact as integer   no-undo.
    define input parameter piNocal as integer   no-undo.
    define input parameter table-handle phttEchlo.

    define variable vhttBuffer as handle no-undo.
    define buffer echlo for echlo.

    vhttBuffer = phttEchlo:default-buffer-handle.
    for first echlo no-lock
        where echlo.tpcon = pcTpcon
          and echlo.nocon = piNocon
          and echlo.noper = piNoper
          and echlo.noact = piNoact
          and echlo.nocal = piNocal:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer echlo:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEchlo no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getEchlo:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table echlo Echelle des loyers
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character no-undo.
    define input parameter piNocon as int64     no-undo.
    define input parameter piNoper as integer   no-undo.
    define input parameter piNoact as integer   no-undo.
    define input parameter piNocal as integer   no-undo.
    define input parameter table-handle phttEchlo.

    define variable vhttBuffer as handle  no-undo.
    define buffer echlo for echlo.

    vhttBuffer = phttEchlo:default-buffer-handle.
    if piNoact = ? and piNocal = ?
    then for each echlo no-lock
        where echlo.tpcon = pcTpcon
          and echlo.nocon = piNocon
          and echlo.noper = piNoper:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer echlo:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else if piNoact = ?
    then for each echlo no-lock
        where echlo.tpcon = pcTpcon
          and echlo.nocon = piNocon
          and echlo.noper = piNoper
          and echlo.nocal = piNocal:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer echlo:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else if piNocal = ?
    then for each echlo no-lock
        where echlo.tpcon = pcTpcon
          and echlo.nocon = piNocon
          and echlo.noper = piNoper
          and echlo.nocal = piNoact:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer echlo:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each echlo no-lock    // équivallent au read.
        where echlo.tpcon = pcTpcon
          and echlo.nocon = piNocon
          and echlo.noper = piNoper
          and echlo.noact = piNoact
          and echlo.nocal = piNocal:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer echlo:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEchlo no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateEchlo private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNoper    as handle  no-undo.
    define variable vhNoact    as handle  no-undo.
    define variable vhNocal    as handle  no-undo.
    define buffer echlo for echlo.

    create query vhttquery.
    vhttBuffer = ghttEchlo:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttEchlo:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNoper, output vhNoact, output vhNocal).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first echlo exclusive-lock
                where rowid(echlo) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer echlo:handle, 'tpcon/nocon/noper/noact/nocal: ', substitute('&1/&2/&3/&4/&5', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhNoper:buffer-value(), vhNoact:buffer-value(), vhNocal:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer echlo:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createEchlo private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer echlo for echlo.

    create query vhttquery.
    vhttBuffer = ghttEchlo:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttEchlo:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create echlo.
            if not outils:copyValidField(buffer echlo:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteEchlo private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNoper    as handle  no-undo.
    define variable vhNoact    as handle  no-undo.
    define variable vhNocal    as handle  no-undo.
    define buffer echlo for echlo.

    create query vhttquery.
    vhttBuffer = ghttEchlo:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttEchlo:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNoper, output vhNoact, output vhNocal).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first echlo exclusive-lock
                where rowid(Echlo) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer echlo:handle, 'tpcon/nocon/noper/noact/nocal: ', substitute('&1/&2/&3/&4/&5', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhNoper:buffer-value(), vhNoact:buffer-value(), vhNocal:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete echlo no-error.
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

procedure getDerniereEchenceLoyer:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par calechid.p
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeBail         as character no-undo.
    define input  parameter piNumeroBail       as int64     no-undo.
    define output parameter piNumeroCalendrier as integer   no-undo.
    define output parameter piNumeroPeriode    as integer   no-undo.

    define buffer echlo for echlo.

dernierEchlo:
    for each echlo no-lock
        where echlo.tpcon = pcTypeBail
          and echlo.nocon = piNumeroBail
          and echlo.noact = 1
        by echlo.noper descending by echlo.nocal descending:
        assign
            piNumeroCalendrier = echlo.nocal
            piNumeroPeriode    = echlo.noper
        .
        leave dernierEchlo.
    end.
end procedure.
