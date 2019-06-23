/*------------------------------------------------------------------------
File        : etabl.i
Purpose     : 
Author(s)   : GGA - 2017/11/13
Notes       :
------------------------------------------------------------------------*/

&if defined(nomTable)   = 0 &then &scoped-define nomTable ttEtabl
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif

define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field dtcsy       as date      initial ?
    field hecsy       as integer   initial ?
    field cdcsy       as character initial ?
    field dtmsy       as date      initial ?
    field hemsy       as integer   initial ?
    field cdmsy       as character initial ?
    field tpcon       as character initial ?
    field nocon       as integer   initial ?
    field tptac       as character initial ?
    field siren       as integer   initial ?
    field nonic       as integer   initial ?
    field cdape       as character initial ?
    field fgtax       as logical   initial ?
    field txtax       as decimal   initial ? decimals 2
    field cdurs       as character initial ?
    field nours       as character initial ?
    field cdeff       as character initial ?
    field txtra       as decimal   initial ? decimals 2
    field cdtra       as character initial ?
    field cdass       as character initial ?
    field noass       as character initial ?
    field nocre       as character initial ?
    field fgint       as logical   initial ?
    field msint       as integer   initial ?
    field lbdiv       as character initial ?
    field fgdas       as logical   initial ?
    field cddev       as character initial ?
    field lbdiv2      as character initial ?
    field lbdiv3      as character initial ?
    field nocon-dec   as decimal   initial ? decimals 0
    field nosie       as character initial ?
    field dossier     as character initial ?
    field nocle       as character initial ?
    field cdir        as character initial ?
    field activite    as character initial ?
    field ifu         as character initial ?
    field fgpoint     as logical   initial ?
    field nomut       as integer   initial ?
    field nopre       as integer   initial ?
    field fgaugsmic   as logical   initial ?
    field ListeRub    as character initial ?
    field noavenant   as integer   initial ?
    field fg-subrog   as logical   initial ?
    field DIF-dtapp   as date      initial ?
    field DIF-dtdeb   as date      initial ?
    field DIF-dtfin   as date      initial ?
    field DIF-crheuan as decimal   initial ? decimals 2
    field DIF-nbancum as decimal   initial ? decimals 2
    field DIF-plafheu as decimal   initial ? decimals 2
    field DIF-nbmoi   as decimal   initial ? decimals 2
    field DIF-pcmajo  as decimal   initial ? decimals 2
    field DIF-fgini   as logical   initial ?
    field cotisant    as character initial ?
    field lbdiv4      as character initial ?
    field lbdiv5      as character initial ?
    field lbdiv6      as character initial ?
    field cSIREN      as character initial ?
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
