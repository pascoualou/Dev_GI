/*------------------------------------------------------------------------
File        : outilFormatage.cls
Purpose     : classe singleton des outils de formatage
Author(s)   : kantena - 2016/12/06
Notes       :
----------------------------------------------------------------------*/
{preprocesseur/famille2tiers.i}
{preprocesseur/nature2voie.i}
{preprocesseur/type2adresse.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/unite2surface.i}

using parametre.pclie.parametrageReferenceGeranceCopro.
using outils.outilTraduction.

class outils.outilFormatage use-widget-pool final:
    /*------------------------------------------------------------------------------
    purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define public static property mToken as class oerealm.token no-undo get. set.

    method public static character getNomFour(pcCodeRegroupement as character, piNumeroCompte as int64):
        /*------------------------------------------------------------------------------
        purpose: retourne le nom d'un fournisseur ou organisme social sur la référence principale
        notes  :
        ------------------------------------------------------------------------------*/
        if piNumeroCompte = ? then return "".
        return getNomFour(pcCodeRegroupement, piNumeroCompte, "").

    end method.

    method public static character getNomFour(pcCodeRegroupement as character, piNumeroCompte as int64, pcTypeContrat as character):
    /*------------------------------------------------------------------------------
    purpose: retourne le nom d'un fournisseur ou organisme social sur la référence passée en paramètre
    Notes  : Ancienne fonction FrmTie1 de adb/comm/fctgene.i
    ------------------------------------------------------------------------------*/
        define variable viNumeroSociete as integer   no-undo.

        define buffer CcptCol for CcptCol.
        define buffer ifour   for ifour.

        if piNumeroCompte = ? then return "".

        viNumeroSociete = mtoken:getSociete(pcTypeContrat).
        return getNomFour(pcCodeRegroupement, piNumeroCompte, viNumeroSociete).

    end method.

    method public static character getNomFour(piNumeroCompte as int64, pcTypeRole as integer):
    /*------------------------------------------------------------------------------
    purpose: retourne le nom d'un fournisseur ou organisme social sur la référence passée en paramètre
    Notes  : Ancienne fonction FrmTie1 de adb/comm/fctgene.i
    ------------------------------------------------------------------------------*/
        define variable viNumeroSociete as integer   no-undo.

        define buffer CcptCol for CcptCol.
        define buffer ifour   for ifour.

        if piNumeroCompte = ? then return "".

        for first ccptCol no-lock
            where ccptcol.soc-cd = integer(mtoken:cRefPrincipale)
              and ccptcol.tprol  = pcTypeRole
          , first ifour no-lock
            where ifour.soc-cd   = ccptcol.soc-cd
              and ifour.coll-cle = ccptcol.coll-cle
              and ifour.cpt-cd   = string(piNumeroCompte, "99999"):
            return trim(ifour.nom).
        end.
        return "".

    end method.

    method public static character getNomFour(pcCodeRegroupement as character, piNumeroCompte as int64, piNumeroSociete as integer):
    /*------------------------------------------------------------------------------
    purpose: retourne le nom d'un fournisseur ou organisme social sur la référence passée en paramètre
    Notes  : Ancienne fonction FrmTie1 de adb/comm/fctgene.i
    ------------------------------------------------------------------------------*/
        define variable viNumeroSociete as integer   no-undo.

        define buffer CcptCol for CcptCol.
        define buffer ifour   for ifour.

        if piNumeroCompte = ? then return "".

        for first CcptCol no-lock
            where ccptCol.coll-cle = pcCodeRegroupement
              and ccptcol.soc-cd   = piNumeroSociete
          , first ifour no-lock
            where ifour.soc-cd   = ccptcol.soc-cd
              and ifour.coll-cle = ccptcol.coll-cle
              and ifour.cpt-cd   = string(piNumeroCompte, "99999"):
            return trim(ifour.nom).
        end.
        return "".

    end method.


    method public static character getNomTiers(pcTypeRole as character, piNumeroRole as int64):
    /*------------------------------------------------------------------------------
    purpose: retourne le nom d'un role formaté sous la forme [Nom] [Prenom]
    Notes  : Ancienne fonction FrmTie1 de adb/comm/fctgene.i
    ------------------------------------------------------------------------------*/
        define buffer vbRoles for roles.
        define buffer tiers   for tiers.

        for first vbRoles no-lock
            where vbRoles.tprol = pcTypeRole
              and vbRoles.norol = piNumeroRole
          , first tiers no-lock
            where tiers.notie = vbRoles.notie:
            /*--> Gestion speciale des personnes civiles ou morales */
            /*    La raison sociale = lnom1 + lpre1                 */
            return if tiers.cdfat = {&FAMILLETIERS-personneMorale} or tiers.cdfat = {&FAMILLETIERS-personneCivile}
                   then trim(tiers.lnom1 + tiers.lpre1)
                   else trim(substitute('&1 &2', tiers.lnom1, tiers.lpre1)).
        end.
        return "".

    end method.
    
    method public static character getNomTiers2(pcTypeRole as character, piNumeroRole as int64, plAvecSeparateur as logical):    
    /*------------------------------------------------------------------------------
    purpose: retourne le nom d'un role formaté sous la forme [civilite court] [Nom] [Prenom]
    Notes  : Ancienne fonction frmtie2 de adb/comm/fctgene.i
    ------------------------------------------------------------------------------*/
        {application/include/glbsepar.i}
        define variable cCivilite as character no-undo. 
        
        define buffer roles for roles.
        define buffer tiers for tiers.
        
        for first roles no-lock where roles.tprol = pcTypeRole and roles.norol = piNumeroRole
          , first tiers no-lock where tiers.notie = roles.notie :
                // Gestion speciale des personnes civiles ou  morales : La raison sociale = lnom1 + lpre1
                cCivilite = outilTraduction:getLibelleProg("O_CVT", tiers.cdcv1, "c"). // Libellé court
                if cCivilite = "Mr" then cCivilite = "M.". // PL : 0609/0030 
                return (if tiers.cdcv1 = "00000" then "" else cCivilite + " " ) 
                     + (if plAvecSeparateur then separ[1] else "") 
                     + (if tiers.cdfat = {&FAMILLETIERS-personneMorale} or tiers.cdfat = {&FAMILLETIERS-personneCivile}
                        then trim(tiers.lnom1 + tiers.lpre1)
                        else trim(tiers.lnom1) + " " + trim(tiers.lpre1))
                        .
        end.
        return "".
    end.
    

    method private static character formateNomSocieteTiers (pcCodeFamille as character, pcLibelleCodeCivileCourt as character, pcLibelleNom as character, pcLibellePrenom as character):
    /*------------------------------------------------------------------------------
    Purpose: Méthode de formatage du nom d'un tiers
    Notes  :
    ------------------------------------------------------------------------------*/
        // Personne civile ou morale = La raison sociale = lnom1 + lpre1
        return trim(pcLibelleCodeCivileCourt) + " " +
                    trim(if pcCodeFamille = {&FAMILLETIERS-personneMorale} or pcCodeFamille = {&FAMILLETIERS-personneCivile} 
                         then pcLibelleNom + pcLibellePrenom 
                         else trim(pcLibelleNom) + " " + trim(pcLibellePrenom)).

    end method.

    method public static character getCiviliteTiers(piNumeroTiers as int64):
    /*------------------------------------------------------------------------------
    purpose: retourne la civilité d'un tiers
    notes  :
    ------------------------------------------------------------------------------*/
        define variable vcLibelleCivilite1-C as character no-undo.
        define variable vcLibelleCivilite2-C as character no-undo.
        define variable vcLibelleliaison     as character no-undo.

        define buffer tiers for tiers.

        for first tiers no-lock
            where tiers.notie = piNumeroTiers:
            // Libelles associes au tiers 
            assign
                vcLibelleliaison     = outilTraduction:getLibelle(102161)  /* et */
                vcLibelleCivilite1-C = if tiers.cdsft = {&SOUSFAMILLETIERS-epoux} // Gestion speciale des sous-familles Epoux. La civilite = Monsieur et Madame 
                                       then outilTraduction:getLibelle(701762)
                                       else outilTraduction:getLibelleProg("O_CVT", tiers.cdcv1)
            .
            // Recherche du libelle civilite - tiers 2
            if tiers.cdfat = {&FAMILLETIERS-personneCouple}
            or (tiers.cdfat = {&FAMILLETIERS-personneMorale} 
              and (tiers.cdsft = {&SOUSFAMILLETIERS-societe} or tiers.cdsft = {&SOUSFAMILLETIERS-association}) 
              and tiers.cdcv2 > "")
            then vcLibelleCivilite2-C = outilTraduction:getLibelleProg("O_CVT", tiers.cdcv2).

            return if tiers.cdfat = {&FAMILLETIERS-personneCouple} and tiers.cdsft <> {&SOUSFAMILLETIERS-epoux} and vcLibelleCivilite2-C > "" 
                   then substitute("&1 &2 &3", vcLibelleCivilite1-C, vcLibelleliaison, vcLibelleCivilite2-C)
                   else vcLibelleCivilite1-C.
        end.
        return "".

    end method.

    method public static character getNomSocieteTiers(piNumeroTiers as int64):
    /*------------------------------------------------------------------------------
    purpose: retourne le nom d'un tiers
    notes  :
    ------------------------------------------------------------------------------*/
        define variable vcLibelleTiers1fr1   as character no-undo.
        define variable vcLibelleTiers2fr1   as character no-undo.
        define variable vcLibelleCivilite2-C as character no-undo.
        define variable vcLibelleliaison     as character no-undo.

        define buffer tiers   for tiers.

        for first tiers no-lock
            where tiers.notie = piNumeroTiers:

            // Libelles associes au tiers 
            assign 
                vcLibelleliaison   = outilTraduction:getLibelle(102161)  /* et */
                vcLibelleTiers1fr1 = formateNomSocieteTiers(tiers.cdfat, "", tiers.lnom1, tiers.lpre1)
            .

            // Recherche du libelle civilite - tiers 2
            if tiers.cdfat = {&FAMILLETIERS-personneCouple} 
            then do:
                vcLibelleTiers2fr1 = formateNomSocieteTiers("", "", (if tiers.cdsft <> {&SOUSFAMILLETIERS-epoux} then tiers.lnom2 else ""), tiers.lPre2).
                return trim(vcLibelleTiers1fr1 + if vcLibelleTiers2fr1 > "" then substitute(" &1 &2 ", vcLibelleliaison, vcLibelleTiers2fr1) else "").
            end.

            if tiers.cdfat = {&FAMILLETIERS-personneMorale} and (tiers.cdsft = {&SOUSFAMILLETIERS-societe} or tiers.cdsft = {&SOUSFAMILLETIERS-association}) 
            then do:
                if tiers.cdcv2 > "" then vcLibelleCivilite2-C = outilTraduction:getLibelleProg("O_CVT", tiers.cdcv2).

                /*--> Preparation des 4 formatages du tiers 2 (du plus grand au plus petit) */
                vcLibelleTiers2fr1 = formateNomSocieteTiers("", vcLibelleCivilite2-C, tiers.lnom2, tiers.lPre2).
                return trim(vcLibelleTiers1fr1 + if vcLibelleTiers2fr1 > "" then substitute(" (&1)", vcLibelleTiers2fr1) else "").
            end.

        end.
        return trim(vcLibelleTiers1fr1).

    end method.

    method public static character getCiviliteNomTiers(pcTypeRole as character, piNumeroRole as int64):
    /*------------------------------------------------------------------------------
    purpose: retourne le nom d'un role formaté sous la forme Civilité + separateur (facultatif) + [Nom] [Prenom]
    notes  :
    ------------------------------------------------------------------------------*/
        run getCiviliteNomTiers(pcTypeRole, piNumeroRole, false).
    end method.
    
    method public static character getCiviliteNomTiers(pcTypeRole as character, piNumeroRole as int64, plAvecSeparateur as logical):
    /*------------------------------------------------------------------------------
    purpose: retourne le nom d'un role formaté sous la forme Civilité + separateur (facultatif) + [Nom] [Prenom]
    notes  :
    ------------------------------------------------------------------------------*/
        {application/include/glbsepar.i}
        define buffer vbRoles for roles.
        define buffer tiers   for tiers.

        for first vbRoles no-lock
            where vbRoles.tprol = pcTypeRole
              and vbRoles.norol = piNumeroRole
          , first tiers no-lock
            where tiers.notie = vbRoles.notie:
            /*--> Gestion speciale des personnes civiles ou morales */
            /*    La raison sociale = lnom1 + lpre1                 */
            return (if tiers.cdcv1 <> "00000" then outilTraduction:getLibelleProg("O_CVT", tiers.cdcv1) + " " else "")
                 + (if plAvecSeparateur then separ[1] else "")
                 + (if tiers.cdfat = {&FAMILLETIERS-personneMorale} or tiers.cdfat = {&FAMILLETIERS-personneCivile}
                    then trim(tiers.lnom1 + tiers.lpre1)
                    else substitute('&1 &2', trim(tiers.lnom1), trim(tiers.lpre1))).
        end.
        return "".

    end method.

    method public static character getAdresseFour(pcCodeRegroupement as character, piNumeroCompte as int64):
        /*------------------------------------------------------------------------------
        purpose: retourne l'adresse d'un fournisseur ou organisme social sur la référence principale
        notes  :
        ------------------------------------------------------------------------------*/
        if piNumeroCompte = ? then return "".
        return GetAdresseFour(pcCodeRegroupement, piNumeroCompte, "").

    end method.

    method public static character getAdresseFour(pcCodeRegroupement as character, piNumeroCompte as int64, pcTypeContrat as character):
        /*------------------------------------------------------------------------------
        Purpose: Retourne l'adresse d'un fournisseur sur la référence correspondant au type de contrat
        Notes  : Ancienne fonction FrmAdr1 de adb/comm/fctgene.i
        ------------------------------------------------------------------------------*/
        define variable viNumeroSociete as integer   no-undo.

        define buffer CcptCol for CcptCol.
        define buffer ifour   for ifour.

        if piNumeroCompte = ? then return "".

        viNumeroSociete = mtoken:getSociete(pcTypeContrat).
        return getAdresseFour(pcCodeRegroupement, piNumeroCompte, viNumeroSociete).

    end method.

    method public static character getAdresseFour(piNumeroCompte as int64, piTypeRole as integer):
        /*------------------------------------------------------------------------------
        Purpose: Retourne l'adresse d'un fournisseur
        Notes  : Ancienne fonction FrmAdr1 de adb/comm/fctgene.i
        ------------------------------------------------------------------------------*/
        define buffer CcptCol for CcptCol.
        define buffer ifour   for ifour.

        if piNumeroCompte = ? then return "".

        for first CcptCol no-lock
            where ccptcol.soc-cd = integer(mtoken:cRefPrincipale)
              and ccptcol.tprol  = piTypeRole 
          , first ifour no-lock
            where ifour.soc-cd   = ccptcol.soc-cd
              and ifour.coll-cle = ccptcol.coll-cle
              and ifour.cpt-cd   = string(piNumeroCompte , "99999"):
            return (if ifour.adr[1] > "" then trim(ifour.adr[1]) + " " else "")
                 + (if ifour.adr[2] > "" then trim(ifour.adr[2]) + " " else "")
                 + (if ifour.adr[3] > "" then trim(ifour.adr[3]) + " " else "")
                 + caps(trim(ifour.cp) + " " + trim(ifour.ville)).
        end.
        return "".

    end method.

    method public static character getAdresseFour(pcCodeRegroupement as character, piNumeroCompte as int64, piNumeroSociete as integer):
        /*------------------------------------------------------------------------------
        Purpose: Retourne l'adresse d'un fournisseur sur la référence correspondant au type de contrat
        Notes  : Ancienne fonction FrmAdr1 de adb/comm/fctgene.i
        ------------------------------------------------------------------------------*/
        define buffer CcptCol for CcptCol.
        define buffer ifour   for ifour.

        if piNumeroCompte = ? then return "".

        for first CcptCol no-lock
            where ccptCol.coll-cle = pcCodeRegroupement
              and ccptcol.soc-cd   = piNumeroSociete
          , first ifour no-lock
            where ifour.soc-cd   = ccptcol.soc-cd
              and ifour.coll-cle = ccptcol.coll-cle
              and ifour.cpt-cd   = string(piNumeroCompte , "99999"):
            return (if ifour.adr[1] > "" then trim(ifour.adr[1]) + " " else "")
                 + (if ifour.adr[2] > "" then trim(ifour.adr[2]) + " " else "")
                 + (if ifour.adr[3] > "" then trim(ifour.adr[3]) + " " else "")
                 + caps(trim(ifour.cp) + " " + trim(ifour.ville)).
        end.
        return "".

    end method.

    method public static character formatageAdresse(pcTypeRole as character, piNumeroRole as int64, piNumeroLien as int64):
    /*------------------------------------------------------------------------------
    Purpose: Retourne l'adresse d'un tiers de gestion (pas les fournisseurs)
    Notes  :
    ------------------------------------------------------------------------------*/
        return formatageAdresse(pcTypeRole, piNumeroRole, piNumeroLien, mToken:iCodeLangueSession, mToken:iCodeLangueReference).

    end method.

    method public static character formatageAdresse(pcTypeRole as character, piNumeroRole as int64):
    /*------------------------------------------------------------------------------
    Purpose: Retourne l'adresse d'un tiers de gestion (pas les fournisseurs)
    Notes  :
    ------------------------------------------------------------------------------*/
        return formatageAdresse(pcTypeRole, piNumeroRole, "", mToken:iCodeLangueSession, mToken:iCodeLangueReference).

    end method.

    method public static character formatageAdresse(pcTypeRole as character, piNumeroRole as int64, piCdLngSes as integer, piCdLngRef as integer):
    /*------------------------------------------------------------------------------
    Purpose: Retourne l'adresse d'un tiers de gestion (pas les fournisseurs)
    Notes  :
    ------------------------------------------------------------------------------*/
        return formatageAdresse(pcTypeRole, piNumeroRole, "", piCdLngSes, piCdLngRef).

    end method.

    method public static character formatageAdresse(pcTypeRole as character, piNumeroRole as int64, pcTypeAdresse as character):
    /*------------------------------------------------------------------------------
    Purpose: Retourne l'adresse d'un tiers en fonction du type d'adresse
    Notes  : Ancienne fonction FrmAdr2 de adb/comm/fctgene.i
    ------------------------------------------------------------------------------*/
        return formatageAdresse(pcTypeRole, piNumeroRole, pcTypeAdresse, mToken:iCodeLangueSession, mToken:iCodeLangueReference).

    end method.

    method public static character formatageAdresse
        (pcTypeRole as character, piNumeroRole as int64, pcTypeAdresse as character, piCdLngSes as integer, piCdLngRef as integer):
    /*------------------------------------------------------------------------------
    Purpose: Retourne l'adresse d'un tiers
    Notes  : Ancienne fonction FrmAdr1 de adb/comm/fctgene.i
    ------------------------------------------------------------------------------*/
        define buffer ladrs   for ladrs.
        define buffer adres   for adres.

        for first ladrs no-lock
            where ladrs.tpidt = pcTypeRole
              and ladrs.noidt = piNumeroRole
              and ladrs.tpadr = (if pcTypeAdresse > "" then pcTypeAdresse else "00001")
          , first adres no-lock
            where adres.noadr = ladrs.noadr:
            return formatageAdresse(buffer ladrs, buffer adres, 3 /* ville et pays */, piCdLngSes, piCdLngRef).
        end.
        return "".

    end method.

    method public static character formatageAdresse
        (pcTypeRole as character, piNumeroRole as int64, piLien as int64, piCdLngSes as integer, piCdLngRef as integer):
        /*------------------------------------------------------------------------------
        Purpose: Retourne l'adresse d'un tiers
        Notes  :
        ------------------------------------------------------------------------------*/
        define buffer ladrs   for ladrs.
        define buffer adres   for adres.

        for first ladrs no-lock
            where ladrs.tpidt = pcTypeRole
              and ladrs.noidt = piNumeroRole
              and ladrs.nolie = piLien
          , first adres no-lock
            where adres.noadr = ladrs.noadr:
            return formatageAdresse(buffer ladrs, buffer adres, 3 /* ville et pays */, piCdLngSes, piCdLngRef).
        end.
        return "".

    end method.

    {&_proparse_ prolint-nowarn(bufdbmeth)}    // prolint ne reconnait pas encore les buffer parameter
    method public static character formatageAdresse
        (buffer pbladrs for ladrs, buffer pbadres for adres, piVilleEtPays as integer, piCdLngSes as integer, piCdLngRef as integer):
    /*------------------------------------------------------------------------------
    Purpose: Retourne l'adresse d'un tiers
    Notes  : piVilleEtPays: 1 = ville, 2 = pays, 3 = ville & pays
    ------------------------------------------------------------------------------*/
        define variable vcLibellePays as character no-undo.
        define variable vcLibelleBis  as character no-undo.
        define variable vlVille       as logical   no-undo.
        define variable vlPays        as logical   no-undo.

        {&_proparse_ prolint-nowarn(bufdbmeth)}    // prolint ne reconnait pas encore les buffer parameter
        assign
            vlVille = (piVilleEtPays modulo 2 = 1)
            vlPays  = (truncate(piVilleEtPays / 2, 0) modulo 2 = 1)
            vcLibellePays = if vlPays then getPays(pbAdres.cdpay) else ""
            vcLibelleBis  = if pbLadrs.cdadr = "00000" then "" else (" " + outilTraduction:getLibelleParam("CDADR", pbLadrs.cdadr, piCdLngSes, piCdLngRef))
        .
        {&_proparse_ prolint-nowarn(bufdbmeth)}    // prolint ne reconnait pas encore les buffer parameter
        return (if pbAdres.cpad2 > "" then trim(pbAdres.cpad2) + " " else "")
             + (if pbLadrs.novoi > "" and pbLadrs.novoi <> "0" then pbLadrs.novoi + vcLibelleBis + " " else "")
             + (if pbAdres.ntvoi <> {&NATUREVOIE--} then outilTraduction:getLibelleParam("NTVOI", pbAdres.ntvoi, piCdLngSes, piCdLngRef) + " " else "")
             + (if pbAdres.lbvoi > "" then trim(pbAdres.lbvoi) + " " else "")
             + (if pbAdres.cpvoi > "" then trim(pbAdres.cpvoi) + " " else "")
             + (if vlVille then caps(trim(pbAdres.cdpos) + " " + trim(pbAdres.lbvil)) else "")
             + (if vlPays and vcLibellePays > "" then ". " + vcLibellePays else "").

    end method.

    {&_proparse_ prolint-nowarn(bufdbmeth)}    // prolint ne reconnait pas encore les buffer parameter
    method public static character formatageAdresse (buffer pbLadrs for ladrs, buffer pbAdres for adres):
        /*------------------------------------------------------------------------------
        Purpose: Retourne l'adresse d'un tiers
        Notes  : Par défaut, ville et pays (troisième paramètre à 3
        ------------------------------------------------------------------------------*/
        {&_proparse_ prolint-nowarn(bufdbmeth)}    // prolint ne reconnait pas encore les buffer parameter
        return formatageAdresse(buffer pbLadrs, buffer pbAdres, 3, mToken:iCodeLangueSession, mToken:iCodeLangueReference).

    end method.

    {&_proparse_ prolint-nowarn(bufdbmeth)}    // prolint ne reconnait pas encore les buffer parameter
    method public static character formatageAdresse (buffer pbLadrs for ladrs, buffer pbAdres for adres, piVilleEtPays as integer):
        /*------------------------------------------------------------------------------
        Purpose: Retourne l'adresse d'un tiers
        Notes  :
        ------------------------------------------------------------------------------*/
        {&_proparse_ prolint-nowarn(bufdbmeth)}    // prolint ne reconnait pas encore les buffer parameter
        return formatageAdresse(buffer pbLadrs, buffer pbAdres, piVilleEtPays, mToken:iCodeLangueSession, mToken:iCodeLangueReference).

    end method.

	/*------------------------------------------------------------------------------
	 Purpose: Formatage d'un tiers sur 1 ligne
	 Notes: ancien programme FormTie4.p
	------------------------------------------------------------------------------*/
	method public static character getNomTiers1Ligne(pcTypeRecherche as character, pcTypeIdentifiantTiers as character, piNumeroIdentifiantTiers as integer, piLongueurLigne as integer  ):
		
		define variable     vcRetour as character no-undo.
        // Tableau des lignes
        define variable     vcTableauLigne                      as character extent 60  no-undo.
        // Chaine temporaire pour mise en forme
        define variable     vcChaineTmp                         as character        no-undo.
        // Variables informations du tiers 1
        define variable     vcLibelleCiviliteLongTiers1         as character    no-undo.
        define variable     vcLibelleCiviliteCourtTiers1        as character    no-undo.
        define variable     vcLibelleParticulierLongTiers1      as character    no-undo.
        define variable     vcLibelleParticulierCourtTiers1     as character    no-undo.
        define variable     vcCodeCiviliteTiers1                as character    no-undo.
        define variable     vcCodeParticulierTiers1             as character    no-undo.
        define variable     vcNomTiers1                         as character    no-undo.
        define variable     vcPrenomTiers1                      as character    no-undo.
        define variable     vcCodeFamilleTiers                  as character    no-undo.
        define variable     viCompteur                          as integer      no-undo.
        define variable     viCompteurMax                       as integer      no-undo.
        // Flag trouve
        define variable     lTiersTrouve                        as logical      no-undo init yes.
        
        define buffer tiers for tiers.
        define buffer roles for roles.
    
        // Recherche du tiers (via la table roles)
        // Avec le numero unique de role (inexistant)
        if pcTypeRecherche = "CODE" then do:
            find tiers no-lock
                where   tiers.notie = piNumeroIdentifiantTiers
                no-error
                .
            if available tiers then
                assign
                    vcCodeCiviliteTiers1 = tiers.cdcv1
                    vcCodeParticulierTiers1 = tiers.cdpr1
                    vcNomTiers1 = tiers.lnom1
                    vcPrenomTiers1 = tiers.lpre1
                    vcCodeFamilleTiers = tiers.cdfat
                    .
            else
                /* le tiers est introuvable */
                lTiersTrouve = false.
        end.
    
        /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         ³ Avec le type et le numero de role             ³
         ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
        if pcTypeRecherche = "TYPE" then do:
    
            /* recherche du role correspondant */
            find roles no-lock
                where   roles.tprol = pcTypeIdentifiantTiers
                and     roles.norol = piNumeroIdentifiantTiers
                no-error
                .
            if available roles then do:
                /* recherche du tiers correspondant */
                find tiers no-lock
                    where   tiers.notie = roles.notie
                    no-error
                    .
                if available tiers then
                    assign
                        vcCodeCiviliteTiers1 = tiers.cdcv1
                        vcCodeParticulierTiers1 = tiers.cdpr1
                        vcNomTiers1 = tiers.lnom1
                        vcPrenomTiers1 = tiers.lpre1
                        vcCodeFamilleTiers = tiers.cdfat
                        .
                else
                    /* le tiers est introuvable */
                    lTiersTrouve = false.
            end.
            else
                /* le role est introuvable */
                lTiersTrouve = false.
        end.
    
        // Tiers non trouve
        if lTiersTrouve = false then do:
            vcRetour = "?.?.?".
            return vcRetour.
        end.

        assign
            // Recherche des libelles associes au tiers
            // Recherche du libelle civilite - tiers 1
            vcLibelleCiviliteLongTiers1 = outilTraduction:getLibelleProg ("O_CVT", vcCodeCiviliteTiers1)
            vcLibelleCiviliteCourtTiers1 = outilTraduction:getLibelleProg ("O_CVT", vcCodeCiviliteTiers1, "C")
            // Recherche du libelle particulier - tiers 1
            vcLibelleParticulierLongTiers1 = outilTraduction:getLibelleProg ("O_PAT", vcCodeCiviliteTiers1)
            vcLibelleParticulierCourtTiers1 = outilTraduction:getLibelleProg ("O_PAT", vcCodeCiviliteTiers1, "C")
            // Positionnement sur la premiere ligne
            viCompteur = 1
            .
    
        /* Gestion sp‚ciale des Personnes civiles (09003)
           ou morale (09004)
           La raison sociale = lnom1 + lpre1*/
        assign
            vcChaineTmp   = vcLibelleCiviliteLongTiers1
            vcChaineTmp   = substitute("&1 &2", trim (vcChaineTmp), vcLibelleParticulierLongTiers1)
            vcChaineTmp   = substitute("&1 &2", trim (vcChaineTmp), if lookup(vcCodeFamilleTiers, "09003,09004") > 0
                                                                    then trim(substitute("&1&2", vcNomTiers1, vcPrenomTiers1))
                                                                    else substitute("&1 &2", trim(vcNomTiers1), trim(vcPrenomTiers1)))
            .
    
        if length (vcChaineTmp, "CHARACTER") > piLongueurLigne then
            assign
                vcChaineTmp   = vcLibelleCiviliteLongTiers1
                vcChaineTmp   = substitute("&1 &2", trim (vcChaineTmp), if lookup(vcCodeFamilleTiers, "09003,09004") > 0 
                                                                        then trim(substitute("&1&2", vcNomTiers1, vcPrenomTiers1))
                                                                        else substitute("&1 &2", trim(vcNomTiers1), trim(vcPrenomTiers1)))
                .
    
        if length (vcChaineTmp, "CHARACTER") > piLongueurLigne then
            assign
                vcChaineTmp   = vcLibelleCiviliteCourtTiers1
                vcChaineTmp   = substitute("&1 &2", trim (vcChaineTmp), if lookup(vcCodeFamilleTiers, "09003,09004") > 0 
                                                                        then trim(substitute("&1&2", vcNomTiers1, vcPrenomTiers1))
                                                                        else substitute("&1 &2", trim(vcNomTiers1), trim(vcPrenomTiers1)))
                .
    
        if length (vcChaineTmp, "CHARACTER") > piLongueurLigne then do:
            if lookup(vcCodeFamilleTiers, "09003,09004") > 0 then
                vcChaineTmp   = trim(substitute("&1&2", vcNomTiers1, vcPrenomTiers1)).
            else
                assign
                    vcChaineTmp   = vcLibelleCiviliteCourtTiers1
                    vcChaineTmp   = substitute("&1 &2", trim (vcChaineTmp), vcNomTiers1)
                    vcChaineTmp   = substitute("&1 &2.", trim (vcChaineTmp), substring (vcPrenomTiers1, 1, 1)) 
                    .
        end.
    
        if length (vcChaineTmp, "CHARACTER") > piLongueurLigne then
            vcChaineTmp   = if lookup(vcCodeFamilleTiers, "09003,09004") > 0 then trim(substitute("&1&2", vcNomTiers1, vcPrenomTiers1))
                            else substitute("&1 &2.", vcNomTiers1, substring(vcPrenomTiers1, 1, 1)). 
    
        assign
            vcTableauLigne[viCompteur] = trim (vcChaineTmp)
            viCompteur    = viCompteur + 1
            .
    
        // Fusion des lignes dans la chaine a retourner
        assign
            viCompteurMax    = viCompteur - 1
            vcRetour = vcTableauLigne[1]
            .
    
        do viCompteur = 2 to viCompteurMax :
            assign
                vcRetour = vcRetour
                        + "|"
                        + vcTableauLigne[viCompteur]
                .
        end.

		return vcRetour.

	end method.

    /*------------------------------------------------------------------------------
     Purpose: Formatage d'un tiers sur 1 ou 2 ligne(s). avec Monsieur et Madame (ou Mr et Mme) pour les Epoux + le 2Šme individu si concubin
     Notes: ancien programme formtiea.p
    ------------------------------------------------------------------------------*/
     method public static character getNomTiersFormtiea(pcTypeRecherche as character, pcTypeIdentifiantTiers as character, piNumeroIdentifiantTiers as int64, piLongueurLigne as integer):

         define variable vcLbChnTie  as character no-undo.
         define variable viCpMinInc  as integer   no-undo.
         define variable viCpMaxInc  as integer   no-undo.
         /*--> Tableau des lignes */
         define variable vcTbMvt     as character no-undo extent 60.
         /*--> Chaine temporaire pour mise en forme */
         define variable vcChaineTmp as character no-undo.
         /*--> Libelle "et" */
         define variable vcLbliaison as character no-undo.
         /*--> Variables informations du tiers 1 */
         define variable vcLbCdcv1-L as character no-undo.
         define variable vcLbCdcv1-C as character no-undo.
         define variable vcLbCdpr1-L as character no-undo.
         define variable vcLbCdpr1-C as character no-undo.
         define variable vcLbTie1fr1 as character no-undo.
         define variable vcLbTie1fr2 as character no-undo.
         define variable vcLbTie1fr3 as character no-undo.
         define variable vcLbTie1fr4 as character no-undo.
         define variable vcLbTie1fr5 as character no-undo.
         /*--> Variables informations du tiers 2 */
         define variable vcLbCdcv2-L as character no-undo.
         define variable vcLbCdcv2-C as character no-undo.
         define variable vcLbCdpr2-L as character no-undo.
         define variable vcLbCdpr2-C as character no-undo.
         define variable vcLbTie2fr1 as character no-undo.
         define variable vcLbTie2fr2 as character no-undo.
         define variable vcLbTie2fr3 as character no-undo.
         define variable vcLbTie2fr4 as character no-undo.
         define variable vcLbTie2fr5 as character no-undo.
         /*--> Variables informations du tiers C/O */
         define variable vcLbCdcv3-L as character no-undo.
         define variable vcLbCdcv3-C as character no-undo.
         define variable vcLbCdpr3-L as character no-undo.
         define variable vcLbCdpr3-C as character no-undo.
         define variable vcLbTie3fr1 as character no-undo.
         define variable vcLbTie3fr2 as character no-undo.
         define variable vcLbTie3fr3 as character no-undo.
         define variable vcLbTie3fr4 as character no-undo.
         define variable vcLbTie3fr5 as character no-undo.
    
        define buffer tiers   for tiers.
        define buffer vbroles for roles.
    
        case pcTypeRecherche:
            when "CODE" then
            do:
                find first tiers no-lock
                     where tiers.notie = piNumeroIdentifiantTiers no-error.
            end.
            when "TYPE" then
            do:
                find first vbroles no-lock
                     where vbroles.tprol = pcTypeIdentifiantTiers
                       and vbroles.norol = piNumeroIdentifiantTiers no-error.
                if available vbroles then
                do:
                    find first tiers no-lock
                         where tiers.notie = vbroles.notie no-error.
                end.
            end.
        end.
        
        /*--> Tiers non trouve */
        if not available tiers
        then return "?.?.?".
    
        /*--PREPARATION FORMATTAGE-------------------------------------------------------------------------------------------------*/
        vcLbliaison = outilTraduction:getLibelle(102161).
        if tiers.cdsft = "06003"                                       /*--> Gestion speciale des sous-familles Epoux. La civilite = Monsieur et Madame */ 
        then assign
                 vcLbcdcv1-L = outilTraduction:getLibelle(701761)
                 vcLbcdcv1-C = outilTraduction:getLibelle(701762)
        .
        else assign                                                    /*--> Recherche du libelle civilite - tiers 1 */
                 vcLbcdcv1-L = outilTraduction:getLibelleProg("O_CVT", tiers.cdcv1)
                 vcLbcdcv1-C = outilTraduction:getLibelleProg("O_CVT", tiers.cdcv1, "C")
        .
        assign                                                            /*--> Recherche du libelle particulier - tiers 1 */
            vcLbcdpr1-L = outilTraduction:getLibelleProg("O_PAT", tiers.cdpr1)         
            vcLbcdpr1-C = outilTraduction:getLibelleProg("O_PAT", tiers.cdpr1, "C")     
        .
        /*--> Preparation des 4 formatages du tiers 1 (du plus grand au plus petit) */
        FrmNomTie(tiers.cdfat, tiers.cdsft, vcLbCdcv1-L, vcLbCdCv1-C, vcLbCdpr1-L, vcLbCdpr1-C, tiers.lnom1, tiers.lpre1,
                  output vcLbTie1Fr1, output vcLbTie1Fr2, output vcLbTie1Fr3, output vcLbTie1Fr4, output vcLbTie1Fr5).
        
        if tiers.cdfat = "09002" and tiers.cdsft <> "06003" 
        then do:
            assign    
                vcLbcdcv2-L = outilTraduction:getLibelleProg("O_CVT", tiers.cdcv2)                /*--> Recherche du libelle civilite - tiers 2 */        
                vcLbcdcv2-C = outilTraduction:getLibelleProg("O_CVT", tiers.cdcv2, "C")                
                vcLbcdpr2-L = outilTraduction:getLibelleProg("O_PAT", tiers.cdpr2)                /*--> Recherche du libelle particulier - tiers 2 */                
                vcLbcdpr2-C = outilTraduction:getLibelleProg("O_PAT", tiers.cdpr2, "C")                             
            .
            /*--> Preparation des 4 formatages du tiers 2 (du plus grand au plus petit) */
            FrmNomTie("", "", vcLbCdcv2-L, vcLbCdCv2-C, vcLbCdpr2-L, vcLbCdpr2-C, tiers.lnom2, tiers.lpre2,
                      output vcLbTie2Fr1, output vcLbTie2Fr2, output vcLbTie2Fr3, output vcLbTie2Fr4, output vcLbTie2Fr5).
        end.
        
        if tiers.cdfat = {&FAMILLETIERS-personneMorale} and tiers.cdsft = "06009"
        then do:
            if tiers.cdcv2 <> "" and tiers.cdpr2 <> "" 
            then assign
                vcLbcdcv2-L = outilTraduction:getLibelleProg("O_CVT", tiers.cdcv2)              /*--> Recherche du libelle civilite - tiers 2 */                   
                vcLbcdcv2-C = outilTraduction:getLibelleProg("O_CVT", tiers.cdcv2, "C")   
                vcLbcdpr2-L = outilTraduction:getLibelleProg("O_PAT", tiers.cdpr2)              /*--> Recherche du libelle particulier - tiers 2 */                                
                vcLbcdpr2-C = outilTraduction:getLibelleProg("O_PAT", tiers.cdpr2, "C")                                            
            .                           
            /*--> Preparation des 4 formatages du tiers 2 (du plus grand au plus petit) */
            FrmNomTie("", "", vcLbCdcv2-L, vcLbCdCv2-C, vcLbCdpr2-L, vcLbCdpr2-C, tiers.lnom2, tiers.lpre2,
                      output vcLbTie2Fr1, output vcLbTie2Fr2, output vcLbTie2Fr3, output vcLbTie2Fr4, output vcLbTie2Fr5).
        end.
        if tiers.fgco3 
        then do:
            if tiers.cdcv3 <> "" and tiers.cdpr3 <> "" 
            then assign
                     vcLbcdcv3-L = outilTraduction:getLibelleProg("O_CVT", tiers.cdcv3)                /*--> Recherche du libelle civilite - tiers C/O */            
                     vcLbcdcv3-C = outilTraduction:getLibelleProg("O_CVT", tiers.cdcv3, "C")             
                     vcLbcdpr3-L = outilTraduction:getLibelleProg("O_PAT", tiers.cdpr3)                /*--> Recherche du libelle particulier - tiers C/O */            
                     vcLbcdpr3-C = outilTraduction:getLibelleProg("O_PAT", tiers.cdpr3, "C")
            .                
            FrmNomTie("", "", vcLbCdcv3-L, vcLbCdCv3-C, vcLbCdpr3-L, vcLbCdpr3-C, tiers.lnom3, tiers.lpre3,
                      output vcLbTie3Fr1, output vcLbTie3Fr2, output vcLbTie3Fr3, output vcLbTie3Fr4, output vcLbTie3Fr5).
        end.
        
    /*--FORMATTAGE DES LIGNES--------------------------------------------------------------------------------------------------*/
        /*--> Positionnement sur la premiere ligne  */
        viCpMinInc = 1.
        
        if tiers.cdfat = "09002" and tiers.cdsft <> "06003" 
        then do:
            vcChaineTmp = trim(vcLbTie1Fr1) + " " + vcLbliaison + " " + vcLbTie2Fr1.
            if length (vcChaineTmp, "CHARACTER") > piLongueurLigne 
            then vcChaineTmp = vcLbTie1Fr2 + " " + vcLbliaison + " " + vcLbTie2Fr2.
            if length (vcChaineTmp, "CHARACTER") > piLongueurLigne 
            then vcChaineTmp = vcLbTie1Fr3 + " " + vcLbliaison + " " + vcLbTie2Fr3.
            if length (vcChaineTmp, "CHARACTER") > piLongueurLigne 
            then vcChaineTmp = vcLbTie1Fr4 + " " + vcLbliaison + " " + vcLbTie2Fr4.
            if length (vcChaineTmp, "CHARACTER") > piLongueurLigne 
            then do:
                /* 2 lignes */
                vcChaineTmp = vcLbTie1Fr1 .
                if length (vcChaineTmp, "CHARACTER") > piLongueurLigne 
                then vcChaineTmp = vcLbTie1Fr2.
                if length (vcChaineTmp, "CHARACTER") > piLongueurLigne 
                then vcChaineTmp = vcLbTie1Fr3.
                if length (vcChaineTmp, "CHARACTER") > piLongueurLigne 
                then vcChaineTmp = vcLbTie1Fr4.
                assign
                    vcTbMvt[viCpMinInc] = trim (vcChaineTmp)
                    viCpMinInc          = viCpMinInc + 1
                    vcChaineTmp         = vcLbliaison + " " + vcLbTie2Fr1
                .
                if length (vcChaineTmp, "CHARACTER") > piLongueurLigne 
                then vcChaineTmp = vcLbTie2Fr2.
                if length (vcChaineTmp, "CHARACTER") > piLongueurLigne 
                then vcChaineTmp = vcLbTie2Fr3.
                if length (vcChaineTmp, "CHARACTER") > piLongueurLigne 
                then vcChaineTmp = vcLbTie2Fr4.
            end.
            assign
                vcTbMvt[viCpMinInc] = trim (vcChaineTmp)
                viCpMinInc          = viCpMinInc + 1
            .
        end.
        else do:
            if tiers.cdfat = {&FAMILLETIERS-personneMorale} and tiers.cdsft = "06009" 
            then do:
                vcChaineTmp = vcLbTie1Fr1. 
                if length (vcChaineTmp, "CHARACTER") > piLongueurLigne 
                then vcChaineTmp = vcLbTie1Fr2.
                if length (vcChaineTmp, "CHARACTER") > piLongueurLigne 
                then vcChaineTmp = vcLbTie1Fr3.
                if length (vcChaineTmp, "CHARACTER") > piLongueurLigne 
                then vcChaineTmp = vcLbTie1Fr4 .
                assign
                    vcTbMvt[viCpMinInc] = trim (vcChaineTmp)
                    viCpMinInc          = viCpMinInc + 1
                    vcChaineTmp         = vcLbTie2Fr1
                .
                if length (vcChaineTmp, "CHARACTER") > piLongueurLigne 
                then vcChaineTmp = vcLbTie2Fr2.
                if length (vcChaineTmp, "CHARACTER") > piLongueurLigne 
                then vcChaineTmp = vcLbTie2Fr3.
                if length (vcChaineTmp, "CHARACTER") > piLongueurLigne
                then vcChaineTmp = vcLbTie2Fr4.
                assign
                    vcTbMvt[viCpMinInc] = trim (vcChaineTmp)
                    viCpMinInc          = viCpMinInc + 1
                .
            end.
            else do:
                vcChaineTmp = vcLbTie1Fr1.
                if length(vcChaineTmp,"CHARACTER") > piLongueurLigne 
                then vcChaineTmp = vcLbTie1Fr2.
                if length(vcChaineTmp,"CHARACTER") > piLongueurLigne 
                then vcChaineTmp = vcLbTie1Fr3.
                if length(vcChaineTmp,"CHARACTER") > piLongueurLigne 
                then vcChaineTmp = vcLbTie1Fr4.
                if length(vcChaineTmp,"CHARACTER") > piLongueurLigne 
                then vcChaineTmp = vcLbTie1Fr5.
                assign
                    vcTbMvt[viCpMinInc] = trim (vcChaineTmp)
                    viCpMinInc          = viCpMinInc + 1
                .
            end.
        end.
        if tiers.fgco3 
        then do:
            assign
                viCpMinInc  = 3
                vcChaineTmp = vcLbTie3Fr1
            . 
            if length (vcChaineTmp, "CHARACTER") > piLongueurLigne 
            then vcChaineTmp = vcLbTie3Fr2.
            if length (vcChaineTmp, "CHARACTER") > piLongueurLigne 
            then vcChaineTmp = vcLbTie3Fr3.
            if length (vcChaineTmp, "CHARACTER") > piLongueurLigne 
            then vcChaineTmp = vcLbTie3Fr4.
            assign
                vcTbMvt[viCpMinInc] = trim (vcChaineTmp)
                viCpMinInc          = viCpMinInc + 1
            .
        end.
        
        /*--> Fusion des lignes dans la chaine a retourner */
        assign
            viCpMaxInc = viCpMinInc - 1
            vcLbChnTie = vcTbMvt[1]
        .
        do viCpMinInc = 2 to viCpMaxInc :
            vcLbChnTie = vcLbChnTie + "|" + vcTbMvt[viCpMinInc].
        end.
        return vcLbChnTie.
     
    end method.


    method public static character FrmNomTie(pcCdfatIN as character, pcCdsftIN as character, pcLbCdCvlLongIN as character, pcLbCdCvlCourtIN as character, pcLbCdPrtLongIN as character, pcLbCdPrtCourtIN as character, pvlbnomIN as character, pcLbpreIN as character,
                                             output pcLbTieFr1OU as character, output pcLbTieFr2OU as character, output pcLbTieFr3OU as character, output pcLbTieFr4OU as character, output pcLbTieFr5OU as character):

        if pcLbCdPrtCourtIN = "-" 
        then assign
                 pcLbCdPrtCourtIN = ""
                 pcLbCdPrtLongIN = ""
        .
    
        /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         ³ Personne civile ou morale :                   ³                                         ³
         ³ La raison sociale = lnom1 + lpre1             ³
         ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
        /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         ³ Gestion sp‚ciale des sous-familles Epoux      ³                                         ³
         ³ La civilit‚ = Monsieur et Madame et pas       ³
         ³ d'affichage du titre particulier              ³
         ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
        assign
            pcLbTieFr1OU = pcLbCdCvlLongIN
            pcLbTieFr1OU = (if pcCdsftIN = "06003" 
                           then trim (pcLbTieFr1OU)
                           else trim (pcLbTieFr1OU) + " " + pcLbCdPrtLongIN)
            pcLbTieFr1OU = trim (pcLbTieFr1OU) + " " + (if pcCdfatIN = {&FAMILLETIERS-personneMorale} or pcCdfatIN = {&FAMILLETIERS-personneCivile}
                                                      then trim(pvlbnomIN + pcLbpreIN)
                                                      else trim(pvlbnomIN) + " " + trim(pcLbpreIN))
            pcLbTieFr2OU = pcLbCdCvlLongIN
            pcLbTieFr2OU = trim (pcLbTieFr2OU) + " " + (if pcCdfatIN = {&FAMILLETIERS-personneMorale} or pcCdfatIN = {&FAMILLETIERS-personneCivile}
                                                      then trim(pvlbnomIN + pcLbpreIN)
                                                      else trim(pvlbnomIN) + " " + trim(pcLbpreIN))
            pcLbTieFr3OU = pcLbCdCvlCourtIN
            pcLbTieFr3OU = trim (pcLbTieFr3OU) + " " + (if pcCdfatIN = {&FAMILLETIERS-personneMorale} or pcCdfatIN = {&FAMILLETIERS-personneCivile}
                                                      then trim(pvlbnomIN + pcLbpreIN)
                                                      else trim(pvlbnomIN) + " " + trim(pcLbpreIN))
        .
        if pcCdfatIN = {&FAMILLETIERS-personneMorale} or pcCdfatIN = {&FAMILLETIERS-personneCivile} 
        then assign
                 pcLbTieFr4OU = pcLbCdCvlCourtIN
                 pcLbTieFr4OU = trim(pcLbTieFr4OU) + " " + trim(pvlbnomIN + pcLbpreIN)
        .
        else assign
                 pcLbTieFr4OU = pcLbCdCvlCourtIN
                 pcLbTieFr4OU = trim(pcLbTieFr4OU) + " " + trim(pvlbnomIN) + " " + substring(pcLbpreIN, 1, 1) + "."
        .
        if pcCdfatIN = {&FAMILLETIERS-personneMorale} or pcCdfatIN = {&FAMILLETIERS-personneCivile} 
        then pcLbTieFr5OU = trim(pvlbnomIN + pcLbpreIN).
        else pcLbTieFr5OU = trim(pvlbnomIN) + " " + substring(pcLbpreIN, 1, 1) + ".".

    end method.

    method public static character getAdresse14Lignes(pcTypeRecherche as character, pcTypeIdentifiantTiers as character, piNumeroIdentifiantTiers as integer, piLongueurLigne as integer  ):
    /*------------------------------------------------------------------------------
     Purpose: Formatage d'une adresse sur 14 lignes
     Notes: ancien programme FormAdr1.p
    ------------------------------------------------------------------------------*/
        define variable vcRetour           as character no-undo.
        define variable vcTableauLigne     as character no-undo extent 30.
        define variable vcChaineTmp        as character no-undo.
        define variable vlTrouve           as logical   no-undo init yes.
        define variable vcCodeAdresseLong  as character no-undo.
        define variable vcCodeAdresseCourt as character no-undo.
        define variable vcNatureVoieLong   as character no-undo.
        define variable vcNatureVoieCourt  as character no-undo.
        define variable vcLibellePaysLong  as character no-undo.
        define variable vcLibellePaysCourt as character no-undo.
        define variable viLigneAdresse     as integer   no-undo.
        define variable vcListeTelephone   as character no-undo.
        define variable viCompteur         as integer   no-undo.
        define variable vhProcFcttelep     as handle    no-undo.
        define variable viNumeroMax        as integer   no-undo.

        define buffer ladrs for ladrs.
        define buffer adres for adres.

        // Recherche du lien adresse Avec le numero de lien
        if pcTypeRecherche = "CODE" then do:
            find first ladrs no-lock
                where ladrs.nolie = piNumeroIdentifiantTiers no-error.
            if not available ladrs then return "?.?.?".
        end.
        // Recherche du lien adresse avec le type et le numero d'identifiant
        else if pcTypeRecherche = "TYPE" then do:
            find first ladrs no-lock
                where ladrs.tpidt   = pcTypeIdentifiantTiers
                    and ladrs.noidt = piNumeroIdentifiantTiers
                    and ladrs.tpadr = "00001" no-error.
            if not available ladrs then return "?.?.?".
        end.
        // Recherche de l'adresse
        find first adres no-lock
            where adres.noadr = ladrs.noadr no-error.
        if not available adres then return "?.?.?".

        assign
            // Décodage du code adresse (BIS, TER, ...). 
            vcCodeAdresseLong  = trim(outilTraduction:getLibelleParam ("CDADR", ladrs.cdadr), "-")
            vcCodeAdresseCourt = trim(outilTraduction:getLibelleParam ("CDADR", ladrs.cdadr, "C"), "-")
            // Décodage de la nature de la voie (Rue, ...).
            vcNatureVoieLong   = trim(outilTraduction:getLibelleParam ("NTVOI", adres.ntvoi), "-")
            vcNatureVoieCourt  = trim(outilTraduction:getLibelleParam ("NTVOI", adres.ntvoi, "C"), "-")
        .
        // Décodage du Code Pays.
        //          RECHERCHE DU CODE PAYS DU CABINET
        if getpays(adres.cdpay) > ""
        then assign
            vcLibellePaysLong  = outilTraduction:getLibelleParam ("CDPAY", adres.cdpay)
            vcLibellePaysCourt = outilTraduction:getLibelleParam ("CDPAY", adres.cdpay, "C")
        .
        // Ligne 1
        assign
            viLigneAdresse = 1
            vcChaineTmp    = if ladrs.novoi <> "0" then ladrs.novoi else ""
            vcChaineTmp    = substitute("&1 &2",trim (vcChaineTmp), vcCodeAdresseLong)
            vcChaineTmp    = substitute("&1 &2",trim (vcChaineTmp), vcNatureVoieLong)
            vcChaineTmp    = substitute("&1 &2",trim (vcChaineTmp), adres.lbvoi)
            vcChaineTmp    = trim (vcChaineTmp)
        .
        if length(vcChaineTmp, "CHARACTER") > piLongueurLigne
        then assign
            vcChaineTmp = if ladrs.novoi <> "0" then ladrs.novoi else ""
            vcChaineTmp = substitute("&1 &2",trim (vcChaineTmp), vcCodeAdresseCourt)
            vcChaineTmp = substitute("&1 &2",trim (vcChaineTmp), vcNatureVoieCourt)
            vcChaineTmp = substitute("&1 &2",trim (vcChaineTmp), adres.lbvoi)
            vcChaineTmp = trim (vcChaineTmp)
        .
        assign
            vcTableauLigne[viLigneAdresse] = vcChaineTmp
            viLigneAdresse                 = viLigneAdresse + 1
            // Ligne 2
            vcTableauLigne[viLigneAdresse] = trim (adres.cpvoi)
            viLigneAdresse                 = viLigneAdresse + 1
            // Ligne 3
            vcChaineTmp                    = adres.cdpos
            vcChaineTmp                    = substitute("&1 &2", trim(vcChaineTmp), adres.lbvil)
            vcChaineTmp                    = trim (vcChaineTmp)
            vcTableauLigne[viLigneAdresse] = caps(vcChaineTmp)
            viLigneAdresse                 = viLigneAdresse + 1
        .
        run adresse/fcttelep.p persistent set vhProcFcttelep.
        vcListeTelephone = dynamic-function('DonneListeTel' in vhProcFcttelep, ladrs.tpidt, ladrs.noidt).
        do viCompteur = 1 to 10:
            assign 
                vcTableauLigne[viLigneAdresse] = dynamic-function('donneEntreeTel' in vhProcFcttelep, viCompteur, vcListeTelephone, "")
                viLigneAdresse                 = viLigneAdresse + 1
            .
        end.
        if valid-handle(vhProcFcttelep) then delete object vhProcFcttelep.
        // Ligne PAYS
        assign
            vcChaineTmp = vcLibellePaysLong
            vcChaineTmp = trim(vcChaineTmp)
        .
        if length (vcChaineTmp, "CHARACTER") > piLongueurLigne 
        then assign
            vcChaineTmp = vcLibellePaysCourt
            vcChaineTmp = trim(vcChaineTmp)
        .
        assign
            vcTableauLigne[viLigneAdresse] = vcChaineTmp
            viLigneAdresse                 = viLigneAdresse + 1
            /* PL : 10/07/2014 (0711/0069) */
            /* Ajout Ligne complement identification adresse */ /* PL : 10/07/2014 (0711/0069) */
            vcChaineTmp                    =  adres.cpad2
            vcTableauLigne[viLigneAdresse] = vcChaineTmp
            viLigneAdresse                 = viLigneAdresse + 1
            // Fusion des elements de la chaine adresse
            VcRetour                       = vcTableauLigne[1]
            viNumeroMax                    = viLigneAdresse - 1
        .
        do viLigneAdresse = 2 to viNumeroMax:
            vcRetour = substitute("&1|&2", vcRetour, vcTableauLigne[viLigneAdresse]).
        end.
        return VcRetour.
    end method.

    method public static character getPays(pcCodePays as character):
        /*------------------------------------------------------------------------------
        purpose:
        Notes  : Ancienne fonction FrmPay1 de adb/comm/fctgene.i
        ------------------------------------------------------------------------------*/
        return getPays(pcCodePays, false, mToken:iCodeLangueSession, mToken:iCodeLangueReference).

    end method.

    method public static character getPaysForce(pcCodePays as character):
    /*------------------------------------------------------------------------------
    purpose:
    Notes  : Ancienne fonction FrmPay2 de adb/comm/fctgene.i
    ------------------------------------------------------------------------------*/
        return getPays(pcCodePays, true, mToken:iCodeLangueSession, mToken:iCodeLangueReference).

    end method.

    method static character getPays(pcCodePays as character, plForcage as logical, piCdLngSes as integer, piCdLngRef as integer):
        /*------------------------------------------------------------------------------
        purpose:
        Notes  : Anciennes fonctions FRmPay1 et FrmPay2 de adb/comm/fctgene.i + include CdPayCab.i
        ------------------------------------------------------------------------------*/
        define variable vcCodePaysCabinet as character no-undo.
        define buffer ladrs for ladrs.
        define buffer adres for adres.
        define buffer roles for roles.

        /*--> Recherche du pays du cabinet */
        for first ladrs no-lock
            where ladrs.tpidt = {&TYPEROLE-mandataire}
              and ladrs.noidt = 1
              and ladrs.tpadr = {&TYPEADRESSE-Principale}
          , first adres no-lock
            where adres.noadr = ladrs.noadr:
            vcCodePaysCabinet = adres.cdpay.
        end.
        if vcCodePaysCabinet = "" then do:
            /* Syndic de copro */
            for first roles no-lock 
                where   roles.tprol = {&TYPEROLE-syndic2copro}
                and     roles.norol = 1,
                first ladrs no-lock
                where ladrs.tpidt = roles.tprol 
                and   ladrs.noidt = roles.norol,
                first adres no-lock
                where adres.noadr = ladrs.noadr:
                vcCodePaysCabinet = adres.cdpay.          
            end.                 
        end.
        if pcCodePays <> vcCodePaysCabinet or plForcage
        then return trim(caps(outilTraduction:getLibelleParam("CDPAY", pcCodePays, piCdLngSes, piCdLngRef))).
        return ''.

    end method.

    method public static character getAdresseTelephonesRole(pcTypeRole as character, piNumeroRole as int64):
    /*------------------------------------------------------------------------------
    Purpose: Formate une adresse + tel sur n lignes et separateur (roles et fournisseurs)
    Notes  : ancien frmadr4
    ------------------------------------------------------------------------------*/
        define variable cCodePaysCabinet as character no-undo.
        define variable cSepar           as character no-undo extent 5  initial ["¤","±","Å","¥","º"].
        define variable cRetour          as character no-undo.
        define variable cLibelleBis      as character no-undo.
        define variable cLibellePays     as character no-undo.
        define variable cNoTelephone1    as character no-undo.
        define variable cNoTelephone2    as character no-undo.
        define variable NoFaxUse         as character no-undo.
        define variable iCptNoTel        as integer   no-undo.
        //define variable iNumeroSociete as integer   no-undo.  nath en attente

        define buffer ccptcol    for ccptcol.
        define buffer ifour      for ifour.
        define buffer ilibpays   for ilibpays.
        define buffer telephones for telephones.
        define buffer ladrs      for ladrs.
        define buffer adres      for adres.

        cRetour = fill(cSepar[1], 7).

        /*--> Recherche du pays du cabinet */
        find first ladrs no-lock
            where ladrs.tpidt = {&TYPEROLE-mandataire}
              and ladrs.noidt = 1
              and ladrs.tpadr = "00001" no-error.
        if available ladrs then do:
            find first adres no-lock
                where adres.noadr = ladrs.noadr no-error.
            if available adres then cCodePaysCabinet = adres.cdpay.
        end.
/* nath pb
    define variable voReferenceGeranceCopro as class parametrageReferenceGeranceCopro.
    voReferenceGeranceCopro = new parametrageReferenceGeranceCopro().
    iNumeroSociete = if pcTypeContrat = "" or not voReferenceGeranceCopro:isDbParameter
                     then mToken:iCodeSociete
                     else integer(if pcTypeContrat = {&TYPECONTRAT-mandat2Gerance} then mToken:cRefGerance else mToken:cRefCopro).
    delete object voReferenceGeranceCopro.
*/
        case pcTypeRole:
            when "FOU" then do:
                /* nath en attente de savoir comment on gère les 'FOU'
                for first ccptcol no-lock
                    where ccptCol.tprol = 12
                      /*and ccptcol.soc-cd = mToken:cRefPrincipale*/    /* nath pb */
                   ,first ifour no-lock
                        where ifour.soc-cd          = ccptcol.soc-cd
                          and ifour.coll-cle        = ccptcol.coll-cle
                          and integer(ifour.cpt-cd) = piNumeroRole
                   ,first ilibpays of ifour no-lock:

                    /* Modif SY le 15/07/2015 */
                    find first telephones
                        where telephones.tpidt     = "FOU"
                          and telephones.noidt     = integer(ifour.cpt-cd)
                          and telephones.four-cle  = ifour.four-cle                                       /* SY 30/10/2015 */
                          and telephones.soc-cd    = (if telephones.soc-cd > 0 then ifour.soc-cd else 0)    /* SY 30/10/2015 V12.3 */
                          and telephones.libadr-cd = 0
                          and telephones.tptel     = "00001" no-lock no-error.
                    if available telephones then NoTe1Use = telephones.notel.
                    find first telephones
                        where telephones.tpidt     = "FOU"
                          and telephones.noidt     = integer(ifour.cpt-cd)
                          and telephones.four-cle  = ifour.four-cle                                       /* SY 30/10/2015 */
                          and telephones.soc-cd    = (if telephones.soc-cd > 0 then ifour.soc-cd else 0)    /* SY 30/10/2015 V12.3 */
                          and telephones.libadr-cd = 0
                          and telephones.tptel     = "00002" no-lock no-error.
                    if available telephones then NoFaxUse = telephones.notel.

                    cRetour = trim(ifour.adr[1]) + cSepar[1] +
                              trim(ifour.cp)     + cSepar[1] +
                              trim(ifour.ville)  + cSepar[1] +
                              trim(ifour.adr[2]) + cSepar[1] +
                              trim(NoTe1Use)     + cSepar[1] +
                              trim(NoFaxUse)     + cSepar[1] +
                              trim(ilibpays.lib) + cSepar[1] +
                              "" + cSepar[1] +
                              ""
                    .
                end.*/
            end.
            otherwise do:
                /* Ajout SY le 28/04/2009 : Nlle table telephones */
                for each telephones no-lock
                    where telephones.tpidt = pcTypeRole
                      and telephones.noidt = piNumeroRole
                      and telephones.tptel = "00001"       /* telephone */
                    break by telephones.nopos:
                    iCptNoTel = iCptNoTel + 1.
                    if iCptNoTel = 1 then cNoTelephone1 = telephones.notel.
                    else if iCptNoTel = 2 then cNoTelephone2 = telephones.notel.
                    else leave.
                end.
                find first ladrs no-lock
                    where ladrs.tpidt = pcTypeRole
                      and ladrs.noidt = piNumeroRole
                      and ladrs.tpadr = "00001" no-error.
                if available ladrs then do:
                    find first adres no-lock
                        where adres.noadr = ladrs.noadr no-error.
                    if available adres then do:
                        assign
                            cLibellePays = getPays(adres.cdpay)
                            cLibelleBis  = if ladrs.cdadr = "00000" then "" else (" " + outilTraduction:getLibelleParam("CDADR", ladrs.cdadr))
                            cRetour      = (if ladrs.novoi <> "0" and ladrs.novoi <> "" then ladrs.novoi + cLibelleBis + " " else "") +
                                           (if adres.ntvoi <> {&NATUREVOIE--} then outilTraduction:getLibelleParam("NTVOI", adres.ntvoi) + " " else "") +
                                           trim(adres.lbvoi) + cSepar[1] +
                                           caps(trim(adres.cdpos)) + cSepar[1] +
                                           caps(trim(adres.lbvil)) + cSepar[1] +
                                           trim(adres.cpvoi) + cSepar[1] +
                                           trim(cNoTelephone1)    + cSepar[1] +
                                           trim(cNoTelephone2)    + cSepar[1] +
                                           trim(if cCodePaysCabinet = adres.cdpay then outilTraduction:getLibelleParam("CDPAY",adres.cdpay) else cLibellePays) + cSepar[1] +
                                           adres.lbbur  + cSepar[1] +      /* ajout SY le 28/04/2009 */
                                           adres.cdins  + cSepar[1] +      /* ajout SY le 28/12/2011 */
                                           adres.cpad2                     /* PL : 10/07/2014 (0711/0069) */
                        .
                    end.
                end.
            end.
        end.
        return cRetour.

    end method.

    method public static character formatageTelephone1 (pcTypeRole as character, piNumeroRole as int64):
        /*------------------------------------------------------------------------------
        Purpose: Formate un téléphone
        Notes  : ancien frmtel1
        ------------------------------------------------------------------------------*/
        define variable cValRet       as character no-undo.
        define variable cColl-cle-Fou as character no-undo.

        define buffer ccptcol    for ccptcol.
        define buffer ifour      for ifour.
        define buffer telephones for telephones.

        /* modif SY le 15/04/2010 */
        if pcTypeRole = "FOU" then do:
            /*--> Recherche du regroupement fournisseur */
            find first ccptcol no-lock
                 where ccptcol.soc-cd = mtoken:iCodeSociete
                   and ccptcol.tprole = 12 no-error.
            if available ccptcol then cColl-cle-Fou = ccptcol.coll-cle.
            find first ifour no-lock
                 where ifour.soc-cd   = mtoken:iCodeSociete
                   and ifour.coll-cle = cColl-cle-Fou
                   and integer(ifour.cpt-cd) = piNumeroRole no-error.
            if available ifour then do:
                find first telephones no-lock
                     where telephones.tpidt = pcTypeRole
                       and telephones.noidt = piNumeroRole
                       and telephones.libadr-cd = 0
                       and telephones.tptel = "00001" no-error.
                if available telephones then return telephones.notel.
            end.
        end.
        else do:
            find first telephones no-lock
                 where telephones.tpidt = pcTypeRole
                   and telephones.noidt = piNumeroRole
                   and telephones.tptel = "00001"       /* telephone */
            no-error.
            if available telephones then return telephones.notel.
        end.
        return "".
    end method.

    method public static character getDateFormat(pdaDate as date, pcTypeLibelle as character):
        /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        define variable vcTmp        as character no-undo.
        define variable vcLbDatUse   as character no-undo.
        define variable viNombreMois as character no-undo.
        define variable vcLbMeszon   as character no-undo.
        define variable viLgMesZon   as integer   no-undo.
        define variable vlMesZon     as logical   no-undo.
        define variable TbDayUse     as character no-undo extent 31
        initial ["premier ","deux ","trois ","quatre ","cinq ","six ","sept ","huit ","neuf ", "dix ",
                 "onze ","douze ","treize ","quatorze ","quinze ","seize ","dix-sept ","dix-huit ","dix-neuf ","vingt ",
                 "vingt et un ","vingt deux ","vingt trois ","vingt quatre ","vingt cinq ","vingt six ","vingt sept ","vingt huit ",
                 "vingt neuf ","trente ","trente et un "].
        define variable TbDizUse as character no-undo extent 10
        initial ["dix ","vingt ","trente ","quarante ","cinquante ","soixante ","soixante-dix ","quatre-vingt ", "quatre-vingt-dix "].

        viNombreMois = string(month(pdaDate), "99999").
        if integer(day(pdaDate)) = 1 
        then vcLbMeszon = outilTraduction:getLibelle(44).

        if pcTypeLibelle = "LL" 
        then do:
            vcTmp = string(year(pdaDate), "9999").

            /* Mois */
            vcLbDatUse = TbDayUse[day(pdaDate)] + outilTraduction:getLibelleParam("CDMOI", viNombreMois) + " ". 
            
            /* Millier */
            if integer(substring(vcTmp, 1, 1))= 1 then vcLbDatUse = vcLbDatUse. 
            else vcLbDatUse = vcLbDatUse + TbDayUse[integer(substring(vcTmp, 1, 1))].
            vcLbDatUse = vcLbDatUse + "mille ".

            /* Centaine */
            if integer(substring(vcTmp, 2, 1)) <= 1  
            then vcLbDatUse = vcLbDatUse.
            else vcLbDatUse = vcLbDatUse + TbDayUse[integer(substring(vcTmp, 2, 1))].
                
            if integer(substring(vcTmp, 2, 1)) = 0 
            then vcLbDatUse = vcLbDatUse.
            else do:
                if integer(substring(vcTmp,3,2)) > 0 or integer(substring(vcTmp, 1, 2)) = 1 
                then vcLbDatUse = vcLbDatUse + "cent ".
                else vcLbDatUse = vcLbDatUse + "cents ".
            end.

            /* Dizaine */
            case integer(substring(vcTmp, 3, 1)):
                when 0 then vcLbDatUse = vcLbDatUse.
                when 1 then do:
                    if integer(substring(vcTmp, 4, 1)) = 0 
                    then vcLbDatUse = vcLbDatUse + TbDizUse[integer(substring(vcTmp,3,1))].
                    else vcLbDatUse = vcLbDatUse.
                end.
                when 7 or when 9 then do:
                    if integer(substring(vcTmp, 4, 1)) = 0 
                    then vcLbDatUse = vcLbDatUse + TbDizUse[integer(substring(vcTmp, 3, 1))].
                    else vcLbDatUse = vcLbDatUse + TbDizUse[integer(substring(vcTmp, 3, 1)) - 1].
                end.
                otherwise vcLbDatUse = vcLbDatUse + TbDizUse[integer(substring(vcTmp, 3, 1))].
            end case.

            /* Unite */
            case integer(substring(vcTmp, 3, 1)):
                when 0 then do:
                    case integer(substring(vcTmp, 4, 1)):
                        when 0 then vcLbDatUse = vcLbDatUse.
                        when 1 then vcLbDatUse = vcLbDatUse + "UN".
                        otherwise vcLbDatUse = vcLbDatUse + TbDayUse[integer(substring(vcTmp, 4, 1))].
                    end case.
                end.
                when 1 then do:
                    case integer(substring(vcTmp, 4, 1)):
                        when 0 then vcLbDatUse = vcLbDatUse.
                        otherwise vcLbDatUse = vcLbDatUse + TbDayUse[integer(substring(vcTmp,4,1)) + 10].
                    end.
                end.
                
                when 7 or when 9 then do:
                    case integer(substring(vcTmp, 4, 1)):
                        when 0 then vcLbDatUse = vcLbDatUse.
                        when 1 then vcLbDatUse = vcLbDatUse + "ET ONZE".
                        otherwise vcLbDatUse = vcLbDatUse + TbDayUse[integer(substring(vcTmp, 4, 1)) + 10].
                    end case.
                end.
                otherwise do:
                    case integer(substring(vcTmp, 4, 1)):
                        when 0 then vcLbDatUse = vcLbDatUse.
                        when 1 then vcLbDatUse = vcLbDatUse + "ET UN".
                        otherwise vcLbDatUse = vcLbDatUse + TbDayUse[INT(substring(vcTmp, 4, 1))].
                    end case.
                end.
            end case.
            return caps(vcLbDatUse).
        end.
        else return substitute("&1&2 &3 &4",
           day(pdaDate),
           if integer(day(pdaDate)) = 1 and mToken:iCodeLangueSession = 0 then outilTraduction:getLibelle(44) else "",
           outilTraduction:getLibelleParam("CDMOI", string(month(pdaDate), "99999"), string(pcTypeLibelle = "C", "C/L")),
           year(pdaDate)).

    end method.
    
    method public static character fSubst(pcLibelle as character, pcListeSubst as character):
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        define variable viSubst  as integer   no-undo.
        define variable vcSepar1 as character no-undo.

        assign
            vcSepar1 = if session:cpinternal = 'iso8859-1' then chr(164) else chr(49828)
            viSubst  = num-entries(pcListeSubst, vcSepar1)
        .
        case viSubst:
            when 0 then .
            when 1 then return substitute(pcLibelle,
                                          entry(1, pcListeSubst, vcSepar1)).
            when 2 then return substitute(pcLibelle,
                                          entry(1, pcListeSubst, vcSepar1),
                                          entry(2, pcListeSubst, vcSepar1)).
            when 3 then return substitute(pcLibelle,
                                          entry(1, pcListeSubst, vcSepar1),
                                          entry(2, pcListeSubst, vcSepar1),
                                          entry(3, pcListeSubst, vcSepar1)).
            when 4 then return substitute(pcLibelle,
                                          entry(1, pcListeSubst, vcSepar1),
                                          entry(2, pcListeSubst, vcSepar1),
                                          entry(3, pcListeSubst, vcSepar1),
                                          entry(4, pcListeSubst, vcSepar1)).
            when 5 then return substitute(pcLibelle,
                                          entry(1, pcListeSubst, vcSepar1),
                                          entry(2, pcListeSubst, vcSepar1),
                                          entry(3, pcListeSubst, vcSepar1),
                                          entry(4, pcListeSubst, vcSepar1),
                                          entry(5, pcListeSubst, vcSepar1)).
            when 6 then return substitute(pcLibelle,
                                          entry(1, pcListeSubst, vcSepar1),
                                          entry(2, pcListeSubst, vcSepar1),
                                          entry(3, pcListeSubst, vcSepar1),
                                          entry(4, pcListeSubst, vcSepar1),
                                          entry(5, pcListeSubst, vcSepar1),
                                          entry(6, pcListeSubst, vcSepar1)).
            when 7 then return substitute(pcLibelle,
                                          entry(1, pcListeSubst, vcSepar1),
                                          entry(2, pcListeSubst, vcSepar1),
                                          entry(3, pcListeSubst, vcSepar1),
                                          entry(4, pcListeSubst, vcSepar1),
                                          entry(5, pcListeSubst, vcSepar1),
                                          entry(6, pcListeSubst, vcSepar1),
                                          entry(7, pcListeSubst, vcSepar1)).
            when 8 then return substitute(pcLibelle,
                                          entry(1, pcListeSubst, vcSepar1),
                                          entry(2, pcListeSubst, vcSepar1),
                                          entry(3, pcListeSubst, vcSepar1),
                                          entry(4, pcListeSubst, vcSepar1),
                                          entry(5, pcListeSubst, vcSepar1),
                                          entry(6, pcListeSubst, vcSepar1),
                                          entry(7, pcListeSubst, vcSepar1),
                                          entry(8, pcListeSubst, vcSepar1)).
            otherwise   return substitute(pcLibelle,
                                          entry(1, pcListeSubst, vcSepar1),
                                          entry(2, pcListeSubst, vcSepar1),
                                          entry(3, pcListeSubst, vcSepar1),
                                          entry(4, pcListeSubst, vcSepar1),
                                          entry(5, pcListeSubst, vcSepar1),
                                          entry(6, pcListeSubst, vcSepar1),
                                          entry(7, pcListeSubst, vcSepar1),
                                          entry(8, pcListeSubst, vcSepar1),
                                          entry(9, pcListeSubst, vcSepar1)).
        end case.
    end method.

    method public static character fSubstGestion(pcLibelle as character, pcListeSubst as character):
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        define variable viI       as integer   no-undo.
        define variable viSubst   as integer   no-undo.
        define variable vcSepar1  as character no-undo.
        define variable vcLibelle as character no-undo.

        assign
            vcSepar1 = if session:cpinternal = 'iso8859-1' then chr(164) else chr(49828)
            viSubst  = num-entries(pcListeSubst, vcSepar1)
            vcLibelle  = replace(pcLibelle, '%s', ' ')
        .
        do viI = 1 to viSubst:
            vcLibelle = replace(vcLibelle, '%' + string(viI, "9"), entry(viI, pcListeSubst, vcSepar1)).
        end.      
        return vcLibelle.
    end method.

    method public static character ConvChiffre (pdNombreChiffre as decimal, pcLibelleDevise as character):
        /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        define variable vcRetour as character no-undo.
        define variable TbUniUse as character no-undo extent 10 initial ["UN ","DEUX ","TROIS ","QUATRE ","CINQ ","SIX ","SEPT ","HUIT ","NEUF "].
        define variable TbSpeUse as character no-undo extent 9  initial ["ONZE ","DOUZE ","TREIZE ","QUATORZE ","QUINZE ","SEIZE ","DIX-SEPT ","DIX-HUIT ","DIX-NEUF "].
        define variable TbDizUse as character no-undo extent 10 initial ["DIX ","VINGT ","TRENTE ","QUARANTE ","CINQUANTE ","SOIXANTE ","SOIXANTE ","QUATRE-VINGT ","QUATRE-VINGT "].
        define variable TbChiUse as character no-undo extent 3.
        define variable TbNbrUse as character no-undo extent 2.
        define variable n        as integer   no-undo extent 3.
        define variable i        as integer   no-undo.
        define variable j        as integer   no-undo.
    
        define buffer isoc for isoc.
    
        /* montant calculé dans la devise demandée */
        find first isoc where isoc.soc-cd = mtoken:iCodeSociete no-lock no-error.
        if mtoken:cDeviseSession <> mToken:cDeviseReference
        then pdNombreChiffre = pdNombreChiffre / isoc.tx-euro.
    
        assign
            TbNbrUse[1] = string(abs(pdNombreChiffre), "999999999999.99")
            j           = 1
            TbChiUse    = ""
        .
    
        if truncate(pdNombreChiffre, 0) = 0 then TbChiUse[j] = "ZERO ".
    
        do i = 1 to length(TbNbrUse[1]) by 3:
            TbNbrUse[2] = substring(TbNbrUse[1],i,3).
            assign
                n[1] = integer(substring(TbNbrUse[2], 1, 1)) /*** Centaines ***/
                n[2] = integer(substring(TbNbrUse[2], 2, 1)) /*** Dizaines  ***/
                n[3] = integer(substring(TbNbrUse[2], 3, 1)) /*** Unites    ***/
            .
            if i = 13 then
            do:
                TbNbrUse[2] = "0" + SUBSTRING(TbNbrUse[2],2,2).
                if (truncate(pdNombreChiffre, 0) / 1000000 - truncate(truncate(pdNombreChiffre, 0) / 1000000,0)) = 0 and pdNombreChiffre >= 1 
                then TbChiUse[j] = TbChiUse[j] + "D' ". /* RF 1108/0490 - 19/06/2009 - UN MILLION D'EUROS, et non UN MILLION DE EUROS (en 2009 on oublie les Francs) ! */
                if pcLibelleDevise ne ? and pcLibelleDevise ne "" 
                then TbChiUse[j] = TbChiUse[j] + pcLibelleDevise + ". ".
            end.
            if length(TbChiUse[j]) >= 56 then j = j + 1.
            if j > 4 then j = 3.
            if n[1] = 1 then TbChiUse[j] = TbChiUse[j] + "CENT ".
            else if n[1] > 1 then TbChiUse[j] = TbChiUse[j] + TbUniUse[n[1]] 
                                              + (if n[2] = 0 and n[3] = 0 then "CENTS " else "CENT ").
            if length(TbChiUse[j]) >= 56 then j = j + 1.
            if j > 4 then j = 3.
            if n[2] > 1 then TbChiUse[j] = TbChiUse[j] + TbDizUse[n[2]].
    
            if length(TbChiUse[j]) >= 56 then j = j + 1.
            if j > 4 then j = 3.
            if n[3] = 1 and n[2] > 1 and n[2] < 8 then TbChiUse[j] = TbChiUse[j] + "ET ".
            if n[2] = 1 or n[2] = 7 or n[2] = 9 
            then assign TbChiUse[j] = if n[3] = 0 then TbChiUse[j] + TbDizUse[1] else TbChiUse[j] + TbSpeUse[n[3]].
            else if n[3] ne 0 and (i ne 7 or TbNbrUse[2] ne "001") 
                 then TbChiUse[j] = TbChiUse[j] + TbUniUse[n[3]].
            if length(TbChiUse[j]) >= 56 then j = j + 1.
            if j > 4 then j = 3.
            if i <= 7 and decimal(TbNbrUse[2]) ne 0 
            then do:
                if i = 1 then TbChiUse[j] = TbChiUse[j] + "MILLIARD".
                if i = 4 then TbChiUse[j] = TbChiUse[j] + "MILLION".
                if i = 7 then TbChiUse[j] = TbChiUse[j] + "MILLE".
                if i <= 4 and decimal(TbNbrUse[2]) > 1 then TbChiUse[j] = TbChiUse[j] + "S ".
                else TbChiUse[j] = TbChiUse[j] + " ".
            end.
            else do:
                if i = 13 and (n[2] * 10 + n[3]) >= 1 
                and pcLibelleDevise = "" and pcLibelleDevise ne ? 
                then do:
                    /* RF 1108/0490 - 19/06/2009 - "CENTIME(S)" dans tous les cas */
                    if n[2] * 10 + n[3] = 1 
                    then TbChiUse[j] = TbChiUse[j] + "CENTIME ".
                    else TbChiUse[j] = TbChiUse[j] + "CENTIMES ".
                end.
            end.
            if length(TbChiUse[j]) >= 56 then j = j + 1.
            if j > 4 then j = 3.
        end.
        vcRetour = (if pdNombreChiffre < 0 then "MOINS " else "") + TbChiUse[1] + TbChiUse[2] + TbChiUse[3].
        
        /* RF 1108/0490 - 19/06/2009 - "ET" comme séparateur EUROS / CENTIMES */
        if r-index(trim(vcRetour),".") ne length(trim(vcRetour))
        then vcRetour = replace(vcRetour, ".", " ET").
        else vcRetour = replace(vcRetour, ".", " ").
        return vcRetour.
        
    end method.

    method public static decimal ConvSurface (pdSurface as decimal, pcCodeUnite as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  : service utilisé par uniteLocation.p, createFiche.p, ...
        ------------------------------------------------------------------------------*/
        case pcCodeUnite:
            when {&UNITESURFACE-m2}       then return pdSurface.
            when {&UNITESURFACE-km2}      then return pdSurface * {&Million}.
            when {&UNITESURFACE-cm2}      then return pdSurface / {&DixMille}.
            when {&UNITESURFACE-are}      then return pdSurface * {&Cent}.
            when {&UNITESURFACE-hectare}  then return pdSurface * {&DixMille}.
            when {&UNITESURFACE-centiare} then return pdSurface.
            otherwise return pdSurface.
        end case.
    
    end method.
    
    method public static character formatDureeAMJ (piNombreAnnee as integer, piNombreMois as integer, piNombreJour as integer, piNombreCaractereMax as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable DureeBail as character no-undo.

        DureeBail = (if piNombreAnnee > 0 then string(piNombreAnnee)         + " " + "An" + (if piNombreAnnee > 1 then "s" else "") else "" )
                  + (if piNombreMois  > 0 then " " + string(piNombreMois)    + " " + "mois" else "")
                  + (if piNombreJour  > 0 then " et " + string(piNombreJour) + " " + "jour" + (if piNombreJour > 1 then "s" else "") else "").    /* Modif SY le 25/07/2011 - fiche 0311/0221 : ajout du "et" */
        if piNombreCaractereMax > 0 and length(DureeBail) > piNombreCaractereMax 
        then do:
            DureeBail = (if piNombreAnnee > 0 then string(piNombreAnnee)      + " " + "A" else "" )
                      + (if piNombreMois  > 0 then " " + string(piNombreMois) + " " + "m" else "")
                      + (if piNombreJour  > 0 then " " + string(piNombreJour) + " " + "j" else "").
            if length(DureeBail) > piNombreCaractereMax 
            then DureeBail = (if piNombreAnnee > 0 then string(piNombreAnnee)      + "A" else "" )
                           + (if piNombreMois  > 0 then " " + string(piNombreMois) + "m" else "")
                           + (if piNombreJour  > 0 then " " + string(piNombreJour) + "j" else "").
        end.
        return DureeBail.

    end method.

end class.
