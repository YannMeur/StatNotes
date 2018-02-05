//
//  Mesure.swift
//  ExtraitNotes
//
//  Created by Yann Meurisse on 25/01/2018.
//  Copyright © 2018 Yann Meurisse. All rights reserved.
//

import Foundation

class Mesure: CustomStringConvertible
{
   var notes = [Note]() // notes de la mesure
   var repetition = ""  // "backward"=fin de zone de répétition
                        // "forward"=début de zone de répétition
                        // "" sinon
   var numero = 0       // numéro de la mesure
   
   var description: String
   {
      var result = ""
      
      result += "[mesure \(numero): "
      for note in notes
      {
         result += String(describing: note) + " "
      }
      result += "]"
      return result
   }

}
