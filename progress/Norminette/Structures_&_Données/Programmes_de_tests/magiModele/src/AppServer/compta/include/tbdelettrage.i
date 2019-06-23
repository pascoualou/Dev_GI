/*------------------------------------------------------------------------
File        : delettrage.i
Purpose     :
Author(s)   : OF - 2011/09/13,  gg  -  2017/04/07
Notes       : reprise include comm\cptaprov.def. Utilisé dans les programmes:
              CADB\SRC\EDIGENE\XRLVPROP.P et XVENTENC.P
              CADB\SRC\BATCH\CPTAPROV.P
              ADB\SRC\TRAV\VISDOAPP.P
----------------------------------------------------------------------*/

define temp-table ttDelettrage no-undo
    field etab-cd    as integer   format ">9"
    field sscoll-cle as character format "x(5)"
    field cpt-cd     as character format "x(15)"
    field lettre     as character format "x(5)"
    field lig        as integer   format ">>>>>9"
    field Flag       as character
.
