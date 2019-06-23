/*------------------------------------------------------------------------
File        : ttPerissolBesson.i
Purpose     : table pour l'extraction table partagé Loi Perissol et Besson   
Author(s)   : GGA  -  2017/12/19 
Notes       : 
------------------------------------------------------------------------*/

define temp-table ttPerissolBesson no-undo
    field iNoMdt  as integer
    field iNoImm  as integer
    field iNoLot  as integer
    field cTpAct  as character
    field iNoExo  as integer
    field cCdLoi  as character
    field daAch   as date
    field daVen   as date
    field daFin   as date
    field dMtAch  as decimal
    field cLbCal  as character
    field dMtDec  as decimal
index NoIdx is unique primary iNoMdt iNoImm iNoLot cTpAct iNoExo.
