//
//  Utils.swift
//  TiPolyfill
//
//  Created by Hans Knöchel on 02.03.25.
//

import CoreGraphics

func convertMultiPageTIFFToPDF(url: URL, filename: String) -> URL? {
    // Create a CGImageSource from the TIFF file
  guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else {
      print("Failed to create image source")
      return nil
  }
  
    // Get the number of pages in the TIFF
    let pageCount = CGImageSourceGetCount(imageSource)
    guard pageCount > 0 else {
        print("No images found in TIFF")
        return nil
    }
    
    // Create a PDF document
    let pdfData = NSMutableData()
    
    // Use the size of the first image for the PDF page size
    var pdfPageBounds = CGRect(x: 0, y: 0, width: 612, height: 792) // Default to US Letter size
    
    if let firstImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) {
        let firstUIImage = UIImage(cgImage: firstImage)
  
        pdfPageBounds = CGRect(x: 0, y: 0, width: firstUIImage.size.width, height: firstUIImage.size.height)
        // Release the CGImage to free memory
        // (firstImage is automatically released by ARC)
    }
    
    UIGraphicsBeginPDFContextToData(pdfData, pdfPageBounds, nil)
    
    // Process each page of the TIFF
    for i in 0..<pageCount {
        guard let cgImage = CGImageSourceCreateImageAtIndex(imageSource, i, nil) else {
            continue
        }
        
        // Create a new PDF page for each TIFF page
        UIGraphicsBeginPDFPage()
        
        // Get the current graphics context
        guard let context = UIGraphicsGetCurrentContext() else {
            continue
        }
        
        // TIFF images and PDF have different coordinate systems, so we need to flip the context
        context.translateBy(x: 0, y: pdfPageBounds.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        // Draw the image
        context.draw(cgImage, in: pdfPageBounds)
    }
    
    // End the PDF context
    UIGraphicsEndPDFContext()
    
    // Save PDF to temporary file
    let pdfURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(filename).pdf")
  
    NSLog("[WARN] Save to: \(pdfURL.absoluteString)")
  
    try? pdfData.write(to: pdfURL, options: .atomic)
    
    return pdfURL
}

