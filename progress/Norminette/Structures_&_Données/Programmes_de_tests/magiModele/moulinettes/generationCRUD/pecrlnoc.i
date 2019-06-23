/*------------------------------------------------------------------------
File        : pecrlnoc.i
Purpose     : Fichier Ecriture O.D. de CLOTURE
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttPecrlnoc
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cpt-cd  as character  initial ? 
    field etab-cd as integer    initial ? 
    field fg-trf  as logical    initial ? 
    field lib     as character  initial ? 
    field mt      as decimal    initial ?  decimals 2
    field mt-EURO as decimal    initial ?  decimals 2
    field prd-cd  as integer    initial ? 
    field sens    as logical    initial ? 
    field soc-cd  as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
