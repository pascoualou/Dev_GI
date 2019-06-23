/*------------------------------------------------------------------------
File        : fusionGeneral.cls
Purpose     : Classe des champs fusion utilisateur GENERAL
Author(s)   : Génération automatique le 2018/01/25
Notes       :
------------------------------------------------------------------------*/
block-level on error undo, throw.
class bureautique.fusion.classe.fusionGeneral:
    /*------------------------------------------------------------------------------
    purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define public property TelephoneCabinet               as character no-undo get. set.
    define public property BanqueCabinet                  as character no-undo get. set.
    define public property NoCompteBancaireCabinet        as character no-undo get. set.
    define public property DatelobtentionCarte            as character no-undo get. set.
    define public property DateobtentionCarteLettre       as character no-undo get. set.
    define public property FaxCabinet                     as character no-undo get. set.
    define public property PaysGarant                     as character no-undo get. set.
    define public property emailCabinet                   as character no-undo get. set.
    define public property VilleCedex_cabinet             as character no-undo get. set.
    define public property NoBICCabinet                   as character no-undo get. set.
    define public property DatePassagePrelSePaCopropriete as character no-undo get. set.
    define public property DelaiNotifPrelSePaCopropriete  as character no-undo get. set.
    define public property NomReclamPrelSePaCopropriete   as character no-undo get. set.
    define public property NomModifPrelSePaCopropriete    as character no-undo get. set.
    define public property DatePassagePrelSePaGerance     as character no-undo get. set.
    define public property DelaiNotifPrelSePaGerance      as character no-undo get. set.
    define public property NomReclamPrelSePaGerance       as character no-undo get. set.
    define public property NomModifPrelSePaGerance        as character no-undo get. set.
    define public property Titre_cabinet                  as character no-undo get. set.
    define public property Nom_Cabinet                    as character no-undo get. set.
    define public property Adresse_cabinet                as character no-undo get. set.
    define public property Suite_adresse_cabinet          as character no-undo get. set.
    define public property Code_postal_cabinet            as character no-undo get. set.
    define public property Ville_cabinet                  as character no-undo get. set.
    define public property Numero_Carte_Prof              as character no-undo get. set.
    define public property Date_obtention_carte           as character no-undo get. set.
    define public property Lieu_obtention_carte           as character no-undo get. set.
    define public property Syndicat_professionnel         as character no-undo get. set.
    define public property Garantie_financiere            as character no-undo get. set.
    define public property Gerant_Cabinet                 as character no-undo get. set.
    define public property Banque_cabinet                 as character no-undo get. set.
    define public property Honoraire_cabinet              as character no-undo get. set.
    define public property Honoraire_cabinetenlettre      as character no-undo get. set.
    define public property ComplementAdresseIdent_Cabinet as character no-undo get. set.
    define public property Titre_Gerant_Cabinet           as character no-undo get. set.
    define public property Nom_Gerant_Cabinet             as character no-undo get. set.
    define public property NumeroCarteProf                as character no-undo get. set.
    define public property DateObtentionCarte             as character no-undo get. set.
    define public property LieuObtentionCarte             as character no-undo get. set.
    define public property DescriptionSyndicat            as character no-undo get. set.
    define public property DescriptionGarant              as character no-undo get. set.
end class.
