/*------------------------------------------------------------------------
File        : cpreln.i
Purpose     : Table des prelevement
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCpreln
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field adr          as character  initial ? 
    field affair-num   as integer    initial ? 
    field appel-num    as character  initial ? 
    field appel-rgrp   as character  initial ? 
    field bic          as character  initial ? 
    field bque         as character  initial ? 
    field cdfic        as character  initial ? 
    field coll-cle     as character  initial ? 
    field cpt          as character  initial ? 
    field cpt-cd       as character  initial ? 
    field dacrea       as date       initial ? 
    field daech        as date       initial ? 
    field daecr        as date       initial ? 
    field damod        as date       initial ? 
    field dev-cd       as character  initial ? 
    field devetr-cd    as character  initial ? 
    field domicil      as character  initial ? 
    field dtder        as date       initial ? 
    field dtechini     as date       initial ? 
    field dtmodrib     as date       initial ? 
    field dtree        as date       initial ? 
    field dtsig        as date       initial ? 
    field dtSolde      as date       initial ? 
    field etab-cd      as integer    initial ? 
    field fg-valid     as logical    initial ? 
    field guichet      as character  initial ? 
    field iban         as character  initial ? 
    field ics          as character  initial ? 
    field ihcrea       as integer    initial ? 
    field ihmod        as integer    initial ? 
    field index-cd     as integer    initial ? 
    field jou-cd       as character  initial ? 
    field lbdiv1       as character  initial ? 
    field lib-ecr1     as character  initial ? 
    field lib-ecr2     as character  initial ? 
    field mandat-cd    as integer    initial ? 
    field mt           as decimal    initial ?  decimals 2
    field mt-EURO      as decimal    initial ?  decimals 2
    field mtdev        as decimal    initial ?  decimals 2
    field mtechini     as decimal    initial ?  decimals 2
    field mtsolde      as decimal    initial ?  decimals 2
    field nbech        as integer    initial ? 
    field noech        as integer    initial ? 
    field nom-fich     as character  initial ? 
    field noprel       as int64      initial ? 
    field norol        as int64      initial ? 
    field norum        as character  initial ? 
    field norum-anc    as character  initial ? 
    field ordre-num    as integer    initial ? 
    field piece-compta as integer    initial ? 
    field ref-num      as character  initial ? 
    field rib-cle      as character  initial ? 
    field sens         as logical    initial ? 
    field SMNDA        as logical    initial ? 
    field soc-cd       as integer    initial ? 
    field sscoll-cle   as character  initial ? 
    field tp-trait     as integer    initial ? 
    field tprol        as character  initial ? 
    field tpseq        as character  initial ? 
    field usridcrea    as character  initial ? 
    field usridmod     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
