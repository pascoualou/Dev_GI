/*------------------------------------------------------------------------
File        : prmut_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table prmut
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/prmut.i}
{application/include/error.i}
define variable ghttprmut as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phNomut as handle, output phNoimm as handle, output phNolot as handle, output phCdcle as handle, output phCdrub as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpcon/nocon/nomut/noimm/nolot/cdcle/cdrub, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
            when 'nomut' then phNomut = phBuffer:buffer-field(vi).
            when 'noimm' then phNoimm = phBuffer:buffer-field(vi).
            when 'nolot' then phNolot = phBuffer:buffer-field(vi).
            when 'cdcle' then phCdcle = phBuffer:buffer-field(vi).
            when 'cdrub' then phCdrub = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudPrmut private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deletePrmut.
    run updatePrmut.
    run createPrmut.
end procedure.

procedure setPrmut:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPrmut.
    ghttPrmut = phttPrmut.
    run crudPrmut.
    delete object phttPrmut.
end procedure.

procedure readPrmut:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table prmut Prorata des mutations
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as integer    no-undo.
    define input parameter piNomut as integer    no-undo.
    define input parameter piNoimm as integer    no-undo.
    define input parameter piNolot as integer    no-undo.
    define input parameter pcCdcle as character  no-undo.
    define input parameter pcCdrub as character  no-undo.
    define input parameter table-handle phttPrmut.
    define variable vhttBuffer as handle no-undo.
    define buffer prmut for prmut.

    vhttBuffer = phttPrmut:default-buffer-handle.
    for first prmut no-lock
        where prmut.tpcon = pcTpcon
          and prmut.nocon = piNocon
          and prmut.nomut = piNomut
          and prmut.noimm = piNoimm
          and prmut.nolot = piNolot
          and prmut.cdcle = pcCdcle
          and prmut.cdrub = pcCdrub:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer prmut:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPrmut no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getPrmut:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table prmut Prorata des mutations
    Notes  : service externe. Critère pcCdcle = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as integer    no-undo.
    define input parameter piNomut as integer    no-undo.
    define input parameter piNoimm as integer    no-undo.
    define input parameter piNolot as integer    no-undo.
    define input parameter pcCdcle as character  no-undo.
    define input parameter table-handle phttPrmut.
    define variable vhttBuffer as handle  no-undo.
    define buffer prmut for prmut.

    vhttBuffer = phttPrmut:default-buffer-handle.
    if pcCdcle = ?
    then for each prmut no-lock
        where prmut.tpcon = pcTpcon
          and prmut.nocon = piNocon
          and prmut.nomut = piNomut
          and prmut.noimm = piNoimm
          and prmut.nolot = piNolot:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer prmut:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each prmut no-lock
        where prmut.tpcon = pcTpcon
          and prmut.nocon = piNocon
          and prmut.nomut = piNomut
          and prmut.noimm = piNoimm
          and prmut.nolot = piNolot
          and prmut.cdcle = pcCdcle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer prmut:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPrmut no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatePrmut private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNomut    as handle  no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define variable vhCdcle    as handle  no-undo.
    define variable vhCdrub    as handle  no-undo.
    define buffer prmut for prmut.

    create query vhttquery.
    vhttBuffer = ghttPrmut:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttPrmut:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNomut, output vhNoimm, output vhNolot, output vhCdcle, output vhCdrub).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first prmut exclusive-lock
                where rowid(prmut) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer prmut:handle, 'tpcon/nocon/nomut/noimm/nolot/cdcle/cdrub: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhNomut:buffer-value(), vhNoimm:buffer-value(), vhNolot:buffer-value(), vhCdcle:buffer-value(), vhCdrub:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer prmut:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createPrmut private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer prmut for prmut.

    create query vhttquery.
    vhttBuffer = ghttPrmut:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttPrmut:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create prmut.
            if not outils:copyValidField(buffer prmut:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deletePrmut private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNomut    as handle  no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define variable vhCdcle    as handle  no-undo.
    define variable vhCdrub    as handle  no-undo.
    define buffer prmut for prmut.

    create query vhttquery.
    vhttBuffer = ghttPrmut:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttPrmut:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNomut, output vhNoimm, output vhNolot, output vhCdcle, output vhCdrub).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first prmut exclusive-lock
                where rowid(Prmut) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer prmut:handle, 'tpcon/nocon/nomut/noimm/nolot/cdcle/cdrub: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhNomut:buffer-value(), vhNoimm:buffer-value(), vhNolot:buffer-value(), vhCdcle:buffer-value(), vhCdrub:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete prmut no-error.
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

