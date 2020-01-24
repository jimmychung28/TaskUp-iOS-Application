//
//  colorViewController.swift
//  Todoey
//
//  Created by Jimmy Chung on 2019-05-08.
//  Copyright © 2019 Jimmy Chung. All rights reserved.
//

import UIKit
import ChromaColorPicker

protocol colorViewControllerDelegate {
    func changeColor(color:UIColor,indexPath:IndexPath)
}
class colorViewController: UIViewController,ChromaColorPickerDelegate {
    var delegate:colorViewControllerDelegate?
    var path:IndexPath?
    func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
        delegate?.changeColor(color:colorPicker.currentColor,indexPath:path!)
        self.dismiss(animated: true, completion: nil)
    }
    

    @IBAction func doneButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let neatColorPicker = ChromaColorPicker(frame: CGRect(x: self.view.frame.size.width/2-(self.view.frame.size.width-50)/2, y: self.view.frame.size.height/2-(self.view.frame.size.width-50)/2, width: self.view.frame.size.width-50, height: self.view.frame.size.width-50))
        neatColorPicker.delegate = self //ChromaColorPickerDelegate
        neatColorPicker.padding = 5
        neatColorPicker.stroke = 3
        neatColorPicker.hexLabel.textColor = UIColor.white
        
        view.addSubview(neatColorPicker)
        // Do any additional setup after loading the view.
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
