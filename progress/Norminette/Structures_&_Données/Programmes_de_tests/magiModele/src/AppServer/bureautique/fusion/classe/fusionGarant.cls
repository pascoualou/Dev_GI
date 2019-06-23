/*------------------------------------------------------------------------
File        : fusionGarant.cls
Purpose     : Classe des champs fusion utilisateur GARANT
Author(s)   : Génération automatique le 2018/01/25
Notes       :
------------------------------------------------------------------------*/
block-level on error undo, throw.
class bureautique.fusion.classe.fusionGarant:
    /*------------------------------------------------------------------------------
    purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define public property LstLocataireGarant        as character no-undo get. set.
    define public property NomCompletGarant          as character no-undo get. set.
    define public property adresseGarant             as character no-undo get. set.
    define public property SuiteadresseGarant        as character no-undo get. set.
    define public property CodePostalGarant          as character no-undo get. set.
    define public property VilleGarant               as character no-undo get. set.
    define public property NoenregisGarant           as character no-undo get. set.
    define public property DateSignatureGarant       as character no-undo get. set.
    define public property DateDebutGarant           as character no-undo get. set.
    define public property DateFinGarant             as character no-undo get. set.
    define public property DelaisPreavisGarant       as character no-undo get. set.
    define public property TypeacteGarant            as character no-undo get. set.
    define public property MtCautionGarant           as character no-undo get. set.
    define public property VilleSignatureGarant      as character no-undo get. set.
    define public property TitreGarant               as character no-undo get. set.
    define public property TitreLGarant              as character no-undo get. set.
    define public property NomGarant                 as character no-undo get. set.
    define public property PolitesseGarant           as character no-undo get. set.
    define public property PaysGarant                as character no-undo get. set.
    define public property NomGarantContact          as character no-undo get. set.
    define public property TitreGarantContact        as character no-undo get. set.
    define public property NomLocContact             as character no-undo get. set.
    define public property TitreLocContact           as character no-undo get. set.
    define public property FaxGarant                 as character no-undo get. set.
    define public property emailGarant               as character no-undo get. set.
    define public property VilleCedexGarant          as character no-undo get. set.
    define public property VilleCedexSignatureGarant as character no-undo get. set.
    define public property ComplementAdresseIdentGarant as character no-undo get. set.
    define public property ComplementAdresseIdentSignatureGarant as character no-undo get. set.
end class.
