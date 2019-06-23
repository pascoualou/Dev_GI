/*------------------------------------------------------------------------
File        : miseAJourFournisseursLoyer.p
Purpose     : Création d'un Fournisseur de Loyers en Compta PME à partir du Tiers Bailleur de l'ADB
Author(s)   : ofa  -  2018/05/29 
Notes       : vient de cadb/src/gestion/majflo.p
TODO: gestion du fichier LOG
--------------------------------------------------------------------------
| 001  |  14/11/01  |  LG    | Erreur sur rib                               |
| 002  |  15/07/02  |  LG    | 0602/1183 - controle sur compte individuel   |
| 003  |  29/10/07  |  RF    | 0707/1129 - Fournisseurs multiref            |
| 004  | 19/09/2008 |  DM    | 0608/0065 : Mandat 5 chiffres                |
| 005  |  05/12/08  |  SY    | 1208/0027 : suite fiche 1206/0220            |
|      |            |        | Gestion séparée No téléphone et no portable  |
|      |            |        |                                              |
+---------------------------------------------------------------------------*/

using parametre.pclie.parametrageMandat5Chiffres.
using parametre.pclie.parametrageFournisseurLoyer.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{preprocesseur/type2role.i}
{preprocesseur/mode2gestionFournisseurLoyer.i}
{crud/include/ifour.i}
{crud/include/iribfour.i}
{crud/include/ifouetab.i}
{compta/include/ccpt.i}
{compta/include/csscpt.i}
{compta/include/csscptcol.i}
{crud/include/ilibrais.i}

define input  parameter piNumeroSocieteADB     like isoc.soc-cd no-undo.
define input  parameter piNumeroRoleBailleur   as integer       no-undo. 
define output parameter plErreur               as logical       no-undo.

define variable voMandat5Chiffres           as class parametrageMandat5Chiffres  no-undo.
define variable voFournisseurLoyer          as class parametrageFournisseurLoyer no-undo.
define variable vcRaisonSocialeFournisseur  as integer no-undo.
define variable vcMessageErreur             as character no-undo.
define variable vcNomFournisseur            as character no-undo.
define variable vcNumeroCompte              as character no-undo.
define variable vcFormatMandat              as character no-undo.
define variable vcRepertoireTmp             as character no-undo.
//define stream stErreur.  TODO: voir comment on gère les fichiers d'erreur
define buffer vbRoles for roles.
define buffer iscimdt for iscimdt.
define buffer ietab   for ietab.
define buffer ccptcol for ccptcol.
function test-compte return logical private (piNumeroSocieteSCI as integer, piNumeroEtablissementSCI as integer, piNumeroMandat as integer, pcNumeroRoleBailleur as character, piTypeRole as integer) forward.

assign
    voMandat5Chiffres   = new parametrageMandat5Chiffres()
    vcFormatMandat      = if voMandat5Chiffres:isDbParameter then "99999" else "9999"
    voFournisseurLoyer  = new parametrageFournisseurLoyer()
    vcRepertoireTmp     = substitute("&1&3&2", right-trim(replace(mToken:getValeur('REPGI'), "/", outils:separateurRepertoire()), outils:separateurRepertoire())
                                             , substitute("gest&1tmp", outils:separateurRepertoire())
                                             , outils:separateurRepertoire())
.
delete object voMandat5Chiffres.
//output stream stErreur to value(vcRepertoireTmp + "pmeflo.err") append.

if not voFournisseurLoyer:isDbParameter
then do :
    /*put stream stErreur substitute("Parametres Fournisseurs de Loyers Inexistants pour la référence &1", piNumeroSocieteADB) skip.
    output STREAM stErreur CLOSE.*/
    plErreur = true.
    mError:createError({&error}, substitute("Parametres Fournisseurs de Loyers Inexistants pour la référence &1", piNumeroSocieteADB)).
end.

if plErreur then return.

find first vbRoles no-lock
    where vbRoles.tprol = {&TYPEROLE-bailleur}
    and   vbRoles.norol = piNumeroRoleBailleur no-error.
if available vbRoles
then do :

    find first iscimdt no-lock 
        where iscimdt.soc-cd = 70000
        and   iscimdt.etab-cd = integer(truncate(vbRoles.norol / 100000, 0)) no-error.
    if available iscimdt 
    then do :
    
        find first ietab no-lock
            where ietab.soc-cd = iscimdt.soc-sci no-error.
        find first ccptcol no-lock
            where ccptcol.soc-cd = iscimdt.soc-sci
            and   ccptcol.tprole = integer({&TYPEROLE-fournisseur}) no-error.
        if not available ccptcol 
        then do :
            /*put stream stErreur substitute("Il manque le collectif de type &1 sur la société &2", {&TYPEROLE-fournisseur}, iscimdt.soc-sci) skip.
            output STREAM stErreur CLOSE.*/
            plErreur = true.
            mError:createError({&error}, substitute("Il manque le collectif de type &1 sur la société &2", {&TYPEROLE-fournisseur}, iscimdt.soc-sci)).
            return.
        end.
        vcNumeroCompte = if voFournisseurLoyer:getCodeModele() = {&MODELE-ResidenceLocative-ComptaSociete} then string(piNumeroRoleBailleur, substitute("&1&2",vcFormatMandat, "99999")) //Compte ADB classique
                         else string(vbRoles.notie,"99999"). //Numero de tiers
        plErreur = true.
        if not test-compte(iscimdt.soc-sci,                                 // Ste PME
                           ietab.etab-cd,                                   // Etab PME
                           iscimdt.etab-cd,                                 // Numero Mdt
                           string(piNumeroRoleBailleur, "9999999999"  ),    // Mandat+Cpt
                           integer({&TYPEROLE-locataire}) 
                           ) then leave.
        plErreur = false.
    end.
    else do :
        //put stream stErreur substitute("Il manque le paramètre SCI pour la référence &1 et le mandat &2", piNumeroSocieteADB, truncate(vbRoles.norol / 100000, 0)) skip.
        plErreur = true. 
        mError:createError({&error}, substitute("Il manque le paramètre SCI pour la référence &1 et le mandat &2", piNumeroSocieteADB, truncate(vbRoles.norol / 100000, 0))).
    end.
end.
else do :
    //put stream stErreur substitute("Le rôle &1 n'existe pas pour la référence &2", piNumeroRoleBailleur, piNumeroSocieteADB) skip.
    plErreur = true.
    mError:createError({&error}, substitute("Le rôle &1 n'existe pas pour la référence &2", piNumeroRoleBailleur, piNumeroSocieteADB)).
end.

//output STREAM stErreur CLOSE.

procedure getNomEtCiviliteTiers private:
    /*------------------------------------------------------------------------------
    Purpose: Découpage du nom complet en civilité (raison sociale) + nom
    Notes  : Ancienne procédure getNomEtCiviliteTiers
    Param entrée : ENTRY(1,LstAdr,"¤")=Civilité + NOM + PRENOM
    ------------------------------------------------------------------------------*/
    define input parameter  pcNomComplet        as character no-undo.
    define output parameter piCodeRaisonSociale as integer   no-undo.
    define output parameter pcNom               as character no-undo.

    if pcNomComplet begins "Monsieur ou Madame" 
    or pcNomComplet begins "M et MME"
    or pcNomComplet begins "M ou MME"
    or pcNomComplet begins "Monsieur et Madame"
    or pcNomComplet begins "M et MLE"
    or pcNomComplet begins "M ou MLE" then
        assign 
            piCodeRaisonSociale = 12
            pcNom = substring(pcNomComplet,length(entry(1,pcNomComplet," ")) 
                                         + length(entry(2,pcNomComplet," "))
                                         + length(entry(3,pcNomComplet," ")) + 4)
        .
    else if pcNomComplet begins "Monsieur"      then piCodeRaisonSociale = 10.
    else if pcNomComplet begins "Docteur" 
         or pcNomComplet begins "DCT"           then piCodeRaisonSociale = 10.
    else if pcNomComplet begins "Madame"        then piCodeRaisonSociale = 11.
    else if pcNomComplet begins "Mademoiselle " then piCodeRaisonSociale = 13.
    else if pcNomComplet begins "Société"       then piCodeRaisonSociale = 1.
    else if pcNomComplet begins "Maître"        then piCodeRaisonSociale = 14.
    else if pcNomComplet begins "Compagnie"     then piCodeRaisonSociale = 31.
    else if pcNomComplet begins "Etablissement" then piCodeRaisonSociale = 51.
    else if pcNomComplet begins "Entreprise"    then piCodeRaisonSociale = 50.
    else if pcNomComplet begins "Association"   then piCodeRaisonSociale = 21.
    else if pcNomComplet begins "Cabinet"       then piCodeRaisonSociale = 30.
    else if pcNomComplet begins "Etude"         then piCodeRaisonSociale = 52.
    else if pcNomComplet begins "Agence"        then piCodeRaisonSociale = 20.
    else if pcNomComplet begins "S.C.I."        then piCodeRaisonSociale = 5.
    else if pcNomComplet begins "S.N.C."        then piCodeRaisonSociale = 6.
    else 
        assign 
            piCodeRaisonSociale = 999
            pcNom               = pcNomComplet
        .

    if piCodeRaisonSociale ne 999 and piCodeRaisonSociale ne 12 then pcNom = substring(pcNomComplet,length(entry(1,pcNomComplet," ")) + 2).

end procedure.

function test-compte return logical private (piNumeroSocieteSCI as integer, piNumeroEtablissementSCI as integer, piNumeroMandat as integer, pcNumeroRoleBailleur as character, piTypeRole as integer):
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable viCodeTaxe                  as integer   no-undo.
    define variable vcCodeRetour                as character no-undo.
    define variable vcRetourModeReglementEtIban as character no-undo.
    define variable vcModeReglement             as character no-undo.
    define variable vcCodePays                  as character no-undo.
    define variable vhProc                      as handle    no-undo.
    define variable voCollection as class collection no-undo.

    define buffer csscptcol for csscptcol.
    define buffer ccptcol   for ccptcol.
    define buffer csscpt    for csscpt.
    define buffer iempl     for iempl.
    define buffer ifour     for ifour.
    define buffer ilibpays  for ilibpays.
    define buffer ifam      for ifam.
    define buffer issfam    for issfam.
    define buffer itaxe     for itaxe.
    define buffer iribfour  for iribfour.

    find first csscptcol no-lock
        where csscptcol.soc-cd = piNumeroSocieteSCI
        and   csscptcol.etab-cd = piNumeroEtablissementSCI
        and   csscptcol.sscoll-cle = "FL" no-error.
    if not available csscptcol then do:
        // Il manque le collectif &1 pour la societe &2 et l'etablissement &3
        //put stream stErreur unformatted substitute(outilTraduction:getLibelleCompta(106759),"FL",piNumeroSocieteSCI,piNumeroEtablissementSCI) skip.
        mError:createError({&error}, substitute(outilTraduction:getLibelleCompta(106759),"FL",piNumeroSocieteSCI,piNumeroEtablissementSCI)).
        return false.
    end.

    if pcNumeroRoleBailleur = "" then do:
        //put stream stErreur unformatted outilTraduction:getLibelleCompta(106961) skip. //Compte incorrect
        mError:createError({&error}, outilTraduction:getLibelleCompta(106961)).
        return false.
    end.

    find first ccptcol no-lock
        where ccptcol.soc-cd = csscptcol.soc-cd
        and   ccptcol.coll-cle = csscptcol.coll-cle no-error.
    if not available ccptcol then do:
        //Il manque le regroupement &1 pour la société &2 et l'établissement &3"
        //put stream stErreur unformatted substitute(outilTraduction:getLibelleCompta(1000760),csscptcol.coll-cle,piNumeroSocieteSCI,piNumeroEtablissementSCI) skip.
        mError:createError({&error}, substitute(outilTraduction:getLibelleCompta(1000760),csscptcol.coll-cle,piNumeroSocieteSCI,piNumeroEtablissementSCI)).
        return false.
    end.

    if can-find(first csscpt no-lock
                where csscpt.soc-cd     = piNumeroSocieteSCI
                and   csscpt.etab-cd    = piNumeroEtablissementSCI
                and   csscpt.coll-cle   = csscptcol.coll-cle
                and   csscpt.sscoll-cle <> csscptcol.sscoll-cle
                and   csscpt.cpt-cd     = vcNumeroCompte)
    then do :
        //Le compte &1 existe déjà pour un autre collectif de la société &2 et l'établissement &3.
        //put stream stErreur unformatted substitute(outilTraduction:getLibelleCompta(1000760),vcNumeroCompte,piNumeroSocieteSCI,piNumeroEtablissementSCI) skip.
        mError:createError({&error}, substitute(outilTraduction:getLibelleCompta(1000761),vcNumeroCompte,piNumeroSocieteSCI,piNumeroEtablissementSCI)).
        return false.
    end.

    voCollection = new collection().
    run adb/cpta/chgadr01.p persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    voCollection:set("pcTpRolUse", string(piTypeRole,"99999")) no-error. 
    voCollection:set("pcCdFndUse", "") no-error.
    voCollection:set("piNoRolUse", int64(pcNumeroRoleBailleur)) no-error.
    voCollection:set("piNoCttUse", piNumeroMandat) no-error.
    voCollection:set("piCdLngSes", mtoken:iCodeLangueSession) no-error.
    run lancementChgadr01 in vhProc (input-output voCollection). 
    run destroy in vhProc.
    run adb/cpta/modeReglementEtIbanDuRole.p(
                             piNumeroSocieteADB,
                             piNumeroMandat,
                             string(piTypeRole, "99999"),
                             integer(pcNumeroRoleBailleur),
                             "",
                             output vcCodeRetour,
                             output vcRetourModeReglementEtIban).
    assign
        vcModeReglement = entry(1,vcRetourModeReglementEtIban,"|")
        vcRetourModeReglementEtIban  = entry(2,vcRetourModeReglementEtIban,"|") when num-entries(vcRetourModeReglementEtIban,"|") >= 2
        .

    find first ilibpays no-lock
        where ilibpays.soc-cd = piNumeroSocieteSCI
        and   ilibpays.libpays-cd = (if voCollection:getCharacter("CdCodPay") <> ?  
                                     then string(voCollection:getCharacter("CdCodPay"), "999") 
                                     else "001") no-error.
    vcCodePays = if available ilibpays then ilibpays.libpays-cd
                 else "001".

    if ccptcol.libtier-cd = 2 then do:
        find first ifour no-lock 
            where ifour.soc-cd = piNumeroSocieteSCI
            and   ifour.four-cle = vcNumeroCompte no-error.
        create ttIfour.
        if available ifour then
            assign
                ttIfour.dtTimestamp = datetime(ifour.damod, ifour.ihmod)
                ttIfour.rRowid      = rowid(ifour)
            .
        run getNomEtCiviliteTiers(if voCollection:getCharacter("NmTieCpl") <> ? then voCollection:getCharacter("NmTieCpl") else "", output vcRaisonSocialeFournisseur, output vcNomFournisseur).
        if not can-find(first ilibrais no-lock
                        where ilibrais.soc-cd = piNumeroSocieteSCI
                        and   ilibrais.etab-cd = piNumeroEtablissementSCI
                        and   ilibrais.librais-cd = 999)
        then do:
            //CRUD inutile pour cette table de paramétrage très rarement mise à jour
            create ttIlibrais.
            assign
                ttIlibrais.soc-cd       = piNumeroSocieteSCI
                ttIlibrais.etab-cd      = piNumeroEtablissementSCI
                ttIlibrais.librais-cd   = 999
                ttIlibrais.lib          = "-"
                ttIlibrais.CRUD         = "C"
                .
        end.
        find first ifam no-lock 
            where ifam.soc-cd = piNumeroSocieteSCI
            and   ifam.etab-cd = piNumeroEtablissementSCI
            and   ifam.libtier-cd = 2 no-error.
        find first issfam no-lock 
            where issfam.soc-cd = piNumeroSocieteSCI
            and   issfam.etab-cd = piNumeroEtablissementSCI
            and   issfam.libtier-cd = 2
            and   issfam.fam-cd = ifam.fam-cd no-error.
        assign  
            ttIfour.soc-cd          = piNumeroSocieteSCI
            ttIfour.four-cle        = vcNumeroCompte
            ttIfour.libtier-cd      = 2
            ttIfour.clegroup        = ""
            ttIfour.coll-cle        = ccptcol.coll-cle
            ttIfour.cpt-cd          = vcNumeroCompte
            ttIfour.librais-cd      = vcRaisonSocialeFournisseur
            ttIfour.nom             = vcNomFournisseur
            ttIfour.adr[1]          = voCollection:getCharacter("LbAdr001") when voCollection:getCharacter("LbAdr001") <> ?
            ttIfour.adr[2]          = voCollection:getCharacter("LbAdr002") when voCollection:getCharacter("LbAdr002") <> ?
            ttIfour.adr[3]          = voCollection:getCharacter("LbCvtTie") when voCollection:getCharacter("LbCvtTie") <> ?
            ttIfour.cp              = voCollection:getCharacter("LbCodPos") when voCollection:getCharacter("LbCodPos") <> ?
            ttIfour.ville           = voCollection:getCharacter("LbNomVil") when voCollection:getCharacter("LbNomVil") <> ?
            ttIfour.tel             = voCollection:getCharacter("NoTelTie") when voCollection:getCharacter("NoTelTie") <> ?
            ttIfour.telex           = voCollection:getCharacter("NoPorTie") when voCollection:getCharacter("NoPorTie") <> ?
            ttIfour.fax             = voCollection:getCharacter("NoFaxTie") when voCollection:getCharacter("NoFaxTie") <> ?
            ttIfour.libpays-cd      = vcCodePays
            ttIfour.siret           = "00000000000000"
            ttIfour.ape             = ""
            ttIfour.tvacee-cle      = ""
            ttIfour.tiers-declar    = ""
            ttIfour.damodif         = today
            ttIfour.fam-cd          = ifam.fam-cd when available ifam
            ttIfour.ssfam-cd        = issfam.ssfam-cd when available issfam
            ttIfour.type-four       = "F"
            ttIfour.dev-cd          = ietab.dev-cd when available ietab
            ttIfour.libass-cd       = 1
            ttIfour.liblang-cd      = 1
            ttIfour.regl-cd         = (if vcModeReglement = "V" then 700 else (if vcModeReglement = "P" then 500 else 300))
            ttIfour.CRUD            = string(available ifour,"U/C")
            .
        delete object voCollection.             
        // Compte Individuel ADB
        find first ccpt no-lock
            where ccpt.soc-cd = piNumeroSocieteSCI
            and   ccpt.coll-cle = csscptcol.coll-cle 
            and   ccpt.cpt-cd = vcNumeroCompte no-error.
        create ttCcpt.
        if not available ccpt then 
            assign
                ttCcpt.dtTimestamp = datetime(ccpt.damod, ccpt.ihmod)
                ttCcpt.rRowid      = rowid(ccpt)
            .

        if ccptcol.libcat-cd = 2 
        then
            for first itaxe no-lock
                where itaxe.soc-cd = piNumeroSocieteSCI 
                and   itaxe.port-emb = true:
                viCodeTaxe = itaxe.taxe-cd.
            end.

        assign
          TtCcpt.soc-cd        = piNumeroSocieteSCI
          TtCcpt.etab-cd       = 0
          TtCcpt.cpt-cd        = vcNumeroCompte
          TtCcpt.libtype-cd    = ccptcol.libtype-cd
          TtCcpt.centra        = ccptcol.centra
          TtCcpt.libcat-cd     = ccptcol.libcat-cd
          TtCcpt.cptaffect     = ccptcol.cptaffect
          TtCcpt.tva-oblig     = false
          TtCcpt.cptprov-num   = ccptcol.cptprov-num
          TtCcpt.cpt-int       = ccptcol.coll-cle + ccpt.cpt-cd
          TtCcpt.coll-cle      = ccptcol.coll-cle
          TtCcpt.taxe-cd       = viCodeTaxe
          TtCcpt.libimp-cd     = ccptcol.libimp-cd
          TtCcpt.libsens-cd    = ccptcol.libsens-cd
          TtCcpt.sscpt-cd      = vcNumeroCompte
          TtCcpt.lib           = ifour.nom
          TtCcpt.CRUD          = string(available ccpt,"U/C")
          .

        find first csscpt no-lock
             where csscpt.soc-cd = piNumeroSocieteSCI
             and   csscpt.etab-cd = piNumeroEtablissementSCI
             and   csscpt.sscoll-cle = csscptcol.sscoll-cle
             and   csscpt.cpt-cd = vcNumeroCompte no-error.
        create ttCsscpt.
        if not available csscpt then 
            assign
                ttCsscpt.dtTimestamp = datetime(csscpt.damod, csscpt.ihmod)
                ttCsscpt.rRowid      = rowid(csscpt)
            .

        assign
            TtCsscpt.soc-cd       = piNumeroSocieteSCI
            TtCsscpt.etab-cd      = piNumeroEtablissementSCI
            TtCsscpt.sscoll-cle   = csscptcol.sscoll-cle
            TtCsscpt.cpt-cd       = vcNumeroCompte
            TtCsscpt.cpt-int      = csscptcol.sscoll-cpt + vcNumeroCompte
            TtCsscpt.coll-cle     = csscptcol.coll-cle
            TtCsscpt.facturable   = csscptcol.facturable
            TtCsscpt.douteux      = csscptcol.douteux
            TtCsscpt.numerateur   = 0
            TtCsscpt.denominateur = 0
            TtCsscpt.lib          = ccpt.lib
            TtCsscpt.CRUD         = string(available csscpt,"U/C")
        .

        find first ifouetab no-lock 
            where ifouetab.soc-cd = piNumeroSocieteSCI
            and   ifouetab.etab-cd = piNumeroEtablissementSCI
            and   ifouetab.four-cle = ifour.four-cle no-error.
        create ttIfouetab.
        if not available ifouetab then 
            assign
                //ttIfouetab.dtTimestamp = datetime(ifouetab.damod, ifouetab.ihmod) Pas de champs damod et ihmod
                ttIfouetab.rRowid      = rowid(ifouetab)
            .
        assign
            ttIfouetab.soc-cd   = piNumeroSocieteSCI
            ttIfouetab.etab-cd  = piNumeroEtablissementSCI
            ttIfouetab.four-cle = vcNumeroCompte
            ttIfouetab.CRUD     = string(available csscpt,"U/C")
        .

        if entry(1,vcRetourModeReglementEtIban,"@") ne "" then do:
            find first iribfour no-lock
                where iribfou.soc-cd = ifour.soc-cd
                and   iribfou.four-cle = ifour.four-cle 
                and   iribfour.ordre-num = 1 no-error.
            create TtIribfour.
            if not available iribfour then 
                assign
                    TtIribfour.dtTimestamp = datetime(iribfour.damod, iribfour.ihmod)
                    TtIribfour.rRowid      = rowid(iribfour)
                .

            assign   
                TtIribfour.soc-cd     = ifour.soc-cd
                TtIribfour.etab-cd    = ifour.etab-cd
                TtIribfour.four-cle   = ifour.four-cle
                TtIribfour.ordre-num  = 1
                TtIribfour.bque       = entry(3,vcRetourModeReglementEtIban,"@") when num-entries(vcRetourModeReglementEtIban,"@") >= 3
                TtIribfour.guichet    = entry(4,vcRetourModeReglementEtIban,"@") when num-entries(vcRetourModeReglementEtIban,"@") >= 4
                TtIribfour.rib        = entry(6,vcRetourModeReglementEtIban,"@") when num-entries(vcRetourModeReglementEtIban,"@") >= 6
                TtIribfour.domicil[1] = entry(2,vcRetourModeReglementEtIban,"@") when num-entries(vcRetourModeReglementEtIban,"@") >= 2
                TtIribfour.domicil[2] = entry(1,vcRetourModeReglementEtIban,"@")
                TtIribfour.cpt        = entry(5,vcRetourModeReglementEtIban,"@") when num-entries(vcRetourModeReglementEtIban,"@") >= 5
                TtIribfour.edition    = true
                TtIribfour.bque-nom   = entry(1,vcRetourModeReglementEtIban,"@")
                TtIribfour.etr        = false
                TtIribfour.CRUD     = string(available iribfour,"U/C")
                .
        end.
        else do :
            find first iribfour no-lock
                where iribfour.soc-cd = ifour.soc-cd
                and   iribfour.four-cle = ifour.four-cle
                and   iribfour.ordre-num = 1 no-error.
            create TtIribfour.
            assign   
                TtIribfour.soc-cd   = ifour.soc-cd
                TtIribfour.etab-cd  = ifour.etab-cd
                TtIribfour.four-cle = ifour.four-cle
                TtIribfour.rRowid   = rowid(iribfour)
                TtIribfour.CRUD     = "D"
            .
        end.

        run crud/iribfour_CRUD.p persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        run setIribfour in vhProc(table TtIribfour by-reference).
        run destroy in vhProc.

        run crud/ifour_CRUD.p persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        run setifour in vhProc(table Ttifour by-reference).
        run destroy in vhProc.

        run crud/ifouetab_CRUD.p persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        run setIfouetab in vhProc(table TtIfouetab by-reference).
        run destroy in vhProc.

        run crud/ccpt_CRUD.p persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        run setCcpt in vhProc(table TtCcpt by-reference).
        run destroy in vhProc.

        run crud/csscpt_CRUD.p persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        run setCsscpt in vhProc(table TtCsscpt by-reference).
        run destroy in vhProc.

        run crud/ilibrais_CRUD.p persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        run setIlibrais in vhProc(table TtIlibrais by-reference).
        run destroy in vhProc.
    end.       

    return true.

end function.
 