/*------------------------------------------------------------------------
File        : tacheReleve.i
Purpose     : Paramétrage taches Eau froide, eau chaude, Thermies, Gaz etc...
Author(s)   : SPo  -  2018/02/08
Notes       : c.f. prmobrlv.p/PrO1rlv.p
derniere revue: 2018/05/17 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTacheReleve
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroTache                     as int64
    field cTypeContrat                     as character
    field iNumeroContrat                   as int64
    field cTypeTache                       as character
    field iChronoTache                     as integer
    field cTypeCompteur                    as character initial ?
    field cLibelleTypeCompteur             as character initial ?
    field cCodeUnite                       as character initial ?
    field cLibelleCodeUnite                as character initial ?
    field iCodeRubriqueAna                 as integer   initial ?
    field iCodeSousRubriqueAna             as integer   initial ?
    field iCodeFiscalite                   as integer   initial ?
    field dPrixFluideTTC                   as decimal   initial ? decimals 6
    field dTauxTVAFluide                   as decimal   initial ? decimals 3
    field cCleRepartitionFluide            as character initial ?
    field cCleRecuperationFluide           as character initial ?
    field dPrixEauFroideRechaufTTC         as decimal   initial ? decimals 3   // pour Eau chaude uniquement
    field dTauxTVAEauFroideRechauf         as decimal   initial ? decimals 3   // pour Eau chaude uniquement
    field cCleRecuperationEauFroideRechauf as character initial ?              // pour Eau chaude uniquement 
    field cCleRecuperation2                as character initial ?              // pour Thermies uniquement
    field dPouvoirCalorifique              as decimal   initial ? decimals 3   // pour Gaz de france uniquement

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
