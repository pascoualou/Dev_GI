/*-----------------------------------------------------------------------------
File        : blocecla.p
Purpose     : Verrouillage des comptes locataires en saisie d'encaissement
Author(s)   : DM - 2008/07/02, Kantena - 2018/01/13 
Notes       :
TODO        : à reprendre, techniquement autres possibilités avec les VST 
01  29/10/2008  DM    1008/0247: Ne pas locker les encaissements si acces à ventil manu desactivé
-----------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

define input  parameter pcCodeAction    as character no-undo.
define input  parameter piCodeSociete       as integer   no-undo.
define input  parameter pcCodeEtablissement      as character no-undo.
define input  parameter pcSousCollectif as character no-undo.
define input  parameter pcCompte        as character no-undo.
define input  parameter pcEcran         as character no-undo.
define input  parameter pcCodeJournal   as character no-undo.

define variable NoSesEnc  as character no-undo.   // todo a corriger, commen initialiser ???

define variable gcProg as character no-undo.

find first aparm no-lock
    where aparm.soc-cd = piCodeSociete
      and aparm.tppar  = "VENTM"
      and aparm.cdpar  = "1"
      and aparm.zone2  = "O" no-error.
if not available aparm and pcEcran <> "ECLATM" then return.

case pcCodeAction:
    when "B" or when "M" then do:       /* B = Bloquer ce compte, message si déjà bloqué, M = Pas de message  */
        if lookup(pcSousCollectif, "L,LF") = 0                       /* On ne bloque que ces 2 collectifs */
        or (pcEcran = "OD" and pcCodeJournal <> "ODT") then return.  /* Par les OD, on ne bloque que les ODT */
    
        find first aparm no-lock
            where aparm.soc-cd = piCodeSociete
              and aparm.etab-cd = 0
              and aparm.tppar = "BECLAT"
              and aparm.cdpar = substitute("&1|&2|&3", pcCodeEtablissement, pcSousCollectif, pcCompte) no-error.
        if not available aparm
        then do:
            create aparm.
            assign
                aparm.soc-cd  = piCodeSociete
                aparm.etab-cd = 0
                aparm.tppar   = "BECLAT"
                aparm.cdpar   = substitute("&1|&2|&3", pcCodeEtablissement, pcSousCollectif, pcCompte)
                aparm.lib     = substitute("&1|&2|&3", mtoken:cUser, NoSesEnc, pcEcran)
                aparm.zone2   = aparm.cdpar /* dupliquée pour faciliter la lecture dans l'écran "Autres paramètres" */
            .
        end.
        else if entry(1, aparm.lib, "|") <> mToken:cUser or entry(2, aparm.lib, "|") <> NoSesEnc
        then do: /* utilisé par un autre user */
            if pcCodeAction = "B" then do:
                gcProg = entry(3, aparm.lib, '|').
                if gcProg = "RCH2" then gcProg = "remise de cheques".
                if gcProg = "PREL" then gcProg = "prélèvements".
                if gcProg = "TIP" then gcProg = "intégration des TIP".
                if gcProg = "ECLATM" then gcProg = "Ventilation des encaissements".
                if gcProg = "ECLATA" then gcProg = "éclatement automatique des encaissements".
                /* Le compte  &1 du mandat &2 est utilisé par &3 en &4 */
                mError:createError({&error}, 110750,
                    substitute("&2&1&3&1&4&1&5 &6&1&7", chr(164), pcSousCollectif, pcCompte, pcCodeEtablissement, entry(1, aparm.lib, '|'), entry(2, aparm.lib, '|'), gcProg)).
            end.
            return "FALSE".
        end.
    end.

    when "D" then do:        /* Débloquer ce compte */
        if lookup(pcSousCollectif, "L,LF") = 0 then return. /* On ne bloque que ces 2 collectifs */

        for each aparm exclusive-lock
            where aparm.soc-cd = piCodeSociete
              and aparm.etab-cd = 0
              and aparm.tppar = "BECLAT"
              and aparm.cdpar = substitute("&1|&2|&3", pcCodeEtablissement, pcSousCollectif, pcCompte):
            delete aparm.
        end.
    end.

    when "DU" then do:  /* Débloquer ce compte uniquement pour ce traitement */
        if lookup(pcSousCollectif, "L,LF") = 0 then return. /* On ne bloque que ces 2 collectifs */

        for each aparm exclusive-lock
            where aparm.soc-cd  = piCodeSociete
              and aparm.etab-cd = 0
              and aparm.tppar   = "BECLAT"
              and aparm.lib     = substitute("&1|&2|&3", mtoken:cUser, NoSesEnc, pcEcran)
              and aparm.cdpar   = substitute("&1|&2|&3", pcCodeEtablissement, pcSousCollectif, pcCompte):
            delete aparm.
        end.
    end.

    when "TD" then for each aparm exclusive-lock    /* Tout Débloquer ce compte */
        where aparm.soc-cd  = piCodeSociete
          and aparm.etab-cd = 0
          and aparm.tppar   = "BECLAT"
          and aparm.lib     begins substitute("&1|&2|", mtoken:cUser, NoSesEnc):
        delete aparm.
    end.

    when "T" then do:    /* Tester si le compte est bloqué */
        if lookup(pcSousCollectif, "L,LF") = 0                       /* On ne bloque que ces 2 collectifs */
        or (pcEcran = "OD" and pcCodeJournal <> "ODT") then return.  /* Par les OD, on ne bloque que les ODT */
    
        for first aparm no-lock
            where aparm.soc-cd  = piCodeSociete
              and aparm.etab-cd = 0
              and aparm.tppar   = "BECLAT"
              and aparm.cdpar   = substitute("&1|&2|&3", pcCodeEtablissement, pcSousCollectif, pcCompte):
            if entry(1, aparm.lib, "|") <> mToken:cUser or entry(2, aparm.lib, "|") <> NoSesEnc
            then do:
                gcProg = entry(3,aparm.lib,'|').
                if gcProg = "RCH2" then gcProg = "remise de cheques".
                if gcProg = "PREL" then gcProg = "prélèvements".
                if gcProg = "TIP" then gcProg = "intégration des TIP".
                if gcProg = "ECLATM" then gcProg = "ventilation des encaissements".
                if gcProg = "ECLATA" then gcProg = "éclatement automatique des encaissements".
                /* Le compte  &1 du mandat &2 est utilisé par &3 en &4 */
                mError:createError({&error}, 110750,
                    substitute("&2&1&3&1&4&1&5 &6&1&7", chr(164), pcSousCollectif, pcCompte, pcCodeEtablissement, entry(1, aparm.lib, '|'), entry(2, aparm.lib, '|'), gcProg)).
                return "FALSE".
            end.
        end.
    end.
end case.
return. 
