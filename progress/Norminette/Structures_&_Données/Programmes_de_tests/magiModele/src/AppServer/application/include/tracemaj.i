/*------------------------------------------------------------------------
File        : tracemaj.i
Purpose     : include permettant de garder la trace des analytiques
Author(s)   : LGI - PS  - 2004/07/15
Notes       :
------------------------------------------------------------------------*/

if (maj.nmtab = 'cecrlnana' or maj.nmtab = 'suplnana')
and can-find(first aparm no-lock
    where aparm.soc-cd = {1}
      and aparm.etab-cd = 0
      and aparm.tppar = "TTANA"
      and aparm.cdpar = "DEBUG")
then maj.soc-cd = (1000000000 + month(today) * 10000000 +  day(today) * 100000 + time) * -1.
else delete maj.
