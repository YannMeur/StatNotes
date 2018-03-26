//
//  Note.swift
//  ExtraitNotes
//
//  Created by Yann Meurisse on 22/01/2018.
//  Copyright © 2018 Yann Meurisse. All rights reserved.
//
//  Version 1.1 au 26/02/2018.

import Foundation

class Note: Comparable, Hashable, CustomStringConvertible
{
   
   // --- Propriétés d'instance ---
   //var pitch = Pitch()
   var step = ""        // "C", "D", "E" .... ou " " pour rest
   var octave: Int = 0  // ... 3, 4 5 ...
   var alter = ""       // nb de 1/2 ton de l'altération : "1"-->dièse  "-1"-->bémol
   var type = ""        // "whole", "eighth", "16th" ...
   var accidental = ""  // "sharp"=dièse  "flat"=bémol "natural"=bécarre
   var dot = false      // note pointée
   var tied = ""        // note liée ? ""=non, "start"=avec suivante, "stop"=avec précédente
   var numMesure = 0    // n° de la mesure à laquelle appartient la note
   var alterParArmure = false // y a-t-il une altération donnée par l'armure ?
   
   // pour associer un nb à une note pour la relation d'ordre
   let note2indDico: [String: Int]  = ["C": 10,"D": 20,"E": 30,"F": 40,"G": 50,"A": 60, "B": 70]
   let note2indDico2: [String: Int] = ["C": 0,"D": 2,"E": 4,"F": 5,"G": 7,"A": 9, "B": 11]
   let note2degres: [String: Int]   = ["C": 0,"D": 1,"E": 2,"F": 3,"G": 4,"A": 5, "B": 6]
   // pour associer une note anglo-saxonne à une note française
   let noteA2noteFDico: [String: String] = ["C": "Do","D": "Ré","E": "Mi","F": "Fa","G": "Sol","A": "La","B": "Si","": ""]
   // et réciproquement
   let noteF2noteADico: [String: String] = [ "Do": "C","Ré": "D","Mi": "E","Fa": "F","Sol": "G" ,"La": "A","Si": "B","": ""]
   
   // --- Propriétés calculées ---
   var stepF: String {
      get{ return noteA2noteFDico[self.step]! }
      set{ step = noteF2noteADico[newValue]! }
   }
   // Les intervalles
   var seconde: Note { get{ return self.shift(nb: 2)! }}
   var tierce_m: Note { get{ return self.shift(nb: 3)! }}
   var tierce_M: Note { get{ return self.shift(nb: 4)! }}
   var quarte: Note { get{ return self.shift(nb: 5)! }}
   var quinte_dim: Note { get{ return self.shift(nb: 6)! }}
   var quinte: Note { get{ return self.shift(nb: 7)! }}
   var quinte_aug: Note { get{ return self.shift(nb: 8)! }}
   var sixte: Note { get{ return self.shift(nb: 9)! }}
   var septieme_m: Note { get{ return self.shift(nb: 10)! }}
   var septieme_M: Note { get{ return self.shift(nb: 11)! }}
   var oct: Note { get{ return self.shift(nb: 12)! }}
   
   // --- Propriétés de class (static) ---
   // ordre des dièses selon l'armure : FA DO SOL RE LA MI SI
   static let ordreSharp = ["F", "C", "G", "D", "A", "E", "B"]
   // ordre des bémols selon l'armure : SI MI LA RE SOL DO FA
   static let ordreFlat = ["B", "E", "A", "D", "G", "C", "F"]
   
   static let bemolGlyphe = "\u{266d}"
   static let becarreGlyphe = "\u{266e}"
   static let dieseGlyphe = "\u{266f}"
   
   static let wholeRestGlyphe                   = "\u{1D13B}"
   static let halfRestGlyphe                    = "\u{1D13C}"
   static let quarterRestGlyphe                 = "\u{1D13D}"
   static let eighthRestGlyphe                  = "\u{1D13E}"
   static let sixteenthRestGlyphe               = "\u{1D13F}"
   static let thirtySecondRestGlyphe            = "\u{1D140}"
   static let sixtyFourthSecondRestGlyphe       = "\u{1D141}"
   static let oneHundredTwentyEighthRestGlyphe  = "\u{1D142}"
   
   static let wholeNoteGlyphe                   = "\u{1D15D}"
   static let halfNoteGlyphe                    = "\u{1D15E}"
   static let quarterNoteGlyphe                 = "\u{1D15F}"
   static let eighthNoteGlyphe                  = "\u{1D160}"
   static let sixteenthNoteGlyphe               = "\u{1D161}"
   static let thirtySecondNoteGlyphe            = "\u{1D162}"
   static let sixtyFourthSecondNoteGlyphe       = "\u{1D163}"
   static let oneHundredTwentyEighthNoteGlyphe  = "\u{1D164}"

   var glyphe: String
   {
      var result = ""
      if self.step == ""   // il s'agit d'un silence
      {
         switch self.type
         {
            case "whole":
               result = Note.wholeRestGlyphe
            case "half":
               result =  Note.halfRestGlyphe
            case "eighth":
               result = Note.eighthRestGlyphe
            case "quarter":
               result = Note.quarterRestGlyphe
            case "16th":
               result = Note.sixteenthRestGlyphe
            default:                            // TODO: à compléter
               result = "??"
         }

      }
      else              // il s'agit d'une vraie note
      {
         switch self.type
         {
            case "whole":
               result = Note.wholeNoteGlyphe
            case "half":
               result =  Note.halfNoteGlyphe
            case "eighth":
               result = Note.eighthNoteGlyphe
            case "quarter":
               result = Note.quarterNoteGlyphe
            case "16th":
               result = Note.sixteenthNoteGlyphe
           default:                            // TODO: à compléter
               result = "??"
         }
      }
      
      if self.accidental != ""
      {
         switch self.accidental
         {
         case "sharp":
            result += Note.dieseGlyphe
         case "natural":
            result += Note.becarreGlyphe
         case "flat":
            result += Note.bemolGlyphe
         default:
            result += ""
         }
      }

      return result
   }
   
   var hashValue: Int
   {
      return self.hashString().hashValue
   }
   
   /********************************************************
    Initialiseurs
    *********************************************************/
   public init()
   {
      self.step = "C"
      self.octave = 0
      self.alter = ""
      self.type = ""
      self.accidental = ""
      self.dot = false
      self.alterParArmure = false
      self.tied = ""
      self.numMesure = 0
   }
   
   public init(_ N: Note)
   {
      self.step = N.step
      self.octave = N.octave
      self.alter = N.alter
      self.type = N.type
      self.accidental = N.accidental
      self.dot = N.dot
      self.alterParArmure = N.alterParArmure
   }
   
   public init(step: String,accidental: String)
   {
      self.step = step
      self.accidental = accidental
   }
   
   public init(step: String,accidental: String,octave: Int)
   {
      self.step = step
      self.accidental = accidental
      self.octave = octave
   }
   
   
   
   
   func hashString() -> String
   {
      var result = ""
      result = self.step + "\(self.octave)" + self.glyphe
      return result
   }
   
   func toString() -> String
   {
      var result = ""
      result = self.step + "\(self.octave)" + self.glyphe + " " + self.type + " " + tied
      if dot
      {
         result += " pointée"
      }
      
      //result += "n° mesure=\(self.numMesure)"
      return result
   }
   
   /**
    Retourne une String représentant de façon minimale la Note:
    son nom + altération éventuelle (notation anglo-saxonne)
    */
   func toStringSimple() -> String
   {
      var result = ""
      result = self.step + self.glyphe
      return result
   }
   /**
    Retourne une String représentant de façon minimale la Note:
    son nom + altération éventuelle (notation françaisee)
    */
   func toChaineSimple() -> String
   {
      var result = ""
      result = self.stepF + self.glyphe
      return result
   }
   
   var description: String
   {
      return self.stepF + self.glyphe
      //return self.step + "\(self.octave)" + self.glyphe+"m\(self.numMesure)"
   }
   
   /**
    Pour que la class adhère au protocol Comparable
    Implémentation du test d'égalité de 2 notes ; basé sur index()
    */
   static func == (note1: Note, note2: Note) -> Bool
   {
      return note1.index() == note2.index()
   }
   
   /*****************************************************************************************
    Associe un nombre propre à chacune des notes dans un ordre croissant comme la notation
    anglo-saxonne
    Nouvelle version basée sur la distance entre les Notes comptée en nb. de 1/2 tons
    ******************************************************************************************/
   /*
    func index() -> Int
    {
    var result: Int = self.octave * 100
    
    result += note2indDico[self.step]!
    switch self.accidental
    {
    case "sharp":
    result += 5
    case "flat":
    result -= 5
    default:
    result += 0
    }
    return result
    }
    */
   func index() -> Int
   {
      var result: Int = self.octave * 12
      
      result += note2indDico2[self.step]!
      switch self.accidental
      {
      case "sharp":
         result += 1
      case "flat":
         result -= 1
      default:
         result += 0
      }
      return result
   }
   
   /*****************************************************************************************
    Fonction inverse de index()
    Retourne une Note en fonction d'un indice
    (basée sur la distance entre les Notes comptée en nb. de 1/2 tons)
    ******************************************************************************************/
   static func index2Note(index: Int) -> Note?
   {
      let octave = index/12
      let reste = index%12
      
      switch reste
      {
      case 0:
         return Note(step: "C",accidental: "",octave: octave)
      case 1:
         return Note(step: "C",accidental: "sharp",octave: octave)
      case 2:
         return Note(step: "D",accidental: "",octave: octave)
      case 3:
         return Note(step: "E",accidental: "flat",octave: octave)
      case 4:
         return Note(step: "E",accidental: "",octave: octave)
      case 5:
         return Note(step: "F",accidental: "",octave: octave)
      case 6:
         return Note(step: "F",accidental: "sharp",octave: octave)
      case 7:
         return Note(step: "G",accidental: "",octave: octave)
      case 8:
         return Note(step: "A",accidental: "flat",octave: octave)
      case 9:
         return Note(step: "A",accidental: "",octave: octave)
      case 10:
         return Note(step: "B",accidental: "flat",octave: octave)
      case 11:
         return Note(step: "B",accidental: "",octave: octave)
      default:
         return nil
         
      }
   }
   
   /******************************************************************************************
    Pour que la class adhère au protocol Comparable
    Implémentation de la relation d'ordre ; basée sur index()
    Attention, l'ordre des notes c'est ... A4 B4 C5 D5 E5 F5 G5 A5 B5 C6 ...
    donc G5 < A5 par ex.
    ******************************************************************************************/
   static func <(lhs: Note, rhs: Note) -> Bool
   {
      
      return lhs.index() < rhs.index()
   }
   /******************************************************************************************
    Retourne la note située à "nb" de demi-tons de la note actuelle
    (la note retournée peut être dièse ou bémol)
    ******************************************************************************************/
   func shift(nb demiTons: Int) -> Note?
   {
      let ind = self.index() + demiTons
      if ind >= 0
      {
         return Note.index2Note(index: ind)
      } else
      {
         print(" Erreur : indice <0 !!!")
         return nil
      }
   }
   /******************************************************************************************
    Retourne la note située à "nd" dedrés de la note actuelle
    
    ******************************************************************************************/
   func shift(nd degre: Int) -> Note?
   {
      let deg = note2degres[self.step]! + degre
      let reste = deg % 7
      
      if let key = note2degres.someKey(forValue: reste)
      {
         return Note(step: key, accidental: "")
      }
      else
      {
         print("erreur dans Note.shift(nd degre: Int) ")
         return nil
      }
   }
   
   
}

//============================================================================================

