/*------------------------------------------------------------------------
File        : tiersIban.i
Purpose     :
Author(s)   : OFA - 2018/05/15
Notes       :
------------------------------------------------------------------------*/
define temp-table ttBanquesTiers no-undo //Table ctanx
    field cTypeContratIban      as character initial ? label "tpcon"
    field iNumeroContratIban    as integer   initial ? label "nocon"
    field iNumeroInterneContrat as integer   initial ? label "nodoc"
    field cTypeRole             as character initial ? label "tprol"
    field iNumeroRole           as integer   initial ? label "norol"
    field cTypeRoleTiers        as character initial ?                  //Lien Iban/contrat -> table rlctt
    field iNumeroRoleTiers      as integer   initial ?                  //Lien Iban/contrat -> table rlctt
    field cTypeContratTiers     as character initial ?                  //Lien Iban/contrat -> table rlctt
    field iNumeroContratTiers   as integer   initial ?                  //Lien Iban/contrat -> table rlctt
    field cIban                 as character initial ? label "iban"
    field cCodeBIC              as character initial ? label "bicod"
    field cTitulaire            as character initial ? label "lbtit"
    field cDomiciliation        as character initial ? label "lbdom"
    field lIbanParDefautDuTiers as logical   initial ? label "tpact" format "DEFAU/"
    field lIbanDuContratEnCours as logical   initial ?
    field cRUM                  as character initial ? label "norum-ger"
    field daSignatureMandatSEPA as date                label "dtsig-sep"
    field cStatutValidationIban as character initial ? label "lbdiv5"
    field cLibelleStatut        as character initial ?
    field lIbanValide           as logical   initial ?
    field lAccesBlocage         as logical   initial ?
    field lAccesDeblocage       as logical   initial ?
    field dtTimestamp           as datetime
    field CRUD                  as character
    field rRowid                as rowid
    .

define temp-table ttControleDesIban
    field lControleDesIban      as logical   initial ?
    .
