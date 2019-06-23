/*------------------------------------------------------------------------
File        : fusionAccordreglement.cls
Purpose     : Classe des champs fusion utilisateur ACCORDREGLEMENT
Author(s)   : Génération automatique le 2018/01/25
Notes       :
------------------------------------------------------------------------*/
block-level on error undo, throw.
class bureautique.fusion.classe.fusionAccordreglement:
    /*------------------------------------------------------------------------------
    purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define public property MontantMoratoire        as character no-undo get. set.
    define public property NbecheanceMoratoire     as character no-undo get. set.
    define public property PeriodiciteMoratoire    as character no-undo get. set.
    define public property DateDebutMoratoire      as character no-undo get. set.
    define public property DateFinMoratoire        as character no-undo get. set.
    define public property DetailecheanceMoratoire as character no-undo get. set.
end class.
