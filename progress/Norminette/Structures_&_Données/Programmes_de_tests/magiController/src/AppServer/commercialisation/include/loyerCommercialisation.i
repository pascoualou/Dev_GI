/*------------------------------------------------------------------------
File        : loyerCommercialisation.i
Purpose     : Table entête 1ère quittance (Loyer, charges, indice révision...)
Author(s)   : SY  -  13/01/2017 
Notes       :
derniere revue: 2018/05/23 - phm: OK
        en fait KO, il manque le champ rRowid sur ttLoyerCommercialisation
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttLoyerCommercialisation
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroLoyer               as integer   initial ? label 'noloyer'
    field iNumeroElementFinance      as integer   initial ? label 'nofinance'
    field iNumeroFiche               as integer   initial ?
    field iNumeroHisto               as integer   initial ?
    field iTypeLoyer                 as integer   initial ? label 'tployer'
    field iPeriodiciteLoyer          as integer   initial ? label 'noperio'         // liste ?
    field iEcheanceLoyer             as integer   initial ? label 'noecheance'      // 1 = avance , 2 = Echu (sys_pr TEQTT)
    field iIndiceRevision            as integer   initial ? label 'noindice'        // 6 = ICC, 201 = IRL (indrv)
    field cLibelleCourtIndice        as character initial ? label ''                // IRL, ILAT, ICC
    field dValeurIndice              as decimal   initial ? label 'indice_rev'      
    field cLibelleCompletIndice      as character initial ? label 'lbindice_rev'    // saisie libre dans la fiche
    field daDateIndiceRevision       as date                label 'dtindice_rev'    // date saisie dans la fiche
    field dValeurIndiceConnu         as decimal   initial ? label 'indice_connu'  
    field cLibelleCompletIndiceConnu as character initial ? label 'lbindice_connu'  // saisie libre
    field iCodeTva                   as integer   initial ? label 'CdTva'    
    field dTauxTVA                   as decimal   initial ?
    field dMontantHorsChargeHT       as decimal   initial ? label 'loyerhc_ht'
    field dMontantHorsChargeTTC      as decimal   initial ? label 'loyerhc_ttc'
    field dMontantChargeHT           as decimal   initial ? label 'charge_ht'
    field dMontantChargeTTC          as decimal   initial ? label 'charge_ttc'
    field daDateEntree               as date                label 'dtdeb_quit'
    field dMontantTotalHT            as decimal   initial ? label 'totalht'
    field dMontantTotalTTC           as decimal   initial ? label 'totalttc'
    field dMontantTotalHTProrata     as decimal   initial ? label 'totalht_pro'
    field dMontantTotalTTCProrata    as decimal   initial ? label 'totalttc_pro'    
    field dMontantTotalAnnuelHT      as decimal   initial ? label 'loyercc_annuel'

    field dtTimestamp as datetime
    field CRUD        as character
.

