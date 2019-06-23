/*-----------------------------------------------------------------------------
File        : extractionSalarie.p
Description : Recherche des donnees de fusion du salarie
Author(s)   : RF - 2008/04/11, KANTENA - 2018/02/26
Notes       :
-----------------------------------------------------------------------------*/
{preprocesseur/famille2tiers.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}
{preprocesseur/fusion/fusionSalarie.i}
{preprocesseur/listeRubQuit2TVA.i}

using bureautique.fusion.classe.fusionSalarie.
using bureautique.fusion.classe.fusionAdresse.
using bureautique.fusion.classe.fusionBanque.
using bureautique.fusion.classe.fusionRole.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{application/include/glbsepar.i} 
{bureautique/fusion/include/fctexport.i}
{bureautique/fusion/include/decodorg.i}

procedure extractionSalarie:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes: service utilisé par extraction.p
    ------------------------------------------------------------------------------*/
    define input        parameter piNumeroSalarie   as integer   no-undo.
    define input        parameter piNumeroDocument  as int64     no-undo.
    define input        parameter pcTypeCttSalarie  as character no-undo.
    define input        parameter pcTypeRoleSalarie as character no-undo.
    define input        parameter pcListeChamp      as character no-undo.
    define input-output parameter poFusionSalarie   as class fusionSalarie no-undo.

    define variable voAdresse             as class fusionAdresse no-undo.
    define variable voRole                as class fusionRole    no-undo.
    define variable voBanque              as class fusionBanque  no-undo.
    define variable viMoisPaieDebut       as integer   no-undo.
    define variable viMoisPaieFin         as integer   no-undo.
    define variable vcVilleCedexURSSAF    as character no-undo.    // TODO   Variable utilisée, mais non assignée !!!!!!!
    define variable vcSIRETemployeur      as character no-undo.
    /* Ajout SY le 25/06/2015 - Paie Pégase */
    define variable viNumeroMandatSalarie as integer   no-undo.
    define variable vcParam               as character no-undo.
    define variable viBoucle              as integer   no-undo.
    define variable vcListeOrgSoc         as character no-undo.
    define variable vcOrgSocPegase        as character no-undo.
    define variable viCompteur            as integer   no-undo.
    define variable vlBloc1               as logical   no-undo.
    define variable vlBloc2               as logical   no-undo.
    define variable vlBloc3               as logical   no-undo.

    define buffer ctrat   for ctrat.
    define buffer difuti  for difuti.
    define buffer cttac   for cttac.
    define buffer conge   for conge.
    define buffer ctanx   for ctanx.
    define buffer vbRoles for roles.
    define buffer ifour   for ifour.
    define buffer pclie   for pclie.
    define buffer orsoc   for orsoc.
    define buffer etabl   for etabl.
    define buffer salar   for salar.
    define buffer intnt   for intnt.
    define buffer csscptcol for csscptcol.

/*
message "piNumeroSalarie : "   piNumeroSalarie
        "piNumeroDocument : "  piNumeroDocument
        "pcLibelleChamp : "    pcLibelleChamp
        "pcTypeCttSalarie : "  pcTypeCttSalarie
        "pcTypeRoleSalarie : " pcTypeRoleSalarie
view-as alert-box.
*/
    viNumeroMandatSalarie = integer(if pcTypeCttSalarie = {&TYPECONTRAT-SalariePegase}
                                    then substring(string(piNumeroSalarie, "9999999999"), 1, 5, "character")
                                    else substring(string(piNumeroSalarie, "999999"), 1, 4, "character")).

boucleCHamp:
    do viCompteur = 1 to num-entries(pcListeChamp):
        case entry(viCompteur, pcListeChamp):
            when {&FUSION-Libelleemploie}          or when {&FUSION-CatINSee}                   or when {&FUSION-CoefSalar}                     or when {&FUSION-ClassifCNN}                   or
            when {&FUSION-NiveauSalar}             or when {&FUSION-TauxHoraire}                or when {&FUSION-Typeemploi}                    or when {&FUSION-StatutSalar}                  or
            when {&FUSION-CodeCIPD}                or when {&FUSION-CatCotisant}                or when {&FUSION-DtentreeSalar}                 or when {&FUSION-ancSalar}                     or
            when {&FUSION-ContratSalar}            or when {&FUSION-DtFinSalar}                 or when {&FUSION-DtDepartSalar}                 or when {&FUSION-MotifDepart}                  or
            when {&FUSION-NoSecu}                  or when {&FUSION-CleSecu}                    or when {&FUSION-RegSecu}                       or when {&FUSION-LogSalar}                     or
            when {&FUSION-TraitSalar}              or when {&FUSION-TpsPartiel}                 or when {&FUSION-acompte13}                     or when {&FUSION-absMaladie}                   or
            when {&FUSION-Repancien}               or when {&FUSION-IndRemplace}                or when {&FUSION-MedTravail}                    or when {&FUSION-SIReT}                        or
            when {&FUSION-NIC}                     or when {&FUSION-aPe}                        or when {&FUSION-assuTxSalar}                   or when {&FUSION-TauxTxSalar}                  or
            when {&FUSION-CaisseURSSaF}            or when {&FUSION-NoURSSaF}                   or when {&FUSION-Libeffectif}                   or when {&FUSION-TauxTranspo}                  or
            when {&FUSION-104196}                  or when {&FUSION-CentreaSSeDIC}              or when {&FUSION-NoCIRP}                        or when {&FUSION-FinGestion}                   or
            when {&FUSION-DtFinGestion}            or when {&FUSION-NoaSSeDIC}                  or when {&FUSION-104541}                        or when {&FUSION-104542}                       or
            when {&FUSION-TelephoneConcierge}      or when {&FUSION-TitreemployeImm}            or when {&FUSION-TitreLemployeImm}              or when {&FUSION-NomemployeImm}                or
            when {&FUSION-TelephoneEmployeImm}     or when {&FUSION-DtlentreeSalar}             or when {&FUSION-DtentreeSalarLettre}           or when {&FUSION-anclSalar}                    or
            when {&FUSION-ancSalarLettre}          or when {&FUSION-DtlFinSalar}                or when {&FUSION-DtFinSalarLettre}              or when {&FUSION-NomCompletConcierge}          or
            when {&FUSION-NomCompletEmployeImm}    or when {&FUSION-NomConcierge}               or when {&FUSION-Titreconcierge}                or when {&FUSION-TitreLConcierge}              or
            when {&FUSION-DtLDepartSalar}          or when {&FUSION-DtDepartSalarLettre}        or when {&FUSION-PolitesseConcierge}            or when {&FUSION-PolitesseemployeImm}          or
            when {&FUSION-PortableConcierge}       or when {&FUSION-NationaliteConcierge}       or when {&FUSION-NationaliteemployeImm}         or when {&FUSION-LieuNaissanceConcierge}       or
            when {&FUSION-LieuNaissanceemployeImm} or when {&FUSION-DateNaissanceConcierge}     or when {&FUSION-DateLNaissanceConcierge}       or when {&FUSION-DateNaissanceConciergeLettre} or
            when {&FUSION-DateNaissanceemployeImm} or when {&FUSION-DateLNaissanceemployeImm}   or when {&FUSION-DateNaissanceemployeImmLettre} or when {&FUSION-PortableemployeImm}           or
            when {&FUSION-FaxemployeImm}           or when {&FUSION-emailemployeImm}            or when {&FUSION-FaxConcierge}                  or when {&FUSION-emailConcierge}               or
            when {&FUSION-Qualification}           or when {&FUSION-adresseURSSaF}              or when {&FUSION-SuiteadresseURSSaF}            or when {&FUSION-CodePostalURSSaF}             or
            when {&FUSION-VilleURSSaF}             or when {&FUSION-VilleCedexURSSaF}           or when {&FUSION-SIReTemployeur}                or when {&FUSION-BanqueemployeImm}             or
            when {&FUSION-TituRibemployeImm}       or when {&FUSION-NoCompteBancaireemployeImm} or when {&FUSION-NoBICemployeImm}               or when {&FUSION-BanqueConcierge}              or
            when {&FUSION-TituRibConcierge}        or when {&FUSION-NoCompteBancaireConcierge}  or when {&FUSION-NoBICConcierge} 
            then do:
                if vlBloc1 then next boucleCHamp.

                vlBloc1 = true.
                for first intnt no-lock
                    where intnt.tpcon = pcTypeCttSalarie    /* SY 0114/0244 */ 
                      and intnt.nocon = piNumeroSalarie
                      and intnt.tpidt = pcTypeRoleSalarie   /* "00050"  SY 0114/0244 */
                  , first salar no-lock
                    where salar.tprol = intnt.tpidt
                      and salar.norol = intnt.noidt:
                    assign
                        poFusionSalarie:LibelleEmploie      = salar.lbemp
                        poFusionSalarie:CatINSEE            = salar.insee2
                        poFusionSalarie:CoefSalar           = string(salar.coeff)
                        poFusionSalarie:ClassifCNN          = outilTraduction:getLibelleParam("PACAT", salar.cdcat, "C")    /* SY 1115/0083 libellé long/court sys_pr  */
                        poFusionSalarie:NiveauSalar         = string(salar.nivea)
                        poFusionSalarie:TauxHoraire         = string(Salar.txhor, ">>9.99")
                        poFusionSalarie:TypeEmploi          = outilTraduction:getLibelleParam("PATYP", salar.cdtyp, "C")    /* SY 1115/0083 libellé long/court sys_pr  */
                        poFusionSalarie:StatutSalar         = outilTraduction:getLibelleParam("PASTA", salar.cdsta, "C")    /* SY 1115/0083 libellé long/court sys_pr  */
                        poFusionSalarie:CodeCIPD            = outilTraduction:getLibelleParam("PACIP", salar.cdcip, "C")    /* SY 1115/0083 libellé long/court sys_pr  */
                        poFusionSalarie:CatCotisant         = outilTraduction:getLibelleParam("PACOT", salar.cdcot, "C")    /* SY 1115/0083 libellé long/court sys_pr  */
                        poFusionSalarie:DtEntreeSalar       = dateToCharacter(Salar.dtent)
                        poFusionSalarie:DtLEntreeSalar      = outilFormatage:getDateFormat(salar.dtent, "L")
                        poFusionSalarie:DtEntreeSalarLettre = outilFormatage:getDateFormat(salar.dtent, "LL")
                        poFusionSalarie:AncSalar            = dateToCharacter(salar.dtanc)
                        poFusionSalarie:AncLSalar           = outilFormatage:getDateFormat(salar.dtanc, "L")
                        poFusionSalarie:AncSalarLettre      = outilFormatage:getDateFormat(salar.dtanc, "LL")
                        poFusionSalarie:ContratSalar        = outilTraduction:getLibelleParam("PACTT", salar.cdctt, "C")    /* SY 1115/0083 libellé long/court sys_pr  */
                        poFusionSalarie:DtFinSalar          = dateToCharacter(salar.dtfct)
                        poFusionSalarie:DtLFinSalar         = outilFormatage:getDateFormat(salar.dtfct, "L")
                        poFusionSalarie:DtFinSalarLettre    = outilFormatage:getDateFormat(salar.dtfct, "LL")
                        poFusionSalarie:DtDepartSalar       = dateToCharacter(salar.dtsor)
                        poFusionSalarie:DtLDepartSalar      = outilFormatage:getDateFormat(salar.dtsor, "L")
                        poFusionSalarie:DtDepartSalarLettre = outilFormatage:getDateFormat(salar.dtsor, "LL")
                        poFusionSalarie:MotifDepart         = outilTraduction:getLibelleProg("O_MOT", salar.cdmot)
                        poFusionSalarie:NoSecu              = salar.nosec
                        poFusionSalarie:CleSecu             = salar.clsec
                        poFusionSalarie:RegSecu             = salar.rgsec
                        poFusionSalarie:LogSalar            = if salar.fglog = true then "O" else "N"
                        poFusionSalarie:TraitSalar          = outilTraduction:getLibelleParam("PAACT",salar.cdact, "C")    /* SY 1115/0083 libellé long/court sys_pr  */
                        poFusionSalarie:TpsPartiel          = if salar.fgtps then "O" else "N"
                        poFusionSalarie:Acompte13           = if salar.fgacp then "O" else "N"
                        poFusionSalarie:AbsMaladie          = if salar.fgabs then "O" else "N"
                        poFusionSalarie:RepAncien           = if salar.fgcan then "O" else "N"
                        poFusionSalarie:IndRemplace         = if salar.fgrpl then "O" else "N"
                        poFusionSalarie:MedTravail          = if salar.fgmed then "O" else "N"
                        poFusionSalarie:Qualification       = poFusionSalarie:codeCIPD            /* ajout SY le 19/05/2009 */
                        voRole                              = chargeRole(salar.tprol, salar.norol, piNumeroDocument)
                    .
                    /* Info nom employe */
                    if (salar.tprol = {&TYPEROLE-salarie} and (salar.cdcat = "00002" or salar.cdcat = "00003"))
                    or (salar.tprol = {&TYPEROLE-salariePegase} and salar.lbdiv5 matches substitute("*CODPROFIL=GIGAR&1*", separ[2])) /* SY 0114/0244 */
                    then assign
                        poFusionSalarie:TitreConcierge               = voRole:Titre
                        poFusionSalarie:TitreLConcierge              = voRole:TitreLettre
                        poFusionSalarie:NomConcierge                 = voRole:Nom
                        poFusionSalarie:NomCompletConcierge          = voRole:nomComplet
                        poFusionSalarie:PolitesseConcierge           = voRole:formulePolitesse
                        poFusionSalarie:NationaliteConcierge         = voRole:Nationalite
                        poFusionSalarie:DateNaissanceConcierge       = voRole:DateNaissance
                        poFusionSalarie:LieuNaissanceConcierge       = voRole:LieuNaissance
                        poFusionSalarie:DateLNaissanceConcierge      = outilFormatage:getDateFormat(date(voRole:DateNaissance), "L")
                        poFusionSalarie:DateNaissanceConciergeLettre = outilFormatage:getDateFormat(date(voRole:DateNaissance), "LL")
                    .
                    assign
                        poFusionSalarie:TitreEmployeImm               = voRole:Titre
                        poFusionSalarie:TitreLEmployeImm              = voRole:TitreLettre
                        poFusionSalarie:NomEmployeImm                 = voRole:Nom
                        poFusionSalarie:NomCompletEmployeImm          = voRole:nomComplet
                        poFusionSalarie:PolitesseEmployeImm           = voRole:formulePolitesse
                        poFusionSalarie:NationaliteEmployeImm         = voRole:Nationalite
                        poFusionSalarie:DateNaissanceEmployeImm       = voRole:DateNaissance
                        poFusionSalarie:LieuNaissanceEmployeImm       = voRole:LieuNaissance
                        poFusionSalarie:DateLNaissanceEmployeImm      = outilFormatage:getDateFormat(date(voRole:DateNaissance), "L")
                        poFusionSalarie:DateNaissanceEmployeImmLettre = outilFormatage:getDateFormat(date(voRole:DateNaissance), "LL")
                        voAdresse                                     = chargeAdresse(salar.tprol, salar.norol, piNumeroDocument)
                    .
                    /* Infor adresse employe */
                    voBanque = chargeBanque(salar.tprol, salar.norol).
                    if (salar.tprol = {&TYPEROLE-salarie}       and (salar.cdcat = "00002" or salar.cdcat = "00003"))
                    or (salar.tprol = {&TYPEROLE-salariePegase} and salar.lbdiv5 matches substitute("*CODPROFIL=GIGAR&1*", separ[2]))        /* SY 0114/0244 */ 
                    then assign
                        poFusionSalarie:TelephoneConcierge         = voAdresse:Telephone
                        poFusionSalarie:PortableConcierge          = voAdresse:Portable
                        poFusionSalarie:FaxConcierge               = voAdresse:Fax
                        poFusionSalarie:EmailConcierge             = voAdresse:Mail
                        poFusionSalarie:BanqueConcierge            = voBanque:Banque-Domiciliation
                        poFusionSalarie:TituRibConcierge           = voBanque:Banque-Titulaire
                        poFusionSalarie:NoCompteBancaireConcierge  = voBanque:Banque-IBAN
                        poFusionSalarie:NoBICConcierge             = voBanque:Banque-BIC
                    .
                    assign
                        poFusionSalarie:TelephoneEmployeImm        = voAdresse:Telephone
                        poFusionSalarie:PortableEmployeImm         = voAdresse:Portable
                        poFusionSalarie:FaxEmployeImm              = voAdresse:Fax
                        poFusionSalarie:EmailEmployeImm            = voAdresse:Mail
                        poFusionSalarie:BanqueEmployeImm           = vobanque:Banque-Domiciliation
                        poFusionSalarie:TituRibEmployeImm          = vobanque:Banque-Titulaire
                        poFusionSalarie:NoCompteBancaireEmployeImm = vobanque:Banque-IBAN
                        poFusionSalarie:NoBICEmployeImm            = vobanque:Banque-BIC
                    .
                    // TODO   Whole index !
                    for first etabl no-lock
                        where etabl.nocon = viNumeroMandatSalarie:
                        assign
                            poFusionSalarie:SIRET       = string(etabl.siren, "999999999")
                            poFusionSalarie:NIC         = string(etabl.nonic, "99999")
                            poFusionSalarie:APE         = etabl.cdape
                            poFusionSalarie:AssuTxSalar = if etabl.fgtax then "O" else "N"
                            poFusionSalarie:TauxTxSalar = string(etabl.txtax)
                        .
                        if pcTypeCttSalarie = {&TYPECONTRAT-Salarie}
                        then do:
                            assign
                                poFusionSalarie:CaisseURSSAF  = ORGANISME("OSS", etabl.cdurs)
                                poFusionSalarie:NoURSSAF      = etabl.nours
                                poFusionSalarie:LibEffectif   = outilTraduction:getLibelleParam("PAEFF", etabl.cdeff, "C")    /* SY 1115/0083 libellé long/court sys_pr  */
                                poFusionSalarie:TauxTranspo   = string(etabl.txtra)
                                poFusionSalarie:CodeTranspo   = etabl.cdtra
                                poFusionSalarie:CentreASSEDIC = ORGANISME("OAS", etabl.cdass)
                                poFusionSalarie:NoASSEDIC     = etabl.noass
                                poFusionSalarie:NoCIRP        = etabl.nocre
                                poFusionSalarie:FinGestion    = if etabl.fgint = true then "O" else "N"
                                poFusionSalarie:DtFinGestion  = iMoisToCharacter(etabl.msint)
                            .
                            /* Ajout Sy le 02/12/2010 - Fiche 0510/0070 */
                            for first orsoc no-lock
                                where orsoc.tporg = "OSS"
                                  and orsoc.ident = etabl.cdurs:
                                assign
                                    poFusionSalarie:AdresseURSSAF                = trim(orsoc.adres)
                                    poFusionSalarie:SuiteAdresseURSSAF           = trim(orsoc.cpadr)
                                    poFusionSalarie:CodePostalURSSAF             = trim(orsoc.cdpos)
                                    poFusionSalarie:VilleCedexURSSAF             = trim(orsoc.lbvil)
                                    poFusionSalarie:VilleURSSAF                  = suppCedex(vcVilleCedexURSSAF)
                                    poFusionSalarie:ComplementAdresseIdentURSSAF = trim(orsoc.lbdiv)
                                .
                            end.
                        end.
                        else do:
boucleParam1:
                            do viBoucle = 1 to num-entries(etabl.lbdiv4, separ[2]):
                                vcParam = entry(viBoucle, etabl.lbdiv4, separ[2]).
                                if num-entries(vcParam, "=") < 2 then next boucleParam1.
                                case entry(1, vcParam, "="):
                                    when "DTFIN" then if date(entry(2, vcParam, "=")) <> ? then poFusionSalarie:DtFinGestion = entry(2, vcParam, "=").
                                end case.
                            end.
                            if poFusionSalarie:DtFinGestion <> ? then poFusionSalarie:FinGestion = "O".
boucleParam2:
                            do viBoucle = 1 to num-entries(salar.lbdiv5, separ[2]):
                                vcParam = entry(viBoucle, salar.lbdiv5, separ[2]).
                                if vcParam begins "ORGSOC="
                                then do: 
                                    vcListeOrgSoc = entry(2, vcParam, "=").
                                    leave boucleParam2.
                                end.
                            end.
boucleOrgsoc:
                            do viBoucle = 1 to num-entries(vcListeOrgSoc):
                                vcOrgSocPegase = entry(viBoucle, vcListeOrgSoc).
                                if vcOrgSocPegase begins "U" then do: 
                                    /* Recherche des informations dans la table de correspondance */
                                    // TODO  utiliser la classe pclie parametrageCorrespondance.cls
                                    find first pclie no-lock
                                        where pclie.tppar = "PGCOR"
                                          and pclie.zon01 = (if etabl.tpcon = {&TYPECONTRAT-mandat2Gerance} then mtoken:cDeviseReference else mtoken:cRefCopro)
                                          and pclie.zon02 = vcOrgSocPegase no-error.
                                    if available pclie and pclie.zon05 > ""
                                    then for first csscptcol no-lock 
                                        where csscptcol.soc-cd   = integer(pclie.zon01)
                                          and csscptcol.coll-cle = pclie.zon05
                                          and csscptcol.etab-cd  = etabl.nocon
                                      , first ifour no-lock
                                         where ifour.soc-cd = csscptcol.soc-cd 
                                           and ifour.coll-cle = csscptcol.coll-cle 
                                           and ifour.cpt-cd = pclie.zon06:
                                        assign
                                            poFusionSalarie:CaisseURSSAF       = trim(ifour.nom)
                                            poFusionSalarie:AdresseURSSAF      = trim(ifour.adr[1])
                                            poFusionSalarie:SuiteAdresseURSSAF = trim(ifour.adr[2])
                                            poFusionSalarie:CodePostalURSSAF   = trim(ifour.cp)
                                            poFusionSalarie:VilleCedexURSSAF   = trim(ifour.ville)
                                            poFusionSalarie:VilleURSSAF        = SuppCedex(vcVilleCedexURSSAF)
                                        .
                                    end.
                                    leave boucleOrgsoc.
                                end.
                            end.
                        end.
                    end.
                    /* Ajout SY le 02/12/2010 */
                    // TODO   UNE SEULE ASSIGNATION DANS LA BOUCLE ??!! Faire leave ??? N'y a t'il pas de ctrat.tpcon ????
                    for each ctrat no-lock
                        where ctrat.nocon = viNumeroMandatSalarie
                      , first vbRoles no-lock
                        where vbRoles.tprol = ctrat.tprol
                          and vbRoles.norol = ctrat.norol
                      , first ctanx no-lock
                        where ctanx.tpcon = {&TYPECONTRAT-TVAIntracommunautaire}
                          and ctanx.tprol = "99999"
                          and ctanx.norol = vbRoles.notie:
                        if ctanx.nosir <> 0 
                        then vcSIRETemployeur = string(ctanx.nosir, "999999999") + string(ctanx.cptbq, "99999").
                    end.
                    assign
                        poFusionSalarie:VilleCedexURSSAF = vcVilleCedexURSSAF
                        poFusionSalarie:SIRETemployeur   = vcSIRETemployeur
                    .
                end.
            end.
            when {&FUSION-SoldeencoursCP}           or when {&FUSION-SoldePeriodeMoins1CP}           or when {&FUSION-SoldePeriodeMoins2CP}           or 
            when {&FUSION-JoursacquisencoursCP}     or when {&FUSION-JoursacquisPeriodeMoins1CP}     or when {&FUSION-JoursacquisPeriodeMoins2CP}     or
            when {&FUSION-JoursancienneteencoursCP} or when {&FUSION-JoursanciennetePeriodeMoins1CP} or when {&FUSION-JoursanciennetePeriodeMoins2CP} or
            when {&FUSION-JoursPrisencoursCP}       or when {&FUSION-JoursPrisPeriodeMoins1CP}       or when {&FUSION-JoursPrisPeriodeMoins2CP}
            then do:
                if vlBloc2 then next boucleCHamp.

                vlBloc2 = true.
                for last conge no-lock
                    where conge.tprol = {&TYPEROLE-salarie}            /* table de la Paie MaGI uniquement */
                      and conge.norol = piNumeroSalarie:
                    assign
                        poFusionSalarie:SoldePeriodeMoins2CP = montantToCharacter(conge.tbcpl[3] + conge.tbcpa[3] - conge.tbjco[3] - conge.tbjpa[3], false)
                        poFusionSalarie:SoldePeriodeMoins1CP = montantToCharacter(conge.tbcpl[2] + conge.tbcpa[2] - conge.tbjco[2] - conge.tbjpa[2], false)
                        poFusionSalarie:SoldeEncoursCP       = montantToCharacter(conge.tbcpl[1] + conge.tbcpa[1] - conge.tbjco[1] - conge.tbjpa[1], false)
                        poFusionSalarie:JoursAcquisPeriodeMoins2CP     = montantToCharacter(conge.tbcpl[3], false)
                        poFusionSalarie:JoursAcquisPeriodeMoins1CP     = montantToCharacter(conge.tbcpl[2], false)
                        poFusionSalarie:JoursAcquisEncoursCP           = montantToCharacter(conge.tbcpl[1], false)
                        poFusionSalarie:JoursAnciennetePeriodeMoins2CP = montantToCharacter(conge.tbcpa[3], false)
                        poFusionSalarie:JoursAnciennetePeriodeMoins1CP = montantToCharacter(conge.tbcpa[2], false)
                        poFusionSalarie:JoursAncienneteEncoursCP       = montantToCharacter(conge.tbcpa[1], false)
                        poFusionSalarie:JoursPrisPeriodeMoins2CP       = montantToCharacter(conge.tbjco[3], false)
                        poFusionSalarie:JoursPrisPeriodeMoins1CP       = montantToCharacter(conge.tbjco[2], false)
                        poFusionSalarie:JoursPrisEncoursCP             = montantToCharacter(conge.tbjco[1], false)
                    .
                end.
            end.
            /* NP 0108/0109 DIF */
            when {&FUSION-DateDebutPeriodeDif} or when {&FUSION-DateFinPeriodeDif}     or when {&FUSION-ListeMoisFormation} or
            when {&FUSION-ListeMotifFormation} or when {&FUSION-ListeNbHeureFormation} or when {&FUSION-NumeroSalarie}
            then do:
                if vlBloc3 then next boucleCHamp.

                assign
                    vlBloc3                             = true
                    poFusionSalarie:NumeroSalarie       = string(piNumeroSalarie)
                    poFusionSalarie:DateDebutPeriodeDif = ""
                    poFusionSalarie:DateFinPeriodeDif   = ""
                .
                for first cttac no-lock
                    where cttac.tpcon = {&TYPECONTRAT-Salarie}         /* données de la Paie MaGI uniquement */
                      and cttac.nocon = piNumeroSalarie
                      and cttac.tptac = {&TYPETACHE-DIF}:
                    assign
                        poFusionSalarie:DateDebutPeriodeDif = (if num-entries(cttac.lbdiv3, "¤") > 1 then entry(2, cttac.lbdiv3, "¤") else "")
                        poFusionSalarie:DateFinPeriodeDif   = (if num-entries(cttac.lbdiv3, "¤") > 2 then entry(3, cttac.lbdiv3, "¤") else "")
                    .
                end.
                if poFusionSalarie:DateDebutPeriodeDif > "" and poFusionSalarie:DateFinPeriodeDif > ""
                then do:
                    assign
                        viMoisPaieDebut = integer(string(year(date(poFusionSalarie:DateDebutPeriodeDif)), "9999") + string(month(date(poFusionSalarie:DateDebutPeriodeDif)), "99"))
                        viMoisPaieFin = integer(string(year(date(poFusionSalarie:DateFinPeriodeDif)),   "9999") + string(month(date(poFusionSalarie:DateFinPeriodeDif)),   "99"))
                    .
                    for each difuti no-lock
                        where difuti.tprol = {&TYPEROLE-salarie}
                          and difuti.norol = piNumeroSalarie
                          and difuti.mspai >= viMoisPaieDebut
                          and difuti.mspai <= viMoisPaieFin:
                        assign
                            poFusionSalarie:listeMoisFormation    = poFusionSalarie:ListeMoisFormation + chr(10)
                                                                  + substring(string(difuti.mspai), 5, 2, "character")
                                                                  + "/" + substring(string(difuti.mspai), 1, 4, "character")
                            poFusionSalarie:listeMotifFormation   = poFusionSalarie:ListeMotifFormation + chr(10) + difuti.motif
                            poFusionSalarie:listeNbHeureFormation = substitute("&1&2&3&4",
                                                                        poFusionSalarie:ListeNbHeureFormation,
                                                                        chr(10),
                                                                        difuti.nbheu,
                                                                        if difuti.nbheu > 1 then " heures" else " heure")
                        .
                    end.
                    assign
                        poFusionSalarie:listeMoisFormation    = trim(poFusionSalarie:listeMoisFormation, chr(10))
                        poFusionSalarie:listeMotifFormation   = trim(poFusionSalarie:ListeMotifFormation, chr(10))
                        poFusionSalarie:listeNbHeureFormation = trim(poFusionSalarie:listeNbHeureFormation, chr(10))
                    .
                end.
            end.
        end case.
    end.
    delete object voAdresse no-error.
    delete object voRole    no-error.

end procedure.
