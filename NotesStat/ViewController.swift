//
//  ViewController.swift
//  ExtraitNotes
//
//  Created by Yann Meurisse on 22/01/2018.
//  Copyright © 2018 Yann Meurisse. All rights reserved.
//

import Cocoa
import MyMathLib

class ViewController: NSViewController,XMLParserDelegate
{
   var notes = [Note]()       // tableau général des notes
   var note = Note()          // cette variable sert-elle ?!?
   var mesures = [Mesure]()   // tableau général des mesures
   var tempNotes = [Note]()   // tableau tempo. pour stocker les notes d'UNE mesure
   var nbOccNotes: [Note: Int] = [:]  // Dict. dénombrant les notes : key=Note , value=nb. occur.
   var nbNotes = 0            // nombre de notes différentes
   //var coupleNoteNb: (note: Note, nb: Int) //
   var arrayNoteNombre: [(note: Note , nb: Int)] = [] // Tableau de tuples (note,nb occurences)
   
   //var pitch = Pitch()
   var step = ""
   var octave = 0
   var type = ""
   var accidental = ""        // "sharp":dièse ou "flat":bémol ou "natural":bécarre ou ...
   var dot = false            // note pointée
   var tied = ""
   var nbOfAccidentals: Int = 0   // nb de dièses (si >0) ou bémols (si <0) à la clef
   var numMesure = 0         // n° de la mesure à laquelle appartient la note
   var repeatDirection = ""   // direction de la répétition "backward" ou "forward"
   
   var foundCharacters = ""
   
   /**********************************************************************************************************
    
    *********************************************************************************************************/
   func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
   {
      //Si on est dans un champ <tie type="start"/>
      if elementName == "tie"
      {
         if let name = attributeDict["type"]
         {
            self.tied = name
         }
      }
      
      //Si on est dans un champ <measure number="..." width="...">
      if elementName == "measure"
      {
         if let name = attributeDict["number"]
         {
            self.numMesure = Int(name)!
         }
      }
      
      //Si on est dans un champ <repeat direction="..." times="..." />
      if elementName == "repeat"
      {
         if let name = attributeDict["direction"]
         {
            self.repeatDirection = name
         }
      }

   }

   /**********************************************************************************************************
    
    *********************************************************************************************************/
   func parser(_ parser: XMLParser, foundCharacters string: String)
   {
      let string2 = string.trimmingCharacters(in: [" ", "\t", "\n", "\r"]) // ajouté par moi !
      //print("string in foundCharacters = "+string2+"\n") // ajouté par moi !
      self.foundCharacters += string2
   }

   /**********************************************************************************************************
    
    *********************************************************************************************************/
   func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
   {
      if elementName == "step"
      {
         self.step = self.foundCharacters
      }
      
      if elementName == "octave"
      {
         self.octave = Int(self.foundCharacters)!
      }
      
      /*
      if elementName == "pitch"
      {
         let tempPitch = Pitch()
         tempPitch.step = self.step
         tempPitch.octave = self.octave
      }
      */
      
      if elementName == "type"
      {
         self.type = self.foundCharacters
      }
      
      if elementName == "dot"
      {
         self.dot = true
      }

      if elementName == "accidental"
      {
         self.accidental = self.foundCharacters
      }
 
      if elementName == "fifths"
      {
         self.nbOfAccidentals = Int(self.foundCharacters)!
      }

      // Si on atteint </note>
      if elementName == "note"
      {
         let tempNote = Note();  // on génère une nouvelle note
         tempNote.step = self.step
         tempNote.octave = self.octave
         tempNote.type = self.type
         tempNote.dot = self.dot                // champ optionnel
         tempNote.tied = self.tied              // champ optionnel
         tempNote.accidental = self.accidental  // champ optionnel
         tempNote.numMesure = self.numMesure
         self.notes.append(tempNote)            // on l'ajoute au tableau général des notes
         self.tempNotes.append(tempNote)        // on l'ajoute au tableau temporaire des notes de la mesure
         
         // il faut ré-initialiser ces champs optionnels
         self.dot = false
         self.tied = ""
         self.accidental = ""
      }
      
      // Si on atteint </measure>
      if elementName == "measure"
      {
         let tempMesure = Mesure();  // on génère une nouvelle mesure
         tempMesure.notes = self.tempNotes
         tempMesure.repetition = self.repeatDirection // champ optionnel
         tempMesure.numero = self.numMesure
         
         self.mesures.append(tempMesure)  // on l'ajoute au tableau général des mesures
         
         // il faut ré-initialiser self.tempNotes
         self.tempNotes.removeAll()
         self.repeatDirection = ""
      }

      self.foundCharacters = ""
   }

   /**********************************************************************************************************
    
    *********************************************************************************************************/
   func parserDidEndDocument(_ parser: XMLParser)
   {
      var indice = 0
      for note in self.notes
      {
         indice += 1
         //print("note\(indice) : \(note.toString()) \n")
         //print("note\(indice) : " + String(describing: note))
         print("note\(indice) :  \(note)")
      }
      
      print("Nombre de mesures : \(self.mesures.count)")
      
      //propageAlterationInMeasure()
      propageAlterationALaClef()
      
      print(String(describing: mesures[26]))
      
      nbNotes = compteNotes()
      print("Nombre de notes différentes : \(self.nbNotes)")
      
      let sortedArray = self.nbOccNotes.sorted(by: <)
      print("_____________________nbOccNotes_________________________")
      print(nbOccNotes)
      print("_____________________sortedArray_________________________")
      print(sortedArray)
      print("______________________arrayNoteNombre________________________")
      print(self.arrayNoteNombre)
      
      // Création du dictionnary associant à chacune des notes utilisées un indice de 0...self.nbNotes-1
      // dans l'ordre croissant des notes (C4 D4 E4 F4 G4 A4 B4 C5 ...)
      var dicoNote2Ind: [Note: Int] = [:]
      indice = 0
      for (note,_) in self.arrayNoteNombre
      {
         dicoNote2Ind[note] = indice
         indice += 1
      }
      print("______________________dicoNote2Ind______________________")
      print(dicoNote2Ind)
      // Création d'une nouvelle liste-succession des notes où chaque note est remplacée par
      // son indice obtenu dans le dico. dicoNote2Ind
      let partitionEnIndices = self.notes.map({ dicoNote2Ind[$0]})
      print("______________________partitionEnIndices______________________")
      print(partitionEnIndices)
      
      // ---- Création de la matrice de transition (ordre1) -----
      //var matTransition = Matrice(Array(repeating: 0.0, count: self.nbNotes*self.nbNotes),nbl: self.nbNotes,nbc: self.nbNotes)
      var matTransition = Matrice(nbl: self.nbNotes)
      
      for i in 0...partitionEnIndices.count-2
      {
         let indL = partitionEnIndices[i]
         let indC = partitionEnIndices[i+1]
         matTransition[indL!,indC!] += 1
      }
      
      print("matTransition (\(matTransition.dim()) :\n\(matTransition))")
       
   }

   /**********************************************************************************************************
    Dans chaque mesure, si une note est altérée toutes les notes identiques (même step) doivent l'être
    *********************************************************************************************************/
   func propageAlterationInMeasure()
   {
      for mes in self.mesures
      {
         // si il y a plus qu'1 note dans la mesure
         if mes.notes.count>1
         {
            // pour chaque note dans la mesure
            for i in 0...mes.notes.count-2
            {
               // si cette note est "diaisée"
               if self.notes[i].accidental == "sharp"
               {
                  // y a-t-il des autres notes de même step dans cette mesure
                  for j in i+1...mes.notes.count-1
                  {
                     // si la note est bécarre => on arrête
                     if (self.notes[j].accidental == "natural")
                     {
                        break
                     }
                     // si la note est de même step on l'altère
                     if (self.notes[j].step == self.notes[i].step)
                     {
                        self.notes[j].accidental = "sharp"
                     }
                  }
               }
               // si cette note est "bémolée"
               if self.notes[i].accidental == "flat"
               {
                  // y a-t-il des autres notes de même step dans cette mesure
                  for j in i+1...mes.notes.count-1
                  {
                     // si la note est bécarre => on arrête
                     if (self.notes[j].accidental == "natural")
                     {
                        break
                     }
                     // si la note est de même step on l'altère
                     if (self.notes[j].step == self.notes[i].step)
                     {
                        self.notes[j].accidental = "flat"
                     }
                  }
               }
            }
         }
      }
   }
   
   /**********************************************************************************************************
    En fonction de l'armure, on applique les altérations éventuelles à toutes les notes
    nbOfAccidentals = 0   // nb de dièses (si >0) ou bémols (si <0) à la clef
    *********************************************************************************************************/
   func propageAlterationALaClef()
   {
      var notesCibles: [String] = []
      var alteration = ""

      if nbOfAccidentals>0
      {
         notesCibles = Array(Note.ordreSharp[0...nbOfAccidentals-1])
         alteration = "sharp"
      }
      if nbOfAccidentals<0
      {
         notesCibles = Array(Note.ordreFlat[0...nbOfAccidentals-1])
         alteration = "flat"
      }
      
      for note in self.notes
      {
         if notesCibles.contains(note.step)
         {
            note.accidental = alteration
         }
      }

      
   }
 
   /**********************************************************************************************************
    Compte les notes : Génère un Dictionnaire (nbOccNotes: [Note: Int]) des Note avec leur nb d'occurence
    *********************************************************************************************************/
   func compteNotes() -> Int
   {
      // ---- Construit le dictionnary : nbOccNotes ---------------------------------
      for note in self.notes
      {
         if let val = self.nbOccNotes[note]
         {
            // now val is not nil and the Optional has been unwrapped, so use it
            self.nbOccNotes[note] = val+1
         } else
         {
            self.nbOccNotes[note] = 1
         }
      }
      // ----- Construit le tableau de tuples : arrayNoteNombre ------------------
      // (classé selon les notes croissantes)
      for (note,nb) in self.nbOccNotes
      {
         self.arrayNoteNombre.append((note, nb))
      }
      self.arrayNoteNombre = self.arrayNoteNombre.sorted(by: { $0.0 < $1.0 })

      return self.nbOccNotes.count
   }
   
   /**********************************************************************************************************
    
    *********************************************************************************************************/
   override func viewDidLoad()
   {
      super.viewDidLoad()

      // Do any additional setup after loading the view.
      var xmlString = ""
      
      if let filepath = Bundle.main.path(forResource: "Aria II", ofType: "strings") {
         do {
            xmlString = try String(contentsOfFile: filepath)
            //xmlString = xmlString.components(separatedBy: ["\t", "\r", "\n"]).joined() // "yuahl"
            //print(xmlString)
         } catch {
            // contents could not be loaded
            print("xmlString could not be loaded")
         }
      } else {
         // example.txt not found!
         print("Aria strings not found!")
      }
      
      
      let xmlData = xmlString.data(using: String.Encoding.utf8)!
      let parser = XMLParser(data: xmlData)
      
      parser.delegate = self
      
      parser.parse()
      


   }

   override var representedObject: Any?
      {
      didSet
      {
      // Update the view, if already loaded.
      }
   }


}

