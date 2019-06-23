block-level on error undo, throw.


&SCOPED-DEFINE MAXRETURNEDROWS  30000

define variable vcOldAddress  as character        no-undo.
define variable giNombreLigne as integer          no-undo.
define stream sFrance.
output stream sFrance      to C:\MAGI\temp\FormatAdresseFour_FRANCE.csv.
define stream sInter.
output stream sInter       to C:\MAGI\temp\FormatAdresseFour_INTER.csv.
define stream sLienAdrFour.
output stream sLienAdrFour to C:\MAGI\temp\lienAdrFour.csv.

// Liste des adresses à traiter
define temp-table ttAddress
    field noadr       as integer
    field cdpay       as character
    field voie1old    as character
    field voie2old    as character
    field voie3old    as character
    field cpold       as character
    field villeold    as character
    field numero      as character
    field voie1new    as character
    field voie2new    as character
    field cpnew       as character
    field villenew    as character
index idx1 is primary unique voie1old voie2old voie3old cpold villeold
index idx2 is unique noadr.

define temp-table ttLienAdresse
    field noadr    as integer
    field nomtable as character
    field four-cle as character
    field soc-cd   as integer
.

boucle_fournisseur:
for each ccptCol no-lock
   where ccptCol.tprol  = 12
     and (ccptcol.soc-cd = 3073
       or ccptcol.soc-cd = 3080)
  , each ifour no-lock
   where ifour.soc-cd = ccptcol.soc-cd
     and ifour.coll-cle = ccptcol.coll-cle
     and ifour.cpt-cd <> "00000"
     and ifour.cpt-cd <> "99999"
     and ifour.fg-actif:

    // Limitation du nombre de fournisseurs traités
    if giNombreLigne >= {&MAXRETURNEDROWS} then leave boucle_fournisseur.

	// IFOUR
    run createttAddress(input buffer ifour:handle).

	// IADRFOUR
	for each iadrfour no-lock
       where iadrfour.soc-cd   = ifour.soc-cd 
	     and iadrfour.four-cle = ifour.four-cle
	     and iadrfour.etab-cd  = ifour.etab-cd:
	   run createttAddress(input buffer iadrfour:handle).
	end.
	
	// ICONTACF
	for each icontacf no-lock
       where icontacf.soc-cd   = ifour.soc-cd 
	     and icontacf.four-cle = ifour.four-cle
	     and icontacf.etab-cd  = ifour.etab-cd:
	    run createttAddress(input buffer icontacf:handle).
	end.

	
    giNombreLigne = giNombreLigne + 1.
end.

run exportData.
output stream sFrance      close.
output stream sInter       close.
output stream slienAdrFour close.

disp "FIN".


procedure exportData:
   /*------------------------------------------------------------------------------
    Purpose: Exporter les données de ttAddress dans un fichier csv
    Notes  :
    -------------------------------------------------------------------------------*/
    // export des données
    for each ttAddress by ttAddress.noadr:
        // Gestion des adresses françaises
        if ttAddress.cdpay = "001"
        then do:
            put stream sFrance unformatted
                    ttAddress.noadr       ";"
                    ttAddress.cdpay       ";"
                    ttAddress.voie1old    ";"
                    ttAddress.voie2old    ";"
                    ttAddress.voie3old    ";"
                    ttAddress.cpold       ";"
                    ttAddress.villeold    ";"
                    ttAddress.numero      ";"
                    ttAddress.voie1new    ";"
                    ttAddress.voie2new    ";"
                    ttAddress.cpnew       ";"
                    ttAddress.villenew
            .
            put stream sFrance skip.
        end.
        // Gestion des adresses internationales
        else do:
            put stream sInter unformatted
                    ttAddress.noadr       ";"
                    ttAddress.cdpay       ";"
                    ttAddress.voie1old    ";"
                    ttAddress.voie2old    ";"
                    ttAddress.voie3old    ";"
                    ttAddress.cpold       ";"
                    ttAddress.villeold    ";"
                    ttAddress.numero      ";"
                    ttAddress.voie1new    ";"
                    ttAddress.voie2new    ";"
                    ttAddress.cpnew       ";"
                    ttAddress.villenew
            .
            put stream sInter skip.
        end.
    end.
    
    for each ttLienAdresse by ttLienAdresse.noadr:
        put stream sLienAdrFour unformatted
            ttLienAdresse.noadr    ";"
            ttLienAdresse.nomtable ";"
            ttLienAdresse.four-cle ";"
            ttLienAdresse.soc-cd
        skip.
    end.

end procedure.

procedure createttAddress:
   /*------------------------------------------------------------------------------
    Purpose: Création des entrées dans ttAddress
    Notes  : Le but est d'éviter les doublons dans la mesure du possible.
    -------------------------------------------------------------------------------*/
    define input parameter phBuffer as handle no-undo.
    define variable cVoie1 as character no-undo.
    define variable cVoie2 as character no-undo.
    define variable cVoie3 as character no-undo.

    define buffer bttAddress for ttAddress.

    assign
        cVoie1    = caps(replace(phBuffer:buffer-field('adr'):buffer-value(1), ',', ''))
        cVoie2    = caps(replace(phBuffer:buffer-field('adr'):buffer-value(2), ',', ''))
        cVoie3    = caps(replace(phBuffer:buffer-field('adr'):buffer-value(3), ',', ''))
        cVoie1    = trim(cVoie1, ' ,.-/')
        cVoie2    = trim(cVoie2, ' ,.-/')
        cVoie3    = trim(cVoie3, ' ,.-/')
    .

    if cVoie1 = "" and cVoie2 = "" and cVoie3 = "" then return.
    
    find first ttAddress 
         where ttAddress.voie1old = cVoie1
           and ttAddress.voie2old = cVoie2
           and ttAddress.voie3old = cVoie3
           and ttAddress.cpold    = phBuffer::cp
           and ttAddress.villeold = trim(phBuffer::ville) no-error.
    if not available ttAddress 
    then do:
        find last bttAddress use-index idx2 no-error.
        create ttAddress.
        assign 
            ttAddress.noadr       = if available bttAddress then bttAddress.noadr + 1 else 1
            ttAddress.cdpay       = phBuffer::libpays-cd
            ttAddress.voie1old    = cVoie1
            ttAddress.voie2old    = cVoie2
            ttAddress.voie3old    = cVoie3
            ttAddress.cpold       = phBuffer::cp
            ttAddress.villeold    = trim(phBuffer::ville)
        .
    end.

    // Création systématique du lien entre le fournisseur courant et l'adresse
    create ttLienAdresse.
    assign 
        ttLienAdresse.nomtable = phBuffer:name
        ttLienAdresse.noadr    = ttAddress.noadr
        ttLienAdresse.four-cle = phBuffer::four-cle
        ttLienAdresse.soc-cd   = phBuffer::soc-cd
    .

end procedure.
