//
//  ViewController.swift
//  CurrencyExchangeApp
//
//  Created by Hnin Yi on 9/6/19.
//  Copyright © 2019 Hnin Yi San. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate {
    
    @IBOutlet weak var dateData: UIDatePicker!
    @IBOutlet weak var fromPicker: UIPickerView!
    @IBOutlet weak var toPicker: UIPickerView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var busyInd: UIActivityIndicatorView!
    
    private let apiUrlString = "http://data.fixer.io/api/"
    private var urlDate = "latest"
    private let apiKey = "c471102c5e084f4a5ea8e5e77bdfa21e"
    private let symbol = "USD,THB,SGD,MMK,JPY,CNY,MYR,BND,LAK,CAD,AUD,INR,KRW"
    
    var symbols = ["USD","EUR","THB","SGD","MMK","JPY","CNY","MYR","BND","LAK","CAD","AUD","INR","KRW"]
    
    private var fromsymbol = "EUR"
    private var tosymbol = "MMK"
    
    func hidebusy(){
        busyInd.stopAnimating()
        busyInd.isHidden = true
    }
    func showbusy(){
        busyInd.isHidden = false
        busyInd.startAnimating()
    }
    
    func setup(){
        showbusy()
        fetchData(fromsymbolString: fromsymbol, tosymbolString: tosymbol)
    }
    
    func fetchData(fromsymbolString:String, tosymbolString:String) {
        let latestUrlString = apiUrlString + urlDate + "?access_key=" + apiKey + "&symbols=" + symbol
        print(latestUrlString)
        guard let latestUrl = URL(string: latestUrlString) else {
            print("Invalid URL")
            return
        }
        print("URl",latestUrl)
        let request = URLRequest(url: latestUrl)
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else { print("sessionerror")
                return}
            
            guard data != nil else { return}
            print("Ok! ready to get data")
            do {
                if let dictionary = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:Any]
                {
                    let rate = dictionary["rates"] as? [String:Double]
                    if let rate = rate {
                    
                    if (self.fromsymbol == "EUR" && self.tosymbol == "EUR") {
                            OperationQueue.main.addOperation {
                                self.resultLabel.text = "1 \(self.fromsymbol) = \(1.0) \(self.tosymbol)"
                            }
                    }
                    else if self.fromsymbol == "EUR" {
                    var symbolmoney = 0.0
                    let tosymbolrate = rate[self.tosymbol] as? Double
                        if let tosymbolrate = tosymbolrate {
                            symbolmoney = (tosymbolrate * 10000).rounded() / 10000
                            print("from symbol rate",self.fromsymbol,rate[self.fromsymbol])
                        }
                    OperationQueue.main.addOperation {
                        self.resultLabel.text = "1 \(self.fromsymbol) = \(symbolmoney) \(self.tosymbol)"
                    }
                    }
                    else if self.tosymbol == "EUR" {
                        let fromsymbolrate = rate[self.fromsymbol] as? Double
                        
                        var tosymbolmoney = 0.0
                        if let fromsymbolrate = fromsymbolrate {
                            tosymbolmoney = 1 / fromsymbolrate
                            tosymbolmoney = (tosymbolmoney * 10000).rounded() / 10000
                        }
                        
                        OperationQueue.main.addOperation {
                            self.resultLabel.text = "1 \(self.fromsymbol) = \(tosymbolmoney) \(self.tosymbol)"
                        }
                    }
                    else {
                        let tosymbolrate = rate[self.tosymbol] as? Double
                        let fromsymbolrate = rate[self.fromsymbol] as? Double
                        
                        var tosymbolmoney = 0.0
                        if let fromsymbolrate = fromsymbolrate, let tosymbolrate = tosymbolrate {
                            print("from to symbol rate",fromsymbolrate,tosymbolrate)
                            tosymbolmoney = tosymbolrate / fromsymbolrate
                            tosymbolmoney = (tosymbolmoney * 10000).rounded() / 10000
                        }
                        
                        OperationQueue.main.addOperation {
                            self.resultLabel.text = "1 \(self.fromsymbol) = \(tosymbolmoney) \(self.tosymbol)"
                        }
                    }
                    }
                }
            }
            catch let error {
                print(error.localizedDescription)
            }
        }
        busyInd.stopAnimating()
        busyInd.isHidden = false
        task.resume()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return symbols.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return symbols[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            fromsymbol = symbols[fromPicker.selectedRow(inComponent: 0)]
            tosymbol = symbols[toPicker.selectedRow(inComponent: 0)]
        fetchData(fromsymbolString: fromsymbol, tosymbolString: tosymbol)
    }
    
    @IBAction func CalculateAmount(_ sender: UIButton) {
        var amount:Double = Double(amountTextField.text!) ?? 0.0
        var result:Double = 0.0
        print(amount,self.fromsymbol,self.tosymbol)
        let latestUrlString = apiUrlString + urlDate + "?access_key=" + apiKey + "&symbols=" + symbol
        print(latestUrlString)
        guard let latestUrl = URL(string: latestUrlString) else {
            return
        }
        let request = URLRequest(url: latestUrl)
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else { print("sessionerror")
                return}
            
            guard data != nil else { return}
            print("Ok! ready to get data to calculate")
            do {
                if let dictionary = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:Any]
                {
                    let rate = dictionary["rates"] as? [String:Double]
                    if let rate = rate {
                            var symbolmoney = 0.0
                        var tosymbolrate:Double? = 0.0
                        var fromsymbolrate:Double? = 0.0
                        
                        if self.fromsymbol == "EUR" {
                            tosymbolrate = rate[self.tosymbol] as? Double
                            fromsymbolrate = 1.0
                        }
                        else if self.tosymbol == "EUR" {
                            tosymbolrate = 1.0 / rate[self.fromsymbol]!
                            fromsymbolrate = 1.0
                        }
                        else {
                            tosymbolrate = rate[self.tosymbol] as? Double
                             fromsymbolrate = rate[self.fromsymbol] as? Double
                        }
                        
                        var tosymbolmoney = 0.0
                        if let fromsymbolrate = fromsymbolrate, let tosymbolrate = tosymbolrate {
                            tosymbolmoney = tosymbolrate / fromsymbolrate
                            tosymbolmoney = (tosymbolmoney * 10000).rounded() / 10000
                            result = tosymbolmoney * amount
                            result = (result * 10000).rounded() / 10000
                        }
                        
                        OperationQueue.main.addOperation {
                            self.resultLabel.text = "\(amount) \(self.fromsymbol) = \(result) \(self.tosymbol)"
                        }
                    }
                }
            }
            catch let error {
                print(error.localizedDescription)
            }
        }
        busyInd.stopAnimating()
        busyInd.isHidden = false
        task.resume()
    }
    
    @IBAction func tagview(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    @IBAction func refresh(_ sender: UIButton) {
        amountTextField.text = nil
        fromPicker.selectRow(0, inComponent: 0, animated: true)
        toPicker.selectRow(0, inComponent: 0, animated: true)
        dateData.date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let dateString = dateFormatter.string(from: dateData.date)
        print(dateString)
        self.urlDate = dateString
        self.fromsymbol = "EUR"
        self.tosymbol = "MMK"
        fetchData(fromsymbolString: fromsymbol, tosymbolString: tosymbol)
    }
    
    @IBAction func chooseDate(_ sender: UIDatePicker) {
        dateData.maximumDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let dateString = dateFormatter.string(from: sender.date)
        print(dateString)
        self.urlDate = dateString
        fetchData(fromsymbolString: fromsymbol, tosymbolString: tosymbol)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        symbols.sort()
        busyInd.isHidden = true
       setup()
    }
}
