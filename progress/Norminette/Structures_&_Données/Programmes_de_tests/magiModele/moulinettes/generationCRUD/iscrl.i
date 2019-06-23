/*------------------------------------------------------------------------
File        : iscrl.i
Purpose     : fichier reponse.txt (gft)
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIscrl
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field adr                 as character  initial ? 
    field ancien-jur          as character  initial ? 
    field ape                 as character  initial ? 
    field bilan-dispo         as character  initial ? 
    field bq-cd2              as integer    initial ? 
    field bq-ref1             as character  initial ? 
    field bq-ref2             as character  initial ? 
    field bque-cd1            as integer    initial ? 
    field ca                  as character  initial ? 
    field capacite-auto       as character  initial ? 
    field capital             as decimal    initial ?  decimals 0
    field capital-actuel      as decimal    initial ?  decimals 0
    field capital-actuel-EURO as decimal    initial ?  decimals 0
    field capital-av          as decimal    initial ?  decimals 0
    field capital-av-EURO     as decimal    initial ?  decimals 0
    field capital-EURO        as decimal    initial ?  decimals 0
    field civilite-dir        as character  initial ? 
    field cli-num             as integer    initial ? 
    field commentaires        as character  initial ? 
    field cotation            as character  initial ? 
    field cote-exper          as character  initial ? 
    field cp                  as character  initial ? 
    field cp-action           as character  initial ? 
    field dat-arret-bil       as date       initial ? 
    field dat-coteexp         as date       initial ? 
    field dat-impaye          as date       initial ? 
    field dat-intervscrl      as date       initial ? 
    field dat-litige          as date       initial ? 
    field dat-motif-jur       as date       initial ? 
    field dat-motifcap        as date       initial ? 
    field dat-prorog          as date       initial ? 
    field dat-protet          as date       initial ? 
    field datcrea             as character  initial ? 
    field datdem              as date       initial ? 
    field datexp              as date       initial ? 
    field datmotif-cote       as date       initial ? 
    field datprivi            as date       initial ? 
    field decis-collect       as character  initial ? 
    field dev-cd              as character  initial ? 
    field dirigeant-cd        as character  initial ? 
    field dont-exp            as character  initial ? 
    field duree-ex            as integer    initial ? 
    field effect-bilan        as character  initial ? 
    field effectif            as character  initial ? 
    field elem-conso          as character  initial ? 
    field encours-cons        as character  initial ? 
    field encours-dem         as character  initial ? 
    field enr-cd              as integer    initial ? 
    field enseigne            as character  initial ? 
    field etab-cd             as integer    initial ? 
    field etab-nb             as integer    initial ? 
    field extens-nom          as character  initial ? 
    field fax                 as character  initial ? 
    field fonds-prop          as character  initial ? 
    field form-juri           as character  initial ? 
    field gest-lettre         as character  initial ? 
    field gest-num1           as character  initial ? 
    field gest-num2           as character  initial ? 
    field lib                 as character  initial ? 
    field lib-juri            as character  initial ? 
    field lib-privi           as character  initial ? 
    field marche              as character  initial ? 
    field mode-exploi         as character  initial ? 
    field modif-cote          as character  initial ? 
    field motif-capital       as character  initial ? 
    field mt-motif-capit      as decimal    initial ?  decimals 0
    field mt-motif-capit-EURO as decimal    initial ?  decimals 0
    field mt-privi            as decimal    initial ?  decimals 0
    field mt-privi-EURO       as decimal    initial ?  decimals 0
    field nbre-demande        as integer    initial ? 
    field nic-num             as integer    initial ? 
    field nom                 as character  initial ? 
    field nom-action          as character  initial ? 
    field nom-dir             as character  initial ? 
    field nouv-jur            as character  initial ? 
    field objet-soc           as character  initial ? 
    field paiements           as character  initial ? 
    field pays-action         as character  initial ? 
    field pays-cd             as character  initial ? 
    field pct-action          as character  initial ? 
    field position-prof       as character  initial ? 
    field prenom-dir          as character  initial ? 
    field presen-privi        as character  initial ? 
    field presence-inc        as character  initial ? 
    field prestation          as character  initial ? 
    field refcli              as character  initial ? 
    field result-cour         as character  initial ? 
    field result-expl         as character  initial ? 
    field result-net          as character  initial ? 
    field scrl-num            as integer    initial ? 
    field sigle               as character  initial ? 
    field siren-num           as integer    initial ? 
    field siret-action        as integer    initial ? 
    field soc-cd              as integer    initial ? 
    field surface-imm         as character  initial ? 
    field tel                 as character  initial ? 
    field telex               as character  initial ? 
    field type-ca             as character  initial ? 
    field val-coteexpert      as character  initial ? 
    field valcote-exper       as character  initial ? 
    field ville               as character  initial ? 
    field ville-action        as character  initial ? 
    field ville-cotation      as character  initial ? 
    field ville-rattach       as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
