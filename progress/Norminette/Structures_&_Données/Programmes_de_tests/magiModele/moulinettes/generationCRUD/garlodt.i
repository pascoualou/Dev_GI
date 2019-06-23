/*------------------------------------------------------------------------
File        : garlodt.i
Purpose     : 0808/0042 - Garantie loyer calculée par locataire
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttGarlodt
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdass    as character  initial ? 
    field cdcsy    as character  initial ? 
    field cdmsy    as character  initial ? 
    field cdper    as character  initial ? 
    field cdter    as character  initial ? 
    field dermsqtt as integer    initial ? 
    field dtappli  as date       initial ? 
    field dtcsy    as date       initial ? 
    field dtdebqtt as date       initial ? 
    field dtfinqtt as date       initial ? 
    field dtmsy    as date       initial ? 
    field fgGRL    as logical    initial ? 
    field hecsy    as integer    initial ? 
    field hemsy    as integer    initial ? 
    field msqtt    as integer    initial ? 
    field mtchg    as decimal    initial ?  decimals 2
    field mtcot    as decimal    initial ?  decimals 2
    field mtfor    as decimal    initial ?  decimals 2
    field mthon    as decimal    initial ?  decimals 2
    field mtloy    as decimal    initial ?  decimals 2
    field mtqtt    as decimal    initial ?  decimals 2
    field mtres    as decimal    initial ?  decimals 2
    field nobar    as integer    initial ? 
    field nogar    as integer    initial ? 
    field nomdt    as integer    initial ? 
    field nompre   as character  initial ? 
    field norol    as decimal    initial ?  decimals 2
    field pcUESL   as decimal    initial ?  decimals 2
    field tpgar    as character  initial ? 
    field tpmdt    as character  initial ? 
    field tprol    as character  initial ? 
    field tptac    as character  initial ? 
    field txcot    as decimal    initial ?  decimals 4
    field txdivttc as decimal    initial ?  decimals 2
    field txres    as decimal    initial ?  decimals 4
    field txtregul as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
