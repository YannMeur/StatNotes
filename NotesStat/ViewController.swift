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
   //var note = Note()          // cette variable sert-elle ?!?
   var mesures = [Mesure]()   // tableau général des mesures
   var tempNotes = [Note]()   // tableau tempo. pour stocker les notes d'UNE mesure
   var nbOccNotes: [Note: Int] = [:]  // Dict. dénombrant les notes : key=Note , value=nb. occur.
   var nbNotes = 0            // nombre de notes différentes
   //var coupleNoteNb: (note: Note, nb: Int) //
   var arrayNoteNombre: [(note: Note , nb: Int)] = [] // Tableau de tuples (note,nb occurences)
   var arrayNote: [Note] = []    // Tableau des ≠ Note utilisées, classé dans l'ordre croissant
   
   var portees = [Portee]()   // tableau général des portées
   var porteeCouranteId: String = ""
   
   
   //var pitch = Pitch()
   var step = ""
   var octave = 0
   var alter = ""
   var type = ""
   var accidental = ""           // "sharp":dièse ou "flat":bémol ou "natural":bécarre ou ...
   var dot = false               // note pointée
   var tied = ""
   var nbOfAccidentals: Int = 0  // nb de dièses (si >0) ou bémols (si <0) à la clef
   var numMesure = 0             // n° de la mesure à laquelle appartient la note
   var repeatDirection = ""      // direction de la répétition "backward" ou "forward"
   var staff: Int = 0            // Portée
   
   var porteeId = ""
   var porteeName = ""
   var porteeInstrument = ""
   
   var foundCharacters = ""
   
   var ancienStr = ""   // copie du .xml de départ à partir duquel on construire le nouveau (détruit au fur
                        // et à mesure)
   var newStr = ""      // nouvelle String obtenue progressivement à partir du .xml de départ (ancienStr)
                        // en remplaçant les anciennes notes par les nouvelles obtenues par leur indice
                        // dans "tableauFinalNotesGenerees"
   var tableauFinalNotesGenerees: [Note] = []
   
   /**********************************************************************************************************
    Appelée chaque fois que le parser trouve une <key>
    C'est là où on gère en particulier les champs de type :
    <tie type="start"/>
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

      //Si on est dans un champ <score-part id="Px" />
      if elementName == "score-part"
      {
         if let name = attributeDict["id"]
         {
            self.porteeId = name
         }
      }

      //Si on est dans un champ <part id="Px" /> : champ contenant toutes les mesures d'une portée
      if elementName == "part"
      {
         if let name = attributeDict["id"]
         {
            self.porteeCouranteId = name
         }
      }

   }

   /**********************************************************************************************************
    Appelée chaque fois que le parser entre dans un champ <key>
    et il s'arrêtera au line breaks
    *********************************************************************************************************/
   func parser(_ parser: XMLParser, foundCharacters string: String)
   {
      let string2 = string.trimmingCharacters(in: [" ", "\t", "\n", "\r"]) // ajouté par moi !
      //print("string in foundCharacters = "+string2+"\n") // ajouté par moi !
      self.foundCharacters += string2
   }

   /**********************************************************************************************************
    Appelée chaque fois que le parser trouve une </key>
    C'est là où on extrait l'information au fur et à mesure.
    *********************************************************************************************************/
   func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
   {
      if elementName == "step"
      {
         self.step = self.foundCharacters
      }
      
      if elementName == "rest"
      {
         self.step = ""
      }

      
      if elementName == "octave"
      {
         self.octave = Int(self.foundCharacters)!
      }
      
      
      if elementName == "alter"
      {
         self.alter = self.foundCharacters
      }
      
      
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

      if elementName == "part-name"
      {
         self.porteeName = self.foundCharacters
      }

      if elementName == "instrument-name"
      {
         self.porteeInstrument = self.foundCharacters
      }

      if elementName == "staff"
      {
         self.staff = self.foundCharacters
      }

      // Si on atteint </note>
      if elementName == "note"
      {
         let tempNote = Note()               // on génère une nouvelle note
         tempNote.step = self.step
         tempNote.octave = self.octave
         tempNote.alter = self.alter            // champ optionnel
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
         self.alter = ""
      }
      
      // Si on atteint </measure>
      if elementName == "measure"
      {
         let tempMesure = Mesure()                    // on génère une nouvelle mesure
         tempMesure.notes = self.tempNotes
         tempMesure.repetition = self.repeatDirection // champ optionnel
         tempMesure.numero = self.numMesure
         tempMesure.porteeId = self.porteeCouranteId
         
         self.mesures.append(tempMesure)  // on l'ajoute au tableau général des mesures
         
         // il faut ré-initialiser self.tempNotes
         self.tempNotes.removeAll()
         self.repeatDirection = ""
      }

      // Si on atteint </score-part>
      if elementName == "score-part"
      {
         let tempPortee = Portee()           // on génère une nouvelle Portee
         tempPortee.id = self.porteeId
         tempPortee.nom = self.porteeName
         tempPortee.instrument = self.porteeInstrument
      }
      
      
      self.foundCharacters = ""
   }

   /**********************************************************************************************************
    Appelée lorsque le parser à terminé et atteint la fin du document.
    
    (pour l'ancienne version : celle qui crée une nouvelle partition, cf. old_ViewController.swift
    *********************************************************************************************************/
   func parserDidEndDocument(_ parser: XMLParser)
   {
      /*
      var indice = 0
      for note in self.notes
      {
         indice += 1
         //print("note\(indice) : \(note.toString()) \n")
         //print("note\(indice) : " + String(describing: note))
         print("note\(indice) :  \(note)")
      }
 
      print("Nombre de mesures : \(self.mesures.count)")
      */
      
      print("Nombre de notes : \(self.notes.count)")
      print("Nombre de mesures : \(self.mesures.count)")
      var i = 0
      for mes in mesures
      {
         i += 1
         print("mesure[\(i)] : \(mes)")
      }

      
      
      
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
                        self.notes[j].alter = "1"
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
                        self.notes[j].alter = "-1"
                     }
                  }
               }
            }
         }
      }
   }
   
   /**********************************************************************************************************
    En fonction de l'armure, on applique les altérations éventuelles à toutes les notes
    nbOfAccidentals : nb de dièses (si >0) ou bémols (si <0) à la clef
    *********************************************************************************************************/
   func propageAlterationALaClef()
   {
      var notesCibles: [String] = []
      var alteration = ""
      var alter = ""

      if nbOfAccidentals>0
      {
         notesCibles = Array(Note.ordreSharp[0...nbOfAccidentals-1])
         alteration = "sharp"
         alter = "1"
      }
      if nbOfAccidentals<0
      {
         notesCibles = Array(Note.ordreFlat[0...nbOfAccidentals-1])
         alteration = "flat"
         alter = "-1"
      }
      
      for note in self.notes
      {
         if notesCibles.contains(note.step)
         {
            note.accidental = alteration
            note.alter = alter
            note.alterParArmure = true
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
         let noteTemp = Note(note)
         if let val = self.nbOccNotes[noteTemp]
         {
            // now val is not nil and the Optional has been unwrapped, so use it
            self.nbOccNotes[noteTemp] = val+1
         } else
         {
            self.nbOccNotes[noteTemp] = 1
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
            Génère le nouveau fichier des notes
    Utilise tableauFinalNotesGenerees
    *********************************************************************************************************/
   func genereNewFile(_ nomFichier: String)
   {
      /*----------------------------------------------------------------------------
       Pour chaque note :
       1- On lit dans ancienStr tout ce qui précède <note>
         1-1 On supprime de ancienStr
       2- On le concatène à newStr
       3- On lit tout ce qu'il y a entre <note> et </note>
         3-1 On supprime de ancienStr
       4- On modifie la note
         4-1 On change le nom
         4-2 On ajoute ou on supprime un "accident" éventuel (attention aux accidents à la clef)
       5- On concatène à newStr
       6- Quand on a fini avec les notes
         6-1 On lit la fin de ancienStr
         6-2 On concatène à newStr
       7- On écrit newStr dans un fichier
      ----------------------------------------------------------------------------*/
      
      /*----------------------------------------------------------------------------
       - Pour chaque note
      ----------------------------------------------------------------------------*/
      for i in 0..<self.notes.count
      //for i in 0..<20
      {
         var rangeLowerBound = ancienStr.range(of: "<")  // Uniquement pour déclarer ces 2 var
         var rangeUpperBound = rangeLowerBound           // qui seront utilisées tout au long de la suite
         
         //--- 1- On lit dans ancienStr tout ce qui précède <note>------------------------
         if let range = ancienStr.range(of: "<note>")
         {
            let substring = String(ancienStr[..<range.lowerBound])
            ancienStr.removeSubrange(..<range.lowerBound)   //    1-1 On supprime de ancienStr
            
            newStr += substring                             // 2- On le concatène à newStr
         }
         else {
            print("String not present")
         }
         //==== 3- On lit tout ce qu'il y a entre <note> et </note> (mis dans -> "substring")
         if let range = ancienStr.range(of: "</note>")
         {
            var substring = String(ancienStr[..<range.lowerBound])
            ancienStr.removeSubrange(..<range.lowerBound)   //    3-1 On supprime de ancienStr
            
            //=== 4- On modifie la note
            //------------ INUTILE ! -------
            /*/    -- D'abord on cherche de quelle note il s'agit  => INUTILE !
            //       -- On cherche le "step"
            let step = substring.substringWithStringBounds(de: "<step>", a: "</step>")
            print("step = " + step)
            //       -- On cherche l'"octave"
            let octave = substring.substringWithStringBounds(de: "<octave>", a: "</octave>")
            print("octave = " + octave)
            --------------------------------*/
            // --- On cherche et supprime une altération éventuelle
            if let lowerBound = substring.range(of: "<alter>")?.lowerBound,
               let upperBound = substring.range(of: "</alter>")?.upperBound
            {
               substring.replaceSubrange(lowerBound..<upperBound, with: "")
            }
            if let lowerBound = substring.range(of: "<accidental>")?.lowerBound,
               let upperBound = substring.range(of: "</accidental>")?.upperBound
            {
               substring.replaceSubrange(lowerBound..<upperBound, with: "")
            }
            // --- On remplace l'ancien step par le nouveau
            if let lowerBound = substring.range(of: "<step>")?.upperBound,
               let upperBound = substring.range(of: "</step>")?.lowerBound
            {
               substring.replaceSubrange(lowerBound..<upperBound, with: tableauFinalNotesGenerees[i].step)
            }
            // --- On remplace l'ancien octave par la nouvelle
            if let lowerBound = substring.range(of: "<octave>")?.upperBound,
               let upperBound = substring.range(of: "</octave>")?.lowerBound
            {
               substring.replaceSubrange(lowerBound..<upperBound, with: String(tableauFinalNotesGenerees[i].octave))
            }
            // --- Reste à écrire les accidents éventuels ...
            // Si la note est altérée mais pas par l'armure
            // TODO : traiter les cas
            //           1. de plusieurs altération de même step dans la même mesure
            //           2. de bécarres
            let laNouvNote = tableauFinalNotesGenerees[i]
            if (laNouvNote.alter != "" && !laNouvNote.alterParArmure)
            {
               if let lowerBound = substring.range(of: "</step>")?.upperBound,
                  let upperBound = substring.range(of: "<octave>")?.lowerBound
               {
                  let newAlter = "\n\t\t\t\t\t<alter>"+laNouvNote.alter+"</alter>\n\t\t\t\t\t"
                  substring.replaceSubrange(lowerBound..<upperBound, with: newAlter)
               }
               if let lowerBound = substring.range(of: "</type>")?.upperBound,
                  let upperBound = substring.range(of: "<stem")?.lowerBound
               {
                  let newAccidental = "\n\t\t\t\t\t<accidental>\(laNouvNote.accidental)</accidental>\n\t\t\t\t\t"
                  substring.replaceSubrange(lowerBound..<upperBound, with: newAccidental)
               }
            
            }
            
            newStr += substring                             // 2- On le concatène à newStr
         }
         else {
            print("String not present")
         }
      }
      newStr += ancienStr

      /*------------------------------------------------------------------------------
       on ecrit "newStr" dans le fichier "newAria II.xml"
       Rem :
       var dirCourant: String = FileManager.default.currentDirectoryPath
       print("dirCourant = "+dirCourant)
       /Users/yannmeurisse/Library/Containers/com.YMeurisse.NotesStat/Data
       ------------------------------------------------------------------------------*/
      /*  1ère version (marche !) ------*/
      let fileName = nomFichier

      let dir = try? FileManager.default.url(for: .documentDirectory,
                                             in: .userDomainMask, appropriateFor: nil, create: true)
      //print("dir = \(String(describing: dir))")
      //dir = Optional(file:///Users/yannmeurisse/Library/Containers/com.YMeurisse.NotesStat/Data/Documents/)
      
      // If the directory was found, we write a file to it and read it back
      if let fileURL = dir?.appendingPathComponent(fileName).appendingPathExtension("xml")
      {
         // Write to the file named newFile
         do
         {
            try newStr.write(to: fileURL, atomically: true, encoding: .utf8)
         } catch {
            print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
         }
      }
      /*  2ème version (marche pas !)------
      if let filepath = Bundle.main.path(forResource: "newAria II", ofType: "xml")
      {
         print("filepath = \(String(describing: filepath))")
         do {
            try newStr.write(toFile: filepath, atomically: true, encoding: .utf8)
            } catch {
               // contents could not be loaded
               print("Pb lors de l'écriture du fichier")
            }
      } else {
         print("Pb avec le filepath du fichier")
      }
      ------*/
      /*  2ème version (marche mais ...location ?)------
      let file = "newAria II.xml"
      
      let dirs: [String]? = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
      
      //print("dirs: \(String(describing: dirs))")
      // dirs: Optional(["/Users/yannmeurisse/Library/Containers/com.YMeurisse.NotesStat/Data/Documents"])
      
      if (dirs != nil)
      {
         let directories:[String] = dirs!
         let dirs = directories[0]; //documents directory
         let path = dirs+file
         
         //writing
         do {
            try newStr.write(toFile: path, atomically: true, encoding: .utf8)
         } catch {
            // contents could not be loaded
            print("Pb lors de l'écriture du fichier")
         }
       }
      ------*/
      

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
            ancienStr = xmlString
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

