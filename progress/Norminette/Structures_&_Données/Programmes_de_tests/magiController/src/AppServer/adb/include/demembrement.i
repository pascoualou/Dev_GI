/*-----------------------------------------------------------------------------
File        : demembrement.i
Purpose     : reconstitution rattachement lots selon demembrements roles usufruitier/co-usufruitier/nuprop/co-nuprop
Author(s)   : DMI 20181023 à partir de adb/src/bien/ratlot00.p
Notes       : 
------------------------------------------------------------------------------*/

&if defined(nomTable)   = 0 &then &scoped-define nomTable ttUsufruitier
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif

define temp-table {&nomTable}  no-undo serialize-name '{&serialName}'
field iNumeroImmeuble     as integer   initial ? // "NoImm"
field iNumeroLot          as integer   initial ? // "Nolot"
field iNumeroDemembrement as integer   initial ? // "Nodem"
field cCodeTypeRole       as character initial ? // "TpUsu"
field iNumeroRole         as int64     initial ? // "NoUsu"
field daDebut             as date      initial ? // "dtdeb"
field daFin               as date      initial ? // "dtfin"
field iNumerateur         as integer   initial ? // "NbNum"
field iDenominateur       as integer   initial ? // "NbDen"
field cCodeTypeContrat    as character initial ? // "TpCtu"
field iNumeroContrat      as int64     initial ? // "NoCtu" 
. // PAS DE CRUD