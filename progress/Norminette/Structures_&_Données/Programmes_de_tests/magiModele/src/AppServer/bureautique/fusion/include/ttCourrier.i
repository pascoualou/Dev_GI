/*-----------------------------------------------------------------------------
File        : ttCourrier.i
Description : 
Author(s)   : KANTENA - 2018/02/26
Notes       :
-----------------------------------------------------------------------------*/
define temp-table ttModeleDocument no-undo serialize-name "tbTmpDot"
    field tptrt as character
    field notrt as integer
    field tpdoc as integer
    field nores as integer
    field tpcon as character
    field nocon as integer   /* DM 0712/0239 */
    field nodos as integer   /* DM 0712/0239 */
    field fgdos as logical
    field nodot as integer
    field tpfou as character /* Ajout SY le 17/10/2013 */
    field nofou as int64     /* Ajout SY le 17/10/2013 */
index primaire is unique tptrt notrt tpdoc
.
define temp-table ttDocument no-undo serialize-name "tbTmpDoc"
    field nodoc as integer
    field nodot as integer
    field tprol as character
    field norol as int64
    field lbdoc as character
    field tpmod as character
    field tpcon as character    /* DM 0712/0239 */
    field nocon as integer      /* DM 0712/0239 */
    field nodos as integer      /* DM 0712/0239 */
    field fgnew as logical      /* DM 0712/0239 */
    field nofou as integer      /* NP 0416/0200 */
    field nmfou as character    /* NP 0416/0200 */
    field noimm as integer      /* NP 0416/0200 */
    field nmimm as character    /* NP 0416/0200 */
    field notrt as integer      /* NP 0416/0200 */
index primaire   is unique NoDoc
index secondaire TpMod NoDoc
.