/*------------------------------------------------------------------------
File        : detail_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table detail
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
/*{include/detail.i}*/
{application/include/error.i}
define variable ghttdetail as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phCddet as handle, output phNodet as handle, output phIddet as handle, output phIxd01 as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cddet/nodet/iddet/ixd01, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cddet' then phCddet = phBuffer:buffer-field(vi).
            when 'nodet' then phNodet = phBuffer:buffer-field(vi).
            when 'iddet' then phIddet = phBuffer:buffer-field(vi).
            when 'ixd01' then phIxd01 = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudDetail private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteDetail.
    run updateDetail.
    run createDetail.
end procedure.

procedure setDetail:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttDetail.
    ghttDetail = phttDetail.
    run crudDetail.
    delete object phttDetail.
end procedure.

procedure readDetail:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table detail Table de détail des infos d'une paire "Code-Num".
Détail contrat avec Code contrat-Numéro contrat, ou d'un role avec code role-numéro role, etc....
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCddet as character  no-undo.
    define input parameter piNodet as int64      no-undo.
    define input parameter piIddet as integer    no-undo.
    define input parameter pcIxd01 as character  no-undo.
    define input parameter table-handle phttDetail.
    define variable vhttBuffer as handle no-undo.
    define buffer detail for detail.

    vhttBuffer = phttDetail:default-buffer-handle.
    for first detail no-lock
        where detail.cddet = pcCddet
          and detail.nodet = piNodet
          and detail.iddet = piIddet
          and detail.ixd01 = pcIxd01:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer detail:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDetail no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getDetail:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table detail Table de détail des infos d'une paire "Code-Num".
Détail contrat avec Code contrat-Numéro contrat, ou d'un role avec code role-numéro role, etc....
    Notes  : service externe. Critère piIddet = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcCddet as character  no-undo.
    define input parameter piNodet as int64      no-undo.
    define input parameter piIddet as integer    no-undo.
    define input parameter table-handle phttDetail.
    define variable vhttBuffer as handle  no-undo.
    define buffer detail for detail.

    vhttBuffer = phttDetail:default-buffer-handle.
    if piIddet = ?
    then for each detail no-lock
        where detail.cddet = pcCddet
          and detail.nodet = piNodet:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer detail:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each detail no-lock
        where detail.cddet = pcCddet
          and detail.nodet = piNodet
          and detail.iddet = piIddet:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer detail:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttDetail no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateDetail private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCddet    as handle  no-undo.
    define variable vhNodet    as handle  no-undo.
    define variable vhIddet    as handle  no-undo.
    define variable vhIxd01    as handle  no-undo.
    define buffer detail for detail.

    create query vhttquery.
    vhttBuffer = ghttDetail:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttDetail:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCddet, output vhNodet, output vhIddet, output vhIxd01).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first detail exclusive-lock
                where rowid(detail) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer detail:handle, 'cddet/nodet/iddet/ixd01: ', substitute('&1/&2/&3/&4', vhCddet:buffer-value(), vhNodet:buffer-value(), vhIddet:buffer-value(), vhIxd01:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer detail:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createDetail private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer detail for detail.

    create query vhttquery.
    vhttBuffer = ghttDetail:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttDetail:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create detail.
            if not outils:copyValidField(buffer detail:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteDetail private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCddet    as handle  no-undo.
    define variable vhNodet    as handle  no-undo.
    define variable vhIddet    as handle  no-undo.
    define variable vhIxd01    as handle  no-undo.
    define buffer detail for detail.

    create query vhttquery.
    vhttBuffer = ghttDetail:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttDetail:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCddet, output vhNodet, output vhIddet, output vhIxd01).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first detail exclusive-lock
                where rowid(Detail) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer detail:handle, 'cddet/nodet/iddet/ixd01: ', substitute('&1/&2/&3/&4', vhCddet:buffer-value(), vhNodet:buffer-value(), vhIddet:buffer-value(), vhIxd01:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete detail no-error.
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

procedure deleteDetailSurCode:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCode as character no-undo.
    
    define buffer detail for detail.

message "deleteDetailSurCode " pcCode. 

blocTrans:
    do transaction:
        for each detail exclusive-lock
           where detail.cddet = pcCode:
            delete detail no-error. 
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.

procedure deleteDetailSurCodeNumeroIndicateur:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCode       as character no-undo.
    define input parameter piNumero     as int64     no-undo.
    define input parameter piIndicateur as integer   no-undo.
    
    define buffer detail for detail.

message "deleteDetailSurCodeNumeroIndicateur " pcCode "// " piNumero "// " piIndicateur. 

blocTrans:
    do transaction:
        for each detail exclusive-lock 
           where detail.cddet = pcCode
             and detail.nodet = piNumero
             and detail.iddet = piIndicateur:
            delete detail no-error. 
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.

