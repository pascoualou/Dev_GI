/*------------------------------------------------------------------------
File        : Etabl.i
Purpose     : Etablissement (Paie)
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttEtabl
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field activite    as character  initial ? 
    field cdape       as character  initial ? 
    field cdass       as character  initial ? 
    field cdcsy       as character  initial ? 
    field cddev       as character  initial ? 
    field cdeff       as character  initial ? 
    field cdir        as character  initial ? 
    field cdmsy       as character  initial ? 
    field cdtra       as character  initial ? 
    field cdurs       as character  initial ? 
    field cotisant    as character  initial ? 
    field cSIREN      as character  initial ? 
    field DIF-crheuan as decimal    initial ?  decimals 2
    field DIF-dtapp   as date       initial ? 
    field DIF-dtdeb   as date       initial ? 
    field DIF-dtfin   as date       initial ? 
    field DIF-fgini   as logical    initial ? 
    field DIF-nbancum as decimal    initial ?  decimals 2
    field DIF-nbmoi   as decimal    initial ?  decimals 2
    field DIF-pcmajo  as decimal    initial ?  decimals 2
    field DIF-plafheu as decimal    initial ?  decimals 2
    field dossier     as character  initial ? 
    field dtcsy       as date       initial ? 
    field dtmsy       as date       initial ? 
    field fg-subrog   as logical    initial ? 
    field fgaugsmic   as logical    initial ? 
    field fgdas       as logical    initial ? 
    field fgint       as logical    initial ? 
    field fgpoint     as logical    initial ? 
    field fgtax       as logical    initial ? 
    field hecsy       as integer    initial ? 
    field hemsy       as integer    initial ? 
    field ifu         as character  initial ? 
    field lbdiv       as character  initial ? 
    field lbdiv2      as character  initial ? 
    field lbdiv3      as character  initial ? 
    field lbdiv4      as character  initial ? 
    field lbdiv5      as character  initial ? 
    field lbdiv6      as character  initial ? 
    field ListeRub    as character  initial ? 
    field msint       as integer    initial ? 
    field noass       as character  initial ? 
    field noavenant   as integer    initial ? 
    field nocle       as character  initial ? 
    field nocon       as integer    initial ? 
    field nocon-dec   as decimal    initial ?  decimals 0
    field nocre       as character  initial ? 
    field nomut       as integer    initial ? 
    field nonic       as integer    initial ? 
    field nopre       as integer    initial ? 
    field nosie       as character  initial ? 
    field nours       as character  initial ? 
    field siren       as integer    initial ? 
    field tpcon       as character  initial ? 
    field tptac       as character  initial ? 
    field txtax       as decimal    initial ?  decimals 2
    field txtra       as decimal    initial ?  decimals 2
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
