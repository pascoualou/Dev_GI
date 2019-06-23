/*------------------------------------------------------------------------
File        : iribcli.i
Purpose     : Liste des RIB pour les clients.
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIribcli
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field adr       as character  initial ? 
    field bic       as character  initial ? 
    field bque      as character  initial ? 
    field bque-nom  as character  initial ? 
    field cli-cle   as character  initial ? 
    field cpt       as character  initial ? 
    field cptetr    as character  initial ? 
    field dacrea    as date       initial ? 
    field damod     as date       initial ? 
    field domicil   as character  initial ? 
    field dtder     as date       initial ? 
    field dtree     as date       initial ? 
    field dtsig     as date       initial ? 
    field edition   as logical    initial ? 
    field etab-cd   as integer    initial ? 
    field etr       as logical    initial ? 
    field guichet   as character  initial ? 
    field iban      as character  initial ? 
    field ics       as character  initial ? 
    field ihcrea    as integer    initial ? 
    field ihmod     as integer    initial ? 
    field norum     as character  initial ? 
    field norum-anc as character  initial ? 
    field ordre-num as integer    initial ? 
    field rib       as character  initial ? 
    field SMNDA     as logical    initial ? 
    field soc-cd    as integer    initial ? 
    field usrid     as character  initial ? 
    field usridmod  as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
