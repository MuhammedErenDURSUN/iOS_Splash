//
//  ViewController.swift
//  splash
//
//  Created by Muhammed Eren Dursun on 28.10.2018.
//  Copyright © 2018 Muhammed Eren Dursun. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private var gradient: CAGradientLayer!
    
    @IBOutlet weak var circleMedium: UIVisualEffectView!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var welcomeBtn: UIButton!
    @IBOutlet weak var circleBig: UIVisualEffectView!
    @IBOutlet weak var gradienView: UIImageView!
    @IBOutlet weak var line: UIImageView!
    @IBOutlet weak var circleSmall: UIVisualEffectView!
    @IBOutlet weak var loading: UIImageView!
    let colorStart: UIColor = UIColor( red: CGFloat(48/255.0), green: CGFloat(207/255.0), blue: CGFloat(208/255.0), alpha: CGFloat(1.0) )
    let colorEnd: UIColor = UIColor( red: CGFloat(51/255.0), green: CGFloat(8/255.0), blue: CGFloat(103/255.0), alpha: CGFloat(1.0) )
    
    var welcomeBtnEvent = ""
    
    let AUTO_LOGIN_URL = "http://192.168.31.58:3000/api/autologin"
    let SERVER_CHECK_URL = "http://192.168.31.58:3000/api/server"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        circleSmall.layer.cornerRadius = circleSmall.frame.size.width/2
        circleSmall.clipsToBounds = true
        
        circleMedium.layer.cornerRadius = circleMedium.frame.size.width/2
        circleMedium.clipsToBounds = true
        
        circleBig.layer.cornerRadius = circleBig.frame.size.width/2
        circleBig.clipsToBounds = true
        
        loading.layer.cornerRadius = loading.frame.size.width/2
        loading.clipsToBounds = true
        
        
        
        
        UIView.animate(withDuration: 2, delay: 0, options: [.autoreverse, .repeat], animations: {
            self.line.frame.origin.x = self.message.frame.size.width-32
        })
        
        UIView.animate(withDuration: 1, delay: 0, options: [.autoreverse, .repeat], animations: {
            self.circleBig.alpha = 0
        })
        welcomeBtn.layer.cornerRadius = welcomeBtn.frame.size.height/2
        welcomeBtn.clipsToBounds = true
        
        welcomeBtn.layer.borderColor = colorEnd.cgColor
        welcomeBtn.layer.borderWidth = 2.0
        
        
        gradient = CAGradientLayer()
        gradient.frame = gradienView.bounds
        gradient.colors = [colorStart.cgColor, colorEnd.cgColor]
        gradient.locations = [0.0, 1.1]
        gradienView.layer.addSublayer(gradient)
        
        serviceCheck()
    }
    @IBAction func welcomeBtnClick(_ sender: Any) {
        
        switch welcomeBtnEvent {
        case "login":
            self.performSegue(withIdentifier: "loginSegue", sender: nil)
        case "loginAgain":
            loginRequest()
        case "CheckAgain":
            serviceCheck()
        default:
            serviceCheck()
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    func serviceCheck() {
        
        message.font = message.font.withSize(24)
        message.text="Lütfen Bekleyin"
        
        loadingButton(button: welcomeBtn, isLoading: true)
        
        let parameters = ["serviceCheck": "com.med.splash"]
        
        guard let url = URL(string: SERVER_CHECK_URL)
            else {
                self.splashControl(status: "error")
                return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
            else {
                self.splashControl(status: "error")
                return
        }
        
        request.httpBody = httpBody
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    let list = json as! NSArray
                    let obj = list[0] as! NSDictionary
                    let status = obj["serviceCheck"] as! String
                    
                    DispatchQueue.main.async(execute: {self.splashControl(status: status)})
                        
                } catch {
                    DispatchQueue.main.async(execute: {self.splashControl(status: "error")})
                }
              }
            else {
            DispatchQueue.main.async(execute: {self.splashControl(status: "error")})
            return
            }
        }
        
        task.resume()
        
        
    }
    
    func splashControl(status:String)
    {
        let userMail=" "
        let loginStatus = "false"
        let userName = "MED"
        switch status {
            case "true":
                if userMail == " " {
                    message.font = message.font.withSize(42)
                    message.text="Merhaba"
                    loadingButton(button: welcomeBtn, isLoading: false)
                    welcomeBtn.setTitle("Devam Et",for: .normal)
                    welcomeBtnEvent = "login"
                    
                    }
                
               else if loginStatus == "false" {
                    message.font = message.font.withSize(24)
                    message.text="Merhaba \(userName)"
                    loadingButton(button: welcomeBtn, isLoading: false)
                    welcomeBtn.setTitle("Giriş Yap",for: .normal)
                    welcomeBtnEvent = "login"
                    
                    }
                
               else if loginStatus == "true" {
                    message.font = message.font.withSize(24)
                    message.text="Merhaba \(userName)"
                    loadingButton(button: welcomeBtn, isLoading: false)
                    loginRequest()
                    
                    }
                    
                else {
                    message.font = message.font.withSize(24)
                    message.text="Bir sorun oluştu"
                    loadingButton(button: welcomeBtn, isLoading: false)
                    welcomeBtn.setTitle("Tekrar Deneyin",for: .normal)
                    welcomeBtnEvent = "loginAgain"
                    
                    }
            case "care":
                message.font = message.font.withSize(24)
                message.text="Geçici olarak bakımdayız"
                loadingButton(button: welcomeBtn, isLoading: false)
                welcomeBtn.setTitle("Tekrar Deneyin",for: .normal)
                welcomeBtnEvent = "CheckAgain"

            default:
                message.font = message.font.withSize(24)
                message.text="İnternet Bağlantınızı Kontrol Edin"
                loadingButton(button: welcomeBtn, isLoading: false)
                welcomeBtn.setTitle("Tekrar Deneyin",for: .normal)
                welcomeBtnEvent = "CheckAgain"
            
        
        }
        
    }
    
    func loginRequest() {
        
        let userMail="m.erendursun@gmail.com"
        let userPassword="12345678"
        let deviceToken="f70-YvIIRmw:APA91bHjY_7k5ITPbGZmJkYjHMhYyI71ieKzCXCK75j-Rs6BqY1G5C-zUla394clbTVoqXANtTXSWUVek_QGhDgh9UgpPFFeVnwNuc3Dhh49XDooYJYvD_1Fw3GP_EN96Hnfkk_RuECl"
        
        message.font = message.font.withSize(24)
        message.text="Lütfen Bekleyin"
        loadingButton(button: welcomeBtn, isLoading: true)
        
        let parameters = ["userMail": userMail ,"userPassword": userPassword ,"deviceToken": deviceToken,"appCheck": "com.med.splash"]
        
        guard let url = URL(string: AUTO_LOGIN_URL)
            else {
                self.loginCompleted(status: "error", message: "error")
                return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
            else {
                self.loginCompleted(status: "error", message: "error")
                return
        }
        
        request.httpBody = httpBody
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    let list = json as! NSArray
                    let obj = list[0] as! NSDictionary
                    let status = obj["status"] as! String
                    let message = obj["message"] as! String
                    
                    DispatchQueue.main.async(execute: {self.loginCompleted(status: status, message: message)})
                    
                } catch {
                    DispatchQueue.main.async(execute: {self.loginCompleted(status: "error", message: "error")})
                }
            }
            else {
                DispatchQueue.main.async(execute: {self.loginCompleted(status: "error", message: "error")})
                return
            }
        }
        
        task.resume()
        
        
    }
    
    func loginCompleted(status:String, message:String) {
        
        switch status {
            case "true":
                self.message.font = self.message.font.withSize(24)
                self.message.text = message
                loadingButton(button: welcomeBtn, isLoading: false)
                self.performSegue(withIdentifier: "appSegue", sender: nil)
            case "false":
                
                self.message.font = self.message.font.withSize(24)
                self.message.text = message
                loadingButton(button: welcomeBtn, isLoading: false)
                welcomeBtn.setTitle("Tekrar Deneyin",for: .normal)
                welcomeBtnEvent = "loginAgain"
            
            case "deviceError":
                self.message.font = self.message.font.withSize(24)
                self.message.text = message
                loadingButton(button: welcomeBtn, isLoading: false)
                welcomeBtn.setTitle("Giriş Yap",for: .normal)
                welcomeBtnEvent = "login"
            
            default:
                self.message.font = self.message.font.withSize(24)
                self.message.text = "İnternet Bağlantınızı Kontrol Edin"
                loadingButton(button: welcomeBtn, isLoading: false)
                welcomeBtn.setTitle("Tekrar Deneyin",for: .normal)
                welcomeBtnEvent = "loginAgain"
        }
        
    }
    
    func loadingButton(button:UIButton,isLoading:Bool) {
        
        if isLoading{
            
             button.setTitle("",for: .normal)
             UIView.animate(withDuration: 0.3, animations: {
             button.frame.origin.x += 332/2-21
             button.frame.size.width = 42
             })
              self.loading.isHidden=false
            
             UIView.animate(withDuration: 0.5, delay: 0, options: [.autoreverse, .repeat], animations: {
             self.loading.transform = CGAffineTransform(rotationAngle: CGFloat(180.0 * Double.pi / 180))
             })
            
        }
        else {
            
            self.loading.stopAnimating()
            self.loading.isHidden=true
        
            UIView.animate(withDuration: 0.3, animations: {
                button.frame.origin.x -= 332/2-21
                button.frame.size.width = 332
            })
        }
    }
}
