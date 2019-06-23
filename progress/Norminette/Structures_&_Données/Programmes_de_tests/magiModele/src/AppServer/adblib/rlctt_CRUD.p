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
                
            if outils:isUpdated(buffer rlctt:handle, 'tpidt/noidt/tpct1/noct1/tpct2: ', substitute('&1/&2/&3/&4/&5', vhTpidt:buffer-value(), vhNoidt:buffer-value(), vhTpct1:buffer-value(), vhNoct1:buffer-value(), vhTpct2:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.
            
            assign
                vcType1Before = rlctt.tpct1
                vcType2Before = rlctt.tpct2
            .
            
            if not outils:copyValidField(buffer rlctt:handle, vhttBuffer, "U", mtoken:cUser)
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
    define input parameter piNumeroContratMaitre as int64     no-undo.
    define input parameter pcTypeIdent           as character no-undo.
    define input parameter piNumeroIdent         as int64     no-undo.
    define input parameter piNumeroContrat       as int64     no-undo.

    define variable vcNumeroCompte     as character no-undo.
    define variable viNumeroContrat    as int64     no-undo.
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
             pas de mise a jour, seulement preparation table ttRlctt
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input-output parameter table for ttRlctt.

    define variable vcTpidtColocOuMandat as character no-undo.
    
    define buffer vbttRlctt for ttRlctt. 
    define buffer rlctt for rlctt.

    for each ttRlctt where ttRlctt.CRUD = "":
        //on regarde si lien banque existe
        find first rlctt no-lock
             where rlctt.tpidt = ttRlctt.tpidt
               and rlctt.noidt = ttRlctt.noidt
               and rlctt.tpct1 = ttRlctt.tpct1
               and rlctt.noct1 = ttRlctt.noct1
               and rlctt.tpct2 = ttRlctt.tpct2 no-error.
        if available rlctt
        then do: 
            //lien banque existe mais banque differente. Dans ce cas on supprime le lien existant car le numero est dans la cle de l'enregistrement
            if rlctt.noct2 <> ttRlctt.noct2
            then do: 
                //passage du crud a C pour creation lien avec nouvelle banque
                ttRlctt.CRUD = "C".
                //creation enregistrement ttRlctt avec crud D pour suppression du lien ancienne banque
                create vbttRlctt.
                assign
                    vbttRlctt.tpidt       = rlctt.tpidt
                    vbttRlctt.noidt       = rlctt.noidt
                    vbttRlctt.tpct1       = rlctt.tpct1
                    vbttRlctt.noct1       = rlctt.noct1
                    vbttRlctt.tpct2       = rlctt.tpct2
                    vbttRlctt.noct2       = rlctt.noct2
                    vbttRlctt.CRUD        = "D"
                    vbttRlctt.dtTimestamp = datetime(rlctt.dtmsy, rlctt.hemsy)
                    vbttRlctt.rRowid      = rowid(rlctt)
            .  
            end.
            //lien banque existe pour la meme banque, on ne fait rien
        end.
        else ttRlctt.CRUD = "C".

        if ttRlctt.Tpidt = {&TYPEROLE-coIndivisaire}
        or ttRlctt.Tpidt = {&TYPEROLE-mandant}                           //Si mandant/indivisaire, modifier banque pour l'autre role
        then do:
            vcTpidtColocOuMandat = if ttRlctt.Tpidt = {&TYPEROLE-mandant} then {&TYPEROLE-coIndivisaire} else {&TYPEROLE-mandant}.
            if can-find(first intnt no-lock
                        where intnt.tpidt = vcTpidtColocOuMandat
                          and intnt.noidt = ttRlctt.Noidt
                          and intnt.tpcon = ttRlctt.tpct1
                          and intnt.nocon = ttRlctt.noct1)
            then do:
                create vbttRlctt.
                assign
                    vbttRlctt.tpidt = vcTpidtColocOuMandat
                    vbttRlctt.noidt = ttRlctt.Noidt
                    vbttRlctt.tpct1 = ttRlctt.tpct1
                    vbttRlctt.noct1 = ttRlctt.noct1
                    vbttRlctt.tpct2 = ttRlctt.tpct2
                    vbttRlctt.noct2 = ttRlctt.noct2
                    vbttRlctt.lbdiv = ""
                .
                //on regarde si lien banque existe
                find first rlctt no-lock                     
                     where rlctt.TpIdt = vbttRlctt.TpIdt
                       and rlctt.NoIdt = vbttRlctt.NoIdt
                       and rlctt.TpCt1 = vbttRlctt.TpCt1
                       and rlctt.NoCt1 = vbttRlctt.NoCt1
                       and rlctt.tpct2 = vbttRlctt.tpct2 no-error.
                if available rlctt
                then do: 
                    //lien banque existe mais banque differente. Dans ce cas on supprime le lien existant car le numero est dans la cle de l'enregistrement
                    if rlctt.noct2 <> vbttRlctt.noct2
                    then do: 
                        //passage du crud a C pour creation lien avec nouvelle banque
                        vbttRlctt.CRUD = "C".
                        //creation enregistrement ttRlctt avec crud D pour suppression du lien ancienne banque
                        create vbttRlctt.
                        assign
                            vbttRlctt.tpidt       = rlctt.tpidt
                            vbttRlctt.noidt       = rlctt.noidt
                            vbttRlctt.tpct1       = rlctt.tpct1
                            vbttRlctt.noct1       = rlctt.noct1
                            vbttRlctt.tpct2       = rlctt.tpct2
                            vbttRlctt.noct2       = rlctt.noct2
                            vbttRlctt.CRUD        = "D"
                            vbttRlctt.dtTimestamp = datetime(rlctt.dtmsy, rlctt.hemsy)
                            vbttRlctt.rRowid      = rowid(rlctt)
                    .  
                    end.
                    //lien banque existe pour la meme banque, on ne fait rien
                end.
                else vbttRlctt.CRUD = "C".
            end.
        end.
    end.

end procedure.

procedure deleteRlcttSurTypeContratSecondaire:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeIdentifiant     as character no-undo.
    define input parameter piNumeroIdentifiant   as int64     no-undo.    
    define input parameter pcTypeContratMaitre   as character no-undo.
    define input parameter piNumeroContratMaitre as int64     no-undo.
    define input parameter pcTypeContrat         as character no-undo.
    
    define buffer rlctt for rlctt.

message "deleteRlcttSurTypeContratSecondaire " pcTypeIdentifiant "// " piNumeroIdentifiant
                      pcTypeContratMaitre "// " piNumeroContratMaitre
                      pcTypeContrat. 

blocTrans:
    do transaction:        
        for each rlctt exclusive-lock
           where rlctt.tpidt = pcTypeIdentifiant
             and rlctt.noidt = piNumeroIdentifiant
             and rlctt.tpct1 = pcTypeContratMaitre
             and rlctt.noct1 = piNumeroContratMaitre
             and rlctt.tpct2 = pcTypeContrat:   
            delete rlctt no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.            
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.

procedure deleteRlcttSurIdentifiant:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeIdentifiant   as character no-undo.
    define input parameter piNumeroIdentifiant as int64     no-undo.
    
    define buffer rlctt for rlctt.

message "deleteRlcttSurIdentifiant " pcTypeIdentifiant "// " piNumeroIdentifiant. 

blocTrans:
    do transaction:
        for each rlctt exclusive-lock
           where rlctt.tpidt = pcTypeIdentifiant
             and rlctt.noidt = piNumeroIdentifiant:
            delete rlctt no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.            
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.

procedure deleteRlcttSurContrat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.
    
    define buffer rlctt for rlctt.

message "deleteRlcttSurContrat" pcTypeContrat "// " piNumeroContrat. 

blocTrans:
    do transaction:
        for each rlctt exclusive-lock
           where rlctt.tpct2 = pcTypeContrat
             and rlctt.noct2 = piNumeroContrat:
            delete rlctt no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.            
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.

procedure deleteRlcttSurContratMaitre:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.
    
    define buffer rlctt for rlctt.

message "deleteRlcttSurContratMaitre " pcTypeContrat "// " piNumeroContrat. 

blocTrans:
    do transaction:
        for each rlctt exclusive-lock
           where rlctt.tpct1 = pcTypeContrat
             and rlctt.noct1 = piNumeroContrat:
            delete rlctt no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.            
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
