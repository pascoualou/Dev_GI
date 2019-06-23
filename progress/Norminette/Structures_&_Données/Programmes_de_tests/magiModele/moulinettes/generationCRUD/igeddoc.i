/*------------------------------------------------------------------------
File        : igeddoc.i
Purpose     : ged : documents
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIgeddoc
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field bloque-user  as character  initial ? 
    field canneemois   as character  initial ? 
    field ccaracfic    as character  initial ? 
    field cddom        as character  initial ? 
    field cdestinat    as character  initial ? 
    field cdivers1     as character  initial ? 
    field cdivers2     as character  initial ? 
    field cdivers3     as character  initial ? 
    field cdivers4     as character  initial ? 
    field cdivers5     as character  initial ? 
    field cdmsy        as character  initial ? 
    field cdnat        as character  initial ? 
    field cdoctype     as character  initial ? 
    field cdsto        as character  initial ? 
    field chfichier    as character  initial ? 
    field clibcpt      as character  initial ? 
    field clibtrt      as character  initial ? 
    field cnumcpt      as character  initial ? 
    field cnumsscpt    as character  initial ? 
    field comment      as character  initial ? 
    field ctypdos      as character  initial ? 
    field ctypetrait   as character  initial ? 
    field dacre        as date       initial ? 
    field dadoc        as date       initial ? 
    field dtmsy        as date       initial ? 
    field hemsy        as integer    initial ? 
    field id-fich      as int64      initial ? 
    field id-fichori   as int64      initial ? 
    field ident_u      as character  initial ? 
    field lbrech       as character  initial ? 
    field liaison-cd   as int64      initial ? 
    field libdesc      as character  initial ? 
    field libobj       as character  initial ? 
    field nbpag        as integer    initial ? 
    field nmfichier    as character  initial ? 
    field noctrat      as character  initial ? 
    field noctt        as int64      initial ? 
    field nodoss       as integer    initial ? 
    field noidt        as int64      initial ? 
    field noimm        as integer    initial ? 
    field nolot        as integer    initial ? 
    field nomdt        as integer    initial ? 
    field nomrol       as character  initial ? 
    field nomrol-ctt   as character  initial ? 
    field noord        as integer    initial ? 
    field norol        as int64      initial ? 
    field norol-ctt    as int64      initial ? 
    field notie        as int64      initial ? 
    field notie-ctt    as int64      initial ? 
    field num-soc      as integer    initial ? 
    field origine      as character  initial ? 
    field resid        as character  initial ? 
    field statut-cd    as character  initial ? 
    field theme-cd     as character  initial ? 
    field tpctt        as character  initial ? 
    field tpidt        as character  initial ? 
    field tprol        as integer    initial ? 
    field tprol-ctt    as integer    initial ? 
    field typ-ratt     as character  initial ? 
    field typdoc-cd    as integer    initial ? 
    field web-cdivers1 as character  initial ? 
    field web-cdivers2 as character  initial ? 
    field web-dadeb    as date       initial ? 
    field web-dafin    as date       initial ? 
    field web-fgmadisp as logical    initial ? 
    field web-idivers1 as integer    initial ? 
    field web-idivers2 as integer    initial ? 
    field web-libobjet as character  initial ? 
    field web-nomfic   as character  initial ? 
    field web-theme-cd as character  initial ? 
    field web-transf   as integer    initial ? 
    field web-typfonc  as character  initial ? 
    field web-typratt  as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
