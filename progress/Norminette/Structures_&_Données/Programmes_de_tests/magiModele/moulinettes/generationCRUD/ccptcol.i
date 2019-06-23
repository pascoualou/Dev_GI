/*------------------------------------------------------------------------
File        : ccptcol.i
Purpose     : Fichier Comptes collectifs
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCcptcol
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field auxcoll     as logical    initial ? 
    field centra      as logical    initial ? 
    field codifaux    as logical    initial ? 
    field coll-cle    as character  initial ? 
    field coll-cpt    as character  initial ? 
    field coll2-cle   as character  initial ? 
    field coll2-cpt   as character  initial ? 
    field cptaffect   as character  initial ? 
    field cptprov-num as character  initial ? 
    field etab-cd     as integer    initial ? 
    field fg-libsoc   as logical    initial ? 
    field fg-libvir   as logical    initial ? 
    field fg-mandat   as logical    initial ? 
    field lib         as character  initial ? 
    field lib2        as character  initial ? 
    field libcat-cd   as integer    initial ? 
    field libimp-cd   as integer    initial ? 
    field libsens-cd  as integer    initial ? 
    field libtier-cd  as integer    initial ? 
    field libtype-cd  as integer    initial ? 
    field noseq       as character  initial ? 
    field reciproq    as logical    initial ? 
    field soc-cd      as integer    initial ? 
    field sscoll-all  as logical    initial ? 
    field tprole      as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
