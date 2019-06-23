/*------------------------------------------------------------------------
File        : intnt.i
Purpose     : 
Author(s)   : KANTENA  2017/02/06
Notes       :
------------------------------------------------------------------------*/

&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIntnt
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif

define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cddev       as character initial ?   // Code devise
    field cdreg       as character initial ?   // Code regroupement
    field cdtri       as character initial ?   // Tri envoi
    field edapf       as character initial ?   // Edition appel de fonds
    field FgCrg       as logical   initial ?   // CRG
    field fgimprdoc   as logical   initial ?   // Impression doc prod.
    field fgmadispo   as logical   initial ?   // Mise à dispo doc prod.
    field fgpay       as logical   initial ?   // Payeur/Receveur
    field idpre       as integer   initial ?   // Identifiant précédent
    field idsui       as integer   initial ?   // Identifiant suivant
    field lbdiv       as character initial ?   // Libellé divers
    field lbdiv2      as character initial ?   // Filler
    field lbdiv3      as character initial ?   // Filler
    field lipar       as character initial ?   // Lien de parenté (Garant)
    field mtprov      as decimal   initial ?   // Provision permanente
    field nbden       as integer   initial ?   // Dénominateur
    field nbnum       as integer   initial ?   // Numérateur
    field nocon       as int64     initial ?   // Numéro de contrat
    field nocon-dec   as decimal   initial ?   // Numero de contrat
    field noidt       as int64     initial ?   // Numéro d'identifiant
    field noidt-dec   as decimal   initial ?   // Numero d'identifiant
    field tpcon       as character initial ?   // Type de contrat
    field tpidt       as character initial ?   // Type d'identifiant
    field tpmadisp    as character initial ?   // Type mise à jour
    field cdcsy       as character initial ?   // User de génération
    field dtcsy       as date      initial ?   // Date de génération
    field hecsy       as integer   initial ?   // Heure de génération
    field cdmsy       as character initial ?   // User de modification
    field dtmsy       as date      initial ?   // Date de modification
    field hemsy       as integer   initial ?   // Heure de modification
    field CRUD        as character initial ?
    field dtTimestamp as datetime  initial ?
    field rRowid      as rowid
.
