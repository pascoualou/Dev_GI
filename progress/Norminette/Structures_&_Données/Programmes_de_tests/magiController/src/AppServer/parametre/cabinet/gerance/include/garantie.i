/*----------------------------------------------------------------------------------
File        : garantie.i
Purpose     :
Author(s)   : RF  -  09/11/2017
Notes       : Paramétrage des assurances garanties - Table image de la table garan
derniere revue: 2018/05/03 - phm: OK
-----------------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttGarantie
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table ttGarantie no-undo serialize-name '{&serialName}'
    field tpctt        as character  initial ?
    field noctt        as integer    initial ?
    field tpbar        as character  initial ?
    field nobar        as integer    initial ?
    field txcot        as decimal    initial ? decimals 4
    field txhon        as decimal    initial ? decimals 4
    field txres        as decimal    initial ? decimals 4
    field fgtot        as logical    initial ?
    field cdtva        as character  initial ?
    field cdper        as character  initial ?
    field txrec        as decimal    initial ? decimals 2
    field txnor        as decimal    initial ? decimals 2
    field lbdiv        as character  initial ?
    field cddev        as character  initial ?
    field lbdiv2       as character  initial ?
    field lbdiv3       as character  initial ?
    field txcot-dev    as decimal    initial ? decimals 2
    field tpmnt        as character  initial ?
    field mtcot        as decimal    initial ? decimals 2
    field typefac-cle  as character  initial ?
    field cdass        as character  initial ?
    field nbmca        as decimal    initial ? decimals 2
    field nbmfr        as decimal    initial ? decimals 2
    field cpgar        as character  initial ?
    field fgGRL        as logical    initial ?
    field convention   as character  initial ?
    field nocontrat    as character  initial ?
    field nompartres   as character  initial ?
    field tprolcour    as character  initial ?
    field norolcour    as integer    initial ?
    field CdDebCal     as character  initial ?
    field CdTriEdi     as character  initial ?
    field cdperbord    as character  initial ?

    field dtTimestamp  as datetime
    field CRUD         as character
    field rRowid       as rowid
.
