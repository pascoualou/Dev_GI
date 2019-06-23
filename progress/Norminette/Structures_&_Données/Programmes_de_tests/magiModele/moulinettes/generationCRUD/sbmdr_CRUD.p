/*------------------------------------------------------------------------
File        : sbmdr_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table sbmdr
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/sbmdr.i}
{application/include/error.i}
define variable ghttsbmdr as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNoref as handle, output phNomds as handle, output phTptrt as handle, output phTpstr as handle, output phNotrt as handle, output phNostr as handle, output phTptir as handle, output phNocop as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noref/nomds/tptrt/tpstr/notrt/nostr/tptir/nocop, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noref' then phNoref = phBuffer:buffer-field(vi).
            when 'nomds' then phNomds = phBuffer:buffer-field(vi).
            when 'tptrt' then phTptrt = phBuffer:buffer-field(vi).
            when 'tpstr' then phTpstr = phBuffer:buffer-field(vi).
            when 'notrt' then phNotrt = phBuffer:buffer-field(vi).
            when 'nostr' then phNostr = phBuffer:buffer-field(vi).
            when 'tptir' then phTptir = phBuffer:buffer-field(vi).
            when 'nocop' then phNocop = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudSbmdr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteSbmdr.
    run updateSbmdr.
    run createSbmdr.
end procedure.

procedure setSbmdr:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSbmdr.
    ghttSbmdr = phttSbmdr.
    run crudSbmdr.
    delete object phttSbmdr.
end procedure.

procedure readSbmdr:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table sbmdr Substitution du mode de règlement lors des demandes de tirage.
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcNoref as character  no-undo.
    define input parameter piNomds as integer    no-undo.
    define input parameter pcTptrt as character  no-undo.
    define input parameter pcTpstr as character  no-undo.
    define input parameter piNotrt as integer    no-undo.
    define input parameter piNostr as integer    no-undo.
    define input parameter pcTptir as character  no-undo.
    define input parameter piNocop as integer    no-undo.
    define input parameter table-handle phttSbmdr.
    define variable vhttBuffer as handle no-undo.
    define buffer sbmdr for sbmdr.

    vhttBuffer = phttSbmdr:default-buffer-handle.
    for first sbmdr no-lock
        where sbmdr.noref = pcNoref
          and sbmdr.nomds = piNomds
          and sbmdr.tptrt = pcTptrt
          and sbmdr.tpstr = pcTpstr
          and sbmdr.notrt = piNotrt
          and sbmdr.nostr = piNostr
          and sbmdr.tptir = pcTptir
          and sbmdr.nocop = piNocop:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer sbmdr:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSbmdr no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getSbmdr:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table sbmdr Substitution du mode de règlement lors des demandes de tirage.
    Notes  : service externe. Critère pcTptir = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcNoref as character  no-undo.
    define input parameter piNomds as integer    no-undo.
    define input parameter pcTptrt as character  no-undo.
    define input parameter pcTpstr as character  no-undo.
    define input parameter piNotrt as integer    no-undo.
    define input parameter piNostr as integer    no-undo.
    define input parameter pcTptir as character  no-undo.
    define input parameter table-handle phttSbmdr.
    define variable vhttBuffer as handle  no-undo.
    define buffer sbmdr for sbmdr.

    vhttBuffer = phttSbmdr:default-buffer-handle.
    if pcTptir = ?
    then for each sbmdr no-lock
        where sbmdr.noref = pcNoref
          and sbmdr.nomds = piNomds
          and sbmdr.tptrt = pcTptrt
          and sbmdr.tpstr = pcTpstr
          and sbmdr.notrt = piNotrt
          and sbmdr.nostr = piNostr:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer sbmdr:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each sbmdr no-lock
        where sbmdr.noref = pcNoref
          and sbmdr.nomds = piNomds
          and sbmdr.tptrt = pcTptrt
          and sbmdr.tpstr = pcTpstr
          and sbmdr.notrt = piNotrt
          and sbmdr.nostr = piNostr
          and sbmdr.tptir = pcTptir:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer sbmdr:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSbmdr no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateSbmdr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoref    as handle  no-undo.
    define variable vhNomds    as handle  no-undo.
    define variable vhTptrt    as handle  no-undo.
    define variable vhTpstr    as handle  no-undo.
    define variable vhNotrt    as handle  no-undo.
    define variable vhNostr    as handle  no-undo.
    define variable vhTptir    as handle  no-undo.
    define variable vhNocop    as handle  no-undo.
    define buffer sbmdr for sbmdr.

    create query vhttquery.
    vhttBuffer = ghttSbmdr:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttSbmdr:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoref, output vhNomds, output vhTptrt, output vhTpstr, output vhNotrt, output vhNostr, output vhTptir, output vhNocop).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first sbmdr exclusive-lock
                where rowid(sbmdr) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer sbmdr:handle, 'noref/nomds/tptrt/tpstr/notrt/nostr/tptir/nocop: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8', vhNoref:buffer-value(), vhNomds:buffer-value(), vhTptrt:buffer-value(), vhTpstr:buffer-value(), vhNotrt:buffer-value(), vhNostr:buffer-value(), vhTptir:buffer-value(), vhNocop:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer sbmdr:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createSbmdr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer sbmdr for sbmdr.

    create query vhttquery.
    vhttBuffer = ghttSbmdr:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttSbmdr:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create sbmdr.
            if not outils:copyValidField(buffer sbmdr:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteSbmdr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoref    as handle  no-undo.
    define variable vhNomds    as handle  no-undo.
    define variable vhTptrt    as handle  no-undo.
    define variable vhTpstr    as handle  no-undo.
    define variable vhNotrt    as handle  no-undo.
    define variable vhNostr    as handle  no-undo.
    define variable vhTptir    as handle  no-undo.
    define variable vhNocop    as handle  no-undo.
    define buffer sbmdr for sbmdr.

    create query vhttquery.
    vhttBuffer = ghttSbmdr:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttSbmdr:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoref, output vhNomds, output vhTptrt, output vhTpstr, output vhNotrt, output vhNostr, output vhTptir, output vhNocop).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first sbmdr exclusive-lock
                where rowid(Sbmdr) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer sbmdr:handle, 'noref/nomds/tptrt/tpstr/notrt/nostr/tptir/nocop: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8', vhNoref:buffer-value(), vhNomds:buffer-value(), vhTptrt:buffer-value(), vhTpstr:buffer-value(), vhNotrt:buffer-value(), vhNostr:buffer-value(), vhTptir:buffer-value(), vhNocop:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete sbmdr no-error.
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

