/*------------------------------------------------------------------------
File        : arib_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table arib
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
derniere revue: 2018/09/05 - phm: OK
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttarib as handle no-undo.      // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phTprole as handle, output phCpt-cd as handle, output phOrdre-num as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/tprole/cpt-cd/ordre-num, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd'    then phSoc-cd    = phBuffer:buffer-field(vi).
            when 'etab-cd'   then phEtab-cd   = phBuffer:buffer-field(vi).
            when 'tprole'    then phTprole    = phBuffer:buffer-field(vi).
            when 'cpt-cd'    then phCpt-cd    = phBuffer:buffer-field(vi).
            when 'ordre-num' then phOrdre-num = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

function getNextArib returns integer (piNumeroSociete as integer, piNumeroMandat as integer, piTypeRole as integer, pcNumeroCompte as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par genoffqt.p
    ------------------------------------------------------------------------------*/
    define buffer arib for arib.

        for last arib no-lock
            where arib.Soc-Cd = piNumeroSociete
            and   arib.Etab-Cd = piNumeroMandat
            and   arib.TpRole = piTypeRole
            and   arib.Cpt-Cd = pcNumeroCompte:
            return arib.Ordre-num + 1.
        end.
        return 1.

end function.

procedure crudArib private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteArib.
    run updateArib.
    run createArib.
end procedure.

procedure setArib:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttArib.
    ghttArib = phttArib.
    run crudArib.
    delete object phttArib.
end procedure.

procedure readArib:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table arib 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer   no-undo.
    define input parameter piEtab-cd   as integer   no-undo.
    define input parameter piTprole    as integer   no-undo.
    define input parameter pcCpt-cd    as character no-undo.
    define input parameter piOrdre-num as integer   no-undo.
    define input parameter table-handle phttArib.

    define variable vhttBuffer as handle no-undo.
    define buffer arib for arib.

    vhttBuffer = phttArib:default-buffer-handle.
    for first arib no-lock
        where arib.soc-cd = piSoc-cd
          and arib.etab-cd = piEtab-cd
          and arib.tprole = piTprole
          and arib.cpt-cd = pcCpt-cd
          and arib.ordre-num = piOrdre-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer arib:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttArib no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getArib:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table arib 
    Notes  : service externe. Critère pcCpt-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer   no-undo.
    define input parameter piEtab-cd as integer   no-undo.
    define input parameter piTprole  as integer   no-undo.
    define input parameter pcCpt-cd  as character no-undo.
    define input parameter table-handle phttArib.
    define variable vhttBuffer as handle  no-undo.
    define buffer arib for arib.

    vhttBuffer = phttArib:default-buffer-handle.
    if pcCpt-cd = ?
    then for each arib no-lock
        where arib.soc-cd = piSoc-cd
          and arib.etab-cd = piEtab-cd
          and arib.tprole = piTprole:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer arib:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each arib no-lock
        where arib.soc-cd = piSoc-cd
          and arib.etab-cd = piEtab-cd
          and arib.tprole = piTprole
          and arib.cpt-cd = pcCpt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer arib:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttArib no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateArib private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery   as handle  no-undo.
    define variable vhttBuffer  as handle  no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd   as handle  no-undo.
    define variable vhTprole    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define variable vhOrdre-num as handle  no-undo.
    define buffer arib for arib.

    create query vhttquery.
    vhttBuffer = ghttArib:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttArib:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhTprole, output vhCpt-cd, output vhOrdre-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first arib exclusive-lock
                where rowid(arib) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer arib:handle, 'soc-cd/etab-cd/tprole/cpt-cd/ordre-num: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhTprole:buffer-value(), vhCpt-cd:buffer-value(), vhOrdre-num:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer arib:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createArib private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery     as handle  no-undo.
    define variable vhttBuffer    as handle  no-undo.
    define variable vhSoc-cd      as handle  no-undo.
    define variable vhEtab-cd     as handle  no-undo.
    define variable vhTprole      as handle  no-undo.
    define variable vhCpt-cd      as handle  no-undo.
    define variable vhOrdre-num   as handle  no-undo.
    define variable viNumeroOrdre as integer no-undo.
    define buffer arib for arib.

    create query vhttquery.
    vhttBuffer = ghttArib:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttArib:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhTprole, output vhCpt-cd, output vhOrdre-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            viNumeroOrdre = vhOrdre-num:buffer-value().
            if viNumeroOrdre = 0 then viNumeroOrdre = getNextArib(vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhTprole:buffer-value(), vhCpt-cd:buffer-value()).
            vhOrdre-num:buffer-value() = viNumeroOrdre.
            create arib.
            if not outils:copyValidField(buffer arib:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteArib private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery   as handle  no-undo.
    define variable vhttBuffer  as handle  no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd   as handle  no-undo.
    define variable vhTprole    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define variable vhOrdre-num as handle  no-undo.
    define buffer arib for arib.

    create query vhttquery.
    vhttBuffer = ghttArib:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttArib:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhTprole, output vhCpt-cd, output vhOrdre-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first arib exclusive-lock
                where rowid(Arib) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer arib:handle, 'soc-cd/etab-cd/tprole/cpt-cd/ordre-num: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhTprole:buffer-value(), vhCpt-cd:buffer-value(), vhOrdre-num:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete arib no-error.
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
