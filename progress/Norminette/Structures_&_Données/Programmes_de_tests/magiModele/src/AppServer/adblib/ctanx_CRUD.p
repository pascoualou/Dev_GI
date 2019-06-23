/*------------------------------------------------------------------------
File        : ctanx_CRUD.p
Purpose     : Librairie contenant les procedures liees a la maj de la table ctanx
Author(s)   : GGA 2017/11/13
Notes       : repris depuis adb/lib/l_ctanx.p (et seulement les procedures utilisees)
derniere revue: 2018/04/27 - phm: KO
         trop de code en commentaire.
         traiter les todo
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}

{oerealm/include/instanciateTokenOnModel.i}        // Doit être positionnée juste après using
define variable ghttctanx      as handle no-undo.  // le handle de la temp table à mettre à jour
define variable ghProcGIAlimaj as handle no-undo.  // pour tracer les MàJ banque

function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nodoc, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
       end case.
    end.
end function.
function getNumeroDocumentField returns handle private(phBuffer as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nodoc, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        if phBuffer:buffer-field(vi):label = 'nodoc'
        then return phBuffer:buffer-field(vi).
    end.
    return ?.
end function.

procedure crudCtanx private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCtanx.
    run updateCtanx.
    run createCtanx.
end procedure.

procedure setCtanx:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCtanx.
    ghttCtanx = phttCtanx.
    run crudCtanx.
    if valid-handle(ghProcGIAlimaj) then run destroy in ghProcGIAlimaj.
    delete object phttCtanx.
end procedure.

procedure readCtanx:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement contrat annexe
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter table-handle phttCtanx.

    define variable vhttBuffer as handle no-undo.
    define buffer ctanx for ctanx.

    vhttBuffer = phttCtanx:default-buffer-handle.
    for first ctanx no-lock
        where ctanx.tpcon = pcTypeContrat
          and ctanx.nocon = piNumeroContrat:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ctanx:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCtanx no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCtanx:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table des contrats annexes
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat as character no-undo.
    define input  parameter pcTypeRole    as character no-undo.
    define input  parameter piNumeroRole  as integer   no-undo.
    define input  parameter table-handle phttCtanx.

    define variable vhttBuffer as handle  no-undo.

    vhttBuffer = phttCtanx:default-buffer-handle.
    if piNumeroRole = ?
    then for each ctanx no-lock
        where ctanx.tpcon = pcTypeContrat
          and ctanx.tprol = pcTypeRole:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ctanx:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ctanx no-lock
        where ctanx.tpcon = pcTypeContrat
          and ctanx.tprol = pcTypeRole
          and ctanx.norol = piNumeroRole:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ctanx:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCtanx no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCtanx private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure pour la mise a jour de la table ctanx
    Notes  : 
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define buffer ctanx for ctanx.

    create query vhttquery.
    vhttBuffer = ghttCtanx:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCtanx:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            run modifSepa(vhttBuffer).
            find first ctanx exclusive-lock
                where rowid(ctanx) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ctanx:handle, 'tpcon/nocon: ', substitute('&1/&2', vhTpcon:buffer-value(), vhNocon:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ctanx:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.

            run traceMajBanque(ctanx.tpcon, ctanx.nocon). 
            if mError:erreur() then undo blocTrans, leave blocTrans. 
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCtanx:
    /*------------------------------------------------------------------------------
    Purpose: Procedure pour la creation dans la table ctanx
    Notes  : 
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNodoc    as handle  no-undo.
    define buffer ctanx for ctanx.

    create query vhttquery.
    vhttBuffer = ghttCtanx:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCtanx:name)).
    vhttquery:query-open().

    vhNodoc = getNumeroDocumentField(vhttBuffer).
    if valid-handle(vhNodoc) then
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            run modifSepa(vhttBuffer).
            if vhNodoc:buffer-value() = ? then do:
                find last ctanx no-lock no-error.
                vhNodoc:buffer-value() = if available ctanx then ctanx.nodoc + 1 else 1.
            end.
            create ctanx.
            if not outils:copyValidField(buffer ctanx:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.

            run traceMajBanque(ctanx.tpcon, ctanx.nocon). 
            if mError:erreur() then undo blocTrans, leave blocTrans. 
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCtanx private:
    /*------------------------------------------------------------------------------
    Purpose: suppression des liens rubriques provision - cle de repartition
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define buffer ctanx for ctanx.

    create query vhttquery.
    vhttBuffer = ghttCtanx:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCtanx:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ctanx exclusive-lock
                where rowid(Ctanx) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ctanx:handle, 'tpcon/nocon: ', substitute('&1/&2', vhTpcon:buffer-value(), vhNocon:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ctanx no-error.
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

procedure modifSepa private:
    /*------------------------------------------------------------------------------
    Purpose: ibantorib
    Notes  : On fait un mapping de champ sur label 
    ------------------------------------------------------------------------------*/
    define input parameter phBuffer as handle no-undo.

    define variable vcTpcon as character no-undo.
    define variable vcTprol as character no-undo.
    define variable vhIban  as handle    no-undo.
    define variable vhCdbqu as handle    no-undo.
    define variable vhCdqui as handle    no-undo.
    define variable vhNocpt as handle    no-undo.
    define variable vhNorib as handle    no-undo.
    define variable vcIban  as character no-undo.
    define variable vi      as integer   no-undo.

    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpcon' then vcTpcon = phBuffer:buffer-field(vi):buffer-value().
            when 'tprol' then vcTprol = phBuffer:buffer-field(vi):buffer-value().
            when 'iban'  then vcIban  = phBuffer:buffer-field(vi):buffer-value().
            when 'cdbqu' then vhCdbqu = phBuffer:buffer-field(vi).
            when 'cdqui' then vhCdqui = phBuffer:buffer-field(vi).
            when 'nocpt' then vhNocpt = phBuffer:buffer-field(vi).
            when 'norib' then vhNorib = phBuffer:buffer-field(vi).
       end case.
    end.
    if vcIban > "" and vcTpcon = {&TYPECONTRAT-prive} and vcTprol = "99999"
    and valid-handle(vhCdbqu)
    and valid-handle(vhCdqui)
    and valid-handle(vhNocpt)
    and valid-handle(vhNorib) then do:                             /* Seulement pour les coord. bancaires */
        if can-do("FR*,MC*", vcIban)                               /* + "MC" = Monaco 0312/0118 */
        then assign
            vhCdbqu:buffer-value() = substring(vcIban, 5, 5, "character")
            vhCdqui:buffer-value() = substring(vcIban, 10, 5, "character")
            vhNocpt:buffer-value() = substring(vcIban, 15, 11, "character")
            vhNorib:buffer-value() = integer(substring(vcIban, 26, 2, "character"))
        .
        else assign
            vhCdbqu:buffer-value() = ?
            vhCdqui:buffer-value() = ?
            vhNocpt:buffer-value() = ?
            vhNorib:buffer-value() = ?
        .
    end.

end procedure.

procedure traceMajBanque private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de tracage des contrats dont le lien banque a ete modifie
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter piNumeroContrat as int64     no-undo.

    define buffer rlctt for rlctt.
    define buffer ctrat for ctrat.

    for each rlctt no-lock
        where rlctt.tpct2 = pcTypeContrat
          and rlctt.noct2 = piNumeroContrat
      , first ctrat no-lock 
        where ctrat.tpcon = rlctt.tpct1
          and ctrat.nocon = rlctt.noct1
        break by rlctt.tpidt by rlctt.noidt:
            //  TODO   pourquoi le first-of serait sur l'un des quatre rlctt.tpct1 cités ????
        if first-of(rlctt.noidt) 
        and (rlctt.tpct1 = {&TYPECONTRAT-mandat2Gerance}    /* Inutile de toper les contrats non transférés au DPS */
          or rlctt.tpct1 = {&TYPECONTRAT-bail}
          or rlctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
          or rlctt.tpct1 = {&TYPECONTRAT-titre2copro})
        then do:
            if not valid-handle(ghProcGIAlimaj) then do:
                // on lance ghProcGIAlimaj le plus tard possible. Effacer dans setCtanx.
                run application/transfert/GI_alimaj.p persistent set ghProcGIAlimaj.
                run getTokenInstance in ghProcGIAlimaj(mToken:JSessionId).
            end.
            run majTrace in ghProcGIAlimaj(integer(mToken:cRefGerance), 'sadb', 'ctrat', string(ctrat.nodoc, '>>>>>>>>9')).
        end.
    end.

end procedure.

procedure getListeContratAnnexe:
    /*------------------------------------------------------------------------------
      Purpose: Procedure qui retourne la liste des Comptes bancaires d'un Role-Tiers. 
               sous la forme "Type contrat-Numéro contrat,..."
      Notes: ex trfmajbqu
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat      as character no-undo.
    define input  parameter pcTypeRole         as character no-undo.
    define input  parameter piNumeroRole       as integer   no-undo.
    define output parameter pcListeBanqueTiers as character no-undo.
    define buffer ctanx for ctanx.

    for each ctAnx no-lock
        where ctanx.tpcon = pcTypeContrat
          and ctanx.tprol = pcTypeRole
          and ctanx.norol = piNumeroRole:
        pcListeBanqueTiers  = substitute('&1-&2,&3', pcListeBanqueTiers, ctanx.tpcon, ctanx.nocon).
    end.
    pcListeBanqueTiers = trim(pcListeBanqueTiers, "-").

end procedure.

/*gga
/* ***************************  Definitions  ************************** */
PROCEDURE BdfCtanx :
    /*------------------------------------------------------------------------------
    Purpose: récupère le compte bancaire par défaut d'un Tiers (ou le premier si pas de compte par défaut)
    Notes:
    ------------------------------------------------------------------------------*/
 /* Recuperation des Paramètres transmis.         */
 RUN RecIntIdt (1, OUTPUT Ch_TpCon).
 RUN RecIntIdt (2, OUTPUT Ch_TpRol).
 RUN RecIntIdt (3, OUTPUT LbTmpPdt).
 ASSIGN Ch_NoRol        = INTEGER (LbTmpPdt).

 /* Lecture de la table des contrats annexes     */
 FIND FIRST ctanx
     WHERE ctanx.tpcon = Ch_TpCon
         AND ctanx.tprol = Ch_TpRol
         AND ctanx.norol = Ch_NoRol
         AND ctanx.tpact = "DEFAU"
     NO-LOCK NO-ERROR.

 IF NOT AVAILABLE ctanx THEN DO:
     FIND FIRST ctanx
         WHERE ctanx.tpcon = Ch_TpCon
             AND ctanx.tprol = Ch_TpRol
             AND ctanx.norol = Ch_NoRol
         NO-LOCK NO-ERROR.
     IF NOT AVAILABLE ctanx THEN DO:
         RUN AffIntIdt (1, "0").                /* Pas Trouvé. */
         RETURN.
     END.
 END.
END PROCEDURE.

gg*/

