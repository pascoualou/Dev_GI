/*------------------------------------------------------------------------
File        : assrc_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table 
              association rubriques provision - cles de repartition
Author(s)   : PL 2003/12/16 - GGA 2017/12/20
Notes       : reprise adb/lib/l_assrc.p
derniere revue: 2018/04/27 - phm: OK
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttassrc as handle no-undo.      // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phNomdt as handle, output phCdrub as handle, output phCdlib as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nomdt/cdrub/cdlib, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nomdt' then phNomdt = phBuffer:buffer-field(vi).
            when 'cdrub' then phCdrub = phBuffer:buffer-field(vi).
            when 'cdlib' then phCdlib = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAssrc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : 
    ------------------------------------------------------------------------------*/
    run deleteAssrc.
    run updateAssrc.
    run createAssrc.
end procedure.

procedure setAssrc:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (appel depuis tachePNO.p)
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAssrc.
    ghttAssrc = phttAssrc.
    run crudAssrc.
    delete object phttAssrc.
end procedure.

procedure readAssrc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement association rubriques provision - cles de repartition
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as integer  no-undo.
    define input parameter piCodeRubrique as integer  no-undo.
    define input parameter piCodeLibelle  as integer  no-undo.
    define input parameter table-handle phttAssrc.

    define variable vhttBuffer as handle no-undo.
    define buffer assrc for assrc.

    vhttBuffer = phttAssrc:default-buffer-handle.
    for first assrc no-lock
        where assrc.nomdt = piNumeroMandat
          and assrc.cdrub = piCodeRubrique
          and assrc.cdlib = piCodeLibelle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer assrc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAssrc no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAssrc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements association rubriques provision - cles de repartition
    Notes  : service externe. Critère piNumeroOrdre = ? si pas à prendre en compte 
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as integer   no-undo.
    define input parameter piCodeRubrique as integer   no-undo.
    define input parameter table-handle phttAssrc.

    define variable vhttBuffer as handle  no-undo.
    define buffer assrc for assrc.

    vhttBuffer = phttAssrc:default-buffer-handle.
    if piCodeRubrique = ?
    then for each assrc no-lock
        where assrc.nomdt = piNumeroMandat:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer assrc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each assrc no-lock
        where assrc.nomdt = piNumeroMandat
          and assrc.cdrub = piCodeRubrique:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer assrc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAssrc no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAssrc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhCdrub    as handle  no-undo.
    define variable vhCdlib    as handle  no-undo.
    define buffer assrc for assrc.

    create query vhttquery.
    vhttBuffer = ghttAssrc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAssrc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomdt, output vhCdrub, output vhCdlib).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first assrc exclusive-lock
                where rowid(assrc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer assrc:handle, 'nomdt/cdrub/cdlib: ', substitute('&1/&2/&3', vhNomdt:buffer-value(), vhCdrub:buffer-value(), vhCdlib:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer assrc:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAssrc:
    /*------------------------------------------------------------------------------
    Purpose: creation des liens rubriques provision - cle de repartition
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer assrc for assrc.

    create query vhttquery.
    vhttBuffer = ghttAssrc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAssrc:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create assrc.
            if not outils:copyValidField(buffer assrc:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAssrc private:
    /*------------------------------------------------------------------------------
    Purpose: suppression des liens rubriques provision - cle de repartition
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define variable vhCdrub    as handle  no-undo.
    define variable vhCdlib    as handle  no-undo.
    define buffer assrc for assrc.

    create query vhttquery.
    vhttBuffer = ghttAssrc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAssrc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomdt, output vhCdrub, output vhCdlib).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first assrc exclusive-lock
                where rowid(Assrc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer assrc:handle, 'nomdt/cdrub/cdlib: ', substitute('&1/&2/&3', vhNomdt:buffer-value(), vhCdrub:buffer-value(), vhCdlib:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete assrc no-error.
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

procedure deleteAssrcSurMandat:
    /*------------------------------------------------------------------------------
    Purpose: suppression des liens rubriques provision - cle de repartition d'un mandat 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as integer no-undo.
    
    define buffer assrc for assrc.

blocTransaction:
    do transaction:
        for each assrc exclusive-lock
            where assrc.nomdt = piNumeroMandat: 
            delete assrc no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTransaction, leave blocTransaction.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status
    return.                               // reset return-value
end procedure.    
