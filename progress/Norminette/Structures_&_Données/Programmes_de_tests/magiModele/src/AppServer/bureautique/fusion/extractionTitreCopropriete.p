/*-----------------------------------------------------------------------------
File        : extractionTitreCopropriete.p
Purpose     : Recherche des donnees de fusion titre de copropriété
Author(s)   : 
Notes       : appelé par extract.p
derniere revue:
-----------------------------------------------------------------------------*/
{preprocesseur/famille2tiers.i}
{preprocesseur/listeRubQuit2TVA.i}
{preprocesseur/type2bien.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2intervention.i}
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}
{preprocesseur/fusion/fusionTitreCopro.i}

using bureautique.fusion.classe.fusionTitreCopro.
using bureautique.fusion.classe.fusionAdresse.
using bureautique.fusion.classe.fusionRole.
using bureautique.fusion.classe.fusionBanque.    // Pour fctExport.i
using parametre.pclie.parametrageRepertoireMagi. // Pour fctExport.i

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{comm/include/fctdatin.i}
{application/include/glbsepar.i}
{bureautique/fusion/include/fctexport.i}
{bureautique/fusion/include/decodorg.i}

procedure extractionTitreCopropriete:
    /*------------------------------------------------------------------------------
    Purpose: Valorisation des données propres au titre de copropriété
    Notes: service utilisé par extraction.p
    ------------------------------------------------------------------------------*/
    define input        parameter piNumeroTitre             as integer   no-undo.
    define input        parameter piNumeroDocument          as integer   no-undo.
    define input        parameter piTypeRole                as character no-undo.
    define input        parameter piNumeroRole              as integer   no-undo.
    define input        parameter piNumeroMandatSyndic      as int64     no-undo.
    define input        parameter pcListeChamp              as character no-undo.
    define input-output parameter poFusionTitreCopro        as class fusionTitreCopro no-undo.

    define variable viCompteur                              as integer   no-undo.
    define variable viCompteurCleTantieme                   as integer   no-undo.
    define variable vcTantCleGene                           as character no-undo.
    define variable vcListeLotsCoproprietaire               as character no-undo.
    define variable vcLstLotCoprop                          as character no-undo.
    define variable vlBloc1                                 as logical   no-undo.
    define variable vlBloc2                                 as logical   no-undo.
    define variable vlBloc3                                 as logical   no-undo.
    define variable vlBloc4                                 as logical   no-undo.
    define variable vlBloc5                                 as logical   no-undo.
    define variable vlBloc6                                 as logical   no-undo.
    define variable vcLbZone                                as character no-undo.
    define variable vhrumlotct                              as handle    no-undo.
    define variable CpArgUse                                as integer   no-undo.
    define variable ChArgUse                                as character no-undo.

    /* Ajout SY le 05/09/2005 */
    /* Compte pour le SOLDE copropriétaire */
    define variable cdcptcop                                as character no-undo.
    define variable cdcptchb                                as character no-undo.
    define variable CdCptCopCD                              as character no-undo.
    /* SY 0511/0023 RUM / SEPA */
    define variable RUMCoproprietaire                       as character no-undo.
    define variable vcNomCreancierCoproprietaire            as character no-undo.
    define variable vcICSCreancierCoproprietaire            as character no-undo.
    define variable BICCreancierCoproprietaire              as character no-undo.

    define variable vcBanqueCreancierCoproprietaire         as character no-undo.
    define variable vcDelaiNotifPrelSEPACoproprietaire      as character no-undo.
    define variable vcMontantEcheanceRUMCoproprietaire      as character no-undo.

    /* Contentieux Copropriétaire - 0614/0152 */  
    define variable DtDebutContentieuxEnLettreCop           as character no-undo.
    define variable vcEtat-contentieuxCop                   as character no-undo.
    define variable vcCommentaire-ContentieuxCop            as character no-undo.

    /* SY 1214/0035 */  
    define variable vdSoldeCompteDebitCopro                 as character no-undo.
    define variable vdSoldeCompteCreditCopro                as character no-undo.
    define variable vdSoldeCpt                              as decimal   no-undo.
    define variable vdSoldeCptCHB                           as decimal   no-undo.
    define variable vdSoldeCptC                             as decimal   no-undo.
    define variable vdSoldeCptCD                            as decimal   no-undo. /* NP #865 */
    define variable viNumeroMandatSEPA                      as integer   no-undo.
    define variable vcLbDivParRUM                           as character no-undo.
    define variable vdaDateDebPSEPA                         as date      no-undo.

    define variable voRole                                  as class fusionRole    no-undo.
    define variable voAdresse                               as class fusionAdresse no-undo.

    define buffer blidoc    for lidoc.
    define buffer ccptcol   for ccptcol.
    define buffer csscptcol for csscptcol.

    /** Initialisation compte pour le solde copropriétaire **/
    for each ccptcol no-lock
        where soc-cd  = integer(mtoken:cRefCopro)
          and tprole = 00008
      , first csscptcol no-lock
        where csscptcol.soc-cd =  ccptcol.soc-cd
          and csscptcol.coll-cle = ccptcol.coll-cle
          and csscptcol.facturable = yes:
        CdCptCop = csscptcol.sscoll-cpt.
    end.
    /** Initialisation compte 'douteux' pour le solde copropriétaire **/    /* NP #865 */
    for each ccptcol no-lock
        where ccptcol.soc-cd = integer(mtoken:cRefCopro) 
          and ccptcol.tprole = 00008
        ,first csscptcol no-lock
            where csscptcol.soc-cd   =  ccptcol.soc-cd
              and csscptcol.coll-cle = ccptcol.coll-cle
              and csscptcol.douteux  = yes:
        CdCptCopCD = csscptcol.sscoll-cpt.
    end.

    /* Ajout SY le 09/03/2009 : init titre de copro avec mandat + compte */
    if piNumeroTitre = 0 and piNumeroMandatSyndic <> 0 and piTypeRole = "00008" and piNumeroRole <> 0 
    then piNumeroTitre = integer(string(piNumeroMandatSyndic, "99999") + string(piNumeroRole , "99999")).

    /* Ajout SY le 12/03/2009 : init titre de copro pour le mandataire */
    if piNumeroTitre = 0 and piNumeroMandatSyndic <> 0 and piTypeRole = "00014" then do:
        find first blidoc no-lock
            where blidoc.nodoc = piNumeroDocument
              and blidoc.tpidt = piTypeRole
              and blidoc.noidt = piNumeroRole no-error.
        if available blidoc 
        then do CpArgUse = 1 to num-entries(blidoc.lbdiv,separ[1]):
            ChArgUse = entry(CpArgUse, blidoc.lbdiv,separ[1]).
            if outils:donneEntree(1, ChArgUse, separ[2]) = "00008" then do:
                piNumeroTitre = integer(string(piNumeroMandatSyndic, "99999") + string(integer(outils:donneEntree(2, ChArgUse, separ[2])), "99999")).
                leave.
            end.
        end.
    end.
    poFusionTitreCopro:NumCoproprietaire = substring(string(piNumeroTitre, "9999999999"), 6, 5). /* NP 0608/0065 */

boucleCHamp:
    do viCompteur = 1 to num-entries(pcListeChamp):
        case entry(viCompteur, pcListeChamp):
            when {&FUSION-TitreCoproprietaire}      or when {&FUSION-TitreLCoproprietaire}   or when {&FUSION-104794}
         or when {&FUSION-NomCoproprietaire}        or when {&FUSION-TitreCoproContact}      or when "103363"
         or when {&FUSION-NomCompletCoproprietaire} or when {&FUSION-NomCompletCoproContact} or when {&FUSION-NomCompletCoproCo}
         or when {&FUSION-NomCompletCoproRep}       or when {&FUSION-PolitesseCoproprietaire}
            then do:
                if vlBloc1 then next boucleCHamp.
                vlBloc1 = true.
                voRole = chargeRole("00008", integer(poFusionTitreCopro:NumCoproprietaire), piNumeroDocument).
                assign
                    poFusionTitreCopro:TitreCoproprietaire      = voRole:titre
                    poFusionTitreCopro:TitreLCoproprietaire     = voRole:titreLettre
                    poFusionTitreCopro:CiviliteCoproprietaire   = voRole:Civilite
                    poFusionTitreCopro:NomCoproprietaire        = voRole:Nom
                    poFusionTitreCopro:TitreCoproContact        = voRole:TitreBis
                    poFusionTitreCopro:NomCoproContact          = voRole:NomBis
                    poFusionTitreCopro:NomCompletCoproprietaire = voRole:NomComplet
                    poFusionTitreCopro:NomCompletCoproCO        = voRole:nomCompletC-O
                    poFusionTitreCopro:NomCompletCoproRep       = voRole:nomCompletRep
                    poFusionTitreCopro:NomCompletCoproContact   = voRole:nomCompletContact
                    poFusionTitreCopro:PolitesseCoproprietaire  = voRole:formulePolitesse
                .
            end.
            when {&FUSION-adresseCoproprietaire} or when {&FUSION-SuiteadresseCoproprietaire} or when {&FUSION-CodePostalCoproprietaire}
         or when {&FUSION-VilleCoproprietaire}   or when {&FUSION-TelCoproprietaire}          or when {&FUSION-PortableCoproprietaire} 
         or when {&FUSION-FaxCoproprietaire}     or when {&FUSION-emailCoproprietaire}        or when {&FUSION-VilleCedexCoproprietaire}
         or when {&FUSION-ComplementAdresseIdentCopropriétaire}  /* PL : 11/01/2016 - (Fiche : 0711/0069) */
            then do:
                if vlBloc2 then next boucleCHamp.
                vlBloc2 = true.
                // run Adresse("00008", integer(NumCoproprietaire), output LbTmpPdt).
                voAdresse = chargeAdresse("00008", integer(poFusionTitreCopro:NumCoproprietaire), piNumeroDocument).
                assign
                    poFusionTitreCopro:AdresseCoproprietaire                = voAdresse:Adresse
                    poFusionTitreCopro:SuiteAdresseCoproprietaire           = voAdresse:complementVoie
                    poFusionTitreCopro:CodePostalCoproprietaire             = voAdresse:CodePostal
                    poFusionTitreCopro:VilleCoproprietaire                  = voAdresse:Ville
                    poFusionTitreCopro:PaysCoproprietaire                   = voAdresse:codePays
                    poFusionTitreCopro:TelCoproprietaire                    = voAdresse:telephone
                    poFusionTitreCopro:PortableCoproprietaire               = voAdresse:Portable
                    poFusionTitreCopro:FaxCoproprietaire                    = voAdresse:Fax
                    poFusionTitreCopro:EmailCoproprietaire                  = voAdresse:mail
                    poFusionTitreCopro:VilleCedexCoproprietaire             = voAdresse:cedex         /* 0109/0192 */
                    poFusionTitreCopro:ComplementAdresseIdentCopropriétaire = voAdresse:IdentAdresse  /* PL : 11/01/2016 - (Fiche : 0711/0069) */ 
                .
            end.
            when {&FUSION-SoldeCoproprietaire}                 or when {&FUSION-SoldeCoproprietaireenLettre}  or when {&FUSION-DateSoldeCopro}
         or when {&FUSION-DateLSoldeCopro}                     or when {&FUSION-DateSoldeCoproLettre}         or when {&FUSION-SoldeDebiteurCoproprietaire}
         or when {&FUSION-SoldeDebiteurCoproprietaireEnLettre} or when {&FUSION-SoldeCrediteurCoproprietaire} or when {&FUSION-SoldeCrediteurCoproprietaireEnLettre}
            then do:
                if vlBloc3 then next boucleCHamp.
                vlBloc3 = true.
                assign
                    vdSoldeCpt                                     = SOLDECPT("01004", piNumeroTitre, 0, CdCptCop, today)
                    poFusionTitreCopro:SoldeCoproprietaire         = montantToCharacter(vdSoldeCpt, true)
                    poFusionTitreCopro:SoldeCoproprietaireEnLettre = convchiffre(vdSoldeCpt)
                    poFusionTitreCopro:DateSoldeCopro              = dateToCharacter(today)
                    poFusionTitreCopro:DateLSoldeCopro             = outilFormatage:getDateFormat(today, "L")
                    poFusionTitreCopro:DateSoldeCoproLettre        = outilFormatage:getDateFormat(today, "LL")
                .
                if vdSoldeCpt > 0 then do:
                    vdSoldeCompteDebitCopro                                 = montantToCharacter(vdSoldeCpt,true).
                    poFusionTitreCopro:SoldeDebiteurCopropriétaireEnLettre  = convchiffre(vdSoldeCpt).
                    poFusionTitreCopro:SoldeCrediteurCopropriétaireEnLettre = convchiffre(0).
                end.
                else do:
                    vdSoldeCompteCreditCopro                                = montantToCharacter(vdSoldeCpt,true).
                    poFusionTitreCopro:SoldeDebiteurCopropriétaireEnLettre  = convchiffre(0).
                    poFusionTitreCopro:SoldeCrediteurCopropriétaireEnLettre = convchiffre(vdSoldeCpt).
                end.
                assign
                    poFusionTitreCopro:SoldeDebiteurCopropriétaire  = vdSoldeCompteDebitCopro
                    poFusionTitreCopro:SoldeCrediteurCopropriétaire = vdSoldeCompteCreditCopro
                .
            end.
            when {&FUSION-TantCleGene} or when {&FUSION-ListeLotsCoproprietaire}
            then do:
                assign
                    viCompteurCleTantieme = 0
                    vcListeLotsCoproprietaire = ""
                .
                for each intnt no-lock 
                   where intnt.tpcon = "01004"
                     and intnt.nocon = piNumeroTitre
                     and intnt.tpidt = "02002"
                     and intnt.nbden = 0
                 , first local no-lock
                   where local.noloc = intnt.noidt
                 ,  each milli no-lock
                   where milli.noimm = local.noimm
                     and milli.cdcle = "A"
                     and milli.nolot = local.nolot:
    
                    find first sys_pr no-lock
                        where sys_pr.tppar = "NTLOT"
                          and sys_pr.cdpar = local.ntlot no-error.
                    if available sys_pr 
                    then find first sys_lb no-lock
                            where sys_lb.nomes = sys_pr.nome1  no-error.
                    assign
                        viCompteurCleTantieme     = viCompteurCleTantieme + nbpar
                        vcListeLotsCoproprietaire = (if available sys_lb
                                                     then vcListeLotsCoproprietaire + " " + string(local.nolot) + " " + sys_lb.lbmes
                                                     else vcListeLotsCoproprietaire + " " + string(local.nolot))
                        .
                end.
                vcTantCleGene = string(viCompteurCleTantieme).
            end.
            when "107441" then do:
                for each intnt no-lock
                   where intnt.tpcon = "01004"
                     and intnt.nocon = piNumeroTitre
                     and intnt.tpidt = "02002"
                     and intnt.nbden = 0
                 , first local no-lock
                   where local.noloc = intnt.noidt:
                    vcLstLotCoprop = vcLstLotCoprop + (if vcLstLotCoprop = "" then "" else ", ") + string(local.nolot).
                end.
            end.
            when {&FUSION-TituRibCoprop}                        or when {&FUSION-NoCompteBancaireCopro}           or when {&FUSION-BanqueCopro}
         or when {&FUSION-NoBICCoproprietaire}                  or when {&FUSION-RUMCoproprietaire}               or when {&FUSION-DateSignatureRUMCoproprietaire}
         or when {&FUSION-DateDernUtilisationRUMCoproprietaire} or when {&FUSION-NomReclamPrelSePaCoproprietaire} or when {&FUSION-NomModifPrelSePaCoproprietaire}
         or when {&FUSION-NomCreancierCoproprietaire}           or when {&FUSION-ICSCreancierCoproprietaire}      or when {&FUSION-IBaNCreancierCoproprietaire}
         or when {&FUSION-BICCreancierCoproprietaire}           or when {&FUSION-BanqueCreancierCoproprietaire}   or when {&FUSION-DelaiNotifPrelSePaCoproprietaire}
         or when {&FUSION-DatePassagePrelSePaCoproprietaire}    or when {&FUSION-LieuSignatureRUMCoproprietaire}  or when {&FUSION-DatePreNotifRUMCoproprietaire}
         or when {&FUSION-DateecheanceRUMCoproprietaire}        or when {&FUSION-MontantecheanceRUMCoproprietaire}
            then do:
                if vlBloc5 then next boucleCHamp.
                vlBloc5 = true.
                if piNumeroTitre > 0 
                then find ctrat no-lock 
                    where ctrat.tpcon = "01004" and ctrat.nocon = piNumeroTitre  no-error.
                find first rlctt no-lock
                     where rlctt.tpidt = "00008"
                       and rlctt.noidt = integer(poFusionTitreCopro:NumCoproprietaire)
                       and rlctt.tpct1 = "01004"                                                   /* ajout Sy le 25/07/2013 */
                       and rlctt.noct1 = (if available ctrat then ctrat.nocon else rlctt.noct1)    /* ajout Sy le 25/07/2013 */
                       and rlctt.tpct2 = "01038" no-error.
                if available rlctt then
                    find first ctanx no-lock
                        where ctanx.tpcon = rlctt.tpct2
                          and ctanx.nocon = rlctt.noct2 no-error.
                else do:
                    find roles no-lock
                         where roles.tprol = "00008"
                           and roles.norol = integer(poFusionTitreCopro:NumCoproprietaire) no-error.
                    if available roles then
                        find first ctanx no-lock
                             where ctanx.tprol = "99999"
                               and ctanx.norol = roles.notie
                               and ctanx.tpact = "DEFAU"
                               and ctanx.tpcon = "01038" no-error.
                end.
                if available ctanx then do:
                    assign
                        poFusionTitreCopro:TituRibCoprop         = ctanx.lbtit
                        poFusionTitreCopro:BanqueCopro           = ctanx.lbdom
                        poFusionTitreCopro:NoCompteBancaireCopro = ctanx.iban
                        poFusionTitreCopro:NoBICCoproprietaire   = ctanx.bicod
                    .
                end.
                if available ctrat then do:
                    /* SY 0511/0023 Recherche de la banque de prélèvement du Coproprietaire si elle existe */
                    run compta/rumrolct.p persistent set vhrumlotct.
                    run rumRoleContrat in vhrumlotct(input integer(mtoken:cRefCopro)
                                                   , input piNumeroMandatSyndic
                                                   , input ctrat.tprol
                                                   , input ctrat.norol
                                                   , input ctrat.tpcon
                                                   , input ctrat.nocon
                                                   , output viNumeroMandatSEPA
                                                   , output RUMCoproprietaire
                                                   , output vcICSCreancierCoproprietaire
                                                   , output vcNomCreancierCoproprietaire
                                                   , output vcLbDivParRUM).
                    run destroy in vhrumlotct.
                    if viNumeroMandatSEPA > 0 then do:
                        find mandatSepa no-lock
                            where mandatSEPA.noMPrelSEPA = viNumeroMandatSEPA no-error.
                        if available mandatsepa 
                        then assign
                            poFusionTitreCopro:DateSignatureRUMCoproprietaire       = dateToCharacter(mandatSEPA.dtsig)
                            poFusionTitreCopro:DateDernUtilisationRUMCoproprietaire = dateToCharacter(mandatSEPA.dtUtilisation)
                            poFusionTitreCopro:LieuSignatureRUMCoproprietaire       = mandatSEPA.lisig
                            poFusionTitreCopro:DatePreNotifRUMCoproprietaire        = dateToCharacter(mandatSEPA.dtNotif)
                            poFusionTitreCopro:DateEcheanceRUMCoproprietaire        = dateToCharacter(mandatSEPA.dtEchNotif)
                            poFusionTitreCopro:MontantEcheanceRUMCoproprietaire     = montantToCharacter(mandatSEPA.MtNotif, true)
                        .
                        if num-entries(vcLbDivParRUM , "|") >= 4 
                        then assign
                            poFusionTitreCopro:IBANCreancierCoproprietaire = entry(3, vcLbDivParRUM, "|" )
                            poFusionTitreCopro:BICCreancierCoproprietaire  = entry(4, vcLbDivParRUM, "|" ) 
                        .
                    end. 
                    find first pclie no-lock where pclie.tppar = "SEPA" no-error.
                    if available pclie then do: 
                        if num-entries(pclie.zon03, "|") >= 2 
                        then vdaDateDebPSEPA = integer2Date(integer(entry(2, pclie.zon03, "|" ))).      /* AAAAMMJJ -> DATE */

                        poFusionTitreCopro:DatePassagePrelSePaCoproprietaire = dateToCharacter(vdaDateDebPSEPA).
                        if num-entries( pclie.zon05 , "|" ) >= 2
                        then vcDelaiNotifPrelSEPACoproprietaire = entry(2, pclie.zon05, "|" ).
                        
                        vcLbZone = entry(2, pclie.zon07, "|" ). /* Copro */
                        poFusionTitreCopro:NomReclamPrelSEPACoproprietaire = trim(entry(1, vcLbZone, separ[2])) + " " + trim(entry(2, vcLbZone, separ[2])).
                        vcLbZone = entry(2, pclie.zon08, "|" ). /* Copro */
                        poFusionTitreCopro:NomModifPrelSEPACoproprietaire  = trim(entry(1 ,vcLbZone, separ[2])) + " " + trim(entry(2, vcLbZone, separ[2])).
                    end.
                end.
                assign
                    poFusionTitreCopro:RUMCoproprietaire                    = RUMCoproprietaire
                    poFusionTitreCopro:NomCreancierCoproprietaire           = vcNomCreancierCoproprietaire
                    poFusionTitreCopro:ICSCreancierCoproprietaire           = vcICSCreancierCoproprietaire
                    poFusionTitreCopro:BanqueCreancierCoproprietaire        = vcBanqueCreancierCoproprietaire
                    poFusionTitreCopro:DelaiNotifPrelSEPACoproprietaire     = vcDelaiNotifPrelSEPACoproprietaire
                    poFusionTitreCopro:MontantEcheanceRUMCoproprietaire     = vcMontantEcheanceRUMCoproprietaire
                .
            end.
            /* Contentieux Copropriétaire - 0614/0152 + NP 0215/0105 */
            when {&FUSION-FgCopContentieux}                        or when {&FUSION-DtDebutContentieuxCop}           or when {&FUSION-DtLDebutContentieuxCop}
         or when {&FUSION-DtDebutContentieuxenLettreCop}           or when {&FUSION-etat-contentieuxCop}             or when {&FUSION-Commentaire-ContentieuxCop}
         or when {&FUSION-IndiceImpayesContentieuxCop}             or when {&FUSION-DtDepIndiceContentieuxCop}       or when {&FUSION-DtLDepIndiceContentieuxCop}
         or when {&FUSION-DtDepIndiceContentieuxCopenLettre}       or when {&FUSION-DtDelivCommandContentieuxCop}    or when {&FUSION-DtLDelivCommandContentieuxCop}
         or when {&FUSION-DtDelivCommandContentieuxCopenLettre}    or when {&FUSION-DtDelivSignassignContentieuxCop} or when {&FUSION-DtLDelivSignassignContentieuxCop}
         or when {&FUSION-DtDelivSignassignContentieuxCopenLettre} or when {&FUSION-DtaudienceContentieuxCop}        or when {&FUSION-DtLaudienceContentieuxCop}
         or when {&FUSION-DtaudienceContentieuxCopenLettre}        or when {&FUSION-DtRequisForceContentieuxCop}     or when {&FUSION-DtLRequisForceContentieuxCop}
         or when {&FUSION-DtRequisForceContentieuxCopEnLettre}  /* SY #1905 */
            then do:
                if vlBloc6 then next boucleCHamp.
                vlBloc6 = true.

                find last tache no-lock 
                    where tache.tpcon = "01004"
                      and tache.nocon = piNumeroTitre
                      and tache.tptac = "04372" no-error.
                if available tache then do:
                    assign
                        poFusionTitreCopro:FgCopContentieux                        = string(tache.tpges = "00001","OUI/NON")
                        poFusionTitreCopro:DtDebutContentieuxCop                   = dateToCharacter(tache.dtdeb)
                        poFusionTitreCopro:DtLDebutContentieuxCop                  = outilFormatage:getDateFormat(tache.dtdeb, "L")
                        poFusionTitreCopro:DtDebutContentieuxEnLettreCop           = outilFormatage:getDateFormat(tache.dtdeb, "LL")
                        poFusionTitreCopro:Etat-contentieuxCop                     = tache.dcreg
                        poFusionTitreCopro:Commentaire-ContentieuxCop              = tache.ntreg
                        poFusionTitreCopro:DtDepIndiceContentieuxCop               = dateToCharacter(tache.dtreg)
                        poFusionTitreCopro:DtLDepIndiceContentieuxCop              = outilFormatage:getDateFormat(tache.dtreg, "L")
                        poFusionTitreCopro:DtDepIndiceContentieuxCopEnLettre       = outilFormatage:getDateFormat(tache.dtreg, "LL")
                        poFusionTitreCopro:DtDelivCommandContentieuxCop            = dateToCharacter(tache.dtree)
                        poFusionTitreCopro:DtLDelivCommandContentieuxCop           = outilFormatage:getDateFormat(tache.dtree, "L")
                        poFusionTitreCopro:DtDelivCommandContentieuxCopEnLettre    = outilFormatage:getDateFormat(tache.dtree, "LL")
                        poFusionTitreCopro:DtDelivSignAssignContentieuxCop         = dateToCharacter(tache.dtrev)
                        poFusionTitreCopro:DtLDelivSignAssignContentieuxCop        = outilFormatage:getDateFormat(tache.dtrev, "L")
                        poFusionTitreCopro:DtDelivSignAssignContentieuxCopEnLettre = outilFormatage:getDateFormat(tache.dtrev, "LL")
                        poFusionTitreCopro:DtAudienceContentieuxCop                = dateToCharacter(date(tache.lbdiv))
                        poFusionTitreCopro:DtLAudienceContentieuxCop               = outilFormatage:getDateFormat(date(tache.lbdiv), "L")
                        poFusionTitreCopro:DtAudienceContentieuxCopEnLettre        = outilFormatage:getDateFormat(date(tache.lbdiv), "LL")
                        /* SY #1905 */
                        poFusionTitreCopro:DtRequisForceContentieuxCop             = dateToCharacter(date(entry(1, tache.LbDiv2, separ[5])))
                        poFusionTitreCopro:DtLRequisForceContentieuxCop            = outilFormatage:getDateFormat(date(entry(1, tache.LbDiv2,separ[5])), "L")
                        poFusionTitreCopro:DtRequisForceContentieuxCopEnLettre     = outilFormatage:getDateFormat(date(entry(1, tache.LbDiv2,separ[5])), "LL")                  
                    .
                end.
                else assign
                        poFusionTitreCopro:FgCopContentieux                        = "NON"
                        poFusionTitreCopro:DtDebutContentieuxCop                   = ""
                        poFusionTitreCopro:DtLDebutContentieuxCop                  = ""
                        poFusionTitreCopro:DtDebutContentieuxEnLettreCop           = ""
                        poFusionTitreCopro:Etat-contentieuxCop                     = ""
                        poFusionTitreCopro:Commentaire-ContentieuxCop              = ""
                        poFusionTitreCopro:DtDepIndiceContentieuxCop               = ""
                        poFusionTitreCopro:DtLDepIndiceContentieuxCop              = ""
                        poFusionTitreCopro:DtDepIndiceContentieuxCopEnLettre       = ""
                        poFusionTitreCopro:DtDelivCommandContentieuxCop            = ""
                        poFusionTitreCopro:DtLDelivCommandContentieuxCop           = ""
                        poFusionTitreCopro:DtDelivCommandContentieuxCopEnLettre    = ""
                        poFusionTitreCopro:DtDelivSignAssignContentieuxCop         = ""
                        poFusionTitreCopro:DtLDelivSignAssignContentieuxCop        = ""
                        poFusionTitreCopro:DtDelivSignAssignContentieuxCopEnLettre = ""
                        poFusionTitreCopro:DtAudienceContentieuxCop                = ""
                        poFusionTitreCopro:DtLAudienceContentieuxCop               = ""
                        poFusionTitreCopro:DtAudienceContentieuxCopEnLettre        = ""
                    .
                assign
                    poFusionTitreCopro:DtDebutContentieuxEnLettreCop = DtDebutContentieuxEnLettreCop
                    poFusionTitreCopro:Etat-contentieuxCop           = vcEtat-contentieuxCop
                    poFusionTitreCopro:Commentaire-ContentieuxCop    = vcCommentaire-ContentieuxCop
                    poFusionTitreCopro:IndiceImpayesContentieuxCop   = montantToCharacter(tache.mtreg, false) /* NP 0215/0105 */
               .
            end.
            when {&FUSION-SoldeCopro_CHB}            or when {&FUSION-SoldeCopro_CHB_enLettre} or when {&FUSION-SoldeCopro_C_CHB}
         or when {&FUSION-SoldeCopro_C_CHB_enLettre} or when {&FUSION-SoldeCopro_CD}           or when {&FUSION-SoldeCopro_CD_EnLettre}  /* SY 1214/0035 */
         or when {&FUSION-SoldeCopro_C_CHB_sansCD}   or when {&FUSION-SoldeCopro_C_CHB_sansCD_EnLettre}         /* NP #865 */
            then do:
                assign 
                    vdSoldeCptC                                         = SOLDECPT("01004", piNumeroTitre, 0, CdCptCop,   today)
                    vdSoldeCptCHB                                       = SOLDECPT("01004", piNumeroTitre, 0, CdCptChb,   today)
                    vdSoldeCptCD                                        = SOLDECPT("01004", piNumeroTitre, 0, CdCptCopCD, today)   /* NP #865 */
                    poFusionTitreCopro:SoldeCopro_CHB                   = montantToCharacter(vdSoldeCptCHB, true)
                    poFusionTitreCopro:SoldeCopro_CHB_EnLettre          = convchiffre(vdSoldeCptCHB)
                    poFusionTitreCopro:SoldeCopro_C_CHB                 = montantToCharacter(vdSoldeCptC + vdSoldeCptCHB, true)
                    poFusionTitreCopro:Etat-SoldeCopro_C_CHB_EnLettre   = convchiffre(vdSoldeCptC + vdSoldeCptCHB)
                    /* NP #865 */
                    poFusionTitreCopro:SoldeCopro_CD                    = montantToCharacter(vdSoldeCptCD, true).
                    poFusionTitreCopro:SoldeCopro_CD_EnLettre           = convchiffre(vdSoldeCptCD).
                    poFusionTitreCopro:SoldeCopro_C_CHB_sansCD          = montantToCharacter(vdSoldeCptC + vdSoldeCptCHB - vdSoldeCptCD, true).
                    poFusionTitreCopro:SoldeCopro_C_CHB_sansCD_EnLettre = convchiffre(vdSoldeCptC + vdSoldeCptCHB - vdSoldeCptCD)
                .
            end.
        end case.
    end.
end procedure.