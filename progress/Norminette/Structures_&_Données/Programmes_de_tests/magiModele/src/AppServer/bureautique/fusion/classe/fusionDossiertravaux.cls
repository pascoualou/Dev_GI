/*------------------------------------------------------------------------
File        : fusionDossiertravaux.cls
Purpose     : Classe des champs fusion utilisateur DOSSIERTRAVAUX
Author(s)   : Génération automatique le 2018/01/25
Notes       :
------------------------------------------------------------------------*/
block-level on error undo, throw.
class bureautique.fusion.classe.fusionDossierTravaux:
    /*------------------------------------------------------------------------------
    purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define public property LbappTrvxTreso      as character no-undo get. set.
    define public property MtappTrvxTreso      as character no-undo get. set.
    define public property LbechTrvxTreso      as character no-undo get. set.
    define public property MtechTrvxTreso      as character no-undo get. set.
    define public property LbTantiemeTrvxTreso as character no-undo get. set.
    define public property MtTantiemeTrvxTreso as character no-undo get. set.
    define public property NoDosTrvx           as character no-undo get. set.
    define public property DtechTrvxTreso      as character no-undo get. set.
end class.
