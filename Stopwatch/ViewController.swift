//
//  ViewController.swift
//  Stopwatch
//
//  Created by chamlingdibyarai on 04/07/21.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //MARK: - IBOutlet
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var lapResetButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    //MARK: - Variables
    var started = false
    var isTimerRunning = false
    var lapCounter = 0
    var mainLapCounter = 0
    var lapTimer : Timer?
    var mainLapTimer : Timer?
    var lapArray = [Lap]()
    var maxIndex = 0
    var minIndex = 0
    var colorCell = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewHeightConstraint.constant = self.view.frame.height / 2
        tableViewHeightConstraint.constant = self.view.frame.height / 2
        reset()
        startStopButton.layer.cornerRadius = 0.5 * startStopButton.bounds.size.width
        lapResetButton.layer.cornerRadius = 0.5 * lapResetButton.bounds.size.width
    }

    @IBAction func lapResetPressed(_ sender: UIButton) {
        if isTimerRunning{
            addLap()
        }else{
            reset()
        }
    }
    
    @IBAction func startStopPressed(_ sender: UIButton) {
        if !started{
            startStopButton.tintColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            startStopButton.setImage(UIImage(systemName: "stop.fill"), for:  .normal)
            startTimer()
            lapResetButton.isEnabled = true
            started = true
            tableView.reloadData()
        } else{
            if isTimerRunning{
                startStopButton.tintColor = #colorLiteral(red: 0, green: 0.9832226634, blue: 0.578263104, alpha: 1)
                startStopButton.setImage(UIImage(systemName: "play.fill"), for:  .normal)
                lapResetButton.setTitle("Reset", for: .normal)
                stopTimer()
            }else{
                startStopButton.tintColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
                startStopButton.setImage(UIImage(systemName: "stop.fill"), for:  .normal)
                lapResetButton.setTitle("Lap", for: .normal)
                startTimer()
            }
        }
        isTimerRunning = !isTimerRunning
    }
    
    // MARK: - Helper Methods
    func startTimer(){
        if mainLapTimer == nil{
            mainLapTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(mainLapTimerUpdate), userInfo: nil, repeats: true)
            RunLoop.current.add(mainLapTimer!, forMode: .common)
        }
        if lapTimer == nil{
            lapTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(lapTimerUpdate), userInfo: nil, repeats: true)
            RunLoop.current.add(lapTimer!, forMode: .common)
        }  
    }
    
    @objc func mainLapTimerUpdate(){
        mainLapCounter += 1
        updateLabel(label: timerLabel, counter: mainLapCounter)
    }
    
    @objc func lapTimerUpdate(){
        lapCounter += 1
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        cell?.detailTextLabel!.text = secondsToHourMinuteSecond(seconds: lapCounter)
    }
    
    func stopTimer(){
        mainLapTimer?.invalidate()
        lapTimer?.invalidate()
        mainLapTimer = nil
        lapTimer = nil
    }
    
    func updateLabel( label : UILabel, counter : Int){
        label.text = secondsToHourMinuteSecond(seconds: counter)
    }
    
    func secondsToHourMinuteSecond( seconds : Int )->String{
        let hour = seconds / 3600
        let minute = seconds / 60 % 60
        let second = seconds % 60
        return String(format: "%02i:%02i:%02i", hour, minute, second )
    }
    
    func reset(){
        startStopButton.tintColor = #colorLiteral(red: 0, green: 0.9832226634, blue: 0.578263104, alpha: 1)
        startStopButton.setImage(UIImage(systemName: "play.fill"), for:  .normal)
        lapResetButton.setTitle("Lap", for: .normal)
        timerLabel.text = "00:00:00"
        stopTimer()
        lapCounter = 0
        mainLapCounter = 0
        lapResetButton.isEnabled = false
        mainLapTimer = nil
        lapTimer = nil
        lapArray.removeAll()
        started = false
        isTimerRunning = false
        colorCell = false
        tableView.reloadData()
    }
    
    func addLap(){
        let lapIndex = lapArray.count + 1
        let newLap = Lap(title: "Lap" + "\(lapIndex)", seconds: lapCounter)
        lapCounter = 0
        lapArray.append(newLap)
        if lapArray.count >= 2{
            colorCell = true
            if lapArray[ lapArray.count - 1].seconds > lapArray[ maxIndex ].seconds{
                maxIndex = lapArray.count - 1
                print( maxIndex )
            }else if lapArray[ lapArray.count - 1].seconds < lapArray[ minIndex ].seconds{
                minIndex = lapArray.count - 1
            }
        }
        tableView.reloadData()
    }
    
    func updateButtonTitle( button : UIButton, title : String, color : UIColor){
        button.setTitle(title, for: .normal)
    }
    
    //MARK: - TableView Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if started{
            return lapArray.count + 1
        }
        return lapArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "TimerCell", for: indexPath)
            cell.textLabel!.text = "Lap " + "\(lapArray.count + 1)"
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "LapCell", for: indexPath)
        let index = lapArray.count - indexPath.row
        if colorCell{
            if index == maxIndex{
                //cell.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
                cell.textLabel?.textColor = #colorLiteral(red: 0, green: 0.9832226634, blue: 0.578263104, alpha: 1)
                cell.detailTextLabel?.textColor = #colorLiteral(red: 0, green: 0.9832226634, blue: 0.578263104, alpha: 1)
            }else if index == minIndex{
                cell.textLabel?.textColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
                cell.detailTextLabel?.textColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            }else{
                cell.textLabel?.textColor = .black
                cell.detailTextLabel?.textColor = .black
            }
        }
        let lap = lapArray[ index ]
        cell.textLabel!.text = lap.title
        cell.detailTextLabel!.text! = secondsToHourMinuteSecond(seconds: lap.seconds )
        return cell
    }
    
}
 
