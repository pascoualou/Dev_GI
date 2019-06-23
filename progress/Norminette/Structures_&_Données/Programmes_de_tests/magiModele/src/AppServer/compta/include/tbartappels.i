/*------------------------------------------------------------------------
File        : artappels.i
Purpose     :
Author(s)   : gga  -  2017/03/07
Notes       :
------------------------------------------------------------------------*/

/*gga todo pour le moment reprise de cette table temporaire car creation
dans les programmes apatcx.p et apipcx.p mais je ne vois pas ou ensuite
cette table est utilise (et meme dans l'appli, defini en shared
dans ctrltrav.p, apatcx.p et apipcx.p mais je ne vois pas ou
defini en new shared dans les dossiers travaux */

define temp-table ttArtappels no-undo
    field cdart as character format "x(4)"
    field noref as character format "x(5)"
    field art   as character format "x(137)"
.
