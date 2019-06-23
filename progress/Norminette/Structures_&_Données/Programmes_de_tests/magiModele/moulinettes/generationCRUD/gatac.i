/*------------------------------------------------------------------------
File        : gatac.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttGatac
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy  as character  initial ? 
    field cddur  as character  initial ? 
    field cdfrq  as character  initial ? 
    field cdmaj  as character  initial ? 
    field cdmod  as character  initial ? 
    field cdmsy  as character  initial ? 
    field cdper  as character  initial ? 
    field cdse2  as character  initial ? 
    field cdse3  as character  initial ? 
    field cdse4  as character  initial ? 
    field codgi  as character  initial ? 
    field crite  as character  initial ? 
    field delta  as integer    initial ? 
    field deltm  as character  initial ? 
    field dtcsy  as date       initial ? 
    field dtmsy  as date       initial ? 
    field DtRDb  as date       initial ? 
    field DtRFi  as date       initial ? 
    field FgDay  as logical    initial ? 
    field hduree as integer    initial ? 
    field hecsy  as integer    initial ? 
    field hemsy  as integer    initial ? 
    field HeRDb  as integer    initial ? 
    field HeRFi  as integer    initial ? 
    field hrale  as character  initial ? 
    field lbdiv  as character  initial ? 
    field lbdiv2 as character  initial ? 
    field lbdiv3 as character  initial ? 
    field LbEmp  as character  initial ? 
    field lbpth  as character  initial ? 
    field lbtac  as character  initial ? 
    field mduree as integer    initial ? 
    field nmprg  as character  initial ? 
    field nojou  as integer    initial ? 
    field notac  as integer    initial ? 
    field ntctt  as character  initial ? 
    field smjou  as integer    initial ? 
    field smnum  as character  initial ? 
    field tpctt  as character  initial ? 
    field type   as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
