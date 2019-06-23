/*------------------------------------------------------------------------
File        : autasatt.p
Purpose     : Création d'un contrat d'assurance lors de la prise en charge d'un contrat.
Author(s)   : LGI - 1996/02/02  /  kantena - 2017/01/02
Notes       :
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{adblib/include/assat.i}

define input parameter pcTypeContrat as character no-undo.
define input parameter piNumContrat  as integer   no-undo.
define input parameter pcTypeTache   as character no-undo.
define output parameter pcCodeRetour  as character no-undo initial '00'.

define variable giAttestation     as integer no-undo.
define variable gdaFinAttestation as date    no-undo.
define variable ghProc            as handle  no-undo.

for first ctrat no-lock
    where ctrat.tpcon = pcTypeContrat
      and ctrat.nocon = piNumContrat:
    run application/l_prgdat.p persistent set ghProc.
    run getTokenInstance in ghProc(mToken:JSessionId).
    run cl2DatFin in ghProc (ctrat.dtdeb, '1', '00001', output gdaFinAttestation). /* Calcul date de fin  */
    run destroy in ghProc.

    run adblib/assat_CRUD.p persistent set ghProc.
    run getTokenInstance in ghProc (mToken:JSessionId).
    create ttAssat.
    assign
        ttAssat.CRUD  = 'C'
        ttAssat.tpcon = pcTypeContrat
        ttAssat.nocon = piNumContrat
        ttAssat.tptac = pcTypeTache
        ttAssat.dtrcp = ctrat.dtdeb
        ttAssat.dtdeb = ctrat.dtdeb
        ttAssat.dtfin = gdaFinAttestation
    .
    run setAssat in ghProc(table ttAssat by-reference).
    run destroy in ghProc.
end.
