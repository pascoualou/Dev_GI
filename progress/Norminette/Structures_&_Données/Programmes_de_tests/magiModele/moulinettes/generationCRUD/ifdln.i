/*------------------------------------------------------------------------
File        : ifdln.i
Purpose     : Table des lignes de facturation diverse
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIfdln
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field affair-num  as decimal    initial ?  decimals 0
    field art-cle     as character  initial ? 
    field com-num     as integer    initial ? 
    field desig1      as character  initial ? 
    field desig2      as character  initial ? 
    field desigcomp   as logical    initial ? 
    field divers      as character  initial ? 
    field etab-cd     as integer    initial ? 
    field fam-cle     as character  initial ? 
    field fg-ana100   as logical    initial ? 
    field lig-num     as integer    initial ? 
    field MtProCop    as decimal    initial ?  decimals 2
    field mttva       as decimal    initial ?  decimals 2
    field mttva-EURO  as decimal    initial ?  decimals 2
    field pourc       as decimal    initial ?  decimals 2
    field puht        as decimal    initial ?  decimals 2
    field puht-EURO   as decimal    initial ?  decimals 2
    field qtefac      as decimal    initial ?  decimals 2
    field rem1        as decimal    initial ?  decimals 2
    field sfam-cle    as character  initial ? 
    field soc-cd      as integer    initial ? 
    field taxe-cd     as integer    initial ? 
    field tva-enc-deb as logical    initial ? 
    field txcomm      as decimal    initial ?  decimals 2
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
