/*------------------------------------------------------------------------
File        : attributsDivers.i
Purpose     :
Author(s)   : LGI/NPO - 2016/12/07
Notes       : paramètre des attributs divers: GLATB dans sys_lb
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAttributsDivers
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroFiche     as integer   initial ? label 'nofiche'
    field iCodeAttribut    as integer   initial ? label 'noattrcom'
    field cLibelleAttribut as character initial ?
.
