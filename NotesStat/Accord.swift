//
//  Accord.swift
//  NotesStat
//
//  Created by Yann Meurisse on 17/02/2018.
//
//  Version 1.0 au 01/03/2018.

import Foundation

class Accord: CustomStringConvertible
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
         
         if degre == 3  // Accord de Quinte
         {
            if augmente == "" && mode == "m" // parfait mineur
            {
               result.append(fondammentale.tierce_m)
               result.append(result[1].tierce_M)
            } else                           // parfait Majeur
            {
               result.append(fondammentale.tierce_M)
               result.append(result[1].tierce_m)
               
            }
            if augmente == "-"               // de quinte diminué
            {
               result.append(fondammentale.tierce_m)
               result.append(result[1].tierce_m)
            }
            if augmente == "+"               // de quinte augmenté
            {
               result.append(fondammentale.tierce_M)
               result.append(result[1].tierce_M)
            }
         }
         
         return result
      }
   }
   
   /********************************************************
    Initialiseurs
    *********************************************************/
   public init()
   {
      self.fondammentale = Note()   // "C"
      self.mode = "M"               // Majeur
      self.degre = 3                // de quinte
      self.augmente = ""            // normal
   }

   public init(fondammentale: Note, mode: String, degre: Int, augmente: String)
   {
      self.fondammentale = fondammentale
      self.mode = mode
      self.degre = degre
      self.augmente = augmente            
   }

   /********************************************************
    Mise en String
    *********************************************************/
   var description: String
   {
      
       var result = "Accord de "
       
       if self.degre == 3
       {
         result += "quinte de "
       }
       
       result += "\(self.fondammentale) "
       if self.augmente == ""
       {
         if self.mode == "m"
         {
            result += "mineur"
         } else
         {
            result += "Majeur"
         }
       } else
       {
         if self.augmente == "-"
         {
            result += "diminué"
         } else
         {
            result += "augmenté"
         }
       }
      
      
      return result
   }
   
   func toString() -> String
   {
      var result = "Accord de "
      
      if self.degre == 3
      {
         result += "quinte de "
      }
      
      result += "\(self.fondammentale) "
      if self.augmente == ""
      {
         if self.mode == "m"
         {
            result += "mineur"
         } else
         {
            result += "Majeur"
         }
      } else
      {
         if self.augmente == "-"
         {
            result += "diminué"
         } else
         {
            result += "augmenté"
         }
      }
      
      
      return result
   }
   
   
}
/*********************************************************************/

