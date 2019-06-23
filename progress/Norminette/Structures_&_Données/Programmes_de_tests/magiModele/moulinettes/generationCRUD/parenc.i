/*------------------------------------------------------------------------
File        : parenc.i
Purpose     : Fichier Parametrage des Encaissements
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttParenc
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field caisse-cpt-cd     as character  initial ? 
    field ccp-cpt-cd        as character  initial ? 
    field chq-cpt-cd        as character  initial ? 
    field chq-num           as integer    initial ? 
    field chqportef-cpt-cd  as character  initial ? 
    field ctrl-daremise     as logical    initial ? 
    field cumul-eff         as logical    initial ? 
    field eff-num           as integer    initial ? 
    field enc-cpt-cd        as character  initial ? 
    field escpt-cpt-cd      as character  initial ? 
    field etab-cd           as integer    initial ? 
    field fg-bqmanu         as logical    initial ? 
    field flag-affbq        as logical    initial ? 
    field flag-avdom        as logical    initial ? 
    field flag-chqa         as logical    initial ? 
    field flag-eff-dacompta as logical    initial ? 
    field flag-transfert    as logical    initial ? 
    field floppy-cle        as character  initial ? 
    field fpiece-chq        as character  initial ? 
    field fpiece-eff        as character  initial ? 
    field lib-manu          as logical    initial ? 
    field mvts              as logical    initial ? 
    field nbex-chq          as integer    initial ? 
    field nbex-eff          as integer    initial ? 
    field nbjour            as integer    initial ? 
    field nbjour-eff        as integer    initial ? 
    field nbuser-chqp       as integer    initial ? 
    field nbuser-remeff     as integer    initial ? 
    field nso-mtdiff        as decimal    initial ?  decimals 2
    field nso-mtdiff-EURO   as decimal    initial ?  decimals 2
    field nso-mttx          as decimal    initial ?  decimals 2
    field num-int           as integer    initial ? 
    field portef-cpt-cd     as character  initial ? 
    field soc-cd            as integer    initial ? 
    field texte-loi         as logical    initial ? 
    field trans-oblig-eff   as logical    initial ? 
    field typechq-cle       as character  initial ? 
    field typeeff-cd        as integer    initial ? 
    field typeeff-cle       as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
