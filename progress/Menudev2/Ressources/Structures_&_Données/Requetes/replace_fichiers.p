define variable cFichier as character no-undo.
define variable cLigne as character no-undo.
define variable cRepertoirePere as character no-undo init "H:\dev\outils\progress\Menudev2\Ressources\Utilisateurs\PPL.DEV".
define variable cCible as character no-undo.
define variable cRef as character no-undo.

define temp-table ttFichiers
    field cNom as character 
    field cNomComplet as character 
    .

input from os-dir(cRepertoirePere) NO-ATTR-LIST.

repeat:
    create ttFichiers.
    import ttFichiers.
end.

for each ttFichiers:

    if ttFichiers.cNom = "" then next.
    if not ttFichiers.cNom begins "t" then next.
    if num-entries(ttFichiers.cNom,"_") < 2 then next.
    
    cCible = entry(2,ttFichiers.cNom,"-").
    cRef = entry(1,ttFichiers.cNom,"-").

    os-copy value(cRepertoirePere + "\" + ttFichiers.cNom) value("e:\bases\" + cRef + "\" + cCible).
    /*message "Copy de " + cRepertoirePere + "\" + ttFichiers.cNom + "   sur   " + "e:\bases\" + cRef + "\" + cCible view-as alert-box.*/

end.

input close.