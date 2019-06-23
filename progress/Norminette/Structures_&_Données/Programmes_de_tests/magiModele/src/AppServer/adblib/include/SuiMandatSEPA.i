/*------------------------------------------------------------------------
File        : suimandatsepa.i
Purpose     : Suivi des prélèvements et modifications des mandats de prélèvement SEPA
Author(s)   : generation automatique le 04/27/18
Notes       :
    
derniere revue: 2018/05/14 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttSuimandatsepa
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field bicod         as character  initial ?
    field bicod-bqu     as character  initial ?
    field cdchgbqu      as character  initial ?
    field cdcsy         as character  initial ?
    field cdmsy         as character  initial ?
    field cdstatut      as character  initial ?
    field coderum       as character  initial ?
    field dacompta      as date
    field daechprl      as date
    field domicil       as character  initial ?
    field dtcsy         as date
    field dtmsy         as date
    field dtresil       as date
    field dtsig         as date
    field hecsy         as integer    initial ?
    field hemsy         as integer    initial ?
    field iban          as character  initial ?
    field iban-bqu      as character  initial ?
    field ics-bqu       as character  initial ?
    field jou-cd-bqu    as character  initial ?
    field lbdiv         as character  initial ?
    field lbdiv2        as character  initial ?
    field lbdiv3        as character  initial ?
    field lbdiv4        as character  initial ?
    field lib-compta    as character  initial ?
    field lstchmodif    as character  initial ?
    field mandat-cd-bqu as integer    initial ?
    field mtprl         as decimal    initial ? decimals 2
    field nolig         as integer    initial ?
    field nom-bqu       as character  initial ?
    field nomprelsepa   as int64      initial ?
    field piece-compta  as integer    initial ?
    field typelig       as character  initial ?
    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
