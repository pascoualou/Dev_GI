/*------------------------------------------------------------------------
File        : ladrs.i
Purpose     : 
Author(s)   : KANTENA  2017/02/06
Notes       :
derniere revue: 2018/05/22 - phm: KO
        todo est-ce bien nécessaire de mettre cdmsy = mtoken:cUser + "|CHPTC" dans contractantContrat.p
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttLadrs
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdadr     as character initial ?   // Code adresse
    field cdte1     as character initial ?   // Code Telephone numero 1
    field cdte2     as character initial ?   // Code telephone numero 2
    field cdte3     as character initial ?   // Code telephone numero 3
    field dtdeb     as date                  // Début validité adresse
    field dtfin     as date                  // Fin validité adresse
    field lbdiv     as character initial ?   // Filler
    field lbdiv2    as character initial ?   // Filler
    field lbdiv3    as character initial ?   // Filler
    field cddev     as character initial ?   // Code devise
    field noadr     as int64     initial ?   // Numero de l'adresse
    field noidt     as int64     initial ?   // Numero de l'identifiant
    field noidt-dec as decimal   initial ?   // Numero d'identifiant
    field nolie     as int64     initial ?   // Numero de lien adresse
    field note1     as character initial ?   // Numero de telephone numero 1
    field note2     as character initial ?   // Numero de telephone numero 2
    field note3     as character initial ?   // Numero de telephone numero 3
    field novoi     as character initial ?   // Numero de voie
    field tpadr     as character initial ?   // Type adresse
    field tpfrt     as character initial ?   // Format adresse
    field tpidt     as character initial ?   // Type identifiant

    field cdmsy     as character initial ?   // todo  mis à jour dans contractantContrat.p 'mtoken:cUser + "|CHPTC"'. pourquoi?

    field CRUD        as character initial ?
    field dtTimestamp as datetime  initial ?
    field rRowid      as rowid
.
