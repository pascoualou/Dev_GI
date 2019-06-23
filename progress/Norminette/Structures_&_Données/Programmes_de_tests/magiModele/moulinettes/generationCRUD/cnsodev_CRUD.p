/*------------------------------------------------------------------------
File        : cnsodev_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cnsodev
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cnsodev.i}
{application/include/error.i}
define variable ghttcnsodev as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phSscoll-cle as handle, output phDev-cd as handle, output phDafin as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/sscoll-cle/dev-cd/dafin, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'sscoll-cle' then phSscoll-cle = phBuffer:buffer-field(vi).
            when 'dev-cd' then phDev-cd = phBuffer:buffer-field(vi).
            when 'dafin' then phDafin = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCnsodev private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCnsodev.
    run updateCnsodev.
    run createCnsodev.
end procedure.

procedure setCnsodev:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCnsodev.
    ghttCnsodev = phttCnsodev.
    run crudCnsodev.
    delete object phttCnsodev.
end procedure.

procedure readCnsodev:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cnsodev recap non soldes en devises
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcSscoll-cle as character  no-undo.
    define input parameter pcDev-cd     as character  no-undo.
    define input parameter pdaDafin      as date       no-undo.
    define input parameter table-handle phttCnsodev.
    define variable vhttBuffer as handle no-undo.
    define buffer cnsodev for cnsodev.

    vhttBuffer = phttCnsodev:default-buffer-handle.
    for first cnsodev no-lock
        where cnsodev.soc-cd = piSoc-cd
          and cnsodev.etab-cd = piEtab-cd
          and cnsodev.sscoll-cle = pcSscoll-cle
          and cnsodev.dev-cd = pcDev-cd
          and cnsodev.dafin = pdaDafin:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cnsodev:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCnsodev no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCnsodev:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cnsodev recap non soldes en devises
    Notes  : service externe. Critère pcDev-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcSscoll-cle as character  no-undo.
    define input parameter pcDev-cd     as character  no-undo.
    define input parameter table-handle phttCnsodev.
    define variable vhttBuffer as handle  no-undo.
    define buffer cnsodev for cnsodev.

    vhttBuffer = phttCnsodev:default-buffer-handle.
    if pcDev-cd = ?
    then for each cnsodev no-lock
        where cnsodev.soc-cd = piSoc-cd
          and cnsodev.etab-cd = piEtab-cd
          and cnsodev.sscoll-cle = pcSscoll-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cnsodev:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cnsodev no-lock
        where cnsodev.soc-cd = piSoc-cd
          and cnsodev.etab-cd = piEtab-cd
          and cnsodev.sscoll-cle = pcSscoll-cle
          and cnsodev.dev-cd = pcDev-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cnsodev:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCnsodev no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCnsodev private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhSscoll-cle    as handle  no-undo.
    define variable vhDev-cd    as handle  no-undo.
    define variable vhDafin    as handle  no-undo.
    define buffer cnsodev for cnsodev.

    create query vhttquery.
    vhttBuffer = ghttCnsodev:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCnsodev:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhSscoll-cle, output vhDev-cd, output vhDafin).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cnsodev exclusive-lock
                where rowid(cnsodev) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cnsodev:handle, 'soc-cd/etab-cd/sscoll-cle/dev-cd/dafin: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhSscoll-cle:buffer-value(), vhDev-cd:buffer-value(), vhDafin:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cnsodev:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCnsodev private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cnsodev for cnsodev.

    create query vhttquery.
    vhttBuffer = ghttCnsodev:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCnsodev:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cnsodev.
            if not outils:copyValidField(buffer cnsodev:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCnsodev private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhSscoll-cle    as handle  no-undo.
    define variable vhDev-cd    as handle  no-undo.
    define variable vhDafin    as handle  no-undo.
    define buffer cnsodev for cnsodev.

    create query vhttquery.
    vhttBuffer = ghttCnsodev:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCnsodev:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhSscoll-cle, output vhDev-cd, output vhDafin).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cnsodev exclusive-lock
                where rowid(Cnsodev) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cnsodev:handle, 'soc-cd/etab-cd/sscoll-cle/dev-cd/dafin: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhSscoll-cle:buffer-value(), vhDev-cd:buffer-value(), vhDafin:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cnsodev no-error.
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

