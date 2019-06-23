/*------------------------------------------------------------------------
File        : mdmws.p
Purpose     : extraction information tiers
Author(s)   : GGA 2018/11/22  - CC 07/12/2012  
Notes       : repris a partir de trans/gene/mdmws.p

 Modifications :
 0001   14/03/2013  OF  Ajout déclaration NoRefGer et NoRefCop pour l'include fctgene.i
 0002   21/03/2013  CC  Passage en majuscule 
 0003   12/04/2013  CC  Erreurs sur adresses
 0004   15/07/2014  CC  Suppression message Exception
 0005   08/07/2015  SY  1013/0126 Prélèvement mensuel des locataires
                        quittancés au Trimestre
 006    16/10/2015  CC  Amélioration des messages
 0007   19/07/2016  SY  Ajout no et nom tiers dans message d'erreur
------------------------------------------------------------------------*/
{preprocesseur/type2role.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2adresse.i}
{preprocesseur/famille2tiers.i}
{preprocesseur/mode2reglement.i}

using parametre.pclie.parametrageBnp.
using parametre.syspg.syspg.

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using

{application/include/glbsepar.i}

function FormatteChaine returns character private (pcChaineIn as character, piLongueurMax as integer):
    /*------------------------------------------------------------------------
    Purpose : tronque une chaine donne une taille donne
    Notes   : 
    ------------------------------------------------------------------------*/
    define variable vcChaineRetour as character no-undo init "".

    vcChaineRetour = right-trim(pcChaineIn).
    vcChaineRetour = trim(vcChaineRetour).
    vcChaineRetour = replace(vcChaineRetour, "&", " ").
    vcChaineRetour = replace(vcChaineRetour, ";", " ").
    if length(vcChaineRetour) > piLongueurMax then vcChaineRetour = substring(vcChaineRetour, 1, piLongueurMax).
    vcChaineRetour = caps(vcChaineRetour).
    return vcChaineRetour.  

end function.

function DonnePays returns character private (pcPaysRole as character):
    /*------------------------------------------------------------------------
    Purpose : Retourne le code iso2 du pays a partir du code iso4 saisi dans les adresses
    Notes   : 
    ------------------------------------------------------------------------*/
    define buffer ipays for ipays. 

    for first ipays no-lock
        where ipays.cdiso4 = string(integer(pcPaysRole), "999"):
        return ipays.cdiso2.
    end.
    return "".  

end function.

function getTelephone returns character private (pcTypeRole as character, piNumeroRole as int64, pcTypeTelephone as character):
    /*------------------------------------------------------------------------------
    Purpose: recherche téléphone
    Notes  : //gga todo voir avec thierry mais si appel depuis trigger comme pour merror (voir plus bas) probleme appel autre pgm pour charger telephone 
    ------------------------------------------------------------------------------*/
    define buffer telephones for telephones.
     
    for first telephones no-lock
        where telephones.tpidt = pcTypeRole
          and telephones.noidt = piNumeroRole
          and telephones.tptel = pcTypeTelephone:
        return telephones.notel.
    end.
    return "".
    
end function.

function Tel returns character private (pcChaineIn as character):
    /*------------------------------------------------------------------------
    Purpose : 
    Notes   : 
    ------------------------------------------------------------------------*/
    define variable vcChaineRetour as character no-undo init "".

    vcChaineRetour = pcChaineIn.
    vcChaineRetour = replace(vcChaineRetour, " ", "").
    vcChaineRetour = replace(vcChaineRetour, ".", "").
    vcChaineRetour = replace(vcChaineRetour, ",", "").
    vcChaineRetour = replace(vcChaineRetour, "/", "").
    vcChaineRetour = replace(vcChaineRetour, "-", "").
    vcChaineRetour = replace(vcChaineRetour, "(", "").
    vcChaineRetour = replace(vcChaineRetour, ")", "").    
    return vcChaineRetour.  

end function.

procedure trtMdmws:
    /*------------------------------------------------------------------------
    Purpose :
    Notes   : service externe
    ------------------------------------------------------------------------*/
    define input parameter piNumeroTiers   as integer   no-undo. 
    define input parameter pcTypeTiers     as character no-undo. 
    define input parameter plGenerationXML as logical   no-undo.

    if not valid-object(merror) then mError = new outils.errorHandler().   //gga todo voir aevc thierry mais si appel depuis trigger merror pas initialise (comment recuperer erreur ?)

    define variable vcFormeJuridique as character no-undo.
    define variable vcNom            as character no-undo.
    define variable vcPrenom         as character no-undo.
    define variable vcFichierXML     as character no-undo.
    define variable vcURLWS          as character no-undo.
    define variable vcInfoTiers      as character no-undo.
    define variable vcChaineExport   as longchar  no-undo.
    define variable vcTypeReglement  as character no-undo.
    define variable vcTitre          as character no-undo.
    define variable vlReturn         as logical   no-undo.
    define variable vcException      as character no-undo.
    define variable vcReponse        as character no-undo.
    define variable vhWebService     as handle    no-undo.
    define variable vhPortType       as handle    no-undo.
    define variable vlConnectWs      as logical   no-undo.
    
    define variable voBnp   as class parametrageBnp no-undo.
    define variable voSyspg as class syspg          no-undo.
   
    define buffer isoc for isoc.
    define buffer tiers for tiers.
    define buffer vbroles for roles.
    define buffer ilienadresse for ilienadresse.
    define buffer ibaseadresse for ibaseadresse.
    define buffer intnt for intnt.
    define buffer tache for tache.
    define buffer ctanx for ctanx.
  
    voBnp = new parametrageBnp().
    if not voBnp:isDbParameter 
    then do:
        delete object voBnp.  
        return.
    end. 
    vcURLWS = voBnp:getUrl().
    delete object voBnp.
    find first isoc no-lock where isoc.specif-cle = 1000 no-error.
    if not available isoc then return.
    find first tiers no-lock where tiers.notie = piNumeroTiers no-error.
    if not available tiers
    then do:
        merror:createError({&error}, substitute("Tiers n° &1 introuvable dans GI", piNumeroTiers)). 
        return.    
    end.        
    find first vbroles no-lock 
         where vbroles.notie = tiers.notie 
           and vbroles.tprol = {&TYPEROLE-locataire} no-error. 
    if not available vbroles 
    then find first vbroles no-lock
              where vbroles.notie = tiers.notie 
                and vbroles.tprol = {&TYPEROLE-coIndivisaire} 
                and can-find (first intnt 
                              where intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
                                and intnt.tpidt = {&TYPEROLE-coIndivisaire}
                                and intnt.noidt = vbroles.norol) no-error.
    if not available vbroles 
    then find first vbroles no-lock
              where vbroles.notie = tiers.notie 
                and vbroles.tprol = {&TYPEROLE-mandant}
                and can-find (first intnt 
                              where intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
                                and intnt.tpidt = {&TYPEROLE-mandant}
                                and intnt.noidt = vbroles.norol) no-error.
    if not available vbroles 
    then find first vbroles no-lock
              where vbroles.notie = tiers.notie 
                and vbroles.tprol = {&TYPEROLE-mandant} no-error.
    if not available vbroles 
    then find first vbroles no-lock
              where vbroles.notie = tiers.notie 
                and vbroles.tprol = {&TYPEROLE-syndicat2copro} no-error.
    if not available vbroles 
    then find first vbroles no-lock
              where vbroles.notie = tiers.notie 
                and vbroles.tprol = {&TYPEROLE-vendeur} no-error.
    if not available vbroles 
    then find first vbroles no-lock
              where vbroles.notie = tiers.notie 
                and vbroles.tprol = {&TYPEROLE-coproprietaire} no-error.
    if not available vbroles 
    then return. 
    vcInfoTiers = "<tier "+ 'xmlns:xs="http://www.w3.org/2001/XMLSchema-instance"' + ">".
    find first iLienAdresse no-lock 
         where iLienAdresse.cTypeAdresse       = {&TYPEADRESSE-Principale}
           and iLienAdresse.cTypeIdentifiant   = vbroles.tprol
           and iLienAdresse.iNumeroIdentifiant = vbroles.norol no-error.
    if not available iLienAdresse then return.  
    find first iBaseAdresse no-lock
         where iBaseAdresse.iNumeroAdresse = iLienAdresse.iNumeroAdresse no-error.
    if not available iBaseAdresse then return.  
    vcInfoTiers = vcInfoTiers 
                     + "<ADRESSE>"
                     + "<RUE1>" + FormatteChaine(iBaseAdresse.cVoie, 40) + "</RUE1>"
                     + "<RUE2>" + FormatteChaine(iBaseAdresse.cComplementDistribution, 40) + "</RUE2>"
                     + "<RUE3>" + "</RUE3>"
                     + "<RUE4>" + "</RUE4>"
                     + "<RUE5>" + "</RUE5>"
                     + "<PAYS>" + FormatteChaine(DonnePays(iBaseAdresse.cCodePays), 2) + "</PAYS>"
                     + "<CODE_POSTAL_LOCALITE>" + FormatteChaine(iBaseAdresse.cCodePostal, 10) + "</CODE_POSTAL_LOCALITE>"
                     + "<LOCALITE>" + FormatteChaine(iBaseAdresse.cVille, 40) + "</LOCALITE>"
                     + "</ADRESSE>"
                     + "<COMPTE_BANCAIRE>"
    .
    if vbroles.tprol = {&TYPEROLE-coproprietaire}
    then do:
        for first intnt no-lock 
            where intnt.tpcon = {&TYPECONTRAT-titre2copro}
              and intnt.tpidt = vbroles.tprol
              and intnt.noidt = vbroles.norol:
            if not can-find (first csscpt
                             where csscpt.soc-cd     = isoc.soc-cd
                               and csscpt.etab-cd    = integer(truncate(intnt.nocon / 100000, 0)) // integer(substring(string(intnt.nocon, "9999999999"), 1, 5))
                               and csscpt.sscoll-cle = "C"
                               and csscpt.cpt-cd     = string(vbroles.norol, "99999"))
            then return.
        end.
    end.
    if vbroles.tprol = {&TYPEROLE-mandant} or vbroles.tprol = {&TYPEROLE-coIndivisaire} 
    then do:
        for last intnt no-lock
           where intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
             and intnt.tpidt = vbroles.tprol
             and intnt.noidt = vbroles.norol:
            if not can-find (first csscpt
                             where csscpt.soc-cd     = isoc.soc-cd
                               and csscpt.etab-cd    = intnt.nocon
                               and csscpt.sscoll-cle = "P"
                               and csscpt.cpt-cd     = string(vbroles.norol, "99999"))
            then return.
            if vbroles.tprol = {&TYPEROLE-coIndivisaire} and num-entries(intnt.lbdiv, "@") >= 1 
            then case entry(1, intnt.lbdiv, "@"):
                when "00000" then vcTypeReglement = "".                   /* "-". */
                when {&MODEREGLEMENT-cheque} then vcTypeReglement = "C".                  /* "Cheque". */
                when "22002" then vcTypeReglement = "V".                  /* "Virement". */
                when "22003" or 
                when "22013" then vcTypeReglement = "P".                  /* "Prelevement". */   /* SY 1013/0126 */
                when "22004" then vcTypeReglement = "W".                  /* "Especes". */
                when "22005" then vcTypeReglement = "V".                  /* "OD de compensation". */
                when "22006" then vcTypeReglement = "P".                  /* "Prlvement mensuel". */
                when "22007" then vcTypeReglement = "V".                  /* "Virement liste". */
                when "22008" then vcTypeReglement = "A".                  /* "Suspendu". */
                when "22009" then vcTypeReglement = "T".                  /* "Manuel". */
                when "22010" then vcTypeReglement = "I".                  /* "T.I.P". */
                when "22015" then vcTypeReglement = "V".                  /* "Compensation". */
                when "22016" then vcTypeReglement = "".                   /* "Telereglement". */
            end case.
            for last tache no-lock
               where tache.tpcon = {&TYPECONTRAT-mandat2Gerance}
                 and tache.nocon = intnt.nocon
                 and tache.tptac = {&TYPETACHE-compteRenduGestion}:
                case tache.ntreg:
                    when "00000" then vcTypeReglement = "".                   /* "-". */
                    when {&MODEREGLEMENT-cheque} then vcTypeReglement = "C".                  /* "Cheque". */
                    when "22002" then vcTypeReglement = "V".                  /* "Virement". */
                    when "22003" or 
                    when "22013" then vcTypeReglement = "P".                  /* "Prelevement". */   /* SY 1013/0126 */
                    when "22004" then vcTypeReglement = "W".                  /* "Especes". */
                    when "22005" then vcTypeReglement = "V".                  /* "OD de compensation". */
                    when "22006" then vcTypeReglement = "P".                  /* "Prlvement mensuel". */
                    when "22007" then vcTypeReglement = "V".                  /* "Virement liste". */
                    when "22008" then vcTypeReglement = "A".                  /* "Suspendu". */
                    when "22009" then vcTypeReglement = "T".                  /* "Manuel". */
                    when "22010" then vcTypeReglement = "I".                  /* "T.I.P". */
                    when "22015" then vcTypeReglement = "V".                  /* "Compensation". */
                    when "22016" then vcTypeReglement = "".                   /* "Telereglement". */
                end case.
            end.
        end.
    end.
    if vbroles.tprol = {&TYPEROLE-locataire} 
    then do:
        if not can-find (first csscpt 
                         where csscpt.soc-cd     = isoc.soc-cd
                           and csscpt.etab-cd    = integer(truncate(vbroles.norol / 100000, 0))   // integer(substring(string(vbroles.norol,"9999999999"),1,5))
                           and csscpt.sscoll-cle = "L"
                           and csscpt.cpt-cd     = string(vbroles.norol modulo 100000))           // substring(string(vbroles.norol,"9999999999"),6,5))
        then return.
        for first tache no-lock
            where tache.tptac = {&TYPETACHE-quittancement}
              and tache.tpcon = {&TYPECONTRAT-bail}
              and tache.nocon = vbroles.norol:
            case tache.cdreg:
                when "00000" then vcTypeReglement = "".                    /* "-". */
                when {&MODEREGLEMENT-cheque} then vcTypeReglement = "C".                   /* "Cheque". */
                when "22002" then vcTypeReglement = "V".                   /* "Virement". */
                when "22003" or 
                when "22013" then vcTypeReglement = "P".                   /* "Prelevement". */    /* SY 1013/0126 */
                when "22004" then vcTypeReglement = "W".                   /* "Especes". */
                when "22005" then vcTypeReglement = "V".                   /* "OD de compensation". */
                when "22006" then vcTypeReglement = "P".                   /* "Prlvement mensuel". */
                when "22007" then vcTypeReglement = "V".                   /* "Virement liste". */
                when "22008" then vcTypeReglement = "A".                   /* "Suspendu". */
                when "22009" then vcTypeReglement = "T".                   /* "Manuel". */
                when "22010" then vcTypeReglement = "I".                   /* "T.I.P". */
                when "22015" then vcTypeReglement = "V".                   /* "Compensation". */
                when "22016" then vcTypeReglement = "".                    /* "Telereglement". */
            end case.
        end.
    end.
    if (vbroles.tprol = {&TYPEROLE-syndicat2copro} 
        or vbroles.tprol = {&TYPEROLE-vendeur} 
        or vbroles.tprol = {&TYPEROLE-acheteur}
        or vbroles.tprol = {&TYPEROLE-coproprietaire} 
        or vbroles.tprol = {&TYPEROLE-coIndivisaire} 
        or vbroles.tprol = {&TYPEROLE-mandant}) 
    and vcTypeReglement = ""
    then vcTypeReglement = "C".
    vcInfoTiers = vcInfoTiers 
                     + "<LIST_COMPTE_BANCAIRES>"
                     + "<BIC>" + "</BIC>"
                     + "<IBAN>" + "</IBAN>"
                     + "<CLE_BANCAIRE>" + "</CLE_BANCAIRE>"
                     + "<CLE_RIB>" + "</CLE_RIB>"
                     + "<NOM_INSTITUT_BANCAIRE>" + "</NOM_INSTITUT_BANCAIRE>"
                     + "<NUM_CB>" + "</NUM_CB>"
                     + "</LIST_COMPTE_BANCAIRES>"
                     + "</COMPTE_BANCAIRE>"
                     + "<COORDONNEE>"
                     + "<ADRESSE_EMAIL>" + FormatteChaine(getTelephone(vbroles.tprol, vbroles.norol, "00003"), 241) + "</ADRESSE_EMAIL>"
                     + "<TELECOPIE>" + Tel(FormatteChaine(right-trim(getTelephone(vbroles.tprol, vbroles.norol, "00010")), 30)) + "</TELECOPIE>"
                     + "<TELEPHONE>" + Tel(FormatteChaine(right-trim(getTelephone(vbroles.tprol, vbroles.norol, "00001")), 30)) + "</TELEPHONE>"
                     + "</COORDONNEE>"
    .
    voSyspg = new syspg().
    voSyspg:reloadUnique("O_CVT", tiers.cdcv1).
    if voSyspg:isDbParameter 
    then case voSyspg:nome1:
        when 701763 then vcTitre = "0002".  /* Monsieur */
        when 702205 then vcTitre = "0002".  /* Monsieur */
        when 701646 then vcTitre = "0002".  /* Monsieur */
        when 701647 then vcTitre = "0002".  /* Monsieur */
        when 701645 then vcTitre = "0002".  /* Monsieur */
        when 701761 then vcTitre = "0002".  /* Monsieur */
        when 701769 then vcTitre = "0002".  /* Monsieur */
        when 701759 then vcTitre = "0002".  /* Monsieur */
        when 702081 then vcTitre = "0002".  /* Monsieur */
        when 701650 then vcTitre = "0001".  /* Madame*/
        when 702802 then vcTitre = "0001".  /* Madame*/
        when 701695 then vcTitre = "0003". /* "STE". */
        when 701651 then vcTitre = "0003". /* "STE". */
        when 701523 then vcTitre = "0005". /* "AGCE". */
        when 701656 then vcTitre = "0006". /* "ASSO". */
        when 701648 then vcTitre = "0006". /* "ASSO". */
        when 701180 then vcTitre = "0006". /* "ASSO". */
        when 702248 then vcTitre = "0006". /* "ASSO". */
        when 701652 then vcTitre = "0007". /* "CIE". */
        when 701654 then vcTitre = "0008". /* "EI". */
        when 701154 then vcTitre = "0009". /* "ETS". */
        when 701653 then vcTitre = "0009". /* "ETS". */
        when 701403 then vcTitre = "0009". /* "ETS". */
        when 701448 then vcTitre = "0009". /* "ETS". */
        when 702336 then vcTitre = "0009". /* "ETS". */
        when 701524 then vcTitre = "0009". /* "ETS". */
        when 702045 then vcTitre = "0009". /* "ETS". */
        when 701655 then vcTitre = "0009". /* "ETS". */
        when 701649 then vcTitre = "0013". /* "ETS". */
    end case.
    vcFormeJuridique = vcTitre.
    if tiers.cdfat = {&FAMILLETIERS-personneMorale} or tiers.cdfat = {&FAMILLETIERS-personneCivile}
    then do:
        voSyspg:reloadUnique("O_SIT", tiers.cdst1).
        if voSyspg:isDbParameter 
        then case voSyspg:nome2:
            when 701684 then vcFormeJuridique = "0014".                                       /* "SA". */
            when 701683 then vcFormeJuridique = "0015".                                       /* "SARL". */
            when 701925 then vcFormeJuridique = "0016".                                       /* "SAS". */
            when 702090 then vcFormeJuridique = "0017".                                       /* "SCA". */
            when 701525 then vcFormeJuridique = "0018".                                       /* "SCI". */
            when 701526 then vcFormeJuridique = "0019".                                       /* "SCP". */
            when 701801 then vcFormeJuridique = "0020".                                       /* SCPI". */
            when 702092 then vcFormeJuridique = "0023".                                       /* "SCS". */
            when 702392 then vcFormeJuridique = "0024".                                       /* "SELR". */
            when 701795 then vcFormeJuridique = "0025".                                       /* "SNC". */
            when 701651 then vcFormeJuridique = "0003".                                       /* "STE". */
            when 701807 then vcFormeJuridique = "0026".                                       /* "SCCV". */
            when 701820 then vcFormeJuridique = "0010".                                       /* "EURL" */
            when 701695 then vcFormeJuridique = (if vcTitre <> "" then vcTitre else "0003").  /*  - */
        end case.
    end.
    delete object voSyspg.
    vcInfoTiers = vcInfoTiers 
                     + "<FORME_JURIDIQUE>" + FormatteChaine(vcFormeJuridique, 4) + "</FORME_JURIDIQUE>"
                     + "<ID_TIERS>" + FormatteChaine(string(tiers.notie), 10) + "</ID_TIERS>"
    .
    if tiers.cdfat = {&FAMILLETIERS-personneMorale} or tiers.cdfat = {&FAMILLETIERS-personneCivile}
    then assign 
             vcNom    = right-trim(tiers.lnom1) + tiers.lpre1
             vcPrenom = ""
    .
    else assign 
             vcNom    = tiers.lnom1 
             vcPrenom = tiers.lpre1 
    .
    assign
        vcNom    = replace(vcNom, "&", " ")
        vcPrenom = replace(vcPrenom, "&", " ")
        vcInfoTiers  = vcInfoTiers 
                          + "<NOM1>" + FormatteChaine(trim(vcPrenom + " " + vcNom), 40) + "</NOM1>"
                          + "<NOM2>" + "</NOM2>"
                          + "<PERSONNE_MORALE>"
                          + "<CLIENT>"
                          + "<AFFECTATION_EC_CLIENT>"
    .
    if pcTypeTiers = "C" 
    then do:
        run infoEntiteComptableClient ("BPRS", vcTypeReglement, vbroles.tprol, input-output vcInfoTiers). 
        run infoEntiteComptableClient ("REPM", vcTypeReglement, vbroles.tprol, input-output vcInfoTiers). 
        run infoEntiteComptableClient ("COSI", vcTypeReglement, vbroles.tprol, input-output vcInfoTiers). 
    end.
    vcInfoTiers = vcInfoTiers 
                     + "</AFFECTATION_EC_CLIENT>"
                     + "<BLOCAGE_CENTRAL_COMPTA_CLIENT>" + (if pcTypeTiers = "C" then "2" else "") + "</BLOCAGE_CENTRAL_COMPTA_CLIENT>"                                                                                                                                                                                                                                                                                                                                                                                          
                     + "<TEMOIN_SUPP_CENTRALE>" + "</TEMOIN_SUPP_CENTRALE>"
                     + "<IDENTIFIANT_SL>" + "</IDENTIFIANT_SL>"
                     + "</CLIENT>"
    .
    find first ctanx no-lock
         where ctanx.tpcon = {&TYPECONTRAT-Association}
           and ctanx.nocon = tiers.nocon no-error.
    vcInfoTiers = vcInfoTiers 
                     + "<SIREN>" + (if available ctanx and ctanx.nosir <> 0 then FormatteChaine(string(ctanx.nosir,"999999999"), 11) else "") + "</SIREN>"
                     + "<SIRET>" + (if available ctanx and ctanx.nosir <> 0 then FormatteChaine(string(ctanx.nosir,"999999999") + string(ctanx.cptbq, "99999"), 16) else "") + "</SIRET>"
    .
    find first ctanx no-lock
         where ctanx.tpcon = {&TYPECONTRAT-TVAIntracommunautaire}
           and ctanx.tprol = {&TYPEROLE-tiers}
           and ctanx.norol = tiers.notie no-error.
    vcInfoTiers = vcInfoTiers 
                     + "<TVA>" + (if available ctanx then FormatteChaine(ctanx.liexe, 20) else "") + "</TVA>"
                     + "<FOURNISSEUR>"
                     + "<AFFECTATION_EC_FOURNISSEUR>"
    .
    if pcTypeTiers = "F" 
    then do:
        run infoEntiteComptableFournisseur ("BPRS", vcTypeReglement, vbroles.tprol, input-output vcInfoTiers). 
        run infoEntiteComptableFournisseur ("REPM", vcTypeReglement, vbroles.tprol, input-output vcInfoTiers). 
        run infoEntiteComptableFournisseur ("COSI", vcTypeReglement, vbroles.tprol, input-output vcInfoTiers). 
    end.
    vcInfoTiers = vcInfoTiers 
                     + "</AFFECTATION_EC_FOURNISSEUR>"
                     + "<BLOCAGE_CENTRAL_COMPTA_FOURNISSEUR>" + (if pcTypeTiers = "F" then "2" else "") + "</BLOCAGE_CENTRAL_COMPTA_FOURNISSEUR>"
                     + "<TEMOIN_SUPP_CENTRALE>" + ""  + "</TEMOIN_SUPP_CENTRALE>"
                     + "<IDENTIFIANT_SL>" + "</IDENTIFIANT_SL>"
                     + "<DATE_BLOCAGE_FOURNISSEUR " + 'xs:nil="true"' + "/>"
                     + "<EST_INTERMEDIAIRE>" + "false" + "</EST_INTERMEDIAIRE>"
                     + "</FOURNISSEUR>"
                     + "<PROFESSION>" + "</PROFESSION>"
                     + "</PERSONNE_MORALE>"
                     + "<SALARIE>"
                     + "<AFFECTATION>" + "</AFFECTATION>"
                     + "<ALLOCATION>" + "</ALLOCATION>"
                     + "<AXE1>" + "</AXE1>"
                     + "<AXE2>" + "</AXE2>"
                     + "<BLOCAGE_CENTRAL_COMPTA_SALARIE>" + "</BLOCAGE_CENTRAL_COMPTA_SALARIE>"
                     + "<DOMICILIATION>" + "</DOMICILIATION>"
                     + "<MATRICULE>" + "</MATRICULE>"
                     + "<TEMOIN_SUPP_CENTRALE>" + "</TEMOIN_SUPP_CENTRALE>"
                     + "<AFFECTATION_EC_SALARIE>" + "</AFFECTATION_EC_SALARIE>"
                     + "<REFOG>" + "</REFOG>"
                     + "</SALARIE>"
                     + "<TYPE_TIERS>" + pcTypeTiers + "</TYPE_TIERS>"
                     + "<BENEFICIAIRE>" + "</BENEFICIAIRE>"
                     + "</tier>". 
    vcChaineExport = codepage-convert(vcInfoTiers, "UTF-8").    
    if plGenerationXML 
    then do:
        vcFichierXML = os-getenv("TMP") 
                       + "\"
                       + "MDM"
                       + "-"
                       + string(year(today),"9999")
                       + string(month(today),"99")
                       + string(day(today),"99")
                       + "-"
                       + pcTypeTiers
                       + "-"
                       + string(tiers.notie,"9999999999")
                       + ".xml".
        copy-lob from vcChaineExport to file vcFichierXML. 
    end.
    run creation-maj (02053, "transfer", "tiers", string(tiers.notie), today, "", "").
    run ConnectWS (vcURLWs, output vhWebService, output vhPortType, output vlConnectWs)  .
    if not vlConnectWs
    then do:
        merror:createError({&information}, "Erreur de communication avec le Web Service - le tiers ne sera pas mis à jour dans le référentiel des tiers comptables - veuillez essayer ultérieurement").             //gga todo erreur ou information
        return. 
    end.       
    run AppelWS (vcChaineExport, string(tiers.notie), vhPortType, output vcException, output vcReponse). 
    if vcReponse <> "OK" 
    then merror:createError({&information}, substitute("Erreur de mise à jour du tiers no &1 - &2 dans le référentiel des tiers comptables - veuillez contacter le support BNPPI", tiers.notie, tiers.lnom1)).             //gga todo erreur ou information
    vlReturn = vhWebService:disconnect() no-error.
    if valid-handle(vhWebService) then delete object vhWebService.
    run creation-maj (02053, "transfer", "tiers", string(tiers.notie), today, vcException, vcReponse).

end procedure.

procedure ConnectWS private:    
    /*----------------------------------------------------------------------------
    Purpose : Connexion au WebService 
    Notes   :
    ----------------------------------------------------------------------------*/      
    define input parameter pcURLWs       as character no-undo.
    define output parameter phWebService as handle    no-undo.
    define output parameter phPortType   as handle    no-undo.   
    define output parameter plConnectWs  as logical   no-undo.

    create server phWebService.
    plConnectWs = phWebService:connect("-WSDL " + pcURLWS ) no-error.
    if not plConnectWs 
    then return.
    run portType set phPortType on phWebService. 
    
end procedure.

procedure AppelWS private:
    /*----------------------------------------------------------------------------
    Purpose : Appel d'une procedure du WebService
    Notes   :
    ----------------------------------------------------------------------------*/      
    define input parameter pcChaineExport  as longchar  no-undo.    
    define input parameter pcApplicationId as character no-undo.
    define input parameter phPortType      as handle    no-undo.
    define output parameter pcExeption     as character no-undo.
    define output parameter pcResponse     as character no-undo.

    define variable vcLogin           as character no-undo.
    define variable vcPassword        as character no-undo.
    define variable vcApplicationCode as character no-undo init "MA".

    /*  RUN ManageThirdParty IN hFTManageThirdParty  */
    /* vcURLWS = "http://pars001i0076:8010/Flows/MDM/THIRDPARTY/Interfaces/intfCreateThirdParty1.0-service.serviceagent?wsdl". */
    
    run CreateThirdParty1.0Op in phPortType (vcLogin, vcPassword, pcChaineExport, pcApplicationId, vcApplicationCode, output pcExeption, output pcResponse) no-error.
    run ErrorInfo. 
 
end procedure.

procedure ErrorInfo private:
    /*----------------------------------------------------------------------------
    Purpose : 
    Notes   :
    ----------------------------------------------------------------------------*/          
    define variable viI               as integer  no-undo.
    define variable vhSOAPFault       as handle   no-undo.
    define variable vhSOAPFaultDetail as handle   no-undo.
    define variable vcHeaderXML       as longchar no-undo.
  
    if error-status:num-messages > 0 
    then do:
        do viI = 1 to error-status:num-messages:
            merror:createError({&information}, substitute("Web Service MDM : &1", 
                                                          error-status:get-message(viI))).             //gga todo erreur ou information
        end.
        if valid-handle(error-status:error-object-detail) 
        then do:
            vhSOAPFault = error-status:error-object-detail.
            merror:createError({&information}, substitute("Web Service MDM - SOAP Error : Fault Code: &1 Fault string: &2 Fault Actor: &3 Error Type: &4", 
                                                          vhSOAPFault:soap-fault-code, 
                                                          vhSOAPFault:soap-fault-string, 
                                                          vhSOAPFault:soap-fault-actor, 
                                                          vhSOAPFault:type)).                          //gga todo erreur ou information
            if valid-handle(vhSOAPFault:soap-fault-detail) 
            then do:
                vhSOAPFaultDetail = vhSOAPFault:soap-fault-detail.
                merror:createError({&information}, substitute("Error Type: &1", 
                                                              vhSOAPFaultDetail:type)).                //gga todo erreur ou information
                vcHeaderXML = vhSOAPFaultDetail:get-serialized().
                merror:createError({&information}, substitute("Web Service MDM - Serialized SOAP fault detail : &1", 
                                                          string(vcHeaderXML))).                       //gga todo erreur ou information
            end.
        end.
    end.
end procedure.

procedure creation-maj private:
    /*----------------------------------------------------------------------------
    Purpose : 
    Notes   :
    ----------------------------------------------------------------------------*/          
    define input parameter  piNoRefLoc-In       as integer   no-undo.
    define input parameter  pcNmLogLoc-In       as character no-undo.
    define input parameter  pcNmTabLoc-In       as character no-undo.
    define input parameter  pcCdEnrLoc-In       as character no-undo.
    define input parameter  pjDateCompLoc-In    as date      no-undo.
    define input parameter  pcGestCdLoc-In      as character no-undo.
    define input parameter  pcMandatCdLoc-In    as character no-undo.
    
    define buffer maj for maj.    
        
    find first maj exclusive-lock 
         where maj.soc-cd = piNoRefLoc-In
           and maj.nmlog  = pcNmLogLoc-In
           and maj.nmtab  = pcNmTabLoc-in
           and maj.cdenr  = pcCdEnrLoc-In no-wait no-error.
    if locked maj 
    then return.
    if not available maj 
    then do:
        create maj.
        assign
            maj.soc-cd   = piNoRefLoc-In
            maj.nmlog    = pcNmLogLoc-In
            maj.nmtab    = pcNmTabLoc-in
            maj.cdenr    = pcCdEnrLoc-In
            maj.jcremvt  = today
            maj.ihcremvt = mtime
        .
    end.                         
    assign
        maj.jmodmvt   = today
        maj.ihmodmvt  = mtime
        maj.DateComp  = pjDateCompLoc-In
        maj.Gest-Cle  = substring(pcGestCdLoc-In, 1, 100)
        maj.Mandat-Cd = substring(pcMandatCdLoc-In, 1, 100)
        maj.jTrf      = ?
        maj.ihTrf     = ?
        maj.nomprog   = os-getenv("USERNAME")
    .
    
end procedure.
  
procedure infoEntiteComptableClient private:
    /*----------------------------------------------------------------------------
    Purpose : 
    Notes   :
    ----------------------------------------------------------------------------*/
    define input parameter pcTypeEc   as character no-undo. 
    define input parameter pcRegl     as character no-undo. 
    define input parameter pcTypeRole as character no-undo.     
    define input-output parameter pcInfoTiers as longchar no-undo. 

    define variable vcCompteCollectif as character no-undo.

    case pcTypeRole:
        when {&TYPEROLE-locataire}
        then vcCompteCollectif = "41117100".
        when {&TYPEROLE-mandant} or when {&TYPEROLE-coIndivisaire} or when {&TYPEROLE-coproprietaire} or when {&TYPEROLE-syndicat2copro} 
        then vcCompteCollectif = "41116420".
    end case.

    pcInfoTiers = pcInfoTiers 
                     + "<LIST_AFFECTATION_ENTITE_COMPTABLE_CLIENT>"
                     + "<EC>" + FormatteChaine(pcTypeEc, 10)+ "</EC>"
                     + "<CORRESPONDANT_CLIENT>" + "</CORRESPONDANT_CLIENT>"
                     + "<MODE_PAIEMENT>"
    .
    if pcRegl <> "" 
    then pcInfoTiers = pcInfoTiers 
                          + "<LIST_MODE_PAIEMENT>"
                          + "<ID_MODE_PAIEMENT>" + pcRegl + "</ID_MODE_PAIEMENT>"
                          + "</LIST_MODE_PAIEMENT>"
    .
    pcInfoTiers = pcInfoTiers 
                     + "</MODE_PAIEMENT>"
                     + "<ORGANISATION_COMMERCIALE>" + "</ORGANISATION_COMMERCIALE>"
                     + "<NUM_ORDRE>" + "</NUM_ORDRE>"
                     + "<COMPTE_COLLECTIF_CLIENT>" + vcCompteCollectif + "</COMPTE_COLLECTIF_CLIENT>"
                     + "</LIST_AFFECTATION_ENTITE_COMPTABLE_CLIENT>"
    .

end procedure.  
    
procedure infoEntiteComptableFournisseur private:
    /*----------------------------------------------------------------------------
    Purpose : 
    Notes   :
    ----------------------------------------------------------------------------*/
    define input parameter pcTypeEc   as character no-undo. 
    define input parameter pcRegl     as character no-undo. 
    define input parameter pcTypeRole as character no-undo. 
    define input-output parameter pcInfoTiers as longchar no-undo. 

    define variable vcCompteCollectif as character no-undo.

    if pcTypeRole = {&TYPEROLE-mandant} or pcTypeRole = {&TYPEROLE-coIndivisaire}
    then vcCompteCollectif = "40111400".
    else vcCompteCollectif = "40110000".

    pcInfoTiers = pcInfoTiers 
                     + "<LIST_AFFECTATION_ENTITE_COMPTABLE_FOURNISSEUR>"
                     + "<DECLARATION_HONORAIRE>" + "</DECLARATION_HONORAIRE>"
                     + "<NUM_ORDRE>" + "</NUM_ORDRE>"
                     + "<EC>" + FormatteChaine(pcTypeEc, 10) + "</EC>"
                     + "<RESPONSABLE_FOURNISSEUR>" + "</RESPONSABLE_FOURNISSEUR>"
                     + "<MODE_PAIEMENT>"
    .
    if pcRegl <> "" 
    then pcInfoTiers = pcInfoTiers 
                          + "<LIST_MODE_PAIEMENT>"
                          + "<ID_MODE_PAIEMENT>" + pcRegl + "</ID_MODE_PAIEMENT>"
                          + "</LIST_MODE_PAIEMENT>"
    .
    pcInfoTiers = pcInfoTiers 
                     + "</MODE_PAIEMENT>"
                     + "<COMPTE_COLLECTIF_FOURNISSEUR>" + vcCompteCollectif + "</COMPTE_COLLECTIF_FOURNISSEUR>"
                     + "</LIST_AFFECTATION_ENTITE_COMPTABLE_FOURNISSEUR>"
    .

end procedure.  
    
    