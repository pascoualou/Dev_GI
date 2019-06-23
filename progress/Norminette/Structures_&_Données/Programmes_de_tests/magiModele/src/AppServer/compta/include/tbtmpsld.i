/*------------------------------------------------------------------------
File        : tbtmpsld.i
Purpose     :
Author(s)   : gga  -  2017/03/07
Notes       :
------------------------------------------------------------------------*/

define temp-table ttTmpSld no-undo
    field nomdt   as integer
    field nocop   as integer
    field mtappcx as decimal
    field mtappan as decimal
    field mtsolde as decimal
    field mtodt   as decimal
    index primaire nomdt nocop
.
