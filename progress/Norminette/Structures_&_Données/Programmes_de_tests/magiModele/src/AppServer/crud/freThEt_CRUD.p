/*------------------------------------------------------------------------
File        : freThEt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table freThEt
Author(s)   : generation automatique le 08/08/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttfreThEt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phNoexo as handle, output phCdcleapp as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpcon/nocon/noexo/cdcleapp, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
            when 'noexo' then phNoexo = phBuffer:buffer-field(vi).
            when 'cdcleapp' then phCdcleapp = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudFrethet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteFrethet.
    run updateFrethet.
    run createFrethet.
end procedure.

procedure setFrethet:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttFrethet.
    ghttFrethet = phttFrethet.
    run crudFrethet.
    delete object phttFrethet.
end procedure.

procedure readFrethet:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table freThEt RIE : tableau  des frÃ©quentations ThÃ©oriques (entete)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon    as character  no-undo.
    define input parameter piNocon    as int64      no-undo.
    define input parameter piNoexo    as integer    no-undo.
    define input parameter pcCdcleapp as character  no-undo.
    define input parameter table-handle phttFrethet.
    define variable vhttBuffer as handle no-undo.
    define buffer freThEt for freThEt.

    vhttBuffer = phttFrethet:default-buffer-handle.
    for first freThEt no-lock
        where freThEt.tpcon = pcTpcon
          and freThEt.nocon = piNocon
          and freThEt.noexo = piNoexo
          and freThEt.cdcleapp = pcCdcleapp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer freThEt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttFrethet no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getFrethet:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table freThEt RIE : tableau  des frÃ©quentations ThÃ©oriques (entete)
    Notes  : service externe. Critère piNoexo = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon    as character  no-undo.
    define input parameter piNocon    as int64      no-undo.
    define input parameter piNoexo    as integer    no-undo.
    define input parameter table-handle phttFrethet.
    define variable vhttBuffer as handle  no-undo.
    define buffer freThEt for freThEt.

    vhttBuffer = phttFrethet:default-buffer-handle.
    if piNoexo = ?
    then for each freThEt no-lock
        where freThEt.tpcon = pcTpcon
          and freThEt.nocon = piNocon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer freThEt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each freThEt no-lock
        where freThEt.tpcon = pcTpcon
          and freThEt.nocon = piNocon
          and freThEt.noexo = piNoexo:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer freThEt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttFrethet no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateFrethet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery   as handle  no-undo.
    define variable vhttBuffer  as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNoexo    as handle  no-undo.
    define variable vhCdcleapp as handle  no-undo.
    define buffer freThEt for freThEt.

    create query vhttquery.
    vhttBuffer = ghttFrethet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttFrethet:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNoexo, output vhCdcleapp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first freThEt exclusive-lock
                where rowid(freThEt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer freThEt:handle, 'tpcon/nocon/noexo/cdcleapp: ', substitute('&1/&2/&3/&4', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhNoexo:buffer-value(), vhCdcleapp:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer freThEt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createFrethet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer freThEt for freThEt.

    create query vhttquery.
    vhttBuffer = ghttFrethet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttFrethet:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create freThEt.
            if not outils:copyValidField(buffer freThEt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteFrethet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNoexo    as handle  no-undo.
    define variable vhCdcleapp as handle  no-undo.
    define buffer freThEt for freThEt.

    create query vhttquery.
    vhttBuffer = ghttFrethet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttFrethet:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNoexo, output vhCdcleapp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first freThEt exclusive-lock
                where rowid(Frethet) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer freThEt:handle, 'tpcon/nocon/noexo/cdcleapp: ', substitute('&1/&2/&3/&4', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhNoexo:buffer-value(), vhCdcleapp:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            //Suppression des détails rattachés à cet entête
            for each FreThDt exclusive-lock
                where FreThDt.tpcon = FreThEt.tpcon
                and   FreThDt.nocon = FreThEt.nocon
                and   FreThDt.noexo = FreThEt.noexo:
                delete FreThDt.
            end.
            delete freThEt no-error.
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

