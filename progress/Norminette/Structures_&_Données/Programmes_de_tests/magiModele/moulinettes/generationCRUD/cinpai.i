/*------------------------------------------------------------------------
File        : cinpai.i
Purpose     : fichier des parametres investissement
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCinpai
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field ana1-ass        as character  initial ? 
    field ana1-cap        as character  initial ? 
    field ana1-int        as character  initial ? 
    field ana2-ass        as character  initial ? 
    field ana2-cap        as character  initial ? 
    field ana2-int        as character  initial ? 
    field ana3-ass        as character  initial ? 
    field ana3-cap        as character  initial ? 
    field ana3-int        as character  initial ? 
    field arrondi         as logical    initial ? 
    field barre-num       as integer    initial ? 
    field compta          as logical    initial ? 
    field cpt-ass         as character  initial ? 
    field cpt-cap         as character  initial ? 
    field cpt-int         as character  initial ? 
    field cpt-ori-urg     as character  initial ? 
    field cpt-ori-vote    as character  initial ? 
    field cron            as logical    initial ? 
    field etab-cd         as integer    initial ? 
    field lien-ach        as logical    initial ? 
    field lien-od         as logical    initial ? 
    field num-int         as integer    initial ? 
    field soc-cd          as integer    initial ? 
    field sscoll-ass      as character  initial ? 
    field sscoll-cap      as character  initial ? 
    field sscoll-int      as character  initial ? 
    field sscoll-ori-urg  as character  initial ? 
    field sscoll-ori-vote as character  initial ? 
    field type-invest     as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
