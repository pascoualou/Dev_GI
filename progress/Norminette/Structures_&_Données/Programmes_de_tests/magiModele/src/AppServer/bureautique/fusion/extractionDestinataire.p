/*-----------------------------------------------------------------------------
File        : extractionDestinataire.p
Purpose     : Recherche des donnees de fusion du destinataire
Author(s)   : RF - 2008/04/11
Notes       :
Derniere revue: 2018/03/20 - phm
01  02/03/2009  PL    0209/0041:Ajout statutPropriete.               |
02  28/04/2009  SY    1106/0142: AGF - RELOCATIONS Ajout BureauDistrib (fctexpor.i)
03  13/05/2009  SY    1106/0142: AGF - RELOCATIONS Ajout SIRENDestinataire, NAFDestinataire (ChgInfRol de fctexpor.i + VALORISER de LibEvPrc.p)
04  13/05/2009  SY    ne pas initialiser les variables globales d'extraction Fgxxxxx à TRUE. (Init dans extract.p uniquement)
05  25/08/2010  NP    0810/0078 Modif ds fctexpor.i
06  10/09/2010  SY    0910/0051 Pb NomCompletDestinataire OTS. Modif chginfrol dans fctexpor.i
07  22/10/2010  PL    0910/0120 Valorisation email fournisseur.
08  29/02/2012  PL    0212/0236 Infos banque.
09  09/01/2013  DM    0412/0084 Code activation GiExtranet
10  25/07/2013  SY    0511/0023 Ajout champs pour RUM / créancier du prélèvement SEPA
11  30/07/2013  PL    NoPrbUse de extract.i oubliée.
12  06/09/2013  SY    0511/0023 Ajout adresse créancier (rumrolct.p) et libellé du rôle (RoleDesti) (demande Geneviève et Christine le 04/09/2013)
13  05/12/2013  SY    1213/0044 Pb variable NoMdtUse à 0 dans certain cas de génération dossier "courrier immeuble"
14  04/02/2014  PL    0114/0275 tiers.lbdiv2 mal initialisée pour les mandats ex 03096. Modification fctexpor.i
15  31/12/2014  NP    1214/0256 Pb RUM pour les titres de copro
16  25/01/2016  PL    0711/0069 Normalisation adresses sur 6 lignes  
-----------------------------------------------------------------------------*/
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2tiers.i}
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}
{preprocesseur/famille2tiers.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/fusion/fusionDocument.i}
{preprocesseur/listeRubQuit2TVA.i}
{preprocesseur/fusion/fusionDestinataire.i}

using bureautique.fusion.classe.fusionDestinataire.
using bureautique.fusion.classe.fusionAdresse.
using bureautique.fusion.classe.fusionBanque.
using bureautique.fusion.classe.fusionRole.
 
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{application/include/glbsepar.i} 
{bureautique/fusion/include/fctexport.i}
{bureautique/fusion/include/decodorg.i}

function inte2Date return date(piDate as integer):
    /*------------------------------------------------------------------------------
      Purpose:
        Notes:
    ------------------------------------------------------------------------------*/
    define variable vdaRetour as date      no-undo.

    vdaRetour = date(truncate(piDate / 100, 0) modulo 100, piDate modulo 100, integer(truncate(piDate / 10000, 0))) no-error.
    error-status:error = false no-error.
    return vdaRetour.
end function.

procedure extractionDestinataire:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes: service appelé par extraction.p
    ------------------------------------------------------------------------------*/
    define input        parameter piNumeroDocument     as int64     no-undo.
    define input        parameter pcTypeRole           as character no-undo.
    define input        parameter piNumeroRole         as int64     no-undo.
    define input        parameter pcListeChamp         as character no-undo.
    define input-output parameter poFusionDestinataire as class FusionDestinataire no-undo.

    /* SY 0511/0023 RUM / SEPA */
    define variable vcRUMDesti           as character no-undo.
    define variable vcNomCreancierDesti  as character no-undo.
    define variable vcICSCreancierDesti  as character no-undo.
    define variable vcIBANCreancierDesti as character no-undo.
    define variable vc3lignes            as character no-undo.
    define variable vcPaysCreancierDesti as character no-undo.
    define variable viNumeroMandatSEPA   as int64     no-undo.
    define variable vcLbDivParRUM        as character no-undo.
    define variable vcTemp               as character no-undo.
    define variable vdaDebutPSEPA        as date      no-undo.
    define variable viNueroReference     as integer   no-undo.
    define variable viNumeroMandat       as integer   no-undo.
    define variable viPosGerCop          as integer   no-undo.
    define variable vcTempAdresse        as character no-undo.
    define variable vhrumlotct           as handle    no-undo.
    define variable voRole               as class fusionRole    no-undo.
    define variable voAdresse            as class fusionAdresse no-undo.
    define variable voBanque             as class fusionBanque  no-undo.

    define variable nosynuse   as integer no-undo. // Todo THK variable globales ?
    define variable NoTitUse   as integer no-undo. // Todo THK variable globales ?
    define variable NoMdtUse   as integer no-undo. // Todo THK variable globales ?
    define variable NoPrbUse   as integer no-undo. // Todo THK variable globales ?
    define variable NoBaiUse   as integer no-undo. // Todo THK variable globales ?
    define variable viCompteur as integer no-undo.
    define variable vlBloc1    as logical no-undo.
    define variable vlBloc2    as logical no-undo.
    define variable vlBloc3    as logical no-undo.

    define buffer vbRoles for roles.
    define buffer tiers   for tiers.
    define buffer ctrat   for ctrat.
    define buffer intnt   for intnt.
    define buffer pclie   for pclie.
    define buffer rlctt   for rlctt.
    define buffer mandatSepa for mandatSepa.

boucleCHamp:
    do viCompteur = 1 to num-entries(pcListeChamp):
        case entry(viCompteur, pcListeChamp):
            when {&FUSION-TitreDestinataire}           or when {&FUSION-194}                      or when {&FUSION-NomDestinataire}
         or when {&FUSION-TitreLDestinataire}          or when {&FUSION-NomDesContact}            or when {&FUSION-TitreDesContact}
         or when {&FUSION-NomDestiSeul}                or when {&FUSION-PrenDestiSeul}            or when {&FUSION-DateNaissanceDesti}
         or when {&FUSION-DateLNaissanceDesti}         or when {&FUSION-NumDestinataire}          or when {&FUSION-NomCompletDestinataire}
         or when {&FUSION-NomCompletDesContact}        or when {&FUSION-NomCompletDesCo}          or when {&FUSION-NomCompletDesRep}
         or when {&FUSION-FormeLgJuridDestinataire}    or when {&FUSION-FormeCtJuridDestinataire} or when {&FUSION-PolitesseDestinataire}
         or when {&FUSION-StatutPropriete}             or when {&FUSION-SIReNDestinataire}        or when {&FUSION-NaFDestinataire}
         or when {&FUSION-BanqueDestinataire}          or when {&FUSION-TituRibDestinataire}      or when {&FUSION-NoCompteBancaireDestinataire}
         or when {&FUSION-NoBICDestinataire}           or when {&FUSION-RUMDesti}                 or when {&FUSION-DateSignatureRUMDesti}
         or when {&FUSION-DateDernUtilisationRUMDesti} or when {&FUSION-NomReclamPrelSePaDesti}   or when {&FUSION-NomModifPrelSePaDesti}
         or when {&FUSION-NomCreancierDesti}           or when {&FUSION-ICSCreancierDesti}        or when {&FUSION-IBaNCreancierDesti}
         or when {&FUSION-BICCreancierDesti}           or when {&FUSION-BanqueCreancierDesti}     or when {&FUSION-DelaiNotifPrelSePaDesti}
         or when {&FUSION-DatePassagePrelSePaDesti}    or when {&FUSION-LieuSignatureRUMDesti}    or when {&FUSION-DatePreNotifRUMDesti}
         or when {&FUSION-DateecheanceRUMDesti}        or when {&FUSION-MontantecheanceRUMDesti}  or when {&FUSION-RoleDesti}
         or when {&FUSION-ComplementAdresseIdentCreancierDesti} /* PL : 11/01/2016 - (Fiche : 0711/0069) */
            then do:
                if vlBloc1 then next boucleCHamp.

                assign
                    vlBloc1  = true
                    voRole   = chargeRole(pcTypeRole, piNumeroRole, piNumeroDocument)
                    poFusionDestinataire:NumDestinataire          = string(piNumeroRole)
                    poFusionDestinataire:TitreDestinataire        = voRole:Titre
    //                poFusionDestinataire:CiviliteDestinataire     = voRole:Civilite
                    poFusionDestinataire:NomDestinataire          = voRole:Nom
                    poFusionDestinataire:NomDestiSeul             = voRole:nom
                    poFusionDestinataire:PrenDestiSeul            = voRole:Prenom
                    poFusionDestinataire:TitreDesContact          = voRole:TitreBis
                    poFusionDestinataire:NomDesContact            = voRole:NomBis
                    poFusionDestinataire:TitreLDestinataire       = voRole:titreLettre
                    poFusionDestinataire:NomCompletDestinataire   = voRole:nomComplet
                    poFusionDestinataire:PolitesseDestinataire    = voRole:formulePolitesse
                    poFusionDestinataire:DateNaissanceDesti       = voRole:DateNaissance
                    poFusionDestinataire:DateLNaissanceDesti      = outilFormatage:getDateFormat(date(voRole:DateNaissance), "L")
                    poFusionDestinataire:NomCompletDesCO          = voRole:nomCompletC-O
                    poFusionDestinataire:NomCompletDesRep         = voRole:nomCompletRep
                    poFusionDestinataire:NomCompletDesContact     = voRole:nomCompletContact
                    poFusionDestinataire:FormeLgJuridDestinataire = voRole:formeJuridiqueLong
                    poFusionDestinataire:FormeCtJuridDestinataire = voRole:formeJuridiqueCourt
                    poFusionDestinataire:SIRENDestinataire        = voRole:SIREN
                    poFusionDestinataire:NAFDestinataire          = voRole:NAF
                .
    //            poFusionDestinataire:StatutPropriete   = voRole:statut
                assign
                    voBanque                                          = chargeBanque(pcTypeRole, piNumeroRole)
                    poFusionDestinataire:BanqueDestinataire           = voBanque:Banque-Domiciliation
                    poFusionDestinataire:TituRibDestinataire          = voBanque:Banque-Titulaire
                    poFusionDestinataire:NoCompteBancaireDestinataire = voBanque:Banque-IBAN
                    poFusionDestinataire:NoBICDestinataire            = voBanque:Banque-BIC
                    poFusionDestinataire:RoleDesti                    = outilTraduction:getLibelleProg("O_ROL", pcTypeRole)
                .
                case pcTypeRole:
                    when {&TYPEROLE-coproprietaire} then do:
                        assign
                            viNueroReference = integer(mtoken:cRefCopro)
                            viNumeroMandat   = nosynuse
                            viPosGerCop      = 2
                        .
                        /* NP 1214/0256 */
                        if NoTitUse = 0 then do:
                            find first rlctt no-lock
                                where rlctt.tpidt = pcTypeRole
                                  and rlctt.noidt = piNumeroRole
                                  and rlctt.tpct1 = {&TYPECONTRAT-titre2copro}
                                  and rlctt.tpct2 = {&TYPECONTRAT-prive} no-error.
                            if available rlctt then NoTitUse = rlctt.noct1.
                            else do:
                                find first intnt no-lock
                                    where intnt.tpidt = pcTypeRole 
                                      and intnt.noidt = piNumeroRole
                                      and intnt.tpcon = {&TYPECONTRAT-titre2copro} no-error.
                                if available intnt then NoTitUse = intnt.nocon.
                            end.
                        end.
                        find first ctrat no-lock
                            where ctrat.tpcon = {&TYPECONTRAT-titre2copro}
                              and ctrat.nocon = NoTitUse no-error.
                        if viNumeroMandat = 0 and available ctrat
                        then viNumeroMandat = integer(substring(string(ctrat.nocon, "9999999999"), 1, 5, "character")).  /* Ajout SY 1213/0044 */ 
                    end.
                    when {&TYPEROLE-locataire} then do:
                        assign
                            viNueroReference = integer(mtoken:cRefGerance)
                            viNumeroMandat   = integer(substring(string(piNumeroRole, "9999999999"), 1, 5, "character"))        /*NoMdtUse*/    /* SY 1213/0044 Pb NoMdtUse à 0 */
                            viPosGerCop      = 1
                        .
                        find first ctrat no-lock
                            where ctrat.tpcon = {&TYPECONTRAT-bail}
                              and ctrat.nocon = piNumeroRole no-error.
                    end.
                    when {&TYPEROLE-candidatLocataire} then do:
                        assign
                            viNueroReference = integer(mtoken:cRefGerance)
                            viNumeroMandat   = integer(substring(string(piNumeroRole, "9999999999"), 1, 5, "character"))        /*NoMdtUse*/    /* SY 1213/0044 Pb NoMdtUse à 0 */
                            viPosGerCop      = 1
                        .
                        find first ctrat no-lock
                            where ctrat.tpcon = {&TYPECONTRAT-preBail}
                              and ctrat.nocon = piNumeroRole no-error.
                    end.
                    when {&TYPEROLE-colocataire} then do:       /* Colocataire */
                        assign
                            viNueroReference = integer(mtoken:cRefGerance)
                            viNumeroMandat   = NoMdtUse
                            viPosGerCop      = 1
                        .
                        find first ctrat no-lock
                            where ctrat.tpcon = (if NoPrbUse > 0 then {&TYPECONTRAT-preBail} else {&TYPECONTRAT-bail}) 
                              and ctrat.nocon = (if NoPrbUse > 0 then NoPrbUse else NoBaiUse) no-error.
                        if viNumeroMandat = 0 and available ctrat
                        then viNumeroMandat = integer(substring(string(ctrat.nocon, "9999999999"), 1, 5, "character")).  /* Ajout SY 1213/0044 */
                    end.
                end case.
                if available ctrat then do:
                    /* SY 0511/0023 Recherche de la banque de prélèvement du Destinataire si elle existe */ 
                     run compta/rumrolct.p persistent set vhrumlotct.
                     run rumRoleContrat in vhrumlotct(
                         viNueroReference,
                         viNumeroMandat,
                         pcTypeRole,
                         piNumeroRole,
                         ctrat.tpcon,
                         ctrat.nocon,
                         today,  /* (date de prélèvement si connue) */
                         output viNumeroMandatSEPA,
                         output vcRUMDesti,
                         output vcICSCreancierDesti,
                         output vcNomCreancierDesti,
                         output vcLbDivParRUM).
                    run destroy in vhrumlotct.
                    if viNumeroMandatSEPA > 0 then do:
                        for first mandatSepa no-lock
                            where mandatSEPA.noMPrelSEPA = viNumeroMandatSEPA:
                            assign 
                                poFusionDestinataire:DateSignatureRUMDesti       = dateToCharacter(mandatSEPA.dtsig)
                                poFusionDestinataire:DateDernUtilisationRUMDesti = dateToCharacter(mandatSEPA.dtUtilisation)
                                poFusionDestinataire:LieuSignatureRUMDesti       = mandatSEPA.lisig
                                poFusionDestinataire:DatePreNotifRUMDesti        = dateToCharacter(mandatSEPA.dtNotif)
                                poFusionDestinataire:DateEcheanceRUMDesti        = dateToCharacter(mandatSEPA.dtEchNotif)
                                poFusionDestinataire:MontantEcheanceRUMDesti     = montantToCharacter(mandatSEPA.MtNotif, true)
                            .
                        end.
                        if num-entries(vcLbDivParRUM, "|") >= 4 
                        then assign
                            poFusionDestinataire:IBANCreancierDesti = entry(3, vcLbDivParRUM, "|")
                            poFusionDestinataire:BICCreancierDesti  = entry(4, vcLbDivParRUM, "|")
                        .
                        if num-entries(vcLbDivParRUM, "|") >= 5
                        then assign
                            vcTempAdresse                                  = entry(5, vcLbDivParRUM, "|" ) 
                            poFusionDestinataire:AdresseCreancierDesti      = entry(1, vcTempAdresse, separ[4])
                            poFusionDestinataire:SuiteAdresseCreancierDesti = entry(2, vcTempAdresse, separ[4])
                            vc3lignes                     = entry(3, vcTempAdresse, separ[4])
                            poFusionDestinataire:CodePostalCreancierDesti   = entry(4, vcTempAdresse, separ[4])
                            poFusionDestinataire:VilleCedexCreancierDesti   = entry(5, vcTempAdresse, separ[4])
                            poFusionDestinataire:VilleCreancierDesti        = SuppCedex(poFusionDestinataire:VilleCedexCreancierDesti)
                            poFusionDestinataire:PaysCreancierDesti         = libpaysfour(mtoken:iCodeSociete, entry(6, vcTempAdresse, separ[4]))
                        .
                    end.
                    // todo utiliser parametrageSEPA.cls   -----------------------------------------------
                    for first pclie no-lock where pclie.tppar = "SEPA":
                        if num-entries(pclie.zon03, "|") >= 2
                        then vdaDebutPSEPA = inte2Date(integer(entry(viPosGerCop, pclie.zon03, "|"))). /* AAAAMMJJ -> DATE */
                        if num-entries(pclie.zon05, "|") >= 2 
                        then poFusionDestinataire:DelaiNotifPrelSEPADesti = entry(viPosGerCop, pclie.zon05, "|").     /* Nbj avant notification SEPA  gérance */
                        assign
                            poFusionDestinataire:DatePassagePrelSEPADesti = dateToCharacter(vdaDebutPSEPA)
                            vcTemp                                        = entry(viPosGerCop, pclie.zon07, "|" )
                            poFusionDestinataire:NomReclamPrelSEPADesti   = trim(entry(1, vcTemp, separ[2])) + " " + trim(entry(2, vcTemp, separ[2]))
                            vcTemp                                        = entry(viPosGerCop , pclie.zon08, "|" )
                            poFusionDestinataire:NomModifPrelSEPADesti    = trim(entry(1, vcTemp, separ[2])) + " " + trim(entry(2, vcTemp, separ[2]))
                        .
                    end.
                end.
                assign
                    poFusionDestinataire:RUMDesti                   = vcRUMDesti
                    poFusionDestinataire:NomCreancierDesti          = vcNomCreancierDesti
                    poFusionDestinataire:ICSCreancierDesti          = vcICSCreancierDesti
                    poFusionDestinataire:IBANCreancierDesti         = vcIBANCreancierDesti
                    poFusionDestinataire:SuiteAdresseCreancierDesti = trim(poFusionDestinataire:SuiteAdresseCreancierDesti + " " + vc3lignes) /* Ajout SY le 06/09/2013 - Nouvelles structures V11.08 */
                    poFusionDestinataire:PaysCreancierDesti         = vcPaysCreancierDesti
    //              poFusionDestinataire:ComplementAdresseIdentCreancierDesti = IdentAdresse /* PL : 11/01/2016 - (Fiche : 0711/0069) */
                .
            end.
            /* PL + RF le 26/02/08 */
            when {&FUSION-adresseDestinataire}  or when {&FUSION-SuiteadresseDestinataire} or when {&FUSION-CodePostalDestinataire}
         or when {&FUSION-VilleDestinataire}    or when {&FUSION-TelephoneDestinataire}    or when {&FUSION-FaxDestinataire}
         or when {&FUSION-PaysDestinataire}     or when {&FUSION-PortableDestinataire}     or when {&FUSION-emailDestinataire}
         or when {&FUSION-BurDistDestinataire}  or when {&FUSION-VilleCedexDestinataire}   or when {&FUSION-ComplementAdresseIdentDestinataire}
            then do:
                if vlBloc2 then next boucleCHamp.

                assign
                    vlBloc2       = true
                    voAdresse     = chargeAdresse(pcTypeRole, piNumeroRole, piNumeroDocument)
                    poFusionDestinataire:AdresseDestinataire                = voAdresse:Adresse
                    poFusionDestinataire:SuiteAdresseDestinataire           = voAdresse:complementVoie
                    poFusionDestinataire:CodePostalDestinataire             = voAdresse:CodePostal
                    poFusionDestinataire:VilleDestinataire                  = voAdresse:villeSansCedex()
                    poFusionDestinataire:PaysDestinataire                   = voAdresse:codePays
                    poFusionDestinataire:TelephoneDestinataire              = voAdresse:Telephone
                    poFusionDestinataire:PortableDestinataire               = voAdresse:Portable
                    poFusionDestinataire:FaxDestinataire                    = voAdresse:Fax
                    poFusionDestinataire:EmailDestinataire                  = voAdresse:Mail
                    poFusionDestinataire:VilleCedexDestinataire             = voAdresse:ville /* 0109/0192 */
                    poFusionDestinataire:ComplementAdresseIdentDestinataire = voAdresse:IdentAdresse /* PL : 11/01/2016 - (Fiche : 0711/0069) */
                    poFusionDestinataire:BurDistDestinataire                = bureauDistrib(pcTypeRole, piNumeroRole, piNumeroDocument) /* Ajout SY le 28/04/2009 : bureau distributeur */
                .
            end.
            when {&FUSION-WebIdentifiantactivation} or when {&FUSION-WebMotDePasseactivation}
            then do:                                  /* DM 0412/0084 */
                if vlBloc3 then next boucleCHamp.

                vlBloc3 = true.
                for first vbRoles no-lock
                    where vbRoles.tprol = pcTypeRole 
                      and vbRoles.norol = piNumeroRole
                  , first tiers no-lock 
                    where tiers.notie = vbRoles.notie:
                    assign
                        poFusionDestinataire:WebIdentifiantActivation = tiers.web-id
                        poFusionDestinataire:WebMotDePasseActivation  = tiers.web-mdp
                    .
                end.
            end.
        end case.
    end.
    delete object voAdresse no-error.
    delete object voRole    no-error.

end procedure.
