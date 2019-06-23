/*------------------------------------------------------------------------
File        : rlctt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table rlctt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/referenceClient.i}
{preprocesseur/type2role.i}

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
{adblib/include/rlctt.i}
{application/include/error.i}
define variable ghttrlctt as handle no-undo.      // le handle de la temp table à mettre à jour
define variable ghProc as handle no-undo.

function getIndexField returns logical private(phBuffer as handle, output phTpidt as handle, output phNoidt as handle, output phTpct1 as handle, output phNoct1 as handle, output phTpct2 as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpidt/noidt/tpct1/noct1/tpct2/noct2, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpidt' then phTpidt = phBuffer:buffer-field(vi).
            when 'noidt' then phNoidt = phBuffer:buffer-field(vi).
            when 'tpct1' then phTpct1 = phBuffer:buffer-field(vi).
            when 'noct1' then phNoct1 = phBuffer:buffer-field(vi).
            when 'tpct2' then phTpct2 = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudRlctt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteRlctt.
    run updateRlctt.
    run createRlctt.
end procedure.

function tracageContratBanque returns logical private(pcTpct1 as character, piNoct1 as int64):
    /*------------------------------------------------------------------------------
    Purpose: Procedure de tracage des contrats dont le lien banque a ete modifie
    Notes  : 
    ------------------------------------------------------------------------------*/
    define buffer ctrat for ctrat.

    /* Inutile de toper les contrats non transferes au DPS */
    if pcTpct1 = {&TYPECONTRAT-mandat2Gerance}  or pcTpct1 = {&TYPECONTRAT-bail}
    or pcTpct1 = {&TYPECONTRAT-mandat2Syndic}   or pcTpct1 = {&TYPECONTRAT-titre2copro}
    then for first ctrat no-lock
        where ctrat.tpcon = pcTpct1
          and ctrat.nocon = piNoct1:
        run majTrace in ghProc(integer(mToken:cRefGerance), 'sadb', 'ctrat', string(ctrat.nodoc, '>>>>>>>>9')).
    end.
end function.

procedure setRlctt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttRlctt.
    run application/transfert/GI_alimaj.p persistent set ghProc.
    run getTokenInstance in ghProc(mToken:JSessionId).
    ghttRlctt = phttRlctt.
    run crudRlctt.
    delete object phttRlctt.
    run destroy in ghProc.
end procedure.

procedure readRlctt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table rlctt 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpidt as character  no-undo.
    define input parameter piNoidt as int64      no-undo.
    define input parameter pcTpct1 as character  no-undo.
    define input parameter piNoct1 as int64      no-undo.
    define input parameter pcTpct2 as character  no-undo.
    define input parameter table-handle phttRlctt.
    define variable vhttBuffer as handle no-undo.
    define buffer rlctt for rlctt.

    vhttBuffer = phttRlctt:default-buffer-handle.
    for first rlctt no-lock
        where rlctt.tpidt = pcTpidt
          and rlctt.noidt = piNoidt
          and rlctt.tpct1 = pcTpct1
          and rlctt.noct1 = piNoct1
          and rlctt.tpct2 = pcTpct2:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer rlctt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRlctt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getRlctt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table rlctt 
    Notes  : service externe. Critère pcTpct2 = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpidt as character  no-undo.
    define input parameter piNoidt as int64      no-undo.
    define input parameter pcTpct1 as character  no-undo.
    define input parameter piNoct1 as int64      no-undo.
    define input parameter pcTpct2 as character  no-undo.
    define input parameter table-handle phttRlctt.
    define variable vhttBuffer as handle  no-undo.
    define buffer rlctt for rlctt.

    vhttBuffer = phttRlctt:default-buffer-handle.
    if pcTpct2 = ?
    then for each rlctt no-lock
        where rlctt.tpidt = pcTpidt
          and rlctt.noidt = piNoidt
          and rlctt.tpct1 = pcTpct1
          and rlctt.noct1 = piNoct1:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer rlctt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each rlctt no-lock
        where rlctt.tpidt = pcTpidt
          and rlctt.noidt = piNoidt
          and rlctt.tpct1 = pcTpct1
          and rlctt.noct1 = piNoct1
          and rlctt.tpct2 = pcTpct2:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer rlctt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRlctt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateRlctt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery     as handle    no-undo.
    define variable vhttBuffer    as handle    no-undo.
    define variable vhTpidt       as handle    no-undo.
    define variable vhNoidt       as handle    no-undo.
    define variable vhTpct1       as handle    no-undo.
    define variable vhNoct1       as handle    no-undo.
    define variable vhTpct2       as handle    no-undo.
    define variable vcType1Before as character no-undo.
    define variable vcType2Before as character no-undo.
    define buffer rlctt for rlctt.

    create query vhttquery.
    vhttBuffer = ghttRlctt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttRlctt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpidt, output vhNoidt, output vhTpct1, output vhNoct1, output vhTpct2).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first rlctt exclusive-lock
                where rowid(rlctt) = vhttBuffer::rRowid no-wait no-error.
            assign
                vcType1Before = rlctt.tpct1
                vcType2Before = rlctt.tpct2
            .
            if outils:isUpdated(buffer rlctt:handle, 'tpidt/noidt/tpct1/noct1/tpct2: ', substitute('&1/&2/&3/&4/&5', vhTpidt:buffer-value(), vhNoidt:buffer-value(), vhTpct1:buffer-value(), vhNoct1:buffer-value(), vhTpct2:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer rlctt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.

            if vcType2Before <> {&TYPECONTRAT-prive} 
            and rlctt.tpct2 = {&TYPECONTRAT-prive}    then tracageContratBanque(rlctt.tpct1, rlctt.noct1).
            if vcType1Before <> {&TYPECONTRAT-preBail}
            and rlctt.tpct1 <> {&TYPECONTRAT-preBail} then run creationCompteBancaire(rlctt.tpct1, rlctt.noct1, rlctt.tpidt, rlctt.noidt, rlctt.noct2).
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createRlctt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer rlctt for rlctt.

    create query vhttquery.
    vhttBuffer = ghttRlctt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttRlctt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create rlctt.
            if not outils:copyValidField(buffer rlctt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.

            if rlctt.tpct2 = {&TYPECONTRAT-prive}    then tracageContratBanque(rlctt.tpct1, rlctt.noct1).
            if rlctt.tpct1 <> {&TYPECONTRAT-preBail} then run creationCompteBancaire(rlctt.tpct1, rlctt.noct1, rlctt.tpidt, rlctt.noidt, rlctt.noct2).
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createRlcttPrivate private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure pour la creation d'un enregistrement dans rlctt
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ttRlctt for ttRlctt.
    define buffer rlctt for rlctt.

blocTransaction:
    do transaction:
        create rlctt.
        assign
            rlctt.TpIdt = ttRlctt.TpIdt
            rlctt.NoIdt = ttRlctt.NoIdt
            rlctt.TpCt1 = ttRlctt.TpCt1
            rlctt.NoCt1 = ttRlctt.NoCt1
            rlctt.TpCt2 = ttRlctt.TpCt2
            rlctt.NoCt2 = ttRlctt.NoCt2
            ttRlctt.rRowid = rowid(rlctt)
        no-error.
        if error-status:error then do:
            mError:createError({&error},  error-status:get-message(1)).
            undo blocTransaction, leave blocTransaction.
        end.
        if not outils:copyValidField(buffer rlctt:handle, buffer ttRlctt:handle, 'C', mtoken:cUser)
        then undo blocTransaction, leave blocTransaction.
        
        if rlctt.tpct2 = {&TYPECONTRAT-prive}    then tracageContratBanque(rlctt.tpct1, rlctt.noct1).
        if rlctt.tpct1 <> {&TYPECONTRAT-preBail} then run creationCompteBancaire(rlctt.tpct1, rlctt.noct1, rlctt.tpidt, rlctt.noidt, rlctt.noct2).
    end.
    run destroy in ghProc.

end procedure.

procedure deleteRlctt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle    no-undo.
    define variable vhttBuffer as handle    no-undo.
    define variable vhTpidt    as handle    no-undo.
    define variable vhNoidt    as handle    no-undo.
    define variable vhTpct1    as handle    no-undo.
    define variable vhNoct1    as handle    no-undo.
    define variable vhTpct2    as handle    no-undo.
    define variable vcType2    as character no-undo.
    define buffer rlctt for rlctt.

    create query vhttquery.
    vhttBuffer = ghttRlctt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttRlctt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpidt, output vhNoidt, output vhTpct1, output vhNoct1, output vhTpct2).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            vcType2 = if vhTpct2:buffer-value() > "" then vhTpct2:buffer-value() else {&TYPECONTRAT-prive}.
            find first rlctt exclusive-lock
                where rowid(Rlctt) = vhttBuffer::rRowid
                  and rlctt.tpCt2 = vcType2 no-wait no-error.
            if outils:isUpdated(buffer rlctt:handle, 'tpidt/noidt/tpct1/noct1/tpct2: ', substitute('&1/&2/&3/&4/&5', vhTpidt:buffer-value(), vhNoidt:buffer-value(), vhTpct1:buffer-value(), vhNoct1:buffer-value(), vhTpct2:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete rlctt no-error.
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


procedure creationCompteBancaire:
    /*------------------------------------------------------------------------------
    Purpose: Procedure executant la creation du compte bancaire dans arib (niveau compta)
             gga todo procedure a retester 
    Notes  : repris de adb/comm/incliadb.i   procedure CreCparib
    todo : a mettre dans arib_crud ???!!! 
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContratMaitre   as character no-undo.
    define input parameter piNumeroContratMaitre as integer   no-undo.
    define input parameter pcTypeIdent           as character no-undo.
    define input parameter piNumeroIdent         as integer   no-undo.
    define input parameter piNumeroContrat       as integer   no-undo.

    define variable vcNumeroCompte     as character no-undo.
    define variable viNumeroContrat    as integer   no-undo.
    define variable viNumeroDoc        as integer   no-undo.
    define variable viNumeroOrdre      as integer   no-undo.
    define variable vcDomicialisation1 as character no-undo.
    define variable vcDomicialisation2 as character no-undo.
    define variable viReference        as integer   no-undo.
  
    define buffer ctanx for ctanx.  
    define buffer arib  for arib.  
    
    if integer(mtoken:cRefPrincipale) = {&REFCLIENT-MANPOWER} then return.
    
    // Pas de creation de compte bancaire Compta pour les salaries ou les contrats salaries
    if pcTypeContratMaitre = {&TYPECONTRAT-Salarie}       
    or pcTypeIdent         = {&TYPEROLE-salarie}
    or pcTypeContratMaitre = {&TYPECONTRAT-SalariePegase} 
    or pcTypeIdent         = {&TYPEROLE-salariePegase}  then return.

    // Extration du mandat (etab-cd) et du compte (cpt-cd) pour arib
    viReference = integer(mtoken:cRefPrincipale). 
    case pcTypeContratMaitre:
        when {&TYPECONTRAT-mandat2Syndic}  or when {&TYPECONTRAT-titre2copro} then viReference = integer(mtoken:cRefCopro).
        when {&TYPECONTRAT-mandat2Gerance} or when {&TYPECONTRAT-bail}        then viReference = integer(mtoken:cRefGerance).
    end case.
            
    if pcTypeContratMaitre = {&TYPECONTRAT-titre2copro} or pcTypeContratMaitre = {&TYPECONTRAT-bail} 
    then viNumeroContrat = integer(substring(string(piNumeroContratMaitre,"9999999999"), 1, 5, "character")). 
    else viNumeroContrat = piNumeroContratMaitre.

    if pcTypeIdent = {&TYPEROLE-locataire}
    then vcNumeroCompte = substring(string(piNumeroIdent, "9999999999"), 6, 5, "character").
    else vcNumeroCompte = string(piNumeroIdent, "99999").

    for first ctanx no-lock
        where ctanx.tpcon = {&TYPECONTRAT-prive}
          and ctanx.nocon = piNumeroContrat:
        assign 
            vcDomicialisation1 = ctanx.lbtit
            vcDomicialisation2 = ctanx.lbdom
            viNumeroDoc        = ctanx.nodoc
        .
    end.

    do transaction: 
        find first arib exclusive-lock 
             where arib.soc-cd  = viReference     
               and arib.etab-cd = viNumeroContrat
               and arib.tprole  = integer (pcTypeIdent)
               and arib.cpt-cd  = vcNumeroCompte
               and arib.nodoc   = viNumeroDoc no-wait no-error.
        if locked arib then do:
            mError:createError({&error}, 211652, substitute("&1/&2/&3/&4", viReference, viNumeroContrat, pcTypeIdent, vcNumeroCompte)).
            return.
        end.
        if not available arib
        then do:     
            find last arib no-lock 
                where arib.soc-cd  = viReference
                  and arib.etab-cd = viNumeroContrat
                  and arib.tprole  = integer (pcTypeIdent)
                  and arib.cpt-cd  = vcNumeroCompte no-error.
            viNumeroOrdre = if available arib then arib.ordre-num + 1 else 1.
            create arib.
            assign 
                arib.soc-cd     = viReference
                arib.etab-cd    = viNumeroContrat
                arib.tprole     = integer (pcTypeIdent)
                arib.cpt-cd     = vcNumeroCompte
                arib.ordre-num  = viNumeroOrdre
                arib.nodoc      = viNumeroDoc
            .
        end.
        assign 
            arib.domicil[1] = vcDomicialisation1
            arib.domicil[2] = vcDomicialisation2
        .
    end.
end procedure.

procedure bquRlctt:
    /*------------------------------------------------------------------------------
    Purpose: Procedure pour la Mise a Jour d'une banque d'un role pour un contrat
    Notes  : service externe (gesind00.p)
    TODO   : revoir cette procédure, pas propre du tout suppression/creation au lieu de update
             une fois revue, supprimer la procédure createRlcttPrivate!!!!
    ------------------------------------------------------------------------------*/
    define input parameter table for ttRlctt.

    define variable vcAncTpidt as character no-undo.
    define buffer rlctt for rlctt.

    run application/transfert/GI_alimaj.p persistent set ghProc.
    run getTokenInstance in ghProc(mToken:JSessionId).
blocTransaction:
    do transaction:
        for each ttRlctt where ttRlctt.CRUD = 'C':
            for first rlctt exclusive-lock                                      //Suppression banque
               where rlctt.TpIdt = ttRlctt.TpIdt
                 and rlctt.NoIdt = ttRlctt.NoIdt
                 and rlctt.TpCt1 = ttRlctt.TpCt1
                 and rlctt.NoCt1 = ttRlctt.NoCt1
                 and rlctt.tpCt2 = ttRlctt.tpct2:
                delete rlctt.
            end.
            run createRlcttPrivate(buffer ttRlctt).                           //Creation banque pour ce role et ce contrat
            if can-find(first ttError where ttError.iType >= {&error})
            then undo blocTransaction, leave blocTransaction.

            if ttRlctt.Tpidt = {&TYPEROLE-coIndivisaire}
            or ttRlctt.Tpidt = {&TYPEROLE-mandant}                           //Si mandant/indivisaire, modifier banque pour l'autre role
            then do:
                assign
                    vcAncTpidt    = ttRlctt.tpidt
                    ttRlctt.tpidt = if ttRlctt.Tpidt = {&TYPEROLE-mandant} then {&TYPEROLE-coIndivisaire} else {&TYPEROLE-mandant}
                .
                if can-find(first intnt no-lock
                            where intnt.tpidt = ttRlctt.Tpidt
                              and intnt.noidt = ttRlctt.Noidt
                              and intnt.tpcon = ttRlctt.tpct1
                              and intnt.nocon = ttRlctt.noct1)
                then do:
                    for first rlctt exclusive-lock                          //suppression banque de l'autre role du contrat
                       where rlctt.TpIdt = ttRlctt.TpIdt
                         and rlctt.NoIdt = ttRlctt.NoIdt
                         and rlctt.TpCt1 = ttRlctt.TpCt1
                         and rlctt.NoCt1 = ttRlctt.NoCt1
                         and rlctt.tpct2 = ttRlctt.tpct2:
                        delete rlctt.
                    end.
                    run createRlcttPrivate(buffer ttRlctt).                  //Creation banque pour ce role et ce contrat
                    if can-find(first ttError where ttError.iType >= {&error})
                    then undo blocTransaction, leave blocTransaction.
                end.
                ttRlctt.Tpidt = vcAncTpidt.
            end.
        end.
    end.
    run destroy in ghProc.
end procedure.
