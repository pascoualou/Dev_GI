/*------------------------------------------------------------------------
File        : compteurReleve.i
Purpose     : liste des compteurs associés aux lots pour un type de relevé
Author(s)   : SPo  -  2018/02/08
Notes       : associé à la table cteur (attention: modification de structure à effectuer pour ajouter tpcon/nocon)
derniere revue: 2018/05/16 - phm: KO
          traiter les todo
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttListeCompteur
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cTypeContrat         as character initial ? 
    field iNumeroContrat       as int64     initial ?
    field iCodageContrat       as int64     initial ? label "noimm"     // TODO : todo : à supprimer quand les structures de cteur seront corrigées (V19.00 ?)
    field iNumeroImmeuble      as integer   initial ?
    field iNumeroLot           as integer   initial ? label "nolot"
    field cLibelleNatureLot    as character initial ?
    field cTypeCompteur        as character initial ? label "tpcpt"
    field cNumeroCompteur      as character initial ? label "nocpt"
    field cEmplacementCompteur as character initial ? label "lbemp"
    field daDateInstallation   as date                label "dtins"
    field cCodeUnite           as character initial ? label "cduni"     // semble inutilisé 
    field iNumeroLocataire     as int64     initial ?                   // dernier locataire occupant
    field daDateEntree         as date                                  // Date d'entrée du locataire 
    field daDateSortie         as date                                  // Date de sortie du locataire 
    field cNomLocataire        as character initial ?

    field dtTimestamp          as datetime
    field CRUD                 as character
    field rRowid               as rowid
.
