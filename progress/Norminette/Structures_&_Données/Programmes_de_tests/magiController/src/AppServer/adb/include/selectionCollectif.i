/*------------------------------------------------------------------------
File        : listeCollectif.i
Purpose     :
Author(s)   : gga - 2018/10/08
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttlisteCollectif
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cTypeContrat       as character initial ?
    field iNumeroContrat     as int64     initial ?
    field cCompteCollectif   as character initial ?
    field cCodeCollectif     as character initial ?
    field cLibelleCollectif  as character initial ?
    field cSousCompte        as character initial ?    
    field cLibelleSousCompte as character initial ?    
.
