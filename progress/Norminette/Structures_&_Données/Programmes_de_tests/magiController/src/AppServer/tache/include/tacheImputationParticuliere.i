/*------------------------------------------------------------------------
File        : tacheImputationParticuliere.i
Purpose     : table tache Imputation Particulière (Liste)
Author(s)   : RF  -  05/01/2018
Notes       :
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTacheImputationParticuliere
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroContrat       as integer   initial ? /* nocon */      
    field cTypeContrat         as character initial ? /* tpcon */ 
    field iNumeroImputation    as integer   initial ? /* dtimp converti en integer aaaammjj */            
    field iNumeroPeriodeCharge as integer   initial ? /* noexo */
    field cLibelleImputation   as character initial ? /* lbimp */   
    field daDateImputation     as date      initial ? /* dtimp */
    field dMontantTTC          as decimal   initial ? /* mtttc */

    field dtTimestamp as datetime 
    field CRUD        as character     /* "R" - lecture simple ici */
.
