/*------------------------------------------------------------------------
File        : archicle.i
Purpose     : fonction pour l'archivages des cles
Author(s)   : GGA  -  2017/12/19
Notes       : reprise de adb/comm/archicle
derniere revue: 2018/04/25 - phm: OK
------------------------------------------------------------------------*/

function isCleArchivee returns logical private(piNumeroImmeuble as integer, piNumeroMandat as integer, pcCodeCle as character):
    /*------------------------------------------------------------------------------
    Purpose: Fonction pour savoir si une cle est archivée ou non
         TRUE  : si la clé est archivée
         FALSE : si la clé n'est pas archivée ou Archivage non géré
         ?     : si la clé est introuvable
    Notes  : anciennement fctCleArc
    ------------------------------------------------------------------------------*/
    define buffer clemi for clemi.

    if not goHistoCG:isArchivageCle() then return false.       /* Test si on gere l'archivage des clés */

    if piNumeroImmeuble <> 0                                   /* L'immeuble est renseigné, on l'utilise en priorité sur le mandat */
    then find first clemi no-lock
        where clemi.noimm = piNumeroImmeuble
          and clemi.cdcle = pcCodeCle no-error.
    else if piNumeroMandat <> 0                                /* Sinon on utilise le mandat si renseigné */
    then find first clemi no-lock
        where clemi.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and clemi.nocon = piNumeroMandat
          and clemi.cdcle = pcCodeCle no-error.
    if available clemi
    then if clemi.cdarc = "00000" or clemi.cdarc = ?
         then return false.
         else if clemi.cdarc = "00099"
         then return true.

    return ?.
end function.
