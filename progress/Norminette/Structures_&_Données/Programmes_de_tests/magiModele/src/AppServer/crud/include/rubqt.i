/*------------------------------------------------------------------------
File        : rubqt.i
Purpose     : 
Author(s)   : kantena 2017/25/12
Notes       :
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttRubqt 
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field aslib         as integer
    field asrub         as integer
    field cdfam         as integer
    field cdgen         as character
    field cdlib         as integer
    field cdrub         as integer
    field cdsfa         as integer
    field cdsig         as character
    field nome1         as integer
    field prg00         as character
    field prg01         as character
    field prg02         as character
    field prg03         as character
    field prg04         as character
    field prg05         as character
    field prg06         as character
    field prg07         as character
    field iNumeroReleve as integer       // utilisation extentcqt.p par exemple.

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
    index primaire cdfam cdsfa iNumeroReleve cdrub
.
