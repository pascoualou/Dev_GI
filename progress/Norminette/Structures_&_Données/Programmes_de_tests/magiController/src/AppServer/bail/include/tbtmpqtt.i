/*------------------------------------------------------------------------
File        : tbtmpqtt.i
Purpose     : table de travail du quittancement d'après TbTmpQtt.i (tables tmqtt/tmrub)
Author(s)   : GGA/Spo 2018/06/xx
Notes       : Compatible avec les différentes tables de la base :
              equit, aquit, pquit, daquit, equitrev
              les extent 20 contiennent les caractéristiques des 1 à 20 rubriques de la quittance
              
derniere revue: 2018/07/28 - phm: 
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttQtt
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNoInterne                  as int64     initial ?                      label "noint"
    field cTypeRole                   as character initial ?                      label "tprol"
    field iNumeroLocataire            as int64     initial ?                      label "noloc"
    field iNoQuittance                as integer   initial ?                      label "noqtt"
    field iMoisTraitementQuitt        as integer   initial ?                      label "msqtt"
    field iMoisReelQuittancement      as integer   initial ?                      label "msqui"
    field daDebutQuittancement        as date                                     label "dtdeb" 
    field daFinQuittancement          as date                                     label "dtfin"
    field daDebutPeriode              as date                                     label "dtdpr"
    field daFinPeriode                as date                                     label "dtfpr"
    field cPeriodiciteQuittancement   as character initial ?                      label "pdqtt"
    field cNatureBail                 as character initial ?                      label "ntbai"
    field iDureeBail                  as integer   initial ?                      label "dubai"
    field cUniteDureeBail             as character initial ?                      label "utdur"
    field daEffetBail                 as date                                     label "dteff"
    field cCodeTypeIndiceRevision     as character initial ?                      label "tpidc"
    field cPeriodiciteIndiceRevision  as character initial ?                      label "pdidc"
    field iPeriodeAnneeIndiceRevision as integer   initial ?                      label "noidc"
    field daProchaineRevision         as date                                     label "dtrev"
    field daTraitementRevision        as date                                     label "dtprv"
    field cCodeModeReglement          as character initial ?                      label "mdreg"
    field cCodeTerme                  as character initial ?                      label "cdter"
    field daEntre                     as date                                     label "dtent"
    field daSortie                    as date                                     label "dtsor"
    field iNumeroImmeuble             as integer   initial ?                      label "noimm"
    field dMontantQuittance           as decimal   initial ? decimals 2           label "mtqtt"
    field iNombreRubrique             as integer   initial ?                      label "nbrub"
    field iProrata                    as integer   initial ?                      label "cdquo"
    field iNumerateurProrata          as integer   initial ?                      label "nbnum"
    field iDenominateurProrata        as integer   initial ?                      label "nbden"
    field cMoisAnnee                  as character initial ?                                            
    field cLibelleMoisAnnee           as character initial ?
    field tbfam                       as integer   initial ? extent 20            serialize-hidden
    field tbsfa                       as integer   initial ? extent 20            serialize-hidden
    field tbrub                       as integer   initial ? extent 20            serialize-hidden
    field tblib                       as integer   initial ? extent 20            serialize-hidden
    field tbgen                       as character initial ? extent 20            serialize-hidden
    field tbsig                       as character initial ? extent 20            serialize-hidden
    field tbdet                       as character initial ? extent 20            serialize-hidden
    field tbqte                       as decimal   initial ? extent 20 decimals 4 serialize-hidden
    field tbpun                       as decimal   initial ? extent 20 decimals 4 serialize-hidden
    field tbtot                       as decimal   initial ? extent 20 decimals 2 serialize-hidden
    field tbpro                       as integer   initial ? extent 20            serialize-hidden
    field tbnum                       as integer   initial ? extent 20            serialize-hidden
    field tbden                       as integer   initial ? extent 20            serialize-hidden
    field tbmtq                       as decimal   initial ? extent 20 decimals 2 serialize-hidden
    field tbdt1                       as date                extent 20            serialize-hidden
    field tbdt2                       as date                extent 20            serialize-hidden
    field tbfil                       as character initial ? extent 20            serialize-hidden
    field cCodeEditionDepotGarantie   as character initial ?                      label "cddep"
    field cCodeEditionSolde           as character initial ?                      label "cdsol"
    field cCodeRevisionDeLaQuittance  as character initial ?                      label "cdrev"
    field cdprv                       as character initial "00000"                serialize-hidden    //inutilisé, toujours à "00000"
    field cdprs                       as character initial ?
    field nbedt                       as integer   initial ?
    field cdcor                       as character initial ?
    field fgtrf                       as logical   initial ?
    field cddev                       as character initial ?                      serialize-hidden    //inutilisé
    field lbdiv                       as character initial ?                      serialize-hidden    //inutilisé
    field lbdiv2                      as character initial ?                      serialize-hidden    //inutilisé
    field cModeCalculTVABail          as character initial ?                      label "lbdiv3#1#Å"  //entry( 1, equit.lbdiv3, separ[3])
    field iNumeroMandat               as integer   initial ?                      label "nomdt"
    field daTransfert                 as date                                     label "dttrf"
    // informations d'une quittance historisée (aquit)
    field daEmission                  as date                                     label "dtems"
    field lFactureLocataire           as logical   initial ?                      label "fgfac"
    field cTypeFacture                as character initial ?                      label "type-fac"    //E,S,C,D
    field iNoInterneFacture           as integer   initial ?                      label "num-int-fac"
    field daFacture                   as date                                     label "dafac"       //iftsai.dafac
    field cLibelleTypeFacture         as character initial ?                      label "typefac-cle" //iftsai.typefac-cle (Entree, Sortie, Divers, Comp)
    field iNoFacture                  as integer   initial ?                      label "fac-num"     //iftsai.fac-num
    field daComptabilisation          as date      initial ?                      label "dacompta"    //iftsai.dacompta
    field lQuittanceAvance            as logical   initial ?                      label "fgqttav"
    field iMoisQuittancementEdition   as integer   initial ?                      label "msqtt-edt"
    field idbai                       as character initial ?                      serialize-hidden    //informations concaténées de l'indice de révision
    // information d'un détail de facture d'entrée avant fusion et historisation (daquit)
    field iNoQuittanceFusionnee       as integer   initial ?                      label "norefqtt"    //0 pour equit/aquit/pquit
    field lExisteDetailQuittEntree    as logical   initial ?                                          //présence des quittances avant fusion pour la facture d'entrée (daquit)
    // Module optionnel Prélèvement mensuel d'un quitt trimestriel
    field iNombreEcheancePrelevement  as integer   initial ?                      label "nbech"
    field tbechDate                   as date                extent 6             serialize-hidden
    field tbEchMtqtt                  as decimal   initial ? extent 6 decimals 2  serialize-hidden
    field tbechmtSld                  as decimal   initial ? extent 6 decimals 2  serialize-hidden
    field mtSolde                     as decimal   initial ?
    field DtSolde                     as date
    // Spécifique 02053 BNP : Rubrique et montant encaissés pour calcul montant loyer d'un bail fournisseur de loyer sous 'Bail proportionnel' (04369)
    field tbrubenc                    as integer   initial ? extent 20            serialize-hidden
    field tbmntenc                    as decimal   initial ? extent 20 decimals 2 serialize-hidden
    // Spécifique 02053 BNP : Type & numéro Chrono des factures associées à la quittance (Quitt et Hono)
    field tbtpchrono                  as character initial ? extent 5             serialize-hidden
    field tbNochrono                  as integer   initial ? extent 5             serialize-hidden
    // gestion des mises à jour
    field cdmaj                as integer   format "9"
    field cdori                as character format "x"
    field cNomTable            as character initial ?                                                 //equit, aquit, pquit, daquit, equitrev

    field dtTimestamp          as datetime
    field CRUD                 as character
    field rRowid               as rowid

    //index Ix_ttQtt01 is unique primary noloc iNoQuittanceFusionnee noqtt
    //index Ix_ttQtt02 noloc msqtt noqtt
    //index Ix_ttQtt03 noloc noqtt msqtt
.
