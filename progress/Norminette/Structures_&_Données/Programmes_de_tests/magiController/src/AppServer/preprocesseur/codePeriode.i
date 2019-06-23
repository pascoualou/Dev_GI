/*------------------------------------------------------------------------
File        : codePeriode.i
Purpose     : Variables préprocesseur des code période
Author(s)   : Kantena - 2016/09/12
Notes       : ATTENTION, perio.cdper, tache.pdges --> 5 caractères,
                         ietab.perio --> entier, 2 positions !!!!!.
              Le Mode de calcul pour les assurances est aussi dans pdreg/pdges (code periode !!!)
------------------------------------------------------------------------*/

&GLOBAL-DEFINE CODEPERIODE-annuel      "00001"
&GLOBAL-DEFINE CODEPERIODE-semestriel  "00002"
&GLOBAL-DEFINE CODEPERIODE-trimestriel "00003"
&GLOBAL-DEFINE CODEPERIODE-mensuel     "00004"
&GLOBAL-DEFINE CODEPERIODE-indetermine "00099"

&GLOBAL-DEFINE CODEPERIODE-iAnnuel      12
&GLOBAL-DEFINE CODEPERIODE-iSemestriel  6
&GLOBAL-DEFINE CODEPERIODE-iTrimestriel 3
&GLOBAL-DEFINE CODEPERIODE-iMensuel     1
&GLOBAL-DEFINE CODEPERIODE-iIndetermine 99

&GLOBAL-DEFINE CODEPERIODE-00000                            "00000" //Inutile (signifie aucune période)
&GLOBAL-DEFINE PERIODICITEGESTION-mensuel                   "20001"
&GLOBAL-DEFINE PERIODICITEGESTION-trimestriel               "20002"
&GLOBAL-DEFINE PERIODICITEGESTION-semestriel                "20003"
&GLOBAL-DEFINE PERIODICITEGESTION-annuel                    "20005"
&GLOBAL-DEFINE PERIODICITEGESTION-fiscale                   "20006"
&GLOBAL-DEFINE PERIODICITEGESTION-trimestrielJanMars        "20010"
&GLOBAL-DEFINE PERIODICITEGESTION-trimestrielFevAvril       "20011"
&GLOBAL-DEFINE PERIODICITEGESTION-trimestrielMarsMai        "20012"
&GLOBAL-DEFINE PERIODICITEGESTION-annuelNormal              "20031"
&GLOBAL-DEFINE PERIODICITEGESTION-annuelForfait             "20032"
&GLOBAL-DEFINE PERIODICITEHONORAIRES-mensuel                "16101"
&GLOBAL-DEFINE PERIODICITEHONORAIRES-trimestrielJanMars     "16301"
&GLOBAL-DEFINE PERIODICITEHONORAIRES-trimestrielFevAvril    "16302"
&GLOBAL-DEFINE PERIODICITEHONORAIRES-trimestrielMarsMai     "16303"

&GLOBAL-DEFINE MODECALCUL-loyer                 "00001"
&GLOBAL-DEFINE MODECALCUL-quittance             "00002"
&GLOBAL-DEFINE MODECALCUL-loyerEtCharges        "00003"
&GLOBAL-DEFINE MODECALCUL-loyerEtChargesEtTaxes "00004"
&GLOBAL-DEFINE MODECALCUL-loyerEtTaxes          "00005"
&GLOBAL-DEFINE MODECALCUL-quittanceEtCharges    "00006"

&GLOBAL-DEFINE PERIODICITEPNO-mensuel     "00001"
&GLOBAL-DEFINE PERIODICITEPNO-trimestriel "00003"
&GLOBAL-DEFINE PERIODICITEPNO-semestriel  "00006"
&GLOBAL-DEFINE PERIODICITEPNO-annuel      "00012"

&GLOBAL-DEFINE PERIODICITEBAIL-annuel     "00001"                     
&GLOBAL-DEFINE PERIODICITEBAIL-mensuel    "00002"
