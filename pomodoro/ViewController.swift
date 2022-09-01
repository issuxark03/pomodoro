//
//  ViewController.swift
//  pomodoro
//
//  Created by Yongwoo Yoo on 2022/03/10.
//

import UIKit
import AudioToolbox

enum TimerStatus {
	case start
	case pause
	case end
}

class ViewController: UIViewController {

	@IBOutlet weak var timerLabel: UILabel!
	@IBOutlet weak var progressView: UIProgressView!
	@IBOutlet weak var datePicker: UIDatePicker!
	
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var toggleButton: UIButton!
	@IBOutlet weak var imageView: UIImageView!
	
	var duration = 60 //datepicker의 초기값이 60
	var timerStatus: TimerStatus = .end
	var timer: DispatchSourceTimer?
	var currentSeconds = 0
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.configureToggleButton()
	}
	
	func setTimerInfoViewVisible(isHidden: Bool) {
		self.timerLabel.isHidden = isHidden
		self.progressView.isHidden = isHidden
	}
	
	func configureToggleButton() {
		self.toggleButton.setTitle("시작", for: .normal) //normal일때 시작
		self.toggleButton.setTitle("일시정지", for: .selected) //selected일때 일시정지
	}
	
	func startTimer() {
		if self.timer == nil {
			self.timer = DispatchSource.makeTimerSource(flags: [], queue: .main) //main thread
			self.timer?.schedule(deadline: .now(), repeating: 1) //now(바로실행), 1초마다 반복
			self.timer?.setEventHandler(handler: { [weak self] in  //1초에 한번씩 handler안에 closure function이 실행
				guard let self = self else { return }
				self.currentSeconds -= 1
				
				let hour = self.currentSeconds / 3600
				let minutes = (self.currentSeconds % 3600) / 60
				let seconds = (self.currentSeconds % 3600) % 60
				self.timerLabel.text = String(format: "%02d:%02d:%02d", hour, minutes, seconds)
				self.progressView.progress = Float(self.currentSeconds) / Float(self.duration)
				
				UIView.animate(withDuration: 0.5, delay: 0, animations: {
					self.imageView.transform = CGAffineTransform(rotationAngle: .pi) //180
				})
				UIView.animate(withDuration: 0.5, delay: 0.5, animations: {
					self.imageView.transform = CGAffineTransform(rotationAngle: .pi * 2) //360
				})
				
				if self.currentSeconds <= 0 { //0초
					AudioServicesPlaySystemSound(1005) // http://iphonedev.wiki/index.php/AudioServices
					self.stopTimer()
					
				}
			})
			self.timer?.resume()
		}
	}
	
	func stopTimer() {
		if self.timerStatus == .pause {
			self.timer?.resume()
		}
		self.timerStatus = .end
		self.cancelButton.isEnabled = false
		UIView.animate(withDuration: 0.5, animations: {
			self.timerLabel.alpha = 0
			self.progressView.alpha = 0
			self.datePicker.alpha = 1
			self.imageView.transform = .identity //원상태로 복귀
		})
		self.toggleButton.isSelected = false
		self.timer?.cancel()
		self.timer = nil //memory release
	}

	@IBAction func tabCancelButton(_ sender: UIButton) {
		
		switch timerStatus {
		case .start, .pause:
			self.stopTimer()

		default:
			break
		}
	}
	
	@IBAction func tabToggleButton(_ sender: UIButton) {
		self.duration = Int(self.datePicker.countDownDuration) // double -> int
		//debugPrint(self.duration)
		switch self.timerStatus {
		case .end:
			self.currentSeconds = self.duration
			self.timerStatus = .start
			UIView.animate(withDuration: 0.5, animations: {
				self.timerLabel.alpha = 1
				self.progressView.alpha = 1
				self.datePicker.alpha = 0
			})
			self.toggleButton.isSelected = true
			self.cancelButton.isEnabled = true
			self.startTimer()
		case .start:
			self.timerStatus = .pause
			self.toggleButton.isSelected = false
			self.timer?.suspend() //일시정지
			
		case .pause:
			self.timerStatus = .start
			self.toggleButton.isSelected = true
			self.timer?.resume() //재시작
			
		}
	}
}

