/*------------------------------------------------------------------------
File        : acomp_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table acomp
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/acomp.i}
{application/include/error.i}
define variable ghttacomp as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phCmpc-mandat-cd as handle, output phCmpc-jou-cd as handle, output phCmpc-prd-cd as handle, output phCmpc-prd-num as handle, output phCmpc-piece-int as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/cmpc-mandat-cd/cmpc-jou-cd/cmpc-prd-cd/cmpc-prd-num/cmpc-piece-int, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'cmpc-mandat-cd' then phCmpc-mandat-cd = phBuffer:buffer-field(vi).
            when 'cmpc-jou-cd' then phCmpc-jou-cd = phBuffer:buffer-field(vi).
            when 'cmpc-prd-cd' then phCmpc-prd-cd = phBuffer:buffer-field(vi).
            when 'cmpc-prd-num' then phCmpc-prd-num = phBuffer:buffer-field(vi).
            when 'cmpc-piece-int' then phCmpc-piece-int = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAcomp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAcomp.
    run updateAcomp.
    run createAcomp.
end procedure.

procedure setAcomp:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAcomp.
    ghttAcomp = phttAcomp.
    run crudAcomp.
    delete object phttAcomp.
end procedure.

procedure readAcomp:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table acomp table des compensations
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd         as integer    no-undo.
    define input parameter piCmpc-mandat-cd as integer    no-undo.
    define input parameter pcCmpc-jou-cd    as character  no-undo.
    define input parameter piCmpc-prd-cd    as integer    no-undo.
    define input parameter piCmpc-prd-num   as integer    no-undo.
    define input parameter piCmpc-piece-int as integer    no-undo.
    define input parameter table-handle phttAcomp.
    define variable vhttBuffer as handle no-undo.
    define buffer acomp for acomp.

    vhttBuffer = phttAcomp:default-buffer-handle.
    for first acomp no-lock
        where acomp.soc-cd = piSoc-cd
          and acomp.cmpc-mandat-cd = piCmpc-mandat-cd
          and acomp.cmpc-jou-cd = pcCmpc-jou-cd
          and acomp.cmpc-prd-cd = piCmpc-prd-cd
          and acomp.cmpc-prd-num = piCmpc-prd-num
          and acomp.cmpc-piece-int = piCmpc-piece-int:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer acomp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAcomp no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAcomp:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table acomp table des compensations
    Notes  : service externe. Critère piCmpc-prd-num = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd         as integer    no-undo.
    define input parameter piCmpc-mandat-cd as integer    no-undo.
    define input parameter pcCmpc-jou-cd    as character  no-undo.
    define input parameter piCmpc-prd-cd    as integer    no-undo.
    define input parameter piCmpc-prd-num   as integer    no-undo.
    define input parameter table-handle phttAcomp.
    define variable vhttBuffer as handle  no-undo.
    define buffer acomp for acomp.

    vhttBuffer = phttAcomp:default-buffer-handle.
    if piCmpc-prd-num = ?
    then for each acomp no-lock
        where acomp.soc-cd = piSoc-cd
          and acomp.cmpc-mandat-cd = piCmpc-mandat-cd
          and acomp.cmpc-jou-cd = pcCmpc-jou-cd
          and acomp.cmpc-prd-cd = piCmpc-prd-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer acomp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each acomp no-lock
        where acomp.soc-cd = piSoc-cd
          and acomp.cmpc-mandat-cd = piCmpc-mandat-cd
          and acomp.cmpc-jou-cd = pcCmpc-jou-cd
          and acomp.cmpc-prd-cd = piCmpc-prd-cd
          and acomp.cmpc-prd-num = piCmpc-prd-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer acomp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAcomp no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAcomp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhCmpc-mandat-cd    as handle  no-undo.
    define variable vhCmpc-jou-cd    as handle  no-undo.
    define variable vhCmpc-prd-cd    as handle  no-undo.
    define variable vhCmpc-prd-num    as handle  no-undo.
    define variable vhCmpc-piece-int    as handle  no-undo.
    define buffer acomp for acomp.

    create query vhttquery.
    vhttBuffer = ghttAcomp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAcomp:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhCmpc-mandat-cd, output vhCmpc-jou-cd, output vhCmpc-prd-cd, output vhCmpc-prd-num, output vhCmpc-piece-int).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first acomp exclusive-lock
                where rowid(acomp) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer acomp:handle, 'soc-cd/cmpc-mandat-cd/cmpc-jou-cd/cmpc-prd-cd/cmpc-prd-num/cmpc-piece-int: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhCmpc-mandat-cd:buffer-value(), vhCmpc-jou-cd:buffer-value(), vhCmpc-prd-cd:buffer-value(), vhCmpc-prd-num:buffer-value(), vhCmpc-piece-int:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer acomp:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAcomp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer acomp for acomp.

    create query vhttquery.
    vhttBuffer = ghttAcomp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAcomp:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create acomp.
            if not outils:copyValidField(buffer acomp:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAcomp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhCmpc-mandat-cd    as handle  no-undo.
    define variable vhCmpc-jou-cd    as handle  no-undo.
    define variable vhCmpc-prd-cd    as handle  no-undo.
    define variable vhCmpc-prd-num    as handle  no-undo.
    define variable vhCmpc-piece-int    as handle  no-undo.
    define buffer acomp for acomp.

    create query vhttquery.
    vhttBuffer = ghttAcomp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAcomp:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhCmpc-mandat-cd, output vhCmpc-jou-cd, output vhCmpc-prd-cd, output vhCmpc-prd-num, output vhCmpc-piece-int).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first acomp exclusive-lock
                where rowid(Acomp) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer acomp:handle, 'soc-cd/cmpc-mandat-cd/cmpc-jou-cd/cmpc-prd-cd/cmpc-prd-num/cmpc-piece-int: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhCmpc-mandat-cd:buffer-value(), vhCmpc-jou-cd:buffer-value(), vhCmpc-prd-cd:buffer-value(), vhCmpc-prd-num:buffer-value(), vhCmpc-piece-int:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete acomp no-error.
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

