/*------------------------------------------------------------------------
File        : centfac_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table centfac
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/centfac.i}
{application/include/error.i}
define variable ghttcentfac as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phType as handle, output phNum-int as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/type/num-int, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'type' then phType = phBuffer:buffer-field(vi).
            when 'num-int' then phNum-int = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCentfac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCentfac.
    run updateCentfac.
    run createCentfac.
end procedure.

procedure setCentfac:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCentfac.
    ghttCentfac = phttCentfac.
    run crudCentfac.
    delete object phttCentfac.
end procedure.

procedure readCentfac:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table centfac Fichier ENTETE de Factures/Avoirs Clients
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter plType    as logical    no-undo.
    define input parameter piNum-int as integer    no-undo.
    define input parameter table-handle phttCentfac.
    define variable vhttBuffer as handle no-undo.
    define buffer centfac for centfac.

    vhttBuffer = phttCentfac:default-buffer-handle.
    for first centfac no-lock
        where centfac.soc-cd = piSoc-cd
          and centfac.etab-cd = piEtab-cd
          and centfac.type = plType
          and centfac.num-int = piNum-int:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer centfac:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCentfac no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCentfac:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table centfac Fichier ENTETE de Factures/Avoirs Clients
    Notes  : service externe. Critère plType = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter plType    as logical    no-undo.
    define input parameter table-handle phttCentfac.
    define variable vhttBuffer as handle  no-undo.
    define buffer centfac for centfac.

    vhttBuffer = phttCentfac:default-buffer-handle.
    if plType = ?
    then for each centfac no-lock
        where centfac.soc-cd = piSoc-cd
          and centfac.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer centfac:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each centfac no-lock
        where centfac.soc-cd = piSoc-cd
          and centfac.etab-cd = piEtab-cd
          and centfac.type = plType:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer centfac:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCentfac no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCentfac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhType    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define buffer centfac for centfac.

    create query vhttquery.
    vhttBuffer = ghttCentfac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCentfac:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhType, output vhNum-int).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first centfac exclusive-lock
                where rowid(centfac) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer centfac:handle, 'soc-cd/etab-cd/type/num-int: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhType:buffer-value(), vhNum-int:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer centfac:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCentfac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer centfac for centfac.

    create query vhttquery.
    vhttBuffer = ghttCentfac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCentfac:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create centfac.
            if not outils:copyValidField(buffer centfac:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCentfac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhType    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define buffer centfac for centfac.

    create query vhttquery.
    vhttBuffer = ghttCentfac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCentfac:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhType, output vhNum-int).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first centfac exclusive-lock
                where rowid(Centfac) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer centfac:handle, 'soc-cd/etab-cd/type/num-int: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhType:buffer-value(), vhNum-int:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete centfac no-error.
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

