/*------------------------------------------------------------------------
File        : rubsel_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table rubsel
Author(s)   : generation automatique le 08/08/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttrubsel as handle no-undo.      // le handle de la temp table à mettre à jour

{crud/include/rubsel.i}

function f-isNull returns logical private(pcChaine as character):
    /*------------------------------------------------------------------------------
    Purpose:     
    Notes  :
    ------------------------------------------------------------------------------*/
    return pcChaine = ? or pcChaine = "".
end function.

function getIndexField returns logical private(phBuffer as handle, output phTpmdt as handle, output phNomdt as handle, output phTpct2 as handle, output phNoct2 as handle, output phTptac as handle, output phIxd01 as handle, output phTprub as handle, output phCdrub as handle, output phCdlib as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpmdt/nomdt/Tpct2/noct2/tptac/ixd01/tprub/cdrub/cdlib, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpmdt' then phTpmdt = phBuffer:buffer-field(vi).
            when 'nomdt' then phNomdt = phBuffer:buffer-field(vi).
            when 'Tpct2' then phTpct2 = phBuffer:buffer-field(vi).
            when 'noct2' then phNoct2 = phBuffer:buffer-field(vi).
            when 'tptac' then phTptac = phBuffer:buffer-field(vi).
            when 'ixd01' then phIxd01 = phBuffer:buffer-field(vi).
            when 'tprub' then phTprub = phBuffer:buffer-field(vi).
            when 'cdrub' then phCdrub = phBuffer:buffer-field(vi).
            when 'cdlib' then phCdlib = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudRubsel private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteRubsel.
    run updateRubsel.
    run createRubsel.
end procedure.

procedure setRubsel:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttRubsel.
    ghttRubsel = phttRubsel.
    run crudRubsel.
    delete object phttRubsel.
end procedure.

procedure readRubsel:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table rubsel SÃ©lection des rubriques pour les calculs honoraires, rubriques calculÃ©es ou autres (0511/0025)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpmdt as character  no-undo.
    define input parameter piNomdt as integer    no-undo.
    define input parameter pcTpct2 as character  no-undo.
    define input parameter piNoct2 as int64      no-undo.
    define input parameter pcTptac as character  no-undo.
    define input parameter pcIxd01 as character  no-undo.
    define input parameter pcTprub as character  no-undo.
    define input parameter pcCdrub as character  no-undo.
    define input parameter pcCdlib as character  no-undo.
    define input parameter table-handle phttRubsel.
    define variable vhttBuffer as handle no-undo.
    define buffer rubsel for rubsel.

    vhttBuffer = phttRubsel:default-buffer-handle.
    for first rubsel no-lock
        where rubsel.tpmdt = pcTpmdt
          and rubsel.nomdt = piNomdt
          and rubsel.Tpct2 = pcTpct2
          and rubsel.noct2 = piNoct2
          and rubsel.tptac = pcTptac
          and rubsel.ixd01 = pcIxd01
          and rubsel.tprub = pcTprub
          and rubsel.cdrub = pcCdrub
          and rubsel.cdlib = pcCdlib:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer rubsel:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRubsel no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getRubsel:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table rubsel SÃ©lection des rubriques pour les calculs honoraires, rubriques calculÃ©es ou autres (0511/0025)
    Notes  : service externe. Critère pcCdrub = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpmdt as character  no-undo.
    define input parameter piNomdt as integer    no-undo.
    define input parameter pcTpct2 as character  no-undo.
    define input parameter piNoct2 as int64      no-undo.
    define input parameter pcTptac as character  no-undo.
    define input parameter pcIxd01 as character  no-undo.
    define input parameter pcTprub as character  no-undo.
    define input parameter pcCdrub as character  no-undo.
    define input parameter table-handle phttRubsel.
    define variable vhttBuffer as handle  no-undo.
    define buffer rubsel for rubsel.

    vhttBuffer = phttRubsel:default-buffer-handle.
    if pcCdrub = ?
    then for each rubsel no-lock
        where rubsel.tpmdt = pcTpmdt
          and rubsel.nomdt = piNomdt
          and rubsel.Tpct2 = pcTpct2
          and rubsel.noct2 = piNoct2
          and rubsel.tptac = pcTptac
          and rubsel.ixd01 = pcIxd01
          and rubsel.tprub = pcTprub:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer rubsel:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each rubsel no-lock
        where rubsel.tpmdt = pcTpmdt
          and rubsel.nomdt = piNomdt
          and rubsel.Tpct2 = pcTpct2
          and rubsel.noct2 = piNoct2
          and rubsel.tptac = pcTptac
          and rubsel.ixd01 = pcIxd01
          and rubsel.tprub = pcTprub
          and rubsel.cdrub = pcCdrub:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer rubsel:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRubsel no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateRubsel private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery   as handle  no-undo.
    define variable vhttBuffer  as handle  no-undo.
    define variable vhTpmdt as handle  no-undo.
    define variable vhNomdt as handle  no-undo.
    define variable vhTpct2 as handle  no-undo.
    define variable vhNoct2 as handle  no-undo.
    define variable vhTptac as handle  no-undo.
    define variable vhIxd01 as handle  no-undo.
    define variable vhTprub as handle  no-undo.
    define variable vhCdrub as handle  no-undo.
    define variable vhCdlib as handle  no-undo.
    define buffer rubsel for rubsel.

    create query vhttquery.
    vhttBuffer = ghttRubsel:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttRubsel:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpmdt, output vhNomdt, output vhTpct2, output vhNoct2, output vhTptac, output vhIxd01, output vhTprub, output vhCdrub, output vhCdlib).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first rubsel exclusive-lock
                where rowid(rubsel) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer rubsel:handle, 'tpmdt/nomdt/Tpct2/noct2/tptac/ixd01/tprub/cdrub/cdlib: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8/&9', vhTpmdt:buffer-value(), vhNomdt:buffer-value(), vhTpct2:buffer-value(), vhNoct2:buffer-value(), vhTptac:buffer-value(), vhIxd01:buffer-value(), vhTprub:buffer-value(), vhCdrub:buffer-value(), vhCdlib:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer rubsel:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createRubsel private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer rubsel for rubsel.

    create query vhttquery.
    vhttBuffer = ghttRubsel:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttRubsel:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create rubsel.
            if not outils:copyValidField(buffer rubsel:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteRubsel private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpmdt as handle  no-undo.
    define variable vhNomdt as handle  no-undo.
    define variable vhTpct2 as handle  no-undo.
    define variable vhNoct2 as handle  no-undo.
    define variable vhTptac as handle  no-undo.
    define variable vhIxd01 as handle  no-undo.
    define variable vhTprub as handle  no-undo.
    define variable vhCdrub as handle  no-undo.
    define variable vhCdlib as handle  no-undo.
    define buffer rubsel for rubsel.

    create query vhttquery.
    vhttBuffer = ghttRubsel:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttRubsel:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpmdt, output vhNomdt, output vhTpct2, output vhNoct2, output vhTptac, output vhIxd01, output vhTprub, output vhCdrub, output vhCdlib).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first rubsel exclusive-lock
                where rowid(Rubsel) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer rubsel:handle, 'tpmdt/nomdt/Tpct2/noct2/tptac/ixd01/tprub/cdrub/cdlib: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8/&9', vhTpmdt:buffer-value(), vhNomdt:buffer-value(), vhTpct2:buffer-value(), vhNoct2:buffer-value(), vhTptac:buffer-value(), vhIxd01:buffer-value(), vhTprub:buffer-value(), vhCdrub:buffer-value(), vhCdlib:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete rubsel no-error.
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

procedure newRubSel:
    /*------------------------------------------------------------------------------
    Purpose: Création nouvel enregistrement de rubsel.     
    Notes  : service appelé par paramBaseRubrique.p
    ------------------------------------------------------------------------------*/
    define parameter buffer ttRubsel for ttRubsel.
    define buffer rubsel for rubsel.
    
    create rubsel.
    outils:copyValidField(buffer rubsel:handle, buffer ttRubsel:handle, 'C', mtoken:cUser).
    if not mError:erreur() then mError:createInfoRowid(rowid(rubsel)). // enregistrement créé, permet de renvoyer le rowid en réponse.
    error-status:error = false no-error.  // reset error-status
    return.                               // reset return-value
end procedure.    

procedure majRubSel:
    /*------------------------------------------------------------------------------
    Purpose: Mise à jour d'enregistrement de rubsel.     
    Notes  : service appelé par paramBaseRubrique.p
    ------------------------------------------------------------------------------*/
    define parameter buffer rubsel   for rubsel.
    define parameter buffer ttRubsel for ttRubsel.  

    if not outils:isUpdated(buffer rubsel:handle, substitute(outilTraduction:getLibelle(1000320),""), ttRubsel.ixd01, ttRubsel.dtTimestamp) /* 1000320 Base de calcul &1 */
    then outils:copyValidField(buffer rubsel:handle, buffer ttRubsel:handle, 'U', mtoken:cUser).
    error-status:error = false no-error.  // reset error-status
    return.                               // reset return-value
end procedure.    

procedure delRubsel:
    /*------------------------------------------------------------------------------
    Purpose: Suppression d'un enregistrement de rubsel.     
    Notes  : service appelé par paramBaseRubrique.p
    ------------------------------------------------------------------------------*/
    define parameter buffer ttRubsel for ttRubsel.
    define buffer rubsel for rubsel.

blocTrans:
    do transaction:
        if f-isNull(ttRubsel.tprub) and f-isNull(ttRubsel.cdrub) and f-isNull(ttRubsel.cdlib)
        then for each rubsel exclusive-lock
            where rubsel.tpmdt = ttRubsel.tpmdt
              and rubsel.nomdt = ttRubsel.nomdt
              and rubsel.tpct2 = ttRubsel.tpct2
              and rubsel.noct2 = ttRubsel.noct2
              and rubsel.tptac = ttRubsel.tptac         
              and rubsel.ixd01 = ttRubsel.ixd01:
            delete rubsel no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
        else if ttRubsel.tprub > "" and f-isNull(ttRubsel.cdrub) and f-isNull(ttRubsel.cdlib)
        then for each rubsel exclusive-lock
            where rubsel.tpmdt = ttRubsel.tpmdt
              and rubsel.nomdt = ttRubsel.nomdt
              and rubsel.tpct2 = ttRubsel.tpct2
              and rubsel.noct2 = ttRubsel.noct2
              and rubsel.tptac = ttRubsel.tptac         
              and rubsel.ixd01 = ttRubsel.ixd01
              and rubsel.tprub = ttRubsel.tprub:
            delete rubsel no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
        else for first rubsel exclusive-lock 
            where rubsel.tpmdt = ttRubsel.tpmdt
              and rubsel.nomdt = ttRubsel.nomdt
              and rubsel.tpct2 = ttRubsel.tpct2
              and rubsel.noct2 = ttRubsel.noct2
              and rubsel.tptac = ttRubsel.tptac         
              and rubsel.ixd01 = ttRubsel.ixd01
              and rubsel.tprub = ttRubsel.tprub
              and rubsel.cdrub = ttRubsel.cdrub
              and rubsel.cdlib = ttRubsel.cdlib:
            delete rubsel no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.
