/*------------------------------------------------------------------------
File        : intnt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table intnt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/intnt.i}
{application/include/error.i}
define variable ghttintnt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phTpidt as handle, output phNoidt as handle, output phNbnum as handle, output phIdpre as handle, output phIdsui as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpcon/nocon/tpidt/noidt/nbnum/idpre/idsui, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
            when 'tpidt' then phTpidt = phBuffer:buffer-field(vi).
            when 'noidt' then phNoidt = phBuffer:buffer-field(vi).
            when 'nbnum' then phNbnum = phBuffer:buffer-field(vi).
            when 'idpre' then phIdpre = phBuffer:buffer-field(vi).
            when 'idsui' then phIdsui = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIntnt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIntnt.
    run updateIntnt.
    run createIntnt.
end procedure.

procedure setIntnt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIntnt.
    ghttIntnt = phttIntnt.
    run crudIntnt.
    delete object phttIntnt.
end procedure.

procedure readIntnt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table intnt 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as int64      no-undo.
    define input parameter pcTpidt as character  no-undo.
    define input parameter piNoidt as int64      no-undo.
    define input parameter piNbnum as integer    no-undo.
    define input parameter piIdpre as integer    no-undo.
    define input parameter piIdsui as integer    no-undo.
    define input parameter table-handle phttIntnt.
    define variable vhttBuffer as handle no-undo.
    define buffer intnt for intnt.

    vhttBuffer = phttIntnt:default-buffer-handle.
    for first intnt no-lock
        where intnt.tpcon = pcTpcon
          and intnt.nocon = piNocon
          and intnt.tpidt = pcTpidt
          and intnt.noidt = piNoidt
          and intnt.nbnum = piNbnum
          and intnt.idpre = piIdpre
          and intnt.idsui = piIdsui:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer intnt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIntnt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIntnt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table intnt 
    Notes  : service externe. Critère piIdpre = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as int64      no-undo.
    define input parameter pcTpidt as character  no-undo.
    define input parameter piNoidt as int64      no-undo.
    define input parameter piNbnum as integer    no-undo.
    define input parameter piIdpre as integer    no-undo.
    define input parameter table-handle phttIntnt.
    define variable vhttBuffer as handle  no-undo.
    define buffer intnt for intnt.

    vhttBuffer = phttIntnt:default-buffer-handle.
    if piIdpre = ?
    then for each intnt no-lock
        where intnt.tpcon = pcTpcon
          and intnt.nocon = piNocon
          and intnt.tpidt = pcTpidt
          and intnt.noidt = piNoidt
          and intnt.nbnum = piNbnum:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer intnt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each intnt no-lock
        where intnt.tpcon = pcTpcon
          and intnt.nocon = piNocon
          and intnt.tpidt = pcTpidt
          and intnt.noidt = piNoidt
          and intnt.nbnum = piNbnum
          and intnt.idpre = piIdpre:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer intnt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIntnt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIntnt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhTpidt    as handle  no-undo.
    define variable vhNoidt    as handle  no-undo.
    define variable vhNbnum    as handle  no-undo.
    define variable vhIdpre    as handle  no-undo.
    define variable vhIdsui    as handle  no-undo.
    define buffer intnt for intnt.

    create query vhttquery.
    vhttBuffer = ghttIntnt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIntnt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhTpidt, output vhNoidt, output vhNbnum, output vhIdpre, output vhIdsui).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first intnt exclusive-lock
                where rowid(intnt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer intnt:handle, 'tpcon/nocon/tpidt/noidt/nbnum/idpre/idsui: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhTpidt:buffer-value(), vhNoidt:buffer-value(), vhNbnum:buffer-value(), vhIdpre:buffer-value(), vhIdsui:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer intnt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIntnt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer intnt   for intnt.
    define buffer vbIntnt for intnt.

    create query vhttquery.
    vhttBuffer = ghttIntnt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIntnt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.
            create intnt.
            if not outils:copyValidField(buffer intnt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.

            if intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
            and (intnt.tpidt = {&TYPEROLE-coIndivisaire}
              or intnt.tpidt = {&TYPEROLE-nuProprietaire}
              or intnt.tpidt = {&TYPEROLE-mandant})
            then do:
                find last vbIntnt no-lock
                    where vbIntnt.idsui > 0 no-error.
                assign
                    intnt.idsui = if available vbIntnt then vbIntnt.idsui + 1 else 1
                    current-value(sq_idsui01) = intnt.idsui
                .
            end.

        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIntnt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhTpidt    as handle  no-undo.
    define variable vhNoidt    as handle  no-undo.
    define variable vhNbnum    as handle  no-undo.
    define variable vhIdpre    as handle  no-undo.
    define variable vhIdsui    as handle  no-undo.
    define buffer intnt for intnt.

    create query vhttquery.
    vhttBuffer = ghttIntnt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIntnt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhTpidt, output vhNoidt, output vhNbnum, output vhIdpre, output vhIdsui).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first intnt exclusive-lock
                where rowid(Intnt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer intnt:handle, 'tpcon/nocon/tpidt/noidt/nbnum/idpre/idsui: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhTpidt:buffer-value(), vhNoidt:buffer-value(), vhNbnum:buffer-value(), vhIdpre:buffer-value(), vhIdsui:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete intnt no-error.
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

procedure deleteIntnt2Contrat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les intnt d'un contrat
    Notes  : anciennement supIntCt. service externe (gesind00.p?)
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeIdentifiant   as character no-undo.
    define input parameter piNumeroContrat     as int64     no-undo.
    define input parameter pcTypeContrat       as character no-undo.

    define buffer intnt for intnt.
blocTrans:
    do transaction:
        for each intnt exclusive-lock
            where intnt.tpcon = pcTypeContrat
              and intnt.nocon = piNumeroContrat
              and intnt.tpidt = pcTypeIdentifiant:
            delete intnt no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.

procedure deleteIntnt2Batiment:
    /*------------------------------------------------------------------------------
    Purpose: suppression des relation contrat / batiment
    Notes  : anciennement supIntCt. service externe (gesind00.p?)
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroBatiment as int64 no-undo.
    for each intnt exclusive-lock
        where intnt.tpidt = {&TYPEBIEN-batiment}
          and intnt.noidt = piNumeroBatiment
          and intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}:
        delete intnt.
    end.
    for each intnt exclusive-lock
        where intnt.tpidt = {&TYPEBIEN-batiment}
          and intnt.noidt = piNumeroBatiment
          and intnt.tpcon = {&TYPECONTRAT-mandat2Syndic}:
        delete intnt.
    end.
end procedure.

procedure getLastIntntContrat:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par genoffqt.p
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat     as character no-undo.
    define input  parameter piNumeroContrat   as int64     no-undo.
    define input  parameter pcTypeIdentifiant as character no-undo.
    define output parameter piNumeroImmeuble  as int64     no-undo.

    define buffer intnt for intnt.

    for last intnt no-lock
        where intnt.tpcon = pcTypeContrat
          and intnt.nocon = piNumeroContrat
          and intnt.tpidt = pcTypeIdentifiant:
        piNumeroImmeuble = intnt.noidt.
    end.
end procedure.

procedure deleteIntntContrat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les intnt d'un contrat
    Notes  : service externe (gesind00.p)
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeIdentifiant   as character no-undo.
    define input parameter piNumeroContrat     as int64     no-undo.
    define input parameter pcTypeContrat       as character no-undo.

    define buffer intnt for intnt.
blocTrans:
    do transaction:
        for each intnt exclusive-lock
            where intnt.tpcon = pcTypeContrat
              and intnt.nocon = piNumeroContrat
              and intnt.tpidt = pcTypeIdentifiant:
            delete intnt no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
