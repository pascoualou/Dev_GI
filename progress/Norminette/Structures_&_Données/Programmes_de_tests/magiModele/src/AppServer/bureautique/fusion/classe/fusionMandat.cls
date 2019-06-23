/*------------------------------------------------------------------------
File        : fusionMandat.cls
Purpose     : Classe des champs fusion utilisateur MANDAT
Author(s)   : Génération automatique le 2018/01/25
Notes       :
------------------------------------------------------------------------*/
block-level on error undo, throw.
class bureautique.fusion.classe.fusionMandat:
    /*------------------------------------------------------------------------------
    purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define public property adresse_mandant                        as character no-undo get. set.
    define public property Suite_adresse_mandant                  as character no-undo get. set.
    define public property Code_Postal_mandant                    as character no-undo get. set.
    define public property Civilite_mandant                       as character no-undo get. set.
    define public property Ville_mandant                          as character no-undo get. set.
    define public property NomManContact                          as character no-undo get. set.
    define public property TitreManContact                        as character no-undo get. set.
    define public property DateFinMandat                          as character no-undo get. set.
    define public property DureeMandat                            as character no-undo get. set.
    define public property echCompteRendu                         as character no-undo get. set.
    define public property PourRemuMand                           as character no-undo get. set.
    define public property Profession_mandant                     as character no-undo get. set.
    define public property SoldeProprietaire                      as character no-undo get. set.
    define public property NumRCS                                 as character no-undo get. set.
    define public property Capital                                as character no-undo get. set.
    define public property QualiteContMandant                     as character no-undo get. set.
    define public property NumMandant                             as character no-undo get. set.
    define public property CapitalenLettre                        as character no-undo get. set.
    define public property SoldeProprietaireenLettre              as character no-undo get. set.
    define public property DateL_Naissance_Mandant                as character no-undo get. set.
    define public property TitreDirecteuragenceGerance            as character no-undo get. set.
    define public property TitreLDirecteuragenceGerance           as character no-undo get. set.
    define public property NomDirecteuragenceGerance              as character no-undo get. set.
    define public property NomagenceGerance                       as character no-undo get. set.
    define public property adresseagenceGerance                   as character no-undo get. set.
    define public property SuiteadresseagenceGerance              as character no-undo get. set.
    define public property CodePostalagenceGerance                as character no-undo get. set.
    define public property VilleagenceGerance                     as character no-undo get. set.
    define public property Tel1agenceGerance                      as character no-undo get. set.
    define public property DescriptifLotsMandat                   as character no-undo get. set.
    define public property PiecesLotsMandat                       as character no-undo get. set.
    define public property MilliemesLotsMandat                    as character no-undo get. set.
    define public property VilleRCS                               as character no-undo get. set.
    define public property DatelFinMandat                         as character no-undo get. set.
    define public property DateFinMandatLettre                    as character no-undo get. set.
    define public property NomCompletMandant                      as character no-undo get. set.
    define public property NomCompletManContact                   as character no-undo get. set.
    define public property BanqueMandant                          as character no-undo get. set.
    define public property NoCompteBancaireMandant                as character no-undo get. set.
    define public property TituRibMandant                         as character no-undo get. set.
    define public property NatioemetteurBquMandant                as character no-undo get. set.
    define public property NomCompletManCo                        as character no-undo get. set.
    define public property NomCompletManRep                       as character no-undo get. set.
    define public property TitreLMandant                          as character no-undo get. set.
    define public property NoMandat                               as character no-undo get. set.
    define public property LstBeneficiaireMandat                  as character no-undo get. set.
    define public property TelGestionnaireGerance                 as character no-undo get. set.
    define public property FaxGestionnaireGerance                 as character no-undo get. set.
    define public property FormeLgJuridMandant                    as character no-undo get. set.
    define public property FormeCtJuridMandant                    as character no-undo get. set.
    define public property FgIRFMdt                               as character no-undo get. set.
    define public property FgPieceMdt100                          as character no-undo get. set.
    define public property FgGarantieSpecialeMdt                  as character no-undo get. set.
    define public property FgGarantieLoyerMdt                     as character no-undo get. set.
    define public property FgPieceMdt101                          as character no-undo get. set.
    define public property FgPieceMdt102                          as character no-undo get. set.
    define public property FgPieceMdt103                          as character no-undo get. set.
    define public property FgPieceMdt104                          as character no-undo get. set.
    define public property FgPieceMdt105                          as character no-undo get. set.
    define public property FgPieceMdt106                          as character no-undo get. set.
    define public property FgPieceMdt107                          as character no-undo get. set.
    define public property FgPieceMdt108                          as character no-undo get. set.
    define public property FgPieceMdt109                          as character no-undo get. set.
    define public property FgPieceMdt110                          as character no-undo get. set.
    define public property NumRegistre                            as character no-undo get. set.
    define public property PolitesseMandant                       as character no-undo get. set.
    define public property activiteMandant                        as character no-undo get. set.
    define public property adresseMandantRep                      as character no-undo get. set.
    define public property NationaliteMandantRep                  as character no-undo get. set.
    define public property DtMariageMandant                       as character no-undo get. set.
    define public property DtLMariageMandant                      as character no-undo get. set.
    define public property DtMariageMandantLettre                 as character no-undo get. set.
    define public property LieuMariageMandant                     as character no-undo get. set.
    define public property RegimeMatrimonialMandant               as character no-undo get. set.
    define public property NomNotaireContratMariageMandant        as character no-undo get. set.
    define public property VilleNotaireContratMariageMandant      as character no-undo get. set.
    define public property DateDebutMandatG                       as character no-undo get. set.
    define public property DateLDebutMandatG                      as character no-undo get. set.
    define public property DateDebutMandatGLettre                 as character no-undo get. set.
    define public property TelephoneMandant                       as character no-undo get. set.
    define public property PortableMandant                        as character no-undo get. set.
    define public property PaysMandant                            as character no-undo get. set.
    define public property DateFinContrat                         as character no-undo get. set.
    define public property DateLFinContrat                        as character no-undo get. set.
    define public property DateFinContratenLettre                 as character no-undo get. set.
    define public property DateSigMandatG                         as character no-undo get. set.
    define public property DateLSigMandatG                        as character no-undo get. set.
    define public property DateSigMandatGenLettre                 as character no-undo get. set.
    define public property DateIniMandatG                         as character no-undo get. set.
    define public property DateLIniMandatG                        as character no-undo get. set.
    define public property DateIniMandatGenLettre                 as character no-undo get. set.
    define public property DateexpirationMandatG                  as character no-undo get. set.
    define public property DateLexpirationMandatG                 as character no-undo get. set.
    define public property DateexpirationMandatGenLettre          as character no-undo get. set.
    define public property DureeMaximale                          as character no-undo get. set.
    define public property PortableGestionnaireGerance            as character no-undo get. set.
    define public property FaxMandant                             as character no-undo get. set.
    define public property emailMandant                           as character no-undo get. set.
    define public property emailGestionnaireGerance               as character no-undo get. set.
    define public property VilleCedex                             as character no-undo get. set.
    define public property VilleCedex_mandant                     as character no-undo get. set.
    define public property VilleCedexagenceGerance                as character no-undo get. set.
    define public property VilleCedexRCS                          as character no-undo get. set.
    define public property VilleCedexNotaireContratMariageMandant as character no-undo get. set.
    define public property NomCompletGestionnaireGerance          as character no-undo get. set.
    define public property NoBICMandant                           as character no-undo get. set.
    define public property NationaliteMandant                     as character no-undo get. set.
    define public property NoIBaNMandat                           as character no-undo get. set.
    define public property BanqueMandat                           as character no-undo get. set.
    define public property NoBICMandat                            as character no-undo get. set.
    define public property FgassuGarantieLoyerMdt                 as character no-undo get. set.
    define public property TypeMandant                            as character no-undo get. set.
    define public property FonctionGestionnaireGerance            as character no-undo get. set.
    define public property NomGestionnaireGerance                 as character no-undo get. set.
    define public property NumMandatannexe                        as character no-undo get. set.
    define public property Descriptif_Indivisaire                 as character no-undo get. set.
    define public property Liste_des_lots_mandat                  as character no-undo get. set.
    define public property DescriptifMandant                      as character no-undo get. set.
    define public property Nom_mandant                            as character no-undo get. set.
    define public property Titre_mandant                          as character no-undo get. set.
    define public property Date_naissance_Mandant                 as character no-undo get. set.
    define public property Lieu_naissance_Mandant                 as character no-undo get. set.
    define public property ComplementAdresseIdent_Mandant         as character no-undo get. set.
    define public property ComplementAdresseIdentNotaireContratMariageMandant as character no-undo get. set.
    define public property ComplementAdresseIdentAgenceGerance                as character no-undo get. set.
    define public property SoldeDebiteurMandant                   as character no-undo get. set.
    define public property SoldeDebiteurMandantEnLettre           as character no-undo get. set.
    define public property SoldeCrediteurMandant                  as character no-undo get. set.
    define public property SoldeCrediteurMandantEnLettre          as character no-undo get. set.
    
end class.
