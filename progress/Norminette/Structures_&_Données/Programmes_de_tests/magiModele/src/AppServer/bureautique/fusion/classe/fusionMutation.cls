/*------------------------------------------------------------------------
File        : fusionMutation.cls
Purpose     : Classe des champs fusion utilisateur MUTATION
Author(s)   : Génération automatique le 2018/01/25
Notes       :
------------------------------------------------------------------------*/
block-level on error undo, throw.
class bureautique.fusion.classe.fusionMutation:
    /*------------------------------------------------------------------------------
    purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define public property TitreCoproVendeur        as character no-undo get. set.
    define public property TitreLCoproVendeur       as character no-undo get. set.
    define public property NomCoproVendeur          as character no-undo get. set.
    define public property adresseCoproVendeur      as character no-undo get. set.
    define public property SuiteadresseCoproVendeur as character no-undo get. set.
    define public property CodePostalCoproVendeur   as character no-undo get. set.
    define public property VilleCoproVendeur        as character no-undo get. set.
    define public property NomCompletCoproVendeur   as character no-undo get. set.
    define public property PolitesseCoproVendeur    as character no-undo get. set.
    define public property VilleCedexNotaireDoMut   as character no-undo get. set.
end class.
