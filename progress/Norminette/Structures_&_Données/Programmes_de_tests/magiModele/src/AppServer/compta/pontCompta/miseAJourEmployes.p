/*------------------------------------------------------------------------
File        : miseAJourEmployes.p
Purpose     : Mise à jour Tiers Personnel en compta ADB
Author(s)   : ofa  -  2018/05/29 
Notes       : vient de cadb/src/gestion/majempl.p
--------------------------------------------------------------------------
| 001  |   24/11/99 |   CC   | Prise en compte de la modification sur csscpt|
| 002  |   19/01/00 |   OF   | Pour la modif precedente, il faut que l'en-  |
|      |            |        | registrement de csscpt soit en EXCLUSIVE-LOCK|
| 003  | 28/08/2003 |  PBP   | 0803/0259 No voie dans cAdresse sur 8 caracteres.|
| 004  | 04/11/2008 |   SY   | 1008/0256 Des salariés ont été créés avec    |
|      |            |        | le Mandat sur 5 chiffres mais c'est          |
|      |            |        | incompatible avec iempl.cpt-cd et            |
|      |            |        | iempl.empl-cle                               |
| 005  | 06/07/2011 |   NP   | 0208/0216 new gestion SEPA que Iban + Bic    |
| 006  | 23/10/2012 |   SY   | 1012/0139 Modification formatage adresse     |
|      |            |        | salarié (incliadb.i, majempl.i)              |
| 007  | 27/03/2013 |   OF   | 1209/0091 Ajout MAJ email + mode d'envoi     |
|      |            |        |                                              |
---------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{compta/include/csscpt.i}
{compta/include/ccpt.i}
{compta/include/iempl.i}
{application/include/glbsepar.i}
define input  parameter poCollection    as collection no-undo.
define output parameter ViRetour-Ou     as integer    no-undo.

define variable viNumeroSociete     like isoc.soc-cd            no-undo.
define variable viNumeroMandat      like isoc.soc-cd            no-undo.
define variable vcNumeroCompte      like iempl.cpt-cd           no-undo.
define variable vcCodeCollectif     like csscptcol.sscoll-cpt   no-undo.
define variable vcNumeroSousCompte  as character format "X(5)"  no-undo.
define variable vcNom               like iempl.nom              no-undo.
define variable vcPrenom            like iempl.prenom           no-undo.
define variable vcCleEmploye    like iempl.empl-cle             no-undo.
define variable vcCodeReglement     as character format "X(1)"  no-undo.
define variable viRaisonSociale     like iempl.librais-cd       no-undo.
define variable vcTelephone         like iempl.tel              no-undo.
define variable vcAdresse           as character format "X(64)" no-undo.
define variable vcVille             like iempl.ville            no-undo.
define variable vcCodePostal        like iempl.cp               no-undo.
define variable vcTitulaireIban     as character format "X(32)" no-undo.
define variable vcDomiciliationIban as character format "X(32)" no-undo.
define variable vcIBAN              like iempl.iban             no-undo.
define variable vcBIC               like iempl.bic              no-undo.
define variable vcEmail             like iempl.email            no-undo.
define variable vcTpMode            like iempl.tpmod            no-undo.
define variable vhProc              as handle                   no-undo.

define buffer ccpt for ccpt.
define buffer iempl for iempl.
define buffer csscpt for csscpt.
define buffer csscptcol for csscptcol.
define buffer aparm for aparm.
define buffer actrc for actrc.
define buffer ccptcol for ccptcol.

assign 
    viNumeroSociete     = poCollection:getinteger("iNumeroSociete")
    viNumeroMandat      = poCollection:getinteger("iNumeroMandat")
    vcNumeroCompte      = poCollection:getCharacter("cNumeroCompte")
    vcCodeCollectif     = poCollection:getCharacter("cCodeCollectif")
    vcNumeroSousCompte  = poCollection:getCharacter("cNumeroSousCompte")
    vcCleEmploye        = poCollection:getCharacter("cCleEmploye")
    vcNom               = poCollection:getCharacter("cNom")
    vcPrenom            = poCollection:getCharacter("cPrenom")
    vcCodeReglement     = poCollection:getCharacter("cCodeReglement")
    viRaisonSociale     = poCollection:getinteger("iRaisonSociale")
    vcTelephone         = poCollection:getCharacter("cTelephone")
    vcAdresse           = poCollection:getCharacter("cAdresse")
    vcCodePostal        = poCollection:getCharacter("cCodePostal")
    vcVille             = poCollection:getCharacter("cVille")
    vcTitulaireIban     = poCollection:getCharacter("cTitulaireIban")
    vcDomiciliationIban = poCollection:getCharacter("cDomiciliationIban")
    vcIBAN              = poCollection:getCharacter("cIBAN")
    vcBIC               = poCollection:getCharacter("cBIC")
    vcEmail             = poCollection:getCharacter("cEmail")
    vcTpMode            = poCollection:getCharacter("cTpMode")
.

empty temp-table ttIempl.
empty temp-table ttCcpt.
empty temp-table ttCsscpt.

find first iempl no-lock
    where iempl.soc-cd = viNumeroSociete
    and   integer(iempl.empl-cle) = integer(vcCleEmploye) no-error.

create ttIempl.
assign 
    ttIempl.soc-cd     = viNumeroSociete
    ttIempl.etab-cd    = 0
    ttIempl.empl-cle   = vcCleEmploye
    ttIempl.dacreat    = today
    ttIempl.cpt-cd     = vcNumeroCompte
    ttIempl.nom        = vcNom
    ttIempl.cp         = vcCodePostal
    ttIempl.ville      = vcVille
    ttIempl.tel        = vcTelephone
    ttIempl.damodif    = today
    ttIempl.domicil[1] = vcTitulaireIban
    ttIempl.domicil[2] = vcDomiciliationIban
    ttIempl.iban       = vcIBAN
    ttIempl.bic        = vcBIC
    ttIempl.prenom     = vcPrenom
    ttIempl.librais-cd = viRaisonSociale
    ttIempl.email      = vcEmail 
    ttIempl.CRUD       = string(available iempl,'U/C')
. 
if available iempl then
    assign
        ttIempl.dtTimestamp = datetime(iempl.damod, iempl.ihmod)
        ttIempl.rRowid      = rowid(iempl)
    .
if vcTpMode ne "" then
    ttIempl.tpmod = outilTraduction:getLibelleProg("MDENV", vcTpMode).

if num-entries(vcAdresse , separ[4]) >= 2 then
    assign
        ttIempl.adr[1] = trim(entry(1, vcAdresse, separ[4]))
        ttIempl.adr[2] = trim(entry(2, vcAdresse, separ[4]))
    .  
else
    assign
        ttIempl.adr[1] = substitute("&1&2", trim(string(INT(substring(vcAdresse,1,8))), substring(vcAdresse,9,32)))
        ttIempl.adr[2] = trim(substring(vcAdresse,33,32))
    .

find first aparm no-lock
    where aparm.soc-cd = 0
    and   aparm.etab-cd = 0
    and   aparm.tppar = "TREGP"
    and   aparm.cdpar = vcCodeReglement no-error.
if not available aparm then
    find first aparm no-lock
        where aparm.soc-cd = 0
        and   aparm.etab-cd = 0   
        and   aparm.tppar = "TREGP"
        and   aparm.cdpar = "C" no-error.
ttIempl.regl-cd = if available aparm then aparm.zone1 else 300.

find first csscptcol no-lock 
    where csscptcol.soc-cd     = viNumeroSociete
    and   csscptcol.etab-cd    = viNumeroMandat 
    and   csscptcol.sscoll-cpt = vcCodeCollectif no-error.
if available csscptcol then do:
    ttIempl.coll-cle = csscptcol.coll-cle.
    find first ccpt no-lock 
        where ccpt.soc-cd   = iempl.soc-cd   
          and ccpt.coll-cle = csscptcol.coll-cle 
          and ccpt.cpt-cd   = vcNumeroSousCompte no-error.
    if not available ccpt then do:
        create ttCcpt.
        assign
            ttCcpt.soc-cd        = viNumeroSociete
            ttCcpt.etab-cd       = 0
            ttCcpt.coll-cle      = csscptcol.coll-cle
            ttCcpt.cpt-cd        = vcNumeroSousCompte
            ttCcpt.cpt2-cd       = ""
            ttCcpt.lib           = " "
            ttCcpt.libtype-cd    = 1
            ttCcpt.cpt-int       = ccpt.coll-cle + ccpt.cpt-cd
            ttCcpt.type          = yes
            ttCcpt.sscpt-cd      = vcNumeroSousCompte
            ttCcpt.CRUD          = "C"
        .
        find first actrc no-lock
            where actrc.cptdeb <= csscptcol.sscoll-cpt 
            and   actrc.cptfin >= csscptcol.sscoll-cpt no-error.
        if available actrc then 
            assign 
                ttCcpt.fg-libsoc = actrc.fg-libsoc
                ttCcpt.type-cd   =  actrc.type-cd
                .
        else ViRetour-Ou = 3.

        find first ccptcol no-lock
            where ccptcol.soc-cd = ccpt.soc-cd
            and   ccptcol.coll-cle = ccpt.coll-cle no-error.
        if available ccptcol then
            assign 
                ttCcpt.libcat-cd   = ccptcol.libcat-cd
                ttCcpt.libsens-cd  = ccptcol.libsens-cd
                ttCcpt.libtype-cd  = ccptcol.libtype-cd
                ttCcpt.libimp-cd   = ccptcol.libimp-cd
                ttCcpt.centra      = ccptcol.centra
                ttCcpt.cptaffect   = ccptcol.cptaffect
                ttCcpt.cptprov-num = ccptcol.cptprov-num
                ttCcpt.fg-mandat   = ccptcol.fg-mandat
                .   
        else ViRetour-Ou = 2.
    end.

    find first csscpt no-lock
        where csscpt.soc-cd = viNumeroSociete
        and   csscpt.etab-cd = viNumeroMandat
        and   csscpt.sscoll-cle = csscptcol.sscoll-cle
        and   csscpt.cpt-cd = ccpt.cpt-cd no-error.
    create ttCsscpt.
    assign 
        ttCsscpt.soc-cd     = viNumeroSociete
        ttCsscpt.etab-cd    = viNumeroMandat
        ttCsscpt.coll-cle   = ccpt.coll-cle
        ttCsscpt.sscoll-cle = csscptcol.sscoll-cle
        ttCsscpt.cpt-cd     = ccpt.cpt-cd
        ttCsscpt.lib        = substitute("&1 &2", iempl.nom, iempl.prenom)
        ttCsscpt.CRUD       = string(available csscpt,'U/C')
        .
    if available csscpt then
        assign
            ttCsscpt.cpt-int     = substitute("&1&2",csscptcol.sscoll-cpt, csscpt.cpt-cd)
            ttCsscpt.dtTimestamp = datetime(csscpt.damod, csscpt.ihmod)
            ttCsscpt.rRowid      = rowid(csscpt)
        .

    run crud/iempl_CRUD.p persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    run setIempl in vhProc(table ttIempl by-reference).
    run destroy in vhProc.

    run crud/ccpt_CRUD.p persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    run setCcpt in vhProc(table ttCcpt by-reference).
    run destroy in vhProc.

    run crud/csscpt_CRUD.p persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    run setCsscpt in vhProc(table ttCsscpt by-reference).
    run destroy in vhProc.
 end.
 else 
   ViRetour-Ou = 1.
