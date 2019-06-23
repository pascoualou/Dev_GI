/*-----------------------------------------------------------------------------
File        : extractionLot.p
Description : Recherche des donnees de fusion de lot
Author(s)   : RF - 2008/04/11, KANTENA - 2018/03/02
Notes       : anciennement lot.p

01  05/01/2008  PL    1008/0151:Ajout include cretbchp.i
02  18/02/2009  PL    1108/0352:Changement recherche libelle pièce
02  28/04/2009  SY    ne pas initialiser les variables globales d'extraction Fgxxxxx à TRUE (Init dans extract.p uniquement !)
03  12/05/2010  SY    1008/0150 fonction FrmEquipement déplacée dans fctequip.i
04  27/08/2010  NP    0810/0096 Modif ds fctexpor.i
05  02/02/2011  SY    1010/0020 Ajout Etiquettes Energie et climat au DPE (Diag. Performance Energétique)
06  29/02/2012  PL    0211/0164 Ajout type et mode chauffage
07  08/10/2012  PL    0112/0090 Ajout MontantFamille + surfaces
08  03/07/2015  SY    0715/0009 NOUVEAU CHAMP POUR LE BAIL RENTRANT EN VIGUEUR LE 01/08/2015 (decret 2015-587)    
09  29/07/2015  PL    1014/0048:ajout champ Loi_Lot
10  05/08/2015  NP    0215/0227 add new champs NumeroLot
11  20/08/2015  SY    0312/0102 Ajout UsageLot (evelot01.p) + TOUJOURS valoriser les champs même si pas de lot
12  14/10/2015  SY    0915/0147 Pb inversion libellé long/libellé court sys_pr corrigé dans base ladb de la version > 12.6
                           -> on remet LIBPR2 pour lib court UTSUR
13  11/01/2016  PL    0711/0069 Normalisation adresses sur 6 lignes 
14  25/01/2016  PL    0711/0069 Normalisation adresses sur 6 lignes 
15  10/10/2017  NP    #7589 modif prdpelot.i : Add valeurs du DPE   
-----------------------------------------------------------------------------*/

{preprocesseur/type2bien.i}
{preprocesseur/type2role.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2tiers.i}
{preprocesseur/type2tache.i}
{preprocesseur/famille2tiers.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/fusion/fusionLot.i}
{preprocesseur/listeRubQuit2TVA.i}

using bureautique.fusion.classe.fusionLot.
using bureautique.fusion.classe.fusionAdresse.
using bureautique.fusion.classe.fusionBanque.
using bureautique.fusion.classe.fusionRole.
using parametre.syspr.parametrageDesignation.
 
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{application/include/glbsepar.i} 
{bureautique/fusion/include/fctexport.i}
{bureautique/fusion/include/fctequip.i}
{bureautique/fusion/include/decodorg.i}
{bureautique/fusion/include/prdpelot.i}

procedure extractionLot:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes: service utilisé par extraction.p
    ------------------------------------------------------------------------------*/
    define input        parameter piNumeroLocal    as integer   no-undo.
    define input        parameter piNumeroDocument as integer   no-undo.
    define input        parameter pcListeChamp     as character no-undo.
    define input-output parameter poFusionLot      as class fusionLot no-undo.

    define variable vcEtiquetteEnergieLot   as character no-undo.
    define variable vcEtiquetteClimatLot    as character no-undo.
    define variable vdaDateRechDPELot       as date      no-undo.
    define variable viValEtqEnergieLot      as integer   no-undo.
    define variable viValEtqClimatLot       as integer   no-undo.
    define variable vcLibellePiece          as character no-undo.
    define variable vcListePiece            as character no-undo.
    define variable viNumeroImmeuble        as integer   no-undo.
    define variable viCompteur              as integer   no-undo.
    define variable vlBloc1                 as logical   no-undo.
    define variable vlBloc2                 as logical   no-undo.
    define variable vlBloc3                 as logical   no-undo.
    define variable vlBloc4                 as logical   no-undo.
    define variable vlBloc5                 as logical   no-undo.
    define variable voRole                  as class fusionRole             no-undo.
    define variable voAdresse               as class fusionAdresse          no-undo.
    define variable voDesignationPiece      as class parametrageDesignation no-undo.

    define buffer etxdt     for etxdt.
    define buffer tache     for tache.
    define buffer vbIntnt   for intnt.
    define buffer ctrat     for ctrat.
    define buffer intnt     for intnt.
    define buffer local     for local.
    define buffer notes     for notes.
    define buffer piece     for piece.
    define buffer usageLot  for usageLot.
    define buffer EquipBien for EquipBien.

boucleCHamp:
    do viCompteur = 1 to num-entries(pcListeChamp):
        case entry(viCompteur, pcListeChamp):
            when {&FUSION-NoBatiment_lot}            or when {&FUSION-etage_lot}               or when {&FUSION-escalier_lot}
         or when {&FUSION-Porte_lot}                 or when {&FUSION-Nombre_Pieces_lot}       or when {&FUSION-Surface_Bien}
         or when {&FUSION-Surface_Terrasse}          or when {&FUSION-Condition}               or when {&FUSION-Type_Bien}
         or when {&FUSION-DesignationLot}            or when {&FUSION-ListeLotsSurfaceUL}      or when {&FUSION-SurfUtileLot}
         or when {&FUSION-SurfPondereeLot}           or when {&FUSION-SurfBureauLot}           or when {&FUSION-SurfCommLot}
         or when {&FUSION-SurfStockageLot}           or when {&FUSION-SurfannexeLot}           or when {&FUSION-SurfCarrezLot}
         or when {&FUSION-SurfCorrigeeLot}           or when {&FUSION-SurfestimeeLot}          or when {&FUSION-SurfSHoNLot}
         or when {&FUSION-SurfPondereeexpertiseeLot} or when {&FUSION-etiquetteenergieLot}     or when {&FUSION-etiquetteClimatLot}
         or when {&FUSION-DateRechDPeLot}            or when {&FUSION-SurfDePlancherLot}       or when {&FUSION-SurfempriseauSolLot}
         or when {&FUSION-LoyerMandat}               or when {&FUSION-ProvisionsChargesMandat} or when {&FUSION-NumeroLot}  /* NP 0215/0227 */
         or when {&FUSION-UsageLot} then do: /* SY 0312/0102 */
                if vlBloc1 then next boucleCHamp.

                vlBloc1 = true.
                for first local no-lock
                    where local.noloc = piNumeroLocal:
                    /* Si le nombre de pieces du bien est <= 1 alors on enleve le 's' */
                    assign
                        vcLibellePiece                        = if local.nbprf <= 1
                                                                then right-trim(outilTraduction:getLibelle(100042), "s")
                                                                else outilTraduction:getLibelle(100042)
                        poFusionLot:NoBatiment_lot            = local.cdbat
                        poFusionLot:Etage_lot                 = local.cdeta
                        poFusionLot:Escalier_Lot              = local.cdesc
                        poFusionLot:Porte_Lot                 = local.cdpte
                        poFusionLot:Nombre_Pieces_lot         = string(local.nbprf)
                        poFusionLot:Surface_Bien              = montantToCharacter(local.sfree, false) + " " + outilTraduction:getLibelleParam("UTSUR", local.usree, "C")
                        poFusionLot:Surface_Terrasse          = montantToCharacter(local.sfter, false) + " " + outilTraduction:getLibelleParam("UTSUR", local.uster, "C")
                        poFusionLot:Type_Bien                 = substitute("&1 &2 &3", outilTraduction:getLibelleParam("NTLOT", local.ntlot), local.nbprf, vcLibellePiece)
                        poFusionLot:DesignationLot            = local.lbgrp
                        poFusionLot:SurfUtileLot              = montantToCharacter(local.sfree, false) + " " + outilTraduction:getLibelleParam("UTSUR", local.usree, "C")
                        poFusionLot:SurfPondereeLot           = montantToCharacter(local.sfpde, false) + " " + outilTraduction:getLibelleParam("UTSUR", local.uspde, "C")
                        poFusionLot:SurfBureauLot             = montantToCharacter(local.sfbur, false) + " " + outilTraduction:getLibelleParam("UTSUR", local.usbur, "C")
                        poFusionLot:SurfCommLot               = montantToCharacter(local.sfCom, false) + " " + outilTraduction:getLibelleParam("UTSUR", local.uscom, "C")
                        poFusionLot:SurfStockageLot           = montantToCharacter(local.sfstk, false) + " " + outilTraduction:getLibelleParam("UTSUR", local.usstk, "C")
                        poFusionLot:SurfCarrezLot             = montantToCharacter(local.sfnon, false) + " " + outilTraduction:getLibelleParam("UTSUR", local.usnon, "C")
                        poFusionLot:SurfCorrigeeLot           = montantToCharacter(local.sfcor, false) + " " + outilTraduction:getLibelleParam("UTSUR", local.uscor, "C")
                        poFusionLot:SurfEstimeeLot            = montantToCharacter(local.sfarc, false) + " " + outilTraduction:getLibelleParam("UTSUR", local.usarc, "C")
                        poFusionLot:SurfSHONLot               = montantToCharacter(local.sfhon, false) + " " + outilTraduction:getLibelleParam("UTSUR", local.ushon, "C")
                        poFusionLot:SurfPondereeExpertiseeLot = montantToCharacter(local.sfexp, false) + " " + outilTraduction:getLibelleParam("UTSUR", local.usexp, "C")
                        poFusionLot:SurfAnnexeLot             = montantToCharacter(local.sfaxe, false) + " " + outilTraduction:getLibelleParam("UTSUR", local.usaxe, "C")
                        poFusionLot:NumeroLot                 = string(local.nolot)   /* NP 0215/0227 */
                        poFusionLot:SurfDePlancherLot         = montantToCharacter(local.sfPlancher, false)   + " " + outilTraduction:getLibelleParam("UTSUR", local.usPlancher, "C")
                        poFusionLot:SurfEmpriseAuSolLot       = montantToCharacter(local.sfEmpriseSol, false) + " " + outilTraduction:getLibelleParam("UTSUR", local.usEmpriseSol, "C").
                    .
                    /* Recherche du code usage du lot */
                    for first usagelot no-lock
                        where usagelot.cdusa = local.cdusage:
                        poFusionLot:UsageLot = usagelot.lbusa.
                    end.
                    for first notes no-lock
                        where notes.noblc = local.noblc:
                        poFusionLot:Condition = notes.lbnot.
                    end.
                    /* SY 1010/0020 */
                    run rchEtqDPELot(local.noloc, local.noimm,
                                     output vdaDateRechDPELot,
                                     output vcEtiquetteEnergieLot,
                                     output vcEtiquetteClimatLot,
                                     output viValEtqEnergieLot,
                                     output viValEtqClimatLot).
                    assign
                        poFusionLot:LoyerMandat             = montantToCharacter(local.MontantFamille[1], false)
                        poFusionLot:ProvisionsChargesMandat = montantToCharacter(local.MontantFamille[2], false)
                    .
                end.
                /* Modif SY le 20/08/2015 : les champs doivent TOUJOURS être valorisés même si lot = 0 */
                assign
                    poFusionLot:EtiquetteEnergieLot = vcEtiquetteEnergieLot
                    poFusionLot:EtiquetteClimatLot  = vcEtiquetteClimatLot
                    poFusionLot:DateRechDPELot      = dateToCharacter(vdaDateRechDPELot)
                .
            end.
            when {&FUSION-origine_acquisition_bien} or when {&FUSION-Type_acte_acquisition} or when {&FUSION-Date_Signature_acquisition} 
         or when {&FUSION-DatelacquisitionBien} or when {&FUSION-DateacquisitionBienLettre} then do:
                if vlBloc2 then next boucleCHamp.

                vlBloc2 = true.
                for first intnt no-lock
                    where intnt.tpidt = {&TYPEBIEN-lot}
                      and intnt.noidt = piNumeroLocal
                      and intnt.tpcon = {&TYPECONTRAT-acte2propriete}
                  , first ctrat no-lock
                    where ctrat.tpcon = intnt.tpcon
                      and ctrat.nocon = intnt.nocon:
                    assign
                        poFusionLot:origine_acquisition_bien   = outilTraduction:getLibelleParam("TPACQ", ctrat.tpren)
                        poFusionLot:Type_acte_acquisition      = outilTraduction:getLibelleParam("TPACT", ctrat.tpact)
                        poFusionLot:Date_Signature_acquisition = dateToCharacter(ctrat.dtsig)
                        poFusionLot:DatelacquisitionBien       = outilFormatage:getDateFormat(ctrat.dtsig, "L")
                        poFusionLot:DateAcquisitionBienLettre  = outilFormatage:getDateFormat(ctrat.dtsig, "LL")
                    .
                end.
            end.
            when {&FUSION-equipement_Individuel} or when {&FUSION-Mode_Chauffage}     or when {&FUSION-DescriptifBien} 
         or when {&FUSION-Liste_pieces}          or when {&FUSION-Type_Chauffage_Lot} or when {&FUSION-Mode_Chauffage_Lot} 
         or when {&FUSION-Type_eau_Chaude_Lot} then do: /* SY 0715/0009 */
                if vlBloc3 then next boucleCHamp.

                assign
                    vlBloc3            = true
                    voDesignationPiece = new parametrageDesignation()
                .
                /* Liste des Pieces avec leur superficie */
                for each piece no-lock
                   where piece.noloc = piNumeroLocal:
                    voDesignationPiece:reload("NTPIE", piece.ntpie).
                    vcListePiece = substitute("&1, &2&3&4",
                                       vcListePiece,
                                       voDesignationPiece:getLibelleDesignation(),
                                       if piece.sfpie <> 0
                                       then substitute(" (&1 &2)", montantToCharacter(piece.sfpie, false), outilTraduction:getLibelleParam("UTPIE", piece.uspie))
                                       else "",
                                       if piece.cdniv <> "1"
                                       then substitute(" (&1 : &2)", outilTraduction:getLibelle(100045), piece.cdniv)
                                       else "").
                end.
                vcListePiece = trim(vcListePiece, ", ").
                if vcListePiece > "" then vcListePiece = vcListePiece + ".".
                delete object voDesignationPiece.

                /* Le Mode de Chauffage */
                for first local no-lock
                    where local.noloc = piNumeroLocal:
                    poFusionLot:Mode_Chauffage_Lot = outilTraduction:getLibelleParam("MDCHA", Local.MdCha).     /* PL 28/02/2012 : 0211/0164 */
                    /* décodage général de tpcha */
                    if local.tpcha >= "00001" then assign
                        poFusionLot:Type_Chauffage_Lot = outilTraduction:getLibelleParam("TPCHA", local.tpcha)                            /* PL 28/02/2012 : 0211/0164 */
                        poFusionLot:Mode_Chauffage     = substitute("&1 (&2)", outilTraduction:getLibelle(110049), poFusionLot:Mode_Chauffage_Lot)
                        viNumeroImmeuble               = local.noimm
                    .
                end.
                /* Existence "Eau chaude individuelle" dans les equipements du lot principal */ /* SY 0715/0009 */
                for first equipBien no-lock
                     where EquipBien.cTypeBien = {&TYPEBIEN-lot}
                       and EquipBien.iNumeroBien = local.noloc
                       and equipBien.cCodeEquipement = "00050": /* Eau chaude individuelle */
                    poFusionLot:Type_Eau_Chaude_Lot = (if equipBien.fgOuiNon then outilTraduction:getLibelle(111514) else outilTraduction:getLibelle(111513)).
                end.
                /* Modif SY le 12/05/2010 */
                assign 
                    poFusionLot:equipement_Individuel = FRMEQUIPEMENTLOT(piNumeroLocal) /* Equipement lot */
                    poFusionLot:equipement_collectif  = FRMEQUIPEMENT(viNumeroImmeuble) /* Equipement Collectif*/
                .
                if poFusionLot:Mode_Chauffage > "" 
                then poFusionLot:DescriptionBien = substitute("&2&1&3&1- &4 :&1&5&1- &6 :&1&7&1", chr(10), vcListePiece,
                                                   poFusionLot:Mode_Chauffage,
                                                   outilTraduction:getLibelle(103155),
                                                   poFusionLot:equipement_Individuel,
                                                   outilTraduction:getLibelle(103156),
                                                   poFusionLot:equipement_Collectif).
                else poFusionLot:DescriptionBien = substitute("&2&1- &3 :&1&4&1- &5 :&1&6&1", chr(10), vcListePiece, 
                                                   outilTraduction:getLibelle(103155),
                                                   poFusionLot:equipement_Individuel,
                                                   outilTraduction:getLibelle(103156),
                                                   poFusionLot:equipement_Collectif).
            end.
            when {&FUSION-NomNotaire} or when {&FUSION-VilleNotaire} or when {&FUSION-VilleCedexNotaire} 
         or when {&FUSION-ComplementAdresseIdentNotaire} then do:  /* PL : 11/01/2016 - (Fiche : 0711/0069) */
                if vlBloc4 then next boucleCHamp.

                vlBloc4 = true.
                for first intnt no-lock
                    where intnt.tpidt = {&TYPEBIEN-lot}
                      and intnt.noidt = piNumeroLocal
                      and intnt.tpcon = {&TYPECONTRAT-acte2propriete}
                  , first vbIntnt no-lock
                    where vbIntnt.tpidt = {&TYPEROLE-notaire}
                      and vbIntnt.tpcon = {&TYPECONTRAT-acte2propriete}
                      and vbIntnt.nocon = intnt.nocon:
                    assign
                        voRole                                    = chargeRole(vbIntnt.tpidt, vbIntnt.noidt, piNumeroDocument)
                        voAdresse                                 = chargeAdresse(vbIntnt.tpidt, vbIntnt.noidt, piNumeroDocument)
                        poFusionLot:NomNotaire                    = voRole:Nom
                        poFusionLot:VilleNotaire                  = voAdresse:villeSansCedex()
                        poFusionLot:ComplementAdresseIdentNotaire = voAdresse:IdentAdresse /* PL : 11/01/2016 - (Fiche : 0711/0069) */
                    .
                end.
                poFusionLot:VilleCedexNotaire = voAdresse:ville. /* 0109/0192 */
            end.
            when {&FUSION-BatimententreeescalierDigicode} or when {&FUSION-LibelleDigicode1}   or when {&FUSION-LibelleDigicode2}
         or when {&FUSION-NouveauDigicode1}               or when {&FUSION-NouveauDigicode2}   or when {&FUSION-ancienDigicode1}
         or when {&FUSION-ancienDigicode2}                or when {&FUSION-DateDebutDigicode1} or when {&FUSION-DateDebutDigicode2}
         or when {&FUSION-DateFinDigicode1}               or when {&FUSION-DateFinDigicode2} then do:
                if vlBloc5 then next boucleCHamp.

                vlBloc5 = true.
                {&_proparse_ prolint-nowarn(wholeindex)}
                if piNumeroLocal = 0
                then find first local no-lock no-error.
                else find first local no-lock
                    where local.noloc = piNumeroLocal no-error.
                if not available local then next boucleCHamp.

                for first intnt no-lock
                    where intnt.tpcon = {&TYPECONTRAT-construction}
                      and intnt.tpidt = {&TYPEBIEN-immeuble}
                      and intnt.noidt = (if piNumeroLocal = 0 then viNumeroImmeuble else local.noimm):
                    /* Recherche par Escalier - Entree - Batiment */
                    find last tache no-lock
                        where tache.tpcon = intnt.tpcon
                          and tache.nocon = intnt.nocon
                          and tache.tptac = {&TYPETACHE-digicode}
                          and tache.tpfin = local.cdbat            /*- Batiment    -*/
                          and tache.cdhon = local.lbdiv            /*- Entree      -*/
                          and tache.tphon = local.cdesc no-error.  /*- Escalier    -*/
                    if not available tache then do:
                        /* Recherche par Entree - Batiment */
                        find last tache no-lock
                            where tache.tpcon = intnt.tpcon
                              and tache.nocon = intnt.nocon
                              and tache.tptac = {&TYPETACHE-digicode}
                              and tache.tpfin = local.cdbat   /*- Batiment    -*/
                              and tache.cdhon = local.lbdiv   /*- Entree      -*/
                              and tache.tphon = "" no-error.  /*- Escalier    -*/
                        if not available tache or piNumeroLocal = 0 then do:
                            /* Recherche par Batiment */
                            find last tache no-lock
                                where tache.tpcon = intnt.tpcon
                                  and tache.nocon = intnt.nocon
                                  and tache.tptac = {&TYPETACHE-digicode}
                                  and tache.tpfin = local.cdbat   /*- Batiment    -*/
                                  and tache.cdhon = ""            /*- Entree      -*/
                                  and tache.tphon = "" no-error.  /*- Escalier    -*/
                            if not available tache or piNumeroLocal = 0
                            then find last tache no-lock
                                where tache.tpcon = intnt.tpcon
                                  and tache.nocon = intnt.nocon
                                  and tache.tptac = {&TYPETACHE-digicode}
                                  and tache.tpfin = ""            /*- Batiment    -*/
                                  and tache.cdhon = ""            /*- Entree      -*/
                                  and tache.tphon = "" no-error.  /*- Escalier    -*/
                        end.
                    end.
                    if available tache then assign
                        poFusionLot:BatimentEntreeEscalierDigicode = (if tache.tpfin > ""
                                                                      then substitute("&1 &2 ", outilTraduction:getLibelle(100609), trim(tache.tpfin)) else "")
                                                                   + (if tache.cdhon > ""
                                                                      then substitute("&1 &2 ", outilTraduction:getLibelle(100188), trim(tache.cdhon)) else "")
                                                                   + (if tache.tphon > ""
                                                                      then substitute("&1 &2 ", outilTraduction:getLibelle(100610), trim(tache.tphon)) else "")
                        poFusionLot:LibelleDigicode1    = tache.lbdiv
                        poFusionLot:NouveauDigicode1    = tache.tpges
                        poFusionLot:AncienDigicode1     = tache.ntges
                        poFusionLot:DateDebutDigicode1  = dateToCharacter(tache.dtdeb)
                        poFusionLot:DateFinDigicode1    = dateToCharacter(tache.dtfin)
                        poFusionLot:LibelleDigicode2    = tache.lbdiv2
                        poFusionLot:NouveauDigicode2    = tache.pdreg
                        poFusionLot:AncienDigicode2     = tache.utreg
                        poFusionLot:DateDebutDigicode2  = dateToCharacter(tache.dtreg)
                        poFusionLot:DateFinDigicode2    = dateToCharacter(tache.dtree)
                    .
                end.
            end.
            /* PL : 29/07/2015 (1014/0048) */
            when {&FUSION-Loi_Lot} then for first intnt no-lock
                where intnt.tpidt = {&TYPEBIEN-lot}
                  and intnt.noidt = piNumeroLocal
                  and intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
              , first etxdt no-lock
                where etxdt.notrx = intnt.nocon
                  and etxdt.tpapp = "00000"
                  and etxdt.noapp = 0
                  and etxdt.nolot = piNumeroLocal:
                poFusionLot:Loi_Lot = outilTraduction:getLibelleParam("CDLOI", etxdt.lbdiv3).
            end.
        end case.
    end.
    delete object voAdresse no-error.
    delete object voRole    no-error.

end procedure.
  