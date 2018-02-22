//
//  Accord.swift
//  NotesStat
//
//  Created by Yann Meurisse on 17/02/2018.
//

import Foundation

class Accord
{
   // --- Propriétés d'instance
   var fondammentale: Note = Note()
   var mode: String = "M"  // Majeur : "M" ou mineur : "m"
   var degre: Int = 3      // 2->seconde, 3->tierce ... 7->septième, 8->octave
   var augmente: String = ""  // ""->normal, "+"->augmenté, "-"->diminué
   
   // --- Propriétés calculées ---
   // Les Note composant l'accord TODO: à compléter
   var notes: [Note] {
      get {
         var result: [Note] = [fondammentale]
          return result
         
      }
   }
}
