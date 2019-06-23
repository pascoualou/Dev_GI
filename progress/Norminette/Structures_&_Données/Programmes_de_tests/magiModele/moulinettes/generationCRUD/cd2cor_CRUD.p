/*------------------------------------------------------------------------
File        : cd2cor_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cd2cor
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cd2cor.i}
{application/include/error.i}
define variable ghttcd2cor as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phZone-cd as handle, output phD2ven-cle as handle, output phCpt-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/zone-cd/d2ven-cle/cpt-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'zone-cd' then phZone-cd = phBuffer:buffer-field(vi).
            when 'd2ven-cle' then phD2ven-cle = phBuffer:buffer-field(vi).
            when 'cpt-cd' then phCpt-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCd2cor private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCd2cor.
    run updateCd2cor.
    run createCd2cor.
end procedure.

procedure setCd2cor:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCd2cor.
    ghttCd2cor = phttCd2cor.
    run crudCd2cor.
    delete object phttCd2cor.
end procedure.

procedure readCd2cor:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cd2cor Correspondance DAS2
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piZone-cd   as integer    no-undo.
    define input parameter pcD2ven-cle as character  no-undo.
    define input parameter pcCpt-cd    as character  no-undo.
    define input parameter table-handle phttCd2cor.
    define variable vhttBuffer as handle no-undo.
    define buffer cd2cor for cd2cor.

    vhttBuffer = phttCd2cor:default-buffer-handle.
    for first cd2cor no-lock
        where cd2cor.soc-cd = piSoc-cd
          and cd2cor.zone-cd = piZone-cd
          and cd2cor.d2ven-cle = pcD2ven-cle
          and cd2cor.cpt-cd = pcCpt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cd2cor:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCd2cor no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCd2cor:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cd2cor Correspondance DAS2
    Notes  : service externe. Critère pcD2ven-cle = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piZone-cd   as integer    no-undo.
    define input parameter pcD2ven-cle as character  no-undo.
    define input parameter table-handle phttCd2cor.
    define variable vhttBuffer as handle  no-undo.
    define buffer cd2cor for cd2cor.

    vhttBuffer = phttCd2cor:default-buffer-handle.
    if pcD2ven-cle = ?
    then for each cd2cor no-lock
        where cd2cor.soc-cd = piSoc-cd
          and cd2cor.zone-cd = piZone-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cd2cor:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cd2cor no-lock
        where cd2cor.soc-cd = piSoc-cd
          and cd2cor.zone-cd = piZone-cd
          and cd2cor.d2ven-cle = pcD2ven-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cd2cor:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCd2cor no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCd2cor private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhZone-cd    as handle  no-undo.
    define variable vhD2ven-cle    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define buffer cd2cor for cd2cor.

    create query vhttquery.
    vhttBuffer = ghttCd2cor:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCd2cor:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhZone-cd, output vhD2ven-cle, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cd2cor exclusive-lock
                where rowid(cd2cor) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cd2cor:handle, 'soc-cd/zone-cd/d2ven-cle/cpt-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhZone-cd:buffer-value(), vhD2ven-cle:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cd2cor:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCd2cor private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cd2cor for cd2cor.

    create query vhttquery.
    vhttBuffer = ghttCd2cor:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCd2cor:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cd2cor.
            if not outils:copyValidField(buffer cd2cor:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCd2cor private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhZone-cd    as handle  no-undo.
    define variable vhD2ven-cle    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define buffer cd2cor for cd2cor.

    create query vhttquery.
    vhttBuffer = ghttCd2cor:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCd2cor:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhZone-cd, output vhD2ven-cle, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cd2cor exclusive-lock
                where rowid(Cd2cor) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cd2cor:handle, 'soc-cd/zone-cd/d2ven-cle/cpt-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhZone-cd:buffer-value(), vhD2ven-cle:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cd2cor no-error.
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

