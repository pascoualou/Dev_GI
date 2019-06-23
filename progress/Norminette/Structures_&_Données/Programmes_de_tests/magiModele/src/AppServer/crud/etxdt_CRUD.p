/*------------------------------------------------------------------------
File        : etxdt_CRUD.p
Purpose     : librairie contenant toutes les procedures liees a la mise a jour des details en-cours des appels fonds
Author(s)   : RT 1996/10/07  -  GGA 2018/01/12
Notes       : a partir de adb/lib/l_etxdt.p
derniere revue: 2018/06/05 - phm: OK

01  19/11/1998  AF    MODIF LOCK
02  18/07/2000  PL    Gestion Double affichage Euro/Devise.
03  21/08/2001  AF    Ajout Champs LbDiv & LbDiv2
04  02/10/2001  AF    Ajout champs lbdiv3
05  17/02/2002  PL    Nouvelle gestion APF travaux
06  17/12/2003  PL    Adaptation nouvelle gestion lib. 
07  20/12/2006  SY    1206/0289: correction gestion des Flags lorsqu'ils ne sont pas envoyés pour maj (Pb depuis nouvelle gestion Lib.)
08  16/09/2008  NP    0608/0065 Gestion Mandats à 5 chiffres
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
define variable ghttetxdt as handle no-undo.      // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phNotrx as handle, output phTpapp as handle, output phNoapp as handle, output phNolot as handle, output phNorol as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index primaire - NB: PAS D'INDEX UNIQUE !!!
    Notes: si la temp-table contient un mapping de label sur notrx/tpapp/noapp/nolot, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'notrx' then phNotrx = phBuffer:buffer-field(vi).
            when 'tpapp' then phTpapp = phBuffer:buffer-field(vi).
            when 'noapp' then phNoapp = phBuffer:buffer-field(vi).
            when 'nolot' then phNolot = phBuffer:buffer-field(vi).
            when 'norol' then phNorol = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudEtxdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteEtxdt.
    run updateEtxdt.
    run createEtxdt.
end procedure.

procedure setEtxdt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttEtxdt.
    ghttEtxdt = phttEtxdt.
    run crudEtxdt.
    delete object phttEtxdt.
end procedure.

procedure readEtxdt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table etxdt
    Notes  : service externe - ATTENTION, PAS D'INDEX UNIQUE !!!
    ------------------------------------------------------------------------------*/
    define input parameter piNotrx as integer    no-undo.
    define input parameter pcTpapp as character  no-undo.
    define input parameter piNoapp as integer    no-undo.
    define input parameter piNolot as integer    no-undo.
    define input parameter piNorol as integer    no-undo.
    define input parameter table-handle phttEtxdt.
    define variable vhttBuffer as handle no-undo.
    define buffer etxdt for etxdt.

    vhttBuffer = phttEtxdt:default-buffer-handle.
    for first etxdt no-lock
        where etxdt.notrx = piNotrx
          and etxdt.tpapp = pcTpapp
          and etxdt.noapp = piNoapp
          and etxdt.nolot = piNolot
          and etxdt.norol = piNorol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer etxdt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEtxdt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getEtxdt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table etxdt - ATTENTION, PAS D'INDEX UNIQUE !!!
    Notes  : service externe. Critère piNoapp = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNotrx as integer   no-undo.
    define input parameter pcTpapp as character no-undo.
    define input parameter piNoapp as integer   no-undo.
    define input parameter piNolot as integer   no-undo.
    define input parameter table-handle phttEtxdt.
    define variable vhttBuffer as handle  no-undo.
    define buffer etxdt for etxdt.

    vhttBuffer = phttEtxdt:default-buffer-handle.
    if piNolot = ?
    then for each etxdt no-lock
        where etxdt.notrx = piNotrx
          and etxdt.tpapp = pcTpapp
          and etxdt.noapp = piNoapp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer etxdt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each etxdt no-lock
        where etxdt.notrx = piNotrx
          and etxdt.tpapp = pcTpapp
          and etxdt.noapp = piNoapp
          and etxdt.nolot = piNolot:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer etxdt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEtxdt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateEtxdt private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure pour la modification d'un enregistrement de etxdt.
    Notes  : 
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNotrx    as handle  no-undo.
    define variable vhTpapp    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define buffer etxdt for etxdt.

    create query vhttquery.
    vhttBuffer = ghttEtxdt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttEtxdt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNotrx, output vhTpapp, output vhNoapp, output vhNolot, output vhNorol).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first etxdt exclusive-lock
                where rowid(etxdt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer etxdt:handle, 'notrx/tpapp/noapp/nolot/norol: ', substitute('&1/&2/&3/&4', vhNotrx:buffer-value(), vhTpapp:buffer-value(), vhNoapp:buffer-value(), vhNolot:buffer-value(), vhNorol:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer etxdt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createEtxdt private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure pour la création d'un enregistrement de etxdt.
    Notes  : 
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer etxdt for etxdt.

    create query vhttquery.
    vhttBuffer = ghttEtxdt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttEtxdt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create etxdt.
            if not outils:copyValidField(buffer etxdt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteEtxdt private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure pour la suppression d'un enregistrement de etxdt.
    Notes  : 
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNotrx    as handle  no-undo.
    define variable vhTpapp    as handle  no-undo.
    define variable vhNoapp    as handle  no-undo.
    define variable vhNolot    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define buffer etxdt for etxdt.

    create query vhttquery.
    vhttBuffer = ghttEtxdt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttEtxdt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNotrx, output vhTpapp, output vhNoapp, output vhNolot, output vhNorol).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first etxdt exclusive-lock
                where rowid(Etxdt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer etxdt:handle, 'notrx/tpapp/noapp/nolot/norol: ', substitute('&1/&2/&3/&4', vhNotrx:buffer-value(), vhTpapp:buffer-value(), vhNoapp:buffer-value(), vhNolot:buffer-value(), vhNorol:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete etxdt no-error.
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

procedure deleteEtxdtSurContratTravaux:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContratTravaux as integer no-undo.
    
    define buffer etxdt for etxdt.

blocTrans:
    do transaction:
        for each etxdt exclusive-lock
            where etxdt.notrx = piNumeroContratTravaux:
            delete etxdt no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
