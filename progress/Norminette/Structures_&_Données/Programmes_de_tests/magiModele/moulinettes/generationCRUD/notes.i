/*------------------------------------------------------------------------
File        : notes.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttNotes
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroBlocNote    as integer   initial ? label 'noblc'
    field iNumeroRubrique    as integer   initial ? label 'norub'
    field cLibelleRubrique   as character initial ? label 'lbrub'
    field cDetailNote        as character initial ? label 'lbnot'
    field iNumeroIdentifiant as integer   initial ?                // champ technique qui permet un lien immeuble ou lot
    field cdcsy              as character initial ?
    field cddev              as character initial ?
    field cdmsy              as character initial ?
    field dtcsy              as date
    field dtmsy              as date
    field fgacc              as character initial ?
    field hecsy              as integer   initial ?
    field hemsy              as integer   initial ?
    field lbdiv              as character initial ?
    field lbdiv2             as character initial ?
    field lbdiv3             as character initial ?
    field dtTimestamp        as datetime
    field CRUD               as character
    field rRowid             as rowid
.
