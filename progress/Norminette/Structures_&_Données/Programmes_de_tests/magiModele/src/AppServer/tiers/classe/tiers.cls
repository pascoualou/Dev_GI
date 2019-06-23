/*------------------------------------------------------------------------
File        : tiers.cls
Purpose     :
Author(s)   : kantena - 2017/10/20
Notes       : 
------------------------------------------------------------------------*/
{preprocesseur/famille2tiers.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}

using outils.outilTraduction.
using parametre.pclie.parametrageFormulePolitesse.
block-level on error undo, throw.

class tiers.classe.tiers:
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    define public property numeroTiers           as int64     no-undo get. set.
    define public property typeTiers             as character no-undo get. set.
    define public property titre                 as character no-undo get. set.
    define public property titreLettre           as character no-undo get. set.
    define public property nom                   as character no-undo get. set.
    define public property nomUsuel              as character no-undo get. set.
    define public property nomComplet            as character no-undo get. set.
    define public property prenom                as character no-undo get. set.
    define public property codeFamille           as character no-undo get. set.
    define public property codeSousFamille       as character no-undo get. set.
    define public property libelleDivers         as character no-undo get. set.
    define public property libelleDivers2        as character no-undo get. set.
    define public property codeCivilite          as character no-undo get. set.
    define public property codeParticule         as character no-undo get. set.
    define public property autre                 as character no-undo get. set.
    define public property lieuNaissance         as character no-undo get. set.
    define public property dateNaissance         as date      no-undo get. set.
    define public property codeDepartement       as character no-undo get. set.
    define public property codeNationalite       as character no-undo get. set.
    define public property profession            as character no-undo get. set.
    define public property codeSituation         as character no-undo get. set.
    define public property dSIRET                as decimal   no-undo get. set.
    define public property cSIREN                as character no-undo get. set.
    define public property LbNIC                 as character no-undo get. set.
    define public property LbNAF                 as character no-undo get. set.
    define public property lCareOf               as logical   no-undo get. set.
    define public property lContact              as logical   no-undo get. set.
    define public property libelleFormeJuriLong  as character no-undo get. set.
    define public property libelleFormeJuriCourt as character no-undo get. set.
    define public property libelleFormePolitesse as character no-undo get. set.
    
    constructor public tiers():
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    end constructor.

    constructor public tiers(piNumeroTiers as int64):
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        run chargeTiersPrincipal (piNumeroTiers).
    end constructor.

    constructor public tiers(pcTypeTiers as character, piNumeroTiers as int64):
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        case pcTypeTiers:
            when {&TYPETIERS-principal}  then chargeTiersPrincipal (piNumeroTiers).
            when {&TYPETIERS-secondaire} then chargeTiersSecondaire(piNumeroTiers).
            when {&TYPETIERS-careOf}     then chargeTiersCareOf    (piNumeroTiers).
            when {&TYPETIERS-contact}    then chargeTiersContact   (piNumeroTiers).
        end case.
    end constructor.

    method private void chargeTiersPrincipal(piNumeroTiers as int64):
        /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        define buffer tiers for tiers.

        for first tiers no-lock 
            where tiers.notie = piNumeroTiers:
            assign
                numeroTiers     = tiers.notie
                prenom          = trim(tiers.lpre1)
                nom             = tiers.lnom1
                codeFamille     = tiers.cdfat
                codeSousFamille = tiers.cdsft
                codeSituation   = tiers.cdst1
                codeCivilite    = tiers.cdcv1
                codeParticule   = tiers.cdpr1
                libelleDivers   = tiers.lbdiv
                libelleDivers2  = tiers.lbdiv2
                lieuNaissance   = trim(tiers.lina1)
                codeDepartement = tiers.dpna1
                dateNaissance   = tiers.dtna1
                codeNationalite = tiers.cdna1
                profession      = trim(tiers.lprf1)
                autre           = trim(tiers.lapr1)
                lCareOf         = tiers.fgco3
                lContact        = tiers.fgct4
            .
        end.
    end method.

    method private void chargeTiersSecondaire(piNumeroTiers as int64):
        /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        define buffer tiers for tiers.

        for first tiers no-lock 
            where tiers.notie = piNumeroTiers
              and tiers.lnom2 > "":
            assign
                numeroTiers     = tiers.notie
                prenom          = trim(tiers.lpre2)
                nom             = trim(tiers.lnom2)
                codeFamille     = tiers.cdfat
                codeSousFamille = tiers.cdsft
                codeSituation   = tiers.cdst2
                codeCivilite    = tiers.cdcv2
                codeParticule   = tiers.cdpr2
                libelleDivers   = tiers.lbdiv
                libelleDivers   = tiers.lbdiv2
                lieuNaissance   = trim(tiers.lina2)
                codeDepartement = trim(tiers.dpna2)
                dateNaissance   = tiers.dtna2
                codeNationalite = tiers.cdna2
                profession      = trim(tiers.lprf2)
                autre           = trim(tiers.lapr2)
            .
        end.
    end method.

    method private void chargeTiersCareOf(piNumeroTiers as int64):
        /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        define buffer tiers for tiers.

        for first tiers no-lock 
            where tiers.notie = piNumeroTiers
              and tiers.fgco3 :
            assign
                numeroTiers     = tiers.notie
                codeCivilite    = tiers.cdcv3
                codeParticule   = tiers.cdpr3
                codeFamille     = tiers.cdfat
                codeSousFamille = tiers.cdsft
                prenom          = trim(tiers.lpre3)
                nom             = trim(tiers.lnom3)
                autre           = trim(tiers.lapr3)
                profession      = trim(Tiers.lprf3)
            .
        end.
    end method.

    method private void chargeTiersContact(piNumeroTiers as int64):
        /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        define buffer tiers for tiers.

        for first tiers no-lock 
            where tiers.notie = piNumeroTiers
              and tiers.fgct4:
            assign
                numeroTiers     = tiers.notie
                codeCivilite    = tiers.cdcv4
                codeParticule   = tiers.cdpr4
                codeFamille     = tiers.cdfat
                codeSousFamille = tiers.cdsft
                prenom          = trim(tiers.lpre4)
                nom             = trim(tiers.lnom4)
                autre           = trim(tiers.lapr4)
                profession      = trim(Tiers.lprf4)
            .
        end.
    end method.

    method public character getNom():
        /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
         return (if this-object:prenom > "" then trim(this-object:prenom) + " " else "") + trim(this-object:getNomUsuel()).
    end method.
    
    method public character getNomComplet():
        /*------------------------------------------------------------------------------
         Purpose: Retourne le nom complet
         Notes:
        ------------------------------------------------------------------------------*/
        return trim(this-object:getTitre() + " " + this-object:getNom()).
    end method.
    
    method public character getNomUsuel():
        /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        define variable viCodeFamilleTiers as integer no-undo.

        viCodeFamilleTiers = integer(this-object:codeFamille) no-error.
        if error-status:error or viCodeFamilleTiers <= 9002 then return this-object:nom.

        return this-object:nom + " " + this-object:prenom.
    end method.

    method public character getPrenom():
        /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        define variable viCodeFamilleTiers as integer no-undo.

        viCodeFamilleTiers = integer(this-object:codeFamille) no-error.
        return (if error-status:error or viCodeFamilleTiers > 9002 then "" else this-object:prenom).
    end method.

    method public character getProfession():
        /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:profession.
    end method.

    method public character getCodeCivilite():
        /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:codeCivilite.
    end method.

    method public character getAutre():
        /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:autre.
    end method.

    method public character getDateNaissanceFormatee():
        /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        if this-object:dateNaissance = ? then return "".

        return string(this-object:dateNaissance, "99/99/9999").
    end method.

    method public character getLieuNaissance():
        /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:lieuNaissance.
    end method.

    method public character getLibelleTypeTiers():
        /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        case this-object:codeFamille:
            when {&FAMILLETIERS-personneMorale} then return outilTraduction:getLibelle(111529).
            when {&FAMILLETIERS-personneCivile} then return outilTraduction:getLibelle(111530).
            otherwise return outilTraduction:getLibelle(111528).                                /* Personne physique */
        end case.
    end method.
    
    method public character getNationalite():
        /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        define buffer ipays for ipays.

        for first ipays no-lock
            where ipays.cdiso4 = string(integer(this-object:codeNationalite), "999"):
            return trim(entry(2, ipays.cdiso5, "|")).
        end.
        return "".
    end method.
    
    method public character getLibelleCivilite():
        /*------------------------------------------------------------------------------
         Purpose: Formatage de la civilité
         Notes:
        ------------------------------------------------------------------------------*/
         define variable vcCivilite as character no-undo.

         if this-object:codeCivilite = ? or this-object:codeCivilite = "00000" then return "".

         vcCivilite = outilTraduction:getLibelleProg("O_CVT", this-object:codeCivilite, "C").
         if vcCivilite = "Mr" then return "M.".    // todo - si code langue = fr, car en anglais, Mr = Mr!  ????

         return vcCivilite.
    end method.

    method public character getLibelleParticule():
        /*------------------------------------------------------------------------------
         Purpose: Formatage de la particule
         Notes:
        ------------------------------------------------------------------------------*/
        return if this-object:codeParticule = ? or this-object:codeParticule = "00000"
               then "" else outilTraduction:getLibelleProg("O_PAR", this-object:codeParticule).
    end method.
    
    method public character getTitre():
        /*------------------------------------------------------------------------------
         Purpose: civilité formattée (titre)
         Notes:
        ------------------------------------------------------------------------------*/
        define variable vcLibelleTitre as character no-undo.

        if this-object:codeCivilite <> ? and this-object:codeCivilite <> "00000" 
        then vcLibelleTitre = outilTraduction:getLibelleProg("O_CVT", this-object:codeCivilite, "C").
        return trim(vcLibelleTitre + " " + getLibelleParticule()).

    end method.

   method public character getFormeJuridiqueCourt():
        /*------------------------------------------------------------------------------
         Purpose: Formatage court de la forme juridique
         Notes:
        ------------------------------------------------------------------------------*/
        if (this-object:codeFamille = {&FAMILLETIERS-personneMorale}
         or this-object:codeFamille = {&FAMILLETIERS-personneCivile})
        and this-object:codeSituation <> "00000" 
        then return outilTraduction:getLibelleProg("O_SIT", this-object:codeSituation, "C").
        return "".
    end method.

    method public character getFormeJuridiqueLong():
        /*------------------------------------------------------------------------------
         Purpose: Formatage long de la forme juridique
         Notes:
        ------------------------------------------------------------------------------*/
        if (this-object:codeFamille = {&FAMILLETIERS-personneMorale}
         or this-object:codeFamille = {&FAMILLETIERS-personneCivile})
        and this-object:codeSituation <> "00000"
        then return outilTraduction:getLibelleProg("O_SIT", this-object:codeSituation).
        return "".
    end method.
    
    method public character getFormulePolitesse():
        /*------------------------------------------------------------------------------
         Purpose: Formatage de la civilité (titre)
         Notes:
        ------------------------------------------------------------------------------*/
        if num-entries(this-object:libelleDivers2, "#") >= 3 
        then return entry(3, this-object:libelleDivers2, "#").
        return "".
    end method.

    method public character getSiren():
        /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        define buffer ctanx for ctanx.
        for first ctanx no-lock
             where ctanx.tpcon = {&TYPECONTRAT-TVAIntracommunautaire}
               and ctanx.tprol = {&TYPEROLE-tiers}
               and ctanx.norol = this-object:numeroTiers:
            if ctanx.nosir <> 0 then return string(ctanx.nosir, "999999999").
        end.
        return "".
    end method.

    method public character getNIC():
        /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        define buffer ctanx for ctanx.
        for first ctanx no-lock
             where ctanx.tpcon = {&TYPECONTRAT-TVAIntracommunautaire}
               and ctanx.tprol = {&TYPEROLE-tiers}
               and ctanx.norol = this-object:numeroTiers:
            return (if integer(ctanx.cdnic) <> 0 then ctanx.cdnic else string(ctanx.cptbq)).
        end.
        return "".
    end method.

    method public character getNAF():
        /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        define buffer ctanx for ctanx.
        for first ctanx no-lock
             where ctanx.tpcon = {&TYPECONTRAT-TVAIntracommunautaire}
               and ctanx.tprol = {&TYPEROLE-tiers}
               and ctanx.norol = this-object:numeroTiers:
            return ctanx.cdape.
        end.
        return "".
    end method.

    method public character getCodeDepartement():
        /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:codeDepartement.
    end method.

    method public character getTitreLettre():
        /*------------------------------------------------------------------------------
         Purpose: Formatage des zones titres Lettre
         Notes:
        ------------------------------------------------------------------------------*/
        define variable vcTitreLettre      as character no-undo.
        define variable vcTempo            as character no-undo.
        define variable voFormulePolitesse as class parametre.pclie.parametrageFormulePolitesse no-undo. 

        vcTempo = this-object:libelleDivers2.
        if vcTempo = ? or vcTempo = "" or num-entries(vcTempo, "#") < 2 then vcTempo = "00001#". // Valeur qui devrait être par défaut dans la zone
        if entry(1, vcTempo, "#") = "00003"
        then vcTitreLettre = entry(2, vcTempo, "#").
        else do:
            voFormulePolitesse = new parametrageFormulePolitesse(this-object:codeSousFamille, this-object:codeCivilite, this-object:codeCivilite).
            if not voFormulePolitesse:isDbParameter 
            then voFormulePolitesse = new parametrageFormulePolitesse(this-object:codeSousFamille, this-object:codeCivilite).
            if voFormulePolitesse:isDbParameter
            then case entry(1, vcTempo ,"#"):
                when "00001" then vctitreLettre = voFormulePolitesse:getFormule1().
                when "00002" then vctitreLettre = voFormulePolitesse:getFormule2().
            end case.
        end.
        if valid-object(voFormulePolitesse) then delete object voFormulePolitesse.
        return vctitreLettre.

    end method.

end class.
