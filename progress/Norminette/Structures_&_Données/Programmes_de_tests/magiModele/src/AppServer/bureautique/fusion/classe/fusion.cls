/*------------------------------------------------------------------------
File        : fusion.cls
Purpose     : Classe des champs fusion utilisateur 
Author(s)   : Génération automatique le 2018/01/25
Notes       :
------------------------------------------------------------------------*/
block-level on error undo, throw.
class bureautique.fusion.classe.fusion:
    /*------------------------------------------------------------------------------
    purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define public property CiviliteCoproprietaire as character no-undo get. set.
    define public property CiviliteSyndCopro      as character no-undo get. set.
    define public property Civilite_Locataire     as character no-undo get. set.
    define public property CiviliteDestinataire   as character no-undo get. set.
    define public property Civilite_mandant       as character no-undo get. set.
end class.
