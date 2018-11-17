//
//  LoginViewController.swift
//  splash
//
//  Created by Muhammed Eren Dursun on 2.11.2018.
//  Copyright © 2018 Muhammed Eren Dursun. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    private var gradient: CAGradientLayer!
    
    @IBOutlet weak var circleMedium: UIVisualEffectView!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var circleBig: UIVisualEffectView!
    @IBOutlet weak var gradienView: UIImageView!
    @IBOutlet weak var line: UIImageView!
    @IBOutlet weak var circleSmall: UIVisualEffectView!
    @IBOutlet weak var loading: UIImageView!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var signupBtn: UIButton!
    
    let colorStart: UIColor = UIColor( red: CGFloat(48/255.0), green: CGFloat(207/255.0), blue: CGFloat(208/255.0), alpha: CGFloat(1.0) )
    let colorEnd: UIColor = UIColor( red: CGFloat(51/255.0), green: CGFloat(8/255.0), blue: CGFloat(103/255.0), alpha: CGFloat(1.0) )
    
    let LOGIN_URL = "http://192.168.31.58:3000/api/login"
    
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
        
        
        UIView.animate(withDuration: 1, delay: 0, options: [.autoreverse, .repeat], animations: {
            self.circleBig.alpha = 0
        })
        
        loginBtn.layer.cornerRadius = loginBtn.frame.size.height/2
        loginBtn.clipsToBounds = true
        
        loginBtn.layer.borderColor = colorEnd.cgColor
        loginBtn.layer.borderWidth = 2.0
        
        
        gradient = CAGradientLayer()
        gradient.frame = gradienView.bounds
        gradient.colors = [colorStart.cgColor, colorEnd.cgColor]
        gradient.locations = [0.0, 1.1]
        gradienView.layer.addSublayer(gradient)
    }
    
 
    @IBAction func signupBtnOut(_ sender: Any) {
        UIView.animate(withDuration: 0.3, animations: {
            self.line.frame.origin.x += 332/2-48
            self.line.frame.size.width = 96
        })
    }
    
    @IBAction func signupBtnDown(_ sender: Any) {
        UIView.animate(withDuration: 0.3, animations: {
            self.line.frame.origin.x -= 332/2-48
            self.line.frame.size.width = 332
        })
    }
    @IBAction func signupBtnClick(_ sender: Any) {
        self.performSegue(withIdentifier: "signupSegue", sender: nil)
    }
    
    @IBAction func loginBtnClick(_ sender: Any) {
        
         loginRequest()
        
    }
    func loginRequest() {
        
        let userMail = self.userName.text
        let userPassword = self.userPassword.text
        let deviceToken="f70-YvIIRmw:APA91bHjY_7k5ITPbGZmJkYjHMhYyI71ieKzCXCK75j-Rs6BqY1G5C-zUla394clbTVoqXANtTXSWUVek_QGhDgh9UgpPFFeVnwNuc3Dhh49XDooYJYvD_1Fw3GP_EN96Hnfkk_RuECl"
        
        messageShow(messageText: "Lütfen Bekleyin")
        
        loadingButton(button: loginBtn, isLoading: true)
        
        let parameters = ["userMail": userMail ,"userPassword": userPassword ,"deviceToken": deviceToken,"appCheck": "com.med.splash"]
        
        guard let url = URL(string: LOGIN_URL)
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
    
    func messageShow(messageText:String)  {
        self.message.alpha = 0
        message.isHidden=false
        message.text = messageText
        
        UIView.animate(withDuration: 0.3, animations: {
            self.message.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 3, animations: {
               self.message.alpha = 0
            })
        }
    }
    
    func loginCompleted(status:String, message:String) {
        
        switch status {
        case "true":
            messageShow(messageText: message)
            loadingButton(button: loginBtn, isLoading: false)
            self.performSegue(withIdentifier: "loginAppSegue", sender: nil)
        case "false":
            
            self.message.font = self.message.font.withSize(24)
             messageShow(messageText: message)
            loadingButton(button: loginBtn, isLoading: false)
            loginBtn.setTitle("Tekrar Deneyin",for: .normal)
          
            
        default:
            self.message.font = self.message.font.withSize(24)
            messageShow(messageText: "İnternet Bağlantınızı Kontrol Edin")
            loadingButton(button: loginBtn, isLoading: false)
            loginBtn.setTitle("Tekrar Deneyin",for: .normal)
           
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
