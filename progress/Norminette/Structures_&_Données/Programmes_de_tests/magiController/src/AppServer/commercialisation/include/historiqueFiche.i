/*------------------------------------------------------------------------
File        : historiqueFiche.i
Purpose     : 
Author(s)   : LGI/NPO - 2017/02/16
Notes       :
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttHistoriqueFiche
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroHisto as integer   initial ? label 'nohisto'
    field iNumeroFiche as integer   initial ? label 'nofiche'
    field CRUD         as character
    field dtTimestamp  as datetime
    field rRowid       as rowid
index idx_NumeroHisto is unique primary iNumeroHisto
.
