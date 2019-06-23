/*------------------------------------------------------------------------
File        : archicle.i
Purpose     : fonction pour l'archivages des cles
Author(s)   : GGA  -  2017/12/19
Notes       : reprise de adb/comm/archicle
derniere revue: 2018/04/25 - phm: OK
------------------------------------------------------------------------*/

function isCleArchivee returns logical private(piNumeroImmeuble as integer, piNumeroMandat as integer, pcCodeCle as character):
    /*------------------------------------------------------------------------------
    Purpose: Fonction pour savoir si une cle est archiv�e ou non
         TRUE  : si la cl� est archiv�e
         FALSE : si la cl� n'est pas archiv�e ou Archivage non g�r�
         ?     : si la cl� est introuvable
    Notes  : anciennement fctCleArc
    ------------------------------------------------------------------------------*/
    define buffer clemi for clemi.

    if not goHistoCG:isArchivageCle() then return false.       /* Test si on gere l'archivage des cl�s */

    if piNumeroImmeuble <> 0                                   /* L'immeuble est renseign�, on l'utilise en priorit� sur le mandat */
    then find first clemi no-lock
        where clemi.noimm = piNumeroImmeuble
          and clemi.cdcle = pcCodeCle no-error.
    else if piNumeroMandat <> 0                                /* Sinon on utilise le mandat si renseign� */
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
