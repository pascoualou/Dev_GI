/*------------------------------------------------------------------------
File        : iLienAdresse.i
Purpose     : Lien adresse - rôle tiers ou fournisseur
Author(s)   : generation automatique le 22/10/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIlienadresse
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field ccomplementdestinataire as character initial ?
    field ccomplementgeographique as character initial ?
    field ctypeadresse            as character initial ?
    field ctypeformat             as character initial ?
    field ctypeidentifiant        as character initial ?
    field ilienadressefournisseur as integer   initial ?
    field inumeroadresse          as int64     initial ?
    field inumeroidentifiant      as int64     initial ?
    field lbmsy       as character initial ?
    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
