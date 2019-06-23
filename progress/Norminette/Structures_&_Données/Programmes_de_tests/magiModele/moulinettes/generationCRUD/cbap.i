/*------------------------------------------------------------------------
File        : cbap.i
Purpose     : Fichier bon a payer
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCbap
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field adr-cd           as integer    initial ? 
    field affair-num       as integer    initial ? 
    field analytique       as logical    initial ? 
    field bqjou-cd         as character  initial ? 
    field bqprofil-cd      as integer    initial ? 
    field cdenr            as character  initial ? 
    field cDiv1            as character  initial ? 
    field cDiv2            as character  initial ? 
    field cDiv3            as character  initial ? 
    field chrono           as integer    initial ? 
    field cmpbqjou-cd      as character  initial ? 
    field cmpbqmdt         as integer    initial ? 
    field cmpc-mandat-cd   as integer    initial ? 
    field coll-cle         as character  initial ? 
    field cpt-cd           as character  initial ? 
    field dacrea           as date       initial ? 
    field dadebper         as date       initial ? 
    field daech            as date       initial ? 
    field dafinper         as date       initial ? 
    field damod            as date       initial ? 
    field dev-cd           as character  initial ? 
    field etab-cd          as integer    initial ? 
    field fg-ana100        as logical    initial ? 
    field fg-rgrp          as logical    initial ? 
    field fg-statut        as logical    initial ? 
    field FgVal            as logical    initial ? 
    field gest-cle         as character  initial ? 
    field ihcrea           as integer    initial ? 
    field ihmod            as integer    initial ? 
    field lib              as character  initial ? 
    field lib-ecr          as character  initial ? 
    field libtier-cd       as integer    initial ? 
    field lienfac          as character  initial ? 
    field lienpaiement     as character  initial ? 
    field manu-int         as int64      initial ? 
    field mdtcop           as integer    initial ? 
    field mt               as decimal    initial ?  decimals 2
    field mt-EURO          as decimal    initial ?  decimals 2
    field mtdev            as decimal    initial ?  decimals 2
    field mtdev-EURO       as decimal    initial ?  decimals 2
    field mttva-dev        as decimal    initial ?  decimals 2
    field paie             as logical    initial ? 
    field pourcentage      as decimal    initial ?  decimals 2
    field ref-num          as character  initial ? 
    field regl-cd          as integer    initial ? 
    field regl-jou-cd      as character  initial ? 
    field regl-mandat-cd   as integer    initial ? 
    field sens             as logical    initial ? 
    field soc-cd           as integer    initial ? 
    field sscoll-cle       as character  initial ? 
    field taxe-cd          as integer    initial ? 
    field tiers-cpt-cd     as character  initial ? 
    field tiers-sscoll-cle as character  initial ? 
    field tva-enc-deb      as logical    initial ? 
    field type-reg         as integer    initial ? 
    field usrid            as character  initial ? 
    field usridmod         as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
