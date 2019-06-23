/*------------------------------------------------------------------------
File        : histoEncadrementLoyer.i
Purpose     :
Author(s)   : LGI/NPO - 2016/12/06
Notes       :
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttHistoEncadrementLoyer
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroHistoLoyerCtrl as integer   initial ?
    field iNumeroFiche          as integer   initial ?
    field cAnneeConstruction    as character initial ?
    field cAdresseEnvoye        as character initial ?
    field iNombrePieces         as integer   initial ?
    field lLocationMeuble       as logical   initial ?
    field dSurfaceHabitable     as decimal   initial ?
    field dLoyerEnvoye          as decimal   initial ?
    field dLoyerM2Envoye        as decimal   initial ?
    field dLoyerM2Mediant       as decimal   initial ?
    field dLoyerM2Minore        as decimal   initial ?
    field dLoyerM2Majore        as decimal   initial ?
    field cCodeRetour           as character initial ?
    field cMessageRetour        as character initial ?
    field cCodeStatutCalcul     as character initial ?
    field dtHorodatageCalcul    as datetime

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
index primaire is primary unique iNumeroHistoLoyerCtrl
.
&if defined(nomTableDemande)   = 0 &then &scoped-define nomTableDemande ttDemandeEncadrementLoyer
&endif
&if defined(serialNameDemande) = 0 &then &scoped-define serialNameDemande {&nomTableDemande}
&endif
define temp-table {&nomTableDemande} no-undo serialize-name '{&serialNameDemande}'
    field iNumeroFiche       as integer   initial ?
    field cAdresseEnvoye     as character initial ?
    field iNombrePieces      as integer   initial ?
    field cAnneeConstruction as character initial ?
    field dLoyerM2Envoye     as decimal   initial ?
    field iLocMeuble         as integer   initial ?
.
&if defined(nomTableCalcul)   = 0 &then &scoped-define nomTableCalcul ttCalculEncadrementLoyer
&endif
&if defined(serialNameCalcul) = 0 &then &scoped-define serialNameCalcul {&nomTableCalcul}
&endif
define temp-table {&nomTableCalcul} no-undo serialize-name '{&serialNameCalcul}'
    field lValid       as logical   serialize-name 'valid'
    field cStatus      as character serialize-name 'code_status'
    field dtHorodatage as datetime  serialize-name 'horodatage'
    field dLoyerMinore as decimal   serialize-name 'min'
    field dLoyerMajore as decimal   serialize-name 'max'
    field dLoyerMedian as decimal   serialize-name 'ref'
.
