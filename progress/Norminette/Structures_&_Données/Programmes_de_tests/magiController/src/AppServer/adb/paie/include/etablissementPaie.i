/*------------------------------------------------------------------------
File        : etablissementPaie.i
Purpose     : 
Author(s)   : GGA  -  2017/11/15
Notes       :
derniere revue: 2018/05/17 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttEtablissementPaie
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cCodeSociete           as character initial ?   /* code société envoyé à Pégase lors de la création */
    field cTypeContrat           as character initial ?
    field iNumeroContrat         as integer   initial ?
    field cTypeRole              as character initial ?
    field iNumeroRole            as integer   initial ?
    field cLibIntervenantContrat as character initial ?
    field daDebutPaiePegase      as date                  // Date de début de la paie Pégase
    field daFinPaiePegase        as date                  // Date de fin de la paie Pégase
    field daExport               as date                  // Date du 1er expor vers Pégase
    field cCodeSiret             as character initial ?
    field cCodeNic               as character initial ?
    field cCodeUrssaf            as character initial ?
    field cNomUrssaf             as character initial ?   /* Ajout SY le 04/07/2014 */
    field cCodeRecette           as character initial ?
    field cNomRecette            as character initial ?   /* Ajout SY le 04/07/2014 */
    field cOrgRetraite           as character initial ?   /* Retraites */
    field cOrgPrevoyance         as character initial ?   /* Prevoyances */
    field cOrgMutuelle           as character initial ?   /* Mutuelles */
    field dTauxTaxSal            as decimal   initial ?   /* taux assujettissement Taxe/Salaire */
    field iNumeroImmeuble        as integer   initial ?
    field iNumeroGestionnaire    as integer   initial ?
    field cNomGestionnaire       as character initial ?
    field daResiliationContrat   as date                  // date résiliation              
.
