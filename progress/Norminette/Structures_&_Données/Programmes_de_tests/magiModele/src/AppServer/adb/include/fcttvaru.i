/*------------------------------------------------------------------------
File        : fctTvaRu.i
Purpose     : Variables et Fonction pour les rubriques de TVA et TVA Articles Honoraires du Quittancement
Author(s)   : SY - 2013/11/07, Kantena 2017/12/27
Notes       : necessite profil2rubQuit.i pour la liste des rubriques TVA concernées.

01 21/11/2013  SY    Ajout f_donnerubtva
02 13/01/14    OF    0114/0115: TVA doublée en facture d'entrée
03 16/01/2014  OF/SY 0114/0115: Pb PROPATH compil compta et adb différents => impossible d'utiliser un sous-include
04 24/01/2014  SY    1113/0188: f_donnerubtva Correction recherche TVA/service Fam 4: la sfam 2 n'est pas concernée
05 08/02/2017  SY    1011/0158: Ajout fonction f_isRubSoumiseTVABail
------------------------------------------------------------------------*/

function f_donnetauxtvarubqt returns decimal (piNumeroRubrique as integer):
    /*------------------------------------------------------------------------
    Purpose :
    Notes   : -1 si taux non trouvé
    ------------------------------------------------------------------------*/
    define buffer rubqt for rubqt.

    for first rubqt no-lock
        where rubqt.cdrub = piNumeroRubrique
          and rubqt.cdlib = 0:
        return decimal(rubqt.prg04) / 100.
    end.
    return -1.
end function.

function donneTauxTvaArticleDate return decimal(piCabinet as integer, pcArticle as character, pdaCompta as date):
    /*------------------------------------------------------------------------
    Purpose : fonction de récupération du taux de TVA d'un article selon la date comptable
    Notes   :
    ------------------------------------------------------------------------*/
    define buffer ifdart for ifdart.
    define buffer itaxe  for itaxe.
    /* Se positionner sur l'article */
    for first ifdart no-lock
        where ifdart.soc-cd  = piCabinet
          and ifdart.art-cle = pcArticle
      , first itaxe no-lock
        where itaxe.soc-cd  = ifdart.soc-cd
          and itaxe.taxe-cd = ifdart.taxe-cd:
        /* SY 1013/0167 Changement taux de TVA au 01/01/2014 */
        if pdaCompta >= 01/01/2014 then do:
            if itaxe.taux = 7    then return 10.
            if itaxe.taux = 19.6 then return 20.
        end.
        else do:
            if itaxe.taux = 10 then return 7.
            if itaxe.taux = 20 then return 19.6.
        end.
        return itaxe.taux.
    end.
    return 0.
end function.

function f_donnerubtva returns integer(piRubrique as integer, pdeTauxTva as decimal):
    /*------------------------------------------------------------------------
    Purpose : fonction de récupération de la rubrique de TVA "calculée" pour une rubrique de quitt (Hors HL)
    Notes   :
    ------------------------------------------------------------------------*/
    define variable vcListeRubrique as character no-undo.
    define variable viBoucle        as integer   no-undo.
    define variable viItem          as integer   no-undo.
    define buffer rubqt for rubqt.

    /* Rubrique de TVA du bail ou TVA sur services ? */
    find first rubqt no-lock
        where rubqt.cdrub = piRubrique
          and rubqt.cdlib = 0 no-error.
    if available rubqt then do:
        vcListeRubrique = {&ListeRubqtTVA-Calcul}.
        if rubqt.cdfam = 4 and (rubqt.cdsfa = 3 or rubqt.cdsfa = 5 or rubqt.cdsfa = 6 or rubqt.cdsfa = 8)
        then vcListeRubrique = {&ListeRubqtTVAService-Calcul}.
    end.
    do viBoucle = 1 to num-entries(vcListeRubrique, ","):
        viItem = integer(entry(viBoucle, vcListeRubrique, ",")).
        for first rubqt no-lock
            where rubqt.cdrub = viItem
              and rubqt.cdlib > 00 and rubqt.cdlib < 99
              and rubqt.cdfam = 05
              and rubqt.cdsfa = 02
              and rubqt.prg04 = string(pdeTauxTva * 100):
            return rubqt.cdrub.
        end.
    end.
    return 0.
end function.

function f_isRubSoumiseTVABail returns logical
    (pcModeCalcul as character, pcFamille as integer, pcSousFamille as integer, piRubrique as integer, piRubrique05 as integer):
    /*------------------------------------------------------------------------
    Purpose : Recherche si une rubrique de quitt est soumise à la TVA du Bail (tâche 04039)
    Notes   : SY 1011/0158
    ------------------------------------------------------------------------*/
    case pcModeCalcul:
        when {&MODECALCUL-loyer}
        then return (pcFamille = 1 and pcSousFamille <> 4).  /* Total loyer (sauf APL) */
        when {&MODECALCUL-quittance} then do: /* Total quittance (sauf rubriques TVA,APL, services hoteliers, assurance locatives, DG, Hono TTC */
            case pcFamille:
                when 01 then return pcSousFamille <> 04.    /* Loyer : sauf APL */
                when 02 then return true.                   /* Charges */
                when 03 then return pcSousFamille <> 03 and (piRubrique <> 504 and piRubrique <> 505).   /* Divers : sauf DG et prestation assurance */
                when 04 then if pcSousFamille = 01 and piRubrique <> 629 then return true.               /* SY 1011/0158 interets sur arrieres non soumis à TVA */
                             else if pcSousFamille = 02 and ( piRubrique = 635 or  piRubrique = 636) then return true.
                             else if  pcSousFamille = 04 then return true.
                when 05 then return pcSousFamille <> 2 or piRubrique05 <> 7.
            end case.
        end.

        when {&MODECALCUL-loyerEtCharges}
        then return (pcFamille = 1 and pcSousFamille <> 4) or pcFamille = 2.

        when {&MODECALCUL-loyerEtChargesEtTaxes}
        then return (pcFamille = 1 and pcSousFamille <> 4) or pcFamille = 2 or (pcFamille = 5 and (pcSousFamille <> 2 or piRubrique05 <> 7)).

        when {&MODECALCUL-loyerEtTaxes}
        then return (pcFamille = 1 and pcSousFamille <> 4) or (pcFamille = 5 and (pcSousFamille <> 2 or piRubrique05 <> 7)).

        when {&MODECALCUL-quittanceEtCharges} then do:   /* (Ajout SY le 20/12/2007) */
            case pcFamille:
                when 01 then return pcSousFamille <> 04.     /* Loyer : sauf APL */
                when 03 then return pcSousFamille <> 03 and (piRubrique <> 504 and piRubrique  <> 505).     /* Divers : sauf DG et prestation assurance */
                when 04 then if pcSousFamille = 01 and piRubrique <> 629 then return true.                                /* SY 1011/0158 interets sur arrieres non soumis à TVA */
                             else if pcSousFamille = 02 and (piRubrique = 635 or piRubrique = 636) then return true.
                             else if pcSousFamille = 04 then return true.
                when 05 then return pcSousFamille <> 2 or piRubrique05 <> 7.
            end case.
        end.
    end case.
    return false.
end function.
