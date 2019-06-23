/*-----------------------------------------------------------------------------
File        : genanqt.p
Purpose     : Génération d'une quittance antérieure à partir d'une date de début
              A partir des tables equit ou aquit, Ctrat, Tache, ...
Author(s)   : DMI -  2018/12/13
Notes       : reprise de adb/src/quit/genanqt_ext.p
derniere revue: 2018/12/21 - SPo: OK
-----------------------------------------------------------------------------*/
{preprocesseur/mode2reglement.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}
{preprocesseur/param2locataire.i}
{preprocesseur/referenceClient.i}
{preprocesseur/profil2rubQuit.i}
{preprocesseur/codeRevisionQuittance.i}
{preprocesseur/codeRubrique.i}

using parametre.pclie.parametrageFournisseurLoyer.
using parametre.pclie.parametrageRubriqueQuittHonoCabinet.

{oerealm/include/instanciateTokenOnModel.i} // Doit être positionnée juste après using //
{application/include/error.i}
{bail/include/tbtmpqtt.i}
{bail/include/tbtmprub.i}

define variable goCollectionHandlePgm as class collection                  no-undo.
define variable goCollectionContrat   as class collection                  no-undo.
define variable goFournisseurLoyer    as class parametrageFournisseurLoyer no-undo.
define variable gcTypeContrat         as character                         no-undo.
define variable giNumeroContrat       as int64                             no-undo.
define variable gdaEntreeLocataire    as date                              no-undo.
define variable gcListeOption         as character                         no-undo.
define variable gcInfo1ereQuittance   as character                         no-undo.
define variable gcMoisModifiable      as character                         no-undo.
define variable ghProc                as handle                            no-undo.

{outils/include/lancementProgramme.i}            // fonctions lancementPgm, suppressionPgmPersistent
{comm/include/prrubhol.i}    // procedures isRubEcla, isRubProCum, valDefProCum8xx

function fCalNoQtt returns decimal private (pcCodePeriode as character, piNoQtt1Qt as integer, pdaDprCal as date, pdaDpr1Qt as date) :
    /*------------------------------------------------------------------------
    Purpose : Procedure de Recherche du no de la 1ere quittance anterieure a generer. On saute le no '0', On travaille en no negatif
    Notes   : d'apres calNoQtt de genantqt_ext.p
    ------------------------------------------------------------------------*/
    define variable viNoQttUse as integer no-undo.
    define variable viNbMoiPer as integer no-undo.
    define variable viNbPerCre as integer no-undo.
    define variable vdaDprTmp  as date    no-undo.
    define variable vdaFprTmp  as date    no-undo.
    define variable vhPrgdat   as handle  no-undo.

    run application/l_prgdat.p persistent set vhPrgdat.
    run getTokenInstance in vhPrgdat(mToken:JSessionId).

    assign
        viNoQttUse = (if piNoQtt1Qt > 0 then -1 else piNoQtt1Qt - 1)
        viNbMoiPer = integer(substring(pcCodePeriode,1,3))
        vdaDprTmp  = pdaDprCal
        viNbPerCre = 0
    .
boucle :
    repeat :
        // Calcul date de fin de periode - Calcul mois quitt et mois traitement GI
        run cl2DatFin in vhPrgdat(vdaDprTmp ,viNbMoiPer, "00002", output vdaFprTmp).
        vdaFprTmp = vdaFprTmp - 1.
        if pdaDpr1Qt <= vdaFprTmp then leave boucle.
        else  // Periode suivante
            assign
                vdaDprTmp  = vdaFprTmp  + 1
                viNbPerCre = viNbPerCre + 1
            .
    end.
    assign viNoQttUse = viNoQttUse - viNbPerCre  + 1.
    run destroy in vhPrgdat.
    return viNoQttUse.

end function.

procedure lancementGenAntQt:
    /*------------------------------------------------------------------------
    Purpose :
    Notes   : service externe
    ------------------------------------------------------------------------*/
    define input        parameter poCollectionContrat as class collection no-undo.
    define input        parameter pdaEntreeLocataire  as date             no-undo.
    define input        parameter pcListeOption       as character        no-undo. // code OUI/NON pour reprise des valeurs de 1ere Quitt
    define input        parameter pcInfo1ereQuittance as character        no-undo. // Info 1ere quittance connue : no # Msqtt # H ou E
    define input        parameter pcMoisModifiable    as character        no-undo. // Code OUI/NON pour faire le test sur le 1er mois modifiable.
    define input-output parameter table for ttQtt.
    define input-output parameter table for ttRub.
    define output       parameter piNoQuittance       as integer          no-undo.
    define output       parameter piMoisQuittance     as integer          no-undo.

    assign
        gcTypeContrat         = poCollectionContrat:getCharacter("cTypeContrat")
        giNumeroContrat       = poCollectionContrat:getInt64("iNumeroContrat")
        gdaEntreeLocataire    = pdaEntreeLocataire
        gcListeOption         = pcListeOption
        gcInfo1ereQuittance   = pcInfo1ereQuittance
        gcMoisModifiable      = pcMoisModifiable
        goCollectionContrat   = poCollectionContrat
        goCollectionHandlePgm = new collection()
        goFournisseurLoyer    = new parametrageFournisseurLoyer({&oui})
    .
    run trtGenAntQt(output piNoQuittance, output piMoisQuittance).
    delete object goFournisseurLoyer no-error.
    suppressionPgmPersistent(goCollectionHandlePgm).
end procedure.

procedure trtGenAntQt private:
    /*------------------------------------------------------------------------
    Purpose : Génération d'une quittance à partir d'une date de début
    Notes   :
    ------------------------------------------------------------------------*/
    define output parameter piNoQuittance   as integer no-undo.
    define output parameter piMoisQuittance as integer no-undo.

    define variable viNoQttUse         as integer   no-undo.
    define variable vcCodeTerme        as character no-undo.
    define variable vcPeriodicite      as character no-undo.
    define variable vlTvaCon           as logical   no-undo.
    define variable viNoQtt1Qt         as integer   no-undo.
    define variable viMsQtt1Qt         as integer   no-undo.
    define variable vcTpQtt1Qt         as character no-undo.
    define variable vdaFapRub          as date      no-undo.
    define variable viMsQttCal         as integer   no-undo.
    define variable viMsQuiCal         as integer   no-undo.
    define variable vdaFinCal          as date      no-undo.
    define variable vdaDprCal          as date      no-undo.
    define variable vdaFprCal          as date      no-undo.
    define variable vdaDpr1Qt          as date      no-undo.
    define variable viNumCal           as integer   no-undo.
    define variable viDenCal           as integer   no-undo.
    define variable viNoRubTmp         as integer   no-undo.
    define variable viNoLibTmp         as integer   no-undo.
    define variable vcLbLibTmp         as character no-undo.
    define variable viCdFamTmp         as character no-undo.
    define variable viCdSfaTmp         as character no-undo.
    define variable vcCdGenTmp         as character no-undo.
    define variable vcCdSigTmp         as character no-undo.
    define variable vcTbRubHis         as character no-undo.
    define variable viNoMdtUse         as integer   no-undo.
    define variable vdaFinBai          as date      no-undo.
    define variable vcLbTmpPdt         as character no-undo.
    define variable viCpUseInc         as integer   no-undo.
    define variable vlRubriqueProratee as logical   no-undo.
    define variable vlRubriqueCumuleee as logical   no-undo.

    define buffer ctrat for ctrat.
    define buffer aquit for aquit.
    define buffer equit for equit.
    define buffer tache for tache.
    define buffer lsirv for lsirv.

    assign
        viNoQtt1Qt         = integer(entry(1, gcInfo1ereQuittance, "#"))
        viMsQtt1Qt         = integer(entry(2, gcInfo1ereQuittance, "#"))
        vcTpQtt1Qt         = entry(3, gcInfo1ereQuittance, "#")
        viNoMdtUse         = truncate(giNumeroContrat / 100000, 0)
        vlTvaCon           = num-entries(gcListeOption, "@") >= 2 and entry(2, gcListeOption, "@") = "TVACONS" // Conservation rub taxe calculees ou transformation en no - 20 rub variables
    .
    // Recherche de la Quittance Modele
    if vcTpQtt1Qt = "H" then do:
        find aquit no-lock
            where aquit.NoLoc = giNumeroContrat
              and aquit.Noqtt = viNoQtt1Qt
              and aquit.MsQtt = viMsQtt1Qt
        no-error.
        if not available aquit then do:
            assign
                vcLbTmpPdt = string(viMsQtt1Qt,"999999")
                vcLbTmpPdt = substitute("&1/&2", substring(vcLbTmpPdt,5,2), substring(vcLbTmpPdt,1,4))
                .
            mError:createErrorGestion({&error}, 100251, substitute("&1|&2", string(viNoQtt1Qt), vcLbTmpPdt)). /// quittance %1 du mois " viMsQtt1Qt " non trouvee en historique
            return.

        end.
        assign // Recuperation de la periodicite & Terme de la 1ere quittance connue
            vcPeriodicite = aquit.pdqtt
            vcCodeTerme   = aquit.cdter
            vdaDpr1Qt     = aquit.dtdpr
        .
    end.
    else do:
        find equit no-lock
            where equit.NoLoc = giNumeroContrat
              and equit.Noqtt = viNoQtt1Qt
              and equit.MsQtt = viMsQtt1Qt
            no-error.
        if not available equit then do:
            assign
                vcLbTmpPdt = string(viMsQtt1Qt,"999999")
                vcLbTmpPdt = substitute("&1/&2", substring(vcLbTmpPdt,5,2), substring(vcLbTmpPdt,1,4))
            .
            mError:createErrorGestion({&error}, 100252, substitute("&1|&2", string(viNoQtt1Qt), vcLbTmpPdt)). // Avis d'echeance no %1 du mois %2 non trouve
            return.

        end.
        assign // Recuperation de la periodicite & Terme de la 1ere quittance connue
            vcPeriodicite = equit.pdqtt
            vcCodeTerme   = equit.cdter
            vdaDpr1Qt     = equit.dtdpr
        .
    end.
    if integer(substring(vcPeriodicite, 1, 3)) = 0 or vdaDpr1Qt = ? then do:
        // Creation des quittances anterieures impossible, Parametres de la 1ere quittance connue errones (Code Periodicite = %1 ; Date debut periode = %2)
        mError:createErrorGestion({&error}, 100253, substitute("&1|&2", vcPeriodicite, string(vdaDpr1Qt))). // Avis d'echeance no %1 du mois %2 non trouve
        return.

    end.
    // Chargement de la table ttQtt
    create ttQtt.
    outils:copyValidField((if vcTpQtt1Qt = "H" then buffer aquit:handle else buffer equit:handle), buffer ttQtt:handle).
    for first ctrat no-lock
            where ctrat.tpcon = gcTypeContrat
              and ctrat.nocon = giNumeroContrat:
        assign
            ttQtt.cNatureBail     = ctrat.ntcon
            ttQtt.iDureeBail      = ctrat.nbdur
            ttQtt.cUniteDureeBail = ctrat.cddur
            ttQtt.daEffetBail     = ctrat.dtdeb
            vdaFinBai             = ctrat.dtfin
        .
    end.
    run CalDatPer(vcPeriodicite, // Calcul des dates de debut et fin de periode
                  gdaEntreeLocataire,
                  vdaFinBai,
                  vcCodeTerme,
                  output vdaDprCal,
                  output vdaFprCal,
                  output vdaFinCal,
                  output viMsQttCal,
                  output viMsQuiCal).

    assign
        viNoQttUse                       = fCalNoQtt(vcPeriodicite, viNoQtt1Qt, vdaDprCal, vdaDpr1Qt) // Calcul du numero de la 1ere quittance anterieure a generer
        ttQtt.iNumeroLocataire           = giNumeroContrat
        ttQtt.iNoQuittance               = viNoQttUse
        ttQtt.iMoisTraitementQuitt       = viMsQttCal
        ttQtt.iMoisReelQuittancement     = viMsQuiCal
        ttQtt.daDebutQuittancement       = gdaEntreeLocataire
        ttQtt.daFinQuittancement         = vdaFinCal
        ttQtt.daDebutPeriode             = vdaDprCal
        ttQtt.daFinPeriode               = vdaFprCal
        ttQtt.cPeriodiciteQuittancement  = vcPeriodicite
        ttQtt.cCodeModeReglement         = {&MODEREGLEMENT-cheque}
        ttQtt.cCodeTerme                 = vcCodeTerme
        ttQtt.daEntre                    = gdaEntreeLocataire
        ttQtt.daSortie                   = vdaFinBai
        ttQtt.dMontantQuittance          = 0
        ttQtt.iNombreRubrique            = 0
        ttQtt.cCodeRevisionDeLaquittance = {&CDREVQTT-aucunerevision}   // Locataire n'ayant pas subi de revision de loyer dans cette quittance
        ttQtt.NbEdt                      = 0
        ttQtt.CdMaj                      = 1         // Modification
        ttQtt.iNumeroMandat              = viNoMdtUse
        ttQtt.CdOri                      = vcTpQtt1Qt
        ttQtt.cNomTable                  = (if vcTpQtt1Qt = "H" then "aquit" else "equit")
        ttQtt.iProrata                   = (if gdaEntreeLocataire = vdaDprCal and vdaFinCal = vdaFprCal then 0 else 1) // Periode entiere, pas de prorata possible
        viNumCal                         = vdaFinCal - gdaEntreeLocataire + 1 // ordre d'assignation à respecter
        viDenCal                         = vdaFprCal - vdaDprCal + 1          // ordre d'assignation à respecter
        ttQtt.iNumerateurProrata         = viNumCal                           // ordre d'assignation à respecter
        ttQtt.iDenominateurProrata       = viDenCal                           // ordre d'assignation à respecter
    .
    // Recherche du n° d'immeuble correspondant
    ghProc = lancementPgm("crud/intnt_CRUD.p", goCollectionHandlePgm).
    run getLastIntntContrat in ghProc({&TYPECONTRAT-mandat2Gerance}, viNoMdtUse, {&TYPEBIEN-immeuble}, output ttQtt.iNumeroImmeuble).
    // Donnees issues de la tache revision (Tache)
    for last tache no-lock
        where tache.tpcon = gcTypeContrat
          and tache.nocon = giNumeroContrat
          and tache.tptac = {&TYPETACHE-revision} :
        assign
            ttQtt.cCodeTypeIndiceRevision     = tache.tpges
            ttQtt.iPeriodeAnneeIndiceRevision = integer(substitute("&1&2", tache.ntreg, tache.cdreg)) // Numero periode indice (Nø periode + Annee)
            ttQtt.daProchaineRevision         = tache.dtfin
            ttQtt.daTraitementRevision        = tache.dtreg
        .
    end.
    for first lsirv no-lock
        where lsirv.cdirv = integer(ttQtt.cCodeTypeIndiceRevision) : // Recherche de la periodicite de l'indice
        assign ttQtt.cPeriodiciteIndiceRevision = string(lsirv.CdPer,"99").
    end.
    // Chargement de la table ttRub
    if entry(1, gcListeOption, "@") = {&oui} then do: // Calcul date de fin d'application des Rub Fixes vdaFap = date fin de periode quittance
        assign vdaFapRub = vdaFprCal .
        // Parcours des Rubriques de la Quittance Modele NB : On ne recupere que les rub FIXES et la rub d'amortissement 109 et on transforme les taxes calculees
        if vcTpQtt1Qt = "H" then do:
boucleRubrique :
            do viCpUseInc = 1 to aquit.nbrub:
                assign
                    vcTbRubHis = aquit.TbRub[viCpUseInc]
                    viNoRubTmp = integer(entry(1, vcTbRubHis, "|"))
                    viNoLibTmp = integer(entry(2, vcTbRubHis, "|"))
                .
                run RchInfRub(viNoRubTmp, viNoLibTmp, output vcLbLibTmp, output viCdFamTmp, output viCdSfaTmp, output vcCdGenTmp, output vcCdSigTmp). // Recherche des infos concernant la rubrique
                // On ne garde que les Rubriques Fixes et les calculs impots/taxes et la rub d'amortissement 109
                if vcCdGenTmp = {&GenreRubqt-Fixe}
                or vcCdGenTmp = {&GenreRubqt-Calcul}
                or viNoRubTmp = {&RUBRIQUE-ajustementLoyer}
                then do:
                    if vcCdGenTmp = {&GenreRubqt-Calcul} then do:
                        if viNoRubTmp < 770 or viNoRubTmp > 790 or viNoRubTmp = {&RUBRIQUE-rappelAvoirCRL} then next boucleRubrique.
                        if not vlTvaCon then do: // Recherche rubrique Variable equivalente
                            assign viNoRubTmp = viNoRubTmp - 20.
                            run RchInfRub(viNoRubTmp, viNoLibTmp, output vcLbLibTmp, output viCdFamTmp, output viCdSfaTmp, output vcCdGenTmp, output vcCdSigTmp).
                        end.
                    end.
                    create ttRub.
                    assign
                        ttRub.iNumeroLocataire   = giNumeroContrat
                        ttRub.iNoQuittance       = viNoQttUse
                        ttRub.iFamille           = integer(viCdFamTmp)
                        ttRub.iSousFamille       = integer(viCdSfaTmp)
                        ttRub.iNorubrique        = viNoRubTmp
                        ttRub.iNoLibelleRubrique = viNoLibTmp
                        ttRub.cLibelleRubrique   = vcLbLibTmp
                        ttRub.cCodeGenre         = vcCdGenTmp
                        ttRub.cCodeSigne         = vcCdSigTmp
                        ttRub.CdDet              = "0"
                        ttRub.dQuantite          = decimal(entry(3, vcTbRubHis, "|"))
                        ttRub.dPrixunitaire      = decimal(entry(4, vcTbRubHis, "|"))
                        // Montant mensuel * nbr mois periode
                        ttRub.dMontantTotal      = decimal(entry(5, vcTbRubHis, "|"))
                        ttRub.daDebutApplication = gdaEntreeLocataire
                        ttRub.daFinApplication   = vdaFapRub
                        ttQtt.iNombreRubrique    = ttQtt.iNombreRubrique + 1
                    .
                    if ttQtt.iProrata = 1 then do:
                        run isRubProCum (ttRub.iNorubrique, ttRub.iNoLibelleRubrique, output vlRubriqueProratee , output vlRubriqueCumuleee).
                        if not vlRubriqueProratee
                        then
                            assign ttRub.dMontantQuittance = ttRub.dMontantTotal.
                        else
                            assign
                                ttRub.iProrata             = 1
                                ttRub.iNumerateurProrata   = viNumCal
                                ttRub.iDenominateurProrata = viDenCal
                                ttRub.dMontantQuittance    = ttRub.dMontantTotal * viNumCal / viDenCal
                                .
                    end.
                    else
                        assign ttRub.dMontantQuittance = ttRub.dMontantTotal.
                    assign ttQtt.dMontantQuittance = ttQtt.dMontantQuittance + ttRub.dMontantQuittance.
                end.
            end.
        end.
        else
boucleRubrique :
        do viCpUseInc = 1 to equit.nbrub: // Parcours des rubriques du 1er mois Quittance
            // On ne garde que les Rubriques Fixes et les calculs impots/taxes et la rub d'amortissement 109
            assign viNoRubTmp = equit.TbRub[viCpUseInc] .
            if equit.TbGen[viCpUseInc] = {&GenreRubqt-Fixe}
            or equit.TbGen[viCpUseInc] = {&GenreRubqt-Calcul}
            or viNoRubTmp = {&RUBRIQUE-ajustementLoyer}
            then do:
                if equit.TbGen[viCpUseInc] = {&GenreRubqt-Calcul} then do:
                    if viNoRubTmp < 770 or viNoRubTmp > 790 or viNoRubTmp = {&RUBRIQUE-rappelAvoirCRL} then next boucleRubrique.
                    if not vlTvaCon then do: // Recherche rubrique Variable equivalente
                        assign viNoRubTmp = viNoRubTmp - 20.
                        run RchInfRub(viNoRubTmp, viNoLibTmp, output vcLbLibTmp, output viCdFamTmp, output viCdSfaTmp, output vcCdGenTmp, output vcCdSigTmp).
                    end.
                end.
                create ttRub.
                assign
                    ttRub.iNumeroLocataire   = giNumeroContrat
                    ttRub.iNoQuittance       = viNoQttUse
                    ttRub.iFamille           = equit.TbFam[viCpUseInc]
                    ttRub.iNorubrique        = viNoRubTmp
                    ttRub.iNoLibelleRubrique = equit.TbLib[viCpUseInc]
                    ttRub.CdDet              = "0"
                    ttRub.dQuantite          = 0
                    ttRub.dPrixunitaire      = 0
                    ttRub.dMontantTotal      = equit.TbTot[viCpUseInc]
                    ttRub.daDebutApplication = gdaEntreeLocataire
                    ttRub.daFinApplication   = vdaFapRub
                    ttQtt.iNombreRubrique    = ttQtt.iNombreRubrique + 1
                .
                if ttQtt.iProrata = 1 then do:
                    run isRubProCum (ttRub.iNorubrique, ttRub.iNoLibelleRubrique, output vlRubriqueProratee , output vlRubriqueCumuleee).
                    if not vlRubriqueProratee
                    then
                        assign ttRub.dMontantQuittance = ttRub.dMontantTotal.
                    else
                        assign
                            ttRub.iProrata = 1
                            ttRub.iNumerateurProrata   = viNumCal
                            ttRub.iDenominateurProrata = viDenCal
                            ttRub.dMontantQuittance    = ttRub.dMontantTotal * viNumCal / viDenCal
                        .
                end.
                else
                    assign ttRub.dMontantQuittance = ttRub.dMontantTotal.
                assign
                    ttQtt.dMontantQuittance = ttQtt.dMontantQuittance + ttRub.dMontantQuittance
                    viNoRubTmp              = ttRub.iNorubrique
                    viNoLibTmp              = ttRub.iNoLibelleRubrique
                .
                // Recherche des infos concernant la rubrique
                run RchInfRub(viNoRubTmp, viNoLibTmp, output vcLbLibTmp, output viCdFamTmp, output viCdSfaTmp, output vcCdGenTmp, output vcCdSigTmp).
                assign
                    ttRub.cLibelleRubrique = vcLbLibTmp
                    ttRub.iSousFamille     = integer(viCdSfaTmp)
                    ttRub.cCodeGenre       = vcCdGenTmp
                    ttRub.cCodeSigne       = vcCdSigTmp
                .
            end.
        end.
    end.
    assign
        piNoQuittance   = viNoQttUse
        piMoisQuittance = viMsQttCal
    .
end procedure.

procedure CalDatPer private:
    /*------------------------------------------------------------------------
    Purpose : Procedure qui calcule les dates de la periode et de la quittance
    Notes   :
    ------------------------------------------------------------------------*/
    define input  parameter pcCodePeriode   as character no-undo.
    define input  parameter pdaDebut        as date      no-undo.
    define input  parameter pdaFinBail      as date      no-undo.
    define input  parameter pcCodeTerme     as character no-undo.
    define output parameter pdaDebutPeriode as date      no-undo.
    define output parameter pdaFinPeriode   as date      no-undo.
    define output parameter pdtfinCal       as date      no-undo.
    define output parameter piMsQttCal      as integer   no-undo.
    define output parameter piMsQuiCal      as integer   no-undo.

    define variable viNbMoiPer as integer   no-undo.
    define variable viNoMoiRef as integer   no-undo.
    define variable viNoAnnDeb as integer   no-undo.
    define variable viNoAnnFin as integer   no-undo.
    define variable viNoMoiApp as integer   no-undo.
    define variable viNoMoiDpr as integer   no-undo.
    define variable viNoMoiFpr as integer   no-undo.
    define variable vdaMoiSui  as date      no-undo.
    define variable viMsMdfUse as integer   no-undo.
    define variable vcTempo    as character no-undo.
    define variable vhPrgdat   as handle    no-undo.

    run application/l_prgdat.p persistent set vhPrgdat.
    run getTokenInstance in vhPrgdat(mToken:JSessionId).

    // Determination des mois de debut et fin de periode
    assign
        viNbMoiPer = integer(substring(pcCodePeriode,1,3))
        viNoMoiApp = month(pdaDebut)
        viNoAnnDeb = year(pdaDebut)
        viNoAnnFin = viNoAnnDeb
        viNoMoiRef = integer(substring(pcCodePeriode,4))
    .
    if viNoMoiRef <= viNoMoiApp then do:
        assign
            viNoMoiDpr = viNoMoiRef
            viNoMoiFpr = viNoMoiDpr + viNbMoiPer
            .
        do while viNoMoiApp >= viNoMoiFpr :
            assign
                viNoMoiDpr = viNoMoiDpr + viNbMoiPer
                viNoMoiFpr = viNoMoiFpr + viNbMoiPer
            .
        end.
        assign viNoMoiFpr = viNoMoiFpr - 1.
        if viNoMoiFpr > 12 then
            assign
                viNoMoiFpr = viNoMoiFpr - 12
                viNoAnnFin = viNoAnnFin + 1
            .
    end.
    else do:
        assign viNoMoiDpr = viNoMoiRef.
        do while viNoMoiDpr > viNoMoiApp :
            assign  viNoMoiDpr = viNoMoiDpr - viNbMoiPer.
        end.
        if viNoMoiDpr < 1 then
            assign
                viNoMoiDpr = viNoMoiDpr + 12
                viNoAnnDeb = viNoAnnDeb - 1
            .
        assign viNoMoiFpr = viNoMoiDpr + viNbMoiPer - 1.
        if viNoMoiFpr > 12 then do:
            assign  viNoMoiFpr = viNoMoiFpr - 12.
            if viNoAnnFin = viNoAnnDeb then
                assign viNoAnnFin = viNoAnnFin + 1.
        end.
    end.
    assign pdaDebutPeriode = date(viNoMoiDpr,01,viNoAnnDeb).
    run DatDerJou in vhPrgdat(date(viNoMoiFpr,01,viNoAnnFin), output pdaFinPeriode). // Recuperation de la date du dernier jour de la periode                                       |
    // Date de fin de bail
    if pdaFinPeriode <= pdaFinBail then
        assign pdtfinCal = pdaFinPeriode.
    else
        assign pdtfinCal = pdaFinBail - 1.
    if integer(mToken:cRefGerance) = {&REFCLIENT-MANPOWER} or pcCodeTerme = {&TERMEQUITTANCEMENT-avance} then
        assign
            piMsQttCal = year(pdaDebutPeriode) * 100 + month(pdaDebutPeriode)
            piMsQuiCal = year(pdaDebutPeriode) * 100 + month(pdaDebutPeriode)
            .
    else // Terme echu Recherche de la date du mois suivant la date de fin de periode
        assign
            vdaMoiSui = pdaFinPeriode + 1
            piMsQttCal = year(vdaMoiSui) * 100 + month(vdaMoiSui)
            piMsQuiCal = year(pdaFinPeriode) * 100 + month(pdaFinPeriode)
            .
    if gcMoisModifiable <> "01" then do:
        viMsMdfUse = if goFournisseurLoyer:isGesFournisseurLoyer() and goCollectionContrat:getLogical("lBailFournisseurLoyer")
                    then goCollectionContrat:getinteger("iMoisModifiable")
                    else if pcCodeTerme = {&TERMEQUITTANCEMENT-echu}
                            then goCollectionContrat:getinteger("iMoisEchu")
                            else goCollectionContrat:getinteger("iMoisModifiable").
        if piMsQttCal >= viMsMdfUse then do: // Si Mois trt quittance >= 1er mois modifiable => interdit
            assign vcTempo = string(piMsQttCal,"999999").
            mError:createErrorGestion({&error}, 100261, substitute("&1/&2",substring(vcTempo,5,2), substring(vcTempo,1,4))). // Création d'une quittance antérieure interdite pour un mois non validé (%1).
        end.
    end.
    run destroy in vhPrgdat.
end procedure.

procedure RchInfRub private:
    /*------------------------------------------------------------------------
    Purpose : Procedure de Recherche des infos concernant la rubrique
    Notes   :
    ------------------------------------------------------------------------*/
    define input  parameter piNoRubTmp as integer   no-undo.
    define input  parameter piNoLibTmp as integer   no-undo.
    define output parameter pcLbLibTmp as character no-undo.
    define output parameter piCdFamTmp as integer   no-undo.
    define output parameter piCdSfaTmp as integer   no-undo.
    define output parameter pcCdGenTmp as character no-undo.
    define output parameter pcCdSigTmp as character no-undo.

    define buffer rubqt for rubqt.

    for first rubqt no-lock
        where rubqt.cdrub = piNoRubTmp
          and rubqt.cdlib = piNoLibTmp:
        assign
            pcLbLibTmp = outilTraduction:getLibelle(rubqt.nome1)
            piCdFamTmp = rubqt.cdfam // Code famille
            piCdSfaTmp = rubqt.cdsfa // Code sous-famille
            pcCdGenTmp = rubqt.cdgen // Code genre
            pcCdSigTmp = rubqt.cdsig // Code signe
        .
    end.
end procedure.
