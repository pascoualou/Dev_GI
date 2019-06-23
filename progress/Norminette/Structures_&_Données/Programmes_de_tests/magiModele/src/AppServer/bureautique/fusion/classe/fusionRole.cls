/*------------------------------------------------------------------------
File        : fusionRole.cls
Description : 
Author(s)   : kantena - 2018/01/23
Notes       : 
------------------------------------------------------------------------*/

block-level on error undo, throw.

class bureautique.fusion.classe.fusionRole: 
    /* Info principal */
    define public property civilite            as character no-undo get. set.
    define public property particule           as character no-undo get. set.
    define public property titre               as character no-undo get. set.
    define public property nomUsuel            as character no-undo get. set.
    define public property prenom              as character no-undo get. set.
    define public property nom                 as character no-undo get. set.
    define public property nomComplet          as character no-undo get. set.
    define public property profession          as character no-undo get. set.
    define public property dateNaissance       as character no-undo get. set.
    define public property paysNaissance       as character no-undo get. set.
    define public property lieuNaissance       as character no-undo get. set.
    define public property departement         as character no-undo get. set.
    define public property nationalite         as character no-undo get. set.
    define public property formeJuridiqueLong  as character no-undo get. set.
    define public property formeJuridiqueCourt as character no-undo get. set.
    define public property formulePolitesse    as character no-undo get. set.
    define public property typeTiers           as character no-undo get. set.
    define public property autre               as character no-undo get. set.
    define public property titreLettre         as character no-undo get. set.
    define public property initiales           as character no-undo get. set.

    /* Info bis */
    define public property civiliteBis         as character no-undo get. set.
    define public property particuleBis        as character no-undo get. set.
    define public property titreBis            as character no-undo get. set.
    define public property nomUsuelBis         as character no-undo get. set.
    define public property prenomBis           as character no-undo get. set.
    define public property NomBis              as character no-undo get. set.
    define public property nomCompletBis       as character no-undo get. set.
    define public property professionBis       as character no-undo get. set.
    define public property dateNaissanceBis    as character no-undo get. set.
    define public property paysNaissanceBis    as character no-undo get. set.
    define public property lieuNaissanceBis    as character no-undo get. set.
    define public property departementBis      as character no-undo get. set.
    define public property nationaliteBis      as character no-undo get. set.
    define public property autreBis            as character no-undo get. set.

    /* Info CareOf */
    define public property nomC-O              as character no-undo get. set.
    define public property nomCompletC-O       as character no-undo get. set.
    define public property particuleC-O        as character no-undo get. set.
    define public property titreC-O            as character no-undo get. set.
    
    /* Info Representant */
    define public property nomCompletRep       as character no-undo get. set.
    define public property nationaliteRep      as character no-undo get. set.
    
    /* Info Contact */
    define public property nomCompletContact   as character no-undo get. set.
    define public property titreLettreContact  as character no-undo get. set.
    define public property SIREN               as character no-undo get. set.
    define public property NIC                 as character no-undo get. set.
    define public property NAF                 as character no-undo get. set.
    define public property SIRET               as decimal   no-undo get. set.

    /* Info carte professionnelle */
    define public property NumeroCarteProf          as character no-undo get. set.
    define public property DateObtentionCarte       as character no-undo get. set.
    define public property DatelObtentionCarte      as character no-undo get. set.
    define public property DateObtentionCarteLettre as character no-undo get. set.
    define public property LieuObtentionCarte       as character no-undo get. set.
    
    constructor public fusionRole():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/

    end constructor.

    method public character getCivilite():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:civilite.
    end method.
    method public character getParticule():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:particule.
    end method.
    method public character getTitre():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:titre.
    end method.
    method public character getNomUsuel():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:nomUsuel.
    end method.
    method public character getPrenom():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:prenom.
    end method.
    method public character getNom():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:nom.
    end method.
    method public character getNomComplet():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:nomComplet.
    end method.
    method public character getDateNaissance():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:dateNaissance.
    end method.
    method public character getLieuNaissance():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:lieuNaissance.
    end method.
    method public character getDepartement():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:departement.
    end method.
    method public character getProfession():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:profession.
    end method.
    method public character getNationalite():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:nationalite.
    end method.
    method public character getFormeJuridiqueLong():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:formeJuridiqueLong.
    end method.
    method public character getFormeJuridiqueCourt():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:formeJuridiqueCourt.
    end method.
    method public character getFormulePolitesse():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:formulePolitesse.
    end method.
    method public character getTypeTiers():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:typeTiers.
    end method.
    method public character getAutre():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:autre.
    end method.
    method public character getTitreLettre():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:titreLettre.
    end method.
    method public character getCiviliteBis():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:civilite.
    end method.
    method public character getParticuleBis():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:particule.
    end method.
    method public character getTitreBis():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:titre.
    end method.
    method public character getNomUsuelBis():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:nomUsuel.
    end method.
    method public character getPrenomBis():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:prenom.
    end method.
    method public character getNomBis():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:nom.
    end method.
    method public character getNomCompletBis():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:nomComplet.
    end method.
    method public character getDateNaissanceBis():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:dateNaissance.
    end method.
    method public character getLieuNaissanceBis():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:lieuNaissance.
    end method.
    method public character getDepartementBis():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:departement.
    end method.
    method public character getProfessionBis():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:profession.
    end method.
    method public character getNationaliteBis():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:nationalite.
    end method.
    method public character getAutreBis():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:autreBis.
    end method.
    method public character getNomC-O():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:nomC-O.
    end method.
    method public character getNomCompletC-O():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:nomCompletC-O.
    end method.
    method public character getParticuleC-O():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:particuleC-O.
    end method.
    method public character getTitreC-O():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:titreC-O.
    end method.
    method public character getNomCompletRep():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:nomCompletRep.
    end method.
    method public character getNationaliteRep():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:nationaliteRep.
    end method.
    method public character getNomCompletContact():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:nomCompletContact.
    end method.
    method public character getTitreLettreContact():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:titreLettreContact.
    end method.
    method public character getSIREN():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:SIREN.
    end method.
    method public character getNIC():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:NIC.
    end method.
    method public character getNAF():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:NAF.
    end method.
    method public decimal getSIRET():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:SIRET.
    end method.
    method public character getNumeroCarteProf():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:NumeroCarteProf.
    end method.
    method public character getDateObtentionCarte():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:DateObtentionCarte.
    end method.
    method public character getDateObtentionCarteLettre():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:DateObtentionCarteLettre.
    end method.
    method public character getLieuObtentionCarte():
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        return this-object:LieuObtentionCarte.
    end method.




    method public void setCivilite(pcParam as character):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        this-object:civilite = pcParam.
    end method.
    method public void setParticule(pcParam as character):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        this-object:particule = pcParam.
    end method.
    method public void setTitre(pcParam as character):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        this-object:titre = pcParam.
    end method.
    method public void setNomUsuel(pcParam as character):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        this-object:nomUsuel = pcParam.
    end method.
    method public void setPrenom(pcParam as character):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        this-object:prenom = pcParam.
    end method.
    method public void setNom(pcParam as character):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        this-object:nom = pcParam.
    end method.
    method public void setNomComplet(pcParam as character):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        this-object:nomComplet = pcParam.
    end method.
    method public void setDateNaissance(pcParam as character):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        this-object:dateNaissance = pcParam.
    end method.
    method public void setLieuNaissance(pcParam as character):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        this-object:lieuNaissance = pcParam.
    end method.
    method public void setDepartement(pcParam as character):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        this-object:departement = pcParam.
    end method.
    method public void setProfession(pcParam as character):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        --------------------------------------------------------------------------------*/
        this-object:profession = pcParam.
    end method.
    method public void setNationalite(pcParam as character):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        --------------------------------------------------------------------------------*/
        this-object:nationalite = pcParam.
    end method.
    method public void setFormeJuridiqueLong(pcParam as character):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        --------------------------------------------------------------------------------*/
        this-object:formeJuridiqueLong = pcParam.
    end method.
    method public void setFormeJuridiqueCourt(pcParam as character):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        --------------------------------------------------------------------------------*/
        this-object:formeJuridiqueCourt = pcParam.
    end method.
    method public void setFormulePolitesse(pcParam as character):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        --------------------------------------------------------------------------------*/
        this-object:formulePolitesse = pcParam.
    end method.
    method public void setTypeTiers(pcParam as character):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        --------------------------------------------------------------------------------*/
        this-object:typeTiers = pcParam.
    end method.
    method public void setAutre(pcParam as character):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        --------------------------------------------------------------------------------*/
        this-object:autre = pcParam.
    end method.
    method public void setTitreLettre(pcParam as character):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        --------------------------------------------------------------------------------*/
        this-object:titreLettre = pcParam.
    end method.
    
    
    
    method public void setCiviliteBis(pcParam as character):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        --------------------------------------------------------------------------------*/
        this-object:civiliteBis = pcParam.
    end method.
    method public void setParticuleBis(pcParam as character):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        --------------------------------------------------------------------------------*/
        this-object:particuleBis = pcParam.
    end method.
    method public void setTitreBis(pcParam as character):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        --------------------------------------------------------------------------------*/
        this-object:titreBis = pcParam.
    end method.
    method public void setNomUsuelBis(pcParam as character):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        --------------------------------------------------------------------------------*/
        this-object:nomUsuelBis = pcParam.
    end method.
    method public void setPrenomBis(pcParam as character):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        --------------------------------------------------------------------------------*/
        this-object:prenomBis = pcParam.
    end method.
    method public void setNomBis(pcParam as character):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        --------------------------------------------------------------------------------*/
        this-object:nomBis= pcParam.
    end method.
    method public void setNomCompletBis(pcParam as character):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        --------------------------------------------------------------------------------*/
        this-object:nomCompletBis = pcParam.
    end method.
    method public void setDateNaissanceBis(pcParam as character):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        --------------------------------------------------------------------------------*/
        this-object:dateNaissanceBis = pcParam.
    end method.
    method public void setLieuNaissanceBis(pcParam as character):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        --------------------------------------------------------------------------------*/
        this-object:lieuNaissanceBis = pcParam.
    end method.
    method public void setDepartementBis(pcParam as character):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        --------------------------------------------------------------------------------*/
        this-object:departementBis = pcParam.
    end method.
    method public void setProfessionBis(pcParam as character):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        --------------------------------------------------------------------------------*/
        this-object:professionBis = pcParam.
    end method.
    method public void setNationaliteBis(pcParam as character):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        --------------------------------------------------------------------------------*/
        this-object:nationaliteBis = pcParam.
    end method.
    method public void setAutreBis(pcParam as character):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        --------------------------------------------------------------------------------*/
        this-object:autreBis = pcParam.
    end method.
    method public void setNomC-O(pcParam as character):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        --------------------------------------------------------------------------------*/
        this-object:nomC-O = pcParam.
    end method.
    method public void setNomCompletC-O(pcParam as character):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        --------------------------------------------------------------------------------*/
        this-object:nomCompletC-O = pcParam.
    end method.
    method public void setParticuleC-O(pcParam as character):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        --------------------------------------------------------------------------------*/
        this-object:particuleC-O = pcParam.
    end method.
    method public void setTitreC-O(pcParam as character):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        --------------------------------------------------------------------------------*/
        this-object:titreC-O = pcParam.
    end method.
    method public void setNomCompletRep(pcParam as character):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        --------------------------------------------------------------------------------*/
        this-object:nomCompletRep = pcParam.
    end method.
    method public void setNationaliteRep(pcParam as character):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        --------------------------------------------------------------------------------*/
        this-object:nationaliteRep = pcParam.
    end method.
    method public void setNomCompletContact(pcParam as character):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        --------------------------------------------------------------------------------*/
        this-object:nomCompletContact = pcParam.
    end method.
    method public void setTitreLettreContact(pcParam as character):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        --------------------------------------------------------------------------------*/
        this-object:titreLettreContact = pcParam.
    end method.
    method public void setSIREN(pcParam as character):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        --------------------------------------------------------------------------------*/
        this-object:SIREN = pcParam.
    end method.
    method public void setNIC(pcParam as character):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        --------------------------------------------------------------------------------*/
        this-object:NIC = pcParam.
    end method.
    method public void setNAF(pcParam as character):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        --------------------------------------------------------------------------------*/
        this-object:NAF = pcParam.
    end method.
    method public void setSIRET(pcParam as decimal):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        --------------------------------------------------------------------------------*/
        this-object:SIRET = pcParam.
    end method.
    method public void setNumeroCarteProf(pcParam as character):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        --------------------------------------------------------------------------------*/
        this-object:NumeroCarteProf = pcParam.
    end method.
    method public void setDateObtentionCarte(pcParam as character):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        --------------------------------------------------------------------------------*/
        this-object:DateObtentionCarte = pcParam.
    end method.
    method public void setDateObtentionCarteLettre(pcParam as character):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        --------------------------------------------------------------------------------*/
        this-object:DateObtentionCarteLettre = pcParam.
    end method.
    method public void setLieuObtentionCarte(pcParam as character):
         /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        --------------------------------------------------------------------------------*/
        this-object:lieuObtentionCarte = pcParam.
    end method.

end class.