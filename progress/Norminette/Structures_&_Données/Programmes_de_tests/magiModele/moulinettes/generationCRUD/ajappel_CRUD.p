/*------------------------------------------------------------------------
File        : ajappel_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ajappel
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ajappel.i}
{application/include/error.i}
define variable ghttajappel as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phNatjou-gi as handle, output phAppel-num as handle, output phDaeffet as handle, output phLig as handle, output phPos as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/natjou-gi/appel-num/daeffet/lig/pos, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'natjou-gi' then phNatjou-gi = phBuffer:buffer-field(vi).
            when 'appel-num' then phAppel-num = phBuffer:buffer-field(vi).
            when 'daeffet' then phDaeffet = phBuffer:buffer-field(vi).
            when 'lig' then phLig = phBuffer:buffer-field(vi).
            when 'pos' then phPos = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAjappel private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAjappel.
    run updateAjappel.
    run createAjappel.
end procedure.

procedure setAjappel:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAjappel.
    ghttAjappel = phttAjappel.
    run crudAjappel.
    delete object phttAjappel.
end procedure.

procedure readAjappel:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ajappel lignes de detail d'appels de fonds
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcNatjou-gi as character  no-undo.
    define input parameter pcAppel-num as character  no-undo.
    define input parameter pdaDaeffet   as date       no-undo.
    define input parameter piLig       as integer    no-undo.
    define input parameter piPos       as integer    no-undo.
    define input parameter table-handle phttAjappel.
    define variable vhttBuffer as handle no-undo.
    define buffer ajappel for ajappel.

    vhttBuffer = phttAjappel:default-buffer-handle.
    for first ajappel no-lock
        where ajappel.soc-cd = piSoc-cd
          and ajappel.etab-cd = piEtab-cd
          and ajappel.natjou-gi = pcNatjou-gi
          and ajappel.appel-num = pcAppel-num
          and ajappel.daeffet = pdaDaeffet
          and ajappel.lig = piLig
          and ajappel.pos = piPos:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ajappel:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAjappel no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAjappel:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ajappel lignes de detail d'appels de fonds
    Notes  : service externe. Critère piLig = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcNatjou-gi as character  no-undo.
    define input parameter pcAppel-num as character  no-undo.
    define input parameter pdaDaeffet   as date       no-undo.
    define input parameter piLig       as integer    no-undo.
    define input parameter table-handle phttAjappel.
    define variable vhttBuffer as handle  no-undo.
    define buffer ajappel for ajappel.

    vhttBuffer = phttAjappel:default-buffer-handle.
    if piLig = ?
    then for each ajappel no-lock
        where ajappel.soc-cd = piSoc-cd
          and ajappel.etab-cd = piEtab-cd
          and ajappel.natjou-gi = pcNatjou-gi
          and ajappel.appel-num = pcAppel-num
          and ajappel.daeffet = pdaDaeffet:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ajappel:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ajappel no-lock
        where ajappel.soc-cd = piSoc-cd
          and ajappel.etab-cd = piEtab-cd
          and ajappel.natjou-gi = pcNatjou-gi
          and ajappel.appel-num = pcAppel-num
          and ajappel.daeffet = pdaDaeffet
          and ajappel.lig = piLig:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ajappel:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAjappel no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAjappel private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNatjou-gi    as handle  no-undo.
    define variable vhAppel-num    as handle  no-undo.
    define variable vhDaeffet    as handle  no-undo.
    define variable vhLig    as handle  no-undo.
    define variable vhPos    as handle  no-undo.
    define buffer ajappel for ajappel.

    create query vhttquery.
    vhttBuffer = ghttAjappel:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAjappel:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNatjou-gi, output vhAppel-num, output vhDaeffet, output vhLig, output vhPos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ajappel exclusive-lock
                where rowid(ajappel) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ajappel:handle, 'soc-cd/etab-cd/natjou-gi/appel-num/daeffet/lig/pos: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNatjou-gi:buffer-value(), vhAppel-num:buffer-value(), vhDaeffet:buffer-value(), vhLig:buffer-value(), vhPos:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ajappel:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAjappel private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ajappel for ajappel.

    create query vhttquery.
    vhttBuffer = ghttAjappel:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAjappel:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ajappel.
            if not outils:copyValidField(buffer ajappel:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAjappel private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNatjou-gi    as handle  no-undo.
    define variable vhAppel-num    as handle  no-undo.
    define variable vhDaeffet    as handle  no-undo.
    define variable vhLig    as handle  no-undo.
    define variable vhPos    as handle  no-undo.
    define buffer ajappel for ajappel.

    create query vhttquery.
    vhttBuffer = ghttAjappel:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAjappel:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNatjou-gi, output vhAppel-num, output vhDaeffet, output vhLig, output vhPos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ajappel exclusive-lock
                where rowid(Ajappel) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ajappel:handle, 'soc-cd/etab-cd/natjou-gi/appel-num/daeffet/lig/pos: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNatjou-gi:buffer-value(), vhAppel-num:buffer-value(), vhDaeffet:buffer-value(), vhLig:buffer-value(), vhPos:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ajappel no-error.
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

