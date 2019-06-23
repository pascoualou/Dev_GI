/*------------------------------------------------------------------------
File        : tacheTva.i
Purpose     : 
Author(s)   : GGA  -  28/07/2017
Notes       :
derniere revue: 2018/05/19 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTacheTva
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroTache            as int64     initial ?
    field cTypeContrat            as character initial ?
    field iNumeroContrat          as int64     initial ?
    field cTypeTache              as character initial ?
    field iChronoTache            as integer   initial ?
    field daActivation            as date                label "HwDtaDtd"
    field daFin                   as date                label "HwDtaDtf"
    field cTypeRegime             as character initial ? label "HwDtaReg"
    field cLibelleRegime          as character initial ?
    field cTypeDeclaration        as character initial ? label "HwDtaDec"
    field cLibelleDeclaration     as character initial ?
    field cCentreImpot            as character initial ? label "HwDtaCdi"
    field cTypePeriode            as character initial ? label "HwDtaFre"
    field cLibellePeriode         as character initial ?
    field iDepotAuPlusTard        as integer   initial ? label "HwDtaJmx"
    field lReglement              as logical   initial ? label "HwDtaRgt"
    field cCentreRecette          as character initial ? label "HwDtaCdr"
    field cCodeTvaConsRev         as character initial ? label "HwRadTvc"
    field cLibelleTvaConsRev      as character initial ?
    field cCodeSiret              as character initial ? label "HwDtaSir"
    field cCodeNic                as character initial ? label "HwDtaNic"
    field cCodeApe                as character initial ? label "HwDtaApe"
    field cCodeRecette            as character initial ? label "HwDtarec"
    field cLibelleRecette         as character initial ?
    field cCodeDepense            as character initial ? label "HwDtaDep"
    field cLibelleDepense         as character initial ?
    field iCodeHonoraire          as integer   initial ? label "HwDtaHon"
    field cLibelleCodeHonoraire   as character initial ?
    field cTvaIntra               as character initial ? label "HwDtaTva"
    field cActivitePrinc          as character initial ? label "HwDtaAct"
    field cNoSie01                as character initial ? label "HwDt1SIE"
    field cNoSie02                as character initial ? label "HwDt2SIE"
    field cNoSie03                as character initial ? label "HwDt3SIE"
    field iNoDossier              as integer   initial ? label "HwDtaDos"
    field iNoCle                  as integer   initial ? label "HwNumCle"
    field iCodeCdir               as integer   initial ? label "HwDtaCod"
    field iCodeService            as integer   initial ? label "HwDtaSrv"
    field lSaisieManuelleProrata  as logical   initial ? label "HwTglPro"
    field iMandatDeclaration      as integer   initial ? label "HwDtaMde"
    field cTypeCentreImpot        as character initial ?                   // type appel liste centre impot
    field cTypeCentreRecette      as character initial ?                   // type appel liste centre recette
    field cCentrePaiementImmeuble as character initial ?                   // Centre de paiement immeuble
    field lTvaTraite              as logical   initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
&if defined(nomTableProrata) = 0 &then &scoped-define nomTableProrata ttProrataParExercice
&endif
&if defined(serialNameProrata) = 0 &then &scoped-define serialNameProrata {&nomTableProrata}
&endif
define temp-table {&nomTableProrata} no-undo serialize-name '{&serialNameProrata}'
    field iExercice             as integer initial ? label "iNoExo"      /* Exercice         */
    field dPrctAssujettissement as decimal initial ? label "dTxAss"      /* Assujettissement */    
    field dPrctTaxation         as decimal initial ? label "dTxTax"      /* % Taxation       */  
    field iNumerateur           as integer initial ? label "iNumerateur" /* Numerateur       */
    field iDenominateur         as integer initial ? label "iNbDen"      /* Denominateur     */
.
