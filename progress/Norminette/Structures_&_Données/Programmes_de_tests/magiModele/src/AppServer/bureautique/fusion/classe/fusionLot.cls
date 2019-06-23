/*------------------------------------------------------------------------
File        : fusionLot.cls
Purpose     : Classe des champs fusion utilisateur LOT
Author(s)   : Génération automatique le 2018/01/25
Notes       :
------------------------------------------------------------------------*/
block-level on error undo, throw.
class bureautique.fusion.classe.fusionLot:
    /*------------------------------------------------------------------------------
    purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define public property DesignationLot                 as character no-undo get. set.
    define public property origine_acquisition_bien       as character no-undo get. set.
    define public property Type_acte_acquisition          as character no-undo get. set.
    define public property Date_Signature_acquisition     as character no-undo get. set.
    define public property DatelacquisitionBien           as character no-undo get. set.
    define public property DateacquisitionBienLettre      as character no-undo get. set.
    define public property BatimententreeescalierDigicode as character no-undo get. set.
    define public property LibelleDigicode1               as character no-undo get. set.
    define public property LibelleDigicode2               as character no-undo get. set.
    define public property NouveauDigicode1               as character no-undo get. set.
    define public property NouveauDigicode2               as character no-undo get. set.
    define public property ancienDigicode1                as character no-undo get. set.
    define public property ancienDigicode2                as character no-undo get. set.
    define public property DateDebutDigicode1             as character no-undo get. set.
    define public property DateDebutDigicode2             as character no-undo get. set.
    define public property DateFinDigicode1               as character no-undo get. set.
    define public property DateFinDigicode2               as character no-undo get. set.
    define public property SurfUtileLot                   as character no-undo get. set.
    define public property SurfPondereeLot                as character no-undo get. set.
    define public property SurfBureauLot                  as character no-undo get. set.
    define public property SurfCommLot                    as character no-undo get. set.
    define public property SurfStockageLot                as character no-undo get. set.
    define public property SurfannexeLot                  as character no-undo get. set.
    define public property SurfCarrezLot                  as character no-undo get. set.
    define public property SurfCorrigeeLot                as character no-undo get. set.
    define public property SurfestimeeLot                 as character no-undo get. set.
    define public property SurfSHoNLot                    as character no-undo get. set.
    define public property SurfPondereeexpertiseeLot      as character no-undo get. set.
    define public property BurDistLotPrincipal            as character no-undo get. set.
    define public property VilleCedexNotaire              as character no-undo get. set.
    define public property etiquetteenergieLot            as character no-undo get. set.
    define public property etiquetteClimatLot             as character no-undo get. set.
    define public property DateRechDPeLot                 as character no-undo get. set.
    define public property Type_Chauffage_Lot             as character no-undo get. set.
    define public property Mode_Chauffage_Lot             as character no-undo get. set.
    define public property SurfDePlancherLot              as character no-undo get. set.
    define public property SurfempriseauSolLot            as character no-undo get. set.
    define public property LoyerMandat                    as character no-undo get. set.
    define public property ProvisionsChargesMandat        as character no-undo get. set.
    define public property Type_eau_Chaude_Lot            as character no-undo get. set.
    define public property Loi_Lot                        as character no-undo get. set.
    define public property UsageLot                       as character no-undo get. set.
    define public property NoBatiment_lot                 as character no-undo get. set.
    define public property etage_lot                      as character no-undo get. set.
    define public property escalier_lot                   as character no-undo get. set.
    define public property Porte_lot                      as character no-undo get. set.
    define public property Nombre_Pieces_lot              as character no-undo get. set.
    define public property equipement_Individuel          as character no-undo get. set.
    define public property equipement_collectif           as character no-undo get. set.
    define public property NomNotaire                     as character no-undo get. set.
    define public property VilleNotaire                   as character no-undo get. set.
    define public property Type_Bien                      as character no-undo get. set.
    define public property Surface_Bien                   as character no-undo get. set.
    define public property Surface_Terrasse               as character no-undo get. set.
    define public property Mode_Chauffage                 as character no-undo get. set.
    define public property Liste_pieces                   as character no-undo get. set.
    define public property DescriptifBien                 as character no-undo get. set.
    define public property NumeroLot                      as character no-undo get. set.
    define public property condition                      as character no-undo get. set.
    define public property DescriptionBien                as character no-undo get. set.
    define public property ComplementAdresseIdentNotaire  as character no-undo get. set.

end class.
