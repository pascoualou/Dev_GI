/*------------------------------------------------------------------------
File        : fusionImmeuble.cls
Purpose     : Classe des champs fusion utilisateur IMMEUBLE
Author(s)   : Génération automatique le 2018/01/25
Notes       :
------------------------------------------------------------------------*/
block-level on error undo, throw.
class bureautique.fusion.classe.fusionImmeuble:
    /*------------------------------------------------------------------------------
    purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define public property NumSyndicexterne                as character no-undo get. set.
    define public property TitreSyndicexterne              as character no-undo get. set.
    define public property TitreLSyndicexterne             as character no-undo get. set.
    define public property NomSyndicexterne                as character no-undo get. set.
    define public property adresseSyndicexterne            as character no-undo get. set.
    define public property SuiteadresseSyndicexterne       as character no-undo get. set.
    define public property CodePostalSyndicexterne         as character no-undo get. set.
    define public property VilleSyndicexterne              as character no-undo get. set.
    define public property DebutPeriodeChauffe             as character no-undo get. set.
    define public property FinPeriodeChauffe               as character no-undo get. set.
    define public property DatelConstructionImmeuble       as character no-undo get. set.
    define public property Date_Construction_Immeuble      as character no-undo get. set.
    define public property DateConstructionImmeubleLettre  as character no-undo get. set.
    define public property NomContactDomotique             as character no-undo get. set.
    define public property HeureDebut1Loge1                as character no-undo get. set.
    define public property HeureDebut1Loge2                as character no-undo get. set.
    define public property HeureDebut2Loge1                as character no-undo get. set.
    define public property HeureDebut2Loge2                as character no-undo get. set.
    define public property HeureFin1Loge1                  as character no-undo get. set.
    define public property HeureFin1Loge2                  as character no-undo get. set.
    define public property HeureFin2Loge1                  as character no-undo get. set.
    define public property HeureFin2Loge2                  as character no-undo get. set.
    define public property ListeJoursouvertureLoge1        as character no-undo get. set.
    define public property ListeJoursouvertureLoge2        as character no-undo get. set.
    define public property Telephone1Loge                  as character no-undo get. set.
    define public property Telephone2Loge                  as character no-undo get. set.
    define public property CommentairesDomotique           as character no-undo get. set.
    define public property ListeDigicodeDestinataire       as character no-undo get. set.
    define public property FgSyndicMdt                     as character no-undo get. set.
    define public property ListeReglementCoproDoSRU        as character no-undo get. set.
    define public property Diagnosticamiante               as character no-undo get. set.
    define public property DiagnosticTermites              as character no-undo get. set.
    define public property DiagnosticSaturnisme            as character no-undo get. set.
    define public property DiagnosticMerule                as character no-undo get. set.
    define public property DiagnosticCapricorne            as character no-undo get. set.
    define public property DiagnosticRadon                 as character no-undo get. set.
    define public property DiagnosticInstallGaz            as character no-undo get. set.
    define public property DiagnosticRisqueTechno          as character no-undo get. set.
    define public property DiagnosticPerfenerg             as character no-undo get. set.
    define public property Diagnosticelectricite           as character no-undo get. set.
    define public property etudeTechniquePlomb             as character no-undo get. set.
    define public property etudeTechniqueascenceur         as character no-undo get. set.
    define public property etudeTechniqueaeraulique        as character no-undo get. set.
    define public property ListeCourteDigicodeDestinataire as character no-undo get. set.
    define public property VilleCedex_Bien                 as character no-undo get. set.
    define public property VilleCedexVendeurDoMut          as character no-undo get. set.
    define public property VilleCedexSyndicexterne         as character no-undo get. set.
    define public property Diagnosticassainissement        as character no-undo get. set.
    define public property etiquetteenergie                as character no-undo get. set.
    define public property etiquetteClimat                 as character no-undo get. set.
    define public property DateRechDPe                     as character no-undo get. set.
    define public property Type_Chauffage_IMM              as character no-undo get. set.
    define public property Mode_Chauffage_IMM              as character no-undo get. set.
    define public property NomCompletSyndicexterneContact  as character no-undo get. set.
    define public property TitreLSyndicexterneContact      as character no-undo get. set.
    define public property NbLotsPrincipaux                as character no-undo get. set.
    define public property NbLotsReglementCopro            as character no-undo get. set.
    define public property NumeroImmatCopro                as character no-undo get. set.
    define public property Type_Habitation_IMM             as character no-undo get. set.
    define public property Regime_Juridique_IMM            as character no-undo get. set.
    define public property Type_eau_Chaude_IMM             as character no-undo get. set.
    define public property Photo_immeuble                  as character no-undo get. set.
    define public property NoBien                          as character no-undo get. set.
    define public property Adresse_Bien                    as character no-undo get. set.
    define public property Suite_Adresse_Bien              as character no-undo get. set.
    define public property Code_Postal_Bien                as character no-undo get. set.
    define public property Ville_Bien                      as character no-undo get. set.
    define public property Ville_Cedex_Bien                as character no-undo get. set.
    define public property Secteur_lot                     as character no-undo get. set.
    define public property equipement_collectif            as character no-undo get. set.
    define public property TelephoneBien                   as character no-undo get. set.
    define public property Surface_Terrain                 as character no-undo get. set.
    define public property NomImmeuble                     as character no-undo get. set.
    define public property EquipementCollectif             as character no-undo get. set.
    define public property ComplementAdresseIdent_Bien     as character no-undo get. set.
    define public property ComplementAdresseIdentSyndicExterne as character no-undo get. set.
end class.
