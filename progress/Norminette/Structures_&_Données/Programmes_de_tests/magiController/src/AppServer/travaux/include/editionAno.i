/*------------------------------------------------------------------------
File        : editionAno.i
Purpose     : 
Author(s)   : gga  -  2017/05/17
Notes       :
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/
define temp-table ttEdtAno no-undo
    field cClass as character format "X(250)"
    field cRefer as character format "X(250)"
    field cLigne as character format "X(500)"
    index TbEdt-i cClass
.
define temp-table ttTmpErr no-undo
    field nomdt as integer 
    field nodos as integer
    field noapp as integer
    field noerr as integer
    field lberr as character extent 20
. 
