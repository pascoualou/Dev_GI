/*------------------------------------------------------------------------
File        : iconvfrf.i
Purpose     : Conversion DEV -> FRF
Author(s)   : gg  -  2017/05/12
Notes       : reprise include gest\comm\iconvfrf.i
    isoc et ietab doivent etre available
    {1} = Date de saisie du document (date du cours)
    {2} = Devise du document
    {3} = Champs montant en devise
    {4} = Cours du document
----------------------------------------------------------------------*/

if ietab.dev-cd = {2}                                            /* Pas de conversion si devise = devise etab */
then {3}
else if {1} >= isoc.dat-euro
     then if isoc.tx-euro = 1
          then {3} / {4}
          else round({3} / {4},3) * isoc.tx-euro
     else {3} * {4}
