/*------------------------------------------------------------------------
File        : honoraireCalculeUL.i
Purpose     :
Author(s)   : DM  -  2017/10/11
Notes       :
derneire revue: 2018/05/16 - phm: OK
------------------------------------------------------------------------*/
define temp-table ttHonoraireCalculeUL no-undo
    field cMois                  as character  initial ? label "lbmoi"
    field daDebut                as date                 label "dtdeb"
    field daFin                  as date                 label "dtfin"
    field iCodeHonoraire         as integer    initial ? label "cdhon"
    field dMontantBareme         as decimal    initial ? label "mtbar"
    field cLibelleNature         as character  initial ? label "lbnat"
    field iNumeroUL              as integer    initial ? label "noapp"
    field cLibelleNatureLocation as character  initial ? label "lbcat"
    field cProrata               as character  initial ? label "lbpro"
    field dMontantHonoraire      as decimal    initial ? label "mthon"
    field cLibelleHonoraire      as character  initial ? label "lbdiv"
    field cJourOccupe            as character  initial ? label "lbjouocc"
    field cJourVacant            as character  initial ? label "lbjouvac"
    field cJourNongere           as character  initial ? label "lbjouindis" 
.