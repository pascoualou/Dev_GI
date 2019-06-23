/*------------------------------------------------------------------------
File        : EmpRp_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table EmpRp
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/EmpRp.i}
{application/include/error.i}
define variable ghttEmpRp as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phTpemp as handle, output phNoemp as handle, output phNolot as handle, output phNocop as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur TpCon/NoCon/TpEmp/NoEmp/NoLot/NoCop, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'TpCon' then phTpcon = phBuffer:buffer-field(vi).
            when 'NoCon' then phNocon = phBuffer:buffer-field(vi).
            when 'TpEmp' then phTpemp = phBuffer:buffer-field(vi).
            when 'NoEmp' then phNoemp = phBuffer:buffer-field(vi).
            when 'NoLot' then phNolot = phBuffer:buffer-field(vi).
            when 'NoCop' then phNocop = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudEmprp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteEmprp.
    run updateEmprp.
    run createEmprp.
end procedure.

procedure setEmprp:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttEmprp.
    ghttEmprp = phttEmprp.
    run crudEmprp.
    delete object phttEmprp.
end procedure.

procedure readEmprp:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table EmpRp Emprunts : Table des repartitions Achat / Vente
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as integer    no-undo.
    define input parameter pcTpemp as character  no-undo.
    define input parameter piNoemp as integer    no-undo.
    define input parameter piNolot as integer    no-undo.
    define input parameter piNocop as integer    no-undo.
    define input parameter table-handle phttEmprp.
    define variable vhttBuffer as handle no-undo.
    define buffer EmpRp for EmpRp.

    vhttBuffer = phttEmprp:default-buffer-handle.
    for first EmpRp no-lock
        where EmpRp.TpCon = pcTpcon
          and EmpRp.NoCon = piNocon
          and EmpRp.TpEmp = pcTpemp
          and EmpRp.NoEmp = piNoemp
          and EmpRp.NoLot = piNolot
          and EmpRp.NoCop = piNocop:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer EmpRp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEmprp no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getEmprp:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table EmpRp Emprunts : Table des repartitions Achat / Vente
    Notes  : service externe. Critère piNolot = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as integer    no-undo.
    define input parameter pcTpemp as character  no-undo.
    define input parameter piNoemp as integer    no-undo.
    define input parameter piNolot as integer    no-undo.
    define input parameter table-handle phttEmprp.
    define variable vhttBuffer as handle  no-undo.
    define buffer EmpRp for EmpRp.

    vhttBuffer = phttEmprp:default-buffer-handle.
    if piNolot = ?
    then for each EmpRp no-lock
        where EmpRp.TpCon = pcTpcon
          and EmpRp.NoCon = piNocon
          and EmpRp.TpEmp = pcTpemp
          and EmpRp.NoEmp = piNoemp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer EmpRp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each EmpRp no-lock
        where EmpRp.TpCon = pcTpcon
          and EmpRp.NoCon = piNocon
          and EmpRp.TpEmp = pcTpemp
          and EmpRp.NoEmp = piNoemp
          and EmpRp.NoLot = piNolot:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer EmpRp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEmprp no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateEmprp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhTpemp    as handle  no-undo.
    define variable vhNoemp    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define variable vhNocop    as handle  no-undo.
    define buffer EmpRp for EmpRp.

    create query vhttquery.
    vhttBuffer = ghttEmprp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttEmprp:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhTpemp, output vhNoemp, output vhNolot, output vhNocop).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first EmpRp exclusive-lock
                where rowid(EmpRp) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer EmpRp:handle, 'TpCon/NoCon/TpEmp/NoEmp/NoLot/NoCop: ', substitute('&1/&2/&3/&4/&5/&6', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhTpemp:buffer-value(), vhNoemp:buffer-value(), vhNolot:buffer-value(), vhNocop:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer EmpRp:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createEmprp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer EmpRp for EmpRp.

    create query vhttquery.
    vhttBuffer = ghttEmprp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttEmprp:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create EmpRp.
            if not outils:copyValidField(buffer EmpRp:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteEmprp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhTpemp    as handle  no-undo.
    define variable vhNoemp    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define variable vhNocop    as handle  no-undo.
    define buffer EmpRp for EmpRp.

    create query vhttquery.
    vhttBuffer = ghttEmprp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttEmprp:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhTpemp, output vhNoemp, output vhNolot, output vhNocop).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first EmpRp exclusive-lock
                where rowid(Emprp) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer EmpRp:handle, 'TpCon/NoCon/TpEmp/NoEmp/NoLot/NoCop: ', substitute('&1/&2/&3/&4/&5/&6', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhTpemp:buffer-value(), vhNoemp:buffer-value(), vhNolot:buffer-value(), vhNocop:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete EmpRp no-error.
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

