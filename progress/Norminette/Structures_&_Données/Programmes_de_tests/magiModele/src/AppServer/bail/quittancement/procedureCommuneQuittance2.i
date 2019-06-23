/*------------------------------------------------------------------------
File        : procedureCommuneQuittance2.i
Purpose     :
Author(s)   : GGA 2018/07/12
Notes       : rajouter using parametre.pclie.parametrageProlongationExpiration
derniere revue: 2018/08/14 - phm: OK
----------------------------------------------------------------------*/

function dateFinBail returns logical private(pcTypeContrat as character, piNumeroContrat as int64, pdaProchaineDate as date):
    /*-------------------------------------------------------------------
    Purpose: Procedure de recherche date fin bail ou date resiliation contrat.
    Notes:
    ----------------------------------------------------------------------*/
    define variable voProlongationExpiration  as class parametrageProlongationExpiration no-undo.
    define variable vlQuittanceProlonge as logical no-undo.
    define buffer ctrat for ctrat.

    for first ctrat no-lock
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroContrat:
        /* Date de resiliation du contrat bail. */
        if ctrat.dtree <> ? and ctrat.dtree < pdaProchaineDate then return true.

        /* Si pas Tacite reconduction: tester Expiration */
        if ctrat.tpren <> "00001" then do:
            /*--> Uniquement si module prolongation apres expiration non ouvert */
            assign
                voProlongationExpiration = new parametrageProlongationExpiration()
                vlQuittanceProlonge      = voProlongationExpiration:isQuittancementProlonge()
            .
            delete object voProlongationExpiration.
            if not vlQuittanceProlonge and ctrat.dtfin < pdaProchaineDate  then return true.   /*--> Date de fin du contrat bail */
        end.
        return false.
    end.
    return true.

end function.

procedure chgTaux private:
    /*-------------------------------------------------------------------
    Purpose: Procedure de recuperation du taux de revision. 
    Notes:
  ----------------------------------------------------------------------*/
    define input  parameter pcTypeIndice    as character no-undo.
    define input  parameter piAnnee         as integer   no-undo.
    define input  parameter piNumeroPeriode as integer   no-undo.
    define input  parameter piPeriodicite   as integer   no-undo.
    define output parameter pdValeur        as decimal   no-undo.
    define output parameter pdTaux          as decimal   no-undo.
    define output parameter plIndParu       as logical   no-undo.

    define variable vhProcIndrv as handle no-undo.
    define variable voCollection as class collection no-undo.

    run crud/indrv_CRUD.p persistent set vhProcIndrv.
    run getTokenInstance in vhProcIndrv(mToken:JSessionId).
    if piPeriodicite = 1
    then run readIndiceRevision2 in vhProcIndrv(
        pcTypeIndice,              /* Type d'indice              */
        piAnnee,                   /* Annee de reference         */
        piNumeroPeriode,           /* Numero de periode          */
        piPeriodicite,             /* Periodicite revision loyer */
        output voCollection
    ).
    else run readIndiceRevision3 in vhProcIndrv(
        pcTypeIndice,              /* Type d'indice              */
        piAnnee + piPeriodicite,   /* Annee de reference         */
        piNumeroPeriode,           /* Numero de perdiode         */
        piPeriodicite,             /* Periodicite revision loyer */
        output voCollection
    ).
    if voCollection:getLogical("lTrouve") 
    then assign
        plIndParu = yes 
        pdValeur  = voCollection:getDecimal("dValeurRevision")
        pdTaux    = voCollection:getDecimal("dTauxRevision")
    .
    if valid-handle(vhProcIndrv) then run destroy in vhProcIndrv.

end procedure.
