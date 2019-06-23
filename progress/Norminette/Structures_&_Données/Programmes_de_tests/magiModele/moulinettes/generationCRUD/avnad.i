/*------------------------------------------------------------------------
File        : avnad.i
Purpose     : Avantages en nature (détail)
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAvnad
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy     as character  initial ? 
    field cdmat     as character  initial ? 
    field cdmsy     as character  initial ? 
    field cdpos     as character  initial ? 
    field cdreg     as character  initial ? 
    field cdsec     as character  initial ? 
    field cduni     as character  initial ? 
    field dtcsy     as date       initial ? 
    field dtdeb     as date       initial ? 
    field dtent     as date       initial ? 
    field dtfin     as date       initial ? 
    field dtmsy     as date       initial ? 
    field dtsor     as date       initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field lbad1     as character  initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field lbnom     as character  initial ? 
    field lbvil     as character  initial ? 
    field mtavnat0  as decimal    initial ?  decimals 2
    field mtavnat1  as decimal    initial ?  decimals 2
    field mtvlo     as decimal    initial ?  decimals 2
    field mtvlo-an  as decimal    initial ?  decimals 2
    field mtvlo-gi  as decimal    initial ?  decimals 2
    field nbenf     as integer    initial ? 
    field noann     as integer    initial ? 
    field noapp     as integer    initial ? 
    field nomdt     as integer    initial ? 
    field ntlot     as character  initial ? 
    field pdavn     as character  initial ? 
    field tbam1     as decimal    initial ?  decimals 2
    field tbam1-dev as decimal    initial ?  decimals 2
    field tbanx     as decimal    initial ?  decimals 2
    field tbanx-dev as decimal    initial ?  decimals 2
    field tbhab     as decimal    initial ?  decimals 2
    field tbhab-dev as decimal    initial ?  decimals 2
    field tbloy     as decimal    initial ?  decimals 2
    field tbmoi     as integer    initial ? 
    field tbsup     as decimal    initial ?  decimals 2
    field tbsup-dev as decimal    initial ?  decimals 2
    field txaba     as decimal    initial ?  decimals 2
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
