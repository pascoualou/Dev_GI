/*------------------------------------------------------------------------
File        : isuisepafour.i
Purpose     : Suivi des prélèvements et modifications des mandats de prélèvement SEPA
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIsuisepafour
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field bicod        as character  initial ? 
    field bicod-bqu    as character  initial ? 
    field cdChgBqu     as character  initial ? 
    field cdcsy        as character  initial ? 
    field cdmsy        as character  initial ? 
    field cdstatut     as character  initial ? 
    field codeRUM      as character  initial ? 
    field dacompta     as date       initial ? 
    field daechprl     as date       initial ? 
    field Domicil      as character  initial ? 
    field dtcsy        as date       initial ? 
    field dtmsy        as date       initial ? 
    field dtresil      as date       initial ? 
    field dtsig        as date       initial ? 
    field etab-cd      as integer    initial ? 
    field four-cle     as character  initial ? 
    field hecsy        as integer    initial ? 
    field hemsy        as integer    initial ? 
    field iban         as character  initial ? 
    field iban-bqu     as character  initial ? 
    field ICS-bqu      as character  initial ? 
    field jou-cd-bqu   as character  initial ? 
    field lbdiv        as character  initial ? 
    field lbdiv2       as character  initial ? 
    field lbdiv3       as character  initial ? 
    field lbdiv4       as character  initial ? 
    field lib-compta   as character  initial ? 
    field LstChModif   as character  initial ? 
    field mtprl        as decimal    initial ?  decimals 2
    field nolig        as integer    initial ? 
    field nom-bqu      as character  initial ? 
    field noMPrelSEPA  as int64      initial ? 
    field piece-compta as integer    initial ? 
    field soc-cd       as integer    initial ? 
    field TypeLig      as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
