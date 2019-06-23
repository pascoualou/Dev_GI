/*------------------------------------------------------------------------
File        : fusionMandatlocation.cls
Purpose     : Classe des champs fusion utilisateur MANDATLOCATION
Author(s)   : Génération automatique le 2018/01/25
Notes       :
------------------------------------------------------------------------*/
block-level on error undo, throw.
class bureautique.fusion.classe.fusionMandatlocation:
    /*------------------------------------------------------------------------------
    purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define public property MdtLocTauxHono        as character no-undo get. set.
    define public property MdtLocTauxTVa         as character no-undo get. set.
    define public property MdtLocPartBailleur    as character no-undo get. set.
    define public property MdtLocPartPreneur     as character no-undo get. set.
    define public property HonoProHT             as character no-undo get. set.
    define public property HonoProTVa            as character no-undo get. set.
    define public property HonoPrenHT            as character no-undo get. set.
    define public property HonoPrenTVa           as character no-undo get. set.
    define public property HonoTotHT             as character no-undo get. set.
    define public property HonoTotTTC            as character no-undo get. set.
    define public property MdtLocNoMandat        as character no-undo get. set.
    define public property MdtLocDateDeb         as character no-undo get. set.
    define public property MdtLocDateFin         as character no-undo get. set.
    define public property MdtLocType            as character no-undo get. set.
    define public property HonoProTTC            as character no-undo get. set.
    define public property HonoPrenTTC           as character no-undo get. set.
    define public property MdtLocTypassiette     as character no-undo get. set.
    define public property MdtLocValassiette     as character no-undo get. set.
    define public property MdtLocNomSign1        as character no-undo get. set.
    define public property MdtLocNomSign2        as character no-undo get. set.
    define public property MdtLocNomSignDlg      as character no-undo get. set.
    define public property MdtLocDescriptifLocal as character no-undo get. set.
    define public property MdtLocDateLDeb        as character no-undo get. set.
    define public property MdtLocDateLFin        as character no-undo get. set.
    define public property MdtLocQualSignDlg     as character no-undo get. set.
    define public property MdtLocNumregistre     as character no-undo get. set.
end class.
