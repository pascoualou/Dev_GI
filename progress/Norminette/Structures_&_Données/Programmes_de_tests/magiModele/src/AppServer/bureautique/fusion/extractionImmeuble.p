/*------------------------------------------------------------------------
File        : extractionImmeuble.p
Description : Recherche des donnees de fusion immeuble
Author(s)   : kantena - 2018/01/15
Notes       : appelé par extract.p
----------------------------------------------------------------------*/
{preprocesseur/fusion/fusionImmeuble.i}
{preprocesseur/famille2tiers.i}
{preprocesseur/listeRubQuit2TVA.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/type2Tache.i}

using bureautique.fusion.classe.fusionImmeuble.
using bureautique.fusion.classe.fusionAdresse.
using bureautique.fusion.classe.fusionRole.
using bureautique.fusion.classe.fusionBanque.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/glbsepar.i}
{ImmeubleEtLot/include/fctequip.i}
{bureautique/fusion/include/fctexport.i}
{bureautique/fusion/include/decodorg.i}

/* Mapping entre le code champ fusion et le type de diagnostic de la tache  */
define variable gcDiagnosticEtude as character no-undo extent 22 initial [
    {&FUSION-Diagnosticamiante},"00001",
     {&FUSION-DiagnosticTermites},"00002",
     {&FUSION-DiagnosticSaturnisme},"00003",
     {&FUSION-DiagnosticMerule},"00004",
     {&FUSION-DiagnosticCapricorne},"00005",
     {&FUSION-DiagnosticRadon},"00006",
     {&FUSION-DiagnosticInstallGaz},"00007",
     {&FUSION-DiagnosticRisqueTechno},"00008",
     {&FUSION-DiagnosticPerfenerg},"00009",
     {&FUSION-Diagnosticelectricite},"00010",
     {&FUSION-Diagnosticassainissement}"00011"].
/* Mapping entre le code champ fusion et le type d'etude technique de la tache  */
define variable gcEtudeTechnique as character no-undo extent 6 initial [
    {&FUSION-etudeTechniquePlomb},"00001",
    {&FUSION-etudeTechniqueascenceur},"00002",
    {&FUSION-etudeTechniqueaeraulique},"00006"].

procedure extractionImmeuble:
    /*------------------------------------------------------------------------------
     Purpose:
     Notes: service de champs fusion immeuble 
    ------------------------------------------------------------------------------*/
    define input        parameter piNumeroImmeuble as integer   no-undo.
    define input        parameter piNumeroDocument as int64     no-undo.
    define input        parameter pcTypeRole       as character no-undo.
    define input        parameter piNumeroRole     as integer   no-undo.
    define input        parameter pcListeChamp     as character no-undo.
    define input-output parameter poFusionImmeuble as class fusionImmeuble no-undo.

    define variable viTempo                     as integer   no-undo.
    define variable vcSurfaceTerrain            as character no-undo.
    define variable vcTmp                       as character no-undo.
    define variable vcListeDigicodeDestinataire as character no-undo.
    define variable vcListeCourteDigicodeDestin as character no-undo.
    define variable vhProcSurface               as handle    no-undo.
    define variable vhProcTel                   as handle    no-undo.
    define variable viCompteur                  as integer   no-undo.
    define variable vlBloc1                     as logical   no-undo.
    define variable vlBloc2                     as logical   no-undo.
    define variable vlBloc3                     as logical   no-undo.
    define variable vlBloc4                     as logical   no-undo.
    define variable vlBloc5                     as logical   no-undo.
    define variable vlBloc6                     as logical   no-undo.
    define variable vlBloc7                     as logical   no-undo.
    define variable vlBloc8                     as logical   no-undo.
    define variable vlBloc9                     as logical   no-undo.
    define variable vlBloc10                    as logical   no-undo.
    define variable pcLibelleChamp              as character no-undo.
    define variable voAdresse                   as class fusionAdresse no-undo.
    define variable voRole                      as class fusionRole    no-undo.
    
    define buffer intnt   for intnt.
    define buffer vbIntnt for intnt.
    define buffer vbImage for image.
    define buffer vbRoles for roles.
    define buffer local   for local.
    define buffer cpuni   for cpuni.
    define buffer unite   for unite.
    define buffer tiers   for tiers.
    define buffer secte   for secte.
    define buffer ctrat   for ctrat.
    define buffer tache   for tache.
    define buffer ctanx   for ctanx.
    define buffer pclie   for pclie.
    define buffer imble   for imble.
    define buffer sys_pr  for sys_pr.
    define buffer equipBien for equipBien.


boucleCHamp:
    do viCompteur = 1 to num-entries(pcListeChamp):
        pcLibelleChamp = entry(viCompteur, pcListeChamp).
        case pcLibelleChamp:
            when {&FUSION-NoBien}               then poFusionImmeuble:NoBien = string(piNumeroImmeuble).
            when {&FUSION-equipement_collectif} then poFusionImmeuble:EquipementCollectif = formateEquipement(piNumeroImmeuble).
            when {&FUSION-NomImmeuble}          then for first imble no-lock
                where imble.noimm = piNumeroImmeuble:
                poFusionImmeuble:nomImmeuble = imble.Lbnom.
            end.
            when {&FUSION-adresse_Bien} or when {&FUSION-Suite_adresse_Bien} or when {&FUSION-Code_Postal_Bien}
         or when {&FUSION-Ville_Bien}   or when {&FUSION-TelephoneBien}      or when {&FUSION-VilleCedex_Bien}
         or when {&FUSION-111634} then do:
                if vlBloc1 then next boucleCHamp.
                vlBloc1 = true.
                assign
                    voAdresse                           = chargeAdresse({&TYPEBIEN-immeuble}, piNumeroImmeuble, piNumeroDocument)
                    poFusionImmeuble:Adresse_Bien       = voAdresse:adresse
                    poFusionImmeuble:Suite_Adresse_Bien = voAdresse:complementVoie
                    poFusionImmeuble:Code_Postal_Bien   = voAdresse:codePostal
                    poFusionImmeuble:Ville_Bien         = voAdresse:ville
                    poFusionImmeuble:TelephoneBien      = voAdresse:telephone
                    poFusionImmeuble:Ville_Cedex_Bien   = voAdresse:cedex
                    poFusionImmeuble:ComplementAdresseIdent_Bien = voAdresse:identAdresse
                .
            end.
            when {&FUSION-Date_Construction_Immeuble} or when {&FUSION-DatelConstructionImmeuble} or when {&FUSION-DateConstructionImmeubleLettre}
            then do:
                if vlBloc2 then next boucleCHamp.
                vlBloc2 = true.
                for first intnt no-lock
                    where intnt.tpidt = {&TYPEBIEN-immeuble}
                      and intnt.noidt = piNumeroImmeuble
                      and intnt.tpcon = {&TYPECONTRAT-construction}
                  , first ctrat no-lock
                    where ctrat.tpcon = intnt.tpcon
                      and ctrat.nocon = intnt.nocon:
                    assign
                        poFusionImmeuble:Date_Construction_Immeuble     = dateToCharacter(ctrat.dtdeb)
                        poFusionImmeuble:DatelConstructionImmeuble      = outilFormatage:getDateFormat(ctrat.dtdeb, "L")
                        poFusionImmeuble:DateConstructionImmeubleLettre = outilFormatage:getDateFormat(ctrat.dtdeb, "LL")
                    .
                end.
            end.
            when {&FUSION-Photo_immeuble} then for first vbImage no-lock
                where vbImage.tpidt = {&TYPEBIEN-immeuble}
                  and vbImage.noidt = piNumeroImmeuble:
                poFusionImmeuble:photo_immeuble = vbImage.NmImg.
            end.
            when {&FUSION-Secteur_lot}         or when {&FUSION-Surface_Terrain}      or when {&FUSION-DebutPeriodeChauffe}
         or when {&FUSION-FinPeriodeChauffe}   or when {&FUSION-Type_Chauffage_IMM}   or when {&FUSION-Mode_Chauffage_IMM}
         or when {&FUSION-Type_Habitation_IMM} or when {&FUSION-Regime_Juridique_IMM} or when {&FUSION-Type_eau_Chaude_IMM}
            then do:
                if vlBloc3 then next boucleCHamp.
                vlBloc3 = true.
                for first imble no-lock
                    where imble.noimm = piNumeroImmeuble:
                    if imble.after = 2 then do:
                        if not valid-handle(vhProcSurface) then do:
                            run immeubleEtLot/surface_CRUD.p persistent set vhProcSurface.
                            run getTokenInstance in vhProcSurface(mToken:JSessionId).
                        end.
                        run formateSurface in vhprocSurface(imble.sfter, imble.after, imble.uster, output vcSurfaceTerrain).
                        poFusionImmeuble:Surface_Terrain = vcSurfaceTerrain.
                    end.
                    else poFusionImmeuble:Surface_Terrain = substitute("&1 &2",
                                                                montantToCharacter(imble.sfter, false), 
                                                                outilTraduction:getLibelleParam("UTSUR", imble.uster)).
                    {&_proparse_ prolint-nowarn(wholeindex)}
                    for first secte no-lock
                        where secte.cdsec = imble.cdsec:
                        poFusionImmeuble:secteur_lot = secte.lbsec.
                    end.
                    if num-entries(imble.lbdiv, "&") >= 6 then poFusionImmeuble:DebutPeriodeChauffe = entry(6, imble.lbdiv, "&").
                    if num-entries(imble.lbdiv, "&") >= 7 then poFusionImmeuble:FinPeriodeChauffe   = entry(7, imble.lbdiv, "&").
                    find first pclie no-lock
                        where pclie.tppar = "tpImm" 
                          and pclie.zon01 = imble.tpimm no-error.
                    assign
                        poFusionImmeuble:Type_Habitation_IMM  = if available pclie then pclie.zon02 else outilTraduction:getLibelleParam("TPIMM", imble.tpimm)
                        poFusionImmeuble:Regime_Juridique_IMM = outilTraduction:getLibelleParam("CLMPR", imble.TpPropriete)     /* Type de propriété (clameur) */
                        poFusionImmeuble:Type_Chauffage_IMM   = outilTraduction:getLibelleParam("TPCHA", imble.tpcha)
                        poFusionImmeuble:Mode_Chauffage_IMM   = outilTraduction:getLibelleParam("MDCHA", imble.MdCha)
                    .
                    /* Existence "Eau chaude individuelle" dans les equipements de l'immeuble */    /* SY 0715/0009 */
                    for first equipBien no-lock
                        where equipBien.cTypeBien       = {&TYPEBIEN-immeuble}
                          and equipBien.iNumeroBien     = imble.noimm
                          and equipBien.cCodeEquipement = "00050": /* Eau chaude individuelle */
                        poFusionImmeuble:Type_Eau_Chaude_IMM = (if equipBien.fgOuiNon then outilTraduction:getLibelle(111514) else outilTraduction:getLibelle(111513)).
                    end.
                end.
            end.
            when {&FUSION-NumSyndicexterne}        or when {&FUSION-TitreSyndicexterne}             or when {&FUSION-TitreLSyndicexterne}
         or when {&FUSION-NomSyndicexterne}        or when {&FUSION-adresseSyndicexterne}           or when {&FUSION-SuiteadresseSyndicexterne}
         or when {&FUSION-CodePostalSyndicexterne} or when {&FUSION-VilleSyndicexterne}             or when {&FUSION-FgSyndicMdt}
         or when {&FUSION-VilleCedexSyndicexterne} or when {&FUSION-NomCompletSyndicexterneContact} or when {&FUSION-TitreLSyndicexterneContact}
         or when {&FUSION-111631} then do:                 /* PL : 11/01/2016 - (Fiche : 0711/0069) */
                if vlBloc4 then next boucleCHamp.
                vlBloc4 = true.
                find first imble no-lock
                    where imble.noimm = piNumeroImmeuble
                      and (imble.tprol = {&TYPEROLE-Syndicexterne} or imble.tprol = "FOU")     /* Modif SY le 14/04/2010 */
                      and imble.norol <> 0 no-error.
                if available imble then assign
                    voRole                                      = chargeRole(imble.tprol, imble.norol, piNumeroDocument)
                    poFusionImmeuble:NumSyndicExterne    = string(imble.norol)
                    poFusionImmeuble:TitreSyndicExterne  = voRole:Titre
                    poFusionImmeuble:TitreLSyndicExterne = voRole:titreLettre
                    poFusionImmeuble:NomSyndicexterne    = voRole:Nom
                    poFusionImmeuble:NomCompletSyndicExterneContact = voRole:nomCompletContact
                    poFusionImmeuble:TitreLSyndicExterneContact = voRole:titreLettreContact
                    voAdresse                                   = chargeAdresse(imble.tprol, imble.norol, piNumeroDocument)
                    poFusionImmeuble:AdresseSyndicExterne       = voAdresse:adresse
                    poFusionImmeuble:SuiteAdresseSyndicExterne  = voAdresse:complementVoie
                    poFusionImmeuble:CodePostalSyndicExterne    = voAdresse:codePostal
                    poFusionImmeuble:VilleSyndicExterne         = voAdresse:ville
                    poFusionImmeuble:VilleCedexSyndicExterne    = voAdresse:cedex
                    /* PL : 11/01/2016 - (Fiche : 0711/0069) */
                    poFusionImmeuble:ComplementAdresseIdentSyndicExterne = voAdresse:identAdresse
                .
                poFusionImmeuble:FgSyndicMdt = "OUI".
                /* Modif SY le 14/04/2010 */
                if available imble and (imble.tprol = {&TYPEROLE-Syndicexterne} or imble.tprol = "FOU") and imble.norol <> 0
                then poFusionImmeuble:FgSyndicMdt = "OUI".  // on aurait pu faire then . Mais pas terrible.
                else for each intnt no-lock
                    where intnt.tpcon = {&TYPECONTRAT-mandat2Syndic}
                      and intnt.tpidt = {&TYPEBIEN-immeuble}
                      and intnt.noidt = piNumeroImmeuble
                  , first ctrat no-lock
                    where ctrat.tpcon = intnt.tpcon
                      and ctrat.nocon = intnt.nocon
                      and (ctrat.dtree = ? or ctrat.dtree > today):
                    poFusionImmeuble:FgSyndicMdt = "NON".
                    {&_proparse_ prolint-nowarn(blocklabel)}
                    leave.
                end.
            end.
            when {&FUSION-ListeDigicodeDestinataire} or when {&FUSION-ListeCourteDigicodeDestinataire}
            then do:
                if vlBloc5 then next boucleCHamp.
                vlBloc5 = true.
                case pcTypeRole:
                    when {&TYPEROLE-locataire} then do:                /* Digicode de l'immeuble */
                        run frmDigicode({&TYPEBIEN-immeuble}, piNumeroImmeuble, "", "", "", input-output vcListeDigicodeDestinataire, input-output vcListeCourteDigicodeDestin).
                        /* Digicode des lots */
                        for each unite no-lock
                            where unite.nomdt = integer(truncate(piNumeroRole / 100000, 0))
                              and unite.noapp = integer(substring(string(piNumeroRole, "9999999999"), 6, 3, "character"))
                              and unite.noact = 0
                          , each cpuni no-lock
                            where cpuni.nomdt = unite.nomdt
                              and cpuni.noapp = unite.noapp
                              and cpuni.nocmp = unite.nocmp
                          , first local no-lock
                            where local.noimm = cpuni.noimm
                              and local.nolot = cpuni.nolot:
                            run frmDigicode({&TYPEBIEN-lot}, piNumeroImmeuble, local.cdbat, local.lbdiv, local.cdesc, input-output vcListeDigicodeDestinataire, input-output vcListeCourteDigicodeDestin).
                        end.
                    end.
                    when {&TYPEROLE-coproprietaire} then do:            /* Digicode de l'immeuble */
                        run frmDigicode({&TYPEBIEN-immeuble}, piNumeroImmeuble, "", "", "", input-output vcListeDigicodeDestinataire, input-output vcListeCourteDigicodeDestin).
                        /* Digicode des lots */
                        for each intnt no-lock
                            where intnt.tpcon = {&TYPECONTRAT-titre2copro}
                              and intnt.tpidt = {&TYPEROLE-coproprietaire}
                              and intnt.noidt = piNumeroRole
                          , each vbIntnt no-lock
                            where vbIntnt.tpcon = intnt.tpcon
                              and vbIntnt.nocon = intnt.nocon
                              and vbIntnt.tpidt = {&TYPEBIEN-lot}
                              and vbIntnt.nbden = 0
                          , first local no-lock
                            where local.noloc = vbIntnt.noidt
                              and local.noimm = piNumeroImmeuble:
                            run FrmDigicode({&TYPEBIEN-lot}, piNumeroImmeuble, local.cdbat, local.lbdiv, local.cdesc, input-output vcListeDigicodeDestinataire, input-output vcListeCourteDigicodeDestin).
                        end.
                        poFusionImmeuble:ListeCourteDigicodeDestinataire = vcListeCourteDigicodeDestin.
                    end.
                    when {&TYPEROLE-mandant} then do:           /* Digicode de l'immeuble */
                        run FrmDigicode({&TYPEBIEN-immeuble}, piNumeroImmeuble, "", "", "", input-output vcListeDigicodeDestinataire, input-output vcListeCourteDigicodeDestin).
                        /* Digicode des lots */
                        for each intnt no-lock
                            where intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
                              and intnt.tpidt = {&TYPEROLE-mandant}
                              and intnt.noidt = piNumeroRole
                          , each vbIntnt no-lock
                            where vbIntnt.tpcon = intnt.tpcon
                              and vbIntnt.nocon = intnt.nocon
                              and vbIntnt.tpidt = {&TYPEBIEN-lot}
                              and vbIntnt.nbden = 0
                         ,  first local no-lock
                            where local.noloc = vbIntnt.noidt
                              and local.noimm = piNumeroImmeuble:
                            run FrmDigicode({&TYPEBIEN-lot}, piNumeroImmeuble, local.cdbat, local.lbdiv, local.cdesc, input-output vcListeDigicodeDestinataire, input-output vcListeCourteDigicodeDestin).
                        end.
                        poFusionImmeuble:ListeCourteDigicodeDestinataire = vcListeCourteDigicodeDestin.
                    end.
                    otherwise do:            /* Digicode de l'immeuble */
                        run frmDigicode({&TYPEBIEN-immeuble}, piNumeroImmeuble, "", "", "", input-output vcListeDigicodeDestinataire, input-output vcListeCourteDigicodeDestin).
                        /* Digicode des lots */
                        for each local no-lock
                            where local.noimm = piNumeroImmeuble
                                break by local.cdbat by local.lbdiv by local.cdesc:
                            if first-of(local.cdesc) then
                            run frmDigicode({&TYPEBIEN-lot}, piNumeroImmeuble, local.cdbat, local.lbdiv, local.cdesc, input-output vcListeDigicodeDestinataire, input-output vcListeCourteDigicodeDestin).
                        end.
                        poFusionImmeuble:ListeCourteDigicodeDestinataire = vcListeCourteDigicodeDestin.
                    end.
                end case.
            end.
            when {&FUSION-NomContactDomotique}      or when {&FUSION-HeureDebut1Loge1}         or when {&FUSION-HeureDebut1Loge2}
         or when {&FUSION-HeureDebut2Loge1}         or when {&FUSION-HeureDebut2Loge2}         or when {&FUSION-HeureFin1Loge1}
         or when {&FUSION-HeureFin1Loge2}           or when {&FUSION-HeureFin2Loge1}           or when {&FUSION-HeureFin2Loge2}
         or when {&FUSION-ListeJoursouvertureLoge1} or when {&FUSION-ListeJoursouvertureLoge2} or when {&FUSION-Telephone1Loge}
         or when {&FUSION-Telephone2Loge}           or when {&FUSION-CommentairesDomotique}
            then do: 
                if vlBloc6 then next boucleCHamp.
                vlBloc6 = true.
                for first intnt no-lock            /* Loge */
                    where intnt.tpcon = {&TYPECONTRAT-construction}
                      and intnt.tpidt = {&TYPEBIEN-immeuble}
                      and intnt.noidt = piNumeroImmeuble
                  , first tache no-lock
                    where tache.tpcon = {&TYPECONTRAT-construction}
                      and tache.nocon = intnt.nocon
                      and tache.tptac = {&TYPETACHE-loge}
                      and tache.notac = 1:
                    if tache.cdreg > "" then assign
                        voRole                               = chargeRole(entry(1, tache.cdreg), integer(entry(2,tache.cdreg)), piNumeroDocument)
                        poFusionImmeuble:NomContactDomotique = voRole:nomComplet
                    .
                    else poFusionImmeuble:NomContactDomotique = tache.tpges.
                    assign
                        poFusionImmeuble:HeureDebut1Loge1         = entry(1, entry(1, tache.tphon, SEPAR[1]), SEPAR[2])
                        poFusionImmeuble:HeureDebut2Loge1         = entry(1, entry(2, tache.tphon, SEPAR[1]), SEPAR[2])
                        poFusionImmeuble:HeureFin1Loge1           = entry(2, entry(1, tache.tphon, SEPAR[1]), SEPAR[2])
                        poFusionImmeuble:HeureFin2Loge1           = entry(2, entry(2, tache.tphon, SEPAR[1]), SEPAR[2])
                        poFusionImmeuble:HeureDebut1Loge2         = entry(1, entry(1, tache.ntges, SEPAR[1]), SEPAR[2])
                        poFusionImmeuble:HeureDebut2Loge2         = entry(1, entry(2, tache.ntges, SEPAR[1]), SEPAR[2])
                        poFusionImmeuble:HeureFin1Loge2           = entry(2, entry(1, tache.ntges, SEPAR[1]), SEPAR[2])
                        poFusionImmeuble:HeureFin2Loge2           = entry(2, entry(2, tache.ntges, SEPAR[1]), SEPAR[2])
                        vcTmp                                     = entry(3, tache.tphon, SEPAR[1])
                        poFusionImmeuble:ListeJoursOuvertureLoge1 = (if substring(vcTmp, 1, 1, "character") <> "0" then outilTraduction:getLibelle(102767) + " " else "")
                                                                  + (if substring(vcTmp, 2, 1, "character") <> "0" then outilTraduction:getLibelle(102768) + " " else "")
                                                                  + (if substring(vcTmp, 3, 1, "character") <> "0" then outilTraduction:getLibelle(102769) + " " else "")
                                                                  + (if substring(vcTmp, 4, 1, "character") <> "0" then outilTraduction:getLibelle(102770) + " " else "")
                                                                  + (if substring(vcTmp, 5, 1, "character") <> "0" then outilTraduction:getLibelle(102771) + " " else "")
                                                                  + (if substring(vcTmp, 6, 1, "character") <> "0" then outilTraduction:getLibelle(102772) + " " else "")
                                                                  + (if substring(vcTmp, 7, 1, "character") <> "0" then outilTraduction:getLibelle(102766) else "")
                        vcTmp                                     = entry(3, tache.ntges, SEPAR[1])
                        poFusionImmeuble:ListeJoursOuvertureLoge2 = (if substring(vcTmp, 1, 1, "character") <> "0" then outilTraduction:getLibelle(102767) + " " else "")
                                                                  + (if substring(vcTmp, 2, 1, "character") <> "0" then outilTraduction:getLibelle(102768) + " " else "")
                                                                  + (if substring(vcTmp, 3, 1, "character") <> "0" then outilTraduction:getLibelle(102769) + " " else "")
                                                                  + (if substring(vcTmp, 4, 1, "character") <> "0" then outilTraduction:getLibelle(102770) + " " else "")
                                                                  + (if substring(vcTmp, 5, 1, "character") <> "0" then outilTraduction:getLibelle(102771) + " " else "")
                                                                  + (if substring(vcTmp, 6, 1, "character") <> "0" then outilTraduction:getLibelle(102772) + " " else "")
                                                                  + (if substring(vcTmp, 7, 1, "character") <> "0" then outilTraduction:getLibelle(102766) else "")
                        poFusionImmeuble:Telephone1Loge           = entry(1, tache.dcreg, SEPAR[1])
                        poFusionImmeuble:Telephone2Loge           = entry(2, tache.dcreg, SEPAR[1])
                    .
                    if tache.lbdiv > "" then assign
                        poFusionImmeuble:CommentairesDomotique = entry(1, tache.lbdiv, SEPAR[1])
                        poFusionImmeuble:CommentairesDomotique = poFusionImmeuble:CommentairesDomotique 
                                                               + (if entry(2, tache.lbdiv,separ[1]) > "" then chr(10) else "")
                                                               + entry(2, tache.lbdiv, separ[1])
                        poFusionImmeuble:CommentairesDomotique = poFusionImmeuble:CommentairesDomotique 
                                                               + (if entry(3, tache.lbdiv,separ[1]) > "" then chr(10) else "")
                                                               + entry(3, tache.lbdiv, separ[1])
                    .
                    if tache.lbdiv2 > "" then assign
                        poFusionImmeuble:CommentairesDomotique = poFusionImmeuble:CommentairesDomotique 
                                                               + (if entry(1, tache.lbdiv2, separ[1]) > "" then chr(10) else "")
                                                               + entry(1, tache.lbdiv2, separ[1])
                        poFusionImmeuble:CommentairesDomotique = poFusionImmeuble:CommentairesDomotique 
                                                               + (if entry(2, tache.lbdiv2, separ[1]) > "" then chr(10) else "")
                                                               + entry(2, tache.lbdiv2, separ[1])
                        poFusionImmeuble:CommentairesDomotique = poFusionImmeuble:CommentairesDomotique 
                                                               + (if entry(3,tache.lbdiv2,separ[1]) > "" then chr(10) else "") 
                                                               + entry(3, tache.lbdiv2, separ[1])
                    .
                    if tache.lbdiv3 > "" then assign
                        poFusionImmeuble:CommentairesDomotique = poFusionImmeuble:CommentairesDomotique
                                                               + (if entry(1, tache.lbdiv3, separ[1]) > "" then chr(10) else "")
                                                               + entry(1, tache.lbdiv3, separ[1])
                        poFusionImmeuble:CommentairesDomotique = poFusionImmeuble:CommentairesDomotique
                                                               + (if entry(2, tache.lbdiv3, separ[1]) > "" then chr(10) else "")
                                                               + entry(2, tache.lbdiv3, separ[1])
                        poFusionImmeuble:CommentairesDomotique = poFusionImmeuble:CommentairesDomotique
                                                               + (if entry(3, tache.lbdiv3, separ[1]) > "" then chr(10) else "")
                                                               + entry(3, tache.lbdiv3, separ[1])
                    .
                end.
            end.
            /* 0108/0340 */    /* NP 0115/0039 */
            when {&FUSION-ListeReglementCoproDoSRU} or when {&FUSION-NbLotsPrincipaux} or when {&FUSION-111654} then do:
                if vlBloc7 then next boucleCHamp.
                vlBloc7 = true.
                assign
                    vcTmp                                 = ""
                    poFusionImmeuble:NbLotsPrincipaux     = ""
                    poFusionImmeuble:NbLotsReglementCopro = ""
                .
                if not valid-handle(vhProcTel) then do:
                    run adresse/fcttelep.p persistent set vhProcTel.
                    run getTokenInstance in vhProcTel(mToken:JSessionId).
                end.
                for first intnt no-lock
                    where intnt.tpcon = {&TYPECONTRAT-construction} /* copro */
                      and intnt.tpidt = {&TYPEBIEN-immeuble} /* immeuble */
                      and intnt.noidt = piNumeroImmeuble:
                    for each tache no-lock
                       where tache.tpcon = {&TYPECONTRAT-construction}
                         and tache.nocon = intnt.nocon
                         and tache.tptac = {&TYPETACHE-reglement2copro}     /* réglement copro */
                       break by tache.tpcon:
                       assign
                           poFusionImmeuble:ListeReglementCoproDoSRU = substitute("&1&2 &3 &4 tel: &5 &6&7",
                                                   vcTmp,
                                                   dateToCharacter(tache.dtfin),
                                                   outilFormatage:getNomTiers2("00017", integer(tache.tpges), false), 
                                                   outilFormatage:formatageAdresse("00017", integer(tache.tpges)), 
                                                   entry(3, dynamic-function("donnePremTpTel" in vhProcTel, "00017", integer(tache.tpges), {&TYPETELEPHONE-telephone}), separ[1]), 
                                                   replace(tache.ntreg, chr(10), ""), 
                                                   if last(tache.tpcon) then "" else chr(10)) 
                            /* on garde les nombres de lots du dernier règlement de copro */
                            poFusionImmeuble:NbLotsPrincipaux     = tache.cdreg
                            poFusionImmeuble:NbLotsReglementCopro = string(tache.duree)        /* SY 0415/0128 */
                        .
                    end.
                end. 
            end.
            /* 0108/0340 */ 
            when gcDiagnosticEtude[1]  or when gcDiagnosticEtude[3]  or when gcDiagnosticEtude[5] 
         or when gcDiagnosticEtude[7]  or when gcDiagnosticEtude[9]  or when gcDiagnosticEtude[11]
         or when gcDiagnosticEtude[13] or when gcDiagnosticEtude[15] or when gcDiagnosticEtude[17]
         or when gcDiagnosticEtude[19] or when gcDiagnosticEtude[21] then do:
                if vlBloc8 then next boucleCHamp.

                assign
                    vlBloc8 = true
                    vcTmp   = ""
                .
    boucleDiag:
                do viTempo = 1 to extent(gcDiagnosticEtude) by 2:
                    if pcLibelleChamp = gcDiagnosticEtude[viTempo] then do: viTempo = viTempo + 1. leave boucleDiag. end.
                end.
                for first intnt no-lock
                    where intnt.tpcon = {&TYPECONTRAT-construction}
                      and intnt.tpidt = {&TYPEBIEN-immeuble}
                      and intnt.noidt = piNumeroImmeuble:
                    {&_proparse_ prolint-nowarn(sortaccess)}
                    for each tache no-lock
                        where tache.tpcon = {&TYPECONTRAT-construction}
                          and tache.nocon = intnt.nocon
                          and tache.tptac = {&TYPETACHE-diagnosticTechnique} /* Diagnostic */
                          and tache.dcreg = gcDiagnosticEtude[viTempo]
                          and tache.pdreg = "FALSE"  /* Ajout SY le 02/02/2011 : ignorer Privatif */
                        break by tache.tpcon by tache.dtdeb:
                        vcTmp = substitute("&1&2 &3 &4",
                                           vcTmp, outilTraduction:getLibelleParam("CDDIA", Tache.DcReg), dateToCharacter(tache.dtdeb), tache.utreg).
                        find first sys_pr no-lock 
                            where sys_pr.tppar = "CDPOS"
                              and sys_pr.cdpar = tache.TpFin no-error.
                        vcTmp = vcTmp
                              + (if available sys_pr then " - " + outilTraduction:getLibelle(sys_pr.nome1) else "")
                              + if last(tache.tpcon) then "" else chr(10).
                        /* Ajout SY le 02/02/2011 : Etiquette energie/climat */
                        if tache.dcreg = "00009" 
                        then do:
                            if tache.etqenergie > "" then vcTmp = substitute("&1 Etiquette énergie: &2", vcTmp, tache.etqenergie).
                            if tache.etqclimat  > "" then vcTmp = substitute("&1 Etiquette climat : &2", vcTmp, tache.etqclimat).
                        end.
                    end.
                    run valoriseChampFusion(integer(pcLibelleChamp), outilTraduction:getLibelle(integer(pcLibelleChamp)), vcTmp).
                end.
            end.
            /* SY 1010/0020 */
            when {&FUSION-etiquetteenergie} or when {&FUSION-etiquetteClimat} or when {&FUSION-DateRechDPe}
            then do:
                if vlBloc9 then next boucleCHamp.
                vlBloc9 = true.
                for first intnt no-lock
                    where intnt.tpcon = {&TYPECONTRAT-construction}
                      and intnt.tpidt = {&TYPEBIEN-immeuble}
                      and intnt.noidt = piNumeroImmeuble
                  , each tache no-lock
                    where tache.tpcon = {&TYPECONTRAT-construction}
                       and tache.nocon = intnt.nocon
                       and tache.tptac = {&TYPETACHE-diagnosticTechnique}
                       and tache.dcreg = "00009"     /* DPE */
                       and tache.pdreg = "FALSE"     /*  NON Privatif */
                     by tache.dtdeb: 
                    /* Ajout SY le 02/02/2011 : Etiquette energie/climat */
                    assign
                        poFusionImmeuble:EtiquetteEnergie = tache.etqenergie
                        poFusionImmeuble:EtiquetteClimat  = tache.etqclimat
                        poFusionImmeuble:DateRechDPE      = string(tache.dtdeb)
                    .
                end.
            end.
            /* 0108/0340 */
            when gcEtudeTechnique[1] or when gcEtudeTechnique[3] or when gcEtudeTechnique[5] then do:
                if vlBloc10 then next boucleCHamp.
                vlBloc10 = true.
                vcTmp = "".
    boucleEtude:
                do viTempo = 1 to extent(gcEtudeTechnique) by 2:
                    if pcLibelleChamp = gcEtudeTechnique[viTempo] then do: viTempo = viTempo + 1. leave boucleEtude. end.
                end.
                for first intnt no-lock
                    where intnt.tpcon = {&TYPECONTRAT-construction}
                      and intnt.tpidt = {&TYPEBIEN-immeuble}
                      and intnt.noidt = piNumeroImmeuble:
                    for each tache no-lock
                       where tache.tpcon = {&TYPECONTRAT-construction}
                         and tache.nocon = intnt.nocon
                         and tache.tptac = {&TYPETACHE-miseEnConformite}      /* Etudes */
                         and tache.dcreg = gcEtudeTechnique[viTempo]
                        break by(tache.tpcon):
                        vcTmp = substitute("&1&2 &3 &4", vcTmp, outilTraduction:getLibelleParam("CDETU", Tache.DcReg), dateToCharacter(tache.dtdeb), tache.utreg).
                        find first sys_pr no-lock
                            where sys_pr.tppar = "CDPOS"
                              and sys_pr.cdpar = tache.TpFin no-error.
                        vcTmp = substitute("&1&2&3",
                                    vcTmp,
                                    if available sys_pr then " - " + outilTraduction:getLibelle(sys_pr.nome1) else "",
                                    if last(tache.tpcon) then "" else chr(10)).
                    end.
                    run valoriseChampFusion(integer(pcLibelleChamp), outilTraduction:getLibelle(integer(pcLibelleChamp)), vcTmp).
                end.
            end.
            /* PL : 13/04/2015 (0315/0214) */
            when {&FUSION-NumeroImmatCopro} then for first vbIntnt no-lock /* Récupération du numero d'immatriculation du syndicat de copro */
                where vbIntnt.tpcon = {&TYPECONTRAT-mandat2Syndic}
                  and vbIntnt.tpidt = {&TYPEBIEN-immeuble}
                  and vbIntnt.noidt = piNumeroImmeuble:
                viTempo = vbIntnt.nocon.
                for first intnt no-lock
                    where intnt.tpcon = {&TYPECONTRAT-mandat2Syndic}
                      and intnt.nocon = viTempo
                      and intnt.tpidt = {&TYPEROLE-syndicat2copro}
                  , first vbRoles no-lock
                    where vbRoles.tprol = intnt.tpidt
                      and vbRoles.norol = intnt.noidt
                  , first tiers no-lock
                    where tiers.notie = vbRoles.notie
                  , first ctanx no-lock
                    where ctanx.tpcon = {&TYPECONTRAT-Association}
                     and ctanx.nocon = tiers.nocon :
                    poFusionImmeuble:NumeroImmatCopro = entry(1, ctanx.lbdiv, separ[1]).
                end.
            end.
        end case.
    end.
    if valid-handle(vhProcSurface) then run destroy in vhProcSurface.
    if valid-handle(vhProcTel)     then run destroy in vhProcTel.
    delete object voAdresse no-error.
    delete object voRole    no-error.

end procedure.
