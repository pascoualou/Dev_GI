/*------------------------------------------------------------------------
File        : tacheEmpruntISF.p
Purpose     : tache Emprunt ISF
Author(s)   : DM 20180111
Notes       : a partir de adb/tach/PrmBxEmp.p
------------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
{preprocesseur/type2honoraire.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/nature2contrat.i}

using parametre.syspg.syspg.
using parametre.syspr.syspr.
using parametre.syspg.parametrageTache.
using parametre.pclie.parametrageDefautMandat.
using parametre.pclie.parametrageISF.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/combo.i}
{application/include/glbsepar.i}
{tache/include/tacheEmpruntISF.i}
{tache/include/empruntISFAnnee.i}
{tache/include/tache.i}
{adblib/include/cttac.i}
{application/include/error.i}

procedure majTache private:
    /*------------------------------------------------------------------------------
    Purpose: maj en base de la tache emprunt ISF
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ttTacheEmpruntISF for ttTacheEmpruntISF.
    define parameter buffer ctrat      for ctrat.

    define variable vhProctache     as handle    no-undo.
    define variable vhProccttac     as handle    no-undo.
    define variable vcDetailEmprunt as character no-undo.

    define buffer cttac for cttac.
    define buffer tache for tache.

    empty temp-table ttTache.
    empty temp-table ttCttac.

    run tache/tache.p persistent set vhProctache.
    run getTokenInstance in vhProctache(mToken:JSessionId).
    run adblib/cttac_CRUD.p persistent set vhProccttac.
    run getTokenInstance in vhProccttac(mToken:JSessionId).

bloc :
    do :
        for each ttEmpruntISFAnnee
            where ttEmpruntISFAnnee.cTypeContrat   = ttTacheEmpruntISF.cTypeContrat
              and ttEmpruntISFAnnee.iNumeroContrat = ttTacheEmpruntISF.iNumeroContrat
              and ttEmpruntISFAnnee.iNumeroTache   = ttTacheEmpruntISF.iNumeroTache :
            vcDetailEmprunt = substitute("&1&2@&3@&4@&5"
                                , vcDetailEmprunt
                                , string(ttEmpruntISFAnnee.iAnnee)
                                , string(ttEmpruntISFAnnee.dRemboursement * 100)
                                , string(ttTacheEmpruntISF.dSoldeFin1997 * 100)
                                , string(ttEmpruntISFAnnee.dInteret * 100))
                                + "&" // Caractère & invalide dans un substitute
                                .
        end.
        vcDetailEmprunt = trim(vcDetailEmprunt,"&").
        create ttTache.
        assign
            ttTache.noita       = ttTacheEmpruntISF.iNumeroTache
            ttTache.tpcon       = ttTacheEmpruntISF.cTypeContrat
            ttTache.nocon       = ttTacheEmpruntISF.iNumeroContrat
            ttTache.tptac       = {&TYPETACHE-empruntISF}
            ttTache.dtdeb       = ttTacheEmpruntISF.daEmprunt
            ttTache.ntreg       = ttTacheEmpruntISF.cNumeroEmprunt
            ttTache.pdreg       = ttTacheEmpruntISF.cLibelleEmprunt
            ttTache.mtreg       = ttTacheEmpruntISF.dCapitalInitial
            ttTache.lbdiv       = vcDetailEmprunt
            ttTache.CRUD        = ttTacheEmpruntISF.CRUD
            ttTache.dtTimestamp = ttTacheEmpruntISF.dtTimestamp
            ttTache.rRowid      = ttTacheEmpruntISF.rRowid
        .
        run setTache in vhProctache(table ttTache by-reference).
        if mError:erreur() then leave bloc.

        // Suppression du lien cttac si aucun emprunt
        find first cttac no-lock
             where cttac.tpcon = ttTacheEmpruntISF.cTypeContrat
               and cttac.nocon = ttTacheEmpruntISF.iNumeroContrat
               and cttac.tptac = {&TYPETACHE-empruntISF}
               no-error.
        find first tache no-lock
            where tache.tpcon = {&TYPECONTRAT-mandat2Gerance}
              and tache.nocon = ttTacheEmpruntISF.iNumeroContrat
              and tache.tptac = {&TYPETACHE-empruntISF}
              no-error.
        if available cttac and ttTacheEmpruntISF.CRUD = "D"
        then do:
            if not available tache then do :
                empty temp-table ttcttac.
                create ttcttac.
                assign
                    ttcttac.tpcon = cttac.tpcon
                    ttcttac.nocon = cttac.nocon
                    ttcttac.tptac = cttac.tptac
                    ttcttac.CRUD  = "D"
                    ttCttac.rRowid      = rowid(cttac)
                    ttcttac.dtTimestamp = datetime(cttac.dtmsy, cttac.hemsy)
                .
                run setCttac in vhProccttac(table ttcttac by-reference).
                if mError:erreur() then leave bloc.
            end.
        end.
        else if not available cttac and lookup(ttTacheEmpruntISF.CRUD,"C,U") > 0
        then do:
            empty temp-table ttcttac.
            create ttcttac.
            assign
                ttcttac.tpcon = ttTacheEmpruntISF.cTypeContrat
                ttcttac.nocon = ttTacheEmpruntISF.iNumeroContrat
                ttcttac.tptac = {&TYPETACHE-empruntISF}
                ttcttac.CRUD  = "C"
            .
            run setCttac in vhProccttac(table ttcttac by-reference).
            if mError:erreur() then leave bloc.
        end.
        if lookup(ttTacheEmpruntISF.CRUD,"C,U") > 0
        then for first tache no-lock
             where tache.tpcon = ttTacheEmpruntISF.cTypeContrat
               and tache.nocon = ttTacheEmpruntISF.iNumeroContrat
               and tache.tptac = {&TYPETACHE-empruntISF}
               and tache.ntreg = ttTacheEmpruntISF.cNumeroEmprunt :
            for each ttEmpruntISFAnnee
                where ttEmpruntISFAnnee.cTypeContrat   = ttTacheEmpruntISF.cTypeContrat
                  and ttEmpruntISFAnnee.iNumeroContrat = ttTacheEmpruntISF.iNumeroContrat
                  and ttEmpruntISFAnnee.iNumeroTache   = ttTacheEmpruntISF.iNumeroTache :
                ttEmpruntISFAnnee.iNumeroTache = tache.noita.
            end.                                      
            assign
                ttTacheEmpruntISF.iNumeroTache = tache.noita
            .
        end.                
        
    end.
    run destroy in vhProctache.
    run destroy in vhProccttac.

end procedure.

procedure setEmpruntISF:
    /*------------------------------------------------------------------------------
    Purpose: maj tache
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input-output parameter table for ttTacheEmpruntISF.
    define input-output parameter table for ttEmpruntISFAnnee.

    define buffer tache for tache.
    define buffer ctrat for ctrat.

BoucleEmprunt :
    for each ttTacheEmpruntISF
    where lookup(ttTacheEmpruntISF.CRUD, "C,U,D") > 0:
        find first ctrat no-lock
             where ctrat.tpcon = ttTacheEmpruntISF.cTypeContrat
               and ctrat.nocon = ttTacheEmpruntISF.iNumeroContrat no-error.
        if not available ctrat
        then do:
            mError:createError({&error}, 100057).
            leave BoucleEmprunt.
        end.
        find last tache no-lock
        where tache.tpcon = ttTacheEmpruntISF.cTypeContrat
          and tache.nocon = ttTacheEmpruntISF.iNumeroContrat
          and tache.noita = ttTacheEmpruntISF.iNumeroTache
          and tache.tptac = {&TYPETACHE-empruntISF} no-error.
        if not available tache
        and lookup(ttTacheEmpruntISF.CRUD, "U,D") > 0
        then do:
            mError:createError({&error}, "modification d'une tache inexistante").
            leave BoucleEmprunt.
        end.
        run controleEntete.
        if mError:erreur() then leave BoucleEmprunt.
        if lookup(ttTacheEmpruntISF.crud,"C,U") > 0 then do :
            find first ttEmpruntISFAnnee
                where ttEmpruntISFAnnee.cTypeContrat   = ttTacheEmpruntISF.cTypeContrat
                  and ttEmpruntISFAnnee.iNumeroContrat = ttTacheEmpruntISF.iNumeroContrat
                  and ttEmpruntISFAnnee.iNumeroTache   = ttTacheEmpruntISF.iNumeroTache
                  no-error.
            if not available ttEmpruntISFAnnee then do:
                mError:createError({&error}, 1000522). // 1000522 "Le tableau n'est pas renseigné"
                leave BoucleEmprunt.
            end.
        end.
        run majTache (buffer ttTacheEmpruntISF, buffer ctrat).
        if mError:erreur() then leave BoucleEmprunt.
    end.
    if mError:erreur() 
    then do :
        empty temp-table ttTacheEmpruntISF.
        empty temp-table ttEmpruntISFAnnee.
    end.        
    else for first ttTacheEmpruntISF where lookup(ttTacheEmpruntISF.CRUD, "C,U") > 0: // Recharger les infos de l'emprunt créé ou modifié
        run getEmpruntISF(ttTacheEmpruntISF.iNumeroContrat, ttTacheEmpruntISF.cTypeContrat, ?, ttTacheEmpruntISF.iNumeroTache, output table ttTacheEmpruntISF, output table ttEmpruntISFAnnee).
    end.                
end procedure.

procedure verEmpruntISF :
    /*------------------------------------------------------------------------------
    Purpose: controle l'entete de l'emprunt
    Notes  : Service appelé par beMandatGerance.cls
    ------------------------------------------------------------------------------*/
    define input parameter table for ttTacheEmpruntISF.

    for each ttTacheEmpruntISF where lookup(ttTacheEmpruntISF.crud,"C,U") > 0 :
        run controleEntete.
        if merror:erreur() then return.

    end.
end procedure.

procedure controleEntete private :
    /*------------------------------------------------------------------------------
    Purpose: controle l'entete de l'emprunt
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer tache for tache.

    if ttTacheEmpruntISF.cNumeroEmprunt = "" then do:
        mError:createError({&error}, 1000520). // 1000520 Le code emprunt ISF n'est pas renseigné
        return.

    end.
    if ttTacheEmpruntISF.daEmprunt = ? then do:
        mError:createError({&error}, 102296). // La saisie de la date est obligatoire
        return.

    end.
    if ttTacheEmpruntISF.dCapitalInitial = 0 then do:
       mError:createError({&error}, 1000521). // Le capital initial n'est pas renseigné
       return.

    end.
    if ttTacheEmpruntISF.dCapitalInitial < ttTacheEmpruntISF.dSoldeFin1997 then do:
       mError:createError({&error}, 104471). // Le Capital initial ne peut être inférieur au solde 1997
       return.

    end.
    if ttTacheEmpruntISF.crud = "C" then do:
        for first tache no-lock
         where tache.tpcon = ttTacheEmpruntISF.cTypeContrat
           and tache.nocon = ttTacheEmpruntISF.iNumeroContrat
           and tache.tptac = {&TYPETACHE-empruntISF}
           and tache.ntreg = ttTacheEmpruntISF.cNumeroEmprunt :
            mError:createError({&error}, 1000523, ttTacheEmpruntISF.cNumeroEmprunt). // 1000523 "L'emprunt &1 existe déjà"
            return.

        end.
    end.
end procedure.

procedure getEmpruntISF:
    /*------------------------------------------------------------------------------
    Purpose: Extraction des emprunts
    Notes  : service externe (beMandatGerance.cls) et tacheISF.p
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroContrat as int64     no-undo.
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter piAnnee         as integer   no-undo.
    define input  parameter viNumeroTache   as integer   no-undo.

    define output parameter table for ttTacheEmpruntISF.
    define output parameter table for ttEmpruntISFAnnee.

    define variable vdCapitalDebut       as decimal no-undo.
    define variable vd1erCapitalDebut    as decimal no-undo.
    define variable vdDernCapitalFin     as decimal no-undo.
    define variable vdRemboursementAnnee as decimal no-undo.
    define variable vdRemboursementTotal as decimal no-undo.
    define variable vdCapitalFin    as decimal no-undo.
    define variable viAnnee         as integer no-undo.
    define variable vlAnnee         as logical no-undo.
    define variable viI1 as integer no-undo.

    define buffer ctrat for ctrat.
    define buffer tache for tache.

    empty temp-table ttTacheEmpruntISF.
    empty temp-table ttEmpruntISFAnnee.

    for first ctrat no-lock
         where ctrat.tpcon = pcTypeContrat
           and ctrat.nocon = piNumeroContrat,
         each tache no-lock
         where tache.tpcon = ctrat.tpcon
           and tache.nocon = ctrat.nocon
           and tache.tptac = {&TYPETACHE-empruntISF}
           and (if viNumeroTache > 0 then tache.noita = viNumeroTache else true) :
               
        if tache.lbdiv <> ""
        then vdCapitalDebut = if integer(entry(3,entry(1,tache.lbdiv,"&"),"@")) = 0
                           then tache.mtreg
                           else integer(entry(3,entry(1,tache.lbdiv,"&"),"@")) / 100.
        else vdCapitalDebut = tache.mtreg.

        assign
            vdRemboursementTotal = 0
            vd1erCapitalDebut    = ?
            vdDernCapitalFin     = ?
            vlAnnee              = false
        .
        do viI1 = 1 to num-entries(tache.lbdiv,"&"):
            assign
                vdRemboursementAnnee = integer(entry(2,entry(viI1,tache.lbdiv,"&"),"@")) / 100
                viAnnee              = integer(entry(1,entry(viI1,tache.lbdiv,"&"),"@"))
            .                

            if piAnnee = 0 or piAnnee = ? or piAnnee = viAnnee then do :
                create ttEmpruntISFAnnee.
                assign
                    vlAnnee                           = true
                    ttEmpruntISFAnnee.cTypeContrat    = tache.tpcon
                    ttEmpruntISFAnnee.iNumeroContrat  = tache.nocon
                    ttEmpruntISFAnnee.iNumeroTache    = tache.noita
                    ttEmpruntISFAnnee.iAnnee          = viAnnee
                    ttEmpruntISFAnnee.dCapitalDebut   = vdCapitalDebut
                    ttEmpruntISFAnnee.dInteret        = integer(entry(4,entry(viI1,tache.lbdiv,"&"),"@")) / 100
                    ttEmpruntISFAnnee.dRemboursement  = vdRemboursementAnnee
                    ttEmpruntISFAnnee.dCapitalFin     = vdCapitalDebut - vdRemboursementAnnee
                    vd1erCapitalDebut                 = ttEmpruntISFAnnee.dCapitalDebut when vd1erCapitalDebut = ?
                    vdDernCapitalFin                  = ttEmpruntISFAnnee.dCapitalFin
                    vdRemboursementTotal              = vdRemboursementTotal + vdRemboursementAnnee
                .
            end.
            vdCapitalDebut = vdCapitalDebut - vdRemboursementAnnee.
        end.
        if piAnnee > 0 and not vlannee then next. // si une année demandée et pas de détail par année -> on ne garde pas
        create ttTacheEmpruntISF.
        assign
            ttTacheEmpruntISF.cTypeContrat    = tache.tpcon
            ttTacheEmpruntISF.iNumeroContrat  = tache.nocon
            ttTacheEmpruntISF.iNumeroTache    = tache.noita
            ttTacheEmpruntISF.cNumeroEmprunt  = tache.ntreg
            ttTacheEmpruntISF.cLibelleEmprunt = tache.pdreg
            ttTacheEmpruntISF.daEmprunt       = tache.dtdeb
            ttTacheEmpruntISF.dCapitalInitial = tache.mtreg
            ttTacheEmpruntISF.dSoldeFin1997   = integer(entry(3,entry(1,tache.lbdiv,"&"),"@")) / 100
            ttTacheEmpruntISF.dCapitalDebut   = vd1erCapitalDebut
            ttTacheEmpruntISF.dRemboursement  = vdRemboursementTotal
            ttTacheEmpruntISF.dCapitalFin     = vdDernCapitalFin
            ttTacheEmpruntISF.dtTimestamp     = datetime(tache.dtmsy, tache.hemsy)
            ttTacheEmpruntISF.CRUD            = 'R'
            ttTacheEmpruntISF.rRowid          = rowid(tache)
        .
    end.
end procedure.

procedure initComboEmpruntISF:
    /*------------------------------------------------------------------------------
    Purpose: Contenu des combos
    Notes  : Service appelé par beMandatGerance.cls
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroContrat as int64     no-undo.
    define input  parameter pcTypeContrat   as character no-undo.

    define output parameter table for ttCombo.

    run chargeCombo(piNumeroContrat, pcTypeContrat).
end procedure.

procedure chargeCombo private:
    /*------------------------------------------------------------------------------
    Purpose: Chargement des combos
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroContrat as int64     no-undo.
    define input  parameter pcTypeContrat   as character no-undo.

    define variable voSyspg    as class syspg no-undo.
    define variable vcLstAnnee as character   no-undo.
    define variable vcAnnee    as character   no-undo.
    define variable viI1       as integer     no-undo.

    define buffer ctrat for ctrat.
    define buffer tache for tache.

    empty temp-table ttCombo.
    voSyspg = new syspg().
    for first  ctrat no-lock
         where ctrat.tpcon = pcTypeContrat
           and ctrat.nocon = piNumeroContrat,
         each  tache no-lock
         where tache.tpcon = ctrat.tpcon
           and tache.nocon = ctrat.nocon
           and tache.tptac = {&TYPETACHE-empruntISF} :
        do viI1 = 1 to num-entries(tache.lbdiv,"&"):
            vcAnnee = entry(1,entry(viI1,tache.lbdiv,"&"),"@").
            if vcAnnee > "" and lookup(vcAnnee, vcLstAnnee) = 0
            then do :
                voSyspg:creationttCombo("CMBANNEEEMPRUNTISF", vcAnnee, vcAnnee, output table ttCombo by-reference).
                vcLstAnnee = vcLstAnnee + "," + vcAnnee.
            end.
        end.
    end.
    delete object voSyspg.
end procedure.

procedure initAnneeEmprunt:
    /*------------------------------------------------------------------------------
    Purpose: Initialisation creation annee
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input-output parameter table for ttTacheEmpruntISF.
    define input-output parameter table for ttEmpruntISFAnnee.
    define input parameter        table for ttError. // Questionnaire

    define buffer bttEmpruntISFAnnee for ttEmpruntISFAnnee.

    define variable vlPasse           as logical no-undo.
    define variable vdMtRemboursement as decimal no-undo.
    define variable viAnnee           as integer no-undo.
    define variable vdMontant         as decimal no-undo.
    define variable viI1              as integer no-undo.
    define variable viReponse         as integer no-undo.

    define buffer ctrat     for ctrat.
    define buffer cecrlnana for cecrlnana.

    for first ttTacheEmpruntISF :
        find first ctrat no-lock
             where ctrat.tpcon = ttTacheEmpruntISF.cTypeContrat
               and ctrat.nocon = ttTacheEmpruntISF.iNumeroContrat
               no-error.
        if not available ctrat
        then do:
            mError:createError({&error}, 100057).
            return.

        end.
        run controleEntete.
        if merror:erreur() then return.
        find last bttEmpruntISFAnnee
        where bttEmpruntISFAnnee.cTypeContrat   = ttTacheEmpruntISF.cTypeContrat
          and bttEmpruntISFAnnee.iNumeroContrat = ttTacheEmpruntISF.iNumeroContrat
          and bttEmpruntISFAnnee.iNumeroTache   = ttTacheEmpruntISF.iNumeroTache
          no-lock no-error.
        if not available bttEmpruntISFAnnee or (available bttEmpruntISFAnnee and bttEmpruntISFAnnee.dCapitalFin > 0)
        then do:
            if available bttEmpruntISFAnnee
                then assign viAnnee = (bttEmpruntISFAnnee.iAnnee + 1).
                else assign viAnnee = (if year(ttTacheEmpruntISF.daEmprunt) < 1998 then 1998 else year(ttTacheEmpruntISF.daEmprunt)).
            vdMtRemboursement = 0.
            vlPasse = false.
            for each cecrlnana no-lock
                where cecrlnana.soc-cd     = integer(mtoken:cRefGerance)
                  and cecrlnana.etab-cd    = ttTacheEmpruntISF.iNumeroContrat
                  and cecrlnana.sscoll-cle = "M"
                  and cecrlnana.cpt-cd     begins "00000"
                  and cecrlnana.ana1-cd    = "140"
                  and cecrlnana.ana2-cd    = "650"
                  and cecrlnana.ana1-cd    <> "999"
                  and not cecrlnana.jou-cd begins "AN"
                  and cecrlnana.type-cle   <> "ODCP2"
                  and cecrlnana.type-cle   <> "ODCOP"
                  and cecrlnana.dacompta   >= DATE("01/01/" + string(viAnnee))
                  and cecrlnana.dacompta   <= DATE("31/12/" + string(viAnnee)) :
                vdMtRemboursement = vdMtRemboursement + (cecrlnana.mt * if cecrlnana.sens then 1 else -1). // On cumule
                vlPasse = true.
            end.
            if vlPasse = false then do : // Pas d'analytique en compta
                if available bttEmpruntISFAnnee
                then vdMtRemboursement = if bttEmpruntISFAnnee.dCapitalFin - bttEmpruntISFAnnee.dRemboursement < 0
                                            then bttEmpruntISFAnnee.dCapitalFin
                                            else bttEmpruntISFAnnee.dRemboursement.
                else vdMtRemboursement = 0.
            end.
            create ttEmpruntISFAnnee.
            assign
                ttEmpruntISFAnnee.cTypeContrat   = ttTacheEmpruntISF.cTypeContrat
                ttEmpruntISFAnnee.iNumeroContrat = ttTacheEmpruntISF.iNumeroContrat
                ttEmpruntISFAnnee.iNumeroTache   = ttTacheEmpruntISF.iNumeroTache
                ttEmpruntISFAnnee.iNumeroContrat = ttTacheEmpruntISF.iNumeroContrat
                ttEmpruntISFAnnee.iAnnee         = viAnnee
                ttEmpruntISFAnnee.dInteret       = 0
            .
            if ttTacheEmpruntISF.crud = "R" then ttTacheEmpruntISF.crud = "U".
            if available bttEmpruntISFAnnee
            then assign ttEmpruntISFAnnee.dCapitalDebut = bttEmpruntISFAnnee.dCapitalFin. // Si un enregistrement existe déja
            else assign ttEmpruntISFAnnee.dCapitalDebut = if year(ttTacheEmpruntISF.daEmprunt) < 1998 // si la table est vide au départ
                                                            then ttTacheEmpruntISF.dSoldeFin1997
                                                            else ttTacheEmpruntISF.dCapitalInitial
                 .
            if ttEmpruntISFAnnee.dCapitalDebut >= vdMtRemboursement
            then assign
                    ttEmpruntISFAnnee.dRemboursement  = vdMtRemboursement
                    ttEmpruntISFAnnee.dCapitalFin = ttEmpruntISFAnnee.dCapitalDebut - ttEmpruntISFAnnee.dRemboursement
                 .
            else do:
                viReponse = outils:questionnaire(1000724, string(ttTacheEmpruntISF.iNumeroContrat), table ttError by-reference). // 1000724 "Le remboursement du Mandat &1 dépasse le restant dû. Voulez augmenter le capital initial ou diminuer le montant du remboursement ?"
                if viReponse < 2 then return.
                // On met à jour le montant de remboursement
                if viReponse = 2 then do: // Répondu non à la question (=diminuer)
                    assign
                        ttEmpruntISFAnnee.dRemboursement = ttEmpruntISFAnnee.dCapitalDebut
                        ttEmpruntISFAnnee.dCapitalFin    = 0
                    .
                end.
                // On met à jour le montant initial sur tous les enregistrements
                else do :
                    for each ttEmpruntISFAnnee
                    where ttEmpruntISFAnnee.cTypeContrat   = ttTacheEmpruntISF.cTypeContrat
                      and ttEmpruntISFAnnee.iNumeroContrat = ttTacheEmpruntISF.iNumeroContrat
                      and ttEmpruntISFAnnee.iNumeroTache   = ttTacheEmpruntISF.iNumeroTache
                    by ttEmpruntISFAnnee.iAnnee descending:
                       if viI1 = 0 then do:
                           assign
                                vdMontant = vdMtRemboursement
                                ttEmpruntISFAnnee.dCapitalDebut  = vdMtRemboursement
                                ttEmpruntISFAnnee.dRemboursement = vdMtRemboursement
                                ttEmpruntISFAnnee.dCapitalFin    = 0
                                viI1 = viI1 + 1
                           .
                           next.
                       end.
                       assign
                           ttEmpruntISFAnnee.dCapitalFin   = vdMontant
                           ttEmpruntISFAnnee.dCapitalDebut = ttEmpruntISFAnnee.dRemboursement  +  ttEmpruntISFAnnee.dCapitalFin
                           vdMontant                       =  ttEmpruntISFAnnee.dCapitalDebut
                           viI1 = viI1 + 1
                        .
                       if ttEmpruntISFAnnee.iAnnee = 1998 then leave.
                    end.
                    for each ttEmpruntISFAnnee
                    where ttEmpruntISFAnnee.cTypeContrat   = ttTacheEmpruntISF.cTypeContrat
                      and ttEmpruntISFAnnee.iNumeroContrat = ttTacheEmpruntISF.iNumeroContrat
                      and ttEmpruntISFAnnee.iNumeroTache   = ttTacheEmpruntISF.iNumeroTache
                       by ttEmpruntISFAnnee.iAnnee :
                        if ttTacheEmpruntISF.dCapitalInitial < ttEmpruntISFAnnee.dCapitalDebut
                        then ttTacheEmpruntISF.dCapitalInitial = ttEmpruntISFAnnee.dCapitalDebut.
                        leave. // sortie à la 1ere occurence
                    end.
                end.
            end.
        end.
    end.
end.