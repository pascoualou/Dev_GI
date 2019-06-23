/*------------------------------------------------------------------------
File        : baremeGarantieLoyer.i
Purpose     : Table générique des barèmes de toutes les garanties loyer (Garantie loyer, PNO, vacance locative...)
Author(s)   : Spo 04/18/2018 d'après RF  -  09/11/2017
Notes       : 
derniere revue: 2018/05/03 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttbaremeGarantieLoyer
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cTypeContrat    as character            initial ? label "tpctt"
    field iNumeroContrat  as integer              initial ? label "noctt"
    field cTypeBareme     as character            initial ? label "tpbar"
    field INumeroBareme   as integer              initial ? label "nobar"
    field dMtCotisation   as decimal              initial ? label "mtcot"
    field dTauxCotisation as decimal   decimals 4 initial ? label "txcot"   // Pour la PNO : inutilisé
    field dTauxHonoraire  as decimal   decimals 4 initial ? label "txhon"   // Pour la PNO : montant OU taux
    field dTauxResultat   as decimal   decimals 4 initial ? label "txres"   // Pour la PNO : montant et non taux
    field dtTimestamp     as datetime
    field CRUD            as character
    field rRowid          as rowid
.
