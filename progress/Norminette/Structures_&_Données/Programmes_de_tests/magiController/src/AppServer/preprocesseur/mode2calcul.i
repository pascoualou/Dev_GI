/*------------------------------------------------------------------------
    File        : mode2calcul.i
    Purpose     : Variables préprocesseur des modes de calcul
    Author(s)   : npo - 2018/07/23
    Notes       :
  ----------------------------------------------------------------------*/
// sys_pr CDCAL : mode de calcul TVA du bail (tache 04039)
&GLOBAL-DEFINE MODECALCUL-loyer                 "00001"
&GLOBAL-DEFINE MODECALCUL-quittance             "00002"
&GLOBAL-DEFINE MODECALCUL-loyerEtCharges        "00003"
&GLOBAL-DEFINE MODECALCUL-loyerEtChargesEtTaxes "00004"
&GLOBAL-DEFINE MODECALCUL-loyerEtTaxes          "00005"
&GLOBAL-DEFINE MODECALCUL-quittanceMoinsCharges "00006"

// R_CAL Lien Tâche 04010 - Mode de calcul DG
&GLOBAL-DEFINE MODECALCULDG-loyerFacture        "00001"
&GLOBAL-DEFINE MODECALCULDG-loyerContractuel    "00002"

// TPCAL Tache Revision Loyer
&GLOBAL-DEFINE MODECALCULREVISION-00000               "00000"
&GLOBAL-DEFINE MODECALCULREVISION-CalendrierEvolution "00001"
&GLOBAL-DEFINE MODECALCULREVISION-EchelleMobile       "00002"