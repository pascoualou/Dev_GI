/*------------------------------------------------------------------------
File        : fusionBail.cls
Purpose     : Classe des champs fusion utilisateur BAIL
Author(s)   : Génération automatique le 2018/01/25
Notes       :
------------------------------------------------------------------------*/
block-level on error undo, throw.
class bureautique.fusion.classe.fusionBail:
    /*------------------------------------------------------------------------------
    purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    /*--- A ---*/
    define public property activiteLocataire                        as character no-undo get. set.
    define public property adresseLocataireRep                      as character no-undo get. set.
    define public property adresseLotPrincipal                      as character no-undo get. set.
    define public property adresseMandantInvest                     as character no-undo get. set.
    define public property adresse_Locataire                        as character no-undo get. set.

    /*--- B ---*/
    define public property BanqueCreancierLocataire                 as character no-undo get. set.
    define public property BanqueGarant                             as character no-undo get. set.
    define public property BanqueLocataire                          as character no-undo get. set.
    define public property BatimentLot2UL                           as character no-undo get. set.
    define public property BatimentLot3UL                           as character no-undo get. set.
    define public property BatimentLot4UL                           as character no-undo get. set.
    define public property BICCreancierLocataire                    as character no-undo get. set.
    define public property BurDistLotPrincipal                      as character no-undo get. set.

    /*--- C ---*/
    define public property CalEvListeDateDebutPeriode               as character no-undo get. set.
    define public property CalEvListeDateFinPeriode                 as character no-undo get. set.
    define public property CalEvListeEtatTraitement                 as character no-undo get. set.
    define public property CalEvListeMontantAnnuel                  as character no-undo get. set.
    define public property CalEvListeNumeroPeriode                  as character no-undo get. set.
    define public property CalEvLoyerContractuelInitial             as character no-undo get. set.
    define public property CalEvMontantAnnuel                       as character no-undo get. set.
    define public property CalEvPeriodeEnCoursDateDebut             as character no-undo get. set.
    define public property CalEvPeriodeEnCoursDateLDebut            as character no-undo get. set.
    define public property CalEvPeriodeEnCoursDateDebutLettre       as character no-undo get. set.
    define public property CalEvPeriodeEnCoursDateFin               as character no-undo get. set.
    define public property CalEvPeriodeEnCoursDateLFin              as character no-undo get. set.
    define public property CalEvPeriodeEnCoursDateFinLettre         as character no-undo get. set.
    define public property CalEvPeriodeEnCoursNumero                as character no-undo get. set.
    define public property CalEvRubriqueLoyer                       as character no-undo get. set.
    define public property CalEvUtilisation                         as character no-undo get. set.
    define public property CalEvVariationPourcentage                as character no-undo get. set.
    define public property CapitalLocataire                         as character no-undo get. set.
    define public property ChargeEnLettre                           as character no-undo get. set.
    define public property Charges                                  as character no-undo get. set.
    define public property ChargeBail                               as character no-undo get. set.
    define public property ChargeBailenLettre                       as character no-undo get. set.
    define public property ChargesFixe                              as character no-undo get. set.
    define public property ChargesFixeenLettre                      as character no-undo get. set.
    define public property Charges_en_Lettre                        as character no-undo get. set.
    define public property CiviliteLocataireTiers2                  as character no-undo get. set.
    define public property Civilite_Locataire                       as character no-undo get. set.
    define public property CodePostalLotPrincipal                   as character no-undo get. set.
    define public property CodePostalMandantInvest                  as character no-undo get. set.
    define public property Code_Postal_Locataire                    as character no-undo get. set.
    define public property Commentaire-ContentieuxLoc               as character no-undo get. set.
    define public property CommentaireImpayesLocataire              as character no-undo get. set.
    define public property ComplementAdresseIdentLocataire          as character no-undo get. set.
    define public property ComplementAdresseIdentLotPrincipal       as character no-undo get. set.
    define public property ComplementAdresseIdentNotaireContratMariageLocataire as character no-undo get. set.
    define public property ComplementAdresseIdentMandatInvest       as character no-undo get. set.

    /*--- D ---*/
    define public property DateaparutionIndice                      as character no-undo get. set.
    define public property DateaparutionIndiceSuiv                  as character no-undo get. set.
    define public property DateaparutionIndiceenLettre              as character no-undo get. set.
    define public property DateaparutionIndiceSuivenLettre          as character no-undo get. set.
    define public property Date1erQuit                              as character no-undo get. set.
    define public property Date1erQuitLettre                        as character no-undo get. set.
    define public property DateCommunicationCa                      as character no-undo get. set.
    define public property DateDbtassuranceLoc                      as character no-undo get. set.
    define public property DateDbtassuranceLocLettre                as character no-undo get. set.
    define public property DateDbtChaudiere                         as character no-undo get. set.
    define public property DateDbtChaudiereLettre                   as character no-undo get. set.
    define public property DateDbtRamonage                          as character no-undo get. set.
    define public property DateDbtRamonageLettre                    as character no-undo get. set.
    define public property DateDebutBailLettre                      as character no-undo get. set.
    define public property DateDebutBailLocPrec                     as character no-undo get. set.
    define public property DateDebutBailLocPrecLettre               as character no-undo get. set.
    define public property DateDerLoyerLocPrec                      as character no-undo get. set.
    define public property DateDerLoyerLocPrecLettre                as character no-undo get. set.
    define public property DateDernUtilisationRUMLocataire          as character no-undo get. set.
    define public property DateDerRevision                          as character no-undo get. set.
    define public property DateDerRevisionLettre                    as character no-undo get. set.
    define public property DateDerRevisionLocPrec                   as character no-undo get. set.
    define public property DateDerRevisionLocPrecenLettre           as character no-undo get. set.
    define public property DateecheanceRUMLocataire                 as character no-undo get. set.
    define public property DateeffetBail                            as character no-undo get. set.
    define public property Dateeffetofferte                         as character no-undo get. set.
    define public property DateeffetDefinitive                      as character no-undo get. set.
    define public property DateeffetDefinitiveLettre                as character no-undo get. set.
    define public property DateeffetofferteLettre                   as character no-undo get. set.
    define public property DateFinassuranceLoc                      as character no-undo get. set.
    define public property DateFinassuranceLocLettre                as character no-undo get. set.
    define public property DateFinBailLocPrec                       as character no-undo get. set.
    define public property DateFinBailLocPrecLettre                 as character no-undo get. set.
    define public property DateFinChaudiere                         as character no-undo get. set.
    define public property DateFinChaudiereLettre                   as character no-undo get. set.
    define public property DateFinRamonage                          as character no-undo get. set.
    define public property DateFinRamonageLettre                    as character no-undo get. set.
    define public property DateIndiceSuiv                           as character no-undo get. set.
    define public property DateIniBail                              as character no-undo get. set.
    define public property DateIniBailLettre                        as character no-undo get. set.
    define public property DateLaparutionIndice                     as character no-undo get. set.
    define public property DateLaparutionIndiceSuiv                 as character no-undo get. set.
    define public property DateLDbtassuranceLoc                     as character no-undo get. set.
    define public property DateLDbtChaudiere                        as character no-undo get. set.
    define public property DateLDbtRamonage                         as character no-undo get. set.
    define public property DateLDebutBailLocPrec                    as character no-undo get. set.
    define public property DateLDerRevision                         as character no-undo get. set.
    define public property DateleffetDefinitive                     as character no-undo get. set.
    define public property Dateleffetofferte                        as character no-undo get. set.
    define public property DateLDerLoyerLocPrec                     as character no-undo get. set.
    define public property DateLDerRevisionLocPrec                  as character no-undo get. set.
    define public property DateLFinassuranceLoc                     as character no-undo get. set.
    define public property DateLFinBailLocPrec                      as character no-undo get. set.
    define public property DateLFinChaudiere                        as character no-undo get. set.
    define public property DateLFinRamonage                         as character no-undo get. set.
    define public property DatelIniBail                             as character no-undo get. set.
    define public property DateLNaissanceLocataireTiers2            as character no-undo get. set.
    define public property DateLNotificationRevision                as character no-undo get. set.
    define public property DateLNouvRevision                        as character no-undo get. set.
    define public property DateLRenouvel                            as character no-undo get. set.
    define public property DatelSigBail                             as character no-undo get. set.
    define public property Datel1erQuit                             as character no-undo get. set.
    define public property DateNotificationRevision                 as character no-undo get. set.
    define public property DateNotificationRevisionLettre           as character no-undo get. set.
    define public property DateNouvRevision                         as character no-undo get. set.
    define public property DateNouvRevisionLettre                   as character no-undo get. set.
    define public property DatePassagePrelSePaLocataire             as character no-undo get. set.
    define public property DatePreNotifRUMLocataire                 as character no-undo get. set.
    define public property DateRenouvel                             as character no-undo get. set.
    define public property DateRenouvelLettre                       as character no-undo get. set.
    define public property DateResiliationLettre                    as character no-undo get. set.
    define public property DateResilTrien                           as character no-undo get. set.
    define public property DateResilTrienPrec                       as character no-undo get. set.
    define public property DateResilTrienPrecLettre                 as character no-undo get. set.
    define public property DateResilTrienLettre                     as character no-undo get. set.
    define public property DateSigBail                              as character no-undo get. set.
    define public property DateSigBailLettre                        as character no-undo get. set.
    define public property DateSignatureRUMLocataire                as character no-undo get. set.
    define public property DateSituaLocataire                       as character no-undo get. set.
    define public property DateSoldeLocataire                       as character no-undo get. set.
    define public property DateSortieBail                           as character no-undo get. set.
    define public property DateSortieBailLettre                     as character no-undo get. set.
    define public property Date_Indice                              as character no-undo get. set.
    define public property Date_de_resiliation                      as character no-undo get. set.
    define public property Date_de_Sortie                           as character no-undo get. set.
    define public property Date_naissance_locataire                 as character no-undo get. set.
    define public property DateL_de_resiliation                     as character no-undo get. set.
    define public property DateL_de_Sortie                          as character no-undo get. set.
    define public property DateL_Naissance_Locataire                as character no-undo get. set.
    define public property DebutL_Bail                              as character no-undo get. set.
    define public property DelaiNotifPrelSePaLocataire              as character no-undo get. set.
    define public property DelaisPreavis                            as character no-undo get. set.
    define public property DepotGarantieenLettre                    as character no-undo get. set.
    define public property DepotGarantieRbt                         as character no-undo get. set.
    define public property Depot_de_garantie                        as character no-undo get. set.
    define public property DernierTraitementImpayesLocataire        as character no-undo get. set.
    define public property DescriptifLoyer                          as character no-undo get. set.
    define public property DescriptifLoyerBail                      as character no-undo get. set.
    define public property DescriptifLocatNationalite               as character no-undo get. set.
    define public property DescriptifGarant                         as character no-undo get. set.
    define public property DescriptifUL                             as character no-undo get. set.
    define public property DescriptifULSurface                      as character no-undo get. set.
    define public property Descriptif_Locataire                     as character no-undo get. set.
    define public property Dossier                                  as character no-undo get. set.
    define public property DossierEnLettre                          as character no-undo get. set.
    define public property DossierBail                              as character no-undo get. set.
    define public property DossierBailenLettre                      as character no-undo get. set.
    define public property Droit                                    as character no-undo get. set.
    define public property DroitBail                                as character no-undo get. set.
    define public property DroitenLettre                            as character no-undo get. set.
    define public property DroitBailenLettre                        as character no-undo get. set.
    define public property DtaudienceContentieuxLoc                 as character no-undo get. set.
    define public property DtaudienceContentieuxLocenLettre         as character no-undo get. set.
    define public property DtDebutContentieuxLoc                    as character no-undo get. set.
    define public property DtDebutContentieuxenLettreLoc            as character no-undo get. set.
    define public property DtDebutIndisponibiliteUL                 as character no-undo get. set.
    define public property DtDelivCommandContentieuxLoc             as character no-undo get. set.
    define public property DtDelivCommandContentieuxLocenLettre     as character no-undo get. set.
    define public property DtDelivSignassignContentieuxLoc          as character no-undo get. set.
    define public property DtDelivSignassignContentieuxLocenLettre  as character no-undo get. set.
    define public property DtDepIndiceContentieuxLoc                as character no-undo get. set.
    define public property DtDepIndiceContentieuxLocenLettre        as character no-undo get. set.
    define public property DtFinIndisponibiliteUL                   as character no-undo get. set.
    define public property DtLaudienceContentieuxLoc                as character no-undo get. set.
    define public property DtLDebutContentieuxLoc                   as character no-undo get. set.
    define public property DtLDelivCommandContentieuxLoc            as character no-undo get. set.
    define public property DtLDelivSignassignContentieuxLoc         as character no-undo get. set.
    define public property DtLDepIndiceContentieuxLoc               as character no-undo get. set.
    define public property DtLimiteRenou                            as character no-undo get. set.
    define public property DtLimiteRenouLettre                      as character no-undo get. set.
    define public property DtLimitReponsePro                        as character no-undo get. set.
    define public property DtLimitReponseProLettre                  as character no-undo get. set.
    define public property DtLLimiteRenou                           as character no-undo get. set.
    define public property DtLLimitReponsePro                       as character no-undo get. set.
    define public property DtLMariageLocataire                      as character no-undo get. set.
    define public property DtMariageLocataire                       as character no-undo get. set.
    define public property DtMariageLocataireLettre                 as character no-undo get. set.
    define public property DtRequisForceContentieuxLoc              as character no-undo get. set.
    define public property DtLRequisForceContentieuxLoc             as character no-undo get. set.
    define public property DtRequisForceContentieuxLocEnLettre      as character no-undo get. set.
    define public property Debut_Bail                               as character no-undo get. set.
    define public property DureeBailenLettre                        as character no-undo get. set.
    define public property Duree_Bail                               as character no-undo get. set.
    define public property DureeResilTrien                          as character no-undo get. set.
    define public property DureeResilTrienPrec                      as character no-undo get. set.

    /*--- E ---*/
    define public property emailLocataire                           as character no-undo get. set.
    define public property emailMandantInvest                       as character no-undo get. set.
    define public property EscalierLot2UL                           as character no-undo get. set.
    define public property EscalierLot3UL                           as character no-undo get. set.
    define public property EscalierLot4UL                           as character no-undo get. set.
    define public property EtageLot2UL                              as character no-undo get. set.
    define public property EtageLot3UL                              as character no-undo get. set.
    define public property EtageLot4UL                              as character no-undo get. set.
    define public property etat                                     as character no-undo get. set.
    define public property etatBail                                 as character no-undo get. set.
    define public property etatBailenLettre                         as character no-undo get. set.
    define public property etatEnLettre                             as character no-undo get. set.
    define public property etatLieux                                as character no-undo get. set.
    define public property etatLieuxenLettre                        as character no-undo get. set.
    define public property etat-contentieuxLoc                      as character no-undo get. set.
    define public property exonerationCRL                           as character no-undo get. set.

    /*--- F ---*/
    define public property FaxLocataire                             as character no-undo get. set.
    define public property FaxMandantInvest                         as character no-undo get. set.
    define public property FgassuGarantieLoyerLoc                   as character no-undo get. set.
    define public property FgLocContentieux                         as character no-undo get. set.
    define public property FinBailLettre                            as character no-undo get. set.
    define public property Fin_Bail                                 as character no-undo get. set.
    define public property FinL_Bail                                as character no-undo get. set.
    define public property FormeCtJuridLocataire                    as character no-undo get. set.
    define public property FormeLgJuridLocataire                    as character no-undo get. set.
    define public property Frais                                    as character no-undo get. set.
    define public property FraisEnLettre                            as character no-undo get. set.
    define public property FraisBail                                as character no-undo get. set.
    define public property FraisBailenLettre                        as character no-undo get. set.
    define public property FraisCorrespondanceenLettre              as character no-undo get. set.
    define public property FraisDossier                             as character no-undo get. set.
    define public property FraisDossierenLettre                     as character no-undo get. set.
    define public property Frais_Correspondance                     as character no-undo get. set.

    /*--- H ---*/
    define public property Honoraire                                as character no-undo get. set.
    define public property HonoraireBail                            as character no-undo get. set.
    define public property HonorLocat                               as character no-undo get. set.

    /*--- I ---*/
    define public property IBaNCreancierLocataire                   as character no-undo get. set.
    define public property ICSCreancierLocataire                    as character no-undo get. set.
    define public property IndiceImpayesContentieuxLoc              as character no-undo get. set.

    /*--- J ---*/
    define public property JourMoisRevision                         as character no-undo get. set.
    define public property JourPaiement                             as character no-undo get. set.
    define public property JourPaiementenLettre                     as character no-undo get. set.

    /*--- L ---*/
    define public property LieuMariageLocataire                     as character no-undo get. set.
    define public property LieuNaissanceLocataireTiers2             as character no-undo get. set.
    define public property LieuSignatureRUMLocataire                as character no-undo get. set.
    define public property Lieu_naissance_locataire                 as character no-undo get. set.
    define public property Listeactivite                            as character no-undo get. set.
    define public property ListeLocataires                          as character no-undo get. set.
    define public property ListeLotsSurfaceUL                       as character no-undo get. set.
    define public property Loyer                                    as character no-undo get. set.
    define public property Loyerannuel                              as character no-undo get. set.
    define public property LoyerannuelBail                          as character no-undo get. set.
    define public property LoyerannuelBailLettre                    as character no-undo get. set.
    define public property LoyerannuelenCours                       as character no-undo get. set.
    define public property LoyerannuelenCoursenLettre               as character no-undo get. set.
    define public property LoyerannuelenLettre                      as character no-undo get. set.
    define public property LoyerBail                                as character no-undo get. set.
    define public property LoyerBailenLettre                        as character no-undo get. set.
    define public property LoyerChargesAnnuelBail                   as character no-undo get. set.
    define public property LoyerChargesAnnuelBailLettre             as character no-undo get. set.
    define public property LoyerContractuel                         as character no-undo get. set.
    define public property LoyerContractuelenLettre                 as character no-undo get. set.
    define public property LoyerDefinitif                           as character no-undo get. set.
    define public property LoyerDefinitifenLettre                   as character no-undo get. set.
    define public property LoyerEnLettre                            as character no-undo get. set.
    define public property LoyerLocatairePrec                       as character no-undo get. set.
    define public property LoyerLocatairePrecenLettre               as character no-undo get. set.
    define public property LoyerMensuelenCours                      as character no-undo get. set.
    define public property Loyeroffert                              as character no-undo get. set.
    define public property LoyeroffertenLettre                      as character no-undo get. set.
    define public property LoyerPrec                                as character no-undo get. set.
    define public property LoyerPrecenLettre                        as character no-undo get. set.
    define public property Loyer_en_Lettre                          as character no-undo get. set.
    define public property LstadresseGarant                         as character no-undo get. set.
    define public property LstallocataireCaF                        as character no-undo get. set.
    define public property LstGarantLocataire                       as character no-undo get. set.

    /*--- M ---*/
    define public property MajorationavantIndexation                as character no-undo get. set.
    define public property MajorationapresIndexation                as character no-undo get. set.
    define public property MilliemeLotCleGene                       as character no-undo get. set.
    define public property millieme_lot                             as character no-undo get. set.
    define public property ModePaiement                             as character no-undo get. set.
    define public property MontantecheanceRUMLocataire              as character no-undo get. set.
    define public property MotifIndisponibiliteUL                   as character no-undo get. set.
    define public property MotifResiliation                         as character no-undo get. set.
    define public property MtFraisaccessSituaLocataire              as character no-undo get. set.
    define public property MtInteretSituaLocataire                  as character no-undo get. set.
    define public property MtPrincipalSituaLocataire                as character no-undo get. set.
    define public property MtSituaLocataire                         as character no-undo get. set.
    define public property MtVariationLoyer                         as character no-undo get. set.

    /*--- N ---*/
    define public property NationaliteLocataire                     as character no-undo get. set.
    define public property NationaliteLocataireRep                  as character no-undo get. set.
    define public property NationaliteLocataireTiers2               as character no-undo get. set.
    define public property NatureBail                               as character no-undo get. set.
    define public property NatureLot                                as character no-undo get. set.
    define public property NatureLot2UL                             as character no-undo get. set.
    define public property NatureLot3UL                             as character no-undo get. set.
    define public property NatureLot4UL                             as character no-undo get. set.
    define public property NbMoisDG                                 as character no-undo get. set.
    define public property NoBICGarant                              as character no-undo get. set.
    define public property NoBICLocataire                           as character no-undo get. set.
    define public property NbPiecesLotPrincipalEnLettres            as character no-undo get. set.
    define public property NoCaFLocataire                           as character no-undo get. set.
    define public property NoCompteBancaireGarant                   as character no-undo get. set.
    define public property NoCompteBancaireLocataire                as character no-undo get. set.
    define public property NoLocataire                              as character no-undo get. set.
    define public property NoLotPrincipal                           as character no-undo get. set.
    define public property NoLot2UL                                 as character no-undo get. set.
    define public property NoLot3UL                                 as character no-undo get. set.
    define public property NoLot4UL                                 as character no-undo get. set.
    define public property NoMandatInvest                           as character no-undo get. set.
    define public property NomassuranceLoc                          as character no-undo get. set.
    define public property NomCompletCoMandantInvest                as character no-undo get. set.
    define public property NomCompletLocataire                      as character no-undo get. set.
    define public property NomCompletLocatairePrec                  as character no-undo get. set.
    define public property NomCompletLocataireTiers2                as character no-undo get. set.
    define public property NomCompletLocCo                          as character no-undo get. set.
    define public property NomCompletLocContact                     as character no-undo get. set.
    define public property NomCompletLocRep                         as character no-undo get. set.
    define public property NomCompletMandantInvest                  as character no-undo get. set.
    define public property NomCreancierLocataire                    as character no-undo get. set.
    define public property NomFournisseurChaudiere                  as character no-undo get. set.
    define public property NomFournisseurRamonage                   as character no-undo get. set.
    define public property NomLocatairePrec                         as character no-undo get. set.
    define public property NomLocContact                            as character no-undo get. set.
    define public property NomModifPrelSePaLocataire                as character no-undo get. set.
    define public property NomNotaireContratMariageLocataire        as character no-undo get. set.
    define public property NomReclamPrelSePaLocataire               as character no-undo get. set.
    define public property Nom_Locataire                            as character no-undo get. set.
    define public property NumContratChaudiere                      as character no-undo get. set.
    define public property NumContratRamonage                       as character no-undo get. set.
    define public property NumLocatairePrec                         as character no-undo get. set.
    define public property NumMandantInvest                         as character no-undo get. set.
    define public property NumPoliceLoc                             as character no-undo get. set.
    define public property NumRCSLocataire                          as character no-undo get. set.
    define public property NumUL                                    as character no-undo get. set.

    /*--- P ---*/
    define public property PaysLocataire                            as character no-undo get. set.
    define public property PaysMandantInvest                        as character no-undo get. set.
    define public property Pays_Naissance_LocataireTiers2           as character no-undo get. set.
    define public property Periodicite_paiement                     as character no-undo get. set.
    define public property Periodicite_Revision                     as character no-undo get. set.
    define public property PolitesseLocataire                       as character no-undo get. set.
    define public property PolitesseLocatairePrec                   as character no-undo get. set.
    define public property PortableGarant                           as character no-undo get. set.
    define public property PortableLocataire                        as character no-undo get. set.
    define public property PortableLocatairePrec                    as character no-undo get. set.
    define public property PourPenaliteCa                           as character no-undo get. set.
    define public property PourVariationSuiv                        as character no-undo get. set.
    define public property PrixM2                                   as character no-undo get. set.
    define public property PrixM2SurfPonderee                       as character no-undo get. set.
    define public property PrixM2annuel                             as character no-undo get. set.
    define public property PrixM2Carrez                             as character no-undo get. set.
    define public property PrixM2Mensuel                            as character no-undo get. set.
    define public property ProchainIndiceBail                       as character no-undo get. set.
    define public property Profession_Locataire                     as character no-undo get. set.

    /*--- Q ---*/
    define public property QuotePartLocCRL                          as character no-undo get. set.
    define public property QuotePartLocIF                           as character no-undo get. set.
    define public property QuotePartLocTaxeBureau                   as character no-undo get. set.

    /*--- R ---*/
    define public property ReactualisationDG                        as character no-undo get. set.
    define public property RegimeMatrimonialLocataire               as character no-undo get. set.
    define public property RUMLocataire                             as character no-undo get. set.

    /*--- S ---*/
    define public property SoldeCompteCrediteur                     as character no-undo get. set.
    define public property SoldeCompteCrediteurenLettre             as character no-undo get. set.
    define public property SoldeCompteDebiteur                      as character no-undo get. set.
    define public property SoldeCompteDebiteurenLettre              as character no-undo get. set.
    define public property SoldeLocataire                           as character no-undo get. set.
    define public property SoldeDateDocLocataire                    as character no-undo get. set.
    define public property SoldeDateDocLocataireEnLettre            as character no-undo get. set.
    define public property SoldeLocataireenLettre                   as character no-undo get. set.
    define public property SuiteadresseLotPrincipal                 as character no-undo get. set.
    define public property SuiteadresseMandantInvest                as character no-undo get. set.
    define public property Suite_adresse_Locataire                  as character no-undo get. set.
    define public property SurfPondereeUL                           as character no-undo get. set.
    define public property SurfUtilesUL                             as character no-undo get. set.


    /*--- T ---*/
    define public property TaciteReconduction                       as character no-undo get. set.
    define public property TacheCalendrier                          as character no-undo get. set.
    define public property TacheCRL                                 as character no-undo get. set.
    define public property TacheImpotFoncier                        as character no-undo get. set.
    define public property TacheTaxeBureau                          as character no-undo get. set.
    define public property TacheTVa                                 as character no-undo get. set.
    define public property Tauxaugmentation                         as character no-undo get. set.
    define public property TauxTVaBail                              as character no-undo get. set.
    define public property Taux_Revision                            as character no-undo get. set.
    define public property Taxeadd                                  as character no-undo get. set.
    define public property TaxeaddBail                              as character no-undo get. set.
    define public property TaxeaddenLettre                          as character no-undo get. set.
    define public property TaxeaddBailenLettre                      as character no-undo get. set.
    define public property TelephoneGarant                          as character no-undo get. set.
    define public property TelephoneLocataire                       as character no-undo get. set.
    define public property TelephoneMandantInvest                   as character no-undo get. set.
    define public property Terme_paiement                           as character no-undo get. set.
    define public property TitreLLocataire                          as character no-undo get. set.
    define public property TitreLLocatairePrec                      as character no-undo get. set.
    define public property TitreLocatairePrec                       as character no-undo get. set.
    define public property TitreLocContact                          as character no-undo get. set.
    define public property TitreLMandantInvest                      as character no-undo get. set.
    define public property Titre_Locataire                          as character no-undo get. set.
    define public property TituRibGarant                            as character no-undo get. set.
    define public property TituRibLoc                               as character no-undo get. set.
    define public property TotalHonoraire                           as character no-undo get. set.
    define public property TotalHonoraireLocation                   as character no-undo get. set.
    define public property TotalHonoraireLocationenLettre           as character no-undo get. set.
    define public property TotalPremiereechperiodecomplete          as character no-undo get. set.
    define public property TotalPremiereechperiodecompleteenLettre  as character no-undo get. set.
    define public property TotalQuittance                           as character no-undo get. set.
    define public property TotalQuittanceEnLettre                   as character no-undo get. set.
    define public property TotalQuittanceProratee                   as character no-undo get. set.
    define public property TotalQuittanceProrateeenLettre           as character no-undo get. set.
    define public property TpDepotGarantie                          as character no-undo get. set.
    define public property TVa                                      as character no-undo get. set.
    define public property TVaenLettre                              as character no-undo get. set.
    define public property TVaBail                                  as character no-undo get. set.
    define public property TVaBailenLettre                          as character no-undo get. set.
    define public property TypeIndicePrec                           as character no-undo get. set.
    define public property Type_Indice                              as character no-undo get. set.

    /*--- U ---*/
    define public property UsageLocaux                              as character no-undo get. set.
    define public property UsageLocauxLocPrec                       as character no-undo get. set.

    /*--- V ---*/
    define public property ValeurIndicePrec                         as character no-undo get. set.
    define public property ValeurIndiceSuiv                         as character no-undo get. set.
    define public property VilleLotPrincipal                        as character no-undo get. set.
    define public property Valeur_indice_Revision                   as character no-undo get. set.
    define public property VilleCedexLocataire                      as character no-undo get. set.
    define public property VilleCedexLotPrincipal                   as character no-undo get. set.
    define public property VilleCedexRCSLocataire                   as character no-undo get. set.
    define public property VillecedexMandantInvest                  as character no-undo get. set.
    define public property VilleCedexNotaireContratMariageLocataire as character no-undo get. set.
    define public property VilleLocataire                           as character no-undo get. set.
    define public property VilleMandantInvest                       as character no-undo get. set.
    define public property VilleNotaireContratMariageLocataire      as character no-undo get. set.
    define public property VilleRCSLocataire                        as character no-undo get. set.

end class.
