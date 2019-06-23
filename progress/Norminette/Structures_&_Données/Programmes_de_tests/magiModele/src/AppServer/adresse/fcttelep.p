/*------------------------------------------------------------------------------
File        : fcttelep.p
Description : Fonctions pour gérer les téléphones  pour ADB
Author(s)   : 2017/04/26  -  / 06/10/2008 - JR
Notes       :
derniere revue: 2018/05/22 - phm: OK
        certaines fonctions semblent non utilisées.

02  07/10/2008  pl    0908/0140:Ajout libelle personalisable
03  03/06/2010  pl    0409/0320:Adaptation pour fournisseurs compta
04  20/07/2015  SY    Modification index table telephones pour V12.3
05  08/09/2015  OF    Gestion telephones par référence
06  12/11/2015  SY    Pb Gestion telephones fournisseur si même cpt-cd mais collectif différent => ajout four-cle
------------------------------------------------------------------------------*/
{preprocesseur/type2telephone.i}
using parametre.pclie.parametrageLibelleMoyen.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{application/include/glbsepar.i}

 define temp-table ttTypesCodesTelephones no-undo
    field cType        as character
    field cLibelleType as character
    field cCode        as character
    field cLibelleCode as character
    field lGI          as logical
    field cLibelleGI   as character
    index ix_TypesCodesTelephones is primary cCode.

define query qTypesCodesTelephones  for ttTypesCodesTelephones scrolling.

function donneLibTel return character private(pcCodeTelephone as character, pcLibellePerso as character):
    /*------------------------------------------------------------------------------
    Purpose:
    notes  : Si pcLibellePerso rempli, alors on retourne pcLibellePerso
    ------------------------------------------------------------------------------*/
    define variable vcLibelle as character no-undo.
    define variable voLibelleMoyen as class parametrageLibelleMoyen no-undo.

    if pcLibellePerso > "" then return pcLibellePerso.

    assign
        voLibelleMoyen = new parametrageLibelleMoyen(pcCodeTelephone)
        vcLibelle = voLibelleMoyen:getTelephone()
    .
    delete object voLibelleMoyen.
    return vcLibelle.
end function.   

function donneListeTel return character(pcTypeRole as character, piNumeroRole as integer):
    /*------------------------------------------------------------------------------
    Purpose: Retourne la liste par ordre des telephones de l'identifiant
    notes  : service utilisé par outilFormattage.cls
    ------------------------------------------------------------------------------*/
    define variable vcListeRetour as character no-undo.
    define buffer telephones for telephones.

    {&_proparse_ prolint-nowarn(sortaccess)}
    for each telephones no-lock
        where telephones.tpidt = pcTypeRole
          and telephones.noidt = piNumeroRole
        by telephones.nopos:
        vcListeRetour = substitute("&1&2&4&3&5&3&6&3&7",
                                   vcListeRetour, separ[1], separ[2], telephones.tptel, telephones.cdtel, telephones.notel, entry(1, telephones.lbdiv, separ[1])).
    end.
    return trim(vcListeRetour, separ[1]).

end function.

function DonneEntreeTel returns character 
	(piNumeroOrdreTelephone as integer, pcListeTelephones as character, pcSeparateur as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes: service utilisé par outilFormattage.cls
    ------------------------------------------------------------------------------*/	
    define variable vcLibelle as character no-undo.

    if num-entries(pcListeTelephones, separ[1]) >= piNumeroOrdreTelephone then do:
        vcLibelle = donneLibTel(entry(2, entry(piNumeroOrdreTelephone, pcListeTelephones, separ[1]), separ[2]),
                                entry(4, entry(piNumeroOrdreTelephone, pcListeTelephones, separ[1]), separ[2])).
        if vcLibelle > ""
        then vcLibelle = vcLibelle + pcSeparateur + "  "
                       + entry(3, entry(piNumeroOrdreTelephone, pcListeTelephones, separ[1]), separ[2]).
        else vcLibelle = entry(3, entry(piNumeroOrdreTelephone, pcListeTelephones, separ[1]), separ[2]).                  
    end.
    return vcLibelle.
end function.

function getPremierTelephone return character(pcTypeRole as character, piNumeroRole as integer):
    /*------------------------------------------------------------------------------
    Purpose: Retourne le premier téléphone non vide (par ordre des telephones de l'identifiant)
    notes  : service utilisé dans rechercheTiers.p
    ------------------------------------------------------------------------------*/
    define buffer telephones for telephones.

    {&_proparse_ prolint-nowarn(sortaccess)}
    for each telephones no-lock
        where telephones.tpidt = pcTypeRole
          and telephones.noidt = piNumeroRole
          and telephones.tptel = {&TYPETELEPHONE-telephone}
        by telephones.nopos:
        if telephones.notel > "" then return telephones.notel.
    end.
    return "".
end function.

function getPremierMail return character(pcTypeRole as character, piNumeroRole as integer):
    /*------------------------------------------------------------------------------
    Purpose: Retourne le premier mail non vide (par ordre des telephones de l'identifiant)
    notes  : service utilisé dans rechercheTiers.p
    ------------------------------------------------------------------------------*/
    define buffer telephones for telephones.

    {&_proparse_ prolint-nowarn(sortaccess)}
    for each telephones no-lock
        where telephones.tpidt = pcTypeRole
          and telephones.noidt = piNumeroRole
          and telephones.tptel = {&TYPETELEPHONE-mail}
        by telephones.nopos:
        if telephones.notel > "" then return telephones.notel.
    end.
    return "".
end function.

function donnelisteTelFour return character(pcTypeRole as character, piNumeroRole as integer, piTypeAdresse as integer, piNumeroAdresse as integer, piContact as integer):
    /*------------------------------------------------------------------------------
    Purpose: Retourne la liste par ordre des telephones du fournisseur
    notes  :
    ------------------------------------------------------------------------------*/
    define variable vcListeRetour   as character no-undo.
    define buffer telephones for telephones.

    {&_proparse_ prolint-nowarn(sortaccess)}
    for each telephones no-lock
        where telephones.tpidt     = pcTypeRole
          and telephones.noidt     = piNumeroRole
          and telephones.libadr-cd = piTypeAdresse
          and telephones.adr-cd    = piNumeroAdresse
          and telephones.numero    = piContact
        by telephones.nopos:
        vcListeRetour = substitute("&1&2&4&3&5&3&6&3&7",
                                   vcListeRetour, separ[1], separ[2], telephones.tptel, telephones.cdtel, telephones.notel, entry(1, telephones.lbdiv, separ[1])).
    end.
    return trim(vcListeRetour, separ[1]).
end function.

function donnelisteTelFourSoc return character(piNumeroSociete as integer, pcTypeRole as character, piNumeroRole as integer, piTypeAdresse as integer, piNumeroAdresse as integer, piContact as integer):
    /*------------------------------------------------------------------------------
    Purpose: Retourne la liste par ordre des telephones du fournisseur en fonction de la société
    notes  :
    ------------------------------------------------------------------------------*/
    define variable vcListeRetour as character no-undo.
    define buffer telephones for telephones.

    {&_proparse_ prolint-nowarn(sortaccess)}
    for each telephones no-lock
        where telephones.tpidt     = pcTypeRole
          and telephones.noidt     = piNumeroRole
          and telephones.soc-cd    = (if telephones.soc-cd > 0 then piNumeroSociete else 0)
          and telephones.libadr-cd = piTypeAdresse
          and telephones.adr-cd    = piNumeroAdresse
          and telephones.numero    = piContact
        by telephones.nopos:
        vcListeRetour = substitute("&1&2&4&3&5&3&6&3&7",
                                   vcListeRetour, separ[1], separ[2], telephones.tptel, telephones.cdtel, telephones.notel, entry(1, telephones.lbdiv, separ[1])).
    end.
    return trim(vcListeRetour, separ[1]).
end function.

function donnelisteTelFourCleSoc return character(piNumeroSociete as integer, pcTypeRole as character, piNumeroRole as integer, pcCleFournisseur as character, piTypeAdresse as integer, piNumeroAdresse as integer, piContact as integer):
    /*------------------------------------------------------------------------------
    Purpose: Retourne la liste par ordre des telephones du fournisseur en fonction de la société
    notes  : Ajout SY le 12/11/2015 pour remplacer donnelisteTelFourSoc
    ------------------------------------------------------------------------------*/
    define variable vcListeRetour as character no-undo.
    define buffer telephones for telephones.

    {&_proparse_ prolint-nowarn(sortaccess)}
    for each  telephones no-lock
        where telephones.tpidt     = pcTypeRole
          and telephones.noidt     = piNumeroRole
          and telephones.four-cle  = pcCleFournisseur
          and telephones.soc-cd    = (if telephones.soc-cd > 0 then piNumeroSociete else 0)
          and telephones.libadr-cd = piTypeAdresse
          and telephones.adr-cd    = piNumeroAdresse
          and telephones.numero    = piContact
        by telephones.nopos:
        vcListeRetour = substitute("&1&2&4&3&5&3&6&3&7",
                                   vcListeRetour, separ[1], separ[2], telephones.tptel, telephones.cdtel, telephones.notel, entry(1, telephones.lbdiv, separ[1])).
    end.
    return trim(vcListeRetour, separ[1]).
end function.

function donneListePremTpTel return character (pcTypeRole as character, piNumeroRole as integer):
     /*------------------------------------------------------------------------------
    Purpose: retourne la liste des premiers tel de chaque type
    notes  :
    ------------------------------------------------------------------------------*/
    define variable vcListeRetour as character no-undo.
    define buffer telephones for telephones.

    {&_proparse_ prolint-nowarn(sortaccess)}
    for each telephones no-lock
        where telephones.tpidt = pcTypeRole
          and telephones.noidt = piNumeroRole
        by telephones.tptel
        by telephones.nopos:
        vcListeRetour = substitute("&1&2&4&3&5&3&6&3&7",
                                   vcListeRetour, separ[1], separ[2], telephones.tptel, telephones.cdtel, telephones.notel, entry(1, telephones.lbdiv, separ[1])).
    end.
    return trim(vcListeRetour, separ[1]).
end function.

function donnePremTel return character (pcTypeRole as character, piNumeroRole as integer):
     /*------------------------------------------------------------------------------
    Purpose: retourne le premier tel de la liste
    notes  :
    ------------------------------------------------------------------------------*/
    define buffer telephones for telephones.

    for first telephones no-lock
        where telephones.tpidt = pcTypeRole
          and telephones.noidt = piNumeroRole:
        return substitute("&2&1&3&1&4&1&5",
                          separ[1], telephones.tptel, telephones.cdtel, telephones.notel, entry(1, telephones.lbdiv, separ[1])).
    end.
    return substitute("&1&1&1", separ[1]).
end function.

function donnePremTpTel return character (pcTypeRole as character, piNumeroRole as integer, pcTypeTelephone as character):
     /*------------------------------------------------------------------------------
    Purpose:  retourne le premier téléphone telephone pour un type donné
    notes  :
    ------------------------------------------------------------------------------*/
    define buffer telephones for telephones.

    for first telephones no-lock
        where telephones.tpidt = pcTypeRole
          and telephones.noidt = piNumeroRole
          and telephones.tpTel = pcTypeTelephone:
        return substitute("&2&1&3&1&4&1&5",
                          separ[1], telephones.tptel, telephones.cdtel, telephones.notel, entry(1, telephones.lbdiv, separ[1])).
    end.
    return substitute("&1&1&1", separ[1]).
end function.

function donnePremTpTelFour return character (pcTypeRole as character, piNumeroRole as integer, pcTypeTelephone as character, piTypeAdresse as integer, piNumeroAdresse as integer, piContact as integer):
    /*------------------------------------------------------------------------------
    Purpose:
    notes  :
    ------------------------------------------------------------------------------*/
    define buffer telephones for telephones.

    for first telephones no-lock
        where telephones.tpidt     = pcTypeRole
          and telephones.noidt     = piNumeroRole
          and telephones.tpTel     = pcTypeTelephone
          and telephones.libadr-cd = piTypeAdresse
          and telephones.adr-cd    = piNumeroAdresse
          and telephones.numero    = piContact:
        return substitute("&2&1&3&1&4&1&5",
                          separ[1], telephones.tptel, telephones.cdtel, telephones.notel, entry(1, telephones.lbdiv, separ[1])).
    end.
    return substitute("&1&1&1", separ[1]).
end function.

function donnePremTpTelFourSoc return character (piNumeroSociete as integer, pcTypeRole as character, piNumeroRole as integer, pcTypeTelephone as character, piTypeAdresse as integer, piNumeroAdresse as integer, piContact as integer):
     /*------------------------------------------------------------------------------
    Purpose:
    notes  :
    ------------------------------------------------------------------------------*/
    define buffer telephones for telephones.

    for first telephones no-lock
        where telephones.tpidt     = pcTypeRole
          and telephones.noidt     = piNumeroRole
          and telephones.soc-cd    = (if telephones.soc-cd > 0 then piNumeroSociete else 0)
          and telephones.tpTel     = pcTypeTelephone
          and telephones.libadr-cd = piTypeAdresse
          and telephones.adr-cd    = piNumeroAdresse
          and telephones.numero    = piContact:
        return substitute("&2&1&3&1&4&1&5",
                          separ[1], telephones.tptel, telephones.cdtel, telephones.notel, entry(1, telephones.lbdiv, separ[1])).
    end.
    return substitute("&1&1&1", separ[1]).
end function.

function getPremierTelephoneFournisseur returns character (piNumeroSociete as integer, piNumeroRole as integer, pcCleFournisseur as character):
    /*------------------------------------------------------------------------------
    Purpose:
    notes  : service utilisé par rechercheTiers.p
    ------------------------------------------------------------------------------*/
    define buffer telephones for telephones.

    for first telephones no-lock
        where telephones.tpidt     = "FOU"
          and telephones.noidt     = piNumeroRole
          and telephones.four-cle  = pcCleFournisseur
          and telephones.soc-cd    = (if telephones.soc-cd > 0 then piNumeroSociete else 0)
          and telephones.tpTel     = {&TYPETELEPHONE-telephone}
          and telephones.libadr-cd = 0
          and telephones.adr-cd    = 0
          and telephones.numero    = 0:
        return telephones.notel.
    end.
    return "".
end function.

function getPremierFaxFournisseur returns character (piNumeroSociete as integer, piNumeroRole as integer, pcCleFournisseur as character):
    /*------------------------------------------------------------------------------
    Purpose:
    notes  :
    ------------------------------------------------------------------------------*/
    define buffer telephones for telephones.

    for first telephones no-lock
        where telephones.tpidt     = "FOU"
          and telephones.noidt     = piNumeroRole
          and telephones.four-cle  = pcCleFournisseur
          and telephones.soc-cd    = (if telephones.soc-cd > 0 then piNumeroSociete else 0)
          and telephones.tpTel     = {&TYPETELEPHONE-fax}
          and telephones.libadr-cd = 0
          and telephones.adr-cd    = 0
          and telephones.numero    = 0:
        return telephones.notel.
    end.
    return "".
end function.

function getPremierMailFournisseur returns character (piNumeroSociete as integer, piNumeroRole as integer, pcCleFournisseur as character):
    /*------------------------------------------------------------------------------
    Purpose:
    notes  : service utilisé par rechercheTiers.p
    ------------------------------------------------------------------------------*/
    define buffer telephones for telephones.

    for first telephones no-lock
        where telephones.tpidt     = "FOU"
          and telephones.noidt     = piNumeroRole
          and telephones.four-cle  = pcCleFournisseur
          and telephones.soc-cd    = (if telephones.soc-cd > 0 then piNumeroSociete else 0)
          and telephones.tpTel     = {&TYPETELEPHONE-mail}
          and telephones.libadr-cd = 0
          and telephones.adr-cd    = 0
          and telephones.numero    = 0:
        return telephones.notel.
    end.
    return "".
end function.

function donnePremCdTel return character (pcTypeRole as character, piNumeroRole as integer, pcCodeTelephone as character):
    /*------------------------------------------------------------------------------
    Purpose: retourne le premier téléphone telephone pour un code donné
    notes  :
    ------------------------------------------------------------------------------*/
    define buffer telephones for telephones.

    for first telephones no-lock
        where telephones.tpidt = pcTypeRole
          and telephones.noidt = piNumeroRole
          and telephones.cdTel = pcCodeTelephone:
        return substitute("&2&1&3&1&4&1&5",
                          separ[1], telephones.tptel, telephones.cdtel, telephones.notel, entry(1, telephones.lbdiv, separ[1])).
    end.
    return substitute("&1&1&1", separ[1]).
end function.

function donnePremCdTelFour return character (pcTypeRole as character, piNumeroRole as integer, pcCodeTelephone as character, piTypeAdresse as integer, piNumeroAdresse as integer, piContact as integer):
    /*------------------------------------------------------------------------------
    Purpose:
    notes  :
    ------------------------------------------------------------------------------*/
    define buffer telephones for telephones.

    for first telephones no-lock
        where telephones.tpidt     = pcTypeRole
          and telephones.noidt     = piNumeroRole
          and telephones.cdtel     = pcCodeTelephone
          and telephones.libadr-cd = piTypeAdresse
          and telephones.adr-cd    = piNumeroAdresse
          and telephones.numero    = piContact:
        return substitute("&2&1&3&1&4&1&5",
                          separ[1], telephones.tptel, telephones.cdtel, telephones.notel, entry(1, telephones.lbdiv, separ[1])).
    end.
    return substitute("&1&1&1", separ[1]).
end function.

function donnePremCdTelFourSoc return character (piNumeroSociete as integer, pcTypeRole as character, piNumeroRole as integer, pcCodeTelephone as character, piTypeAdresse as integer, piNumeroAdresse as integer, piContact as integer):
    /*------------------------------------------------------------------------------
    Purpose:
    notes  :
    ------------------------------------------------------------------------------*/
    define buffer telephones for telephones.

    for first telephones no-lock
        where telephones.tpidt     = pcTypeRole
          and telephones.noidt     = piNumeroRole
          and telephones.soc-cd    = (if telephones.soc-cd > 0 then piNumeroSociete else 0)
          and telephones.cdTel     = pcCodeTelephone
          and telephones.libadr-cd = piTypeAdresse
          and telephones.adr-cd    = piNumeroAdresse
          and telephones.numero    = piContact:
        return substitute("&2&1&3&1&4&1&5",
                          separ[1], telephones.tptel, telephones.cdtel, telephones.notel, entry(1, telephones.lbdiv, separ[1])).
    end.
    return substitute("&1&1&1", separ[1]).
end function.

function donnePremCdTelFourCleSoc return character(piNumeroSociete as integer, pcTypeRole as character, piNumeroRole as integer, pcCleFournisseur as character, pcCodeTelephone as character, piTypeAdresse as integer, piNumeroAdresse as integer, piContact as integer):
    /*------------------------------------------------------------------------------
    Purpose:
    notes  :  SY le 12/11/2015 pour remplacer donnePremCdTelFourSoc
    ------------------------------------------------------------------------------*/
    define buffer telephones for telephones.

    for first telephones no-lock
        where telephones.tpidt     = pcTypeRole
          and telephones.noidt     = piNumeroRole
          and telephones.four-cle  = pcCleFournisseur
          and telephones.soc-cd    = (if telephones.soc-cd > 0 then piNumeroSociete else 0)
          and telephones.cdTel     = pcCodeTelephone
          and telephones.libadr-cd = piTypeAdresse
          and telephones.adr-cd    = piNumeroAdresse
          and telephones.numero    = piContact:
        return substitute("&2&1&3&1&4&1&5",
                          separ[1], telephones.tptel, telephones.cdtel, telephones.notel, entry(1, telephones.lbdiv, separ[1])).
    end.
    return substitute("&1&1&1", separ[1]).
end function.

procedure dupliqueTelephones:
    /*------------------------------------------------------------------------------
    Purpose: Duplique Telephones (a partir de comm/fcttelep.i)
    notes  : service externe (contractantContrat.p)
    ------------------------------------------------------------------------------*/
    define input parameter pcTpRolUseSrc as character no-undo.
    define input parameter piNoRolUseSrc as integer   no-undo.
    define input parameter pcTpRolUseDes as character no-undo.
    define input parameter piNoRolUseDes as integer   no-undo.

    define buffer telephones   for telephones.
    define buffer vbTelephones for telephones.
    define buffer vbTeladrs    for ladrs.

    find first vbTeladrs no-lock
        where vbTeladrs.tpidt = pcTpRolUseSrc
          and vbTeladrs.noidt = piNoRolUseSrc no-error.
    if not available vbTeladrs then return.

    do transaction on error undo, return:
        for each telephones exclusive-lock
            where telephones.tpidt = pcTpRolUseDes
              and telephones.noidt = piNoRolUseDes:
            delete telephones.
        end.
        for each telephones no-lock
            where telephones.tpidt = pcTpRolUseSrc
              and telephones.noidt = piNoRolUseSrc:
            create vbTelephones.
            buffer-copy telephones
            except telephones.dtcsy
                   telephones.hecsy
                   telephones.cdcsy
                   telephones.dtmsy
                   telephones.hemsy
                   telephones.cdmsy
                   telephones.tpidt
                   telephones.noidt
            to vbTelephones
            assign vbTelephones.dtcsy = today
                   vbTelephones.hecsy = time
                   vbTelephones.cdcsy = mtoken:cUser
                   vbTelephones.tpidt = pcTpRolUseDes
                   vbTelephones.noidt = piNoRolUseDes
            .
        end.
    end.

end procedure.
