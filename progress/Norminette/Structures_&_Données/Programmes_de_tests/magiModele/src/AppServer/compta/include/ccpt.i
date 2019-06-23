/*------------------------------------------------------------------------
File        : ccpt.i
Purpose     : Fichiers comptes Generaux
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCcpt
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field centra      as logical    initial ? 
    field champmod    as character  initial ? 
    field coll-cle    as character  initial ? 
    field cpt-cd      as character  initial ? 
    field cpt-int     as character  initial ? 
    field cpt-tri     as character  initial ? 
    field cpt2-cd     as character  initial ? 
    field cpt2-int    as character  initial ? 
    field cptaffect   as character  initial ? 
    field cptg-cd     as character  initial ? 
    field cptprov-num as character  initial ? 
    field dacrea      as date       initial ? 
    field dadeb       as date       initial ? 
    field dafin       as date       initial ? 
    field damod       as date       initial ? 
    field detail-tres as logical    initial ? 
    field etab-cd     as integer    initial ? 
    field fg-conf     as logical    initial ? 
    field fg-libsoc   as logical    initial ? 
    field fg-mandat   as logical    initial ? 
    field fg-tiers    as logical    initial ? 
    field ihcrea      as integer    initial ? 
    field ihmod       as integer    initial ? 
    field lettre      as character  initial ? 
    field lettre-int  as integer    initial ? 
    field lib         as character  initial ? 
    field lib2        as character  initial ? 
    field libcat-cd   as integer    initial ? 
    field libimp-cd   as integer    initial ? 
    field libsens-cd  as integer    initial ? 
    field libtype-cd  as integer    initial ? 
    field reciproq    as logical    initial ? 
    field sens-oblig  as logical    initial ? 
    field soc-cd      as integer    initial ? 
    field sscpt-cd    as character  initial ? 
    field taxe-cd     as integer    initial ? 
    field tva-compte  as character  initial ? 
    field tva-oblig   as logical    initial ? 
    field type        as logical    initial ? 
    field type-cd     as integer    initial ? 
    field usrid       as character  initial ? 
    field usridmod    as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
