/*------------------------------------------------------------------------
File        : SuiHonDet_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table SuiHonDet
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/SuiHonDet.i}
{application/include/error.i}
define variable ghttSuiHonDet as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phNomdt as handle, output phTphon as handle, output phCdhon as handle, output phNoper as handle, output phNolot as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nomdt/tphon/cdhon/noper/nolot, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nomdt' then phNomdt = phBuffer:buffer-field(vi).
            when 'tphon' then phTphon = phBuffer:buffer-field(vi).
            when 'cdhon' then phCdhon = phBuffer:buffer-field(vi).
            when 'noper' then phNoper = phBuffer:buffer-field(vi).
            when 'nolot' then phNolot = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudSuihondet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteSuihondet.
    run updateSuihondet.
    run createSuihondet.
end procedure.

procedure setSuihondet:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSuihondet.
    ghttSuihondet = phttSuihondet.
    run crudSuihondet.
    delete object phttSuihondet.
end procedure.

procedure readSuihondet:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table SuiHonDet Detail du suivi des honoraires SuiHono (0513/0067)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNomdt as integer    no-undo.
    define input parameter pcTphon as character  no-undo.
    define input parameter piCdhon as integer    no-undo.
    define input parameter piNoper as integer    no-undo.
    define input parameter piNolot as integer    no-undo.
    define input parameter table-handle phttSuihondet.
    define variable vhttBuffer as handle no-undo.
    define buffer SuiHonDet for SuiHonDet.

    vhttBuffer = phttSuihondet:default-buffer-handle.
    for first SuiHonDet no-lock
        where SuiHonDet.nomdt = piNomdt
          and SuiHonDet.tphon = pcTphon
          and SuiHonDet.cdhon = piCdhon
          and SuiHonDet.noper = piNoper
          and SuiHonDet.nolot = piNolot:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer SuiHonDet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSuihondet no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getSuihondet:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table SuiHonDet Detail du suivi des honoraires SuiHono (0513/0067)
    Notes  : service externe. Critère piNoper = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNomdt as integer    no-undo.
    define input parameter pcTphon as character  no-undo.
    define input parameter piCdhon as integer    no-undo.
    define input parameter piNoper as integer    no-undo.
    define input parameter table-handle phttSuihondet.
    define variable vhttBuffer as handle  no-undo.
    define buffer SuiHonDet for SuiHonDet.

    vhttBuffer = phttSuihondet:default-buffer-handle.
    if piNoper = ?
    then for each SuiHonDet no-lock
        where SuiHonDet.nomdt = piNomdt
          and SuiHonDet.tphon = pcTphon
          and SuiHonDet.cdhon = piCdhon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer SuiHonDet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each SuiHonDet no-lock
        where SuiHonDet.nomdt = piNomdt
          and SuiHonDet.tphon = pcTphon
          and SuiHonDet.cdhon = piCdhon
          and SuiHonDet.noper = piNoper:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer SuiHonDet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSuihondet no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateSuihondet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhTphon    as handle  no-undo.
    define variable vhCdhon    as handle  no-undo.
    define variable vhNoper    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define buffer SuiHonDet for SuiHonDet.

    create query vhttquery.
    vhttBuffer = ghttSuihondet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttSuihondet:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomdt, output vhTphon, output vhCdhon, output vhNoper, output vhNolot).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first SuiHonDet exclusive-lock
                where rowid(SuiHonDet) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer SuiHonDet:handle, 'nomdt/tphon/cdhon/noper/nolot: ', substitute('&1/&2/&3/&4/&5', vhNomdt:buffer-value(), vhTphon:buffer-value(), vhCdhon:buffer-value(), vhNoper:buffer-value(), vhNolot:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer SuiHonDet:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createSuihondet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer SuiHonDet for SuiHonDet.

    create query vhttquery.
    vhttBuffer = ghttSuihondet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttSuihondet:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create SuiHonDet.
            if not outils:copyValidField(buffer SuiHonDet:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteSuihondet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhTphon    as handle  no-undo.
    define variable vhCdhon    as handle  no-undo.
    define variable vhNoper    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define buffer SuiHonDet for SuiHonDet.

    create query vhttquery.
    vhttBuffer = ghttSuihondet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttSuihondet:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomdt, output vhTphon, output vhCdhon, output vhNoper, output vhNolot).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first SuiHonDet exclusive-lock
                where rowid(Suihondet) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer SuiHonDet:handle, 'nomdt/tphon/cdhon/noper/nolot: ', substitute('&1/&2/&3/&4/&5', vhNomdt:buffer-value(), vhTphon:buffer-value(), vhCdhon:buffer-value(), vhNoper:buffer-value(), vhNolot:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete SuiHonDet no-error.
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

