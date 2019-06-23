/*------------------------------------------------------------------------
File      : ctrconvm.p
Purpose   : Module de controle autorisation de convertir un mandat en une autre nature de mandat
Author(s) : GGA - 2017/09/21
Notes     : reprise adb/lib/ctrconvm.p
01  14/02/2002  SY    Correction mauvais code retour quant tout OK
02  21/02/2002  SY    Vu avec JPM: Pb confusion appels budgets
                        - ex APBU 12.02 et appels fonds de roulement
                        - ex APFL 12.02 lors des traitement regroupés => changement du codage
                        APHB : 30 -> 90, APFS : 2n -> 8n, APFR : 1n -> 6n
03  20/03/2002  SY    1201/1717: Résiliation mandat de copro ou de gérance avec OD fin de gestion + nouveau controle gérance: pas de quitt en cours pour ce mandat
04  10/04/2002  SY    0402/0982: Nouveau code erreur (16) au retour de chntcon3
05  24/10/2002  PL    1002/0207: Nouveau code erreur (17) au retour de chntcon3
06  01/08/2003  OF    0703/0431: Ajout codes erreur 18 à 21 au retour de chntcon3.p
07  12/03/2007  DM    1106/0114: Pas d'ODFM si ODFE sur l'exercice
08  08/10/2007  PL    0707/1039: supp message debug
09  16/09/2008  NP    0608/0065: Gestion Mandats à 5 chiffres
10  22/12/2010  SY    1106/0114: Erreur 51 Non Bloquante ==> erreur 22 Bloquante (Pas d'ODFM si ODFE sur l'exercice est bloquant)
11  18/01/2011  SY    1210/0165: Ajout PROCESS EVENTS (essai), pas utile en reprise web.
------------------------------------------------------------------------*/
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}
{preprocesseur/mode2reglement.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{cadbgestion/include/chntcon3.i}    // procedure chntcon3Controle

function getLibelleTransfert returns character private(pcTypeTransfert as character, pcTypeAppel as character, piNumeroMandatSyndic as integer):
    /*------------------------------------------------------------------------------
    Purpose: Fonction de recherche s'il y a un traitement en cours
    Notes  : TODO  - and trfpm.dttrf > 06/01/2006:  A SUPPRIMER - FAIRE LE MENAGE ?!
    ------------------------------------------------------------------------------*/
    define buffer trfpm for trfpm.

boucle:
    for each trfpm no-lock
        where trfpm.tptrf = pcTypeTransfert
          and trfpm.tpapp = pcTypeAppel
          and trfpm.nomdt = piNumeroMandatSyndic
          and trfpm.ettrt = "00002"       /* Emis, attente retour compta */
          and trfpm.dttrf > 06/01/2006:   /* filtrer les vieilles traces */
        if pcTypeTransfert = "CC" then return substitute("&1 &2.&3", trfpm.tptrf, trfpm.noexe, trfpm.noapp).
        case pcTypeAppel:
            when "TR"  then return substitute("&1TR &2.&3", trfpm.tptrf, trfpm.noexe, trfpm.noapp).
            when "BU"  then return substitute("&1&2 &3.&4", trfpm.tptrf, trfpm.tpapp, trfpm.noexe, trfpm.noapp).
            when "TA"  then return substitute("&1&2 &3.&4", trfpm.tptrf, trfpm.tpapp, trfpm.noexe, trfpm.noapp).
            when "FRO" then return substitute("&1FR &2.&3", trfpm.tptrf, 1000 + trfpm.noexe - 60, trfpm.noapp).
            when "FRE" then return substitute("&1FS &2.&3", trfpm.tptrf, trfpm.noexe - 80, trfpm.noapp).
            when "HB"  then return substitute("&1&2 &3",    trfpm.tptrf, trfpm.tpapp, trfpm.noapp).
            otherwise       return substitute("&1&2 &3",    trfpm.tptrf, trfpm.tpapp, trfpm.noapp).
        end case.
    end.
    return "".
end function.

function isTransfertEnCours returns logical private(plCodeAppelCharge as logical, plCodeAppelBudget as logical, plCodeAppelHorsBudget as logical, plCodeAppelTravaux as logical, piNumeroMandatSyndic as integer):
    /*------------------------------------------------------------------------------
    Purpose: Fonction de recherche s'il y a un traitement en cours
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vcLibelleTransfert as character no-undo.

    if plCodeAppelCharge
    then vcLibelleTransfert = getLibelleTransfert("CC", "", piNumeroMandatSyndic).
    if plCodeAppelBudget
    then vcLibelleTransfert = trim(substitute("&1, &2, &3", vcLibelleTransfert,
                                   getLibelleTransfert("AP", "BU", piNumeroMandatSyndic),
                                   getLibelleTransfert("AP", "TA", piNumeroMandatSyndic)), ', ').
    if plCodeAppelHorsBudget
    then vcLibelleTransfert = trim(substitute("&1, &2, &3, &4", vcLibelleTransfert,
                                   getLibelleTransfert("AP", "HB" , piNumeroMandatSyndic),
                                   getLibelleTransfert("AP", "FRE", piNumeroMandatSyndic),
                                   getLibelleTransfert("AP", "FRO", piNumeroMandatSyndic)), ', ').
    if plCodeAppelTravaux
    then vcLibelleTransfert = trim(substitute("&1, &2", vcLibelleTransfert,
                                   getLibelleTransfert("AP", "TR", piNumeroMandatSyndic)), ', ').
    if vcLibelleTransfert > ""
    then do:
        mError:createErrorGestion({&error}, 106648, vcLibelleTransfert).
        return true.
    end.
end function.

procedure ctrconvmControle:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat      as character no-undo.
    define input  parameter piNumeroContrat    as int64     no-undo.
    define input  parameter pdaResiliation     as date      no-undo.
    define input  parameter pcMotifResiliation as character no-undo.
    define input  parameter pdaOdFinMandat     as date      no-undo.
    define output parameter pcCodeRetour       as character no-undo.

//  define variable viNumeroTitre        as integer no-undo initial 107048.  // Resiliation avec OD automatique de fin de gestion refuse. gga todo voir avec sylvie nicolas affichage titre sur message erreur ou information
    define variable viNumeroImmeuble     as integer no-undo.
    define variable viNumeroMandatSyndic as integer no-undo.

    define buffer intnt for intnt.

message "gga debut ctrconvmControle" .
/*gga todo voir avec philippe probleme des triggers
        /*
         Pour désactiver les triggers de CHGREF.P qui modifient NoRefUse en dynamique
        */
    ON FIND OF ctrat DO:
    END.
    ON FIND OF intnt DO:
    END.
gga*/

    // Recherche no Immeuble du mandat
    find first intnt no-lock
         where intnt.tpcon = pcTypeContrat
           and intnt.nocon = piNumeroContrat
           and intnt.tpidt = {&TYPEBIEN-immeuble} no-error.
    if not available intnt
    then do:
        /* Immeuble non trouve pour mandat %1 */
        mError:createErrorGestion({&error}, 106470, string(piNumeroContrat)).
        pcCodeRetour = "24".
        return.
    end.
    viNumeroImmeuble = intnt.noidt.

    if pcTypeContrat = {&TYPECONTRAT-mandat2Gerance}
    then do:
        // Recherche no mandat de copro de l'Immeuble
        for first intnt no-lock
            where intnt.tpcon = {&TYPECONTRAT-mandat2Syndic}
              and intnt.tpidt = {&TYPEBIEN-immeuble}
              and intnt.noidt = viNumeroImmeuble:
            viNumeroMandatSyndic = intnt.nocon.
        end.
        run controleGestion(piNumeroContrat, viNumeroMandatSyndic, output pcCodeRetour).
    end.
    else run controleCoproADB(piNumeroContrat, output pcCodeRetour).
    if pcCodeRetour <> "00" then return.

    run controleComptaADB(pcTypeContrat, piNumeroContrat, pcMotifResiliation, pdaResiliation, pdaOdFinMandat, output pcCodeRetour).

end procedure.

procedure controleGestion private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroContrat      as integer   no-undo.
    define input  parameter piNumeroMandatSyndic as integer   no-undo.
    define output parameter pcCodeRetour         as character no-undo initial "00".

    define variable vlReglementOD         as logical   no-undo.
    define variable vcListeModeReglement  as character no-undo.
    define variable vlCodeAppelCharge     as logical   no-undo.
    define variable vlCodeAppelBudget     as logical   no-undo.
    define variable vlCodeAppelHorsBudget as logical   no-undo.
    define variable vlCodeAppelTravaux    as logical   no-undo.

    define buffer ajquit for ajquit.
    define buffer synge  for synge.
    define buffer intnt  for intnt.

    /* S'il y a un quittancement en cours pour ce mandat */
    for first ajquit no-lock
        where ajquit.soc-cd  = integer(mtoken:cRefPrincipale)
          and ajquit.etab-cd = piNumeroContrat:
        mError:createError({&error}, 107049).
        pcCodeRetour = "22".
        return.
    end.

    /* S'il y a compensation copro - gerance sur ce mandat */
    for each synge no-lock
        where synge.tpctp = {&TYPECONTRAT-mandat2Syndic}
          and synge.noctp = piNumeroMandatSyndic
          and synge.tpct1 = {&TYPECONTRAT-titre2copro}
          and synge.tpct2 = {&TYPECONTRAT-mandat2Gerance}
          and synge.noct2 = piNumeroContrat
      , first intnt no-lock        /* Recherche s'il y a OD compensation */
        where intnt.tpcon = synge.tpct1
          and intnt.nocon = synge.noct1
          and intnt.tpidt = "00008"
          and intnt.noidt = synge.noct1 modulo 100000:     // integer(substring(string(synge.noct1, "9999999999"), 6, 5))
        vcListeModeReglement = entry(1, intnt.lbdiv, "@").
        if lookup({&MODEREGLEMENT-ODCompensation}, vcListeModeReglement, '#') > 0
        then do:
            if  entry(1, vcListeModeReglement, "#") = {&MODEREGLEMENT-ODCompensation} then vlCodeAppelCharge     = true.
            if num-entries(vcListeModeReglement, "#") >= 2
            and entry(2, vcListeModeReglement, "#") = {&MODEREGLEMENT-ODCompensation} then vlCodeAppelBudget     = true.
            if num-entries(vcListeModeReglement, "#") >= 3
            and entry(3, vcListeModeReglement, "#") = {&MODEREGLEMENT-ODCompensation} then vlCodeAppelHorsBudget = true.
            if num-entries(vcListeModeReglement, "#") >= 4
            and entry(4, vcListeModeReglement, "#") = {&MODEREGLEMENT-ODCompensation} then vlCodeAppelTravaux    = true.
            vlReglementOD = yes.
        end.
    end.
    if vlReglementOD
    and isTransfertEnCours(vlCodeAppelCharge, vlCodeAppelBudget, vlCodeAppelHorsBudget, vlCodeAppelTravaux, piNumeroMandatSyndic)
    then pcCodeRetour = "25".
    return.
end procedure.

procedure controleCoproADB private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de controle pour la Copro ADB
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroMandatSyndic as integer   no-undo.
    define output parameter pcCodeRetour         as character no-undo initial "00".

    if isTransfertEnCours(true, true, true, true, piNumeroMandatSyndic)
    then pcCodeRetour = "30".
    return.
end procedure.

procedure controleComptaADB private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de controle pour la compta ADB
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat      as character no-undo.
    define input  parameter piNumeroContrat    as integer   no-undo.
    define input  parameter pcMotifResiliation as character no-undo.
    define input  parameter pdaResiliation     as date      no-undo.
    define input  parameter pdaOdFinMandat     as date      no-undo.
    define output parameter pcCdRetCpt-OU      as character no-undo initial "00".

    define variable viNoErrCpt as integer no-undo.

    run chntcon3Controle(integer(if pcTypeContrat = {&TYPECONTRAT-mandat2Gerance} then mtoken:cRefGerance else mtoken:cRefCopro),
                         piNumeroContrat, "RESOD", pdaResiliation, pdaOdFinMandat, output viNoErrCpt).
    if viNoErrCpt > 0 and viNoErrCpt < 50         // erreur bloquante, sinon "00"
    then pcCdRetCpt-OU = string(viNoErrCpt, "99").

end procedure.
