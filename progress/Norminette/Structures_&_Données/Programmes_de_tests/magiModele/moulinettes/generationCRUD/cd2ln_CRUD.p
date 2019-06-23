/*------------------------------------------------------------------------
File        : cd2ln_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cd2ln
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cd2ln.i}
{application/include/error.i}
define variable ghttcd2ln as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phNum-int as handle, output phZone-cd as handle, output phD2ven-cle as handle, output phCpt-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/num-int/zone-cd/d2ven-cle/cpt-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'num-int' then phNum-int = phBuffer:buffer-field(vi).
            when 'zone-cd' then phZone-cd = phBuffer:buffer-field(vi).
            when 'd2ven-cle' then phD2ven-cle = phBuffer:buffer-field(vi).
            when 'cpt-cd' then phCpt-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCd2ln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCd2ln.
    run updateCd2ln.
    run createCd2ln.
end procedure.

procedure setCd2ln:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCd2ln.
    ghttCd2ln = phttCd2ln.
    run crudCd2ln.
    delete object phttCd2ln.
end procedure.

procedure readCd2ln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cd2ln DAS2 : Detail des montants par fournisseur
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter piNum-int   as integer    no-undo.
    define input parameter piZone-cd   as integer    no-undo.
    define input parameter pcD2ven-cle as character  no-undo.
    define input parameter pcCpt-cd    as character  no-undo.
    define input parameter table-handle phttCd2ln.
    define variable vhttBuffer as handle no-undo.
    define buffer cd2ln for cd2ln.

    vhttBuffer = phttCd2ln:default-buffer-handle.
    for first cd2ln no-lock
        where cd2ln.soc-cd = piSoc-cd
          and cd2ln.etab-cd = piEtab-cd
          and cd2ln.num-int = piNum-int
          and cd2ln.zone-cd = piZone-cd
          and cd2ln.d2ven-cle = pcD2ven-cle
          and cd2ln.cpt-cd = pcCpt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cd2ln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCd2ln no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCd2ln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cd2ln DAS2 : Detail des montants par fournisseur
    Notes  : service externe. Critère pcD2ven-cle = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter piNum-int   as integer    no-undo.
    define input parameter piZone-cd   as integer    no-undo.
    define input parameter pcD2ven-cle as character  no-undo.
    define input parameter table-handle phttCd2ln.
    define variable vhttBuffer as handle  no-undo.
    define buffer cd2ln for cd2ln.

    vhttBuffer = phttCd2ln:default-buffer-handle.
    if pcD2ven-cle = ?
    then for each cd2ln no-lock
        where cd2ln.soc-cd = piSoc-cd
          and cd2ln.etab-cd = piEtab-cd
          and cd2ln.num-int = piNum-int
          and cd2ln.zone-cd = piZone-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cd2ln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cd2ln no-lock
        where cd2ln.soc-cd = piSoc-cd
          and cd2ln.etab-cd = piEtab-cd
          and cd2ln.num-int = piNum-int
          and cd2ln.zone-cd = piZone-cd
          and cd2ln.d2ven-cle = pcD2ven-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cd2ln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCd2ln no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCd2ln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define variable vhZone-cd    as handle  no-undo.
    define variable vhD2ven-cle    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define buffer cd2ln for cd2ln.

    create query vhttquery.
    vhttBuffer = ghttCd2ln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCd2ln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNum-int, output vhZone-cd, output vhD2ven-cle, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cd2ln exclusive-lock
                where rowid(cd2ln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cd2ln:handle, 'soc-cd/etab-cd/num-int/zone-cd/d2ven-cle/cpt-cd: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNum-int:buffer-value(), vhZone-cd:buffer-value(), vhD2ven-cle:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cd2ln:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCd2ln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cd2ln for cd2ln.

    create query vhttquery.
    vhttBuffer = ghttCd2ln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCd2ln:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cd2ln.
            if not outils:copyValidField(buffer cd2ln:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCd2ln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define variable vhZone-cd    as handle  no-undo.
    define variable vhD2ven-cle    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define buffer cd2ln for cd2ln.

    create query vhttquery.
    vhttBuffer = ghttCd2ln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCd2ln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNum-int, output vhZone-cd, output vhD2ven-cle, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cd2ln exclusive-lock
                where rowid(Cd2ln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cd2ln:handle, 'soc-cd/etab-cd/num-int/zone-cd/d2ven-cle/cpt-cd: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNum-int:buffer-value(), vhZone-cd:buffer-value(), vhD2ven-cle:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cd2ln no-error.
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

