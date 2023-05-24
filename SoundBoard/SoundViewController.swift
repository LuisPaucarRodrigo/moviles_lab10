//
//  SoundViewController.swift
//  SoundBoard
//
//  Created by Mac 10 on 24/05/23.
//

import UIKit
import AVFoundation

class SoundViewController: UIViewController {

    @IBOutlet weak var grabarButton: UIButton!
    @IBOutlet weak var reproducirtButton: UIButton!
    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var agregarButton: UIButton!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var volumenSlider: UISlider!
    
    
    
    
    var grabarAudio:AVAudioRecorder?
    var reproducirAudio:AVAudioPlayer?
    var audioURL:URL?
    var recordingStartTime: Date?
    var timer: Timer?
    var recordingDuration:String = ""
    
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording{
            grabarAudio?.stop()
            stopRecording()
            grabarButton.setTitle("GRABAR", for: .normal)
            reproducirtButton.isEnabled = true
            agregarButton.isEnabled = true
        }else{
            grabarAudio?.record()
            startRecording()
            grabarButton.setTitle("DETENER", for: .normal)
            reproducirtButton.isEnabled = false
        }
    }
    
    
    @objc func volumenCambiado(_ sender: UISlider) {
        reproducirAudio?.volume = sender.value
    }

    
    func startRecording() {
          // Tu código para comenzar la grabación
          
          // Establecer el tiempo de inicio de la grabación
          recordingStartTime = Date()
          
          // Configurar el temporizador para actualizar el UILabel
          timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateDurationLabel), userInfo: nil, repeats: true)
      }
      
      func formatDuration(_ duration: TimeInterval) -> String {
          let minutes = Int((duration / 60).truncatingRemainder(dividingBy: 60))
          let seconds = Int(duration.truncatingRemainder(dividingBy: 60))
          let formattedDuration = String(format: "%02d:%02d", minutes, seconds)
          return formattedDuration
      }
      
      @objc func updateDurationLabel() {
          guard let startTime = recordingStartTime else {
              return
          }
          
          let currentTime = Date()
          let duration = currentTime.timeIntervalSince(startTime)
          
          // Formatear la duración en el formato deseado (por ejemplo, HH:mm:ss)
          let durationText = formatDuration(duration)
          recordingDuration = durationText
          
          // Actualizar el UILabel con la duración
          durationLabel.text = durationText
      }
      func stopRecording() {
          // Tu código para detener la grabación
          
          // Detener el temporizador
          timer?.invalidate()
          timer = nil
      }
    
    @IBAction func reproducirTapped(_ sender: Any) {
        do{
           try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
           reproducirAudio!.play()
            reproducirAudio?.volume = volumenSlider.value
           print("Reproduciendo")
        }catch{}
    }
    
    @IBAction func agregarTapped(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let grabacion = Grabacion(context: context)
        grabacion.nombre = nombreTextField.text
        grabacion.duracion = durationLabel.text
        grabacion.audio = NSData(contentsOf:audioURL!)! as Data
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController!.popViewController(animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarGrabacion()
        reproducirtButton.isEnabled = false
        agregarButton.isEnabled = false
        volumenSlider.addTarget(self, action: #selector(volumenCambiado(_:)), for: .valueChanged)

        // Do any additional setup after loading the view.
    }
    
    func configurarGrabacion(){
       do{
           let session = AVAudioSession.sharedInstance()
           try session.setCategory(AVAudioSession.Category.playAndRecord, mode:AVAudioSession.Mode.default, options: [])
           try session.overrideOutputAudioPort(.speaker)
           try session.setActive(true)


           let basePath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask,true).first!
           let pathComponents = [basePath,"audio.m4a"]
           audioURL = NSURL.fileURL(withPathComponents: pathComponents)!


           print("*****************")
           print(audioURL!)
           print("*****************")


           var settings:[String:AnyObject] = [:]
           settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
           settings[AVSampleRateKey] = 44100.0 as AnyObject?
           settings[AVNumberOfChannelsKey] = 2 as AnyObject?


           grabarAudio = try AVAudioRecorder(url:audioURL!, settings: settings)
           grabarAudio!.prepareToRecord()
       }catch let error as NSError{
           print(error)
       }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
