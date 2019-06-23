/*------------------------------------------------------------------------
File        : peffcirc_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table peffcirc
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/peffcirc.i}
{application/include/error.i}
define variable ghttpeffcirc as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phJou-cd as handle, output phPrd-cd as handle, output phPrd-num as handle, output phPiece-int as handle, output phLig-tot as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int/lig-tot, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'jou-cd' then phJou-cd = phBuffer:buffer-field(vi).
            when 'prd-cd' then phPrd-cd = phBuffer:buffer-field(vi).
            when 'prd-num' then phPrd-num = phBuffer:buffer-field(vi).
            when 'piece-int' then phPiece-int = phBuffer:buffer-field(vi).
            when 'lig-tot' then phLig-tot = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudPeffcirc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deletePeffcirc.
    run updatePeffcirc.
    run createPeffcirc.
end procedure.

procedure setPeffcirc:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPeffcirc.
    ghttPeffcirc = phttPeffcirc.
    run crudPeffcirc.
    delete object phttPeffcirc.
end procedure.

procedure readPeffcirc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table peffcirc Effets en circulation
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcJou-cd    as character  no-undo.
    define input parameter piPrd-cd    as integer    no-undo.
    define input parameter piPrd-num   as integer    no-undo.
    define input parameter piPiece-int as integer    no-undo.
    define input parameter piLig-tot   as integer    no-undo.
    define input parameter table-handle phttPeffcirc.
    define variable vhttBuffer as handle no-undo.
    define buffer peffcirc for peffcirc.

    vhttBuffer = phttPeffcirc:default-buffer-handle.
    for first peffcirc no-lock
        where peffcirc.soc-cd = piSoc-cd
          and peffcirc.etab-cd = piEtab-cd
          and peffcirc.jou-cd = pcJou-cd
          and peffcirc.prd-cd = piPrd-cd
          and peffcirc.prd-num = piPrd-num
          and peffcirc.piece-int = piPiece-int
          and peffcirc.lig-tot = piLig-tot:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer peffcirc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPeffcirc no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getPeffcirc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table peffcirc Effets en circulation
    Notes  : service externe. Critère piPiece-int = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcJou-cd    as character  no-undo.
    define input parameter piPrd-cd    as integer    no-undo.
    define input parameter piPrd-num   as integer    no-undo.
    define input parameter piPiece-int as integer    no-undo.
    define input parameter table-handle phttPeffcirc.
    define variable vhttBuffer as handle  no-undo.
    define buffer peffcirc for peffcirc.

    vhttBuffer = phttPeffcirc:default-buffer-handle.
    if piPiece-int = ?
    then for each peffcirc no-lock
        where peffcirc.soc-cd = piSoc-cd
          and peffcirc.etab-cd = piEtab-cd
          and peffcirc.jou-cd = pcJou-cd
          and peffcirc.prd-cd = piPrd-cd
          and peffcirc.prd-num = piPrd-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer peffcirc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each peffcirc no-lock
        where peffcirc.soc-cd = piSoc-cd
          and peffcirc.etab-cd = piEtab-cd
          and peffcirc.jou-cd = pcJou-cd
          and peffcirc.prd-cd = piPrd-cd
          and peffcirc.prd-num = piPrd-num
          and peffcirc.piece-int = piPiece-int:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer peffcirc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPeffcirc no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatePeffcirc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhJou-cd    as handle  no-undo.
    define variable vhPrd-cd    as handle  no-undo.
    define variable vhPrd-num    as handle  no-undo.
    define variable vhPiece-int    as handle  no-undo.
    define variable vhLig-tot    as handle  no-undo.
    define buffer peffcirc for peffcirc.

    create query vhttquery.
    vhttBuffer = ghttPeffcirc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttPeffcirc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhPrd-cd, output vhPrd-num, output vhPiece-int, output vhLig-tot).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first peffcirc exclusive-lock
                where rowid(peffcirc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer peffcirc:handle, 'soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int/lig-tot: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhPiece-int:buffer-value(), vhLig-tot:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer peffcirc:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createPeffcirc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer peffcirc for peffcirc.

    create query vhttquery.
    vhttBuffer = ghttPeffcirc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttPeffcirc:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create peffcirc.
            if not outils:copyValidField(buffer peffcirc:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deletePeffcirc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhJou-cd    as handle  no-undo.
    define variable vhPrd-cd    as handle  no-undo.
    define variable vhPrd-num    as handle  no-undo.
    define variable vhPiece-int    as handle  no-undo.
    define variable vhLig-tot    as handle  no-undo.
    define buffer peffcirc for peffcirc.

    create query vhttquery.
    vhttBuffer = ghttPeffcirc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttPeffcirc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhPrd-cd, output vhPrd-num, output vhPiece-int, output vhLig-tot).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first peffcirc exclusive-lock
                where rowid(Peffcirc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer peffcirc:handle, 'soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int/lig-tot: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhPiece-int:buffer-value(), vhLig-tot:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete peffcirc no-error.
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

