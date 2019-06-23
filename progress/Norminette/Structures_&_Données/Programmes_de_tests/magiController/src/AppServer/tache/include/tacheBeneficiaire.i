/*------------------------------------------------------------------------
File        : tacheBeneficiaire.i
Purpose     :
Author(s)   : gga - 2017/09/06
Notes       : 
derneire revue: 2018/05/18 - gga: 0K
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTacheBeneficiaire 
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cTypeContrat        as character initial ?   
    field iNumeroContrat      as integer   initial ?  
    field iNumeroIndivisaire  as integer   initial ?     
    field cTypeIndivisaire    as character initial ? //si 00022 indivisaire = mandant (mandat sasn indivision)
    field iNumeroBeneficiaire as integer   initial ? /* no role beneficiaire  */
    field iNumeroTiers        as integer   initial ? /* no tiers beneficiaire */
    field cNom                as character initial ? /* NOM prenom            */
    field iNumeroBanque       as integer   initial ? /* no contrat banque     */ 
    field cIbanBq             as character initial ? /* compte bancaire       */
    field cDomiciliationBq    as character initial ? /* Domiciliation bancaire*/
    field cTitulairebq        as character initial ? /* Titulaire IBAN */
    field cLibModeReglement   as character initial ? /* libelle mode reglt    */
    field cModeReglement      as character initial ? /* code mode reglt       */
    field iTantieme           as integer   initial ? /* tantiemes             */
    field iBase               as integer   initial ? /* base                  */
    field lACompleter         as logical   initial ? 

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid      
.
