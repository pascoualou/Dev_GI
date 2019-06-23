/*------------------------------------------------------------------------
File        : tmprubcal.i
Purpose     : 
Author(s)   : kantena  -  2017/11/27 
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttRubCal
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdrub     as integer          /* rubrique  */
    field cdlib     as integer          /* no lib rubrique  */
    field lib       as character        
    field MtTot     as decimal          /* Montant total rubrique */
    field vlmtq     as decimal          /* Montant rubrique quittancé*/
    field fg-rubtva as logical          /* flag rubrique de TVA (ex : 758.01, 778.01...) */
    field fg-calc   as logical          
    field cdfam     as integer
    field cdsfa     as integer
    field rubtva    as integer          /* rub TVA associée */
    field taux      as decimal          /* taux TVA */
index primaire is primary unique cdRub cdLib
.