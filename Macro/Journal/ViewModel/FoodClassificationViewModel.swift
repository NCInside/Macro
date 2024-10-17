//
//  FoodClassificationViewModel.swift
//  Macro
//
//  Created by WanSen on 17/10/24.
//


import Foundation
import Combine
import Vision
import VisionKit

class FoodClassificationViewModel: ObservableObject {
    
    @Published var imageClassificationText: [String] = []
    @Published var imageClassificationProb: [Double] = []
    
    var cancellable = Set<AnyCancellable>()
    
    func FoodClassificationModel(uiImage: UIImage) {
        
        imageClassificationText.removeAll()
        imageClassificationProb.removeAll()
        
        let resizeImage = uiImage.resizeImageTo(size: CGSize(width: 299, height: 299))
        
        guard let cvPixelBuffer = resizeImage?.pixelBuffer() else { return }
        
        do {
            let model = try FoodClassification(configuration: MLModelConfiguration())
            let prediction = try model.prediction(image: cvPixelBuffer)
            
            
            var predictionPairs: [(target: String, probability: Double)] = []
            for (target, prob) in prediction.targetProbability {
                predictionPairs.append((target, prob))
            }
            
            
            predictionPairs.sort { $0.probability > $1.probability }
            
            
            for pair in predictionPairs {
                appendText(text: pair.target)
                appendProb(prob: pair.probability)
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }

    
    func appendText(text: String) {
        DispatchQueue.main.async { [weak self] in
            self?.imageClassificationText.append(text)
        }
    }
    
    func appendProb(prob: Double) {
        DispatchQueue.main.async { [weak self] in
            self?.imageClassificationProb.append(prob)
        }
    }
}
