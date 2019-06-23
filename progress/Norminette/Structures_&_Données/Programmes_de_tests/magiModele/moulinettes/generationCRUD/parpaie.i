/*------------------------------------------------------------------------
File        : parpaie.i
Purpose     : Parametrage des paiements
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttParpaie
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field Bo-iso          as logical    initial ? 
    field chrono          as integer    initial ? 
    field cpt-eap         as character  initial ? 
    field cpt-eap2        as character  initial ? 
    field cpt-vap         as character  initial ? 
    field ctrl-solde      as logical    initial ? 
    field eap-detail-rb   as logical    initial ? 
    field edi-rs-bao      as logical    initial ? 
    field edi-rs-chqa4    as logical    initial ? 
    field edi-rs-trt      as logical    initial ? 
    field edi-rs-vir      as logical    initial ? 
    field edi-trt         as logical    initial ? 
    field etab-cd         as integer    initial ? 
    field fg-bqmanu       as logical    initial ? 
    field fg-eff-dacompta as logical    initial ? 
    field fg-libmdt       as logical    initial ? 
    field fg-nvfac        as logical    initial ? 
    field fg-odpointe     as logical    initial ? 
    field fg-pointage     as logical    initial ? 
    field fg1chqmdt       as logical    initial ? 
    field floppy-cle      as character  initial ? 
    field lcr-iso         as logical    initial ? 
    field lstreg          as character  initial ? 
    field mail-cli        as logical    initial ? 
    field mail-corps      as character  initial ? 
    field mail-four       as logical    initial ? 
    field mail-obj        as character  initial ? 
    field mail-org        as logical    initial ? 
    field mail-pers       as logical    initial ? 
    field od-jou-cd       as character  initial ? 
    field od-type-cle     as character  initial ? 
    field odcre           as logical    initial ? 
    field regl-cd         as integer    initial ? 
    field rib-date        as date       initial ? 
    field rib-periode     as integer    initial ? 
    field rib-pwd         as character  initial ? 
    field soc-cd          as integer    initial ? 
    field virt-exp        as logical    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
