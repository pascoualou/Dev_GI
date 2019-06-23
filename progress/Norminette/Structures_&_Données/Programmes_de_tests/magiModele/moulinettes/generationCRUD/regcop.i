/*------------------------------------------------------------------------
File        : regcop.i
Purpose     : Registre des copropriétés
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttRegcop
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cCodeErreur          as character  initial ? 
    field cCodeRetourHTTP      as character  initial ? 
    field cdcsy                as character  initial ? 
    field cdmsy                as character  initial ? 
    field cEmailTeledeclarant  as character  initial ? 
    field cFichierEnvoye       as character  initial ? 
    field cFichierJustificatif as character  initial ? 
    field cFichierRetour       as character  initial ? 
    field cImmatCopro          as character  initial ? 
    field cMessageErreur       as character  initial ? 
    field cNumeroTeledeclarant as character  initial ? 
    field cTypeDeclaration     as character  initial ? 
    field cTypeJustificatif    as character  initial ? 
    field dDateFinExercice     as date       initial ? 
    field dtcsy                as date       initial ? 
    field dtmsy                as date       initial ? 
    field hecsy                as integer    initial ? 
    field hemsy                as integer    initial ? 
    field iAnneeDeclaration    as integer    initial ? 
    field iOrdre               as integer    initial ? 
    field lbdiv                as character  initial ? 
    field lbdiv2               as character  initial ? 
    field lbdiv3               as character  initial ? 
    field lbdiv4               as character  initial ? 
    field lbdiv5               as character  initial ? 
    field lbdiv6               as character  initial ? 
    field nocon                as int64      initial ? 
    field noimm                as integer    initial ? 
    field tpcon                as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
