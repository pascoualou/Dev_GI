/*------------------------------------------------------------------------------
Purpose: generation preproc des champs fusion
Notes  : kantena - 2018/01/23
------------------------------------------------------------------------------*/
define stream sortie.
define variable vcprefixe as character   no-undo.
define variable viMax     as integer     no-undo.

function getMaximum returns integer (pcCritere as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable miMax as integer     no-undo.
    define buffer champ  for champ.
    define buffer sys_lb for sys_lb.
    for each champ no-lock
        where champ.cdcrt = pcCritere
      , first sys_lb no-lock where nomes = integer(champ.lbchp) and cdlng = 0:
        miMax = maximum(miMax, length(sys_lb.lbmes)).
    end.
    return miMax.
end function.

function prefixe returns character (pcCritere as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    case pcCritere:
        when "00000" then return "".
        when "00001" then return "general".
        when "00002" then return "mandat".
        when "00003" then return "bail".
        when "00004" then return "immeuble".
        when "00005" then return "lot".
        when "00006" then return "document".
        when "00007" then return "destinataire".
        when "00008" then return "salarie".
        when "00009" then return "assurance".
        when "00010" then return "TitreCopro".
        when "00011" then return "syndic".
        when "00012" then return "OrganismeSocial".
        when "00013" then return "Mutation".
        when "00014" then return "DossierMutation".
        when "00015" then return "ContratFour".
        when "00016" then return "prebail".
        when "00017" then return "signalement".
        when "00018" then return "devis".
        when "00019" then return "ordreservice".
        when "00020" then return "AccordReglement".
        when "00021" then return "Accessoire".
        when "00022" then return "garant".
        when "00023" then return "evenement".
        when "00024" then return "fichelocataire".
        when "00025" then return "mandatlocation".
        when "00026" then return "dossiertravaux".
    end CASE.
end function.

    /* calcule longueur maxi de la pre-proc */
    for each champ no-lock
      , first sys_lb no-lock where nomes = integer(champ.lbchp) and cdlng = 0
        break by integer(champ.cdcrt) by champ.lbchp:

        if first-of(integer(champ.cdcrt)) then do:
            assign
                vcPrefixe = lc(prefixe(champ.cdcrt))
                viMax = getMaximum(champ.cdcrt)
            .
            output stream sortie to value("c:/temp/fusion" + caps(substring(vcPrefixe, 1, 1)) + substring(vcPrefixe, 2) + ".i").
            put stream sortie unformatted
                "/*------------------------------------------------------------------------" skip
                "File        : fusion" caps(substring(vcPrefixe, 1, 1)) substring(vcPrefixe, 2) ".i" skip
                "Purpose     : Variables préprocesseur des champs fusion utilisateur " caps(vcPrefixe) skip
                "Author(s)   : Génération automatique le " year(today) "/" month(today) format "99" "/" day(today) format "99" skip
                "Notes       :" skip
                "------------------------------------------------------------------------*/" skip
            .
        end.

        put stream sortie unformatted
            "~&GLOBAL-DEFINE " "FUSION-" 
            replace(replace(replace(replace(sys_lb.lbmes, "é", "e"), "è", "e"), "ô", "o"), "â", "a")
            fill(" ", viMax - length(sys_lb.lbmes) + 1) quoter(champ.lbchp) skip.

        if last-of(integer(champ.cdcrt)) then output stream sortie close.
     end.
