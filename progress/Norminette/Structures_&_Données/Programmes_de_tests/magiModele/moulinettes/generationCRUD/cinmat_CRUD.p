/*------------------------------------------------------------------------
File        : cinmat_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cinmat
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cinmat.i}
{application/include/error.i}
define variable ghttcinmat as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phNum-int as handle, output phInvest-cle as handle, output phMat-num as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/num-int/invest-cle/mat-num, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'num-int' then phNum-int = phBuffer:buffer-field(vi).
            when 'invest-cle' then phInvest-cle = phBuffer:buffer-field(vi).
            when 'mat-num' then phMat-num = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCinmat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCinmat.
    run updateCinmat.
    run createCinmat.
end procedure.

procedure setCinmat:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCinmat.
    ghttCinmat = phttCinmat.
    run crudCinmat.
    delete object phttCinmat.
end procedure.

procedure readCinmat:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cinmat Fichier materiel (immos)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter piNum-int    as integer    no-undo.
    define input parameter pcInvest-cle as character  no-undo.
    define input parameter pcMat-num    as character  no-undo.
    define input parameter table-handle phttCinmat.
    define variable vhttBuffer as handle no-undo.
    define buffer cinmat for cinmat.

    vhttBuffer = phttCinmat:default-buffer-handle.
    for first cinmat no-lock
        where cinmat.soc-cd = piSoc-cd
          and cinmat.etab-cd = piEtab-cd
          and cinmat.num-int = piNum-int
          and cinmat.invest-cle = pcInvest-cle
          and cinmat.mat-num = pcMat-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cinmat:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCinmat no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCinmat:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cinmat Fichier materiel (immos)
    Notes  : service externe. Critère pcInvest-cle = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter piNum-int    as integer    no-undo.
    define input parameter pcInvest-cle as character  no-undo.
    define input parameter table-handle phttCinmat.
    define variable vhttBuffer as handle  no-undo.
    define buffer cinmat for cinmat.

    vhttBuffer = phttCinmat:default-buffer-handle.
    if pcInvest-cle = ?
    then for each cinmat no-lock
        where cinmat.soc-cd = piSoc-cd
          and cinmat.etab-cd = piEtab-cd
          and cinmat.num-int = piNum-int:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cinmat:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cinmat no-lock
        where cinmat.soc-cd = piSoc-cd
          and cinmat.etab-cd = piEtab-cd
          and cinmat.num-int = piNum-int
          and cinmat.invest-cle = pcInvest-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cinmat:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCinmat no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCinmat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define variable vhInvest-cle    as handle  no-undo.
    define variable vhMat-num    as handle  no-undo.
    define buffer cinmat for cinmat.

    create query vhttquery.
    vhttBuffer = ghttCinmat:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCinmat:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNum-int, output vhInvest-cle, output vhMat-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cinmat exclusive-lock
                where rowid(cinmat) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cinmat:handle, 'soc-cd/etab-cd/num-int/invest-cle/mat-num: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNum-int:buffer-value(), vhInvest-cle:buffer-value(), vhMat-num:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cinmat:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCinmat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cinmat for cinmat.

    create query vhttquery.
    vhttBuffer = ghttCinmat:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCinmat:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cinmat.
            if not outils:copyValidField(buffer cinmat:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCinmat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define variable vhInvest-cle    as handle  no-undo.
    define variable vhMat-num    as handle  no-undo.
    define buffer cinmat for cinmat.

    create query vhttquery.
    vhttBuffer = ghttCinmat:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCinmat:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNum-int, output vhInvest-cle, output vhMat-num).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cinmat exclusive-lock
                where rowid(Cinmat) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cinmat:handle, 'soc-cd/etab-cd/num-int/invest-cle/mat-num: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNum-int:buffer-value(), vhInvest-cle:buffer-value(), vhMat-num:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cinmat no-error.
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

