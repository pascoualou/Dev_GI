/*------------------------------------------------------------------------
File        : controleBancaire.p
Purpose     : Contrôle des coordonées bancaire IBAN/BIC/RIB
Created     : Thu Jul 06 15:02:06 CEST 2017
Notes       : ancien include ctrlsep2.i
derniere revue : 2018/05/18  - ofa - OK
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

function controleIban returns logical(pcIban as character):
    /*---- ISO 13616 -------------------------------------------------------------------------
    1. Contrôler les caractères indésirables (espaces, tirets)
    2. Déplacer les 4 premiers caractères à droite
    3. Convertir les lettres en chiffres via une table de conversion (A=10, B=11, C=12 etc.)
    4. Diviser le nombre ainsi obtenu par 97. Si le reste est égal à 1 l'IBAN est correct
    => BE43 0689 9999 9501
    1ère étape : BE43068999999501
    2ème étape :068999999501BE43
    3ème étape :068999999501111443 avec B=11 et E = 14
    4ème étape :068999999501111443 Modulo 97 = 1
    -----------------------------------------------------------------------------------------*/
    define variable viIndice       as integer   no-undo.
    define variable viPosition     as integer   no-undo.
    define variable vcControle1    as character no-undo.
    define variable vcControle2    as character no-undo.
    define variable vdIban         as decimal   no-undo.
    define variable vdDenominateur as decimal   no-undo.
    define variable viLettre       as integer   no-undo.
    define variable vcLettre       as character no-undo.

    // 1. Contrôler les caractères indésirables (espaces, tirets, ...)
    pcIban = trim(caps(pcIban)).
    if length(pcIban, 'character') < 15 then do:
        mError:createError({&error}, outilTraduction:getLibelle(1000747)). //La longueur de l'Iban est invalide (min = 15 caractères)
        return false.
    end.
boucle:
    do viIndice  = 1 to length(pcIban, 'character'):
        viLettre = asc(substring(pcIban, viIndice, 1, 'character')).
        if  (viLettre < 48 or viLettre > 57) /* 0-9 */
        and (viLettre < 65 or viLettre > 90) /* A-Z */
        then do:
            viPosition = viIndice.
            leave boucle.
        end.
    end.
    if viPosition <> 0 then do:
message "**************  = "  outilTraduction:getLibelle(1000748).
        mError:createError({&error}, substitute(outilTraduction:getLibelle(1000748), substring(pcIban, viPosition, 1, 'character'), viPosition)). //Le caractère "&1" en position &2 de l'IBAN est invalide
        return false.
    end.

    // 2. Déplacer les 4 premiers caractères à droite
    vcControle1 = substitute("&1&2",trim(substring(pcIban, 5)), substring(pcIban, 1, 4, 'character')).

    // 3. Convertir les lettres en chiffres via une table de conversion (A=10, B=11, C=12 etc.)
    do viIndice = 1 to length(vcControle1, 'character'):
        assign
            vcLettre    = substring(vcControle1, viIndice, 1, 'character')
            vcControle2 = substitute("&1&2",vcControle2, (if vcLettre >= "A" and vcLettre <= "Z" then string(asc(vcLettre) - 55, "99") else vcLettre))
        .
    end.

    // 4. Diviser le nombre ainsi obtenu par 97.
    assign
        vdIban         = decimal(vcControle2)
        vdDenominateur = truncate(vdIban / 97, 0)
    .

    if vdIban - (vdDenominateur * 97) <> 1 then do:
        mError:createError({&error}, outilTraduction:getLibelle(1000749)). //IBAN incorrect
        return false.
    end.
    return true.

end function.

function controleBic returns logical(pcBic as character, pcIban as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable viLettre       as integer   no-undo.
    define variable viIndice       as integer   no-undo.
    define variable viPosition     as integer   no-undo.
    define variable vcPaysIban     as character no-undo.

    pcBic = trim(caps(pcBic)).

    // Code pays
    if not can-find(first iPays no-lock
                    where ipays.cdiso2 = substring(pcBic, 5, 2, 'character'))
    then do:
        mError:createError({&error}, substitute(outilTraduction:getLibelle(1000744),substring(pcBic, 5, 2, 'character'))). //Code Pays &1 du code BIC inconnu
        return false.
    end.

    // Longueur
    if length(pcBic, 'character') <> 8 and length(pcBic, 'character') <> 11 then do:
        mError:createError({&error}, outilTraduction:getLibelle(1000745)). //Longueur du code BIC incorrecte. Seuls 8 ou 11 caractères sont autorisés
        return false.
    end.

    // 6 Premiers caractères
boucle:
    do viIndice = 1 to 8:
        viLettre = asc(substring(pcBic, viIndice, 1, 'character')).
        if viIndice <= 6
        and (viLettre < 65 or viLettre > 90 ) /* A-Z*/
        then do:
            viPosition = viIndice.
            leave boucle.
        end.
        if viIndice = 7
        and (viLettre < 50 or viLettre > 57) /* 2-9 */
        and (viLettre < 65 or viLettre > 90) /* A-Z */
        then do:
            viPosition = viIndice.
            leave boucle.
        end.
        if viIndice = 8
        and (viLettre < 48 or viLettre > 57) /* 0-9 */
        and (viLettre < 65 or viLettre > 78) /* A-N */
        and (viLettre < 80 or viLettre > 90) /* P-Z */
        then do:
            viPosition = viIndice.
            leave boucle.
        end.
    end.
    if viPosition > 0 then do:
        mError:createError({&error}, substitute(outilTraduction:getLibelle(1000746), substring(pcBic, viPosition, 1, 'character'), viPosition)). //Le caractère &1 en position &2 du code BIC est invalide
        return false.
    end.
    if length(pcBic, 'character') = 11
    then do viIndice = 9 to 11:
        viLettre = asc(substring(pcBic, viIndice, 1, 'character')).
        if  (viLettre < 48 or viLettre > 57) /* 0-9 */
        and (viLettre < 65 or viLettre > 90) /* A-Z */
        then do:
            mError:createError({&error}, substitute(outilTraduction:getLibelle(1000745), substring(pcBic, viIndice, 1, 'character'), viIndice)).
            return false.
        end.
    end.
    return true.

end function.

function controleIbanBic returns logical(pcBic as character, pcIban as character):
    /*------------------------------------------------------------------------------
    Purpose: permet de lancer le contrôle BIC et IBAN en un seul appel
    Notes  :
    ------------------------------------------------------------------------------*/
    return controleIban(pcIban) and controleBic(pcBic, pcIban).
end function.

function isZoneRIB returns logical (input cIBan as character, input cBic  as character):
  /*---------------------------------------------------------------------------
  Purpose: Sommes nous dans la zone RIB ?
  Notes:
------------------------------------------------------------------------------*/

  return can-find(first ipays no-lock
                  where ipays.cdiso2 = substring(cIban, 1, 2)
                  and iPays.fg-rib).

end function.

function isZoneSEPA returns logical (input cIBan as character, input cBic  as character):
    /*------------------------------------------------------------------------------
    Purpose: Sommes nous dans la zone SEPA ?
    Notes:
    ------------------------------------------------------------------------------*/

     return can-find(first ipays no-lock
                  where ipays.cdiso2 = substring(cIban, 1, 2)
                  and   iPays.fg-sepa)
            and (can-find(first ipays no-lock
                          where ipays.cdiso2 = substring(cBic, 5, 2)
                          and   iPays.fg-sepa) or cBic = "").

end function.
