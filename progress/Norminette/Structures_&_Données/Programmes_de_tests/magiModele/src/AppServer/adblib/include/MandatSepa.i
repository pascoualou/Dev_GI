/*------------------------------------------------------------------------
File        : mandatsepa.i
Purpose     : Mandats de pr�l�vement SEPA
Author(s)   : generation automatique le 04/27/18
Notes       : Fiche 0511/0023
derniere revue: 2018/05/14 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttMandatsepa
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field bicod         as character  initial ?
    field cdchgbqu      as character  initial ?
    field cdcsy         as character  initial ?
    field cddur         as character  initial ?
    field cdext         as character  initial ?
    field cdmsy         as character  initial ?
    field cdori         as character  initial ?
    field cdstatut      as character  initial ?
    field coderum       as character  initial ?
    field domicil       as character  initial ?
    field dtcsy         as date
    field dtdeb         as date
    field dtechnotif    as date
    field dtfin         as date
    field dtmsy         as date
    field dtnotif       as date
    field dtresil       as date
    field dtsig         as date
    field dtutilisation as date
    field dtvalide      as date
    field fgvalide      as logical    initial ?
    field hecsy         as integer    initial ?
    field hemsy         as integer    initial ?
    field iban          as character  initial ?
    field lbdiv         as character  initial ?
    field lbdiv2        as character  initial ?
    field lbdiv3        as character  initial ?
    field lbdiv4        as character  initial ?
    field lbnom         as character  initial ?
    field lisig         as character  initial ?
    field lnom2         as character  initial ?
    field motifresil    as character  initial ?
    field mtnotif       as decimal    initial ? decimals 2
    field nbdur         as integer    initial ?
    field noave         as integer    initial ?
    field noblc         as integer    initial ?
    field nocon         as int64      initial ?
    field nomandat      as int64      initial ?
    field nomcontact    as character  initial ?
    field nomdt         as integer    initial ?
    field nomprelsepa   as int64      initial ?
    field nomreclam     as character  initial ?
    field noord         as integer    initial ?
    field norol         as int64      initial ?
    field ntcon         as character  initial ?
    field tpcon         as character  initial ?
    field tpfin         as character  initial ?
    field tpmandat      as character  initial ?
    field tprol         as character  initial ?
    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
