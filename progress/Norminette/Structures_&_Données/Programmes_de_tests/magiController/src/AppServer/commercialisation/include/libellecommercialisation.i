/*------------------------------------------------------------------------
File        : libellecommercialisation.i
Purpose     : table libelle specifique commercialisation
Author(s)   : GGA - 2017/04/19
Notes       :
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttlibelle
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNoLibelle    as integer   initial ? label 'nolibelle'
    field iTypeLibelle  as integer   initial ? label 'tpidt'
    field iNoMes        as integer   initial ? label 'nomes'
    field cLibelleLibre as character initial ? label 'libellelibre'
    field cLibelleStd   as character initial ? label 'libellestandard'   /*correspond libelle sys-lb si nomes <> 0*/
    field iNoOrdre      as integer   initial ? label 'noordre'
    field iNoIdt        as integer   initial ? label 'noidt'

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
