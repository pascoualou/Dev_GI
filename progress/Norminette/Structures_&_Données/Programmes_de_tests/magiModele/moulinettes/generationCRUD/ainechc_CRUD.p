/*------------------------------------------------------------------------
File        : ainechc_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ainechc
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ainechc.i}
{application/include/error.i}
define variable ghttainechc as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phType-invest as handle, output phNum-int as handle, output phOrder-num as handle, output phNolot as handle, output phCpt-copro as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/type-invest/num-int/order-num/nolot/cpt-copro, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'type-invest' then phType-invest = phBuffer:buffer-field(vi).
            when 'num-int' then phNum-int = phBuffer:buffer-field(vi).
            when 'order-num' then phOrder-num = phBuffer:buffer-field(vi).
            when 'nolot' then phNolot = phBuffer:buffer-field(vi).
            when 'cpt-copro' then phCpt-copro = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAinechc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAinechc.
    run updateAinechc.
    run createAinechc.
end procedure.

procedure setAinechc:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAinechc.
    ghttAinechc = phttAinechc.
    run crudAinechc.
    delete object phttAinechc.
end procedure.

procedure readAinechc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ainechc echeances emprunt par copro et lot
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter piType-invest as integer    no-undo.
    define input parameter piNum-int     as integer    no-undo.
    define input parameter piOrder-num   as integer    no-undo.
    define input parameter piNolot       as integer    no-undo.
    define input parameter pcCpt-copro   as character  no-undo.
    define input parameter table-handle phttAinechc.
    define variable vhttBuffer as handle no-undo.
    define buffer ainechc for ainechc.

    vhttBuffer = phttAinechc:default-buffer-handle.
    for first ainechc no-lock
        where ainechc.soc-cd = piSoc-cd
          and ainechc.etab-cd = piEtab-cd
          and ainechc.type-invest = piType-invest
          and ainechc.num-int = piNum-int
          and ainechc.order-num = piOrder-num
          and ainechc.nolot = piNolot
          and ainechc.cpt-copro = pcCpt-copro:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ainechc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAinechc no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAinechc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ainechc echeances emprunt par copro et lot
    Notes  : service externe. Critère piNolot = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter piType-invest as integer    no-undo.
    define input parameter piNum-int     as integer    no-undo.
    define input parameter piOrder-num   as integer    no-undo.
    define input parameter piNolot       as integer    no-undo.
    define input parameter table-handle phttAinechc.
    define variable vhttBuffer as handle  no-undo.
    define buffer ainechc for ainechc.

    vhttBuffer = phttAinechc:default-buffer-handle.
    if piNolot = ?
    then for each ainechc no-lock
        where ainechc.soc-cd = piSoc-cd
          and ainechc.etab-cd = piEtab-cd
          and ainechc.type-invest = piType-invest
          and ainechc.num-int = piNum-int
          and ainechc.order-num = piOrder-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ainechc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ainechc no-lock
        where ainechc.soc-cd = piSoc-cd
          and ainechc.etab-cd = piEtab-cd
          and ainechc.type-invest = piType-invest
          and ainechc.num-int = piNum-int
          and ainechc.order-num = piOrder-num
          and ainechc.nolot = piNolot:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ainechc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAinechc no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAinechc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhType-invest    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define variable vhOrder-num    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define variable vhCpt-copro    as handle  no-undo.
    define buffer ainechc for ainechc.

    create query vhttquery.
    vhttBuffer = ghttAinechc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAinechc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhType-invest, output vhNum-int, output vhOrder-num, output vhNolot, output vhCpt-copro).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ainechc exclusive-lock
                where rowid(ainechc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ainechc:handle, 'soc-cd/etab-cd/type-invest/num-int/order-num/nolot/cpt-copro: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhType-invest:buffer-value(), vhNum-int:buffer-value(), vhOrder-num:buffer-value(), vhNolot:buffer-value(), vhCpt-copro:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ainechc:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAinechc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ainechc for ainechc.

    create query vhttquery.
    vhttBuffer = ghttAinechc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAinechc:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ainechc.
            if not outils:copyValidField(buffer ainechc:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAinechc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhType-invest    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define variable vhOrder-num    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define variable vhCpt-copro    as handle  no-undo.
    define buffer ainechc for ainechc.

    create query vhttquery.
    vhttBuffer = ghttAinechc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAinechc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhType-invest, output vhNum-int, output vhOrder-num, output vhNolot, output vhCpt-copro).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ainechc exclusive-lock
                where rowid(Ainechc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ainechc:handle, 'soc-cd/etab-cd/type-invest/num-int/order-num/nolot/cpt-copro: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhType-invest:buffer-value(), vhNum-int:buffer-value(), vhOrder-num:buffer-value(), vhNolot:buffer-value(), vhCpt-copro:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ainechc no-error.
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

