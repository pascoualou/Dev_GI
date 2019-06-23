/*------------------------------------------------------------------------
File        : centfac.i
Purpose     : Fichier ENTETE de Factures/Avoirs Clients
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCentfac
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field acompte1      as decimal    initial ?  decimals 3
    field acompte2      as decimal    initial ?  decimals 3
    field adrfac        as character  initial ? 
    field adrfac-cd     as integer    initial ? 
    field adrliv        as character  initial ? 
    field adrliv-cd     as integer    initial ? 
    field affact-cle    as character  initial ? 
    field affair-num    as integer    initial ? 
    field affect        as character  initial ? 
    field cli-cle       as character  initial ? 
    field cod-trans     as character  initial ? 
    field com-num       as integer    initial ? 
    field commentaire   as character  initial ? 
    field compta        as logical    initial ? 
    field cours         as decimal    initial ?  decimals 4
    field cours-tar     as decimal    initial ?  decimals 4
    field cpfac         as character  initial ? 
    field cpliv         as character  initial ? 
    field dadepart      as date       initial ? 
    field daech         as date       initial ? 
    field dafac         as date       initial ? 
    field dareleve      as date       initial ? 
    field dasai         as date       initial ? 
    field demandeur     as character  initial ? 
    field dev-cd        as character  initial ? 
    field devtar-cd     as character  initial ? 
    field direct        as logical    initial ? 
    field div-cd        as integer    initial ? 
    field echeance      as logical    initial ? 
    field edifac        as logical    initial ? 
    field embtaxe-cd    as integer    initial ? 
    field etab-cd       as integer    initial ? 
    field exonere       as logical    initial ? 
    field fac-num       as integer    initial ? 
    field flag-contrat  as logical    initial ? 
    field flag-langue   as logical    initial ? 
    field flag-redev    as logical    initial ? 
    field franco        as logical    initial ? 
    field libass-cd     as integer    initial ? 
    field libpaysfac-cd as character  initial ? 
    field libpaysliv-cd as character  initial ? 
    field libraisfac-cd as integer    initial ? 
    field libraisliv-cd as integer    initial ? 
    field livr-cd       as integer    initial ? 
    field modifech      as logical    initial ? 
    field mt-assf-tar   as decimal    initial ?  decimals 2
    field mt-assv-tar   as decimal    initial ?  decimals 2
    field mt-crfixe-tar as decimal    initial ?  decimals 2
    field mt-crvar-tar  as decimal    initial ?  decimals 2
    field mt-exp-tar    as decimal    initial ?  decimals 2
    field mt-fdiv-tar   as decimal    initial ?  decimals 2
    field mt-pordu-tar  as decimal    initial ?  decimals 2
    field mt-timbre-tar as decimal    initial ?  decimals 2
    field mt-var-tar    as decimal    initial ?  decimals 2
    field mtembht       as decimal    initial ?  decimals 3
    field mtembttc      as decimal    initial ?  decimals 3
    field mtescpt       as decimal    initial ?  decimals 3
    field mtht          as decimal    initial ?  decimals 3
    field mtht-EURO     as decimal    initial ?  decimals 3
    field mtportht      as decimal    initial ?  decimals 3
    field mtportht-tar  as decimal    initial ?  decimals 3
    field mtportttc     as decimal    initial ?  decimals 3
    field mtremex       as decimal    initial ?  decimals 3
    field mtttc         as decimal    initial ?  decimals 3
    field mtttc-EURO    as decimal    initial ?  decimals 3
    field mttva         as decimal    initial ?  decimals 3
    field mttva-EURO    as decimal    initial ?  decimals 3
    field mttvaemb      as decimal    initial ?  decimals 3
    field mttvaport     as decimal    initial ?  decimals 3
    field mvtstock      as logical    initial ? 
    field nbcolis       as integer    initial ? 
    field nbetiq        as integer    initial ? 
    field nom-cli       as character  initial ? 
    field nomfac        as character  initial ? 
    field nomliv        as character  initial ? 
    field num-int       as integer    initial ? 
    field num-int-org   as integer    initial ? 
    field operateur     as character  initial ? 
    field origine       as character  initial ? 
    field period        as character  initial ? 
    field periodicite   as character  initial ? 
    field poidsbrut     as decimal    initial ?  decimals 3
    field poidsnet      as decimal    initial ?  decimals 3
    field port-cd       as integer    initial ? 
    field porttaxe-cd   as integer    initial ? 
    field refcli        as character  initial ? 
    field regl-cd       as integer    initial ? 
    field releve        as logical    initial ? 
    field releve-num    as integer    initial ? 
    field remliv        as decimal    initial ?  decimals 3
    field rep-cle       as character  initial ? 
    field rep-cle2      as character  initial ? 
    field serv-cd       as integer    initial ? 
    field situ          as logical    initial ? 
    field soc-cd        as integer    initial ? 
    field tar-num       as character  initial ? 
    field texte         as character  initial ? 
    field totht         as decimal    initial ?  decimals 3
    field totht-EURO    as decimal    initial ?  decimals 3
    field tottva        as decimal    initial ?  decimals 3
    field tottva-EURO   as decimal    initial ?  decimals 3
    field traite        as logical    initial ? 
    field trans-cle     as character  initial ? 
    field txescpt       as decimal    initial ?  decimals 2
    field txremex       as decimal    initial ?  decimals 2
    field typccl-cd     as integer    initial ? 
    field type          as logical    initial ? 
    field val-releve    as logical    initial ? 
    field val-traite    as logical    initial ? 
    field valfac        as logical    initial ? 
    field vilfac        as character  initial ? 
    field villiv        as character  initial ? 
    field volume        as decimal    initial ?  decimals 3
    field zone-liv      as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
