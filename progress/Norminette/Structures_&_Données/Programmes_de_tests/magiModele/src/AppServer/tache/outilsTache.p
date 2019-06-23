/*------------------------------------------------------------------------
File        : outilsTache.p
Purpose     : programme contenant des includes communs a plusieurs programmes
              transformation en procedure (exemple adb/comm/DtFapMax.i devient procedure dtFapMax)
Author(s)   : GGA - 2017/08/03
Notes       :
------------------------------------------------------------------------*/
{preprocesseur/referenceClient.i}
using parametre.pclie.parametrageProlongationExpiration.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

procedure DtFapMax:
    /*------------------------------------------------------------------------------
    Purpose: Calcul de la date de fin d'application maximum des rubriques fixes
             à partir de adb/comm/DtFapMax.i
    Notes  : service utilisé par baux.p, genoffqt.p, ...
    ------------------------------------------------------------------------------*/
    define input  parameter plTacRec  as logical no-undo.
    define input  parameter pdaFinBai as date    no-undo.
    define input  parameter pdaSorLoc as date    no-undo.
    define input  parameter pdaResBai as date    no-undo.
    define output parameter pdaFapMax as date    no-undo.

    define variable voProlongationExpiration as class parametrageProlongationExpiration no-undo.
    define variable vdaFapCal as date no-undo.

    voProlongationExpiration = new parametrageProlongationExpiration().
    // Spécifique manpower: On ne tient pas compte de la date de fin de bail pour calculer la date de fin d'application de la rubrique.
    if integer(mtoken:cRefPrincipale) = {&REFCLIENT-MANPOWER}  
    then assign
        pdaFinBai = 12/31/2299               /* Ajout SY le 14/10/2013 : 31/12/2299 */
        vdaFapCal = pdaFinBai
    .
    else vdaFapCal = date(12, 31, year(pdaFinBai) + 2).
    if plTacRec and (vdaFapCal = ? or vdaFapCal < today) and voProlongationExpiration:isQuittancementProlonge()
    then vdaFapCal = 12/31/2950.

    /*--> Prendre la plus petite des dates de sorties */
    if pdaSorLoc <> ? and pdaResBai <> ?
    then pdaFapMax = minimum(pdaSorLoc, pdaResBai).
    else if pdaSorLoc <> ?
        then pdaFapMax = pdaSorLoc.
        else if pdaResBai <> ? then pdaFapMax = pdaResBai.
    if not plTacRec                                                                         // Mode : Non Tacite Reconduction
    then do:
        {&_proparse_ prolint-nowarn(when)}
        if voProlongationExpiration:isQuittancementProlonge()
        then assign pdaFapMax = 12/31/2950 when pdaFapMax = ?.                               // On garde la date de sortie si il en existe une
        else pdaFapMax = if pdaFapMax = ? then pdaFinBai else minimum(pdaFapMax, pdaFinBai). // Mode : "Normal"
    end.
    else pdaFapMax = if pdaFapMax = ? then vdaFapCal else pdaFapMax.                         // Mode : Tacite Recondution
    delete object voProlongationExpiration.
end procedure.
