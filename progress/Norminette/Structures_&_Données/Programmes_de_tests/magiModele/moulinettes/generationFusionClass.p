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
    if pcCritere = ?
    then for each champ no-lock
      , first sys_lb no-lock where nomes = integer(champ.lbchp) and cdlng = 0:
        miMax = maximum(miMax, length(sys_lb.lbmes)).
    end.
    else for each champ no-lock
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
    end case.
end function.
    /*   generation de la class globale  */
    output stream sortie to value("c:/temp/fusionWord.cls").
    viMax = getMaximum(?).
    put stream sortie unformatted
        "/*------------------------------------------------------------------------" skip
        "File        : fusionWord.cls" skip
        "Purpose     : Classe des champs fusion utilisateur" skip
        "Author(s)   : Génération automatique le " year(today) "/" month(today) format "99" "/" day(today) format "99" skip
        "Notes       :" skip
        "------------------------------------------------------------------------*/" skip
        "block-level on error undo, throw." skip
        "class fusionWord inherits System.Object:" skip
        "    /*------------------------------------------------------------------------------" skip
        "    purpose:" skip
        "    Notes  :" skip
        "    ------------------------------------------------------------------------------*/" skip
    .
    /* calcule longueur maxi de la pre-proc */
    for each champ no-lock
      , first sys_lb no-lock where sys_lb.nomes = integer(champ.lbchp) and sys_lb.cdlng = 0
        break by sys_lb.lbmes: //by integer(champ.cdcrt) by champ.lbchp:
        if first-of(sys_lb.lbmes) then do:
            put stream sortie unformatted
                "    define public property " 
                replace(replace(replace(replace(sys_lb.lbmes, "é", "e"), "è", "e"), "ô", "o"), "â", "a") fill(" ", viMax - length(sys_lb.lbmes))
                " as character no-undo get. set." skip
            .
        end.
     end.
     put stream sortie unformatted skip(1)
        "    method public void merge(poObject as Progress.Lang.Object):" skip
        "        /*------------------------------------------------------------------------------" skip
        "        purpose:" skip
        "        Notes  :" skip
        "        ------------------------------------------------------------------------------*/" skip
        "        define variable oProperties as Progress.Reflect.Property no-undo extent." skip
        "        define variable vcName      as character no-undo." skip
        "        define variable vi          as integer   no-undo." skip
        "        define variable vcValeur    as character no-undo." skip(1)
        "        oProperties = poObject:GetClass():GetProperties()." skip
        "        do vi = 1 to extent(oProperties):" skip
        "            assign" skip
        "                vcName = oProperties[vi]:Name." skip
        "                vcValeur = dynamic-property(poObject, vcName)" skip
        "            ." skip
        "            dynamic-property(this-object, vcName) = vcValeur no-error." skip
        "        end." skip
        "    end method." skip
        "end class." skip
    .
    for each champ no-lock
      , first sys_lb no-lock where nomes = integer(champ.lbchp) and cdlng = 0
        break by integer(champ.cdcrt) by champ.lbchp:

        if first-of(integer(champ.cdcrt)) then do:
            assign
                vcPrefixe = lc(prefixe(champ.cdcrt))
                viMax     = getMaximum(champ.cdcrt)
            .
            output stream sortie to value("c:/temp/fusion" + caps(substring(vcPrefixe, 1, 1)) + substring(vcPrefixe, 2) + ".cls").
            put stream sortie unformatted
                "/*------------------------------------------------------------------------" skip
                "File        : fusion" caps(substring(vcPrefixe, 1, 1)) substring(vcPrefixe, 2) ".cls" skip
                "Purpose     : Classe des champs fusion utilisateur " caps(vcPrefixe) skip
                "Author(s)   : Génération automatique le " year(today) "/" month(today) format "99" "/" day(today) format "99" skip
                "Notes       :" skip
                "------------------------------------------------------------------------*/" skip
                "block-level on error undo, throw." skip
                "class fusion" caps(substring(vcPrefixe, 1, 1)) substring(vcPrefixe, 2) ":" skip
                "    /*------------------------------------------------------------------------------" skip
                "    purpose:" skip
                "    Notes  :" skip
                "    ------------------------------------------------------------------------------*/" skip
            .
        end.
        if first-of(champ.lbchp) then do:
            put stream sortie unformatted
                "    define public property " 
                replace(replace(replace(replace(sys_lb.lbmes, "é", "e"), "è", "e"), "ô", "o"), "â", "a") fill(" ", viMax - length(sys_lb.lbmes))
                " as character no-undo get. set." skip
            .
        end.
        if last-of(integer(champ.cdcrt)) then do:
            put stream sortie unformatted "end class." skip.
            output stream sortie close.
        end.

    end.
    
