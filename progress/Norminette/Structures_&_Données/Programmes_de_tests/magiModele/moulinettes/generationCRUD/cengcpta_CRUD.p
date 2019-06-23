/*------------------------------------------------------------------------
File        : cengcpta_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cengcpta
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cengcpta.i}
{application/include/error.i}
define variable ghttcengcpta as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phNiv-num as handle, output phAna-cd as handle, output phNum-int as handle, output phLig as handle, output phJou-cd as handle, output phPrd-cd as handle, output phPrd-num as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/niv-num/ana-cd/num-int/lig/jou-cd/prd-cd/prd-num/piece-compta, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'niv-num' then phNiv-num = phBuffer:buffer-field(vi).
            when 'ana-cd' then phAna-cd = phBuffer:buffer-field(vi).
            when 'num-int' then phNum-int = phBuffer:buffer-field(vi).
            when 'lig' then phLig = phBuffer:buffer-field(vi).
            when 'jou-cd' then phJou-cd = phBuffer:buffer-field(vi).
            when 'prd-cd' then phPrd-cd = phBuffer:buffer-field(vi).
            when 'prd-num' then phPrd-num = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCengcpta private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCengcpta.
    run updateCengcpta.
    run createCengcpta.
end procedure.

procedure setCengcpta:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCengcpta.
    ghttCengcpta = phttCengcpta.
    run crudCengcpta.
    delete object phttCengcpta.
end procedure.

procedure readCengcpta:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cengcpta 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piNiv-num as integer    no-undo.
    define input parameter pcAna-cd  as character  no-undo.
    define input parameter piNum-int as integer    no-undo.
    define input parameter piLig     as integer    no-undo.
    define input parameter pcJou-cd  as character  no-undo.
    define input parameter piPrd-cd  as integer    no-undo.
    define input parameter piPrd-num as integer    no-undo.
    define input parameter table-handle phttCengcpta.
    define variable vhttBuffer as handle no-undo.
    define buffer cengcpta for cengcpta.

    vhttBuffer = phttCengcpta:default-buffer-handle.
    for first cengcpta no-lock
        where cengcpta.soc-cd = piSoc-cd
          and cengcpta.etab-cd = piEtab-cd
          and cengcpta.niv-num = piNiv-num
          and cengcpta.ana-cd = pcAna-cd
          and cengcpta.num-int = piNum-int
          and cengcpta.lig = piLig
          and cengcpta.jou-cd = pcJou-cd
          and cengcpta.prd-cd = piPrd-cd
          and cengcpta.prd-num = piPrd-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cengcpta:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCengcpta no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCengcpta:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cengcpta 
    Notes  : service externe. Critère piPrd-num = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piNiv-num as integer    no-undo.
    define input parameter pcAna-cd  as character  no-undo.
    define input parameter piNum-int as integer    no-undo.
    define input parameter piLig     as integer    no-undo.
    define input parameter pcJou-cd  as character  no-undo.
    define input parameter piPrd-cd  as integer    no-undo.
    define input parameter piPrd-num as integer    no-undo.
    define input parameter table-handle phttCengcpta.
    define variable vhttBuffer as handle  no-undo.
    define buffer cengcpta for cengcpta.

    vhttBuffer = phttCengcpta:default-buffer-handle.
    if piPrd-num = ?
    then for each cengcpta no-lock
        where cengcpta.soc-cd = piSoc-cd
          and cengcpta.etab-cd = piEtab-cd
          and cengcpta.niv-num = piNiv-num
          and cengcpta.ana-cd = pcAna-cd
          and cengcpta.num-int = piNum-int
          and cengcpta.lig = piLig
          and cengcpta.jou-cd = pcJou-cd
          and cengcpta.prd-cd = piPrd-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cengcpta:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cengcpta no-lock
        where cengcpta.soc-cd = piSoc-cd
          and cengcpta.etab-cd = piEtab-cd
          and cengcpta.niv-num = piNiv-num
          and cengcpta.ana-cd = pcAna-cd
          and cengcpta.num-int = piNum-int
          and cengcpta.lig = piLig
          and cengcpta.jou-cd = pcJou-cd
          and cengcpta.prd-cd = piPrd-cd
          and cengcpta.prd-num = piPrd-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cengcpta:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCengcpta no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCengcpta private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNiv-num    as handle  no-undo.
    define variable vhAna-cd    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define variable vhLig    as handle  no-undo.
    define variable vhJou-cd    as handle  no-undo.
    define variable vhPrd-cd    as handle  no-undo.
    define variable vhPrd-num    as handle  no-undo.
    define buffer cengcpta for cengcpta.

    create query vhttquery.
    vhttBuffer = ghttCengcpta:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCengcpta:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNiv-num, output vhAna-cd, output vhNum-int, output vhLig, output vhJou-cd, output vhPrd-cd, output vhPrd-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cengcpta exclusive-lock
                where rowid(cengcpta) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cengcpta:handle, 'soc-cd/etab-cd/niv-num/ana-cd/num-int/lig/jou-cd/prd-cd/prd-num/piece-compta: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8/&9', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNiv-num:buffer-value(), vhAna-cd:buffer-value(), vhNum-int:buffer-value(), vhLig:buffer-value(), vhJou-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cengcpta:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCengcpta private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cengcpta for cengcpta.

    create query vhttquery.
    vhttBuffer = ghttCengcpta:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCengcpta:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cengcpta.
            if not outils:copyValidField(buffer cengcpta:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCengcpta private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNiv-num    as handle  no-undo.
    define variable vhAna-cd    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define variable vhLig    as handle  no-undo.
    define variable vhJou-cd    as handle  no-undo.
    define variable vhPrd-cd    as handle  no-undo.
    define variable vhPrd-num    as handle  no-undo.
    define buffer cengcpta for cengcpta.

    create query vhttquery.
    vhttBuffer = ghttCengcpta:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCengcpta:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNiv-num, output vhAna-cd, output vhNum-int, output vhLig, output vhJou-cd, output vhPrd-cd, output vhPrd-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cengcpta exclusive-lock
                where rowid(Cengcpta) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cengcpta:handle, 'soc-cd/etab-cd/niv-num/ana-cd/num-int/lig/jou-cd/prd-cd/prd-num/piece-compta: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8/&9', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNiv-num:buffer-value(), vhAna-cd:buffer-value(), vhNum-int:buffer-value(), vhLig:buffer-value(), vhJou-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cengcpta no-error.
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

