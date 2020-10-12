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
    
    var currentColor: UIColor?
    
    let colorPicker = ChromaColorPicker()
    let brightnessSlider = ChromaBrightnessSlider()
    

    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        delegate?.changeColor(color:currentColor!,indexPath:path!)
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setupColorPicker() {
        colorPicker.delegate = self
        colorPicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(colorPicker)
        
        let verticalOffset = -defaultColorPickerSize.height / 6
        
        NSLayoutConstraint.activate([
            colorPicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            colorPicker.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: verticalOffset),
            colorPicker.widthAnchor.constraint(equalToConstant: self.view.frame.size.width-50),
            colorPicker.heightAnchor.constraint(equalToConstant: self.view.frame.size.width-50)
        ])
    }
    
    private func setupBrightnessSlider() {
        brightnessSlider.connect(to: colorPicker)
        
        // Style
        brightnessSlider.trackColor = UIColor.blue
        brightnessSlider.handle.borderWidth = 3.0 // Example of customizing the handle's properties.
        
        // Layout
        brightnessSlider.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(brightnessSlider)
        
        NSLayoutConstraint.activate([
            brightnessSlider.centerXAnchor.constraint(equalTo: colorPicker.centerXAnchor),
            brightnessSlider.topAnchor.constraint(equalTo: colorPicker.bottomAnchor, constant: 28),
            brightnessSlider.widthAnchor.constraint(equalTo: colorPicker.widthAnchor, multiplier: 0.9),
            brightnessSlider.heightAnchor.constraint(equalTo: brightnessSlider.widthAnchor, multiplier: brightnessSliderWidthHeightRatio)
        ])
    }
    
    private func setupColorPickerHandles() {

        colorPicker.addHandle(at: currentColor)
    }
    
    func colorPickerHandleDidChange(_ colorPicker: ChromaColorPicker, handle: ChromaColorHandle, to color: UIColor) {
        currentColor = color
        // Here I can detect when the color is too bright to show a white icon
        // on the handle and change its tintColor.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupColorPicker()
        setupBrightnessSlider()
        setupColorPickerHandles()
    }
    
    private let defaultColorPickerSize = CGSize(width: 320, height: 320)
    private let brightnessSliderWidthHeightRatio: CGFloat = 0.1

}
