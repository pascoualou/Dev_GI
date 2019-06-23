/*------------------------------------------------------------------------
File        : acreg_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table acreg
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/acreg.i}
{application/include/error.i}
define variable ghttacreg as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phTplig as handle, output phDtech as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpcon/nocon/tplig/dtech, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
            when 'tplig' then phTplig = phBuffer:buffer-field(vi).
            when 'dtech' then phDtech = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAcreg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAcreg.
    run updateAcreg.
    run createAcreg.
end procedure.

procedure setAcreg:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAcreg.
    ghttAcreg = phttAcreg.
    run crudAcreg.
    delete object phttAcreg.
end procedure.

procedure readAcreg:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table acreg Accords de règlement
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as int64      no-undo.
    define input parameter pcTplig as character  no-undo.
    define input parameter pdaDtech as date       no-undo.
    define input parameter table-handle phttAcreg.
    define variable vhttBuffer as handle no-undo.
    define buffer acreg for acreg.

    vhttBuffer = phttAcreg:default-buffer-handle.
    for first acreg no-lock
        where acreg.tpcon = pcTpcon
          and acreg.nocon = piNocon
          and acreg.tplig = pcTplig
          and acreg.dtech = pdaDtech:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer acreg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAcreg no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAcreg:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table acreg Accords de règlement
    Notes  : service externe. Critère pcTplig = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as int64      no-undo.
    define input parameter pcTplig as character  no-undo.
    define input parameter table-handle phttAcreg.
    define variable vhttBuffer as handle  no-undo.
    define buffer acreg for acreg.

    vhttBuffer = phttAcreg:default-buffer-handle.
    if pcTplig = ?
    then for each acreg no-lock
        where acreg.tpcon = pcTpcon
          and acreg.nocon = piNocon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer acreg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each acreg no-lock
        where acreg.tpcon = pcTpcon
          and acreg.nocon = piNocon
          and acreg.tplig = pcTplig:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer acreg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAcreg no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAcreg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhTplig    as handle  no-undo.
    define variable vhDtech    as handle  no-undo.
    define buffer acreg for acreg.

    create query vhttquery.
    vhttBuffer = ghttAcreg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAcreg:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhTplig, output vhDtech).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first acreg exclusive-lock
                where rowid(acreg) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer acreg:handle, 'tpcon/nocon/tplig/dtech: ', substitute('&1/&2/&3/&4', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhTplig:buffer-value(), vhDtech:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer acreg:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAcreg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer acreg for acreg.

    create query vhttquery.
    vhttBuffer = ghttAcreg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAcreg:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create acreg.
            if not outils:copyValidField(buffer acreg:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAcreg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhTplig    as handle  no-undo.
    define variable vhDtech    as handle  no-undo.
    define buffer acreg for acreg.

    create query vhttquery.
    vhttBuffer = ghttAcreg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAcreg:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhTplig, output vhDtech).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first acreg exclusive-lock
                where rowid(Acreg) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer acreg:handle, 'tpcon/nocon/tplig/dtech: ', substitute('&1/&2/&3/&4', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhTplig:buffer-value(), vhDtech:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete acreg no-error.
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

