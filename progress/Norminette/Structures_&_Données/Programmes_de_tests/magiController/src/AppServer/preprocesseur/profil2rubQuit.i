/*------------------------------------------------------------------------
File        : profil2rubQuit.i
Purpose     : Variables préprocesseur les rubriques de quittancement : code genre, familles etc...
Author(s)   : SPo - 23/01/2017
Notes       :
------------------------------------------------------------------------*/
&GLOBAL-DEFINE FamilleRubqt-Loyer                         01
&GLOBAL-DEFINE FamilleRubqt-Charge                        02
&GLOBAL-DEFINE FamilleRubqt-Divers                        03
&GLOBAL-DEFINE FamilleRubqt-Administratif                 04
&GLOBAL-DEFINE FamilleRubqt-Taxe                          05
&GLOBAL-DEFINE FamilleRubqt-HonoraireCabinet              08
&GLOBAL-DEFINE FamilleRubqt-TVAHonoraire                  09

// Famille 01 - Loyers
&GLOBAL-DEFINE SousFamilleRubqt-Equipement                03
&GLOBAL-DEFINE SousFamilleRubqt-APL                       04
&GLOBAL-DEFINE SousFamilleRubqt-AutreLoyer                06
&GLOBAL-DEFINE SousFamilleRubqt-ChargeForfaitaire         07

// Famille 02 - Charges
&GLOBAL-DEFINE SousFamilleRubqt-Provision                 01
&GLOBAL-DEFINE SousFamilleRubqt-Consommation              02
&GLOBAL-DEFINE SousFamilleRubqt-ChargeDiverse             04

// Famille 04 - Administratif
&GLOBAL-DEFINE SousFamilleRubqt-Administratif             00
&GLOBAL-DEFINE SousFamilleRubqt-ServiceHotelier           03
&GLOBAL-DEFINE SousFamilleRubqt-ServiceDivers             05
&GLOBAL-DEFINE SousFamilleRubqt-RedevanceSoumiseTVA       06
&GLOBAL-DEFINE SousFamilleRubqt-LoyerRedevanceService     08

// Famille 05 - Impôts, taxes
&GLOBAL-DEFINE SousFamilleRubqt-ImpotsTaxesFiscaux        02

// Paramètre sys_pr RUGEN
&GLOBAL-DEFINE GenreRubqt-Fixe                       "00001"
&GLOBAL-DEFINE GenreRubqt-Variable                   "00003"
&GLOBAL-DEFINE GenreRubqt-Calcul                     "00004"
&GLOBAL-DEFINE GenreRubqt-Resultat                   "00007"
&GLOBAL-DEFINE GenreRubqt-Cumul                      "00008"

// Paramètre sys_pr RUSIG
&GLOBAL-DEFINE SigneRubqt-Positif                    "00000"
&GLOBAL-DEFINE SigneRubqt-Negatif                    "00001"
&GLOBAL-DEFINE SigneRubqt-PositifOuNegatif           "00002"
&GLOBAL-DEFINE SigneRubqt-Rappel                     "00003"
&GLOBAL-DEFINE SigneRubqt-Avoir                      "00004"
&GLOBAL-DEFINE SigneRubqt-RappelOuAvoir              "00005"
&GLOBAL-DEFINE SigneRubqt-Complement                 "00006"
&GLOBAL-DEFINE SigneRubqt-Remboursement              "00007"
&GLOBAL-DEFINE SigneRubqt-ComplementOuRemboursement  "00008"

// Rubriques particulières (rubqt)
&GLOBAL-DEFINE RubriqueQuitt-Franchise                                104
&GLOBAL-DEFINE RubriqueQuitt-SurLoyer                                 110
&GLOBAL-DEFINE RubriqueQuitt-MajorationLoyerMEH                       111
&GLOBAL-DEFINE RubriqueQuitt-RappelouAvoirMajorationLoyerMEH          114
&GLOBAL-DEFINE RubriqueQuitt-RappelouAvoirRevisionMajorationLoyerMEH  118
&GLOBAL-DEFINE RubriqueQuitt-IndemniteComplementairePrestation        404

// Rubriques TVA (rubqt)
&GLOBAL-DEFINE ListeRubqtTVA-Variable        "744,747,752,753,754,755,756,758,759"
&GLOBAL-DEFINE ListeRubqtTVA-RappelAvoir     "745,748,762,763,764,765,766,768,769"
&GLOBAL-DEFINE ListeRubqtTVA-Calcul          "746,749,772,773,774,775,776,778,779"
&GLOBAL-DEFINE ListeRubqtTVAService-Calcul   "781,782,783,784,785,786,787,788,789"
&GLOBAL-DEFINE ListeRubqtTVAHono-Calcul      "900,901,902,903,906,907,908,910,920"
&GLOBAL-DEFINE ListeRubQtTVA-Manu            "744,745,747,748,752,753,754,755,756,758,759,762,763,764,765,766,768,769"
