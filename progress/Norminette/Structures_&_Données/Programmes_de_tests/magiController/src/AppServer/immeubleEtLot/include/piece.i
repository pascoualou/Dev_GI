/*------------------------------------------------------------------------
File        : piece.i
Purpose     :
Author(s)   : KANTENA  -  2016/10/28
Notes       :
derniere revue: 2018/05/25 - phm: OK
----------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttPiece
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroBien     as int64     initial ? label 'noloc'
    field iNumeroPiece    as integer   initial ? label 'nopie'
    field cCodeNature     as character initial ? label 'ntpie'
    field cLibelleNature  as character initial ? label ''
    field cNiveau         as character initial ? label 'cdniv'
    field iNumeroBloc     as integer   initial ? label 'noblc'
    field dValeur         as decimal   initial ? label 'sfpie'
    field cCodeUnite      as character initial ? label 'uspie'
    field cLibelleUnite   as character initial ?
    field lPrincipale     as logical   initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
