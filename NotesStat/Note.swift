//
//  Note.swift
//  ExtraitNotes
//
//  Created by Yann Meurisse on 22/01/2018.
//  Copyright © 2018 Yann Meurisse. All rights reserved.
//

import Foundation

class Note: Comparable, Hashable, CustomStringConvertible
{
   
   
   //var pitch = Pitch()
   var step = ""        // "C", "D", "E" ....
   var octave: Int = 0  // ... 3, 4 5 ...
   var alter = ""       // nb de 1/2 ton de l'altération : "1"-->dièse  "-1"-->bémol
   var type = ""        // "whole", "eighth", "16th" ...
   var accidental = ""  // "sharp"=dièse  "flat"=bémol "natural"=bécarre
   var dot = false      // note pointée
   var tied = ""        // note liée ? ""=non, "start"=avec suivante, "stop"=avec précédente
   var numMesure = 0    // n° de la mesure à laquelle appartient la note
   var alterParArmure = false // y a-t-il une altération donnée par l'armure ?
   
   // pour associer un nb à une note pour la relation d'ordre
   let note2indDico: [String: Int] = ["C": 10,"D": 20,"E": 30,"F": 40,"G": 50,"A": 60, "B": 70]
   
   // ordre des dièses selon l'armure : FA DO SOL RE LA MI SI
   static let ordreSharp = ["F", "C", "G", "D", "A", "E", "B"]
   // ordre des bémols selon l'armure : SI MI LA RE SOL DO FA
   static let ordreFlat = ["B", "E", "A", "D", "G", "C", "F"]
   
   static let bemolGlyphe = "\u{266d}"
   static let becarreGlyphe = "\u{266e}"
   static let dieseGlyphe = "\u{266f}"
   
   var glyphe: String
   {
      switch self.accidental
      {
         case "sharp":
            return Note.dieseGlyphe
         case "natural":
            return Note.becarreGlyphe
         case "flat":
            return Note.bemolGlyphe
         default:
            return ""
      }
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
      self.step = ""
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
   
   var description: String
   {
      return self.step + "\(self.octave)" + self.glyphe+"m\(self.numMesure)"
   }

   /*****************************************************************************************
    Pour que la class adhère au protocol Comparable
    Implémentation du test d'égalité de 2 notes ; basé sur index()
    ******************************************************************************************/
   static func == (note1: Note, note2: Note) -> Bool
   {
      return note1.index() == note2.index()
   }
   
   /*****************************************************************************************
      Associe un nombre propre à chacune des notes dans un ordre croissant comme la notation
      anglo-saxonne
    ******************************************************************************************/
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

}
