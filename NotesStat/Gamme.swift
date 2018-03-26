//
//  Gamme.swift
//  NotesStat
//
//  Created by Yann Meurisse on 14/02/2018.
//
//  Version 1.1 au 01/03/2018.

import Foundation

class Gamme: CustomStringConvertible
{
   // --- Propriétés d'instance ----
   var fondamentale:Note = Note(step: "C",accidental: "")   // "A", "B" ... "G"
   var mode: String = "M"   // "M" pour majeur , "m" pour mineur
   // Armure correspondante
   var nbAccidents: Int = 0   // à la clef !!
   var typeAccident: String = "" // à la clef !! : "flat" ou "sharp" ou ""
   
   // --- Propriétés de class (static) ----
   /**
    Dictionnaire des Gammes majeures classées en fct. du nb de dièses puis
    du nb de bémols à l'armure
    - "Note": La note fondammentale de la Gamme
    - Int: le nombre d'accidents (0≤..≤7)
    - String: Le type d'accident
    - "flat" pour des bémols
    - "sharp" pour des dièses
    */
   static let gammes_M: [Note: (Int,String)] = [Note(step: "C",accidental: ""):(0,""),
                                                Note(step: "G",accidental: ""):       (1,"sharp"),
                                                Note(step: "D",accidental: ""):       (2,"sharp"),
                                                Note(step: "A",accidental: ""):       (3,"sharp"),
                                                Note(step: "E",accidental: ""):       (4,"sharp"),
                                                Note(step: "B",accidental: ""):       (5,"sharp"),
                                                Note(step: "F",accidental: "sharp"):  (6,"sharp"),
                                                Note(step: "C",accidental: "sharp"):  (7,"sharp"),
                                                
                                                Note(step: "F",accidental: ""):       (1,"flat"),
                                                Note(step: "B",accidental: "flat"):   (2,"flat"),
                                                Note(step: "E",accidental: "flat"):   (3,"flat"),
                                                Note(step: "A",accidental: "flat"):   (4,"flat"),
                                                Note(step: "D",accidental: "flat"):   (5,"flat"),
                                                Note(step: "G",accidental: "flat"):   (6,"flat"),
                                                Note(step: "C",accidental: "flat"):   (7,"flat")]
   /**
    Dictionnaire des Gammes mineures classées en fct. du nb de dièses puis
    du nb de bémols à l'armure
    - "Note": La note fondammentale de la Gamme
    - Int: le nombre d'accidents (0≤..≤7)
    - String: Le type d'accident
    - "flat" pour des bémols
    - "sharp" pour des dièses
    */
   static let gammes_m: [Note: (Int,String)] = [Note(step: "A",accidental: ""):(0,""),
                                                Note(step: "E",accidental: ""):       (1,"sharp"),
                                                Note(step: "B",accidental: ""):       (2,"sharp"),
                                                Note(step: "F",accidental: "sharp"):  (3,"sharp"),
                                                Note(step: "C",accidental: "sharp"):  (4,"sharp"),
                                                Note(step: "G",accidental: "sharp"):  (5,"sharp"),
                                                Note(step: "D",accidental: "sharp"):  (6,"sharp"),
                                                Note(step: "A",accidental: "sharp"):  (7,"sharp"),
                                                
                                                Note(step: "D",accidental: ""):       (1,"flat"),
                                                Note(step: "G",accidental: ""):       (2,"flat"),
                                                Note(step: "C",accidental: ""):       (3,"flat"),
                                                Note(step: "F",accidental: ""):       (4,"flat"),
                                                Note(step: "B",accidental: "flat"):   (5,"flat"),
                                                Note(step: "E",accidental: "flat"):   (6,"flat"),
                                                Note(step: "A",accidental: "flat"):   (7,"flat")]
   
   // --- Propriétés calculées ---
   
   /**
    Suite des nombres de 1/2 tons de la gamme (Majeure ou mineure)
    */
   var suiteDemiTons: [Int] {
      get {
         let result = (self.mode=="M") ? [2,2,1,2,2,2,1] : [2,1,2,2,1,2,2]
         return result
      }
   }
   
   /**
    Tableau classé des Note constituant la Gamme
    TODO: Il ne faudrait pas de mélange dièse-bémols
    
    */
   /***
    var notes: [Note] {
    get {
    var result = [self.fondamentale]
    
    for i in 0..<suiteDemiTons.count
    {
    result.append(result[i].shift(nb: suiteDemiTons[i])!)
    }
    // il faut maintenant vérifier que chaque degré apparait une
    // et une seule fois
    
    return result
    }
    }
    ***/
   var notes: [Note] {
      get {
         var result = [self.fondamentale]
         for i in 1...6
         {
            result.append(self.fondamentale.shift(nd: i)!)
         }
         
         // on altère maintenant éventuellement chaque note
         for i in 1...6
         {
            // distance en 1/2 Tons entre la note courante et la précedente
            var distance = result[i].index() - result[i-1].index()
            if distance < 0
            {
               distance += 12
            }
            // distance qu'il faudrait
            let dist_cible = suiteDemiTons[i-1]
            if dist_cible > distance
            {
               result[i].alter = "1"
               result[i].accidental = "sharp"
            } else if dist_cible < distance
            {
               result[i].alter = "-1"
               result[i].accidental = "flat"
            }
         }
         result.append(Note(result[0]))
         return result
      }
   }
   
   /*************************************************************
    // Initialiseurs                                             //
    *************************************************************/
   public init()
   {
      self.fondamentale = Note(step: "C",accidental: "")
      self.mode = "M"
      self.nbAccidents = 0
      self.typeAccident = ""
      //self.gammeRelative = Gamme(fond: Note(step: "G",accidental: ""),mode: "m")
   }
   
   public init(fond: Note,mode: String)
   {
      self.fondamentale = fond
      self.mode = mode
      // TODO : mettre à jour les autres propriétés
   }
   
   /**
    Initialise une gamme (Majeure si mode: "M" ou mineure si mode: "m") à partir
    du nombre et du type d'accident à la clef
    */
   public convenience init(nombre: Int,accident: String,mode: String)
   {
      if nombre == 0
      {
         self.init()
      } else if (nombre>0 && nombre<8) && (accident == "flat" || accident == "sharp")
      {
         var laNote: Note = Note()
         var leMode: String = ""
         if mode == "M"
         {
            for key in Gamme.gammes_M.keys
            {
               if let (nb,type) = Gamme.gammes_M[key]
               {
                  if nb==nombre && type==accident
                  {
                     laNote = key
                     leMode = "M"
                  }
                  
               }
            }
         }
         if mode == "m"
         {
            for key in Gamme.gammes_m.keys
            {
               if let (nb,type) = Gamme.gammes_m[key]
               {
                  if nb==nombre && type==accident
                  {
                     laNote = key
                     leMode = "m"
                  }
               }
            }
         }
         self.init(fond: laNote,mode: leMode)
      }
      else
      {
         print("Paramêtres incompatibles : 0≤nombre≤7 et accident = \"\" , flat ou sharp")
         self.init()
      }
   }
   
   /**
    Pour implémenter "...\(Gamme) "
    */
   var description: String
   {
      var result: String = "gamme de " + self.fondamentale.toChaineSimple()
      
      switch self.mode
      {
      case "M":
         result += " Majeur"
      case "m":
         result += " mineur"
      default:
         result += " erreur"
      }
      return result
   }
   
   
   /**
    Calcule la gamme relative
    */
   func gammeRelative() -> Gamme
   {
      var result = Gamme()
      
      if self.mode == "M"
      {
         if let (nb,type) = Gamme.gammes_M[self.fondamentale]
         {
            result = Gamme(nombre: nb, accident: type, mode: "m")
         }
      }
      if self.mode == "m"
      {
         if let (nb,type) = Gamme.gammes_m[self.fondamentale]
         {
            result = Gamme(nombre: nb, accident: type, mode: "M")
         }
      }
      return result
   }
}
/*********************************************************************/

