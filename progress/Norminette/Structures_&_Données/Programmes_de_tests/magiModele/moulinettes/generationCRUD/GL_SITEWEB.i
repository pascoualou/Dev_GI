/*------------------------------------------------------------------------
File        : GL_SITEWEB.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttGl_siteweb
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy            as character  initial ? 
    field cdmsy            as character  initial ? 
    field cheminLogo       as character  initial ? 
    field colphoto         as character  initial ? 
    field correspondance   as character  initial ? 
    field csvdelimiter     as character  initial ? 
    field csvnom           as character  initial ? 
    field dtcsy            as date       initial ? 
    field dtmsy            as date       initial ? 
    field fgpublier        as logical    initial ? 
    field fgsend_unique    as logical    initial ? 
    field filtre_champ     as character  initial ? 
    field ftpcurdir        as character  initial ? 
    field hecsy            as integer    initial ? 
    field hemsy            as integer    initial ? 
    field identifiant      as character  initial ? 
    field identifiantfiche as character  initial ? 
    field nom              as character  initial ? 
    field nomes_upd        as integer    initial ? 
    field nositeweb        as integer    initial ? 
    field tabcomplement    as character  initial ? 
    field tabftp           as character  initial ? 
    field urlscript        as character  initial ? 
    field zipnom           as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
