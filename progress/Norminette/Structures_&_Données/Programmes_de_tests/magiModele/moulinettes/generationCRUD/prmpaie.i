/*------------------------------------------------------------------------
File        : prmpaie.i
Purpose     : 0208/0323 : avenant 69 de Paie
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttPrmpaie
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy   as character  initial ? 
    field cdmsy   as character  initial ? 
    field coeff   as character  initial ? 
    field dtcsy   as date       initial ? 
    field dtdeb   as date       initial ? 
    field dtmsy   as date       initial ? 
    field hecsy   as integer    initial ? 
    field hemsy   as integer    initial ? 
    field lbdiv   as character  initial ? 
    field lbdiv2  as character  initial ? 
    field lbdiv3  as character  initial ? 
    field montant as decimal    initial ?  decimals 4
    field tppar   as character  initial ? 
    field valeurA as decimal    initial ?  decimals 4
    field valeurB as decimal    initial ?  decimals 4
    field valeurC as decimal    initial ?  decimals 4
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
