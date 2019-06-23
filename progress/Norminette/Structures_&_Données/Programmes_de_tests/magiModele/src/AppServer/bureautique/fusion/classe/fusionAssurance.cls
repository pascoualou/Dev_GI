/*------------------------------------------------------------------------
File        : fusionAssurance.cls
Purpose     : Classe des champs fusion utilisateur ASSURANCE
Author(s)   : Génération automatique le 2018/01/25
Notes       :
------------------------------------------------------------------------*/
block-level on error undo, throw.
class bureautique.fusion.classe.fusionAssurance:
    /*------------------------------------------------------------------------------
    purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define public property TitreCompagnie           as character no-undo get. set.
    define public property NomCompagnie             as character no-undo get. set.
    define public property adresseCompagnie         as character no-undo get. set.
    define public property SuiteadresseCompagnie    as character no-undo get. set.
    define public property VilleCompagnie           as character no-undo get. set.
    define public property CodePostalCompagnie      as character no-undo get. set.
    define public property NumPoliceassurance       as character no-undo get. set.
    define public property DateDbtassurance         as character no-undo get. set.
    define public property DateFinassurance         as character no-undo get. set.
    define public property TitreCourtier            as character no-undo get. set.
    define public property NomCourtier              as character no-undo get. set.
    define public property adresseCourtier          as character no-undo get. set.
    define public property SuiteadresseCourtier     as character no-undo get. set.
    define public property VilleCourtier            as character no-undo get. set.
    define public property CodePostalCourtier       as character no-undo get. set.
    define public property LstGarassurance          as character no-undo get. set.
    define public property DatelDbtassurance        as character no-undo get. set.
    define public property DateDbtassuranceLettre   as character no-undo get. set.
    define public property DatelFinassurance        as character no-undo get. set.
    define public property DateFinassuranceLettre   as character no-undo get. set.
    define public property DateSigassurance         as character no-undo get. set.
    define public property DateLSigassurance        as character no-undo get. set.
    define public property DateSigassuranceenLettre as character no-undo get. set.
    define public property DateIniassurance         as character no-undo get. set.
    define public property DateLIniassurance        as character no-undo get. set.
    define public property DateIniassuranceenLettre as character no-undo get. set.
    define public property VilleCedexCompagnie      as character no-undo get. set.
    define public property VilleCedexCourtier       as character no-undo get. set.
    define public property emailCompagnie           as character no-undo get. set.
    define public property TelephoneCompagnie       as character no-undo get. set.
    define public property FaxCompagnie             as character no-undo get. set.
    define public property emailCourtier            as character no-undo get. set.
    define public property TelephoneCourtier        as character no-undo get. set.
    define public property FaxCourtier              as character no-undo get. set.
    define public property ComplementAdresseIdentCompagnie as character no-undo get. set.
    define public property ComplementAdresseIdentCourtier  as character no-undo get. set.
end class.
