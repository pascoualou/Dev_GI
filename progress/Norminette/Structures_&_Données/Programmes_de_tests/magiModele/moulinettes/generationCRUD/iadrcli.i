/*------------------------------------------------------------------------
File        : iadrcli.i
Purpose     : Liste des adresses pour les clients.
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIadrcli
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field adr        as character  initial ? 
    field adr-cd     as integer    initial ? 
    field cli-cle    as character  initial ? 
    field contact    as character  initial ? 
    field cp         as character  initial ? 
    field dacrea     as date       initial ? 
    field damod      as date       initial ? 
    field email      as character  initial ? 
    field etab-cd    as integer    initial ? 
    field fax        as character  initial ? 
    field ihcrea     as integer    initial ? 
    field ihmod      as integer    initial ? 
    field libadr-cd  as integer    initial ? 
    field libpays-cd as character  initial ? 
    field librais-cd as integer    initial ? 
    field nom        as character  initial ? 
    field soc-cd     as integer    initial ? 
    field tel        as character  initial ? 
    field telex      as character  initial ? 
    field tpmod      as character  initial ? 
    field usrid      as character  initial ? 
    field usridmod   as character  initial ? 
    field ville      as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
