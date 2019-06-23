/*------------------------------------------------------------------------
File        : fusionFichelocataire.cls
Purpose     : Classe des champs fusion utilisateur FICHELOCATAIRE
Author(s)   : Génération automatique le 2018/01/25
Notes       :
------------------------------------------------------------------------*/
block-level on error undo, throw.
class bureautique.fusion.classe.fusionFichelocataire:
    /*------------------------------------------------------------------------------
    purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define public property FRelocPerLoyer        as character no-undo get. set.
    define public property FRelocLoyer           as character no-undo get. set.
    define public property FRequipeIndividuel    as character no-undo get. set.
    define public property FRequipeCollectif     as character no-undo get. set.
    define public property FRListePieces         as character no-undo get. set.
    define public property FRNoLotPrincipal      as character no-undo get. set.
    define public property FRNombrePiecesLot     as character no-undo get. set.
    define public property FRNomGardien          as character no-undo get. set.
    define public property FRTelephoneGardien    as character no-undo get. set.
    define public property FRDescriptifUL        as character no-undo get. set.
    define public property FRDescriptifULSurface as character no-undo get. set.
    define public property FRSurfUtileUL         as character no-undo get. set.
    define public property FRSurfPondUL          as character no-undo get. set.
    define public property FRSurfannexeUL        as character no-undo get. set.
    define public property FRStatut              as character no-undo get. set.
    define public property FRDateFiche           as character no-undo get. set.
    define public property FRProvisoire          as character no-undo get. set.
    define public property FRNomSign1            as character no-undo get. set.
    define public property FRNomSign2            as character no-undo get. set.
    define public property FRNomSign3            as character no-undo get. set.
    define public property FRFonctionSign1       as character no-undo get. set.
    define public property FRFonctionSign2       as character no-undo get. set.
    define public property FRFonctionSign3       as character no-undo get. set.
    define public property FRTypeTravaux         as character no-undo get. set.
    define public property FRDureeTravaux        as character no-undo get. set.
    define public property FRLoyerann            as character no-undo get. set.
    define public property FRLoyerMens           as character no-undo get. set.
    define public property FRChargeann           as character no-undo get. set.
    define public property FRChargeMens          as character no-undo get. set.
    define public property FRParkingann          as character no-undo get. set.
    define public property FRParkingMens         as character no-undo get. set.
    define public property FRInvest              as character no-undo get. set.
    define public property FRLoyerMensM2         as character no-undo get. set.
    define public property FRLoyerMensM2Pond     as character no-undo get. set.
    define public property FRanneeRelGeo         as character no-undo get. set.
    define public property FRanneePlanGeo        as character no-undo get. set.
    define public property FRobservations        as character no-undo get. set.
    define public property FRTravRecLocataire    as character no-undo get. set.
    define public property FRTravProprietaire    as character no-undo get. set.
    define public property FRTravactif           as character no-undo get. set.
    define public property FRTravTot             as character no-undo get. set.
    define public property FRLoyerannuelenCours  as character no-undo get. set.
    define public property FRLoyerMensuelenCours as character no-undo get. set.
    define public property FRDesignSpeciales     as character no-undo get. set.
    define public property FRRelGeo              as character no-undo get. set.
    define public property FRPlanGeo             as character no-undo get. set.
    define public property FRCommentaires        as character no-undo get. set.
    define public property FRetageLot            as character no-undo get. set.
    define public property FRPerRevis            as character no-undo get. set.
    define public property FRDureeBail           as character no-undo get. set.
    define public property FRNbMoisDG            as character no-undo get. set.
    define public property FRUsageLoc            as character no-undo get. set.
    define public property FRtypeIndice          as character no-undo get. set.
    define public property FRPerioQuitt          as character no-undo get. set.
    define public property FRTermeQuitt          as character no-undo get. set.
    define public property FRelocCharges         as character no-undo get. set.
    define public property FRelocParking         as character no-undo get. set.
    define public property FRelocTaxeFonciere    as character no-undo get. set.
    define public property FRelocTaxeBureau      as character no-undo get. set.
    define public property FRRegimeFiscal        as character no-undo get. set.
    define public property FRTauxFiscal          as character no-undo get. set.
    define public property FRDateDispo           as character no-undo get. set.
    define public property FRDateReception       as character no-undo get. set.
    define public property FRrevisDG             as character no-undo get. set.
    define public property FRFlgParking          as character no-undo get. set.
    define public property FRFlgTaxeFonciere     as character no-undo get. set.
    define public property FRFlgTaxeBureau       as character no-undo get. set.
    define public property FRDateLDispo          as character no-undo get. set.
    define public property FRDateLReception      as character no-undo get. set.
    define public property FRPkgDispo            as character no-undo get. set.
    define public property FRNatLotPrincipal     as character no-undo get. set.
    define public property FRLoyerannM2          as character no-undo get. set.
    define public property FRLoyerannM2Pond      as character no-undo get. set.
    define public property FRancLoyerMensM2Pond  as character no-undo get. set.
    define public property FRancLoyerannM2Pond   as character no-undo get. set.
    define public property FRTableLotsSurf       as character no-undo get. set.
    define public property FRTableLotsSurfCum    as character no-undo get. set.
    define public property FRListeNolot          as character no-undo get. set.
    define public property FRListeNatLot         as character no-undo get. set.
    define public property FRListeBatLot         as character no-undo get. set.
    define public property FRListeescLot         as character no-undo get. set.
    define public property FRListeetgLot         as character no-undo get. set.
    define public property FRListePteLot         as character no-undo get. set.
    define public property FRListeSfUtiLot       as character no-undo get. set.
    define public property FRListeSfanxLot       as character no-undo get. set.
    define public property FRListeSfPondLot      as character no-undo get. set.
    define public property FRListePcSfUtiLot     as character no-undo get. set.
    define public property FRListePcSfanxLot     as character no-undo get. set.
    define public property FRListePcSfPondLot    as character no-undo get. set.
    define public property FRListeQuoPCHallLot   as character no-undo get. set.
    define public property FRListeQuoPCPalLot    as character no-undo get. set.
    define public property FRListeQuoPCPteLot    as character no-undo get. set.
    define public property FRListePcQuoPCHallLot as character no-undo get. set.
    define public property FRListePcQuoPCPalLot  as character no-undo get. set.
    define public property FRListePcQuoPCPteLot  as character no-undo get. set.
    define public property FRListeNatLot2        as character no-undo get. set.
    define public property FRListeBatLot2        as character no-undo get. set.
    define public property FRListeetgLot2        as character no-undo get. set.
    define public property FRListeSfUtiLot2      as character no-undo get. set.
    define public property FRListeSfanxLot2      as character no-undo get. set.
    define public property FRListeSfPondLot2     as character no-undo get. set.
    define public property FRListeSfUtiTot       as character no-undo get. set.
    define public property FRListeSfanxTot       as character no-undo get. set.
    define public property FRListeSfPondTot      as character no-undo get. set.
    define public property FRListeQuoPCHallTot   as character no-undo get. set.
    define public property FRListeQuoPCPalTot    as character no-undo get. set.
    define public property FRListeQuoPCPteTot    as character no-undo get. set.
    define public property FRTypeFiche           as character no-undo get. set.
    define public property FRorganisme           as character no-undo get. set.
    define public property FRTravCoutM2          as character no-undo get. set.
    define public property FRTravRetInvest       as character no-undo get. set.
end class.
