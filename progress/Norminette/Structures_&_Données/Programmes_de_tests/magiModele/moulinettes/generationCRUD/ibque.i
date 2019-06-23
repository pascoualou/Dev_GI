/*------------------------------------------------------------------------
File        : ibque.i
Purpose     : Informations sur les banques
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIbque
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field adr             as character  initial ? 
    field bic             as character  initial ? 
    field bque            as character  initial ? 
    field bque-cd         as integer    initial ? 
    field chqbana-formu   as integer    initial ? 
    field cmc7            as character  initial ? 
    field compens-ville   as character  initial ? 
    field contact         as character  initial ? 
    field cp              as character  initial ? 
    field cpt             as character  initial ? 
    field cpt-adr         as character  initial ? 
    field cpt-cd          as character  initial ? 
    field cpt-cp          as character  initial ? 
    field cpt-intitule    as character  initial ? 
    field cpt-ville       as character  initial ? 
    field cptetr          as character  initial ? 
    field dachqetr        as integer    initial ? 
    field dachqhpl        as integer    initial ? 
    field dachqspl        as integer    initial ? 
    field datrtenc        as integer    initial ? 
    field datrtenc3       as integer    initial ? 
    field datrtenc4       as integer    initial ? 
    field datrtesc        as integer    initial ? 
    field decouv          as decimal    initial ?  decimals 2
    field decouv-EURO     as decimal    initial ?  decimals 2
    field dernbao         as integer    initial ? 
    field dernchq-bana    as integer    initial ? 
    field derntrt         as integer    initial ? 
    field dernvir         as integer    initial ? 
    field domicil         as character  initial ? 
    field edition         as logical    initial ? 
    field emet-num        as character  initial ? 
    field emet2-num       as character  initial ? 
    field emet3-num       as character  initial ? 
    field etab-cd         as integer    initial ? 
    field etr             as logical    initial ? 
    field fax             as character  initial ? 
    field fg-active       as logical    initial ? 
    field fg-chqA4        as logical    initial ? 
    field fg-chqbanal     as logical    initial ? 
    field fg-chqTLMC      as logical    initial ? 
    field fg-formvirA4    as logical    initial ? 
    field fg-iso          as logical    initial ? 
    field fg-lcr          as logical    initial ? 
    field fg-logochqA4    as logical    initial ? 
    field fg-pivot        as logical    initial ? 
    field fg-postmarquage as logical    initial ? 
    field fg-tip          as logical    initial ? 
    field fg-virA4        as logical    initial ? 
    field fg-vrec         as logical    initial ? 
    field fg-vrej         as logical    initial ? 
    field FgEdtVil        as logical    initial ? 
    field fic-lcr         as character  initial ? 
    field fic-tip         as character  initial ? 
    field fic-vrec        as character  initial ? 
    field fic-vrej        as character  initial ? 
    field ficLCR          as character  initial ? 
    field ficPREL         as character  initial ? 
    field ficVIR          as character  initial ? 
    field file-name       as character  initial ? 
    field floppy-cle      as character  initial ? 
    field fmtprl          as character  initial ? 
    field fmtvir          as character  initial ? 
    field frais           as logical    initial ? 
    field guichet         as character  initial ? 
    field iban            as character  initial ? 
    field ics             as character  initial ? 
    field interbq-num     as character  initial ? 
    field interf          as logical    initial ? 
    field libpays-cd      as character  initial ? 
    field logo-chq        as character  initial ? 
    field mdcprl          as logical    initial ? 
    field mdcvir          as logical    initial ? 
    field nbj-rappro      as integer    initial ? 
    field NbLgnDest       as integer    initial ? 
    field nne             as character  initial ? 
    field nom             as character  initial ? 
    field numdeb-bana     as integer    initial ? 
    field numfin-bana     as integer    initial ? 
    field nvguichet       as integer    initial ? 
    field payable-adr     as character  initial ? 
    field payable-tel     as character  initial ? 
    field plafond         as decimal    initial ?  decimals 2
    field plafond-EURO    as decimal    initial ?  decimals 2
    field pourc-rappro    as integer    initial ? 
    field prembao         as integer    initial ? 
    field premchq         as integer    initial ? 
    field premtrt         as integer    initial ? 
    field rappro-dsq      as logical    initial ? 
    field respagence      as character  initial ? 
    field rib             as character  initial ? 
    field serie           as character  initial ? 
    field soc-cd          as integer    initial ? 
    field tauxdecouv      as decimal    initial ?  decimals 2
    field tauxesc         as decimal    initial ?  decimals 2
    field tel             as character  initial ? 
    field telex           as character  initial ? 
    field tip-cd          as character  initial ? 
    field top-bnp         as logical    initial ? 
    field ville           as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
