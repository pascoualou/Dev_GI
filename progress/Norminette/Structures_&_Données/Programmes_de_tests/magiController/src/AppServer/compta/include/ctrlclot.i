/*------------------------------------------------------------------------
File        : ctrlclot.i
Description :
Author(s)   : LGI/  -  2017/01/13
Notes       :
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/
define temp-table ttTmpCop no-undo
    field nomdt   as integer
    field nocop   as integer
    field mtappcx as decimal
    field mtappan as decimal
    field mtsolde as decimal
    field mtodt   as decimal
    field mtfinal as decimal
.
define temp-table ttApatTmp no-undo
    field cpt-cd     as character
    field NumAppel   as character
    field mt         as decimal
    field annulation as decimal
    field nocop      as integer
.
define temp-table ttApipTmp no-undo
    field cpt-cd as character
    field nolot  as integer
    field cle    as character
    field mt     as decimal
    field cumul  as decimal
    field lib    as character
    field nocop  as integer
.
