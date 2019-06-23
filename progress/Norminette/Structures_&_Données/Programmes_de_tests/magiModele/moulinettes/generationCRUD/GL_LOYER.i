/*------------------------------------------------------------------------
File        : GL_LOYER.i
Purpose     : Liste des éléments financiers de type loyer
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttGl_loyer
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy          as character  initial ? 
    field cdmsy          as character  initial ? 
    field charge_ht      as decimal    initial ?  decimals 2
    field charge_ttc     as decimal    initial ?  decimals 2
    field dtcsy          as date       initial ? 
    field dtdeb_quit     as date       initial ? 
    field dtindice_rev   as date       initial ? 
    field dtmsy          as date       initial ? 
    field hecsy          as integer    initial ? 
    field hemsy          as integer    initial ? 
    field indice_connu   as decimal    initial ?  decimals 2
    field indice_rev     as decimal    initial ?  decimals 2
    field lbindice_connu as character  initial ? 
    field lbindice_rev   as character  initial ? 
    field loyercc_annuel as decimal    initial ?  decimals 2
    field loyerhc_ht     as decimal    initial ?  decimals 2
    field loyerhc_ttc    as decimal    initial ?  decimals 2
    field noecheance     as integer    initial ? 
    field nofinance      as integer    initial ? 
    field noindice       as integer    initial ? 
    field noloyer        as integer    initial ? 
    field noperio        as integer    initial ? 
    field totalht        as decimal    initial ?  decimals 2
    field totalht_pro    as decimal    initial ?  decimals 2
    field totalttc       as decimal    initial ?  decimals 2
    field totalttc_pro   as decimal    initial ?  decimals 2
    field tployer        as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
