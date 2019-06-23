/*------------------------------------------------------------------------
File        : afamqtord_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table afamqtord
Author(s)   : generation automatique le 01/24/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
derniere revue: 2018/04/27 - phm: OK
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttafamqtord as handle no-undo.      // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phCdfam as handle, output phCdsfa as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/cdfam/cdsfa, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd'  then phSoc-cd  = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'cdfam'   then phCdfam   = phBuffer:buffer-field(vi).
            when 'cdsfa'   then phCdsfa   = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAfamqtord private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAfamqtord.
    run updateAfamqtord.
    run createAfamqtord.
end procedure.

procedure setAfamqtord:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle vhttAfamqtord.
    ghttAfamqtord = vhttAfamqtord.
    run crudAfamqtord.
end procedure.

procedure readAfamqtord:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table afamqtord Ordonnancement des familles et des  sous familles
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer   no-undo.
    define input parameter piEtab-cd as integer   no-undo.
    define input parameter piCdfam   as integer   no-undo.
    define input parameter piCdsfa   as integer   no-undo.
    define output parameter table-handle phttAfamqtord.

    define variable vhttBuffer as handle no-undo.
    define buffer afamqtord for afamqtord.

    vhttBuffer = phttAfamqtord:default-buffer-handle.
    for first afamqtord no-lock
        where afamqtord.soc-cd  = piSoc-cd
          and afamqtord.etab-cd = piEtab-cd
          and afamqtord.cdfam   = piCdfam
          and afamqtord.cdsfa   = piCdsfa:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer afamqtord:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAfamqtord no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAfamqtord:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table afamqtord Ordonnancement des familles et des  sous familles
    Notes  : service externe. Critère piCdfam = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer   no-undo.
    define input parameter piEtab-cd as integer   no-undo.
    define input parameter piCdfam   as integer   no-undo.
    define output parameter table-handle phttAfamqtord.

    define variable vhttBuffer as handle  no-undo.
    define buffer afamqtord for afamqtord.

    vhttBuffer = phttAfamqtord:default-buffer-handle.
    if piCdfam = ?
    then for each afamqtord no-lock
        where afamqtord.soc-cd  = piSoc-cd
          and afamqtord.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer afamqtord:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each afamqtord no-lock
        where afamqtord.soc-cd  = piSoc-cd
          and afamqtord.etab-cd = piEtab-cd
          and afamqtord.cdfam   = piCdfam:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer afamqtord:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAfamqtord no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAfamqtord private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhSoc-cd   as handle  no-undo.
    define variable vhEtab-cd  as handle  no-undo.
    define variable vhCdfam    as handle  no-undo.
    define variable vhCdsfa    as handle  no-undo.
    define buffer afamqtord for afamqtord.

    create query vhttquery.
    vhttBuffer = ghttAfamqtord:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAfamqtord:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhCdfam, output vhCdsfa).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first afamqtord exclusive-lock
                where rowid(afamqtord) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer afamqtord:handle, 'soc-cd/etab-cd/cdfam/cdsfa: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhCdfam:buffer-value(), vhCdsfa:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer afamqtord:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAfamqtord private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer afamqtord for afamqtord.

    create query vhttquery.
    vhttBuffer = ghttAfamqtord:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAfamqtord:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create afamqtord.
            if not outils:copyValidField(buffer afamqtord:handle, vhttBuffer, "", mtoken:cUser) // crud = "" car pas de champs cdmsy...
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAfamqtord private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhSoc-cd   as handle  no-undo.
    define variable vhEtab-cd  as handle  no-undo.
    define variable vhCdfam    as handle  no-undo.
    define variable vhCdsfa    as handle  no-undo.
    define buffer afamqtord for afamqtord.

    create query vhttquery.
    vhttBuffer = ghttAfamqtord:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAfamqtord:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhCdfam, output vhCdsfa).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first afamqtord exclusive-lock
                where rowid(Afamqtord) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer afamqtord:handle, 'soc-cd/etab-cd/cdfam/cdsfa: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhCdfam:buffer-value(), vhCdsfa:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete afamqtord no-error.
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
