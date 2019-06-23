/*------------------------------------------------------------------------
File        : adres.i
Purpose     : 
Author(s)   : KANTENA  2017/02/06
Notes       :
derniere revue: 2018/05/22 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAdres
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cddev              as character initial ?   // Code devise
    field cdins              as character initial ?   // Code INSEE commune
    field cdpay              as character initial ?   // Code pays
    field cdpos              as character initial ?   // Code postal
    field cpad2              as character initial ?   // Complément adresse 2 = Identification
    field cpad3              as character initial ?   // Complément adresse 3 = non encore dvlppé
    field CplLocConstruction as character initial ?   //
    field CplLocVoie         as character initial ?   //
    field cpvoi              as character initial ?   // Complement adresse
    field lbbur              as character initial ?   // Bureau distributeur
    field lbdiv              as character initial ?   // Filler
    field lbdiv2             as character initial ?   // Filler
    field lbdiv3             as character initial ?   // Filler
    field lbvil              as character initial ?   // Ville
    field lbvoi              as character initial ?   // Libelle de la voie
    field noadr              as int64     initial ?   // Numero adresse
    field ntvoi              as character initial ?   // Nature de la voie
    field cdcsy              as character initial ?   // Code utilisateur de generation du record
    field dtcsy              as date                  // Date de generation du record
    field hecsy              as integer   initial ?   // Heure de generation du record
    field cdmsy              as character initial ?   // Code utilisateur de modification du record
    field dtmsy              as date                  // Date de modification du record
    field hemsy              as integer   initial ?   // Heure de modification du record

    field CRUD        as character
    field dtTimestamp as datetime
    field rRowid      as rowid
.
