/*------------------------------------------------------------------------
File        : fusionSalarie.cls
Purpose     : Classe des champs fusion utilisateur SALARIE
Author(s)   : Génération automatique le 2018/01/25
Notes       :
------------------------------------------------------------------------*/
block-level on error undo, throw.
class bureautique.fusion.classe.fusionSalarie:
    /*------------------------------------------------------------------------------
    purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define public property absMaladie                     as character no-undo get. set.
    define public property acompte13                      as character no-undo get. set.
    define public property anclSalar                      as character no-undo get. set.
    define public property ancSalar                       as character no-undo get. set.
    define public property ancSalarLettre                 as character no-undo get. set.
    define public property adresseURSSaF                  as character no-undo get. set.
    define public property aPe                            as character no-undo get. set.
    define public property assuTxSalar                    as character no-undo get. set.
    define public property BanqueConcierge                as character no-undo get. set.
    define public property BanqueemployeImm               as character no-undo get. set.
    define public property CaisseURSSaF                   as character no-undo get. set.
    define public property CatCotisant                    as character no-undo get. set.
    define public property CatINSee                       as character no-undo get. set.
    define public property CentreaSSeDIC                  as character no-undo get. set.
    define public property CodePostalURSSaF               as character no-undo get. set.
    define public property CoefSalar                      as character no-undo get. set.
    define public property ClassifCNN                     as character no-undo get. set.
    define public property CleSecu                        as character no-undo get. set.
    define public property CodeCIPD                       as character no-undo get. set.
    define public property CodeTranspo                    as character no-undo get. set.
    define public property ComplementAdresseIdentURSSAF   as character no-undo get. set.
    define public property ContratSalar                   as character no-undo get. set.
    define public property DateNaissanceConcierge         as character no-undo get. set.
    define public property DateLNaissanceConcierge        as character no-undo get. set.
    define public property DateNaissanceConciergeLettre   as character no-undo get. set.
    define public property DateNaissanceemployeImm        as character no-undo get. set.
    define public property DateLNaissanceemployeImm       as character no-undo get. set.
    define public property DateNaissanceemployeImmLettre  as character no-undo get. set.
    define public property DateDebutPeriodeDif            as character no-undo get. set.
    define public property DateFinPeriodeDif              as character no-undo get. set.
    define public property DtDepartSalarLettre            as character no-undo get. set.
    define public property DtDepartSalar                  as character no-undo get. set.
    define public property DtFinSalarLettre               as character no-undo get. set.
    define public property DtentreeSalar                  as character no-undo get. set.
    define public property DtentreeSalarLettre            as character no-undo get. set.
    define public property DtFinGestion                   as character no-undo get. set.
    define public property DtFinSalar                     as character no-undo get. set.
    define public property DtLDepartSalar                 as character no-undo get. set.
    define public property DtlentreeSalar                 as character no-undo get. set.
    define public property DtlFinSalar                    as character no-undo get. set.
    define public property emailConcierge                 as character no-undo get. set.
    define public property emailemployeImm                as character no-undo get. set.
    define public property FaxConcierge                   as character no-undo get. set.
    define public property FaxemployeImm                  as character no-undo get. set.
    define public property FinGestion                     as character no-undo get. set.
    define public property IndRemplace                    as character no-undo get. set.
    define public property JoursacquisencoursCP           as character no-undo get. set.
    define public property JoursacquisPeriodeMoins1CP     as character no-undo get. set.
    define public property JoursacquisPeriodeMoins2CP     as character no-undo get. set.
    define public property JoursancienneteencoursCP       as character no-undo get. set.
    define public property JoursanciennetePeriodeMoins1CP as character no-undo get. set.
    define public property JoursanciennetePeriodeMoins2CP as character no-undo get. set.
    define public property JoursPrisencoursCP             as character no-undo get. set.
    define public property JoursPrisPeriodeMoins1CP       as character no-undo get. set.
    define public property JoursPrisPeriodeMoins2CP       as character no-undo get. set.
    define public property Libeffectif                    as character no-undo get. set.
    define public property Libelleemploie                 as character no-undo get. set.
    define public property LieuNaissanceConcierge         as character no-undo get. set.
    define public property LieuNaissanceemployeImm        as character no-undo get. set.
    define public property ListeMoisFormation             as character no-undo get. set.
    define public property ListeMotifFormation            as character no-undo get. set.
    define public property ListeNbHeureFormation          as character no-undo get. set.
    define public property LogSalar                       as character no-undo get. set.
    define public property MedTravail                     as character no-undo get. set.
    define public property MotifDepart                    as character no-undo get. set.
    define public property NationaliteConcierge           as character no-undo get. set.
    define public property NationaliteemployeImm          as character no-undo get. set.
    define public property NIC                            as character no-undo get. set.
    define public property NiveauSalar                    as character no-undo get. set.
    define public property NoaSSeDIC                      as character no-undo get. set.
    define public property NoBICConcierge                 as character no-undo get. set.
    define public property NoBICemployeImm                as character no-undo get. set.
    define public property NoCIRP                         as character no-undo get. set.
    define public property NoCompteBancaireConcierge      as character no-undo get. set.
    define public property NoCompteBancaireemployeImm     as character no-undo get. set.
    define public property NomCompletConcierge            as character no-undo get. set.
    define public property NomCompletEmployeImm           as character no-undo get. set.
    define public property NomConcierge                   as character no-undo get. set.
    define public property NomemployeImm                  as character no-undo get. set.
    define public property NoSecu                         as character no-undo get. set.
    define public property NoURSSaF                       as character no-undo get. set.
    define public property NumeroSalarie                  as character no-undo get. set.
    define public property PolitesseConcierge             as character no-undo get. set.
    define public property PolitesseemployeImm            as character no-undo get. set.
    define public property PortableConcierge              as character no-undo get. set.
    define public property PortableemployeImm             as character no-undo get. set.
    define public property Qualification                  as character no-undo get. set.
    define public property RegSecu                        as character no-undo get. set.
    define public property Repancien                      as character no-undo get. set.
    define public property SIReT                          as character no-undo get. set.
    define public property SIReTemployeur                 as character no-undo get. set.
    define public property SoldeencoursCP                 as character no-undo get. set.
    define public property SoldePeriodeMoins1CP           as character no-undo get. set.
    define public property SoldePeriodeMoins2CP           as character no-undo get. set.
    define public property StatutSalar                    as character no-undo get. set.
    define public property SuiteadresseURSSaF             as character no-undo get. set.
    define public property TauxHoraire                    as character no-undo get. set.
    define public property TauxTranspo                    as character no-undo get. set.
    define public property TauxTxSalar                    as character no-undo get. set.
    define public property TelephoneConcierge             as character no-undo get. set.
    define public property TelephonEemployeImm            as character no-undo get. set.
    define public property Titreconcierge                 as character no-undo get. set.
    define public property TitreemployeImm                as character no-undo get. set.
    define public property TitreLConcierge                as character no-undo get. set.
    define public property TitreLemployeImm               as character no-undo get. set.
    define public property TituRibConcierge               as character no-undo get. set.
    define public property TituRibemployeImm              as character no-undo get. set.
    define public property TpsPartiel                     as character no-undo get. set.
    define public property TraitSalar                     as character no-undo get. set.
    define public property Typeemploi                     as character no-undo get. set.
    define public property VilleCedexURSSaF               as character no-undo get. set.
    define public property VilleURSSaF                    as character no-undo get. set.

end class.
