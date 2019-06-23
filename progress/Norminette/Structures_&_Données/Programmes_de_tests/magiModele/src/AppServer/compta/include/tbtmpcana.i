/*------------------------------------------------------------------------
File        : TbTmpCana.i
Purpose     : creation d'une table temporaire pour comparer les analytiques avant
              le delete (etat = FALSE ) et apres la creation (etat = TRUE)
Author(s)   : gga  -  2017/05/11
Notes       : creation a partir include cadb\src\batch\ttCompAna.def
------------------------------------------------------------------------*/

define temp-table ttCompAna no-undo
    field soc-cd    like cecrlnana.soc-cd
    field etab-cd   like cecrlnana.etab-cd
    field jou-cd    like cecrlnana.jou-cd
    field prd-cd    like cecrlnana.prd-cd
    field prd-num   like cecrlnana.prd-num
    field piece-int like cecrlnana.piece-int
    field lig       like cecrlnana.lig
    field pos       like cecrlnana.pos
    field mt        like cecrlnana.mt
    field mttva     like cecrlnana.mttva
    field sens      like cecrlnana.sens
    field ana1-cd   like cecrlnana.ana1-cd
    field ana2-cd   like cecrlnana.ana2-cd
    field ana3-cd   like cecrlnana.ana3-cd
    field ana4-cd   like cecrlnana.ana4-cd
    field lib       like cecrlnana.lib
    field lib-ecr   like cecrlnana.lib-ecr
    field regrp     like cecrlnana.regrp
    field etat      as logical
    index ttCompAna-i is unique primary soc-cd etab-cd jou-cd prd-cd prd-num piece-int lig pos etat
.
