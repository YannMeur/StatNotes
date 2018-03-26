//
//  Portee.swift
//  NotesStat
//
//  Created by Yann Meurisse on 09/03/2018.
//

import Foundation

class Portee:  CustomStringConvertible
{
   
   // --- Propriétés d'instance ---
   var id: String  = ""          // identité dans le fichier XML  Ex: "P1"
   var nom: String = ""          // nom (facultatif) sur la partition
   var instrument: String = ""   // nom de l'instrument  Ex: "Piano"
   
   
   // --- Pour l'affichage ---
   var description: String
   {
      return "Portée \(self.id) - nom: \(self.nom), instrument : \(self.instrument)"
   }

}
