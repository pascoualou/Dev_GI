/*------------------------------------------------------------------------
File        : sequence.i
Purpose     : 
Author(s)   : LGI/NPO - 2017/02/15
Notes       :
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttSequence
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroSequence as integer   initial ? label 'nosequence'
    field iNumeroFiche    as integer   initial ? label 'nofiche'
    field iNumeroRang     as integer   initial ? label 'norang'
    field iNumeroHisto    as integer   initial ?
    field daDateDispo     as date                label 'dtdispo'
    field daDateSortie    as date                label 'dtsortie'
    field daDateEntree    as date                label 'dtentree'
    field daDateConge     as date                label 'dtconge'

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
index ix_NumeroSequence is unique primary iNumeroSequence
.
