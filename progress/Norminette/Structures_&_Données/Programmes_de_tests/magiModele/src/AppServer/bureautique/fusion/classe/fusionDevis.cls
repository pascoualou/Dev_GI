/*------------------------------------------------------------------------
File        : fusionDevis.cls
Purpose     : Classe des champs fusion utilisateur DEVIS
Author(s)   : Génération automatique le 2018/01/25
Notes       :
------------------------------------------------------------------------*/
block-level on error undo, throw.
class bureautique.fusion.classe.fusionDevis:
    /*------------------------------------------------------------------------------
    purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define public property NumDevis                   as character no-undo get. set.
    define public property DateCreationDevis          as character no-undo get. set.
    define public property DateLCreationDevis         as character no-undo get. set.
    define public property NumFourniDevis             as character no-undo get. set.
    define public property TableDevis                 as character no-undo get. set.
    define public property DelaiDevis                 as character no-undo get. set.
    define public property CondPaiemDevis             as character no-undo get. set.
    define public property CondPortDevis              as character no-undo get. set.
    define public property DateCreationDevisLettre    as character no-undo get. set.
    define public property ListeDesignationDevis      as character no-undo get. set.
    define public property ListeRefarticleDevis       as character no-undo get. set.
    define public property ListeQteDevis              as character no-undo get. set.
    define public property ListeDelaiDevis            as character no-undo get. set.
    define public property ListeCommentaireDevis      as character no-undo get. set.
    define public property ListePUDevis               as character no-undo get. set.
    define public property ListeTxRemiseDevis         as character no-undo get. set.
    define public property ListeMontantDevis          as character no-undo get. set.
    define public property ListeCleDevis              as character no-undo get. set.
    define public property ListeCleLibelleDevis       as character no-undo get. set.
    define public property ListeLotsDevis             as character no-undo get. set.
    define public property ListeNatureLotsDevis       as character no-undo get. set.
    define public property ListeBatLotsDevis          as character no-undo get. set.
    define public property ListeentreeLotsDevis       as character no-undo get. set.
    define public property ListeescLotsDevis          as character no-undo get. set.
    define public property ListeetageLotsDevis        as character no-undo get. set.
    define public property ListePorteLotsDevis        as character no-undo get. set.
    define public property ListeoccupantLotsDevis     as character no-undo get. set.
    define public property TableLotsDevis             as character no-undo get. set.
    define public property TableLotsoccupantsDevis    as character no-undo get. set.
    define public property RoleSignalantDevis         as character no-undo get. set.
    define public property TitreSignalantDevis        as character no-undo get. set.
    define public property TitreLSignalantDevis       as character no-undo get. set.
    define public property CiviliteSignalantDevis     as character no-undo get. set.
    define public property NomSignalantDevis          as character no-undo get. set.
    define public property NomCompletSignalantDevis   as character no-undo get. set.
    define public property adresseSignalantDevis      as character no-undo get. set.
    define public property SuiteadresseSignalantDevis as character no-undo get. set.
    define public property CodePostalSignalantDevis   as character no-undo get. set.
    define public property VilleSignalantDevis        as character no-undo get. set.
    define public property VilleCedexSignalantDevis   as character no-undo get. set.
    define public property ListeTeloccupantLotsDevis  as character no-undo get. set.
    define public property TelSignalantDevis          as character no-undo get. set.
    define public property PortableSignalantDevis     as character no-undo get. set.
    define public property ListeemailoccupantDevis    as character no-undo get. set.
end class.
